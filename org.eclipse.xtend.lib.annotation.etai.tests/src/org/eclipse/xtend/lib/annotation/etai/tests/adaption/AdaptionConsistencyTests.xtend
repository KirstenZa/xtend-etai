package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.INotAutoAdaptedExtension
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@ApplyRules
public class AutoAdapted1 {
}

@ApplyRules
public class AutoAdapted2 extends AutoAdapted1 {
}

public class NotAutoAdapted extends AutoAdapted2 {
}

@ApplyRules
@TraitClassAutoUsing
abstract public class AutoAdaptedExtension1 {
}

@ApplyRules
@TraitClassAutoUsing
abstract public class AutoAdaptedExtension2 extends AutoAdaptedExtension1 {
}

@TraitClassAutoUsing
abstract public class NotAutoAdaptedExtension extends AutoAdaptedExtension2 {
}

@ExtendedByAuto
public class NotAutoAdaptedExtendedClass implements INotAutoAdaptedExtension {
}

class AdaptionConsistencyTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test(expected=AssertionError)
	def void testErrorIfNotAutoAdaptedDerivedClass() {

		new NotAutoAdapted()

	}

	@Test(expected=AssertionError)
	def void testErrorIfNotAutoAdaptedTraitClass() {

		new NotAutoAdaptedExtendedClass()

	}

	@Test
	def void testTypeAdaptionRuleErrors() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules

@ApplyRules
public class A {}

public class B extends A {}

@ApplyRules
public class C extends B {}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.C")

			val problemsClass1 = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("but the closer supertype"))

		]

	}

	@Test
	def void testRuleUsageWithoutAutoAdaptionAnnotationErrors() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

import virtual.intf.ISimpleTraitClass

@TraitClassAutoUsing
abstract class SimpleTraitClass {
	@ConstructorMethod
	protected def void create(int param) {}
}

@FactoryMethodRule(factoryMethod="create", initMethod="init")
class TestClass1 {
	def void init() {}
}

@ConstructRule(SimpleTraitClass)
@FactoryMethodRule(factoryMethod="create")
@ExtendedByAuto
class TestClass2 implements ISimpleTraitClass {
}

class TestClass3 {

	@CopyConstructorRule
	new() {
	}

	@TypeAdaptionRule
	def int myMethod() { 0 }

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass('virtual.TestClass1')
			val clazz2 = findClass('virtual.TestClass2')
			val clazz3 = findClass('virtual.TestClass3')

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val problemsClass2 = (clazz2.primarySourceElement as ClassDeclaration).problems
			val problemsConstructor3 = (clazz3.declaredConstructors.get(0).
				primarySourceElement as ConstructorDeclaration).problems
			val problemsMethod3 = (clazz3.declaredMethods.get(0).primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("in context of"))

			assertEquals(2, problemsClass2.size)
			assertEquals(Severity.ERROR, problemsClass2.get(0).severity)
			assertTrue(problemsClass2.get(0).message.contains("in context of"))
			assertEquals(Severity.ERROR, problemsClass2.get(1).severity)
			assertTrue(problemsClass2.get(1).message.contains("in context of"))

			assertEquals(1, problemsConstructor3.size)
			assertEquals(Severity.ERROR, problemsConstructor3.get(0).severity)
			assertTrue(problemsConstructor3.get(0).message.contains("in context of"))

			assertEquals(1, problemsMethod3.size)
			assertEquals(Severity.ERROR, problemsMethod3.get(0).severity)
			assertTrue(problemsMethod3.get(0).message.contains("in context of"))

		]

	}

}
