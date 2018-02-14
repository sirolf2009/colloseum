package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.trading.ITrade
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class TradeSummary implements ITrade {

	val ITrade openingTrade
	val List<ITrade> allTrades

	new(ITrade openingTrade) {
		this.openingTrade = openingTrade
		this.allTrades = new ArrayList()
		add(openingTrade)
	}

	def add(ITrade trade) {
		allTrades.add(trade)
	}
	
	override toString() {
		if(bought) {
			return '''Bought «amount.floatValue» at «price.floatValue»'''
		} else {
			return '''Sold «amount.floatValue» at «price.floatValue»'''
		}
	}
	
	override getPrice() {
		return allTrades.stream.mapToDouble[price.doubleValue].sum() / allTrades.size()
	}

	override getPoint() {
		return openingTrade.point
	}

	override getAmount() {
		return allTrades.map[amount.doubleValue()].reduce[a, b|a + b]
	}

}
