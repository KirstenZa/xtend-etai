package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.DefaultValueProvider
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassEnvelopeBase
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassEnvelopeDerived
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

class SimpleDefaultValueProvider20 implements DefaultValueProvider<Integer> {

	override Integer getDefaultValue() {
		return 20
	}

}

class SimpleDefaultValueProvider40 implements DefaultValueProvider<Integer> {

	override Integer getDefaultValue() {
		return 40
	}

}

@TraitClassAutoUsing
abstract class TraitClassEnvelopeBase {

	@EnvelopeMethod(required=false)
	override void method1() {
		TraitTestsBase.TEST_BUFFER += "1"
		method1$extended
		method1$extended
	}

	@EnvelopeMethod(required=false)
	override void method1(boolean p1, String x) {
		TraitTestsBase.TEST_BUFFER += (if(p1) "T" else "F") + x + "1"
		method1$extended(p1, x + "B")
		method1$extended(p1, x + "B")
	}

	@EnvelopeMethod(required=false)
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "1"
		method2$extended
		method2$extended
	}

	@EnvelopeMethod(required=false)
	override void method2(boolean p1, String x) {
		TraitTestsBase.TEST_BUFFER += (if(p1) "T" else "F") + x + "1"
		method2$extended(p1, x + "B")
		method2$extended(p1, x + "B")
	}

	@EnvelopeMethod(required=true, setFinal=false)
	override int method3(String x) {
		TraitTestsBase.TEST_BUFFER += x + "1"
		return method3$extended(x + "B")
	}

	@EnvelopeMethod(required=false, defaultValueProvider=SimpleDefaultValueProvider20)
	override int method4(String x) {
		TraitTestsBase.TEST_BUFFER += x + "1"
		return method4$extended(x + "B")
	}

	@EnvelopeMethod(required=false)
	override void method5(int ... args) {
		for (arg : args)
			TraitTestsBase.TEST_BUFFER += arg
		method5$extended(5, 6, 7)
	}

	@EnvelopeMethod(required=true)
	override void methodChangeRequired() {}

}

@TraitClassAutoUsing
abstract class TraitClassEnvelopeDerived extends TraitClassEnvelopeBase {

	@EnvelopeMethod(setFinal=false)
	override void method1() {
		TraitTestsBase.TEST_BUFFER += "9"
		super.method1$impl
	}

	@EnvelopeMethod(required=false, defaultValueProvider=SimpleDefaultValueProvider40)
	override int method4(String x) {
		TraitTestsBase.TEST_BUFFER += "9"
		return super.method4$impl(x)
	}

	@EnvelopeMethod(required=false)
	override void method5(int ... args) {
		super.method5$impl(args)
		TraitTestsBase.TEST_BUFFER += "Z"
	}

	@EnvelopeMethod(required=false)
	override void methodChangeRequired() {}

}

@ExtendedByAuto
class ExtendedByEnvelopeBase implements ITraitClassEnvelopeBase {

	override void method1() {
		TraitTestsBase.TEST_BUFFER += "2"
	}

	override void method1(boolean p1, String x) {
		TraitTestsBase.TEST_BUFFER += (if(p1) "T" else "F") + x + "3"
	}

	override int method3(String x) {
		TraitTestsBase.TEST_BUFFER += x + "2"
		return 10
	}

	override void method5(int ... args) {
		for (arg : args)
			TraitTestsBase.TEST_BUFFER += arg
	}

	override void methodChangeRequired() {}

}

@ExtendedByAuto
class ExtendedByEnvelopeDerived implements ITraitClassEnvelopeDerived {

	override void method1() {
		TraitTestsBase.TEST_BUFFER += "2"
	}

	override int method3(String x) {
		TraitTestsBase.TEST_BUFFER += x + "2"
		return 10
	}

}

class ExtendedByEnvelopeDerivedThenDerived extends ExtendedByEnvelopeDerived {

	override void method1() {
		TraitTestsBase.TEST_BUFFER += "3"
	}

	override int method3(String x) {
		TraitTestsBase.TEST_BUFFER += "3"
		val y = super.method3(x)
		TraitTestsBase.TEST_BUFFER += "4"
		return 99 + y
	}

}

class ClassBE {

	def void method1() {
		TraitTestsBase.TEST_BUFFER += "2"
	}

	def void method1(boolean p1, String x) {
		TraitTestsBase.TEST_BUFFER += (if(p1) "T" else "F") + x + "3"
	}

	def int method3(String x) {
		TraitTestsBase.TEST_BUFFER += x + "2"
		return 10
	}

}

@ExtendedByAuto
class ExtendedByEnvelopeBaseMethodFromClassBE extends ClassBE implements ITraitClassEnvelopeBase {

	override void methodChangeRequired() {}

}

@ExtendedByAuto
class ExtendedByEnvelopeDerivedMethodFromClassBE extends ClassBE implements ITraitClassEnvelopeDerived {
}

class TraitsEnvelopeTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testEnvelopeBasic() {

		val obj = new ExtendedByEnvelopeBase()
		obj.method1
		assertEquals("122", TEST_BUFFER)

	}

	@Test
	def void testEnvelopeMethodNotAvailableInExtendedClass() {

		val obj = new ExtendedByEnvelopeBase()
		obj.method2
		assertEquals("1", TEST_BUFFER)

	}

	@Test
	def void testEnvelopeWithParameter() {

		val obj = new ExtendedByEnvelopeBase()
		obj.method1(true, "A")
		assertEquals("TA1TAB3TAB3", TEST_BUFFER)

	}

	@Test
	def void testEnvelopeWithParameterMethodNotAvailableInExtendedClass() {

		val obj = new ExtendedByEnvelopeBase()
		obj.method2(true, "A")
		assertEquals("TA1", TEST_BUFFER)

	}

	@Test
	def void testEnvelopeWithReturnType() {

		val obj = new ExtendedByEnvelopeBase()
		assertEquals(10, obj.method3("A"))
		assertEquals("A1AB2", TEST_BUFFER)

	}

	@Test
	def void testEnvelopeWithReturnTypeMethodNotAvailableInExtendedClass() {

		val obj = new ExtendedByEnvelopeBase()
		assertEquals(20, obj.method4("A"))
		assertEquals("A1", TEST_BUFFER)

	}

	@Test
	def void testEnvelopeVarArgs() {

		val obj = new ExtendedByEnvelopeBase()
		obj.method5(1, 2, 3)
		assertEquals("123567", TEST_BUFFER)

	}

	@Test
	def void testEnvelopeExtendedByDerived() {

		val obj = new ExtendedByEnvelopeDerived()
		TEST_BUFFER = ""
		obj.method1
		assertEquals("9122", TEST_BUFFER)
		TEST_BUFFER = ""
		obj.method1(true, "A")
		assertEquals("TA1", TEST_BUFFER)
		TEST_BUFFER = ""
		assertEquals(10, obj.method3("A"))
		assertEquals("A1AB2", TEST_BUFFER)
		TEST_BUFFER = ""
		assertEquals(40, obj.method4("A"))
		assertEquals("9A1", TEST_BUFFER)
		TEST_BUFFER = ""
		obj.method5(1, 2, 3)
		assertEquals("123Z", TEST_BUFFER)

	}

	@Test
	def void testEnvelopeExtendedByDerivedThenDerived() {

		val obj = new ExtendedByEnvelopeDerivedThenDerived()
		TEST_BUFFER = ""
		obj.method1
		assertEquals("3", TEST_BUFFER)
		TEST_BUFFER = ""
		assertEquals(109, obj.method3("A"))
		assertEquals("3A1AB24", TEST_BUFFER)

	}

	@Test
	def void testEnvelopeForMethodsInBaseClass() {

		val obj1 = new ExtendedByEnvelopeBaseMethodFromClassBE()
		TEST_BUFFER = ""
		obj1.method1
		assertEquals("122", TEST_BUFFER)
		TEST_BUFFER = ""
		obj1.method2
		assertEquals("1", TEST_BUFFER)
		TEST_BUFFER = ""
		obj1.method1(true, "A")
		assertEquals("TA1TAB3TAB3", TEST_BUFFER)
		TEST_BUFFER = ""
		obj1.method2(true, "A")
		assertEquals("TA1", TEST_BUFFER)
		TEST_BUFFER = ""
		assertEquals(10, obj1.method3("A"))
		assertEquals("A1AB2", TEST_BUFFER)
		TEST_BUFFER = ""
		assertEquals(20, obj1.method4("A"))
		assertEquals("A1", TEST_BUFFER)
		TEST_BUFFER = ""
		obj1.method5(1, 2, 3)
		assertEquals("123", TEST_BUFFER)

		val obj2 = new ExtendedByEnvelopeDerivedMethodFromClassBE()
		TEST_BUFFER = ""
		obj2.method1
		assertEquals("9122", TEST_BUFFER)
		TEST_BUFFER = ""
		obj2.method2
		assertEquals("1", TEST_BUFFER)
		TEST_BUFFER = ""
		obj2.method1(true, "A")
		assertEquals("TA1TAB3TAB3", TEST_BUFFER)
		TEST_BUFFER = ""
		obj2.method2(true, "A")
		assertEquals("TA1", TEST_BUFFER)
		TEST_BUFFER = ""
		assertEquals(10, obj2.method3("A"))
		assertEquals("A1AB2", TEST_BUFFER)
		TEST_BUFFER = ""
		assertEquals(40, obj2.method4("A"))
		assertEquals("9A1", TEST_BUFFER)
		TEST_BUFFER = ""
		obj2.method5(1, 2, 3)
		assertEquals("123Z", TEST_BUFFER)

	}

	@Test
	def void testRequiredFlagMismatch() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod

@TraitClassAutoUsing
abstract class TraitClassEnvelope {

	@EnvelopeMethod(required = false)
	override int method() {
		1
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassEnvelope")

			val problemsMethod = (clazz.findDeclaredMethod("method").primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod.size)
			assertEquals(Severity.ERROR, problemsMethod.get(0).severity)
			assertTrue(problemsMethod.get(0).message.contains("either set the required flag"))

		]

	}

	@Test
	def void testNoDefaultValueProviderForVoid() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.DefaultValueProvider
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

class SimpleValueProvider implements DefaultValueProvider<Integer>
{	
	override getDefaultValue() {}	
}

@TraitClassAutoUsing
abstract class TraitClassEnvelope {

	@EnvelopeMethod(defaultValueProvider=SimpleValueProvider)
	override void method() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassEnvelope")

			val problemsMethod = (clazz.findDeclaredMethod("method").primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod.size)
			assertEquals(Severity.ERROR, problemsMethod.get(0).severity)
			assertTrue(problemsMethod.get(0).message.contains("specify a default value provider"))

		]

	}

	@Test
	def void testEnvelopMethodCannotBeChangedToAnotherType() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

@TraitClassAutoUsing
abstract class TraitClassEnvelope {

	@EnvelopeMethod
	override void method() {}

}

@TraitClassAutoUsing
abstract class TraitClassEnvelopeDerived extends TraitClassEnvelope {

	@ExclusiveMethod
	override void method() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassEnvelopeDerived")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("this type must be used here"))

		]

	}

}
