package com.sirolf2009.gladiator.colloseum.trading.fee

import com.sirolf2009.commonwealth.trading.ITrade

interface IFeeCalculator {
	
	def Number getFee(ITrade trade, boolean isMarket)
	
}
