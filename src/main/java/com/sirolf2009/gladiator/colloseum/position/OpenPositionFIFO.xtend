package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.PositionType
import com.sirolf2009.gladiator.colloseum.trading.ClosedPosition
import com.sirolf2009.gladiator.colloseum.trading.TradeSummary
import java.util.LinkedList
import java.util.Optional
import java.util.Queue
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class OpenPositionFIFO implements IOpenPosition {

	public static IOpenPositionFactory FACTORY = [trade, fee|new OpenPositionFIFO(trade, fee)]

	val Queue<ITrade> openTrades
	val TradeSummary openingTrades
	val PositionType positionType
	var double maxDrawdown
	var Optional<TradeSummary> closingTrades
	var double fees

	new(ITrade entry, Number fee) {
		this.openTrades = new LinkedList(#[entry])
		this.openingTrades = new TradeSummary(entry)
		this.closingTrades = Optional.empty()
		positionType = if(entry.bought) PositionType.LONG else PositionType.SHORT
		fees += fee
	}
	
	override toString() {
		return '''«if(openingTrades.bought) "Bought" else "Sold"» «Math.abs(size)» at «price»'''
	}

	override add(ITrade trade, Number fee) {
		fees += fee
		if(isLong == trade.bought) {
			openTrades.add(trade)
			openingTrades.add(trade)
		} else {
			openTrades.poll()
			if(closingTrades.present) {
				closingTrades.get().add(trade)
			} else {
				closingTrades = Optional.of(new TradeSummary(trade))
			}
		}
	}

	override getPrice() {
		openTrades.stream.mapToDouble[price.doubleValue].sum / openTrades.size()
	}

	override getSize() {
		openTrades.stream.mapToDouble[amount.doubleValue].sum()
	}

	override isClosed() {
		return getSize() == 0
	}

	override getPositionType() {
		return positionType
	}

	override close() {
		return new ClosedPosition(positionType, openingTrades as ITrade, fees/2, closingTrades.get() as ITrade, fees/2, maxDrawdown)
	}

}
