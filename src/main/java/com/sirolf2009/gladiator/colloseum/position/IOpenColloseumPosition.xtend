package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.trading.IOpenPosition
import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.gladiator.colloseum.trading.ClosedPosition

interface IOpenColloseumPosition extends IOpenPosition {

	def void setMaxDrawdown(Number drawdown)
	def void setMaxDrawup(Number drawup)

	def void add(ITrade trade, Number fee)

	def ClosedPosition close()

	def update(double bid, double ask) {
		if(isLong()) {
			getProfit(bid) => [
				updateDrawdown()
				updateDrawup()
			]
		} else {
			getProfit(ask) => [
				updateDrawdown()
				updateDrawup()
			]
		}
	}

	def updateDrawdown(double newDrawdown) {
		if(newDrawdown < 0 && newDrawdown < getMaxDrawdown().doubleValue()) {
			setMaxDrawdown(newDrawdown)
		}
	}

	def updateDrawup(double newDrawup) {
		if(newDrawup > 0 && newDrawup > getMaxDrawup().doubleValue()) {
			setMaxDrawup(newDrawup)
		}
	}

	def boolean isClosed() {
		println(getSize()+" == 0 ? "+getSize() == 0)
		return getSize() == 0
	}

}
