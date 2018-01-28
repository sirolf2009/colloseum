package com.sirolf2009.gladiator.colloseum.trading

import com.sirolf2009.commonwealth.trading.IPosition
import com.sirolf2009.commonwealth.trading.PositionType
import org.eclipse.xtend.lib.annotations.Data

@Data class ClosedPosition implements IPosition {
	
	val PositionType positionType
	val TradeSummary entry
	val Number entryFee
	val TradeSummary exit
	val Number exitFee
	
}
