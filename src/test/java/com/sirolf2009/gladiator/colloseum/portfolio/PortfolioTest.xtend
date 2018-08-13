package com.sirolf2009.gladiator.colloseum.portfolio

import com.sirolf2009.commonwealth.trading.orderbook.LimitOrder
import com.sirolf2009.gladiator.colloseum.position.OpenPositionBFX
import com.sirolf2009.gladiator.colloseum.trading.TradingEngine
import com.sirolf2009.gladiator.colloseum.trading.fee.PercentageFeeCalculator
import java.util.Date
import org.junit.Assert
import org.junit.Test

class PortfolioTest {
	
	@Test
	def void test() {
		val engine = new TradingEngine(new PercentageFeeCalculator(0, 0), OpenPositionBFX.FACTORY)
		val portfolio = new Portfolio(engine, 0.3, 0.15, 10_000)
		Assert.assertEquals(33_333.33, portfolio.getMaxTradePosition(), 0.01)
		Assert.assertEquals(0d, portfolio.getRequiredMargin(100), 0.01)
		Assert.assertEquals(0d, portfolio.getRequiredMargin(1000), 0.01)
		Assert.assertEquals(0d, portfolio.getTradeSize(), 0.01)
		Assert.assertEquals(0d, portfolio.getProfit(), 0.01)
		
		engine.placeAskOrder(new LimitOrder(6301, 0.012))
		engine.onNewBidAsk(new Date(), new LimitOrder(6300, 1), new LimitOrder(6300, 1))
		engine.onNewBidAsk(new Date(), new LimitOrder(6302, 1), new LimitOrder(6302, 1))
		
		Assert.assertEquals(13.3d, portfolio.getRequiredMargin(), 0.1d)
		Assert.assertEquals(9986.66d, portfolio.getUnusedMargin(), 0.01d)
		
		engine.placeAskOrder(new LimitOrder(6326, 0.012))
		engine.onNewBidAsk(new Date(), new LimitOrder(6327, 1), new LimitOrder(6327, 1))
		engine.onNewBidAsk(new Date(), new LimitOrder(6326, 1), new LimitOrder(6326, 1))
		
		Assert.assertEquals(26.8d, portfolio.getRequiredMargin(), 0.1d)
		Assert.assertEquals(9973.21d, portfolio.getUnusedMargin(), 0.01d)
	}
	
}