package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.timeseries.Point
import com.sirolf2009.commonwealth.trading.Trade
import org.junit.Test

import static org.junit.Assert.*

class TradeSummaryTest {
	
	@Test
	def void testBuy() {
		val summary = new TradeSummary(new Trade(new Point(System.currentTimeMillis(), 1), 1))
		assertEquals(1d, summary.price)
		assertEquals(1d, summary.amount)
		assertTrue(summary.bought)
		assertFalse(summary.sold)
		
		summary.add(new Trade(new Point(System.currentTimeMillis(), 2), 1))
		assertEquals(1.5d, summary.price)
		assertEquals(2d, summary.amount)
		assertTrue(summary.bought)
		assertFalse(summary.sold)
	}
	
	@Test
	def void testSell() {
		val summary = new TradeSummary(new Trade(new Point(System.currentTimeMillis(), 1), -1))
		assertEquals(1d, summary.price)
		assertEquals(-1d, summary.amount)
		assertFalse(summary.bought)
		assertTrue(summary.sold)
		
		summary.add(new Trade(new Point(System.currentTimeMillis(), 2), -1))
		assertEquals(1.5d, summary.price)
		assertEquals(-2d, summary.amount)
		assertFalse(summary.bought)
		assertTrue(summary.sold)
	}
	
	def void assertEquals(double expected, double actual) {
		assertEquals(expected, actual, 0.00001)
	}
	
}