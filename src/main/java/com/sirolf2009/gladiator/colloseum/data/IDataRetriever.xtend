package com.sirolf2009.gladiator.colloseum.data

interface IDataRetriever {
	
	def Iterable<? extends IBidAsk> getData()
	
}