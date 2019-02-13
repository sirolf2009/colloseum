package com.sirolf2009.gladiator.colloseum

import com.sirolf2009.gladiator.colloseum.data.IBidAsk
import com.sirolf2009.gladiator.colloseum.position.IOpenColloseumPosition
import com.sirolf2009.gladiator.colloseum.trading.event.IEvent
import java.util.ArrayList
import java.util.List
import java.util.Optional
import org.eclipse.xtend.lib.annotations.Accessors

class Tick extends ArrayList<IEvent> {
	
	@Accessors val IBidAsk bidAsk
	@Accessors val Optional<IOpenColloseumPosition> position
	
	new(List<IEvent> events, IBidAsk bidAsk, Optional<IOpenColloseumPosition> position) {
		super(events)
		this.bidAsk = bidAsk
		this.position = position
	}
	
}