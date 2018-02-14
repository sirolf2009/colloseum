package com.sirolf2009.gladiator.colloseum.position

import com.sirolf2009.commonwealth.timeseries.Point
import com.sirolf2009.commonwealth.trading.Trade
import org.junit.Test

import static org.junit.Assert.*

class OpenPositionFIFOTest {
	
	@Test
	def void testLong() {
		val position = new OpenPositionFIFO(new Trade(new Point(System.currentTimeMillis(), 1), 1), 1)
		assertEquals(1, position.price)
		assertEquals(1, position.size)
		assertTrue(position.long)
		assertFalse(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 1), 1), 1)
		assertEquals(1, position.price)
		assertEquals(2, position.size)
		assertTrue(position.long)
		assertFalse(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 4), 1), 1)
		assertEquals(2, position.price)
		assertEquals(3, position.size)
		assertTrue(position.long)
		assertFalse(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 4), -1), 1)
		assertEquals(2.5, position.price)
		assertEquals(2, position.size)
		assertTrue(position.long)
		assertFalse(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 4), -1), 1)
		assertEquals(4, position.price)
		assertEquals(1, position.size)
		assertTrue(position.long)
		assertFalse(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 5), -1), 1)
		assertTrue(position.long)
		assertFalse(position.short)
		assertTrue(position.closed)
		
		val closed = position.close
		assertEquals(1, Math.round(closed.profit))
		assertEquals(3, closed.size.doubleValue)
	}
	
	@Test
	def void testShort() {
		val position = new OpenPositionFIFO(new Trade(new Point(System.currentTimeMillis(), 1), -1), 1)
		assertEquals(1, position.price)
		assertEquals(-1, position.size)
		assertFalse(position.long)
		assertTrue(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 1), -1), 1)
		assertEquals(1, position.price)
		assertEquals(-2, position.size)
		assertFalse(position.long)
		assertTrue(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 4), -1), 1)
		assertEquals(2, position.price)
		assertEquals(-3, position.size)
		assertFalse(position.long)
		assertTrue(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 4), 1), 1)
		assertEquals(2.5, position.price)
		assertEquals(-2, position.size)
		assertFalse(position.long)
		assertTrue(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 4), 1), 1)
		assertEquals(4, position.price)
		assertEquals(-1, position.size)
		assertFalse(position.long)
		assertTrue(position.short)
		assertFalse(position.closed)
		
		position.add(new Trade(new Point(System.currentTimeMillis(), 5), 1), 1)
		assertFalse(position.long)
		assertTrue(position.short)
		assertTrue(position.closed)
		
		val closed = position.close
		assertEquals(1, Math.round(closed.profit))
		assertEquals(-3, closed.size.doubleValue)
	}
	
	def void assertEquals(double expected, double actual) {
		assertEquals(expected, actual, 0.00001)
	}
	
}