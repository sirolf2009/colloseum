package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.Trade
import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import com.sirolf2009.gladiator.colloseum.trading.event.EventOrderHit
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionClosed
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionOpened
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionUpdate
import com.sirolf2009.gladiator.colloseum.trading.event.IEvent
import com.sirolf2009.gladiator.colloseum.trading.fee.IFeeCalculator
import java.util.ArrayList
import java.util.List
import java.util.Optional
import java.util.Collections

class TradingEngine {
	
	val IFeeCalculator feeCalculator
	val closedPositions = new ArrayList<ClosedPosition>()
	val askOrders = new ArrayList<ILimitOrder>()
	val bidOrders = new ArrayList<ILimitOrder>()
	var double lastPrice = Double.NaN
	var Optional<OpenPosition> position = Optional.empty()
	var List<IEvent> events
	
	new(IFeeCalculator feeCalculator) {
		this.feeCalculator = feeCalculator
	}
	
	def onNewPrice(ITrade trade) {
		events = new ArrayList()
		if(!lastPrice.naN) {
			val hitAskOrders = askOrders.filter[
				lastPrice <= price.doubleValue() && trade.price.doubleValue() > price.doubleValue()
			].sortWith[a,b| a.price.doubleValue.compareTo(b.price.doubleValue)]
			hitAskOrders.forEach[hitOrder(trade)]
			askOrders.removeAll(hitAskOrders)
			val hitBidOrders = bidOrders.filter[
				lastPrice >= price.doubleValue() && trade.price.doubleValue() < price.doubleValue()
			].sortWith[a,b| a.price.doubleValue.compareTo(b.price.doubleValue)].reverse
			hitBidOrders.forEach[hitOrder(trade)]
			bidOrders.removeAll(hitBidOrders)
		}
		lastPrice = trade.price.doubleValue()
		return events
	}
	
	def hitOrder(ILimitOrder order, ITrade trigger) {
		events.add(new EventOrderHit(order))
		val myTrade = new Trade(trigger.point, order.amount)
		if(position.present) {
			position.get().add(myTrade, feeCalculator.getFee(myTrade, false))
			events.add(new EventPositionUpdate(position.get()))
			if(position.get().closed) {
				closePosition(order, trigger)
			}
		} else {
			openPosition(myTrade)
		}
	}
	
	def openPosition(ITrade entry) {
		position = Optional.of(new OpenPosition(entry, feeCalculator.getFee(entry, false)))
		events.add(new EventPositionOpened(position.get()))
	}
	
	def closePosition(ILimitOrder order, ITrade trigger) {
		val it = position.get()
		closedPositions.add(new ClosedPosition(positionType, entry, entryFee, exit.get(), exitFee))
		position = Optional.empty()
		events.add(new EventPositionClosed(closedPositions.last))
	}
	
	def placeAskOrder(ILimitOrder order) {
		askOrders.add(order)
	}
	
	def placeBidOrder(ILimitOrder order) {
		bidOrders.add(order)
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
