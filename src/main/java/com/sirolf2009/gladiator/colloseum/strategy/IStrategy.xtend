package com.sirolf2009.gladiator.colloseum.strategy

import com.sirolf2009.gladiator.colloseum.trading.TradingEngine
import java.util.List
import com.sirolf2009.gladiator.colloseum.trading.event.IEvent
import com.sirolf2009.gladiator.colloseum.data.IBidAsk

interface IStrategy {
	
	def void onTick(extension TradingEngine engine, List<IEvent> events, IBidAsk bidAsk)
	
}