package com.sirolf2009.gladiator.colloseum.portfolio

import com.sirolf2009.gladiator.colloseum.trading.TradingEngine
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class Portfolio {
	
	val TradingEngine engine
	val double margin
	val double maintenanceMargin
	var double balance
	
	new(TradingEngine engine, double margin, double maintenanceMargin, double balance) {
		this.engine = engine
		this.margin = margin
		this.maintenanceMargin = maintenanceMargin
		this.balance = balance
	}
	
	override toString() {
		return '''
		Portfolio [
			Balance: «balance»
			Margin: «margin»
			Leverage: «getMaxLeverage()»
			MaxTrade: «getMaxTradePosition()»
			Maintenance: «maintenanceMargin»
			Profit: «getProfit()»
			Trade Size: «getTradeSize()»
			Req Margin: «getRequiredMargin()»
			Unused Margin: «getUnusedMargin()»
		]
		'''
	}
	
	def addProfit(double amount) {
		balance += amount
	}
	
	def getUnusedMargin() {
		return getBalance() - getRequiredMargin()
	}
	
	def getRequiredMargin() {
		if(getTradeSize() > 0) {
			getRequiredMargin(engine.getBid())
		} else {
			getRequiredMargin(engine.getAsk())
		}
	}
	
	def getRequiredMargin(double currentPrice) {
		currentPrice * Math.abs(getTradeSize()) * maintenanceMargin / (1 - maintenanceMargin)
	}
	
	def getProfit() {
		return getProfit(engine.getBid(), engine.getAsk())
	}
	
	def getProfit(double price) {
		return getProfit(price, price)
	}
	
	def getProfit(double bid, double ask) {
		return engine.getPosition().map[it.getProfit(bid, ask)].orElse(0d)
	}
	
	def getTradeSize() {
		return engine.getPosition().map[getSize().doubleValue()].orElse(0d)
	}
	
	def getMaxTradePosition() {
		balance*getMaxLeverage()
	}
	
	def getMaxLeverage() {
		1/margin
	}
	
}