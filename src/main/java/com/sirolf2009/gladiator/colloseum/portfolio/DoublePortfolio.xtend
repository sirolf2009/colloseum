package com.sirolf2009.gladiator.colloseum.portfolio

import com.sirolf2009.gladiator.colloseum.trading.TradingEngine
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class DoublePortfolio {
	
	/** The Trading engine, used to get latest bid/ask */
	val TradingEngine engine
	/** Your stake in a trade */
	val double margin
	/** 
	 * How much of your portfolio needs to be available
	 * 
	 * Let's say you open a long position of 13.333 shares @ 250$
	 * Let's also say your balanceUSD is 1000 and your maintenanceMargin is 0.15 (15%)
	 * The position was worth 13.333 * 250 = 3333.33$
	 * 15% of 3333.33$ is 500$, which means you need to have more than 500$ left as collateral
	 * If your position reaches a loss of 500, you'd only have 1000-500=500$ left as collateral
	 * Because that reaches the maintenance threshold, you get liquidated
	 */
	val double maintenanceMargin
	/** Your balance of USD */
	var double balanceUSD
	/** The amount of shares you own (or whatever else you're trading) */
	var double balanceShare
	
	/**
	 * @param engine - The TradingEngine, used to get latest bid/ask
	 * @param margin - Your stake in a trade
	 * @param maintenanceMargin - How much of your portfolio needs to be available
	 * @param balanceUSD - Your balance of USD
	 * @param balanceShare - The amount of shares you own (or whatever else you're trading)
	 */
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
	
	def getIsLiquidated() {
		return getUnusedMargin() <= 0
	}
	
}