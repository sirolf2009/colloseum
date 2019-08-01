package com.sirolf2009.gladiator.colloseum.portfolio

import com.sirolf2009.commonwealth.trading.orderbook.LimitOrder
import com.sirolf2009.gladiator.colloseum.position.OpenPositionBFX
import com.sirolf2009.gladiator.colloseum.trading.TradingEngine
import com.sirolf2009.gladiator.colloseum.trading.fee.PercentageFeeCalculator
import java.util.Date
import org.junit.Assert
import org.junit.Test

class DoublePortfolioTest {
	
	@Test
	def void test() {
		val engine = new TradingEngine(new PercentageFeeCalculator(0, 0), OpenPositionBFX.FACTORY)
		val portfolio = new DoublePortfolio(engine, 0.3, 0.15, 10_000, 1)
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
	
	@Test
	def void testRequiredMargin() {
		val engine = new TradingEngine(new PercentageFeeCalculator(0, 0), OpenPositionBFX.FACTORY)
		val portfolio = new DoublePortfolio(engine, 0.3, 0.15, 10_000, 1)
		
		engine.onNewBidAsk(new Date(), new LimitOrder(6300, 1), new LimitOrder(6300, 1))
		Assert.assertEquals("We don't require margin if we're not in a trade", 0.0d, portfolio.getRequiredMargin(), 0.001d)
		
		engine.placeAskOrder(new LimitOrder(6301, 0.012))
		engine.onNewBidAsk(new Date(), new LimitOrder(6302, 1), new LimitOrder(6302, 1))
		val requiredMarginBase = portfolio.getRequiredMargin()
		Assert.assertTrue("We do require margin if we're in a trade", requiredMarginBase > 0)
		
		engine.onNewBidAsk(new Date(), new LimitOrder(6300, 1), new LimitOrder(6300, 1))
		engine.placeAskOrder(new LimitOrder(6301, 0.012))
		engine.onNewBidAsk(new Date(), new LimitOrder(6302, 1), new LimitOrder(6302, 1))
		Assert.assertEquals("We require double the margin if the trade is twice as big", requiredMarginBase * 2, portfolio.getRequiredMargin(), 0.01d)
	}
	
	@Test
	def void testUnusedMargin() {
		val engine = new TradingEngine(new PercentageFeeCalculator(0, 0), OpenPositionBFX.FACTORY)
		val portfolio = new DoublePortfolio(engine, 0.3, 0.15, 10_000, 1)
		
		engine.onNewBidAsk(new Date(), new LimitOrder(6300, 1), new LimitOrder(6300, 1))
		Assert.assertEquals("When not in a trade, the dollar value sum of our assets is our unused margin", 10_000 + (1 * 6300), portfolio.getUnusedMargin(), 0.001d)
	}
	
}