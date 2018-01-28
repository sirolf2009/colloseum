package com.sirolf2009.gladiator.colloseum.trading.event

import com.sirolf2009.gladiator.colloseum.trading.OpenPosition
import org.eclipse.xtend.lib.annotations.Data

@Data class EventPositionOpened implements IEvent {
	
	val OpenPosition position
	
}