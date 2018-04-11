package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassEmpty
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArguments
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArgumentsAlternative
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArgumentsBase
import java.util.List
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassTypeArgumentsBase<U, T extends U, X, Y, Z> {

	@ExclusiveMethod
	override T returnSomething1() {
		return null as T
	}

	@ExclusiveMethod
	override X returnSomething2() {
		return null as X
	}

	@ExclusiveMethod
	override Y returnSomething31() {
		return null as Y
	}

	@ExclusiveMethod
	override List<Y> returnSomething32() {
		return null as List<Y>
	}

	@ExclusiveMethod
	override Z returnSomething4() {
		return null as Z
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeArguments<T, U> extends TraitClassTypeArgumentsBase<Number, Double, T, List<T>, List<?>> {

	@ExclusiveMethod
	override T returnSomething5() {
		return null as T
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeArgumentsAlternative<T> {

	@ExclusiveMethod
	override T wrapper(T value) {
		return value
	}

}

@ExtendedByAuto
class ExtendedClassTypeArguments<T> implements ITraitClassTypeArguments<T, Character> {
}

@ExtendedByAuto
class ExtendedClassTypeArgumentsTwoTraits<T> implements ITraitClassTypeArguments<T, Character>, ITraitClassTypeArgumentsAlternative<Double>, ITraitClassEmpty {
}

@ExtendedByAuto
class ExtendedClassDetailsWithWildcard implements ITraitClassTypeArguments<List<?>, Character> {
}

@ExtendedByAuto
class ExtendedClassDetailsWithWildcardExtends implements ITraitClassTypeArguments<List<? extends String>, Character> {
}

@ExtendedByAuto
class ExtendedClassDetailsWithWildcardSuper implements ITraitClassTypeArguments<List<? super String>, Character> {
}

class TraitsClassTypeArgumentsTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testTraitClassTypeArguments() {

		val obj = new ExtendedClassTypeArguments<String>

		var ITraitClassTypeArguments<String, Character> baseInterface2 = obj
		var ITraitClassTypeArgumentsBase<Number, Double, String, List<String>, List<?>> baseInterface1 = obj
		var Double myDouble1 = obj.returnSomething1
		var String myString1 = obj.returnSomething2
		var List<String> myStringList1 = obj.returnSomething31
		var List<List<String>> myStringListList1 = obj.returnSomething32
		var List<?> myList1 = obj.returnSomething4
		var String myString2 = obj.returnSomething5
		assertSame(baseInterface1, obj)
		assertSame(baseInterface2, obj)
		assertNull(myDouble1)
		assertNull(myString1)
		assertNull(myStringList1)
		assertNull(myStringListList1)
		assertNull(myList1)
		assertNull(myString2)

	}

	@Test
	def void testTraitClassTypeArgumentsTwoExtensions() {

		val obj = new ExtendedClassTypeArgumentsTwoTraits<String>

		var ITraitClassTypeArguments<String, Character> baseInterface2 = obj
		var ITraitClassTypeArgumentsBase<Number, Double, String, List<String>, List<?>> baseInterface1 = obj
		var Double myDouble1 = obj.returnSomething1
		var String myString1 = obj.returnSomething2
		var List<String> myStringList1 = obj.returnSomething31
		var List<List<String>> myStringListList1 = obj.returnSomething32
		var List<?> myList1 = obj.returnSomething4
		var String myString2 = obj.returnSomething5
		assertSame(baseInterface1, obj)
		assertSame(baseInterface2, obj)
		assertNull(myDouble1)
		assertNull(myString1)
		assertNull(myStringList1)
		assertNull(myStringListList1)
		assertNull(myList1)
		assertNull(myString2)

		assertEquals(4.5, obj.wrapper(4.5), 0.0001)

	}

	@Test
	def void testTraitClassDetailsWithWildcard() {

		val obj = new ExtendedClassDetailsWithWildcard
		val List<?> myList = obj.returnSomething2
		assertNull(myList)

	}

	@Test
	def void testTraitClassDetailsWithWildcardExtends() {

		val obj = new ExtendedClassDetailsWithWildcardExtends
		val List<? extends String> myList = obj.returnSomething2
		assertNull(myList)

	}

	@Test
	def void testTraitClassDetailsWithWildcardSuper() {

		val obj = new ExtendedClassDetailsWithWildcardSuper
		val List<? super String> myList = obj.returnSomething2
		assertNull(myList)

	}

	@Test
	def void testRecursivelyResolvedAndExtended() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod

import virtual.intf.ITraitClassTypeArguments

@TraitClassAutoUsing
abstract class TraitClassTypeArgumentsBase<Y> {

	@ExclusiveMethod
	override Y returnSomething(Y arg) {
		return null as Y
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeArguments<T> extends TraitClassTypeArgumentsBase<java.util.List<T>> {
}

@ExtendedByAuto
class ExtendedClassTypeArguments<T> implements ITraitClassTypeArguments<String> {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassTypeArguments")

			val methodDeclaration = clazz.declaredMethods.findFirst[it.simpleName == "returnSomething"]

			// do assertions
			assertEquals(1, methodDeclaration.parameters.get(0).type.actualTypeArguments.size)
			assertEquals(string, methodDeclaration.parameters.get(0).type.actualTypeArguments.get(0))

			assertEquals(1, methodDeclaration.returnType.actualTypeArguments.size)
			assertEquals(string, methodDeclaration.returnType.actualTypeArguments.get(0))

		]

	}

}
