/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedUsingInterface
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassInterfaceImportant
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingInterface
import org.junit.Test

import static org.junit.Assert.*

// Explicitly use this order, which causes trouble without ProcessQueue
@TraitClassAutoUsing
abstract class TraitClassUsingInterface implements ITraitClassInterfaceImportant {
}

@TraitClassAutoUsing
abstract class TraitClassInterfaceImportant {

	@RequiredMethod
	override void method()

}

@ExtendedByAuto
@ExtractInterface
class ExtendedUsingInterface implements ITraitClassUsingInterface {

	override void method() {}

}

class ExtendedUsingInterfaceTests extends TraitTestsBase {

	@Test
	def void testImplementedInterfaces() {

		assertEquals(2, TraitClassUsingInterface.interfaces.size)
		assertSame(ITraitClassInterfaceImportant, TraitClassUsingInterface.interfaces.get(0))
		assertSame(ITraitClassUsingInterface, TraitClassUsingInterface.interfaces.get(1))
		assertEquals(2, ExtendedUsingInterface.interfaces.size)
		assertSame(IExtendedUsingInterface, ExtendedUsingInterface.interfaces.get(1))
		assertSame(ITraitClassUsingInterface, ExtendedUsingInterface.interfaces.get(0))

		assertEquals(1, ITraitClassUsingInterface.interfaces.size)
		assertSame(ITraitClassInterfaceImportant, ITraitClassUsingInterface.interfaces.get(0))
		assertEquals(1, IExtendedUsingInterface.interfaces.size)
		assertSame(ITraitClassUsingInterface, IExtendedUsingInterface.interfaces.get(0))

	}

}
