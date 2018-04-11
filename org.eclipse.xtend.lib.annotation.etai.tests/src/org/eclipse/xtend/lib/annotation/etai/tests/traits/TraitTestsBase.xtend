package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.junit.Before

abstract class TraitTestsBase {

	static public String TEST_BUFFER

	@Before
	def void prepare() {

		// clear buffer before each test run
		TEST_BUFFER = ""

	}

}
