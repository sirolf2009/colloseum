package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.trading.PositionType
import org.junit.Test

import static com.sirolf2009.gladiator.colloseum.position.OpenPositionBFX.*
import static org.junit.Assert.*
import com.sirolf2009.commonwealth.trading.Trade
import com.sirolf2009.commonwealth.timeseries.Point

class OpenPositionBFXTest {
	
	@Test
	def void testCalculateEntry() {
		assertEquals(900, calculateEntry(PositionType.LONG, 1, 100, 1000))
		assertEquals(1100, calculateEntry(PositionType.LONG, 1, -100, 1000))
		assertEquals(1100, calculateEntry(PositionType.SHORT, -1, 100, 1000))
		assertEquals(900, calculateEntry(PositionType.SHORT, -1, -100, 1000))
	}
	
	@Test
	def void addEntryLong() {
		new OpenPositionBFX(new Trade(new Point(now(), 100), 100), 0) => [
			assertEquals(100d, getSize())
			assertEquals(100d, getEntryPrice())

			(1 ..< 100).forEach[index|
				val profit = getProfit(100-index)
				add(new Trade(new Point(now(), 100-index), 100), 0)
				assertTrue(getEntryPrice().doubleValue() < 100d)
				assertEquals(profit, getProfit(100-index))
			]
		]
	}
	
	@Test
	def void addEntryShort() {
		new OpenPositionBFX(new Trade(new Point(now(), 100), -100), 0) => [
			assertEquals(-100d, getSize())
			assertEquals(100d, getEntryPrice())

			(1 ..< 100).forEach[index|
				val profit = getProfit(100+index)
				add(new Trade(new Point(now(), 100+index), 100), 0)
				assertTrue(getEntryPrice().doubleValue() > 100d)
				assertEquals(profit, getProfit(100+index))
			]
		]
	}
	
	def now() {
		return System.currentTimeMillis()
	}
	
	def void assertEquals(double expected, double actual) {
		assertEquals(expected, actual, 0.00001)
	}
	
}