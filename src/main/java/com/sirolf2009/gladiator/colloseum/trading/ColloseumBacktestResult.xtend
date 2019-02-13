package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.trading.backtest.IBacktestResult
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class ColloseumBacktestResult implements IBacktestResult {

	val List<ClosedPosition> trades
	
}