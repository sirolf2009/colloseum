package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.timeseries.Point
import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.Trade
import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import com.sirolf2009.commonwealth.trading.orderbook.LimitOrder
import com.sirolf2009.gladiator.colloseum.data.IBidAsk
import com.sirolf2009.gladiator.colloseum.position.IOpenColloseumPosition
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
import java.util.Date
import java.util.List
import java.util.Optional
import org.eclipse.xtend.lib.annotations.Accessors
import com.sirolf2009.gladiator.colloseum.Tick
import com.sirolf2009.gladiator.colloseum.data.BidAsk

@JMXBean @Accessors
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
	}

	def onNewPrice(ITrade trade) {
		return onNewBidAsk(trade.point.date, new LimitOrder(trade.price.doubleValue(), 0), new LimitOrder(trade.price.doubleValue(), 0))
	}

	def onNewBidAsk(Date date, ILimitOrder bid, ILimitOrder ask) {
		return onNewBidAsk(new BidAsk(date, ask, bid))
	}

	def synchronized onNewBidAsk(IBidAsk bidAsk) {
		this.currentDate = bidAsk.getTimestamp()
		this.ask = bidAsk.getAsk().price.doubleValue
		this.bid = bidAsk.getBid().price.doubleValue
		events = new ArrayList()
		onNewAsk(bidAsk.getTimestamp(), bidAsk.getAsk())
		onNewBid(bidAsk.getTimestamp(), bidAsk.getBid())
		position.ifPresent [
			update(bidAsk.getBid().price.doubleValue(), bidAsk.getAsk().price.doubleValue())
			drawdown = it.maxDrawdown.doubleValue
		]
		return new Tick(events, bidAsk, position)
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

	def synchronized placeMarketBuyOrder(Number amount) {
		if(amount.doubleValue() < 0) {
			throw new IllegalArgumentException("Can not buy a negative amount")
		}
		events = new ArrayList()
		hitOrder(currentDate, new LimitOrder(ask, amount))
		return events
	}

	def synchronized placeMarketSellOrder(Number amount) {
		if(amount.doubleValue() > 0) {
			throw new IllegalArgumentException("Can not sell a positive amount")
		}
		events = new ArrayList()
		hitOrder(currentDate, new LimitOrder(ask, amount))
		return events
	}

	def private hitOrder(Date date, ILimitOrder order) {
		events.add(new EventOrderHit(order))
		val myTrade = new Trade(new Point(date.time, order.price), order.amount)
		if(position.present) {
			val positionSize = position.get().getSize().doubleValue()
			if(position.get().isLong() && !myTrade.bought() && -myTrade.getAmount().doubleValue() > positionSize) {
				closeAndOpenPosition(myTrade)
			} else if(position.get().isShort() && myTrade.bought() && myTrade.getAmount().doubleValue() > -positionSize) {
				closeAndOpenPosition(myTrade)
			} else {
				position.get().add(myTrade, feeCalculator.getFee(myTrade, false))
				events.add(new EventPositionUpdate(position.get()))
				if(position.get().closed) {
					closePosition()
				}
			}
		} else {
			openPosition(myTrade)
		}
	}

	def private closeAndOpenPosition(ITrade trade) {
		val positionSize = position.get().getSize().doubleValue()
		val closingTrade = new Trade(new Point(trade.getDate().time, trade.price), -positionSize)
		position.get().add(closingTrade, feeCalculator.getFee(closingTrade, false))
		events.add(new EventPositionUpdate(position.get()))
		closePosition()

		val remainderTrade = new Trade(new Point(trade.getDate().time, trade.getPrice()), trade.getAmount().doubleValue() + positionSize)
		openPosition(remainderTrade)
	}

	def private openPosition(ITrade entry) {
		position = Optional.of(positionFactory.getPosition(entry, feeCalculator.getFee(entry, false)))
		events.add(new EventPositionOpened(position.get()))
	}

	def private closePosition() {
		val it = position.get()
		closedPositions.add(close())
		position = Optional.empty()
		events.add(new EventPositionClosed(closedPositions.last))
	}

	def synchronized placeAskOrder(ILimitOrder order) {
		askOrders.add(order)
	}

	def synchronized cancelAskOrder(ILimitOrder order) {
		askOrders.remove(order)
	}

	def synchronized placeBidOrder(ILimitOrder order) {
		bidOrders.add(order)
	}

	def synchronized cancelBidOrder(ILimitOrder order) {
		bidOrders.remove(order)
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
		return closedPositions
	}

	def getAskOrders() {
		return askOrders
	}

	def getBidOrders() {
		return bidOrders
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
		return -summarize().maxDrawdown.getMin().orElse(0)
	}

	override double getProfits() {
		return summarize().profits.sum()
	}

	override double getDrawdown() {
		return -drawdown
	}

}
