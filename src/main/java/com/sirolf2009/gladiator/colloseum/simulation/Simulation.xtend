package com.sirolf2009.gladiator.colloseum.simulation

import com.sirolf2009.gladiator.colloseum.data.IDataRetriever
import com.sirolf2009.gladiator.colloseum.position.OpenPositionFIFO
import com.sirolf2009.gladiator.colloseum.trading.ColloseumBacktestResult
import com.sirolf2009.gladiator.colloseum.trading.TradingEngine
import com.sirolf2009.gladiator.colloseum.trading.fee.PercentageFeeCalculator

class Simulation {
	
	def static ColloseumBacktestResult simulate(IStrategy strategy, IDataRetriever loader, double fee) {
		return simulate(new TradingEngine(new PercentageFeeCalculator(fee, fee), OpenPositionFIFO.FACTORY), strategy, loader)
	}
	
	def static ColloseumBacktestResult simulate(TradingEngine engine, IStrategy strategy, IDataRetriever loader) {
		loader.getData().forEach[
			strategy.onTick(engine, engine.onNewBidAsk(it))
		]
		return engine.summarize
	}
	
}