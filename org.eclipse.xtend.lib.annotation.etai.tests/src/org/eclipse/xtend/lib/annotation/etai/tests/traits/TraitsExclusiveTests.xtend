/**
 * Test passes if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassEmpty
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassExclusive
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassEmpty {
}

/**
 * This is the description of TraitClassExclusive
 */
@TraitClassAutoUsing
abstract class TraitClassExclusive {

	/**
	 * This is the description of the method inside TraitClassExclusive
	 */
	@ExclusiveMethod
	override void method() {
		TraitTestsBase::TEST_BUFFER += "USE"
	}

}

/**
 * This is the description of ExtendedClassExclusive
 */
@ExtendedByAuto
class ExtendedClassExclusive implements ITraitClassExclusive {
}

abstract class ExtendedClassExclusiveDeclareAbstractBase {

	// exclusive trait methods can override abstract methods that have been declared within superclasses of extended class
	abstract def void method()

}

@ExtendedByAuto
class ExtendedClassExclusiveDeclareAbstractFromBase extends ExtendedClassExclusiveDeclareAbstractBase implements ITraitClassExclusive {
}

@ExtendedByAuto
abstract class ExtendedClassExclusiveDeclareAbstract implements ITraitClassExclusive {

	// exclusive trait methods can use abstract methods that have been declared within extended class
	abstract override void method()

}

@ExtendedByAuto
abstract class ExtendedClassExclusiveOverrideExclusive extends ExtendedClassExclusiveDeclareAbstract implements ITraitClassEmpty {

	override void method() {}

}

class ExtendedClassExclusivePrivateBase {
	
	private def void method() {
		TraitTestsBase::TEST_BUFFER += "NOT_USE"
	}

	def void useMethods() {
		method
	}
	
}

@ExtendedByAuto
class ExtendedClassExclusivePrivateDerived extends ExtendedClassExclusivePrivateBase implements ITraitClassExclusive {
}

class TraitsExclusiveTests extends TraitTestsBase  {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testExclusiveDoesNotApplyPrivateInBase() {
		
		val obj = new ExtendedClassExclusivePrivateDerived
		
		TEST_BUFFER = "";
		obj.method
		assertEquals("USE", TEST_BUFFER)
		
	}

	@Test
	def void testExtensionExclusive() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod

import virtual.intf.ITraitClassWithExclusive

@TraitClassAutoUsing
abstract class TraitClassWithExclusive {

	@ExclusiveMethod
	override void method() {
	}

}

@ExtendedByAuto
class ExtendedClassWithExclusive implements ITraitClassWithExclusive {

	override void method() {
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassWithExclusive")

			val clazzProblems = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, clazzProblems.size)
			assertEquals(Severity.ERROR, clazzProblems.get(0).severity)
			assertTrue(clazzProblems.get(0).message.contains("must not exist in the extended class"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testExtensionExclusiveInBaseClass() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface

import virtual.intf.ITraitClassTest

@TraitClassAutoUsing
abstract class TraitClassTest {

	@ExclusiveMethod
	override void method() {
	}

}

@ExtractInterface
class ExtendedClassTestBase {

	override void method() {
	}

}

@ExtendedByAuto
class ExtendedClassTest extends ExtendedClassTestBase implements ITraitClassTest {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassTest")

			val clazzProblems = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, clazzProblems.size)
			assertEquals(Severity.ERROR, clazzProblems.get(0).severity)
			assertTrue(clazzProblems.get(0).message.contains("must not exist in the extended class"))

			assertEquals(1, allProblems.size)

		]

	}

}
