package com.sirolf2009.gladiator.colloseum.trading.fee

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import com.sirolf2009.commonwealth.trading.ITrade

@FinalFieldsConstructor class PercentageFeeCalculator implements IFeeCalculator {
	
	val double makerFeePercentage
	val double takerFeePercentage
	
	override getFee(ITrade trade, boolean isMarket) {
		val percentage = if(isMarket) takerFeePercentage else makerFeePercentage
		val feePerUnit = trade.price.doubleValue()/100*percentage
		return Math.abs(trade.amount.doubleValue()) * feePerUnit
	}
	
}
