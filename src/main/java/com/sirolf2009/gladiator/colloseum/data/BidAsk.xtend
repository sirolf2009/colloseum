package com.sirolf2009.gladiator.colloseum.data

import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import java.util.Date
import org.eclipse.xtend.lib.annotations.Data

@Data class BidAsk implements IBidAsk {
	val Date timestamp
	val ILimitOrder bid
	val ILimitOrder ask
}