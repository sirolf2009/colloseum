package com.sirolf2009.gladiator.colloseum.data

import java.util.stream.Stream

interface IDataRetriever {
	
	def Stream<? extends IBidAsk> getData()
	
}