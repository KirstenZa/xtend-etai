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
	def void testInvalidTraitMethods() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod

@TraitClassAutoUsing
abstract class TraitClassInvalid {

	override void method1() {}

	protected def void method2() {}

	@ExclusiveMethod
	private def void method3() {}

	@ExclusiveMethod
    static def void method4() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassInvalid")

			val problemsMethod1 = (clazz.findDeclaredMethod("method1").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod2 = (clazz.findDeclaredMethod("method2").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod3 = (clazz.findDeclaredMethod("method3").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod4 = (clazz.findDeclaredMethod("method4").primarySourceElement as MethodDeclaration).
				problems

			// do assertions
			assertEquals(1, problemsMethod1.size)
			assertEquals(Severity.ERROR, problemsMethod1.get(0).severity)
			assertTrue(problemsMethod1.get(0).message.contains("must be a trait method"))

			assertEquals(1, problemsMethod2.size)
			assertEquals(Severity.ERROR, problemsMethod2.get(0).severity)
			assertTrue(problemsMethod2.get(0).message.contains("must be a trait method"))

			assertEquals(1, problemsMethod3.size)
			assertEquals(Severity.ERROR, problemsMethod3.get(0).severity)
			assertTrue(problemsMethod3.get(0).message.contains("must not be declared private"))

			assertEquals(1, problemsMethod4.size)
			assertEquals(Severity.ERROR, problemsMethod4.get(0).severity)
			assertTrue(problemsMethod4.get(0).message.contains("must not be declared static"))

			assertEquals(4, allProblems.size)

		]

	}

	@Test
	def void testTraitMethodMustBeInsideTraitClass() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
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

	@PriorityEnvelopeMethod(value=200)
		def void method6() {
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
			val problemsMethod6 = (clazz.findDeclaredMethod("method6").primarySourceElement as MethodDeclaration).
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

			assertEquals(1, problemsMethod6.size)
			assertEquals(Severity.ERROR, problemsMethod6.get(0).severity)
			assertTrue(problemsMethod6.get(0).message.contains("only be declared within a trait class"))

			assertEquals(6, allProblems.size)

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
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod

import virtual.intf.ITraitClassBasic

@TraitClassAutoUsing
abstract class TraitClassBasic {

	@RequiredMethod
	override void method1()

	@ProcessedMethod(processor=EPVoidPre)
	override void method2() {}

	@PriorityEnvelopeMethod(value=400)
	override void method3() {}

}

@ExtendedByAuto
class ExtendedClassBasic implements ITraitClassBasic {

	override method1() {}

	override method2() {}

	override method3() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassBasic")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(3, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("inferred"))
			assertEquals(Severity.ERROR, problemsClass.get(1).severity)
			assertTrue(problemsClass.get(1).message.contains("inferred"))
			assertEquals(Severity.ERROR, problemsClass.get(2).severity)
			assertTrue(problemsClass.get(2).message.contains("inferred"))

			assertEquals(3, allProblems.size)

		]

	}

	@Test
	def void testTraitMethodWrongUsageOnFields() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
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

	@PriorityEnvelopeMethod(value=4)
	int dataPriorityEnvelope

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
			val problemsFieldDataPriorityEnvelope = (clazz.findDeclaredField("dataPriorityEnvelope").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldDataExclusive.size)
			assertEquals(Severity.ERROR, problemsFieldDataExclusive.get(0).severity)
			assertTrue(problemsFieldDataExclusive.get(0).message.contains("only applied to a field if"))

			assertEquals(1, problemsFieldDataProcessed.size)
			assertEquals(Severity.ERROR, problemsFieldDataProcessed.get(0).severity)
			assertTrue(problemsFieldDataProcessed.get(0).message.contains("only applied to a field if"))

			assertEquals(1, problemsFieldDataEnvelope.size)
			assertEquals(Severity.ERROR, problemsFieldDataEnvelope.get(0).severity)
			assertTrue(problemsFieldDataEnvelope.get(0).message.contains("only applied to a field if"))

			assertEquals(1, problemsFieldDataPriorityEnvelope.size)
			assertEquals(Severity.ERROR, problemsFieldDataPriorityEnvelope.get(0).severity)
			assertTrue(problemsFieldDataPriorityEnvelope.get(0).message.contains("only applied to a field if"))

			assertEquals(4, allProblems.size)

		]

	}

	@Test
	def void testCannotExtendIfStatic() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

import virtual.intf.ITraitClassBasic

@TraitClassAutoUsing
abstract class TraitClassBasic {

	@RequiredMethod
	override void method1()

	@ProcessedMethod(processor=EPVoidPre, required=false)
	override void method2() {}

	@EnvelopeMethod(required=false)
	override void method3() {}

	@PriorityEnvelopeMethod(value=100, required=false)
	override void method4() {}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassBasic implements ITraitClassBasic {

	static def void method1() {}

	static def void method2() {}

	static def void method3() {}

	static def void method4() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ExtendedClassBasic')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(4, problemsClass.size)
			assertTrue(problemsClass.map[it.message].exists[it.contains("method1") && it.contains("static")])
			assertEquals(Severity.ERROR, problemsClass.findFirst [
				it.message.contains("method1") && it.message.contains("static")
			].severity)
			assertTrue(problemsClass.map[it.message].exists[it.contains("method2") && it.contains("static")])
			assertEquals(Severity.ERROR, problemsClass.findFirst [
				it.message.contains("method2") && it.message.contains("static")
			].severity)
			assertTrue(problemsClass.map[it.message].exists[it.contains("method3") && it.contains("static")])
			assertEquals(Severity.ERROR, problemsClass.findFirst [
				it.message.contains("method3") && it.message.contains("static")
			].severity)
			assertTrue(problemsClass.map[it.message].exists[it.contains("method4") && it.contains("static")])
			assertEquals(Severity.ERROR, problemsClass.findFirst [
				it.message.contains("method4") && it.message.contains("static")
			].severity)

			assertEquals(4, allProblems.size)

		]

	}

	@Test
	def void testCannotExtendIfPrivate() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

import virtual.intf.ITraitClassBasic

@TraitClassAutoUsing
abstract class TraitClassBasic {

	@RequiredMethod
	override void method1()

	@ProcessedMethod(processor=EPVoidPre, required=false)
	override void method2() {}

	@EnvelopeMethod(required=false)
	override void method3() {}

	@PriorityEnvelopeMethod(value=100, required=false)
	override void method4() {}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassBasic implements ITraitClassBasic {

	private def void method1() {}

	private def void method2() {}

	private def void method3() {}

	private def void method4() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ExtendedClassBasic')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(4, problemsClass.size)
			assertTrue(problemsClass.map[it.message].exists[it.contains("method1") && it.contains("private")])
			assertEquals(Severity.ERROR, problemsClass.findFirst [
				it.message.contains("method1") && it.message.contains("private")
			].severity)
			assertTrue(problemsClass.map[it.message].exists[it.contains("method2") && it.contains("private")])
			assertEquals(Severity.ERROR, problemsClass.findFirst [
				it.message.contains("method2") && it.message.contains("private")
			].severity)
			assertTrue(problemsClass.map[it.message].exists[it.contains("method3") && it.contains("private")])
			assertEquals(Severity.ERROR, problemsClass.findFirst [
				it.message.contains("method3") && it.message.contains("private")
			].severity)
			assertTrue(problemsClass.map[it.message].exists[it.contains("method4") && it.contains("private")])
			assertEquals(Severity.ERROR, problemsClass.findFirst [
				it.message.contains("method4") && it.message.contains("private")
			].severity)

			assertEquals(4, allProblems.size)

		]

	}

}
