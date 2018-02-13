package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.PositionType
import com.sirolf2009.commonwealth.trading.IPosition

interface IOpenPosition {
	
	def double getPrice()
	def double getSize()
	def double getFees()
	def void add(ITrade trade, Number fee)
	def IPosition close()
	def PositionType getPositionType()
	
	def double getProfit(double currentPrice) {
		if(isLong()) {
			return (currentPrice - getPrice()) * getSize() - getFees()
		} else {
			return (getPrice() - currentPrice) * -getSize() - getFees()
		}
	}
	
	def boolean isClosed() {
		return getSize() == 0
	}
	
	def isLong() {
		return positionType == PositionType.LONG
	}
	
	def isShort() {
		return positionType == PositionType.SHORT
	}
	
}