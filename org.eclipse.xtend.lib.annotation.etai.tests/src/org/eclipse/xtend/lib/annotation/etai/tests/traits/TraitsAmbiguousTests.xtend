/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassAmbiguous1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassAmbiguous2
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassAmbiguous1 {

	/**
	 * method1 in class TraitClassAmbiguous1
	 */
	@RequiredMethod
	abstract override void method1()

	/**
	 * method2 in class TraitClassAmbiguous1
	 */
	@ProcessedMethod(processor=EPVoidPre)
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "B1"
	}

	/**
	 * method3 in class TraitClassAmbiguous1
	 */
	@ProcessedMethod(processor=EPVoidPre)
	override void method3() {

		TraitTestsBase.TEST_BUFFER += "C1"

	}

	/**
	 * method4 in class TraitClassAmbiguous1
	 */
	@ProcessedMethod(processor=EPVoidPre)
	override void method4() {

		TraitTestsBase.TEST_BUFFER += "D1"

	}

	/**
	 * method5 in class TraitClassAmbiguous1
	 */
	@EnvelopeMethod(setFinal=false, required=false)
	override void method5() {

		TraitTestsBase.TEST_BUFFER += "E1"
		method5$extended
		TraitTestsBase.TEST_BUFFER += "E1"

	}

}

@TraitClassAutoUsing
abstract class TraitClassAmbiguous2 {

	/**
	 * method1 in class TraitClassAmbiguous2
	 */
	@ExclusiveMethod
	override void method1() {
		TraitTestsBase.TEST_BUFFER += "A1"
	}

	/**
	 * method2 in class TraitClassAmbiguous2
	 */
	@ProcessedMethod(processor=EPVoidPre)
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "B2"
	}

	/**
	 * method3 in class TraitClassAmbiguous2
	 */
	@ProcessedMethod(processor=EPVoidPre)
	override void method3() {
		TraitTestsBase.TEST_BUFFER += "C2"
	}

	/**
	 * method4 in class TraitClassAmbiguous2
	 */
	@ProcessedMethod(processor=EPVoidPost)
	override void method4() {
		TraitTestsBase.TEST_BUFFER += "D2"
	}

	/**
	 * method5 in class TraitClassAmbiguous2
	 */
	@ProcessedMethod(processor=EPVoidPre)
	override void method5() {
		TraitTestsBase.TEST_BUFFER += "E2"
	}

}

@ExtendedByAuto
abstract class ExtendedClassAmbiguousBase implements ITraitClassAmbiguous1 {
}

@ExtendedByAuto
@ExtractInterface
class ExtendedClassAmbiguousOnePerClass extends ExtendedClassAmbiguousBase implements ITraitClassAmbiguous2 {

	/**
	 * method3 in class ExtendedClassAmbiguousOnePerClass
	 */
	override void method3() {
		TraitTestsBase.TEST_BUFFER += "C3"
		super.method3
	}

	/**
	 * method4 in class ExtendedClassAmbiguousOnePerClass
	 */
	override void method4() {
		TraitTestsBase.TEST_BUFFER += "D3"
		super.method4
	}

	/**
	 * method5 in class ExtendedClassAmbiguousOnePerClass
	 */
	override void method5() {
		TraitTestsBase.TEST_BUFFER += "E3"
		super.method5
	}

}

@ExtendedByAuto
@ExtractInterface
class ExtendedClassAmbiguousMultiplePerClass implements ITraitClassAmbiguous2, ITraitClassAmbiguous1 {

	/**
	 * method3 in class ExtendedClassAmbiguousMultiplePerClass
	 */
	override void method3() {
		TraitTestsBase.TEST_BUFFER += "C3"
	}

	/**
	 * method4 in class ExtendedClassAmbiguousMultiplePerClass
	 */
	override void method4() {
		TraitTestsBase.TEST_BUFFER += "D3"
	}

	/**
	 * method5 in class ExtendedClassAmbiguousMultiplePerClass
	 */
	override void method5() {
		TraitTestsBase.TEST_BUFFER += "E3"
	}

}

@ExtractInterface
class ExtendedClassAmbiguousMultiplePerClassBase {

	/**
	 * method3 in class ExtendedClassAmbiguousMultiplePerClassBase
	 */
	override void method3() {
		TraitTestsBase.TEST_BUFFER += "C3"
	}

	/**
	 * method4 in class ExtendedClassAmbiguousMultiplePerClassBase
	 */
	override void method4() {
		TraitTestsBase.TEST_BUFFER += "D3"
	}

	/**
	 * method5 in class ExtendedClassAmbiguousMultiplePerClassBase
	 */
	override void method5() {
		TraitTestsBase.TEST_BUFFER += "E3"
	}

}

@ExtractInterface
@ExtendedByAuto
class ExtendedClassAmbiguousDerivedMultiplePerClass extends ExtendedClassAmbiguousMultiplePerClassBase implements ITraitClassAmbiguous2, ITraitClassAmbiguous1 {
}

class TraitsAmbiguousTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	def void testTraitClassCombinationInternal(String extensionMethodDetail1, String extensionMethodDetail2,
		String extensionMethodDetail3, String extensionMethodDetail4, String errorMessage) {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod

import virtual.intf.ITraitClassAmbiguous1
import virtual.intf.ITraitClassAmbiguous2

@TraitClassAutoUsing
abstract class TraitClassAmbiguous1 {

	@«extensionMethodDetail1»Method«extensionMethodDetail2»
	override void method() {
	}

}

@TraitClassAutoUsing
abstract class TraitClassAmbiguous2 {

	@«extensionMethodDetail3»Method«extensionMethodDetail4»
	override void method() {
	}

}

@ExtendedByAuto
class ExtendedClassAmbiguous implements ITraitClassAmbiguous1, ITraitClassAmbiguous2 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassAmbiguous")

			val localProblems = (clazz.primarySourceElement as ClassDeclaration).problems

			if (errorMessage !== null) {

				// do assertions
				assertEquals(1, allProblems.size)
				assertEquals(1, localProblems.size)
				assertEquals(Severity.ERROR, localProblems.get(0).severity)

				assertTrue(localProblems.get(0).message.contains(errorMessage))

			} else {

				// do assertions
				assertEquals(0, allProblems.size)
				assertEquals(0, localProblems.size)

			}

		]

	}

	@Test
	def void testTraitMethodCombination() {

		testTraitClassCombinationInternal("Exclusive", "", "Exclusive", "", "as exclusive");
		testTraitClassCombinationInternal("Exclusive", "", "Envelope", "(required=false,setFinal=false)", null);
		testTraitClassCombinationInternal("Exclusive", "", "Processed", "(processor=EPVoidPre)", null);

		testTraitClassCombinationInternal("Processed", "(processor=EPVoidPre)", "Exclusive", "", "as exclusive");
		testTraitClassCombinationInternal("Processed", "(processor=EPVoidPre)", "Envelope",
			"(required=false,setFinal=false)", null);
		testTraitClassCombinationInternal("Processed", "(processor=EPVoidPre)", "Processed",
			"(processor=EPVoidPre)", null);

		testTraitClassCombinationInternal("Envelope", "(required=false,setFinal=false)", "Exclusive", "",
			"as exclusive");
		testTraitClassCombinationInternal("Envelope", "(required=false,setFinal=false)", "Envelope",
			"(required=false,setFinal=false)", null);
		testTraitClassCombinationInternal("Envelope", "(required=false,setFinal=false)", "Processed",
			"(processor=EPVoidPre)", null);

	}

	@Test
	def void testExtensionAmbiguousExtensionInSameAnnotation() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClassAmbiguous
import virtual.intf.ITraitClassAmbiguousDerived

@TraitClassAutoUsing
abstract class TraitClassAmbiguous {
}

@TraitClassAutoUsing
abstract class TraitClassAmbiguousDerived extends TraitClassAmbiguous {
}

@ExtendedByAuto
class ExtendedClassAmbiguous1 implements ITraitClassAmbiguous, ITraitClassAmbiguousDerived {
}

@ExtendedByAuto
class ExtendedClassAmbiguous2 implements ITraitClassAmbiguousDerived, ITraitClassAmbiguous {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtendedClassAmbiguous1")
			val clazz2 = findClass("virtual.ExtendedClassAmbiguous2")

			val localProblems1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val localProblems2 = (clazz2.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, allProblems.size)

			assertEquals(1, localProblems1.size)
			assertEquals(Severity.ERROR, localProblems1.get(0).severity)
			assertTrue(localProblems1.get(0).message.contains("has already been applied"))

			assertEquals(1, localProblems2.size)
			assertEquals(Severity.ERROR, localProblems2.get(0).severity)
			assertTrue(localProblems2.get(0).message.contains("has already been applied"))

		]

	}

	@Test
	def void testExtensionAmbiguousExtension() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.I_X
import virtual.intf.I_XE1
import virtual.intf.I_XE2
import virtual.intf.I_Y1_use_X
import virtual.intf.I_Y2_use_X
import virtual.intf.I_Y3_use_XE1
import virtual.intf.I_Y4_use_XE2
import virtual.intf.I_Z2_use_Y2_use_X
import virtual.intf.I_Z3_use_Y4_use_XE2

@TraitClassAutoUsing
abstract class _X {
}

@TraitClassAutoUsing
abstract class _XE1 extends _X {
}

@TraitClassAutoUsing
abstract class _XE2 extends _X {
}

@TraitClassAutoUsing
abstract class _Y1_use_X implements I_X {
}

@TraitClassAutoUsing
abstract class _Y2_use_X implements I_X {
}

@TraitClassAutoUsing
abstract class _Y3_use_XE1 implements I_XE1 {
}

@TraitClassAutoUsing
abstract class _Y4_use_XE2 implements I_XE2 {
}

@TraitClassAutoUsing
abstract class _Z1_use_Y1_use_X implements I_Y1_use_X {
}

@TraitClassAutoUsing
abstract class _Z2_use_Y2_use_X implements I_Y2_use_X {
}

@TraitClassAutoUsing
abstract class _Z3_use_Y4_use_XE2 implements I_Y4_use_XE2 {
}

@ExtendedByAuto
class A_extBy_X implements I_X {
}

@ExtendedByAuto
class A_extBy_XE2 implements I_XE2 {
}

@ExtendedByAuto
class A_extBy_Y3_use_XE1 implements I_Y3_use_XE1 {	
}

@ExtendedByAuto
class A_extBy_Y2_use_X implements I_Y2_use_X {
}

// must be a problem because trait class has already been applied by parent (no using)
@ExtendedByAuto
class ExtendedScenario1 extends A_extBy_X implements I_X {
}

// must be a problem because super type of trait class has already been applied by parent (no using)
@ExtendedByAuto
class ExtendedScenario2 extends A_extBy_X implements I_XE1 {
}

// must be a problem because derived type of trait class has already been applied by parent (no using)
@ExtendedByAuto
class ExtendedScenario3 extends A_extBy_XE2 implements I_X {
}

// must be a problem because common super type of trait class has already been applied by parent (no using)
@ExtendedByAuto
class ExtendedScenario4 extends A_extBy_XE2 implements I_XE1 {
}

// must not be a problem because using just ensures that extension is used
@ExtendedByAuto
class ExtendedScenario5 extends A_extBy_X implements I_Y1_use_X {
}

// must not be a problem because using (also in base class) just ensures that extension is used
@ExtendedByAuto
class ExtendedScenario6 extends A_extBy_Y2_use_X implements I_Y1_use_X {
}

// must be a problem because using ensures that extension is used and it cannot be applied (directly) again
@ExtendedByAuto
class ExtendedScenario7 extends A_extBy_Y2_use_X implements I_X {
}

// must not be a problem, also in nested using scenarios
@ExtendedByAuto
class ExtendedScenario8 extends A_extBy_Y2_use_X implements I_Z2_use_Y2_use_X {
}

// must not be a problem, also in nested using scenarios
@ExtendedByAuto
class ExtendedScenario9 extends A_extBy_X implements I_Z2_use_Y2_use_X {
}

// must be a problem because a related type (common supertype) has been used and applied in parent
@ExtendedByAuto
class ExtendedScenario10 extends A_extBy_Y3_use_XE1 implements I_Y4_use_XE2 {
}

// must be a problem because a related type (common supertype) has been used and applied in parent
@ExtendedByAuto
class ExtendedScenario11 extends A_extBy_Y3_use_XE1 implements I_Z3_use_Y4_use_XE2 {
}

// must be a problem because a super type has been used and applied in parent
@ExtendedByAuto
class ExtendedScenario12 extends A_extBy_Y2_use_X implements I_Z3_use_Y4_use_XE2 {
}

// must not be a problem because a derived type has been used and applied in parent
@ExtendedByAuto
class ExtendedScenario13 extends A_extBy_Y3_use_XE1 implements I_Z2_use_Y2_use_X {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtendedScenario1")
			val clazz2 = findClass("virtual.ExtendedScenario2")
			val clazz3 = findClass("virtual.ExtendedScenario3")
			val clazz4 = findClass("virtual.ExtendedScenario4")
			val clazz5 = findClass("virtual.ExtendedScenario5")
			val clazz6 = findClass("virtual.ExtendedScenario6")
			val clazz7 = findClass("virtual.ExtendedScenario7")
			val clazz8 = findClass("virtual.ExtendedScenario8")
			val clazz9 = findClass("virtual.ExtendedScenario9")
			val clazz10 = findClass("virtual.ExtendedScenario10")
			val clazz11 = findClass("virtual.ExtendedScenario11")
			val clazz12 = findClass("virtual.ExtendedScenario12")
			val clazz13 = findClass("virtual.ExtendedScenario13")

			val localProblems1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val localProblems2 = (clazz2.primarySourceElement as ClassDeclaration).problems
			val localProblems3 = (clazz3.primarySourceElement as ClassDeclaration).problems
			val localProblems4 = (clazz4.primarySourceElement as ClassDeclaration).problems
			val localProblems5 = (clazz5.primarySourceElement as ClassDeclaration).problems
			val localProblems6 = (clazz6.primarySourceElement as ClassDeclaration).problems
			val localProblems7 = (clazz7.primarySourceElement as ClassDeclaration).problems
			val localProblems8 = (clazz8.primarySourceElement as ClassDeclaration).problems
			val localProblems9 = (clazz9.primarySourceElement as ClassDeclaration).problems
			val localProblems10 = (clazz10.primarySourceElement as ClassDeclaration).problems
			val localProblems11 = (clazz11.primarySourceElement as ClassDeclaration).problems
			val localProblems12 = (clazz12.primarySourceElement as ClassDeclaration).problems
			val localProblems13 = (clazz13.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(8, allProblems.size)

			assertEquals(1, localProblems1.size)
			assertEquals(Severity.ERROR, localProblems1.get(0).severity)
			assertTrue(localProblems1.get(0).message.contains("has already been applied"))

			assertEquals(1, localProblems2.size)
			assertEquals(Severity.ERROR, localProblems2.get(0).severity)
			assertTrue(localProblems2.get(0).message.contains("has already been applied"))

			assertEquals(1, localProblems3.size)
			assertEquals(Severity.ERROR, localProblems3.get(0).severity)
			assertTrue(localProblems3.get(0).message.contains("has already been applied"))

			assertEquals(1, localProblems4.size)
			assertEquals(Severity.ERROR, localProblems4.get(0).severity)
			assertTrue(localProblems4.get(0).message.contains("has already been applied"))

			assertEquals(0, localProblems5.size)

			assertEquals(0, localProblems6.size)

			assertEquals(1, localProblems7.size)
			assertEquals(Severity.ERROR, localProblems7.get(0).severity)
			assertTrue(localProblems7.get(0).message.contains("has already been applied"))

			assertEquals(0, localProblems8.size)

			assertEquals(0, localProblems9.size)

			assertEquals(1, localProblems10.size)
			assertEquals(Severity.ERROR, localProblems10.get(0).severity)
			assertTrue(localProblems10.get(0).message.contains("has already been applied"))

			assertEquals(1, localProblems11.size)
			assertEquals(Severity.ERROR, localProblems11.get(0).severity)
			assertTrue(localProblems11.get(0).message.contains("has already been applied"))

			assertEquals(1, localProblems12.size)
			assertEquals(Severity.ERROR, localProblems12.get(0).severity)
			assertTrue(localProblems12.get(0).message.contains("has already been applied"))

			assertEquals(0, localProblems13.size)

		]

	}

	@Test
	def void testExtensionAmbiguousSimpleName() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClassEmpty

@TraitClassAutoUsing
abstract class TraitClassEmpty {
}

@ExtendedByAuto
class ExtendedClassEmpty implements ITraitClassEmpty, org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassEmpty {
}

	'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassEmpty")

			val localProblems = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, localProblems.size)
			assertEquals(Severity.ERROR, localProblems.get(0).severity)
			assertTrue(localProblems.get(0).message.contains("multiple times"))

		]

	}

	@Test
	def void testExtensionAmbiguousOnePerClassCallMethodRequired() {

		val obj = new ExtendedClassAmbiguousOnePerClass
		obj.method1
		assertEquals("A1", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousOnePerClassCallMethod() {

		val obj = new ExtendedClassAmbiguousOnePerClass
		obj.method2
		assertEquals("B2B1", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousOnePerClassCallMethodAlsoInExtended() {

		val obj = new ExtendedClassAmbiguousOnePerClass
		obj.method3
		assertEquals("C2C3C1", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousOnePerClassCallMethodAlsoInExtendedDifferentProcessors() {

		val obj = new ExtendedClassAmbiguousOnePerClass
		obj.method4
		assertEquals("D3D1D2", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousOnePerClassCallWithEnvelopeMethod() {

		val obj = new ExtendedClassAmbiguousOnePerClass
		obj.method5
		assertEquals("E2E3E1E1", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousMultiplePerClassCallMethodRequired() {

		val obj = new ExtendedClassAmbiguousMultiplePerClass
		obj.method1
		assertEquals("A1", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousMultiplePerClassCallMethod() {

		val obj = new ExtendedClassAmbiguousMultiplePerClass
		obj.method2
		assertEquals("B1B2", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousMultiplePerClassCallMethodAlsoInExtended() {

		val obj = new ExtendedClassAmbiguousMultiplePerClass
		obj.method3
		assertEquals("C1C2C3", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousMultiplePerClassCallMethodAlsoInExtendedDifferentProcessors() {

		val obj = new ExtendedClassAmbiguousMultiplePerClass
		obj.method4
		assertEquals("D1D3D2", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousMultiplePerClassCallWithEnvelopeMethod() {

		val obj = new ExtendedClassAmbiguousMultiplePerClass
		obj.method5
		assertEquals("E1E2E3E1", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousDerivedMultiplePerClassCallMethodRequired() {

		val obj = new ExtendedClassAmbiguousDerivedMultiplePerClass
		obj.method1
		assertEquals("A1", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousDerivedMultiplePerClassCallMethod() {

		val obj = new ExtendedClassAmbiguousDerivedMultiplePerClass
		obj.method2
		assertEquals("B1B2", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousDerivedMultiplePerClassCallMethodAlsoInExtended() {

		val obj = new ExtendedClassAmbiguousDerivedMultiplePerClass
		obj.method3
		assertEquals("C1C2C3", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousDerivedMultiplePerClassCallMethodAlsoInExtendedDifferentProcessors() {

		val obj = new ExtendedClassAmbiguousDerivedMultiplePerClass
		obj.method4
		assertEquals("D1D3D2", TEST_BUFFER)

	}

	@Test
	def void testExtensionAmbiguousDerivedMultiplePerClassCallWithEnvelopeMethod() {

		val obj = new ExtendedClassAmbiguousDerivedMultiplePerClass
		obj.method5
		assertEquals("E1E2E3E1", TEST_BUFFER)

	}

}
