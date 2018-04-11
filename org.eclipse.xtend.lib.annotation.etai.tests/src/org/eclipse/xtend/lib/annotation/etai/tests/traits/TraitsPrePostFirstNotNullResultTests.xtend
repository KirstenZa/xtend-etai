package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPFirstNotNullPost
import org.eclipse.xtend.lib.annotation.etai.EPFirstNotNullPre
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.junit.Test

import static org.junit.Assert.*

class FirstNotNullExtendedPostContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassFirstNotNullExtendedPost {

		@ProcessedMethod(processor=EPFirstNotNullPost)
		override Object method() {
			TraitTestsBase.TEST_BUFFER += "A"
			null
		}

	}

	@ExtendedByAuto
	static class ExtendedClassFirstNotNullExtendedPost implements ITraitClassFirstNotNullExtendedPost {

		override Object method() {
			TraitTestsBase.TEST_BUFFER += "B"
			new Object
		}

	}

}

class FirstNotNullTraitClassPostContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassFirstNotNullTraitClassPost {

		@ProcessedMethod(processor=EPFirstNotNullPost)
		override Object method() {
			TraitTestsBase.TEST_BUFFER += "A"
			new Object
		}

	}

	@ExtendedByAuto
	static class ExtendedClassFirstNotNullTraitClassPost implements ITraitClassFirstNotNullTraitClassPost {

		override Object method() {
			TraitTestsBase.TEST_BUFFER += "B"
			null
		}

	}

}

class FirstNotNullExtendedPreContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassFirstNotNullExtendedPre {

		@ProcessedMethod(processor=EPFirstNotNullPre)
		override Object method() {
			TraitTestsBase.TEST_BUFFER += "A"
			null
		}

	}

	@ExtendedByAuto
	static class ExtendedClassFirstNotNullExtendedPre implements ITraitClassFirstNotNullExtendedPre {

		override Object method() {
			TraitTestsBase.TEST_BUFFER += "B"
			new Object
		}

	}

}

class FirstNotNullTraitClassPreContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassFirstNotNullTraitClassPre {

		@ProcessedMethod(processor=EPFirstNotNullPre)
		override Object method() {
			TraitTestsBase.TEST_BUFFER += "A"
			new Object
		}

	}

	@ExtendedByAuto
	static class ExtendedClassFirstNotNullTraitClassPre implements ITraitClassFirstNotNullTraitClassPre {

		override Object method() {
			TraitTestsBase.TEST_BUFFER += "B"
			null
		}

	}

}

class FirstNotNullBothNullPostContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassFirstNotNullBothNullPost {

		@ProcessedMethod(processor=EPFirstNotNullPost)
		override Object method() {
			TraitTestsBase.TEST_BUFFER += "A"
			null
		}

	}

	@ExtendedByAuto
	static class ExtendedClassFirstNotNullBothNullPost implements ITraitClassFirstNotNullBothNullPost {

		override Object method() {
			TraitTestsBase.TEST_BUFFER += "B"
			null
		}

	}

}

class FirstNotNullBothNullPreContainer {

	@TraitClassAutoUsing
	abstract static class TraitClassFirstNotNullBothNullPre {

		@ProcessedMethod(processor=EPFirstNotNullPre)
		override Object method() {
			TraitTestsBase.TEST_BUFFER += "A"
			null
		}

	}

	@ExtendedByAuto
	static class ExtendedClassFirstNotNullBothNullPre implements ITraitClassFirstNotNullBothNullPre {

		override Object method() {
			TraitTestsBase.TEST_BUFFER += "B"
			null
		}

	}

}

class TraitsPrePostFirstNotNullTests extends TraitTestsBase {

	@Test
	def void testFirstNotNullExtendedPost() {

		val obj = new FirstNotNullExtendedPostContainer.ExtendedClassFirstNotNullExtendedPost
		assertNotNull(obj.method)
		assertEquals("B", TEST_BUFFER)

	}

	@Test
	def void testFirstNotNullTraitClassPost() {

		val obj = new FirstNotNullTraitClassPostContainer.ExtendedClassFirstNotNullTraitClassPost()
		assertNotNull(obj.method)
		assertEquals("BA", TEST_BUFFER)

	}

	@Test
	def void testFirstNotNullExtendedPre() {

		val obj = new FirstNotNullExtendedPreContainer.ExtendedClassFirstNotNullExtendedPre()
		assertNotNull(obj.method)
		assertEquals("AB", TEST_BUFFER)

	}

	@Test
	def void testFirstNotNullTraitClassPre() {

		val obj = new FirstNotNullTraitClassPreContainer.ExtendedClassFirstNotNullTraitClassPre()
		assertNotNull(obj.method)
		assertEquals("A", TEST_BUFFER)

	}

	@Test
	def void testFirstNotNullBothNullPost() {

		val obj = new FirstNotNullBothNullPostContainer.ExtendedClassFirstNotNullBothNullPost()
		assertNull(obj.method)
		assertEquals("BA", TEST_BUFFER)

	}

	@Test
	def void testFirstNotNullBothNullPre() {

		val obj = new FirstNotNullBothNullPreContainer.ExtendedClassFirstNotNullBothNullPre()
		assertNull(obj.method)
		assertEquals("AB", TEST_BUFFER)

	}

}
