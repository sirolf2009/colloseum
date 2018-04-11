package com.sirolf2009.gladiator.colloseum

import com.sirolf2009.gladiator.colloseum.trading.TradingEngine
import com.sirolf2009.gladiator.colloseum.data.IDataRetriever
import com.sirolf2009.gladiator.colloseum.strategy.IStrategy

class Colloseum {
	
	def static simulate(TradingEngine engine, IDataRetriever dataRetriever, IStrategy strategy) {
		dataRetriever.getData().forEach[
			strategy.onTick(engine, engine.onNewBidAsk(it), it)
		]
	}
	
}