/**
 * Test passes if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPFirstNotNullPost
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodTypeArguments
import java.util.ArrayList
import java.util.List
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitMethodTypeArguments {

	@ExclusiveMethod
	override <T extends String> T getSomething1(Class<T> type) {

		var String test = null
		return test as T

	}

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override <T extends TypeA> T getSomething2(Class<T> type) {

		return new TypeA as T

	}

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override <T extends TypeA> List<List<T>> getSomething3(Class<T> type) {

		return new ArrayList<List<T>>

	}

}

@ExtendedByAuto
class ExtendedMethodTypeArguments implements ITraitMethodTypeArguments {

	override <T extends TypeA> T getSomething2(Class<T> type) {

		return null

	}

	override <T extends TypeA> List<List<T>> getSomething3(Class<T> type) {

		return null

	}

}

class MethodTypeArgumentsBase {

	def <V extends TypeA> V getSomething2(Class<V> type) {

		return null

	}

	def <V extends TypeA> List<List<V>> getSomething3(Class<V> type) {

		return null

	}

}

@ExtendedByAuto
class ExtendedMethodTypeArgumentsWithBase extends MethodTypeArgumentsBase implements ITraitMethodTypeArguments {
}

class TraitsMethodTypeArgumentsTests extends TraitTestsBase {

	// using this method avoids warnings concerning unnecessary instanceof tests
	static def boolean instanceOf(Object obj, Class<?> clazz) {
		return clazz.isAssignableFrom(obj.class)
	}

	@Test
	def void testTraitMethodTypeArgumentReturns() {

		{

			val obj = new ExtendedMethodTypeArguments
			assertNull(obj.getSomething1(String))
			assertTrue(obj.getSomething2(TypeA).instanceOf(TypeA))
			assertTrue(obj.getSomething3(TypeA).instanceOf(List))

			assertEquals(1, ExtendedMethodTypeArguments.methods.filter[name == "getSomething1"].size)
			assertEquals(1, ExtendedMethodTypeArguments.methods.filter[name == "getSomething2"].size)
			assertEquals(1, ExtendedMethodTypeArguments.methods.filter[name == "getSomething3"].size)

		}

		{

			val obj = new ExtendedMethodTypeArgumentsWithBase
			assertNull(obj.getSomething1(String))
			assertTrue(obj.getSomething2(TypeA).instanceOf(TypeA))
			assertTrue(obj.getSomething3(TypeA).instanceOf(List))

			assertEquals(1, ExtendedMethodTypeArgumentsWithBase.methods.filter[name == "getSomething1"].size)
			assertEquals(1, ExtendedMethodTypeArgumentsWithBase.methods.filter[name == "getSomething2"].size)
			assertEquals(1, ExtendedMethodTypeArgumentsWithBase.methods.filter[name == "getSomething3"].size)

		}

	}

}
