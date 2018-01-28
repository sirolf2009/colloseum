package com.sirolf2009.gladiator.colloseum.trading.event

import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import org.eclipse.xtend.lib.annotations.Data

@Data class EventOrderHit implements IEvent {
	
	val ILimitOrder order
	
}