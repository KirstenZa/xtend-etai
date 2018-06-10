/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.implement

import org.eclipse.xtend.lib.annotation.etai.ImplementDefault
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

class TypeBase {
}

class TypeDerived extends TypeBase {
}

interface InterfaceSimple1 {

	def void ifmethod10()

	def int ifmethod11()

	def int ifmethod12(int a)

	def int ifmethod13(int a, int b)

	def int ifmethod14()

	def int ifmethod15()

}

interface InterfaceSimple2 {

	def void ifmethod20()

	def int ifmethod21()

	def int ifmethod22(int a)

	def int ifmethod23(int a, int b)

}

interface InterfaceSimpleDuplicates {

	def void ifmethod20()

}

abstract class AbstractBaseSimple {

	def void method0()

	def int method1()

	def int method2()

	def int method3(int a)

	def int method3(int a, int b)

	def int method4(int a)

	def int method4(int a, int b)

}

abstract class BaseSimple extends AbstractBaseSimple implements InterfaceSimple1 {

	override int method2() { 10 }

	override int method3(int a, int b) { 30 }

	override int ifmethod13(int a, int b) { 70 }

}

@ImplementDefault
class DefaultImplementedSimple extends AbstractBaseSimple {
}

@ImplementDefault
class DefaultImplementedSimpleWithBase extends BaseSimple implements InterfaceSimple2, InterfaceSimpleDuplicates {

	override int method4(int a) { 50 }

	override int ifmethod15() { 90 }

	override int ifmethod23(int a, int b) { 80 }

}

abstract class AbstractBaseCovariance {

	def TypeBase method()

}

@ImplementDefault
class DefaultImplementedCovariance extends AbstractBaseCovariance {

	override TypeDerived method() { new TypeDerived() }

}

abstract class AbstractBaseAllTypes {

	def void methodVoid()

	def boolean methodBoolean()

	def int methodInt()

	def long methodLong()

	def short methodShort()

	def byte methodByte()

	def float methodFloat()

	def double methodDouble()

	def char methodChar()

	def String methodString()
	
	def Integer methodInteger()

	def Object methodObject()

}

@ImplementDefault
class DefaultImplementedAllTypes extends AbstractBaseAllTypes {
}

class ImplementDefaultGeneralTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testDefaultImplementationAllTypes() {

		val obj = new DefaultImplementedAllTypes
		obj.methodVoid
		assertEquals(false, obj.methodBoolean)
		assertEquals(0, obj.methodInt)
		assertEquals(0, obj.methodLong)
		assertEquals(0, obj.methodShort)
		assertEquals(0, obj.methodByte)
		assertEquals(0.0f, obj.methodFloat, 0.0)
		assertEquals(0.0d, obj.methodDouble, 0.0)
		assertEquals(0, obj.methodChar)
		assertNull(obj.methodString)
		assertNull(obj.methodInteger)
		assertNull(obj.methodObject)

	}

	@Test
	def void testDefaultImplementationSimpleWithBase() {

		val obj = new DefaultImplementedSimpleWithBase
		obj.method0
		assertEquals(0, obj.method1)
		assertEquals(10, obj.method2)
		assertEquals(0, obj.method3(20))
		assertEquals(30, obj.method3(100, 200))
		assertEquals(50, obj.method4(20))
		assertEquals(0, obj.method4(100, 200))
		obj.ifmethod10
		assertEquals(0, obj.ifmethod11())
		assertEquals(0, obj.ifmethod12(3))
		assertEquals(70, obj.ifmethod13(1, 5))
		assertEquals(0, obj.ifmethod14())
		assertEquals(90, obj.ifmethod15())
		obj.ifmethod20
		assertEquals(0, obj.ifmethod21())
		assertEquals(0, obj.ifmethod22(5))
		assertEquals(80, obj.ifmethod23(1, 2))

	}

	@Test
	def void testDefaultImplementationDerived() {

		val obj = new DefaultImplementedCovariance
		assertNotNull(obj.method)

	}

	@Test
	def void testNoDefaultImplementationInAbstractClass() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ImplementDefault

@ImplementDefault
abstract class DefaultImplementedAbstract {	
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.DefaultImplementedAbstract")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("default methods in abstract class"))

		]

	}

}
