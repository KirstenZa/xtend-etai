package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPBooleanPostAnd
import org.eclipse.xtend.lib.annotation.etai.EPBooleanPostOr
import org.eclipse.xtend.lib.annotation.etai.EPBooleanPreAnd
import org.eclipse.xtend.lib.annotation.etai.EPBooleanPreOr
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassBooleanProcessorTest
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassBooleanProcessorTest {

	/**
	 * This is the method description in TraitClassBooleanProcessorTest.
	 */
	@ProcessedMethod(processor=EPBooleanPostAnd)
	override boolean methodBooleanPostAnd(int varX) {
		TraitTestsBase.TEST_BUFFER += "X"
		return varX >= 10
	}

	@ProcessedMethod(processor=EPBooleanPreAnd)
	override boolean methodBooleanPreAnd(int varX) {
		TraitTestsBase.TEST_BUFFER += "X"
		return varX >= 10
	}

	@ProcessedMethod(processor=EPBooleanPostOr)
	override boolean methodBooleanPostOr(int varX) {
		TraitTestsBase.TEST_BUFFER += "X"
		return varX >= 10
	}

	@ProcessedMethod(processor=EPBooleanPreOr)
	override boolean methodBooleanPreOr(int varX) {
		TraitTestsBase.TEST_BUFFER += "X"
		return varX >= 10
	}

}

@ExtendedByAuto
class ExtendedClassBooleanProcessorTest implements ITraitClassBooleanProcessorTest {

	/**
	 * This is the method description in ExtendedClassBooleanProcessorTest.
	 */
	override boolean methodBooleanPostAnd(int varX) {
		TraitTestsBase.TEST_BUFFER += "Y"
		return varX >= 7
	}

	override boolean methodBooleanPreAnd(int varX) {
		TraitTestsBase.TEST_BUFFER += "Y"
		return varX >= 7
	}

	override boolean methodBooleanPostOr(int varX) {
		TraitTestsBase.TEST_BUFFER += "Y"
		return varX >= 7
	}

	override boolean methodBooleanPreOr(int varX) {
		TraitTestsBase.TEST_BUFFER += "Y"
		return varX >= 7
	}

}

class TraitsProcessorBooleanTests extends TraitTestsBase {

	@Test
	def void testBooleanPostAnd() {

		val obj = new ExtendedClassBooleanProcessorTest();
		assertEquals(true, obj.methodBooleanPostAnd(11))
		assertEquals(false, obj.methodBooleanPostAnd(9))
		assertEquals(false, obj.methodBooleanPostAnd(6))
		assertEquals("YXYXY", TEST_BUFFER);

	}

	@Test
	def void testBooleanPreAnd() {

		val obj = new ExtendedClassBooleanProcessorTest();
		assertEquals(true, obj.methodBooleanPreAnd(11))
		assertEquals(false, obj.methodBooleanPreAnd(9))
		assertEquals(false, obj.methodBooleanPreAnd(6))
		assertEquals("XYXX", TEST_BUFFER);

	}

	@Test
	def void testBooleanPostOr() {

		val obj = new ExtendedClassBooleanProcessorTest();
		assertEquals(true, obj.methodBooleanPostOr(11))
		assertEquals(true, obj.methodBooleanPostOr(9))
		assertEquals(false, obj.methodBooleanPostOr(6))
		assertEquals("YYYX", TEST_BUFFER);

	}

	@Test
	def void testBooleanPreOr() {

		val obj = new ExtendedClassBooleanProcessorTest();
		assertEquals(true, obj.methodBooleanPreOr(11))
		assertEquals(true, obj.methodBooleanPreOr(9))
		assertEquals(false, obj.methodBooleanPreOr(6))
		assertEquals("XXYXY", TEST_BUFFER);

	}

}
