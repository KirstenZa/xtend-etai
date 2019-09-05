package org.eclipse.xtend.lib.annotation.etai.tests.traits

import java.lang.reflect.Modifier
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.DefaultValueProviderNull
import org.eclipse.xtend.lib.annotation.etai.EPFirstNotNullPost
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassPriorityEnvelopeInvalidSuperCall
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodOverridePriorityEnvelopeInTraitClassOverridden
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitPriorityEnvelopeMethodInteracting
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitPriorityEnvelopePrio100
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitPriorityEnvelopePrio300
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitPriorityEnvelopePrio500
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitPriorityEnvelopePrio700
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitPriorityEnvelopePrio900
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod2
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod3
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClass
abstract class TraitPriorityEnvelopePrio100 {

	@PriorityEnvelopeMethod(value=100, required=false, defaultValueProvider=SimpleDefaultValueProvider20)
	override int methodInt() {

		TraitTestsBase::TEST_BUFFER += "P100A"
		try {
			return methodInt$extended + 100
		} finally {
			TraitTestsBase::TEST_BUFFER += "P100B"
		}

	}

	@PriorityEnvelopeMethod(value=100, required=false)
	override void methodVoid(Character anotherParameterName) {

		TraitTestsBase::TEST_BUFFER += "P10_" + anotherParameterName + "_A"
		try {
			var char newChar = anotherParameterName
			newChar++
			methodVoid$extended(newChar)
		} finally {
			TraitTestsBase::TEST_BUFFER += "P100B"
		}

	}

	@PriorityEnvelopeMethod(value=100, required=false)
	override void checkVisiblity1() {}

	@PriorityEnvelopeMethod(value=100, required=false)
	protected def void checkVisiblity2() {}

	@PriorityEnvelopeMethod(value=100, required=false)
	protected def void checkVisiblity3() {}

}

@TraitClass
abstract class TraitPriorityEnvelopePrio300InvalidBase {

	@PriorityEnvelopeMethod(value=99999, required=false, defaultValueProvider=SimpleDefaultValueProvider5000)
	override int methodInt() {

		TraitTestsBase::TEST_BUFFER += "P99999A"
		try {
			return methodInt$extended + 99999
		} finally {
			TraitTestsBase::TEST_BUFFER += "P99999B"
		}

	}

	@PriorityEnvelopeMethod(value=99999, required=false, defaultValueProvider=DefaultValueProviderNull)
	override Double justAnotherMethodWhichMustNotCauseProblems() {

		return null

	}

}

@TraitClass
abstract class TraitPriorityEnvelopePrio300 extends TraitPriorityEnvelopePrio300InvalidBase {

	@PriorityEnvelopeMethod(value=300, required=false, defaultValueProvider=SimpleDefaultValueProvider5000)
	override int methodInt() {

		TraitTestsBase::TEST_BUFFER += "P300A"
		try {
			return methodInt$extended + 300
		} finally {
			TraitTestsBase::TEST_BUFFER += "P300B"
		}

	}

	@PriorityEnvelopeMethod(value=300, required=false)
	override void methodVoid(Character c) {

		TraitTestsBase::TEST_BUFFER += "P30_" + c + "_A"
		try {
			var char newChar = c
			newChar++
			methodVoid$extended(newChar)
		} finally {
			TraitTestsBase::TEST_BUFFER += "P300B"
		}

	}

}

@TraitClass
abstract class TraitPriorityEnvelopePrio500 {

	@PriorityEnvelopeMethod(value=500, required=false, defaultValueProvider=SimpleDefaultValueProvider20)
	override int methodInt() {

		TraitTestsBase::TEST_BUFFER += "P500A"
		try {
			return methodInt$extended + 500
		} finally {
			TraitTestsBase::TEST_BUFFER += "P500B"
		}

	}

	@PriorityEnvelopeMethod(value=500, required=false)
	override void methodVoid(Character anotherParameterName) {

		TraitTestsBase::TEST_BUFFER += "P50_" + anotherParameterName + "_A"
		try {
			var char newChar = anotherParameterName
			newChar++
			methodVoid$extended(newChar)
		} finally {
			TraitTestsBase::TEST_BUFFER += "P500B"
		}

	}

	@PriorityEnvelopeMethod(value=500, required=false)
	override void someMethod() {}

}

@TraitClass
abstract class TraitPriorityEnvelopePrio900 {

	@PriorityEnvelopeMethod(value=900, required=false, defaultValueProvider=SimpleDefaultValueProvider20)
	override int methodInt() {

		TraitTestsBase::TEST_BUFFER += "P900A"
		try {
			return methodInt$extended + 900
		} finally {
			TraitTestsBase::TEST_BUFFER += "P900B"
		}

	}

	@PriorityEnvelopeMethod(value=900, required=false)
	override void methodVoid(Character anotherParameterName) {

		TraitTestsBase::TEST_BUFFER += "P90_" + anotherParameterName + "_A"
		try {
			var char newChar = anotherParameterName
			newChar++
			methodVoid$extended(newChar)
		} finally {
			TraitTestsBase::TEST_BUFFER += "P900B"
		}

	}

	@PriorityEnvelopeMethod(value=900, required=false)
	protected def void checkVisiblity1() {}

	@PriorityEnvelopeMethod(value=900, required=false)
	override void checkVisiblity2() {}

	@PriorityEnvelopeMethod(value=900, required=false)
	protected def void checkVisiblity3() {}

}

@TraitClass
abstract class TraitPriorityEnvelopeSummPrio200 {

	@PriorityEnvelopeMethod(value=200, required=false, defaultValueProvider=SimpleDefaultValueProvider20)
	override Integer sum(Integer a, int b) {
		return a + b
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedByPrio500WithOwn implements ITraitPriorityEnvelopePrio500 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "I"
		return 1
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "I" + c
	}

}

@ApplyRules
class ExtendedByPrioInBetween extends ExtendedByPrio500WithOwn {
}

@ExtendedByAuto
@ApplyRules
class ExtendedByPrio100500900 extends ExtendedByPrioInBetween implements ITraitPriorityEnvelopePrio900, ITraitPriorityEnvelopePrio100 {
}

@ApplyRules
class ExtendedByPrio100500900Override1 extends ExtendedByPrio100500900 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "J"
		return 7
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "J" + c
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedByPrio100300500900Override2 extends ExtendedByPrio100500900Override1 implements ITraitPriorityEnvelopePrio300 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedByPrio100300500700900Override3 extends ExtendedByPrio100300500900Override2 implements ITraitPriorityEnvelopePrio700 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "Q"
		return 10000 + super.methodInt
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "Q" + c
	}

}

@ApplyRules
class ExtendedByPrio100300500700900Override4 extends ExtendedByPrio100300500700900Override3 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "R"
		return 100000 + super.methodInt
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "R" + c
	}

}

@ApplyRules
class ExtendedByPrio100500900OverrideWithSuper extends ExtendedByPrio100500900 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "K"
		return super.methodInt + 1
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "K" + c
		var char newChar = c
		newChar++
		super.methodVoid(newChar)
	}

}

@ApplyRules
class ExtendedByPrio100500900OverrideWithSuperBetween extends ExtendedByPrio100500900OverrideWithSuper {
}

@ApplyRules
class ExtendedByPrio100500900OverrideWithSuperFinal extends ExtendedByPrio100500900OverrideWithSuperBetween {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "L"
		return super.methodInt + 100000
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "L" + c
		var char newChar = c
		newChar++
		super.methodVoid(newChar)
	}

}

class NotExtendedByPrio {

	def int methodInt() {
		TraitTestsBase::TEST_BUFFER += "R"
		return 800
	}

	def void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "R" + c
	}

}

@ApplyRules
@ExtendedByAuto
class ExtendedByPrio100WithSuperToBase extends NotExtendedByPrio implements ITraitPriorityEnvelopePrio100 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "K"
		return super.methodInt + 1
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "K" + c
		var char newChar = c
		newChar++
		super.methodVoid(newChar)
	}

}

@ApplyRules
@ExtendedByAuto
class ExtendedByPrio100WithOwnInBase extends NotExtendedByPrio implements ITraitPriorityEnvelopePrio100 {
}

@ApplyRules
class ExtendedByPrio100WithOwnInBaseWithSuper extends ExtendedByPrio100WithOwnInBase {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "K"
		return super.methodInt + 1
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "K" + c
		var char newChar = c
		newChar++
		super.methodVoid(newChar)
	}

}

@ApplyRules
@ExtendedByAuto
class ExtendedByPrio100300WithOwnInBaseWithSuper extends ExtendedByPrio100WithOwnInBase implements ITraitPriorityEnvelopePrio300 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "K"
		return super.methodInt + 1
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "K" + c
		var char newChar = c
		newChar++
		super.methodVoid(newChar)
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedByPrio900WithoutOwn implements ITraitPriorityEnvelopePrio900 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedByPrio300900WithoutOwnOverride1 extends ExtendedByPrio900WithoutOwn implements ITraitPriorityEnvelopePrio300 {
}

@ApplyRules
class ExtendedByPrio300900WithoutOwnOverride2 extends ExtendedByPrio300900WithoutOwnOverride1 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "K"
		return 1
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "K" + c
	}

}

@ApplyRules
class ExtendedByPrio300900WithoutOwnOverride3 extends ExtendedByPrio300900WithoutOwnOverride1 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "K"
		return super.methodInt + 1
	}

	override void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "K" + c
		var char newChar = c
		newChar++
		super.methodVoid(newChar)
	}

}

@ApplyRules
class ExtendedByPrio500PrivateBase {

	private def void methodVoid(Character c) {
		TraitTestsBase::TEST_BUFFER += "DO_NOT_ADD"
	}

	private def int methodInt() {
		return 777
	}

	def void useMethods() {
		methodVoid('A')
		methodInt
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedByPrio500PrivateDerived extends ExtendedByPrio500PrivateBase implements ITraitPriorityEnvelopePrio500 {

	override int methodInt() {
		return 555
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedByCheckVisibilityAllProtected implements ITraitPriorityEnvelopePrio900, ITraitPriorityEnvelopePrio100 {

	protected override void checkVisiblity1() {}

	protected override void checkVisiblity2() {}

	protected def void checkVisiblity3() {}

}

@ExtendedByAuto
@ApplyRules
class ExtendedByCheckVisibilityAllPublic implements ITraitPriorityEnvelopePrio900, ITraitPriorityEnvelopePrio100 {

	override void checkVisiblity1() {}

	override void checkVisiblity2() {}

	def void checkVisiblity3() {}

}

@ApplyRules
class ExtendedByCheckVisibilityAllProtectedInBaseBase {

	protected def void checkVisiblity1() {}

	protected def void checkVisiblity2() {}

	protected def void checkVisiblity3() {}

}

@ExtendedByAuto
@ApplyRules
class ExtendedByCheckVisibilityAllProtectedInBase extends ExtendedByCheckVisibilityAllProtectedInBaseBase implements ITraitPriorityEnvelopePrio900, ITraitPriorityEnvelopePrio100 {
}

@ApplyRules
class ExtendedByCheckVisibilityAllPublicInBaseBase {

	def void checkVisiblity1() {}

	def void checkVisiblity2() {}

	def void checkVisiblity3() {}

}

@ExtendedByAuto
@ApplyRules
class ExtendedByCheckVisibilityAllPublicInBase extends ExtendedByCheckVisibilityAllPublicInBaseBase implements ITraitPriorityEnvelopePrio900, ITraitPriorityEnvelopePrio100 {
}

@TraitClassAutoUsing
abstract class TraitMethodOverridePriorityEnvelopeInTraitClass {

	@PriorityEnvelopeMethod(value=101)
	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "R"
		methodInt$extended
		return 5
	}

	@PriorityEnvelopeMethod(value=100, required=true)
	override void methodVoid(Character parName) {
	}

}

@TraitClassAutoUsing
abstract class TraitMethodOverridePriorityEnvelopeInTraitClassOverridden extends TraitMethodOverridePriorityEnvelopeInTraitClass {

	@PriorityEnvelopeMethod(value=99)
	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "S"
		methodInt$extended
		return 20
	}

	// test: override priority in order to avoid problem 
	@PriorityEnvelopeMethod(value=99, required=false)
	override void methodVoid(Character anotherParameterName) {}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassOverridePriorityEnvelopeInTraitClass implements ITraitMethodOverridePriorityEnvelopeInTraitClassOverridden, ITraitPriorityEnvelopePrio100 {

	override int methodInt() {
		TraitTestsBase::TEST_BUFFER += "T"
		return 10
	}

}

@TraitClass
abstract class TraitClassPriorityEnvelopeInvalidSuperCall {

	@PriorityEnvelopeMethod(value=900, required=false)
	override void methodPriorityEnvelopeMethod() {
		methodPriorityEnvelopeMethod$extended
	}

}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedClassPriorityEnvelopeInvalidSuperCallAbstract implements ITraitClassPriorityEnvelopeInvalidSuperCall {
}

@ApplyRules
class ExtendedClassPriorityEnvelopeInvalidSuperCall extends ExtendedClassPriorityEnvelopeInvalidSuperCallAbstract {

	override void methodPriorityEnvelopeMethod() {
		super.methodPriorityEnvelopeMethod
	}

}

@TraitClass
abstract class TraitPriorityEnvelopeMethodInteracting {

	@PriorityEnvelopeMethod(value=99, required=true)
	override void methodVoid(Character anotherParameterName) {
		TraitTestsBase::TEST_BUFFER += anotherParameterName + "9"
		methodVoid$extended("c")
	}

	@PriorityEnvelopeMethod(value=99, required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeA methodTyped() {
		TraitTestsBase::TEST_BUFFER += "A"
		return methodTyped$extended()
	}

}

@TraitClassAutoUsing
abstract class TraitProcessedMethodInteractingWithPriorityEnvelopeMethod1 {

	@ProcessedMethod(processor=EPVoidPre)
	override void methodVoid(Character parName) {
		TraitTestsBase::TEST_BUFFER += parName + "1"
	}

}

@TraitClassAutoUsing
abstract class TraitProcessedMethodInteractingWithPriorityEnvelopeMethod2 {

	@ProcessedMethod(processor=EPVoidPre)
	override void methodVoid(Character parName) {
		TraitTestsBase::TEST_BUFFER += parName + "2"
	}

}

@TraitClassAutoUsing
abstract class TraitProcessedMethodInteractingWithPriorityEnvelopeMethod3 {

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override TypeB methodTyped() {
		TraitTestsBase::TEST_BUFFER += "B"
		return new TypeB
	}

}

@TraitClassAutoUsing
abstract class TraitExclusiveMethodInteractingWithPriorityEnvelopeMethod {

	@ExclusiveMethod
	override void methodVoid(Character parName) {
		TraitTestsBase::TEST_BUFFER += parName + "1"
	}

	@ExclusiveMethod
	override TypeB methodTyped() {
		TraitTestsBase::TEST_BUFFER += "B"
		return new TypeB
	}

}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedClassPriorityEnvelopeMethodInteractionWithPre1 implements ITraitPriorityEnvelopeMethodInteracting {
}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedClassPriorityEnvelopeMethodInteractionWithPre2 implements ITraitPriorityEnvelopeMethodInteracting, ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod2 {
}

@ApplyRules
abstract class ExtendedClassPriorityEnvelopeMethodInteractionWithBetween1 extends ExtendedClassPriorityEnvelopeMethodInteractionWithPre1 {
}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedClassPriorityEnvelopeMethodInteractionWithPreImplementation implements ITraitPriorityEnvelopeMethodInteracting {

	override void methodVoid(Character parNameX) {

		TraitTestsBase::TEST_BUFFER += parNameX + "P";

	}

	override TypeA methodTyped() {

		TraitTestsBase::TEST_BUFFER += "P";
		return null

	}

}

@ApplyRules
abstract class ExtendedClassPriorityEnvelopeMethodInteractionWithBetween2 extends ExtendedClassPriorityEnvelopeMethodInteractionWithPreImplementation {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed1 implements ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod1, ITraitPriorityEnvelopeMethodInteracting {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed2 implements ITraitPriorityEnvelopeMethodInteracting, ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod1 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed3 extends ExtendedClassPriorityEnvelopeMethodInteractionWithPre1 implements ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod1 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed4 extends ExtendedClassPriorityEnvelopeMethodInteractionWithPre2 implements ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod1 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed6 extends ExtendedClassPriorityEnvelopeMethodInteractionWithBetween1 implements ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod1 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithProcessedCovariance extends ExtendedClassPriorityEnvelopeMethodInteractionWithPreImplementation implements ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod3 {
}

class TraitsPriorityEnvelopeTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testPriorityEnvelopeInTraitBaseClass() {

		val obj = new ExtendedByPrio100300500900Override2
		assertNull(obj.justAnotherMethodWhichMustNotCauseProblems)

	}

	@Test
	def void testPriorityEnvelopePrio500WithOwn() {

		val obj = new ExtendedByPrio500WithOwn

		TEST_BUFFER = "";
		obj.methodVoid('A')
		assertEquals("P50_A_AIBP500B", TEST_BUFFER)

		TEST_BUFFER = "";
		assertEquals(501, obj.methodInt)
		assertEquals("P500AIP500B", TEST_BUFFER)

	}

	@Test
	def void testPriorityEnvelopePrio500WithOwnInBase() {

		val obj = new ExtendedByPrio100WithOwnInBase

		TEST_BUFFER = "";
		obj.methodVoid('A')
		assertEquals("P10_A_ARBP100B", TEST_BUFFER)

		TEST_BUFFER = "";
		assertEquals(900, obj.methodInt)
		assertEquals("P100ARP100B", TEST_BUFFER)

	}

	@Test
	def void testPriorityEnvelopePrio900WithoutOwn() {

		val obj = new ExtendedByPrio900WithoutOwn

		TEST_BUFFER = "";
		obj.methodVoid('A')
		assertEquals("P90_A_AP900B", TEST_BUFFER)

		TEST_BUFFER = "";
		assertEquals(920, obj.methodInt)
		assertEquals("P900AP900B", TEST_BUFFER)

	}

	@Test
	def void testPriorityEnvelopePrio100500900Order() {

		val obj = new ExtendedByPrio100500900

		TEST_BUFFER = "";
		obj.methodVoid('A')
		assertEquals("P90_A_AP50_B_AP10_C_AIDP100BP500BP900B", TEST_BUFFER)

		TEST_BUFFER = "";
		assertEquals(1501, obj.methodInt)
		assertEquals("P900AP500AP100AIP100BP500BP900B", TEST_BUFFER)

	}

	@Test
	def void testPriorityEnvelopePrio100500900Override() {

		val obj = new ExtendedByPrio100500900Override1

		TEST_BUFFER = "";
		obj.methodVoid('A')
		assertEquals("P90_A_AP50_B_AP10_C_AJDP100BP500BP900B", TEST_BUFFER)

		TEST_BUFFER = "";
		assertEquals(1507, obj.methodInt)
		assertEquals("P900AP500AP100AJP100BP500BP900B", TEST_BUFFER)

	}

	@Test
	def void testPriorityEnvelopePrioOverrideComplex() {

		{

			val obj = new ExtendedByPrio100300500900Override2

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P90_A_AP50_B_AP30_C_AP10_D_AJEP100BP300BP500BP900B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(1807, obj.methodInt)
			assertEquals("P900AP500AP300AP100AJP100BP300BP500BP900B", TEST_BUFFER)

		}

		{

			val obj = new ExtendedByPrio100300500700900Override3

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P90_A_AP70_B_AP50_C_AP30_D_AP10_E_AQFP100BP300BP500BP700BP900B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(12507, obj.methodInt)
			assertEquals("P900AP700AP500AP300AP100AQJP100BP300BP500BP700BP900B", TEST_BUFFER)

		}

		{

			val obj = new ExtendedByPrio100300500700900Override4

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P90_A_AP70_B_AP50_C_AP30_D_AP10_E_ARFP100BP300BP500BP700BP900B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(112507, obj.methodInt)
			assertEquals("P900AP700AP500AP300AP100ARQJP100BP300BP500BP700BP900B", TEST_BUFFER)

		}

		{

			val obj = new ExtendedByPrio100300500700900Override5

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P90_A_AP70_B_AP50_C_AP30_D_AP10_E_ARFP100BP300BP500BP700BP900B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(112507, obj.methodInt)
			assertEquals("P900AP700AP500AP300AP100ARQJP100BP300BP500BP700BP900B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(35, obj.sum(10, 25))

		}

		{

			val obj = new ExtendedByPrio300900WithoutOwnOverride1

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P90_A_AP30_B_AP300BP900B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(6200, obj.methodInt)
			assertEquals("P900AP300AP300BP900B", TEST_BUFFER)

		}

		{

			val obj = new ExtendedByPrio300900WithoutOwnOverride2

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P90_A_AP30_B_AKCP300BP900B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(1201, obj.methodInt)
			assertEquals("P900AP300AKP300BP900B", TEST_BUFFER)

		}

		{

			var boolean exceptionThrown

			val obj = new ExtendedByPrio300900WithoutOwnOverride3

			TEST_BUFFER = "";
			exceptionThrown = false
			try {
				obj.methodVoid('A')
			} catch (AssertionError assertionError) {
				exceptionThrown = true
			}
			assertTrue(exceptionThrown)

			TEST_BUFFER = "";
			exceptionThrown = false
			try {
				obj.methodInt
			} catch (AssertionError assertionError) {
				exceptionThrown = true
			}
			assertTrue(exceptionThrown)

		}

	}

	@Test
	def void testPriorityEnvelopeDefaultValueProvider() {

		val obj = new ExtendedByPrio900WithoutOwn
		assertEquals(920, obj.methodInt)

	}

	@Test
	def void testPriorityEnvelopePrio100500900SuperCall() {

		{

			val obj = new ExtendedByPrio100500900OverrideWithSuper

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P90_A_AP50_B_AP10_C_AKDIEP100BP500BP900B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(1502, obj.methodInt)
			assertEquals("P900AP500AP100AKIP100BP500BP900B", TEST_BUFFER)

		}

		{
			val obj = new ExtendedByPrio100500900OverrideWithSuperFinal

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P90_A_AP50_B_AP10_C_ALDKEIFP100BP500BP900B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(101502, obj.methodInt)
			assertEquals("P900AP500AP100ALKIP100BP500BP900B", TEST_BUFFER)

		}

	}

	@Test
	def void testPriorityEnvelopeSuperCallToBase() {

		{

			val obj = new ExtendedByPrio100WithSuperToBase

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P10_A_AKBRCP100B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(901, obj.methodInt)
			assertEquals("P100AKRP100B", TEST_BUFFER)

		}

		{
			val obj = new ExtendedByPrio100WithOwnInBaseWithSuper

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P10_A_AKBRCP100B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(901, obj.methodInt)
			assertEquals("P100AKRP100B", TEST_BUFFER)

		}

		{
			val obj = new ExtendedByPrio100300WithOwnInBaseWithSuper

			TEST_BUFFER = "";
			obj.methodVoid('A')
			assertEquals("P30_A_AP10_B_AKCRDP100BP300B", TEST_BUFFER)

			TEST_BUFFER = "";
			assertEquals(1201, obj.methodInt)
			assertEquals("P300AP100AKRP100BP300B", TEST_BUFFER)

		}

	}

	@Test
	def void testPriorityEnvelopePrivateInBaseClass() {

		val obj = new ExtendedByPrio500PrivateDerived

		TEST_BUFFER = "";
		obj.methodVoid('A')
		assertEquals("P50_A_AP500B", TEST_BUFFER)

		TEST_BUFFER = "";
		assertEquals(1055, obj.methodInt)
		assertEquals("P500AP500B", TEST_BUFFER)

	}

	@Test
	def void testPriorityEnvelopeVisibility() {

		assertTrue(
			Modifier.isPublic(ExtendedByCheckVisibilityAllProtected.getDeclaredMethod("checkVisiblity1").modifiers))
		assertTrue(
			Modifier.isPublic(ExtendedByCheckVisibilityAllProtected.getDeclaredMethod("checkVisiblity2").modifiers))
		assertTrue(
			Modifier.isProtected(ExtendedByCheckVisibilityAllProtected.getDeclaredMethod("checkVisiblity3").modifiers))

		assertTrue(Modifier.isPublic(ExtendedByCheckVisibilityAllPublic.getDeclaredMethod("checkVisiblity1").modifiers))
		assertTrue(Modifier.isPublic(ExtendedByCheckVisibilityAllPublic.getDeclaredMethod("checkVisiblity2").modifiers))
		assertTrue(Modifier.isPublic(ExtendedByCheckVisibilityAllPublic.getDeclaredMethod("checkVisiblity3").modifiers))

		assertTrue(
			Modifier.isPublic(
				ExtendedByCheckVisibilityAllProtectedInBase.getDeclaredMethod("checkVisiblity1").modifiers))
		assertTrue(
			Modifier.isPublic(
				ExtendedByCheckVisibilityAllProtectedInBase.getDeclaredMethod("checkVisiblity2").modifiers))
		assertTrue(
			Modifier.isProtected(
				ExtendedByCheckVisibilityAllProtectedInBase.getDeclaredMethod("checkVisiblity3").modifiers))

		assertTrue(
			Modifier.isPublic(ExtendedByCheckVisibilityAllPublicInBase.getDeclaredMethod("checkVisiblity1").modifiers))
		assertTrue(
			Modifier.isPublic(ExtendedByCheckVisibilityAllPublicInBase.getDeclaredMethod("checkVisiblity2").modifiers))
		assertTrue(
			Modifier.isPublic(ExtendedByCheckVisibilityAllPublicInBase.getDeclaredMethod("checkVisiblity3").modifiers))

	}

	@Test
	def void testPriorityEnvelopeOverridingInTraitClass() {

		val obj = new ExtendedClassOverridePriorityEnvelopeInTraitClass
		TEST_BUFFER = "";
		assertEquals(120, obj.methodInt)
		assertEquals("P100ASTP100B", TEST_BUFFER)

	}

	@Test
	def void testPriorityEnvelopeInvalidSuperCall() {

		var boolean exceptionThrown

		val obj = new ExtendedClassPriorityEnvelopeInvalidSuperCall

		exceptionThrown = false
		try {
			obj.methodPriorityEnvelopeMethod
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

	}

	@Test
	def void testPriorityEnvelopeCovariance() {

		val obj = new ExtendedClassPriorityEnvelopeMethodInteractionWithProcessedCovariance
		TEST_BUFFER = "";
		assertSame(TypeB, obj.methodTyped.class)
		assertEquals("APB", TEST_BUFFER)

	}

	@Test
	def void testPriorityEnvelopeInteractionWithOtherTraitMethods() {

		{

			val obj = new ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed1
			TEST_BUFFER = "";
			obj.methodVoid("x")
			assertEquals("x9c1", TEST_BUFFER)

		}

		{

			val obj = new ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed2
			TEST_BUFFER = "";
			obj.methodVoid("x")
			assertEquals("x9c1", TEST_BUFFER)

		}

		{

			val obj = new ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed3
			TEST_BUFFER = "";
			obj.methodVoid("x")
			assertEquals("x9c1", TEST_BUFFER)

		}

		{

			val obj = new ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed4
			TEST_BUFFER = "";
			obj.methodVoid("x")
			assertEquals("x9c1c2", TEST_BUFFER)

		}

		{

			val obj = new ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed5
			TEST_BUFFER = "";
			obj.methodVoid("x")
			assertEquals("x9c1c2", TEST_BUFFER)

		}

		{

			val obj = new ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed6
			TEST_BUFFER = "";
			obj.methodVoid("x")
			assertEquals("x9c1", TEST_BUFFER)

		}

		{

			val obj = new ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed7
			TEST_BUFFER = "";
			obj.methodVoid("x")
			assertEquals("x9c1cP", TEST_BUFFER)

		}

		{

			val obj = new ExtendedClassPriorityEnvelopeMethodInteractionWithExclusive
			TEST_BUFFER = "";
			obj.methodVoid("x")
			assertEquals("x9c1", TEST_BUFFER)
			TEST_BUFFER = "";
			obj.methodTyped()
			assertEquals("AB", TEST_BUFFER)

		}

	}

	@Test
	def void testPriorityEnvelopeNoApplyRules() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import virtual.intf.ITraitPriorityEnvelope

@TraitClass
abstract class TraitPriorityEnvelope {

	@PriorityEnvelopeMethod(value=100, required=false)
	override void methodVoid() {
	}

}

@ExtendedByAuto
abstract class ExtendedByPriorityEnvelop implements ITraitPriorityEnvelope {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedByPriorityEnvelop")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("@ApplyRules"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testRequiredFlagMismatch() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod

@TraitClassAutoUsing
abstract class TraitClassPriorityEnvelope {

	@PriorityEnvelopeMethod(value=600, required = false)
	override int method() {
		1
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassPriorityEnvelope")

			val problemsMethod = (clazz.findDeclaredMethod("method").primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod.size)
			assertEquals(Severity.ERROR, problemsMethod.get(0).severity)
			assertTrue(problemsMethod.get(0).message.contains("either set the required flag"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testNoDefaultValueProviderForVoid() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.DefaultValueProvider
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

class SimpleValueProvider implements DefaultValueProvider<Integer>
{	
	override getDefaultValue() {}
}

@TraitClassAutoUsing
abstract class TraitClassPriorityEnvelope {

	@PriorityEnvelopeMethod(value=100, required=false, defaultValueProvider=SimpleValueProvider)
	override void method() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassPriorityEnvelope")

			val problemsMethod = (clazz.findDeclaredMethod("method").primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod.size)
			assertEquals(Severity.ERROR, problemsMethod.get(0).severity)
			assertTrue(problemsMethod.get(0).message.contains("specify a default value provider"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testDefaultValueProviderWrongInterface() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.DefaultValueProvider
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

class SimpleValueProvider implements DefaultValueProvider<Integer>
{	
	override getDefaultValue() {}	
}

@TraitClassAutoUsing
abstract class TraitClassPriorityEnvelope {

	@PriorityEnvelopeMethod(required=false, value=100, defaultValueProvider=java::lang::Integer)
	override int method() { return 1; }

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassPriorityEnvelope")

			val problemsMethod = (clazz.findDeclaredMethod("method").primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod.size)
			assertEquals(Severity.ERROR, problemsMethod.get(0).severity)
			assertTrue(problemsMethod.get(0).message.contains("DefaultValueProvider interface"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testPriorityEnvelopeMethodInvalidPriorityValues() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod

@TraitClass
abstract class TraitPriorityEnvelope {

	@PriorityEnvelopeMethod(-1)
	override void methodPriorityUnder0() {}

	@PriorityEnvelopeMethod(0)
	override void methodPriority0() {}

	@PriorityEnvelopeMethod(java.lang.Integer::MAX_VALUE)
	override void methodPriorityMax() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitPriorityEnvelope")

			val problemsMethodPriorityUnder0 = (clazz.findDeclaredMethod("methodPriorityUnder0").
				primarySourceElement as MethodDeclaration).problems
			val problemsMethodPriority0 = (clazz.findDeclaredMethod("methodPriority0").
				primarySourceElement as MethodDeclaration).problems
			val problemsMethodPriorityMax = (clazz.findDeclaredMethod("methodPriorityMax").
				primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethodPriorityUnder0.size)
			assertEquals(Severity.ERROR, problemsMethodPriorityUnder0.get(0).severity)
			assertTrue(problemsMethodPriorityUnder0.get(0).message.contains("Priority value must be"))

			assertEquals(1, problemsMethodPriority0.size)
			assertEquals(Severity.ERROR, problemsMethodPriority0.get(0).severity)
			assertTrue(problemsMethodPriority0.get(0).message.contains("Priority value must be"))

			assertEquals(1, problemsMethodPriorityMax.size)
			assertEquals(Severity.ERROR, problemsMethodPriorityMax.get(0).severity)
			assertTrue(problemsMethodPriorityMax.get(0).message.contains("Priority value must be"))

			assertEquals(3, allProblems.size)

		]

	}

	@Test
	def void testPriorityEnvelopeMethodPriorityDuplicateError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitPrio100_1
import virtual.intf.ITraitPrio100_2
import virtual.intf.ITraitPrio100_3

@TraitClass
@ApplyRules
abstract class TraitPrio100_1 {

	@PriorityEnvelopeMethod(value=100, required=false)
	override void test() {}

}

@TraitClass
@ApplyRules
abstract class TraitPrio100_2 {

	@PriorityEnvelopeMethod(value=100, required=false)
	override void test() {}

}

@TraitClassAutoUsing
@ApplyRules
abstract class TraitPrio100_3 implements ITraitPrio100_2 {
}

@ExtendedByAuto
@ApplyRules
class Extended1 implements ITraitPrio100_1, ITraitPrio100_2 {
	override void test() {}
}

@ExtendedByAuto
@ApplyRules
class Extended2 implements ITraitPrio100_1, ITraitPrio100_2 {
}

@ExtendedByAuto
@ApplyRules
class Extended3 implements ITraitPrio100_1, ITraitPrio100_3 {
	override void test() {}
}

@ExtendedByAuto
@ApplyRules
class Extended_Base1 implements ITraitPrio100_1 {
	override void test() {}
}

@ExtendedByAuto
@ApplyRules
class Extended_Base2 implements ITraitPrio100_1 {
}

@ExtendedByAuto
@ApplyRules
class Extended_Derived11 extends Extended_Base1 implements ITraitPrio100_2 {
	override void test() {}
}

@ExtendedByAuto
@ApplyRules
class Extended_Derived12 extends Extended_Base1 implements ITraitPrio100_2 {
}

@ExtendedByAuto
@ApplyRules
class Extended_Derived21 extends Extended_Base2 implements ITraitPrio100_2 {
	override void test() {}
}

@ExtendedByAuto
@ApplyRules
class Extended_Derived22 extends Extended_Base2 implements ITraitPrio100_2 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.Extended1")
			val clazz2 = findClass("virtual.Extended2")
			val clazz3 = findClass("virtual.Extended3")
			val clazz11 = findClass("virtual.Extended_Derived11")
			val clazz12 = findClass("virtual.Extended_Derived12")
			val clazz21 = findClass("virtual.Extended_Derived21")
			val clazz22 = findClass("virtual.Extended_Derived22")

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val problemsClass2 = (clazz2.primarySourceElement as ClassDeclaration).problems
			val problemsClass3 = (clazz3.primarySourceElement as ClassDeclaration).problems
			val problemsClass11 = (clazz11.primarySourceElement as ClassDeclaration).problems
			val problemsClass12 = (clazz12.primarySourceElement as ClassDeclaration).problems
			val problemsClass21 = (clazz21.primarySourceElement as ClassDeclaration).problems
			val problemsClass22 = (clazz22.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("already contained"))

			assertEquals(1, problemsClass2.size)
			assertEquals(Severity.ERROR, problemsClass2.get(0).severity)
			assertTrue(problemsClass2.get(0).message.contains("already contained"))

			assertEquals(1, problemsClass3.size)
			assertEquals(Severity.ERROR, problemsClass3.get(0).severity)
			assertTrue(problemsClass3.get(0).message.contains("already contained"))

			assertEquals(1, problemsClass11.size)
			assertEquals(Severity.ERROR, problemsClass11.get(0).severity)
			assertTrue(problemsClass11.get(0).message.contains("already contained"))

			assertEquals(1, problemsClass12.size)
			assertEquals(Severity.ERROR, problemsClass12.get(0).severity)
			assertTrue(problemsClass12.get(0).message.contains("already contained"))

			assertEquals(1, problemsClass21.size)
			assertEquals(Severity.ERROR, problemsClass21.get(0).severity)
			assertTrue(problemsClass21.get(0).message.contains("already contained"))

			assertEquals(1, problemsClass22.size)
			assertEquals(Severity.ERROR, problemsClass22.get(0).severity)
			assertTrue(problemsClass22.get(0).message.contains("already contained"))

			assertEquals(7, allProblems.size)

		]

	}

	@Test
	def void testPriorityEnvelopeMethodCannotBeChangedToAnotherType() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

@TraitClassAutoUsing
abstract class TraitClassPriorityEnvelope {

	@PriorityEnvelopeMethod(value=400)
	override void method() {}

}

@TraitClassAutoUsing
abstract class TraitClassPriorityEnvelopeDerived extends TraitClassPriorityEnvelope {

	@ExclusiveMethod
	override void method() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassPriorityEnvelopeDerived")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("must also be used here"))

			assertEquals(1, allProblems.size)

		]

	}@Test
	def void testPriorityEnvelopeMethodNoRedirection() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection

import virtual.intf.ITraitMethodPriorityEnvelopeRedirection

@TraitClassAutoUsing
abstract class TraitMethodPriorityEnvelopeRedirection {

	@PriorityEnvelopeMethod(40)
	override void method1() {
	}

	@PriorityEnvelopeMethod(40)
	override void method2() {
	}

}

abstract class ExtendedPriorityEnvelopeRedirectionBase {

	@TraitMethodRedirection("method1Redirected")
	abstract def void method1()
	
	@TraitMethodRedirection("method2Redirected")
	def	void method2() {
	}

}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedPriorityEnvelopeRedirection extends ExtendedPriorityEnvelopeRedirectionBase implements ITraitMethodPriorityEnvelopeRedirection {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedPriorityEnvelopeRedirection")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("not allow trait method redirection"))
			assertEquals(Severity.ERROR, problemsClass.get(1).severity)
			assertTrue(problemsClass.get(1).message.contains("not allow trait method redirection"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testPriorityEnvelopeMethodDoesNotPreventExclusiveErrorDetection() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.DefaultValueProviderNull

import virtual.intf.ITraitPriorityEnvelopeMethod
import virtual.intf.ITraitExclusiveMethod

class TypeA {}
class TypeB extends TypeA {}

@TraitClassAutoUsing
abstract class TraitPriorityEnvelopeMethod {

	@PriorityEnvelopeMethod(value=99, required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeA methodTyped() {}

}

@TraitClassAutoUsing
abstract class TraitExclusiveMethod {

	@ExclusiveMethod
	override TypeB methodTyped() {}

}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedClassBaseWithImpl implements ITraitPriorityEnvelopeMethod {
	
	override TypeA methodTyped() {}
	
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithExclusive extends ExtendedClassBaseWithImpl implements ITraitExclusiveMethod {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassPriorityEnvelopeMethodInteractionWithExclusive")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("must not exist in the extended"))

			assertEquals(1, allProblems.size)

		]

	}

}
