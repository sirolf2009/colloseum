package com.sirolf2009.gladiator.colloseum.data

import org.eclipse.xtend.lib.annotations.Data
import java.util.Date
import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import com.sirolf2009.commonwealth.trading.orderbook.LimitOrder

@Data class BidAsk implements IBidAsk {
	Date timestamp
	ILimitOrder ask
	ILimitOrder bid
	
	new(Date timestamp, double ask, double bid) {
		this(timestamp, new LimitOrder(ask, 1), new LimitOrder(bid, 1))
	}
	
	new(Date timestamp, ILimitOrder ask, ILimitOrder bid) {
		if(ask.getPrice().doubleValue() < bid.getPrice().doubleValue()) {
			throw new IllegalArgumentException("Ask may not be less than bid")
		}
		this.timestamp = timestamp
		this.ask = ask
		this.bid = bid
	}
}
