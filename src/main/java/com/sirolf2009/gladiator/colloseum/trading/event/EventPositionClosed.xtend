package com.sirolf2009.gladiator.colloseum.trading.event

import com.sirolf2009.commonwealth.trading.IPosition
import org.eclipse.xtend.lib.annotations.Data

@Data class EventPositionClosed implements IEvent {
	
	val IPosition position
	
}