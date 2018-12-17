package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.util.NoSuchElementException
import org.eclipse.xtend.lib.annotation.etai.utils.CollectionUtils.StraightIndexList
import org.junit.Test

import static org.junit.Assert.*

class StraightIndexListTests {

	@Test
	def void testStraightIndexList() {

		var boolean exceptionThrown = false

		val l = new StraightIndexList(10, 5)
		val lEmpty = new StraightIndexList(20, 0)

		// unsupported operations
		exceptionThrown = false
		try {
			l.add(3)
		} catch (UnsupportedOperationException unsupportedOperationException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			l.remove(3)
		} catch (UnsupportedOperationException unsupportedOperationException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			l.clear
		} catch (UnsupportedOperationException unsupportedOperationException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			l.set(0, 3)
		} catch (UnsupportedOperationException unsupportedOperationException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		// get
		assertEquals(10, l.get(0))
		assertEquals(11, l.get(1))
		assertEquals(14, l.get(4))
		exceptionThrown = false
		try {
			l.get(5)
		} catch (IndexOutOfBoundsException indexOutOfBoundException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		// indexOf
		assertEquals(0, l.indexOf(10))
		assertEquals(1, l.indexOf(11))
		assertEquals(2, l.lastIndexOf(12))
		assertEquals(-1, l.indexOf(15))

		// empty
		assertEquals(false, l.empty)
		assertEquals(true, lEmpty.empty)

		// toArray
		val Integer [] array = #[0, 0, 0, 0, 0];
		assertArrayEquals(#[10, 11, 12, 13, 14], l.toArray)
		assertArrayEquals(#[10, 11, 12, 13, 14], l.toArray(array))
		assertArrayEquals(#[10, 11, 12, 13, 14], array)

		// others
		assertEquals(5, l.size)

		// contains
		assertTrue(l.contains(10))
		assertTrue(l.contains(11))
		assertTrue(l.contains(14))
		assertFalse(l.contains(15))
		assertFalse(l.contains(0))

		// sub list
		val subList = l.subList(1, 3)
		assertArrayEquals(#[11, 12], subList.toArray)
		exceptionThrown = false
		try {
			l.subList(1, 0)
		} catch (IndexOutOfBoundsException indexOutOfBoundException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			l.subList(1, 6)
		} catch (IndexOutOfBoundsException indexOutOfBoundException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

	}

	@Test
	def void testStraightIndexListIterator() {

		var boolean exceptionThrown = false
		var int currentIndex = 0

		val l = new StraightIndexList(10, 5)

		// for each
		currentIndex = 10
		for (i : l)
			assertEquals(currentIndex++, i)
		assertEquals(15, currentIndex)

		// list iterator
		val iterator = l.listIterator

		var index = 0
		assertEquals(-1, iterator.previousIndex)
		assertEquals(0, iterator.nextIndex)
		currentIndex = 10
		while (iterator.hasNext) {
			assertEquals(index, iterator.nextIndex)
			assertEquals(index++, iterator.nextIndex)
			assertEquals(currentIndex++, iterator.next)
		}
		assertEquals(15, currentIndex)
		assertEquals(5, iterator.nextIndex)
		exceptionThrown = false
		try {
			iterator.next
		} catch (NoSuchElementException noSuchElementException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		currentIndex--
		index--
		while (iterator.hasPrevious) {
			assertEquals(index, iterator.previousIndex)
			assertEquals(index--, iterator.previousIndex)
			assertEquals(currentIndex--, iterator.previous)
		}
		assertEquals(9, currentIndex)
		assertEquals(-1, iterator.previousIndex)
		assertEquals(0, iterator.nextIndex)
		exceptionThrown = false
		try {
			iterator.previous
		} catch (NoSuchElementException noSuchElementException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

	}

}
