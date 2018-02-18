package com.sirolf2009.gladiator.colloseum.trading

import java.util.Date

interface ITradingEngineMXBean {
	
	def Date getCurrentTime()
	def Double getBiggestTrade()
	def Double getProfits()
	def Double getMaxDrawdown()
	
}