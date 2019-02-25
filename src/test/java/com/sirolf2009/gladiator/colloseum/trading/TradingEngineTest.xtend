package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.timeseries.Point
import com.sirolf2009.commonwealth.trading.IPosition
import com.sirolf2009.commonwealth.trading.Trade
import com.sirolf2009.commonwealth.trading.orderbook.LimitOrder
import com.sirolf2009.gladiator.colloseum.position.OpenPositionFIFO
import com.sirolf2009.gladiator.colloseum.trading.event.EventOrderHit
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionClosed
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionOpened
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionUpdate
import com.sirolf2009.gladiator.colloseum.trading.event.IEvent
import com.sirolf2009.gladiator.colloseum.trading.fee.PercentageFeeCalculator
import java.util.List
import org.junit.Test

import static junit.framework.Assert.*
import com.sirolf2009.gladiator.colloseum.position.IOpenColloseumPosition

class TradingEngineTest {
	
	@Test
	def void testOrderPlacing() {
		val engine = new TradingEngine(new PercentageFeeCalculator(0d, 0d), OpenPositionFIFO.FACTORY)
		
		engine.onNewPrice(new Trade(new Point(0, 100), 1)).assertEmpty()
		engine.placeBidOrder(new LimitOrder(99, 1))
		engine.onNewPrice(new Trade(new Point(1, 98), 1)) => [
			assertSize(2)
			assertBoughtAt(99)
			newPosition => [
				assertTrue(isLong())
				assertFalse(isShort())
				assertFalse(isClosed())
				assertEquals(1d, getSize())
				assertEquals(99d, getEntryPrice())
			]
		]
		engine.bidOrders.assertEmpty()
		engine.placeBidOrder(new LimitOrder(97, 1))
		engine.onNewPrice(new Trade(new Point(2, 96), 1)) => [
			assertSize(2)
			assertBoughtAt(97)
			getPosition.get() => [
				assertTrue(isLong())
				assertFalse(isShort())
				assertFalse(isClosed())
				assertEquals(2d, getSize())
				assertEquals((99d+97d)/2, getEntryPrice())
			]
		]
		
		engine.placeAskOrder(new LimitOrder(100, -1))
		engine.onNewPrice(new Trade(new Point(3, 101), 1)) => [
			assertSize(2)
			assertSoldAt(100)
			getPosition.get() => [
				assertTrue(isLong())
				assertFalse(isShort())
				assertFalse(isClosed())
				assertEquals(1d, getSize())
				assertEquals(97d, getEntryPrice())
			]
		]
		engine.placeAskOrder(new LimitOrder(102, -1))
		engine.onNewPrice(new Trade(new Point(4, 103), 1)) => [
			assertSize(3)
			assertSoldAt(102)
			assertFalse(getPosition().isPresent())
			getClosedPosition() => [
				assertTrue(entry.bought())
				assertFalse(entry.sold())
				assertEquals(entry.getPrice().intValue(), 98)
				assertEquals(entry.getAmount().intValue(), 2)
				assertTrue(exit.sold())
				assertFalse(exit.bought())
				assertEquals(exit.getPrice().intValue(), 101)
				assertEquals(exit.getAmount().intValue(), -2)
				assertTrue(isLong())
				assertFalse(isShort())
				assertEquals(2d, getSize())
				
				/*
				 * Buy at 99, sell at 100, 1$ profit
				 * Buy at 97, sell at 102, 5$ profit
				 * Total profit: $6
				 */
				 assertEquals(6, getProfit(), 0.001d)
			]
		]
	}
	
	@Test
	def void testNoOrderHit() {
		val engine = new TradingEngine(new PercentageFeeCalculator(0d, 0d), OpenPositionFIFO.FACTORY)
		
		engine.onNewPrice(new Trade(new Point(0, 100), 1)).assertEmpty()
		engine.placeBidOrder(new LimitOrder(99, 1))
		engine.onNewPrice(new Trade(new Point(1, 100), 1)).assertEmpty()
		engine.onNewPrice(new Trade(new Point(2, 101), 1)).assertEmpty()
	}
	
	@Test
	def void testOrderHit() {
		val engine = new TradingEngine(new PercentageFeeCalculator(0d, 0d), OpenPositionFIFO.FACTORY)
		
		engine.onNewPrice(new Trade(new Point(0, 100), 1)).assertEmpty()
		engine.placeBidOrder(new LimitOrder(99, 1))
		engine.onNewPrice(new Trade(new Point(0, 98), 1)) => [
			assertSize(2)
			assertBoughtAt(99)
			newPosition => [
				assertTrue(isLong())
				assertFalse(isShort())
				assertFalse(isClosed())
				assertEquals(1d, getSize())
			]
		]
	}
	
	def void assertEmpty(List<?> list) {
		list.assertSize(0)
	}
	
	def void assertSize(List<?> list, int expectedSize) {
		assertEquals(expectedSize, list.size())
	}
	
	def IPosition getClosedPosition(List<IEvent> events) {
		val closedPositions = events.filter[it instanceof EventPositionClosed].map[it as EventPositionClosed].toList()
		assertEquals(1, closedPositions.size())
		return closedPositions.get(0).position
	}
	
	def IOpenColloseumPosition getNewPosition(List<IEvent> events) {
		val newPositions = events.filter[it instanceof EventPositionOpened].map[it as EventPositionOpened].toList()
		assertEquals(1, newPositions.size())
		return newPositions.get(0).position
	}
	
	def IOpenColloseumPosition getPosition(List<IEvent> events) {
		val positions = events.filter[it instanceof EventPositionUpdate].map[it as EventPositionUpdate].toList()
		assertEquals(1, positions.size())
		return positions.get(0).position
	}
	
	def void assertBoughtAt(List<IEvent> events, double price) {
		events.assertOrderHitAt(price)
		assertTrue(events.orders.get(0).order.amount.doubleValue() > 0)
	}
	
	def void assertSoldAt(List<IEvent> events, double price) {
		events.assertOrderHitAt(price)
		assertTrue(events.orders.get(0).order.amount.doubleValue() < 0)
	}
	
	def void assertOrderHitAt(List<IEvent> events, double price) {
		assertEquals(events.orders.size(), 1)
		val order = events.orders.get(0).order
		assertEquals(order.price.doubleValue, price, 0.00001)
	}
	
	def Iterable<EventOrderHit> getOrders(List<IEvent> events) {
		return events.filter[it instanceof EventOrderHit].map[it as EventOrderHit]
	}
	
}