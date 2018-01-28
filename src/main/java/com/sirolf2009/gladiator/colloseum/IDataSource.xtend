package com.sirolf2009.gladiator.colloseum

import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.gladiator.colloseum.trading.fee.IFeeCalculator

interface IDataSource {
	
	def Iterable<ITrade> getData()
	def IFeeCalculator getFeeCalculator()
	
}