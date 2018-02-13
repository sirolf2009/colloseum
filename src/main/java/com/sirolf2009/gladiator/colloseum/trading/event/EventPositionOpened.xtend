package com.sirolf2009.gladiator.colloseum.trading.event

import com.sirolf2009.gladiator.colloseum.position.IOpenPosition
import org.eclipse.xtend.lib.annotations.Data

@Data class EventPositionOpened implements IEvent {
	
	val IOpenPosition position
	
}