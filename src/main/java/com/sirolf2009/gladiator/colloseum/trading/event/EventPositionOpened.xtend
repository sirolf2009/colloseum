package com.sirolf2009.gladiator.colloseum.trading.event

import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.gladiator.colloseum.position.IOpenColloseumPosition

@Data class EventPositionOpened implements IEvent {
	
	val IOpenColloseumPosition position
	
}