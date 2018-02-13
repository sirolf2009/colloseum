package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.Position
import com.sirolf2009.commonwealth.trading.PositionType
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
	var Optional<TradeSummary> closingTrades
	var double fees

	new(ITrade entry, Number fee) {
		this.openTrades = new LinkedList(#[entry])
		this.openingTrades = new TradeSummary(entry)
		this.closingTrades = Optional.empty()
		positionType = if(entry.bought) PositionType.LONG else PositionType.SHORT
		fees += fee
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
		openTrades.stream.mapToDouble[price.doubleValue].average().orElseThrow[new IllegalStateException("No open trades left")]
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
		return new Position(openingTrades as ITrade, closingTrades.get() as ITrade, fees/2, fees/2, positionType)
	}

}
