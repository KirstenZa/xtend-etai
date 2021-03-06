package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

class TypeAdaptionRuleErrorTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testTypeAdaptionRuleParsingErrors() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

@ExtractInterface
@ApplyRules
class MyComponent1 {

	new(
		@TypeAdaptionRule("applyVariable(var.class.simple);someMethod()")
		Object obj) {
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replaceMyComponent,org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController")
	override Object _ctrl1() {
		return null;
	}

	@TypeAdaptionRule("classTypev;replace(MyComponent,org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController)")
	override Object _ctrl2() {
		return null;
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);someMethod()")
	override Object _ctrl3() {
		return null;
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replace(org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController  )")
		override Object _ctrl4() {
			return null;
		}

	@TypeAdaptionRule(" apply( Test   ) ;replace( MyComponent  ,org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController  )")
	override Object _ctrl5() {
		return null;
	}

}

@ApplyRules
class MyComponent2 extends MyComponent1 {}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.MyComponent1')

			val problemsContructor = (clazz.declaredConstructors.get(0).primarySourceElement as ConstructorDeclaration).
				problems
			val problemsMethod1 = (clazz.findDeclaredMethod("_ctrl1").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod2 = (clazz.findDeclaredMethod("_ctrl2").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod3 = (clazz.findDeclaredMethod("_ctrl3").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod4 = (clazz.findDeclaredMethod("_ctrl4").primarySourceElement as MethodDeclaration).
				problems

			// do assertions
			assertEquals(1, problemsContructor.size)
			assertEquals(Severity.ERROR, problemsContructor.get(0).severity)
			assertTrue(problemsContructor.get(0).message.contains("not found"))
			assertEquals(1, problemsMethod1.size)
			assertEquals(Severity.ERROR, problemsMethod1.get(0).severity)
			assertTrue(problemsMethod1.get(0).message.contains("Incorrect"))
			assertEquals(1, problemsMethod2.size)
			assertEquals(Severity.ERROR, problemsMethod2.get(0).severity)
			assertTrue(problemsMethod2.get(0).message.contains("Incorrect"))
			assertEquals(1, problemsMethod3.size)
			assertEquals(Severity.ERROR, problemsMethod3.get(0).severity)
			assertTrue(problemsMethod3.get(0).message.contains("not found"))
			assertEquals(1, problemsMethod4.size)
			assertEquals(Severity.ERROR, problemsMethod4.get(0).severity)
			assertTrue(problemsMethod4.get(0).message.contains("not found"))

			assertEquals(5, allProblems.size)

		]

	}

	@Test
	def void testTypeAdaptionRuleNotStaticErrors() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

@ApplyRules
class MyComponent {

	@TypeAdaptionRule("applyVariable(var.class.qualified)")
	static def Object method1() {
		return null;
	}

	static def void method2(@TypeAdaptionRule("applyVariable(var.class.qualified)")
	Object param) {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.MyComponent")

			val problemsMethod1 = (clazz.findDeclaredMethod("method1").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod2 = (clazz.findDeclaredMethod("method2", Object.newTypeReference).
				primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod1.size)
			assertEquals(Severity.ERROR, problemsMethod1.get(0).severity)
			assertTrue(problemsMethod1.get(0).message.contains("static"))

			assertEquals(1, problemsMethod2.size)
			assertEquals(Severity.ERROR, problemsMethod2.get(0).severity)
			assertTrue(problemsMethod2.get(0).message.contains("static"))

		]

	}

}
