package com.sirolf2009.gladiator.colloseum.simulation

import java.util.List
import com.sirolf2009.gladiator.colloseum.trading.event.IEvent
import com.sirolf2009.gladiator.colloseum.trading.TradingEngine

interface IStrategy {
	
	def void onTick(TradingEngine engine, List<IEvent> events)
	
}