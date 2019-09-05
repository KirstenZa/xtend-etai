package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPExtendedResultPost
import org.eclipse.xtend.lib.annotation.etai.EPExtendedResultPre
import org.eclipse.xtend.lib.annotation.etai.EPTraitClassResultPost
import org.eclipse.xtend.lib.annotation.etai.EPTraitClassResultPre
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.junit.Test

import static org.junit.Assert.*

class ExtendedResultPostContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassExtendedResultPost {

		@ProcessedMethod(processor=EPExtendedResultPost)
		override int method() {
			TraitTestsBase::TEST_BUFFER += "A"
			10
		}

	}

	@ExtendedByAuto
	static class ExtendedClassExtendedResultPost implements ITraitClassExtendedResultPost {

		override int method() {
			TraitTestsBase::TEST_BUFFER += "B"
			20
		}

	}

}

class ExtendedResultPreContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassExtendedResultPre {

		@ProcessedMethod(processor=EPExtendedResultPre)
		override int method() {
			TraitTestsBase::TEST_BUFFER += "A"
			10
		}

	}

	@ExtendedByAuto
	static class ExtendedClassExtendedResultPre implements ITraitClassExtendedResultPre {

		override int method() {
			TraitTestsBase::TEST_BUFFER += "B"
			20
		}

	}

}

class TraitClassResultPostContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassTraitClassResultPost {

		@ProcessedMethod(processor=EPTraitClassResultPost)
		override int method() {
			TraitTestsBase::TEST_BUFFER += "A"
			10
		}

	}

	@ExtendedByAuto
	static class ExtendedClassTraitClassResultPost implements ITraitClassTraitClassResultPost {

		override int method() {
			TraitTestsBase::TEST_BUFFER += "B"
			20
		}

	}

}

class TraitClassResultPreContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassTraitClassResultPre {

		@ProcessedMethod(processor=EPTraitClassResultPre)
		override int method() {
			TraitTestsBase::TEST_BUFFER += "A"
			10
		}

	}

	@ExtendedByAuto
	static class ExtendedClassTraitClassResultPre implements ITraitClassTraitClassResultPre {

		override int method() {
			TraitTestsBase::TEST_BUFFER += "B"
			20
		}

	}

}

class TraitsPrePostExtendedResultTests extends TraitTestsBase {

	@Test
	def void testExtendedResultPost() {

		val obj = new ExtendedResultPostContainer.ExtendedClassExtendedResultPost()
		assertEquals(20, obj.method)
		assertEquals("BA", TEST_BUFFER)

	}

	@Test
	def void testExtendedResultPre() {

		val obj = new ExtendedResultPreContainer.ExtendedClassExtendedResultPre()
		assertEquals(20, obj.method)
		assertEquals("AB", TEST_BUFFER)

	}

	@Test
	def void testTraitClassResultPost() {

		val obj = new TraitClassResultPostContainer.ExtendedClassTraitClassResultPost()
		assertEquals(10, obj.method)
		assertEquals("BA", TEST_BUFFER)

	}

	@Test
	def void testTraitClassResultPre() {

		val obj = new TraitClassResultPreContainer.ExtendedClassTraitClassResultPre()
		assertEquals(10, obj.method)
		assertEquals("AB", TEST_BUFFER)

	}

}
