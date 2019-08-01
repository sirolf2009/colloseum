package com.sirolf2009.gladiator.colloseum

import com.sirolf2009.gladiator.colloseum.trading.TradingEngine

class Util {
	
	def static String prettyFormatOrders(TradingEngine engine) {
		engine.getAskOrders().sortBy[getPrice().doubleValue()].reverse().map[getAmount()+" @ "+getPrice()].join("\n")+"\n"+engine.getAsk()+"\n"+engine.getBidOrders().sortBy[getPrice().doubleValue()].reverse().map[getAmount()+" @ "+getPrice()].join("\n")
	}
}