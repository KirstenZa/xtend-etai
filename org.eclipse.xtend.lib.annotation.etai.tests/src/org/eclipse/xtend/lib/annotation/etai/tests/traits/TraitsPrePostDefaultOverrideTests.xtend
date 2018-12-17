package org.eclipse.xtend.lib.annotation.etai.tests.traits

import java.lang.reflect.Modifier
import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.EPOverride
import org.eclipse.xtend.lib.annotation.etai.EPVoidFinally
import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassDefault
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassFinally
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassOverride
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassPost
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassPre1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassPre2
import org.junit.Test

import static org.junit.Assert.*

class StringCombinatorPre implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		if (expressionExtendedClass === null)
			return expressionTraitClass.eval() as String
		else
			expressionTraitClass.eval() as String + expressionExtendedClass.eval() as String
	}

}

class StringCombinatorPost implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		if (expressionExtendedClass === null)
			return expressionTraitClass.eval() as String
		else
			expressionExtendedClass.eval() as String + expressionTraitClass.eval() as String
	}

}

@TraitClassAutoUsing
abstract class TraitClassPre1 {

	@ProcessedMethod(processor=EPVoidPre)
	override void method() {
		TraitTestsBase.TEST_BUFFER += "A"
	}

	@ProcessedMethod(processor=StringCombinatorPre)
	override String methodReturn() {
		"X"
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void methodBase() {
		TraitTestsBase.TEST_BUFFER += "K"
	}

}

@TraitClassAutoUsing
abstract class TraitClassPre2 {

	@ProcessedMethod(processor=EPVoidPre)
	override void method() {
		TraitTestsBase.TEST_BUFFER += "Z"
	}

}

class ExtendedClassPreBase {

	def void methodBase() {
		TraitTestsBase.TEST_BUFFER += "L"
	}

}

@ExtendedByAuto
class ExtendedClassPre extends ExtendedClassPreBase implements ITraitClassPre1, ITraitClassPre2 {

	override void method() {
		TraitTestsBase.TEST_BUFFER += "B"
	}

	override String methodReturn() {
		"Y"
	}

}

@TraitClassAutoUsing
abstract class TraitClassPost {

	/**
	 * This is the description of the method in TraitClassPost.
	 */
	@ProcessedMethod(processor=EPVoidPost)
	override void method() {
		TraitTestsBase.TEST_BUFFER += "A"
	}

	/**
	 * This is the description of the method in TraitClassPost.
	 */
	@ProcessedMethod(processor=StringCombinatorPost)
	override String methodReturn() {
		"X"
	}

	@ProcessedMethod(processor=EPVoidPost)
	override void methodBase() {
		TraitTestsBase.TEST_BUFFER += "K"
	}

}

class ExtendedClassPostBase {

	def void methodBase() {
		TraitTestsBase.TEST_BUFFER += "L"
	}

}

@ExtendedByAuto
class ExtendedClassPost extends ExtendedClassPostBase implements ITraitClassPost {

	/**
	 * This is the description of the method in ExtendedClassPost.
	 */
	override void method() {
		TraitTestsBase.TEST_BUFFER += "B"
	}

	/**
	 * This is the description of the method in ExtendedClassPost.
	 */
	override String methodReturn() {
		"Y"
	}

}

@TraitClassAutoUsing
abstract class TraitClassDefault {

	/**
	 * This is the description of the method in TraitClassDefault.
	 */
	@ProcessedMethod(processor=EPDefault)
	override void method() {
		TraitTestsBase.TEST_BUFFER += "A"
	}

	/**
	 * This is the description of the method in TraitClassDefault.
	 */
	@ProcessedMethod(processor=EPDefault)
	override int methodReturn() {
		return 1
	}

	/**
	 * This is the description of the method in TraitClassDefault.
	 */
	@ProcessedMethod(processor=EPDefault)
	override int methodReturnDefault() {
		return 55
	}

	@ProcessedMethod(processor=EPDefault)
	override void methodBase() {
		TraitTestsBase.TEST_BUFFER += "K"
	}

	@ProcessedMethod(processor=EPDefault)
	override void methodVisibilityCheck() {
	}

	@ProcessedMethod(processor=EPDefault)
	override void methodVisibilityCheckBase() {
	}

	@ProcessedMethod(processor=EPDefault, setFinal=true)
	override void methodSetFinalCheck() {
	}

}

class ExtendedClassDefaultBase {

	def void methodBase() {
		TraitTestsBase.TEST_BUFFER += "L"
	}

	protected def void methodVisibilityCheckBase() {
	}

	def void methodSetFinalCheck() {
	}

}

@ExtendedByAuto
class ExtendedClassDefault extends ExtendedClassDefaultBase implements ITraitClassDefault {

	override void method() {
		TraitTestsBase.TEST_BUFFER += "B"
	}

	/**
	 * This is the description of the method in ExtendedClassDefault.
	 */
	override int methodReturn() {
		return 99
	}

	protected override void methodVisibilityCheck() {
	}

}

@TraitClassAutoUsing
abstract class TraitClassOverride {

	@ProcessedMethod(processor=EPOverride)
	override void method() {
		TraitTestsBase.TEST_BUFFER += "A"
	}

	@ProcessedMethod(processor=EPOverride)
	override int methodReturn() {
		return 1
	}

	@ProcessedMethod(processor=EPOverride)
	override int methodReturnOverride() {
		return 55
	}

	@ProcessedMethod(processor=EPOverride)
	override void methodBase() {
		TraitTestsBase.TEST_BUFFER += "K"
	}

	@ProcessedMethod(processor=EPDefault)
	override void methodVisibilityCheck() {
	}

	@ProcessedMethod(processor=EPDefault)
	override void methodVisibilityCheckBase() {
	}

}

class ExtendedClassOverrideBase {

	def void methodBase() {
		TraitTestsBase.TEST_BUFFER += "L"
	}

	protected def void methodVisibilityCheckBase() {
	}

}

@ExtendedByAuto
class ExtendedClassOverride extends ExtendedClassOverrideBase implements ITraitClassOverride {

	override void method() {
		TraitTestsBase.TEST_BUFFER += "B"
	}

	override int methodReturn() {
		return 99
	}

	protected override void methodVisibilityCheck() {
	}

}

@TraitClass
abstract class TraitClassFinally {

	@ProcessedMethod(processor=EPVoidFinally)
	override void secureMethod() {

		TraitTestsBase.TEST_BUFFER += "Z"

	}

}

@ExtendedByAuto
class ExtendedClassFinally implements ITraitClassFinally {

	override void secureMethod() {

		TraitTestsBase.TEST_BUFFER += "A"

		// should be always true
		if (TraitTestsBase.TEST_BUFFER.charAt(0) != 'X')
			throw new RuntimeException();

		TraitTestsBase.TEST_BUFFER += "B"

	}

}

class TraitsPrePostDefaultOverrideTests extends TraitTestsBase {

	@Test
	def void testExtensionPre() {

		val obj = new ExtendedClassPre()
		obj.method
		assertEquals("ZAB", TEST_BUFFER)

	}

	@Test
	def void testExtensionPreCombineResult() {

		val obj = new ExtendedClassPre()
		assertEquals("XY", obj.methodReturn)

	}

	@Test
	def void testExtensionPreBase() {

		val obj = new ExtendedClassPre()
		obj.methodBase
		assertEquals("KL", TEST_BUFFER)

	}

	@Test
	def void testExtensionPost() {

		val obj = new ExtendedClassPost()
		obj.method
		assertEquals("BA", TEST_BUFFER)

	}

	@Test
	def void testExtensionPostCombineResult() {

		val obj = new ExtendedClassPost()
		assertEquals("YX", obj.methodReturn)

	}

	@Test
	def void testExtensionPostBase() {

		val obj = new ExtendedClassPost()
		obj.methodBase
		assertEquals("LK", TEST_BUFFER)

	}

	@Test
	def void testExtensionFinally() {

		val obj = new ExtendedClassFinally()
		try {
			obj.secureMethod
		} catch (RuntimeException ex) {
		}
		assertEquals("AZ", TEST_BUFFER)

	}

	@Test
	def void testExtensionDefault() {

		val obj = new ExtendedClassDefault()
		obj.method
		assertEquals("B", TEST_BUFFER)

	}

	@Test
	def void testExtensionDefaultResult() {

		val obj = new ExtendedClassDefault()
		assertEquals(obj.methodReturn, 99)

	}

	@Test
	def void testExtensionDefaultBase() {

		val obj = new ExtendedClassDefault()
		obj.methodBase
		assertEquals("L", TEST_BUFFER)

	}

	@Test
	def void testExtensionDefaultJustExtension() {

		val obj = new ExtendedClassDefault()
		assertEquals(55, obj.methodReturnDefault)

	}

	@Test
	def void testExtensionDefaultOptimized() {

		// if optimized correctly, there is no delegation usage inside of class
		assertTrue(!ExtendedByProcessor::ENABLE_PROCESSOR_SHORTCUT || !ExtendedClassDefault.declaredMethods.exists [
			it.name.contains('$beforeExtended$')
		])

	}

	@Test
	def void testExtensionDefaultVisibilityCheck() {

		assertTrue(
			Modifier.isPublic(ExtendedClassDefault.declaredMethods.findFirst [
				name == "methodVisibilityCheck" && synthetic == false
			].modifiers)
		)
		assertTrue(
			Modifier.isPublic(ExtendedClassDefault.declaredMethods.findFirst [
				name == "methodVisibilityCheckBase" && synthetic == false
			].modifiers)
		)

	}

	@Test
	def void testExtensionDefaultSetFinalCheck() {

		assertTrue(
			Modifier.isFinal(ExtendedClassDefault.declaredMethods.findFirst [
				name == "methodSetFinalCheck" && synthetic == false
			].modifiers)
		)

	}

	@Test
	def void testExtensionOverride() {

		val obj = new ExtendedClassOverride()
		obj.method
		assertEquals("A", TEST_BUFFER)

	}

	@Test
	def void testExtensionOverrideResult() {

		val obj = new ExtendedClassOverride()
		assertEquals(obj.methodReturn, 1)

	}

	@Test
	def void testExtensionOverrideBase() {

		val obj = new ExtendedClassOverride()
		obj.methodBase
		assertEquals("K", TEST_BUFFER)

	}

	@Test
	def void testExtensionOverrideJustExtension() {

		val obj = new ExtendedClassOverride()
		assertEquals(55, obj.methodReturnOverride)

	}

	@Test
	def void testExtensionOverrideVisibilityCheck() {

		assertTrue(
			Modifier.isPublic(ExtendedClassDefault.declaredMethods.findFirst [
				name == "methodVisibilityCheck" && synthetic == false
			].modifiers)
		)
		assertTrue(
			Modifier.isPublic(ExtendedClassDefault.declaredMethods.findFirst [
				name == "methodVisibilityCheckBase" && synthetic == false
			].modifiers)
		)

	}

}
