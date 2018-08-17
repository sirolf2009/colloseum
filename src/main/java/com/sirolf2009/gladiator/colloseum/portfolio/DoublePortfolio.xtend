package com.sirolf2009.gladiator.colloseum.portfolio

import com.sirolf2009.gladiator.colloseum.trading.TradingEngine
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class DoublePortfolio {
	
	val TradingEngine engine
	val double margin
	val double maintenanceMargin
	var double balanceUSD
	var double balanceShare
	
	new(TradingEngine engine, double margin, double maintenanceMargin, double balanceUSD, double balanceShare) {
		this.engine = engine
		this.margin = margin
		this.maintenanceMargin = maintenanceMargin
		this.balanceUSD = balanceUSD
		this.balanceShare = balanceShare
	}
	
	override toString() {
		return '''
		Portfolio [
			BalanceUSD: «balanceUSD»
			BalanceShare: «balanceShare»
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
	
	def getBalance() {
		return getBalance(engine.getAsk())
	}
	
	def getBalance(double price) {
		return balanceUSD + balanceShare * price
	}
	
	def addProfit(double amount) {
		balanceUSD += amount
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
		getBalance()*getMaxLeverage()
	}
	
	def getMaxLeverage() {
		1/margin
	}
	
}