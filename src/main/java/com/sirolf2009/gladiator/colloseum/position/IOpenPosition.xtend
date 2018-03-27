package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.PositionType
import com.sirolf2009.gladiator.colloseum.trading.ClosedPosition

interface IOpenPosition {

	def double getPrice()

	def double getSize()

	def double getFees()

	def double getMaxDrawdown()

	def void setMaxDrawdown(double drawdown)

	def void add(ITrade trade, Number fee)

	def ClosedPosition close()

	def PositionType getPositionType()

	def updateDrawdown(double bid, double ask) {
		if(isLong()) {
			updateDrawdown(getProfit(bid))
		} else {
			updateDrawdown(getProfit(ask))
		}
	}

	def updateDrawdown(double newDrawdown) {
		if(newDrawdown < 0 && newDrawdown < getMaxDrawdown()) {
			setMaxDrawdown(newDrawdown)
		}
	}

	def double getProfit(double bid, double ask) {
		if(isLong()) {
			return getProfit(ask)
		} else {
			return getProfit(bid)
		}
	}

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
