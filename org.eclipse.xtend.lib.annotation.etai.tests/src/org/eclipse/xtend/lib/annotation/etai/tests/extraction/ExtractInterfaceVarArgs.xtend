package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.junit.Test

import static org.junit.Assert.*

import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceVarArgs

@ExtractInterface
class ExtractInterfaceVarArgs {
	override void methodWithVarArgs(int param1, Object... objs) {}
}

class ExtractVarArgsTestCode {

	@Test
	def void testVarArgs() {
		assertEquals(true, ExtractInterfaceVarArgs.declaredMethods.get(0).varArgs)
		assertEquals(true, IExtractInterfaceVarArgs.declaredMethods.get(0).varArgs)
	}

}
