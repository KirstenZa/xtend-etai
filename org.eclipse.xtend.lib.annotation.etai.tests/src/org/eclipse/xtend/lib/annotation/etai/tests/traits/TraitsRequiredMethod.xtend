package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredMethodDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredMethodIntermediate
import java.lang.reflect.Modifier
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
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

}

@TraitClassAutoUsing
abstract class TraitClassRequiredMethodIntermediate extends TraitClassRequiredMethod {
}

@TraitClassAutoUsing
abstract class TraitClassRequiredMethodDerived extends TraitClassRequiredMethodIntermediate {

	@ExclusiveMethod
	override void method1() {
		TraitTestsBase.TEST_BUFFER += "4"
	}

	@ExclusiveMethod
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "8"
	}

}

@ExtendedByAuto
class ExtendedRequiredMethod implements ITraitClassRequiredMethod {

	override void method1() {
		TraitTestsBase.TEST_BUFFER += "3"
	}

	protected def void method2() {
		TraitTestsBase.TEST_BUFFER += "9"
	}

}

@ExtendedByAuto
class ExtendedRequiredMethodIntermediate implements ITraitClassRequiredMethodIntermediate {

	override void method1() {
		TraitTestsBase.TEST_BUFFER += "3"
	}

	protected def void method2() {
		TraitTestsBase.TEST_BUFFER += "9"
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
		TraitTestsBase.TEST_BUFFER += "3"
	}

	protected def void method2() {
		TraitTestsBase.TEST_BUFFER += "9"
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
		assertEquals("39", TEST_BUFFER);

	}

	@Test
	def void testRequiredMethodIntermediate() {

		val obj = new ExtendedRequiredMethodIntermediate
		obj.method1
		obj.method2
		assertEquals("39", TEST_BUFFER);

	}

	@Test
	def void testRequiredMethodAbstract() {

		assertTrue(Modifier.isAbstract(ExtendedRequiredMethodAbstract.getDeclaredMethod("method2").modifiers));

	}

	@Test
	def void testRequiredMethodAbstractIntermediate() {

		assertTrue(
			Modifier.isAbstract(ExtendedRequiredMethodAbstractIntermediate.getDeclaredMethod("method2").modifiers));

	}

	@Test
	def void testRequiredMethodDerived() {

		val obj = new ExtendedRequiredMethodDerived
		obj.method1
		obj.method2
		assertEquals("48", TEST_BUFFER);

	}

	@Test
	def void testRequiredMethodNoUnnecessaryAbstractDeclaration() {

		assertEquals(0, ExtendedRequiredMethodAbstract.declaredMethods.filter[name.equals("method1")].size)

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
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsMethod.size)
			assertEquals(Severity.ERROR, problemsMethod.get(0).severity)
			assertTrue(problemsMethod.get(0).message.contains("abstract"))

		]

	}

	@Test
	def void testRequiredMethodMustExistsInNonAbstract() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod

import virtual.intf.ITraitClassRequiring

@TraitClassAutoUsing
abstract class TraitClassRequiring {

	@RequiredMethod
	override void method1()

	@RequiredMethod
	protected def void method2()

}

@ExtendedByAuto
class ExtendedClassNotFulfillingRequirement implements ITraitClassRequiring {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassNotFulfillingRequirement")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, allProblems.size)

			assertEquals(2, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("requires method"))
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("requires method"))

		]

	}

}
