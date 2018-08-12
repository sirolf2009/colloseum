package com.sirolf2009.gladiator.colloseum.portfolio

import com.sirolf2009.gladiator.colloseum.trading.TradingEngine
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class Portfolio {
	
	val TradingEngine engine
	val double margin
	val double maintenanceMargin
	var double balance
	
	def getRequiredMargin(double currentPrice) {
		currentPrice * Math.abs(getTradeSize()) * maintenanceMargin / (1 - maintenanceMargin)
	}
	
	def getProfit() {
		return engine.getPosition().map[getProfit(engine.getBid(), engine.getAsk())].orElse(0d)
	}
	
	def getTradeSize() {
		return engine.getPosition().map[getSize().doubleValue()].orElse(0d)
	}
	
	def getMaxTradePosition() {
		balance*(1/margin)
	}
	
}