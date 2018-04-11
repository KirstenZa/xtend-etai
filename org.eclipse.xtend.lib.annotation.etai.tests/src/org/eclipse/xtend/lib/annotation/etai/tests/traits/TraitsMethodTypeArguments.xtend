/**
 * Test passes, if this file compiles without problem.
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

class TraitsMethodTypeArgumentsTests extends TraitTestsBase {

	@Test
	def void testTraitMethodTypeArgumentReturns() {

		val obj = new ExtendedMethodTypeArguments
		assertNull(obj.getSomething1(String))
		assertTrue(obj.getSomething2(TypeA) instanceof TypeA)
		assertTrue(obj.getSomething3(TypeA) instanceof List<?>)

	}

}
