/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassBody
import org.junit.Test

import static org.junit.Assert.*

@TraitClass
abstract class TraitClassBody {

	@ProcessedMethod(processor=StringCombinatorPre)
	override String someMethod() {
		return "Pre"
	}

}

@ExtendedByAuto
class ExtendedBody implements ITraitClassBody {

	override String someMethod() {

		new TypeA() {

			Object obj = Integer::valueOf(1)

			def method() {
				obj
			}

		}

		val obj = new TypeA() {

			Object obj = "Main"

			def method() {
				obj
			}

		}

		return obj.method as String;

	}

}

class TraitsBodyTests {

	@Test
	def void testTraitClassBodyLocalClassesWork() {

		val obj = new ExtendedBody
		assertEquals("PreMain", obj.someMethod)

	}

}
