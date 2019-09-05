package org.eclipse.xtend.lib.annotation.etai.tests.traits

import java.lang.reflect.Modifier
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredImplemented
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredMethodDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredMethodIntermediate
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassRequiredMethod {

	@RequiredMethod
	abstract override void method1()

	@RequiredMethod
	abstract protected def void method2()

	@RequiredMethod
	abstract protected def void method3()

}

@TraitClassAutoUsing
abstract class TraitClassRequiredMethodIntermediate extends TraitClassRequiredMethod {
}

@TraitClassAutoUsing
abstract class TraitClassRequiredMethodDerived extends TraitClassRequiredMethodIntermediate {

	@ExclusiveMethod
	override void method1() {
		TraitTestsBase::TEST_BUFFER += "4"
	}

	@ExclusiveMethod
	override void method2() {
		TraitTestsBase::TEST_BUFFER += "8"
	}

	@ExclusiveMethod
	override void method3() {
		TraitTestsBase::TEST_BUFFER += "2"
	}

}

@TraitClassAutoUsing
abstract class TraitClassRequiredImplemented {

	@ExclusiveMethod
	override void method1() {
		TraitTestsBase::TEST_BUFFER += "X"
	}

	@EnvelopeMethod(required=false)
	override void method2() {
		TraitTestsBase::TEST_BUFFER += "Y"
	}

	@PriorityEnvelopeMethod(value=90, required=false)
	override void method3() {
		TraitTestsBase::TEST_BUFFER += "Z"
	}

}

@ExtendedByAuto
class ExtendedRequiredMethod implements ITraitClassRequiredMethod {

	override void method1() {
		TraitTestsBase::TEST_BUFFER += "3"
	}

	protected def void method2() {
		TraitTestsBase::TEST_BUFFER += "9"
	}

	protected def void method3() {
		TraitTestsBase::TEST_BUFFER += "7"
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedRequiredMethodImplementedAfter implements ITraitClassRequiredMethod, ITraitClassRequiredImplemented {
}

@ExtendedByAuto
@ApplyRules
class ExtendedRequiredMethodImplementedBefore implements ITraitClassRequiredImplemented, ITraitClassRequiredMethod {
}

@ExtendedByAuto
class ExtendedRequiredMethodIntermediate implements ITraitClassRequiredMethodIntermediate {

	override void method1() {
		TraitTestsBase::TEST_BUFFER += "3"
	}

	protected def void method2() {
		TraitTestsBase::TEST_BUFFER += "9"
	}

	protected def void method3() {
		TraitTestsBase::TEST_BUFFER += "7"
	}

}

@ExtendedByAuto
abstract class ExtendedRequiredMethodAbstract implements ITraitClassRequiredMethod {
}

@ExtendedByAuto
abstract class ExtendedRequiredMethodAbstractIntermediate implements ITraitClassRequiredMethodIntermediate {
}

class ExtendedRequiredMethodFromBase {

	protected def void method1() {
		TraitTestsBase::TEST_BUFFER += "3"
	}

	protected def void method2() {
		TraitTestsBase::TEST_BUFFER += "9"
	}

	protected def void method3() {
		TraitTestsBase::TEST_BUFFER += "7"
	}

}

@ExtendedByAuto
class ExtendedRequiredMethodFromBaseCheckVisibility extends ExtendedRequiredMethodFromBase implements ITraitClassRequiredMethod {
}

@ExtendedByAuto
class ExtendedRequiredMethodDerived implements ITraitClassRequiredMethodDerived {
}

class RequiredMethodTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testRequiredMethodInterface() {

		assertTrue(ITraitClassRequiredMethod.getDeclaredMethod("method1") !== null);

	}

	@Test
	def void testRequiredMethodVisibility() {

		assertTrue(Modifier.isPublic(ExtendedRequiredMethod.getDeclaredMethod("method1").modifiers))
		assertTrue(Modifier.isPublic(ExtendedRequiredMethodIntermediate.getDeclaredMethod("method1").modifiers))
		assertTrue(Modifier.isPublic(ExtendedRequiredMethodDerived.getDeclaredMethod("method1").modifiers))
		assertTrue(
			Modifier.isPublic(ExtendedRequiredMethodFromBaseCheckVisibility.getDeclaredMethod("method1").modifiers))

		assertTrue(Modifier.isProtected(ExtendedRequiredMethod.getDeclaredMethod("method2").modifiers))
		assertTrue(Modifier.isProtected(ExtendedRequiredMethodIntermediate.getDeclaredMethod("method2").modifiers))
		assertTrue(Modifier.isPublic(ExtendedRequiredMethodDerived.getDeclaredMethod("method2").modifiers))

		// if optimization is working correctly, this method is not re-implemented
		var exceptionThrown = false
		try {
			ExtendedRequiredMethodFromBaseCheckVisibility.getDeclaredMethod("method2")
		} catch (NoSuchMethodException exception) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

	}

	@Test
	def void testRequiredMethod() {

		val obj = new ExtendedRequiredMethod
		obj.method1
		obj.method2
		obj.method3
		assertEquals("397", TEST_BUFFER);

	}

	@Test
	def void testRequiredMethodImplementedBeforeAndAfter() {

		{

			assertTrue(
				Modifier.isPublic(ExtendedRequiredMethodImplementedBefore.getDeclaredMethod("method1").modifiers))
			assertTrue(
				Modifier.isPublic(ExtendedRequiredMethodImplementedBefore.getDeclaredMethod("method1").modifiers))
			assertTrue(
				Modifier.isPublic(ExtendedRequiredMethodImplementedBefore.getDeclaredMethod("method1").modifiers))

			val obj = new ExtendedRequiredMethodImplementedBefore
			TEST_BUFFER = "";
			obj.method1
			obj.method2
			obj.method3
			assertEquals("XYZ", TEST_BUFFER);

		}

		{

			assertTrue(Modifier.isPublic(ExtendedRequiredMethodImplementedAfter.getDeclaredMethod("method1").modifiers))
			assertTrue(Modifier.isPublic(ExtendedRequiredMethodImplementedAfter.getDeclaredMethod("method1").modifiers))
			assertTrue(Modifier.isPublic(ExtendedRequiredMethodImplementedAfter.getDeclaredMethod("method1").modifiers))

			val obj = new ExtendedRequiredMethodImplementedAfter
			TEST_BUFFER = "";
			obj.method1
			obj.method2
			obj.method3
			assertEquals("XYZ", TEST_BUFFER);

		}

	}

	@Test
	def void testRequiredMethodIntermediate() {

		val obj = new ExtendedRequiredMethodIntermediate
		obj.method1
		obj.method2
		obj.method3
		assertEquals("397", TEST_BUFFER);

	}

	@Test
	def void testRequiredMethodAbstract() {

		assertTrue(Modifier.isAbstract(ExtendedRequiredMethodAbstract.getDeclaredMethod("method2").modifiers));
		assertTrue(Modifier.isAbstract(ExtendedRequiredMethodAbstract.getDeclaredMethod("method3").modifiers));

	}

	@Test
	def void testRequiredMethodAbstractIntermediate() {

		assertTrue(
			Modifier.isAbstract(ExtendedRequiredMethodAbstractIntermediate.getDeclaredMethod("method2").modifiers));
		assertTrue(
			Modifier.isAbstract(ExtendedRequiredMethodAbstractIntermediate.getDeclaredMethod("method3").modifiers));

	}

	@Test
	def void testRequiredMethodDerived() {

		val obj = new ExtendedRequiredMethodDerived
		obj.method1
		obj.method2
		obj.method3
		assertEquals("482", TEST_BUFFER);

	}

	@Test
	def void testRequiredMethodNoUnnecessaryAbstractDeclaration() {

		assertEquals(0, ExtendedRequiredMethodAbstract.declaredMethods.filter [
			name.equals("method1") && synthetic == false
		].size)

	}

	@Test
	def void testRequiredMethodMustBeAbstract() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod

@TraitClassAutoUsing
abstract class TraitClassWithRequiredMethods {

	@RequiredMethod
	override void method() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassWithRequiredMethods")

			val problemsMethod = (clazz.findDeclaredMethod("method").primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod.size)
			assertEquals(Severity.ERROR, problemsMethod.get(0).severity)
			assertTrue(problemsMethod.get(0).message.contains("abstract"))

			assertEquals(1, allProblems.size)

		]

	}

}
