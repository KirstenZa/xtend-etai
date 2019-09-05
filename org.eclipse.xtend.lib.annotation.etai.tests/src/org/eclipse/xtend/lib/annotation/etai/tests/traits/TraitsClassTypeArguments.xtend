package org.eclipse.xtend.lib.annotation.etai.tests.traits

import java.util.List
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassEmpty
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArguments
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArgumentsAlternative1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArgumentsAlternative2
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArgumentsAlternative3
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArgumentsBase
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.DefaultValueProviderNull

class TypeCombinatorNotNull implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		if (expressionExtendedClass === null) {
			return expressionTraitClass.eval()
		} else {
			val result1 = expressionTraitClass.eval()
			val result2 = expressionExtendedClass.eval()
			if (result1 !== null)
				return result1
			else
				return result2
		}
	}

}

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
abstract class TraitClassTypeArgumentsAlternative1<T> {

	@ExclusiveMethod
	override T wrapper(T value) {
		return value
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeArgumentsAlternative2<T> {

	T value

	@ExclusiveMethod
	override void setTValue(T value) {
		this.value = value
	}

	@ProcessedMethod(processor=TypeCombinatorNotNull)
	override T getTProcessed1() {
		return value
	}

	@EnvelopeMethod(required=false, defaultValueProvider=DefaultValueProviderNull)
	override T getTEnvelope1() {
		return if (value as Double > 4.0) return value else getTEnvelope1$extended()
	}

	@PriorityEnvelopeMethod(value=10, required=false, defaultValueProvider=DefaultValueProviderNull)
	override T getTEnvelopePriority1() {
		return if (value as Double > 4.0) return value else getTEnvelopePriority1$extended()
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeArgumentsAlternative3<T extends Number> {

	@ProcessedMethod(processor=TypeCombinatorNotNull)
	override T getTProcessed2(T value) {
		return null
	}

	@EnvelopeMethod(required=false, defaultValueProvider=DefaultValueProviderNull)
	override T getTEnvelope2(T value) {
		return if(value.doubleValue > 4.0) value else getTEnvelope2$extended(value)
	}

	@PriorityEnvelopeMethod(value=10, required=false, defaultValueProvider=DefaultValueProviderNull)
	override T getTEnvelopePriority2(T value) {
		return if(value.doubleValue > 4.0) value else getTEnvelopePriority2$extended(value)
	}

}

@ExtendedByAuto
class ExtendedClassTypeArguments<T> implements ITraitClassTypeArguments<T, Character> {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassTypeArgumentsTwoTraits<T, X extends Double> implements ITraitClassTypeArguments<T, Character>, ITraitClassTypeArgumentsAlternative1<Double>, ITraitClassTypeArgumentsAlternative2<X>, ITraitClassTypeArgumentsAlternative3<Double>, ITraitClassEmpty {

	public X concreteValue

	override X getTProcessed1() {
		return null
	}

	override X getTEnvelope1() {
		return concreteValue
	}

	override X getTEnvelopePriority1() {
		return concreteValue 
	}

	override Double getTProcessed2(Double value) {
		return value
	}

	override Double getTEnvelope2(Double value) {
		return 6.0
	}

	override Double getTEnvelopePriority2(Double value) {
		return 6.0
	}

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

		val obj = new ExtendedClassTypeArgumentsTwoTraits<String, Double>

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

		obj.TValue = null
		var Double myDoubleProc1Null = obj.getTProcessed1()
		obj.concreteValue = 55.0
		obj.TValue = 1.0
		var Double myDoubleProc1 = obj.getTProcessed1()
		var Double myDoubleEnv11 = obj.getTEnvelope1()
		var Double myDoublePrio11 = obj.getTEnvelopePriority1()
		obj.TValue = 5.0
		var Double myDoubleEnv12 = obj.getTEnvelope1()
		var Double myDoublePrio12 = obj.getTEnvelopePriority1()

		assertNull(myDoubleProc1Null)
		assertEquals(1.0, myDoubleProc1, 0.1)
		assertEquals(55.0, myDoubleEnv11, 0.1)
		assertEquals(5.0, myDoubleEnv12, 0.1)
		assertEquals(55.0, myDoublePrio11, 0.1)
		assertEquals(5.0, myDoublePrio12, 0.1)

		var Double myDoubleProc2 = obj.getTProcessed2(1.0)
		var Double myDoubleEnv21 = obj.getTEnvelope2(5.0)
		var Double myDoubleEnv22 = obj.getTEnvelope2(3.0)
		var Double myDoublePrio21 = obj.getTEnvelopePriority2(5.0)
		var Double myDoublePrio22 = obj.getTEnvelopePriority2(3.0)

		assertEquals(1.0, myDoubleProc2, 0.1)
		assertEquals(5.0, myDoubleEnv21, 0.1)
		assertEquals(6.0, myDoubleEnv22, 0.1)
		assertEquals(5.0, myDoublePrio21, 0.1)
		assertEquals(6.0, myDoublePrio22, 0.1)

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
