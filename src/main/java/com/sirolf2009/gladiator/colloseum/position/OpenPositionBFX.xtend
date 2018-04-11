package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.timeseries.IPoint
import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.PositionType
import com.sirolf2009.commonwealth.trading.Trade
import com.sirolf2009.gladiator.colloseum.trading.ClosedPosition
import org.eclipse.xtend.lib.annotations.Accessors
import com.sirolf2009.commonwealth.timeseries.Point

@Accessors class OpenPositionBFX implements IOpenColloseumPosition {

	public static IOpenPositionFactory FACTORY = [trade, fee|new OpenPositionBFX(trade, fee)]

	val IPoint point
	val PositionType positionType
	var double maxDrawdown
	var double fees
	var double price
	var double size
	var ITrade exit

	new(ITrade entry, Number fee) {
		this.point = entry.point
		positionType = if(entry.bought) PositionType.LONG else PositionType.SHORT
//		fees += fee
		price = entry.price.doubleValue()
		size = entry.amount.doubleValue()
	}

	override toString() {
		return '''«if(isLong) "Bought" else "Sold"» «Math.abs(size)» at «price»'''
	}

	override getEntry() {
		return new Trade(new Point(point.x, price), size)
	}

	override add(ITrade trade, Number fee) {
//		fees += fee
		if(isLong == trade.bought) {
			val profit = getProfit(trade.price)
			size += trade.amount
			val prevPrice = price
			price = calculateEntry(positionType, size, profit, trade.price.doubleValue())
			if(prevPrice < price) {
				System.exit(0)
			}
		} else {
			val profit = getProfit(trade.price)
			size -= trade.amount
			if(size != 0d) {
				price = calculateEntry(positionType, size, profit, trade.price.doubleValue())
			} else {
				exit = trade
			}
		}
	}

	def static calculateEntry(PositionType type, double size, double profit, double price) {
		if(type == PositionType.LONG) {
			return (profit - (price * size)) / -size
		} else {
			return (price * size - profit) / size
		}
	}

	override getSize() {
		return size
	}

	override getEntryFee() {
		return fees
	}

	override isClosed() {
		return getSize().doubleValue() == 0d
	}

	override getPositionType() {
		return positionType
	}

	override close() {
		return new ClosedPosition(positionType, new Trade(point, exit.amount), fees / 2, exit, fees / 2, maxDrawdown)
	}

}
