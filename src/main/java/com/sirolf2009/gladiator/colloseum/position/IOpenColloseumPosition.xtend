package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.trading.IOpenPosition
import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.gladiator.colloseum.trading.ClosedPosition

interface IOpenColloseumPosition extends IOpenPosition {

	def double getMaxDrawdown()

	def void setMaxDrawdown(double drawdown)

	def void add(ITrade trade, Number fee)

	def ClosedPosition close()

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

	def boolean isClosed() {
		return getSize() == 0
	}

}
