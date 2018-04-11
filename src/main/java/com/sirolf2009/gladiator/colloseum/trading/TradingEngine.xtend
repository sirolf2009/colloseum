package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.timeseries.Point
import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.Trade
import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import com.sirolf2009.commonwealth.trading.orderbook.LimitOrder
import com.sirolf2009.gladiator.colloseum.data.IBidAsk
import com.sirolf2009.gladiator.colloseum.position.IOpenPositionFactory
import com.sirolf2009.gladiator.colloseum.trading.event.EventOrderHit
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionClosed
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionOpened
import com.sirolf2009.gladiator.colloseum.trading.event.EventPositionUpdate
import com.sirolf2009.gladiator.colloseum.trading.event.IEvent
import com.sirolf2009.gladiator.colloseum.trading.fee.IFeeCalculator
import com.sirolf2009.util.jmx.JMXBean
import java.io.File
import java.io.FileOutputStream
import java.io.ObjectOutputStream
import java.util.ArrayList
import java.util.Collections
import java.util.Date
import java.util.List
import java.util.Optional
import com.sirolf2009.gladiator.colloseum.position.IOpenColloseumPosition

@JMXBean
class TradingEngine {

	val IFeeCalculator feeCalculator
	val IOpenPositionFactory positionFactory
	val closedPositions = new ArrayList<ClosedPosition>()
	val askOrders = new ArrayList<ILimitOrder>()
	val bidOrders = new ArrayList<ILimitOrder>()
	var Optional<IOpenColloseumPosition> position = Optional.empty()
	var List<IEvent> events
	var Date currentDate
	var double ask
	var double bid
	var double drawdown

	new(IFeeCalculator feeCalculator, IOpenPositionFactory positionFactory) {
		this.feeCalculator = feeCalculator
		this.positionFactory = positionFactory
		registerAs("com.sirolf2009.gladiator.colloseum:type=TradingEngine")
	}

	def onNewPrice(ITrade trade) {
		return onNewBidAsk(trade.point.date, new LimitOrder(trade.point.x, trade.price.doubleValue()), new LimitOrder(trade.point.x, trade.price.doubleValue()))
	}
	
	def onNewBidAsk(IBidAsk bidAsk) {
		onNewBidAsk(bidAsk.timestamp, bidAsk.bid, bidAsk.ask)
	}

	def synchronized onNewBidAsk(Date date, ILimitOrder bid, ILimitOrder ask) {
		this.currentDate = date
		this.ask = ask.price.doubleValue
		this.bid = bid.price.doubleValue
		events = new ArrayList()
		onNewAsk(date, ask)
		onNewBid(date, bid)
		position.ifPresent[
			updateDrawdown(bid.price.doubleValue(), ask.price.doubleValue())
			drawdown = it.maxDrawdown
		]
		return events
	}

	def private onNewAsk(Date date, ILimitOrder ask) {
		val hitBidOrders = bidOrders.filter [
			ask.price.doubleValue() <= price.doubleValue()
		].sortWith[a, b|a.price.doubleValue.compareTo(b.price.doubleValue)].reverse
		hitBidOrders.forEach[hitOrder(date, it)]
		bidOrders.removeAll(hitBidOrders)
	}

	def private onNewBid(Date date, ILimitOrder bid) {
		val hitAskOrders = askOrders.filter [
			bid.price.doubleValue() >= price.doubleValue()
		].sortWith[a, b|a.price.doubleValue.compareTo(b.price.doubleValue)]
		hitAskOrders.forEach[hitOrder(date, it)]
		askOrders.removeAll(hitAskOrders)
	}

	def private hitOrder(Date date, ILimitOrder order) {
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

	def private openPosition(ITrade entry) {
		position = Optional.of(positionFactory.getPosition(entry, feeCalculator.getFee(entry, false)))
		events.add(new EventPositionOpened(position.get()))
	}

	def private closePosition(ILimitOrder order) {
		val it = position.get()
		closedPositions.add(close())
		position = Optional.empty()
		events.add(new EventPositionClosed(closedPositions.last))
	}

	def synchronized placeAskOrder(ILimitOrder order) {
		askOrders.add(order)
	}

	def synchronized placeBidOrder(ILimitOrder order) {
		bidOrders.add(order)
	}
	
	def summarize() {
		return new ColloseumBacktestResult(closedPositions)
	}
	
	def savePositionsTo(File file) {
		val out = new ObjectOutputStream(new FileOutputStream(file))
		out.writeObject(closedPositions)
		out.close()
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
	
	// JMX methods
	
	override Date getCurrentTime() {
		return currentDate
	}
	
	override double getBid() {
		return bid
	}
	
	override double getAsk() {
		return ask
	}
	
	override double getAvgEntry() {
		return position.map[entryPrice.doubleValue].orElse(null)
	}
	
	override boolean isLong() {
		return position.map[isLong].orElse(false)
	}
	
	override boolean isShort() {
		return position.map[isShort].orElse(false)
	}
	
	override double getSize() {
		return position.map[size.doubleValue].orElse(null)
	}
	
	override double getProfit() {
		return position.map[getProfit(bid, ask)].orElse(null)
	}
	
	override double getBiggestTrade() {
		return summarize().sizes.getMax().orElse(0)
	}
	
	override double getMaxDrawdown() {
		return -summarize().drawdown.getMin().orElse(0)
	}
	
	override double getProfits() {
		return summarize().profits.sum()
	}
	
	override double getDrawdown() {
		return -drawdown
	}

}
