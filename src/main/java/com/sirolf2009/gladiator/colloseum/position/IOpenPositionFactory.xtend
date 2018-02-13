package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.trading.ITrade

interface IOpenPositionFactory {
	
	def IOpenPosition getPosition(ITrade entry, Number fee)
	
}