package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.timeseries.Point
import com.sirolf2009.commonwealth.trading.IPosition
import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.Trade
import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import com.sirolf2009.commonwealth.trading.orderbook.LimitOrder
import com.sirolf2009.gladiator.colloseum.position.IOpenPosition
import com.sirolf2009.gladiator.colloseum.position.IOpenPositionFactory
import com.sirolf2009.gladiator.colloseum.trading.event.EventOrderHit
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionClosed
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionOpened
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionUpdate
import com.sirolf2009.gladiator.colloseum.trading.event.IEvent
import com.sirolf2009.gladiator.colloseum.trading.fee.IFeeCalculator
import java.util.ArrayList
import java.util.Collections
import java.util.Date
import java.util.List
import java.util.Optional

class TradingEngine {

	val IFeeCalculator feeCalculator
	val IOpenPositionFactory positionFactory
	val closedPositions = new ArrayList<IPosition>()
	val askOrders = new ArrayList<ILimitOrder>()
	val bidOrders = new ArrayList<ILimitOrder>()
	var Optional<IOpenPosition> position = Optional.empty()
	var List<IEvent> events

	new(IFeeCalculator feeCalculator, IOpenPositionFactory positionFactory) {
		this.feeCalculator = feeCalculator
		this.positionFactory = positionFactory
	}

	def onNewPrice(ITrade trade) {
		return onNewBidAsk(trade.point.date, new LimitOrder(trade.point.x, trade.price.doubleValue()), new LimitOrder(trade.point.x, trade.price.doubleValue()))
	}

	def onNewBidAsk(Date date, ILimitOrder bid, ILimitOrder ask) {
		events = new ArrayList()
		onNewAsk(date, ask)
		onNewBid(date, bid)
		return events
	}

	def onNewAsk(Date date, ILimitOrder ask) {
		val hitBidOrders = bidOrders.filter [
			ask.price.doubleValue() < price.doubleValue()
		].sortWith[a, b|a.price.doubleValue.compareTo(b.price.doubleValue)].reverse
		hitBidOrders.forEach[hitOrder(date, it)]
		bidOrders.removeAll(hitBidOrders)
	}

	def onNewBid(Date date, ILimitOrder bid) {
		val hitAskOrders = askOrders.filter [
			bid.price.doubleValue() > price.doubleValue()
		].sortWith[a, b|a.price.doubleValue.compareTo(b.price.doubleValue)]
		hitAskOrders.forEach[hitOrder(date, it)]
		askOrders.removeAll(hitAskOrders)
	}

	def hitOrder(Date date, ILimitOrder order) {
		events.add(new EventOrderHit(order))
		val myTrade = new Trade(new Point(date.time, order.price), order.amount)
		if(position.present) {
			position.get().add(myTrade, feeCalculator.getFee(myTrade, false))
			events.add(new EventPositionUpdate(position.get()))
			if(position.get().closed) {
				closePosition(order)
			}
		} else {
			openPosition(myTrade)
		}
	}

	def openPosition(ITrade entry) {
		position = Optional.of(positionFactory.getPosition(entry, feeCalculator.getFee(entry, false)))
		events.add(new EventPositionOpened(position.get()))
	}

	def closePosition(ILimitOrder order) {
		val it = position.get()
		closedPositions.add(close())
		position = Optional.empty()
		events.add(new EventPositionClosed(closedPositions.last))
	}

	def placeAskOrder(ILimitOrder order) {
		askOrders.add(order)
	}

	def placeBidOrder(ILimitOrder order) {
		bidOrders.add(order)
	}
	
	def getPosition() {
		return position
	}

	def getClosedPositions() {
		return Collections.unmodifiableList(closedPositions)
	}

	def getAskOrders() {
		return Collections.unmodifiableList(askOrders)
	}

	def getBidOrders() {
		return Collections.unmodifiableList(bidOrders)
	}

}
