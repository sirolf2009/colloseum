package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.trading.backtest.IBacktestResult
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.commonwealth.trading.analysis.NumberSeries
import java.util.stream.Collectors

@Data class ColloseumBacktestResult implements IBacktestResult {

	val List<ClosedPosition> trades	
	
	def getDrawdown() {
		return new NumberSeries(trades.stream().map[maxDrawdown].collect(Collectors.toList()))
	}
	
}