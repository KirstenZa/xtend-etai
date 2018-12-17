package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.junit.Test

import static org.junit.Assert.*

class AAAXXXXXXBB {
}

class AAAXXXXXXDerivedBB extends AAAXXXXXXBB {
}

@ExtractInterface
@ApplyRules
class TypeAdaptionOverrideRegularExpressionBase {

	@TypeAdaptionRule("apply(AAAXXXXXXBB);replaceAll(AAA(X*)BB,AAA$1DerivedBB)")
	override AAAXXXXXXBB method() {
		return null
	}

}

@ExtractInterface
@ApplyRules
class TypeAdaptionOverrideRegularExpressionDerived extends TypeAdaptionOverrideRegularExpressionBase {
}

class TypeAdaptionRegularExpressionTests {

	@Test
	def void testRegularExpressionAdaption() {

		assertEquals(1, TypeAdaptionOverrideRegularExpressionDerived.declaredMethods.filter[
			name == "method" && synthetic == false
		].size)
		assertSame(AAAXXXXXXDerivedBB, TypeAdaptionOverrideRegularExpressionDerived.declaredMethods.filter[
			name == "method" && synthetic == false
		].get(0).returnType)

	}

}
