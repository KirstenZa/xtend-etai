/**
 * Classes in this file should not be renamed because there has been a bug that 
 * only occurs if the names within this file are exactly as is. Probably, this goes back to
 * some collections and hashes.
 * 
 * For this test, which passes if this file compiles without problem, the following files are
 * required:
 * - org.eclipse.xtend.lib.annotation.etai.tests.extraction.ExtractInterfaceDerivedType.xtend
 * - org.eclipse.xtend.lib.annotation.etai.tests.extraction.ExtractInterfaceUpperType.xtend
 * 
 * In order to execute this test, no other class should be in the test project.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceNeededType

@ExtractInterface
abstract class ExtractInterfaceSuperType {
	
	override IExtractInterfaceNeededType getNeededObject() {
		null
	}

}
