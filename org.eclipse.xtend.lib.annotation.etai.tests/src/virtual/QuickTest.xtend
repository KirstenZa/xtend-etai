package virtual

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.tests.traits.TraitTestsBase
import org.junit.Test

import static org.junit.Assert.*

/**
 * <p>This facility can be used to quickly test and debug the compilation of the specified Xtend code.</p>
 */
class QuickTest extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testCompilation() {

		'''

package virtual

		'''.compile [

			assertNull(null)

		]

	}

}
