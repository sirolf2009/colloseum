package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.PositionType
import com.sirolf2009.gladiator.colloseum.trading.ClosedPosition
import com.sirolf2009.gladiator.colloseum.trading.TradeSummary
import java.util.Optional
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString

@Accessors(PUBLIC_GETTER) @ToString class OpenPositionAverage implements IOpenColloseumPosition {
	
	public static IOpenPositionFactory FACTORY = [trade,fee| new OpenPositionAverage(trade, fee)] 
	
	val TradeSummary entry
	val PositionType positionType
	@Accessors var Number maxDrawdown
	@Accessors var Number maxDrawup
	var double fees
	var Optional<TradeSummary> exit
	
	new(ITrade entry, Number fee) {
		this.entry = new TradeSummary(entry)
		positionType = if(entry.bought) PositionType.LONG else PositionType.SHORT
		fees += fee
		exit = Optional.empty()
		setMaxDrawdown(0)
		setMaxDrawup(0)
	}
	
	override getProfit(Number currentPrice) {
		var double exitPrices
		var double weights
		exitPrices += exit.map[
			allTrades.map[price.doubleValue()*amount.doubleValue()].reduce[a,b|a+b]
		].orElse(0d)
		weights += exit.map[
			allTrades.map[amount.doubleValue()].reduce[a,b|a+b]
		].orElse(0d)
		exitPrices += currentPrice.doubleValue * (entry.amount.doubleValue() - exit.map[amount].orElse(0d))
		weights += entry.amount.doubleValue() - exit.map[amount].orElse(0d)
		val exitPrice = exitPrices/weights
		if(isLong()) {
			return (exitPrice - entry.price.doubleValue()) * getSize() - fees
		} else {
			return (entry.price.doubleValue() - exitPrice) * getSize() - fees
		}
	}
	
	override getEntryPrice() {
		return entry.price
	}
	
	override getEntryFee() {
		return fees
	}
	
	override getSize() {
		if(isLong()) {
			entry.amount.doubleValue() - exit.map[Math.abs(amount.doubleValue())].orElse(0d)
		} else {
			Math.abs(entry.amount.doubleValue()) - exit.map[amount].orElse(0)
		}
	}
	
	override add(ITrade trade, Number fee) {
		fees += fee
		if((isLong() && trade.bought) || (isShort() && trade.sold)) {
			entry.add(trade)
		} else {
			if(exit.present) {
				exit.get().add(trade)
			} else {
				exit = Optional.of(new TradeSummary(trade))
			}
		}
	}
	
	override isClosed() {
		if(!exit.present) {
			return false
		}
		return Math.abs(entry.amount.doubleValue() + exit.get().amount.doubleValue()) <= 0.0001
	}
	
	override close() {
		return new ClosedPosition(positionType, entry as ITrade, fees/2, exit.get() as ITrade, fees/2, maxDrawdown, maxDrawup)
	}
	
}