/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

class TraitsMethodTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testTraitMethodMustBeInsideTraitClass() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod

class RegularClass {

	@ConstructorMethod
	def void method1() {
	}

	@RequiredMethod
	abstract def void method2()

	@ProcessedMethod(processor=EPVoidPost)
	def void method3() {
	}

	@ExclusiveMethod
	def void method4() {
	}

	@EnvelopeMethod
	def void method5() {
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.RegularClass")

			val problemsMethod1 = (clazz.findDeclaredMethod("method1").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod2 = (clazz.findDeclaredMethod("method2").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod3 = (clazz.findDeclaredMethod("method3").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod4 = (clazz.findDeclaredMethod("method4").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod5 = (clazz.findDeclaredMethod("method5").primarySourceElement as MethodDeclaration).
				problems

			// do assertions
			assertEquals(1, problemsMethod1.size)
			assertEquals(Severity.ERROR, problemsMethod1.get(0).severity)
			assertTrue(problemsMethod1.get(0).message.contains("only be declared within a trait class"))

			assertEquals(1, problemsMethod2.size)
			assertEquals(Severity.ERROR, problemsMethod2.get(0).severity)
			assertTrue(problemsMethod2.get(0).message.contains("only be declared within a trait class"))

			assertEquals(1, problemsMethod3.size)
			assertEquals(Severity.ERROR, problemsMethod3.get(0).severity)
			assertTrue(problemsMethod3.get(0).message.contains("only be declared within a trait class"))

			assertEquals(1, problemsMethod4.size)
			assertEquals(Severity.ERROR, problemsMethod4.get(0).severity)
			assertTrue(problemsMethod4.get(0).message.contains("only be declared within a trait class"))

			assertEquals(1, problemsMethod5.size)
			assertEquals(Severity.ERROR, problemsMethod5.get(0).severity)
			assertTrue(problemsMethod5.get(0).message.contains("only be declared within a trait class"))

			assertEquals(5, allProblems.size)

		]

	}
	
	@Test
	def void testExtendedMethodNotInferred() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod

import virtual.intf.ITraitClassBasic

@TraitClassAutoUsing
abstract class TraitClassBasic {

	@RequiredMethod
	override void method1()

	@ProcessedMethod(processor=EPVoidPre)
	override void method2() {}

}

@ExtendedByAuto
class ExtendedClassBasic implements ITraitClassBasic {

	override method1() {}

	override method2() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassBasic")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("inferred"))
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("inferred"))

			assertEquals(2, allProblems.size)

		]

	}
	
	@Test
	def void testTraitMethodWrongUsageOnFields() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod

@TraitClass
abstract class TraitClassWithFields {

	@ExclusiveMethod
	int dataExclusive

	@ProcessedMethod(processor=EPDefault)
	int dataProcessed

	@EnvelopeMethod
	int dataEnvelope

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.TraitClassWithFields')

			val problemsFieldDataExclusive = (clazz.findDeclaredField("dataExclusive").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataProcessed = (clazz.findDeclaredField("dataProcessed").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataEnvelope = (clazz.findDeclaredField("dataEnvelope").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldDataExclusive.size)
			assertEquals(Severity.ERROR, problemsFieldDataExclusive.get(0).severity)
			assertTrue(problemsFieldDataExclusive.get(0).message.contains("only applied to a field, if"))

			assertEquals(1, problemsFieldDataProcessed.size)
			assertEquals(Severity.ERROR, problemsFieldDataProcessed.get(0).severity)
			assertTrue(problemsFieldDataProcessed.get(0).message.contains("only applied to a field, if"))

			assertEquals(1, problemsFieldDataEnvelope.size)
			assertEquals(Severity.ERROR, problemsFieldDataEnvelope.get(0).severity)
			assertTrue(problemsFieldDataEnvelope.get(0).message.contains("only applied to a field, if"))

			assertEquals(3, allProblems.size)

		]

	}

}
