package org.eclipse.xtend.lib.annotation.etai.tests.traits

import java.lang.reflect.Modifier
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassFinal
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassFinalPriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassFinalTraitMethod1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassFinalTraitMethod2
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassFinal {

	@ExclusiveMethod(setFinal=true)
	override void method1() {}

	@ExclusiveMethod
	override void method2() {}

	@ProcessedMethod(processor=EPVoidPre, setFinal=true)
	override void method3() {}

	@ProcessedMethod(processor=EPVoidPre)
	override void method4() {}

	@EnvelopeMethod(required=false)
	override void method5() {}

	@EnvelopeMethod(required=false, setFinal=false)
	override void method6() {}

	@ProcessedMethod(processor=EPVoidPre)
	override void method7() {}

}

@TraitClassAutoUsing
abstract class TraitClassFinalPriorityEnvelopeMethod {

	@PriorityEnvelopeMethod(value=10)
	override void method2() {}

	@PriorityEnvelopeMethod(value=10)
	override void method4() {}

}

@TraitClassAutoUsing
abstract class TraitClassFinalTraitMethod1 {

	@ProcessedMethod(processor=EPVoidPost)
	final override void method() {}

}

@TraitClassAutoUsing
abstract class TraitClassFinalTraitMethod2 {

	@ProcessedMethod(processor=EPVoidPost)
	override void method() {}

}

@TraitClassAutoUsing
abstract class TraitClassFinalTraitMethod1Derived extends TraitClassFinalTraitMethod1 {
}

@ExtendedByAuto
final class ExtendedClassFinal implements ITraitClassFinal {

	// trait classes applied for this class, can address even methods that are set final locally
	final override void method7() {}

}

@ExtendedByAuto
@ApplyRules
final class ExtendedClassFinalExtendedByPriorityMethod implements ITraitClassFinal, ITraitClassFinalPriorityEnvelopeMethod {

	final override void method4() {}

}

@ExtendedByAuto
final class ExtendedClassFinalExtendedTwice implements ITraitClassFinalTraitMethod1, ITraitClassFinalTraitMethod2 {

	// trait classes applied for this class, can address even methods that are set final locally (apply trait method even twice)
	final override void method() {}

}

class TraitsFinalTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testExclusiveFinal() {

		assertTrue(Modifier.isFinal(ExtendedClassFinal.getDeclaredMethod("method1").modifiers))
		assertTrue(!Modifier.isFinal(ExtendedClassFinal.getDeclaredMethod("method2").modifiers))

	}

	@Test
	def void testProcessedFinal() {

		assertTrue(Modifier.isFinal(ExtendedClassFinal.getDeclaredMethod("method3").modifiers))
		assertTrue(!Modifier.isFinal(ExtendedClassFinal.getDeclaredMethod("method4").modifiers))

	}

	@Test
	def void testEnvelopeFinal() {

		assertTrue(Modifier.isFinal(ExtendedClassFinal.getDeclaredMethod("method5").modifiers))
		assertTrue(!Modifier.isFinal(ExtendedClassFinal.getDeclaredMethod("method6").modifiers))

	}

	@Test
	def void testPriorityEnvelopeMethod() {

		assertTrue(!Modifier.isFinal(ExtendedClassFinalExtendedByPriorityMethod.getDeclaredMethod("method2").modifiers))
		assertTrue(Modifier.isFinal(ExtendedClassFinalExtendedByPriorityMethod.getDeclaredMethod("method4").modifiers))

	}

	@Test
	def void testApplyExtensionToFinal() {

		assertTrue(Modifier.isFinal(ExtendedClassFinal.getDeclaredMethod("method7").modifiers))

		assertTrue(Modifier.isFinal(ExtendedClassFinalExtendedTwice.getDeclaredMethod("method").modifiers))

	}

	@Test
	def void testFinalTraitMethod() {

		assertTrue(Modifier.isFinal(TraitClassFinalTraitMethod1.getDeclaredMethod("method$impl").modifiers))

	}

	@Test
	def void testTraitClassCannotOverrideFinal() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod

import virtual.intf.ITraitClassProcessed1
import virtual.intf.ITraitClassProcessed2
import virtual.intf.ITraitClassProcessed3
import virtual.intf.ITraitClassProcessed4
import virtual.intf.ITraitClassProcessed5

@TraitClassAutoUsing
abstract class TraitClassProcessed1 {
	@ProcessedMethod(processor=EPVoidPre)
	override void method1() {}
}

@TraitClassAutoUsing
abstract class TraitClassProcessed2 {
	@ProcessedMethod(processor=EPVoidPre)
	override void method1() {}
}

@TraitClassAutoUsing
abstract class TraitClassProcessed3 {
	@ProcessedMethod(processor=EPVoidPre, setFinal=true)
	override void method2() {}
}

@TraitClassAutoUsing
abstract class TraitClassProcessed4 {
	@ProcessedMethod(processor=EPVoidPre)
	override void method2() {}
}


@TraitClassAutoUsing
abstract class TraitClassProcessed5 {
	@PriorityEnvelopeMethod(10)
	override void method2() {}
}

@ExtendedByAuto
class ExtendedClassWithFinalBase implements ITraitClassProcessed1, ITraitClassProcessed3 {
	final override void method1() {}
}

@ExtendedByAuto
class ExtendedClassWithFinalDerived1 extends ExtendedClassWithFinalBase implements ITraitClassProcessed2 {
}

@ExtendedByAuto
class ExtendedClassWithFinalDerived2 extends ExtendedClassWithFinalBase implements ITraitClassProcessed4 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassWithFinalDerived3 extends ExtendedClassWithFinalBase implements ITraitClassProcessed5 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazzBase = findClass("virtual.ExtendedClassWithFinalBase")
			val clazzDerived1 = findClass("virtual.ExtendedClassWithFinalDerived1")
			val clazzDerived2 = findClass("virtual.ExtendedClassWithFinalDerived2")
			val clazzDerived3 = findClass("virtual.ExtendedClassWithFinalDerived3")

			val localProblemsBase = (clazzBase.primarySourceElement as ClassDeclaration).problems
			val localProblemsDerived1 = (clazzDerived1.primarySourceElement as ClassDeclaration).problems
			val localProblemsDerived2 = (clazzDerived2.primarySourceElement as ClassDeclaration).problems
			val localProblemsDerived3 = (clazzDerived3.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(0, localProblemsBase.size)

			assertEquals(1, localProblemsDerived1.size)
			assertEquals(Severity.ERROR, localProblemsDerived1.get(0).severity)
			assertTrue(localProblemsDerived1.get(0).message.contains("final"))

			assertEquals(1, localProblemsDerived2.size)
			assertEquals(Severity.ERROR, localProblemsDerived2.get(0).severity)
			assertTrue(localProblemsDerived2.get(0).message.contains("final"))

			assertEquals(1, localProblemsDerived3.size)
			assertEquals(Severity.ERROR, localProblemsDerived3.get(0).severity)
			assertTrue(localProblemsDerived3.get(0).message.contains("final"))

			assertEquals(3, allProblems.size)

		]

	}

	@Test
	def void testTraitClassOverrideFinalMultipleTraitClasses() {

		val tester = new TraitsAmbiguousTests

		tester.testTraitClassCombinationInternal("Exclusive", "(setFinal=true)", "Processed", "(processor=EPVoidPre)",
			"final");
		tester.testTraitClassCombinationInternal("Exclusive", "(setFinal=false)", "Processed", "(processor=EPVoidPre)",
			null);
		tester.testTraitClassCombinationInternal("Processed", "(setFinal=true,processor=EPVoidPre)", "Processed",
			"(processor=EPVoidPre)", "final");
		tester.testTraitClassCombinationInternal("Processed", "(setFinal=false,processor=EPVoidPre)", "Processed",
			"(processor=EPVoidPre,setFinal=true)", null);
		tester.testTraitClassCombinationInternal("Envelope", "(required=false)", "Processed", "(processor=EPVoidPre)",
			"final");
		tester.testTraitClassCombinationInternal("Envelope", "(setFinal=false,required=false)", "Processed",
			"(processor=EPVoidPre,setFinal=true)", null);

	}

}
