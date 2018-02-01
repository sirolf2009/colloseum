package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.PositionType
import java.util.Optional
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString

@Accessors(PUBLIC_GETTER) @ToString class OpenPosition {
	
	val TradeSummary entry
	val PositionType positionType
	var double entryFee
	var Optional<TradeSummary> exit
	var double exitFee
	
	new(ITrade trade, Number fee) {
		entry = new TradeSummary(trade)
		positionType = if(trade.bought) PositionType.LONG else PositionType.SHORT
		entryFee += fee
		exit = Optional.empty()
	}
	
	def getProfit(double currentPrice) {
		var double exitPrices
		var double weights
		exitPrices += exit.map[
			allTrades.map[price.doubleValue()*amount.doubleValue()].reduce[a,b|a+b]
		].orElse(0d)
		weights += exit.map[
			allTrades.map[amount.doubleValue()].reduce[a,b|a+b]
		].orElse(0d)
		exitPrices += currentPrice * (entry.amount.doubleValue() - exit.map[amount].orElse(0d))
		weights += entry.amount.doubleValue() - exit.map[amount].orElse(0d)
		val exitPrice = exitPrices/weights
		if(isLong()) {
			return (exitPrice - entry.price.doubleValue()) * (entry.amount.doubleValue() - exit.map[Math.abs(amount.doubleValue())].orElse(0d)) - entryFee - exitFee
		} else {
			return (entry.price.doubleValue() - exitPrice) * (Math.abs(entry.amount.doubleValue()) - exit.map[amount].orElse(0)) - entryFee - exitFee
		}
	}
	
	def add(ITrade trade, Number fee) {
		if((isLong() && trade.bought) || (isShort() && trade.sold)) {
			entry.add(trade)
			entryFee += fee
		} else {
			if(exit.present) {
				exit.get().add(trade)
			} else {
				exit = Optional.of(new TradeSummary(trade))
			}
			exitFee += fee
		}
	}
	
	def isClosed() {
		if(!exit.present) {
			return false
		}
		return Math.abs(entry.amount.doubleValue() + exit.get().amount.doubleValue()) <= 0.0001
	}
	
	def isLong() {
		return positionType == PositionType.LONG
	}
	
	def isShort() {
		return positionType == PositionType.SHORT
	}
	
}
