package com.sirolf2009.gladiator.colloseum.data

import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import java.util.Date

interface IBidAsk {
	def Date getTimestamp()
	def ILimitOrder getAsk()
	def ILimitOrder getBid()
}