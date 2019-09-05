/**
 * Test passes if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredFlag
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredFlagPriorityHigh
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredFlagPriorityLow
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredFlagPriorityVeryHigh
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.DefaultValueProviderNull

@TraitClassAutoUsing
abstract class TraitClassRequiredFlag {

	@ProcessedMethod(processor=EPVoidPre)
	override void methodProcessedVoidNotRequired() {
		TraitTestsBase::TEST_BUFFER += "X"
	}

	@ProcessedMethod(processor=EPVoidPre, required=true)
	override void methodProcessedVoidRequired() {
		TraitTestsBase::TEST_BUFFER += "L"
	}

	@ProcessedMethod(processor=StringCombinatorPre, required=true)
	override String methodProcessedStringRequired() { "a" }

	@EnvelopeMethod(required=false)
	override void methodEnvelopeVoidNotRequired() {
		TraitTestsBase::TEST_BUFFER += "Y"
		methodEnvelopeVoidNotRequired$extended
	}

	@EnvelopeMethod(required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeA methodEnvelopeReturnTypeNotRequired() {
		return methodEnvelopeReturnTypeNotRequired$extended
	}

	@EnvelopeMethod
	override void methodEnvelopeVoidRequired() {
		TraitTestsBase::TEST_BUFFER += "M"
		methodEnvelopeVoidRequired$extended
	}

	@EnvelopeMethod
	override String methodEnvelopeStringRequired() { "b" + methodEnvelopeStringRequired$extended }

	@PriorityEnvelopeMethod(value=1, required=false)
	override void methodPriorityEnvelopeVoidNotRequired() {
		TraitTestsBase::TEST_BUFFER += "Z"
		methodPriorityEnvelopeVoidNotRequired$extended
	}

	@PriorityEnvelopeMethod(value=1, required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeA methodPriorityEnvelopeReturnTypeNotRequired() {
		return methodPriorityEnvelopeReturnTypeNotRequired$extended
	}

	@PriorityEnvelopeMethod(value=1)
	override void methodPriorityEnvelopeVoidRequired() {
		TraitTestsBase::TEST_BUFFER += "N"
		methodPriorityEnvelopeVoidRequired$extended
	}

	@PriorityEnvelopeMethod(value=1)
	override String methodPriorityEnvelopeStringRequired() { "c" + methodPriorityEnvelopeStringRequired$extended }

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassRequiredFlag implements ITraitClassRequiredFlag {

	override void methodProcessedVoidRequired() {}

	override String methodProcessedStringRequired() { "1" }

	override void methodEnvelopeVoidRequired() {}

	override String methodEnvelopeStringRequired() { "2" }

	override void methodPriorityEnvelopeVoidRequired() {}

	override String methodPriorityEnvelopeStringRequired() { "3" }

}

class ExtendedClassRequiredFlagBaseWithoutPriorityEnvelope {

	def void methodProcessedVoidRequired() {}

	def String methodProcessedStringRequired() { "1" }

	def void methodEnvelopeVoidRequired() {}

	def String methodEnvelopeStringRequired() { "2" }

}

class ExtendedClassRequiredFlagBase extends ExtendedClassRequiredFlagBaseWithoutPriorityEnvelope {

	def void methodPriorityEnvelopeVoidRequired() {}

	def String methodPriorityEnvelopeStringRequired() { "3" }

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassRequiredFlagFromBase extends ExtendedClassRequiredFlagBase implements ITraitClassRequiredFlag {
}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedClassRequiredFlagAbstractForPriorityEnvelopeMethod extends ExtendedClassRequiredFlagBaseWithoutPriorityEnvelope implements ITraitClassRequiredFlag {
}

@ApplyRules
class ExtendedClassRequiredFlagForPriorityEnvelopeMethod extends ExtendedClassRequiredFlagAbstractForPriorityEnvelopeMethod {

	override void methodPriorityEnvelopeVoidRequired() {
		TraitTestsBase::TEST_BUFFER += "H"
	}

	override String methodPriorityEnvelopeStringRequired() {
		"I"
	}

}

@ApplyRules
abstract class ExtendedClassRequiredFlagAbstractForPriorityEnvelopeMethodBase extends ExtendedClassRequiredFlagBaseWithoutPriorityEnvelope {

	abstract def void methodPriorityEnvelopeVoidRequired()

	abstract def String methodPriorityEnvelopeStringRequired()

}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedClassRequiredFlagAbstractForPriorityEnvelopeMethodDerived extends ExtendedClassRequiredFlagAbstractForPriorityEnvelopeMethodBase implements ITraitClassRequiredFlag {
}

@ApplyRules
class ExtendedClassRequiredFlagForPriorityEnvelopeMethodDerived extends ExtendedClassRequiredFlagAbstractForPriorityEnvelopeMethodDerived {

	override void methodPriorityEnvelopeVoidRequired() {
		TraitTestsBase::TEST_BUFFER += "H"
	}

	override String methodPriorityEnvelopeStringRequired() {
		"I"
	}

}

@TraitClassAutoUsing
abstract class TraitClassRequiredFlagPriorityLow {

	@PriorityEnvelopeMethod(value=10, required=false)
	override void methodPriorityEnvelope() {
		TraitTestsBase::TEST_BUFFER += "L"
		methodPriorityEnvelope$extended
	}

}

@TraitClassAutoUsing
abstract class TraitClassRequiredFlagPriorityHigh {

	@PriorityEnvelopeMethod(value=50, required=true)
	override void methodPriorityEnvelope() {
		TraitTestsBase::TEST_BUFFER += "H"
		methodPriorityEnvelope$extended
	}

}

@TraitClassAutoUsing
abstract class TraitClassRequiredFlagPriorityVeryHigh {

	@PriorityEnvelopeMethod(value=900, required=true)
	override void methodPriorityEnvelope() {
		TraitTestsBase::TEST_BUFFER += "V"
		methodPriorityEnvelope$extended
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassRequiredPriorityEnvelopeNotImplemented implements ITraitClassRequiredFlagPriorityVeryHigh, ITraitClassRequiredFlagPriorityLow, ITraitClassRequiredFlagPriorityHigh {
}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedClassRequiredPriorityEnvelopeNotImplementedAbstract implements ITraitClassRequiredFlagPriorityVeryHigh, ITraitClassRequiredFlagPriorityHigh {
}

@ApplyRules
@ExtendedByAuto
class ExtendedClassRequiredPriorityEnvelopeNotImplementedDerived extends ExtendedClassRequiredPriorityEnvelopeNotImplementedAbstract implements ITraitClassRequiredFlagPriorityLow {
}

class RequiredFlagTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testVoidNotRequired() {

		{
			val obj = new ExtendedClassRequiredFlag

			TEST_BUFFER = ""
			obj.methodProcessedVoidNotRequired
			assertEquals("X", TEST_BUFFER)

			TEST_BUFFER = ""
			obj.methodEnvelopeVoidNotRequired
			assertEquals("Y", TEST_BUFFER)

			TEST_BUFFER = ""
			obj.methodPriorityEnvelopeVoidNotRequired
			assertEquals("Z", TEST_BUFFER)

		}

		{
			val obj = new ExtendedClassRequiredFlagFromBase

			TEST_BUFFER = ""
			obj.methodProcessedVoidNotRequired
			assertEquals("X", TEST_BUFFER)

			TEST_BUFFER = ""
			obj.methodEnvelopeVoidNotRequired
			assertEquals("Y", TEST_BUFFER)

			TEST_BUFFER = ""
			obj.methodPriorityEnvelopeVoidNotRequired
			assertEquals("Z", TEST_BUFFER)

		}

	}

	@Test
	def void testReturnTypeNotRequired() {

		val obj = new ExtendedClassRequiredFlag
		obj.methodEnvelopeReturnTypeNotRequired
		obj.methodPriorityEnvelopeReturnTypeNotRequired

	}

	@Test
	def void testRequiredStringReturn() {

		{

			val obj = new ExtendedClassRequiredFlag

			assertEquals("a1", obj.methodProcessedStringRequired)
			assertEquals("b2", obj.methodEnvelopeStringRequired)
			assertEquals("c3", obj.methodPriorityEnvelopeStringRequired)

		}

		{

			val obj = new ExtendedClassRequiredFlagFromBase

			assertEquals("a1", obj.methodProcessedStringRequired)
			assertEquals("b2", obj.methodEnvelopeStringRequired)
			assertEquals("c3", obj.methodPriorityEnvelopeStringRequired)

		}

	}

	@Test
	def void testRequiredFlagForPriorityEnvelopeMethodsCreateAbstract() {

		{
			val obj = new ExtendedClassRequiredFlagForPriorityEnvelopeMethod

			TEST_BUFFER = ""
			obj.methodPriorityEnvelopeVoidRequired
			assertEquals("NH", TEST_BUFFER)

			assertEquals("cI", obj.methodPriorityEnvelopeStringRequired)

		}

		{
			val obj = new ExtendedClassRequiredFlagForPriorityEnvelopeMethodDerived

			TEST_BUFFER = ""
			obj.methodPriorityEnvelopeVoidRequired
			assertEquals("NH", TEST_BUFFER)

			assertEquals("cI", obj.methodPriorityEnvelopeStringRequired)

		}

	}

	@Test
	def void testNotRequiredInLowPriorityEnvelopeMethod() {

		{

			val obj = new ExtendedClassRequiredPriorityEnvelopeNotImplemented

			TEST_BUFFER = ""
			obj.methodPriorityEnvelope
			assertEquals("VHL", TEST_BUFFER)

		}

		{

			val obj = new ExtendedClassRequiredPriorityEnvelopeNotImplementedDerived

			TEST_BUFFER = ""
			obj.methodPriorityEnvelope
			assertEquals("VHL", TEST_BUFFER)

		}

	}

	@Test
	def void testNotRequiredInHighPriorityEnvelopeMethod() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

import virtual.intf.ITraitClassRequiredFlagPriorityLow
import virtual.intf.ITraitClassRequiredFlagPriorityMedium
import virtual.intf.ITraitClassRequiredFlagPriorityHigh
import virtual.intf.ITraitClassRequiredFlagPriorityVeryHigh

@TraitClassAutoUsing
abstract class TraitClassRequiredFlagPriorityVeryHigh {

	@PriorityEnvelopeMethod(value=900, required=false)
	override void methodPriorityEnvelope() {}

}

@TraitClassAutoUsing
abstract class TraitClassRequiredFlagPriorityLow {

	@PriorityEnvelopeMethod(value=10, required=true)
	override void methodPriorityEnvelope() {}

}

@TraitClassAutoUsing
abstract class TraitClassRequiredFlagPriorityMedium {

	@PriorityEnvelopeMethod(value=30, required=true)
	override void methodPriorityEnvelope() {}

}

@TraitClassAutoUsing
abstract class TraitClassRequiredFlagPriorityHigh {

	@PriorityEnvelopeMethod(value=50, required=false)
	override void methodPriorityEnvelope() {}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassRequiredPriorityEnvelopeNotImplemented implements ITraitClassRequiredFlagPriorityVeryHigh, ITraitClassRequiredFlagPriorityLow, ITraitClassRequiredFlagPriorityHigh {
}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedClassRequiredPriorityEnvelopeNotImplementedAbstract implements ITraitClassRequiredFlagPriorityMedium {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassRequiredPriorityEnvelopeNotImplementedDerived extends ExtendedClassRequiredPriorityEnvelopeNotImplementedAbstract implements ITraitClassRequiredFlagPriorityVeryHigh {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtendedClassRequiredPriorityEnvelopeNotImplemented")
			val clazz2 = findClass("virtual.ExtendedClassRequiredPriorityEnvelopeNotImplementedDerived")

			val clazzProblems1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val clazzProblems2 = (clazz2.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, clazzProblems1.size)
			assertEquals(Severity.ERROR, clazzProblems1.get(0).severity)
			assertTrue(clazzProblems1.get(0).message.contains("requires"))

			assertEquals(1, clazzProblems2.size)
			assertEquals(Severity.ERROR, clazzProblems2.get(0).severity)
			assertTrue(clazzProblems2.get(0).message.contains("requires"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testMissingRequired() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

import virtual.intf.ITraitClassRequiredFlag
import virtual.intf.ITraitClassRequiringPriorityEnvelope
import virtual.intf.ITraitClassNotRequiringPriorityEnvelope

@TraitClassAutoUsing
abstract class TraitClassRequiredFlag {

	@ProcessedMethod(processor=EPVoidPre)
	override void methodProcessedVoidNotRequired() {}

	@ProcessedMethod(processor=EPVoidPre, required=true)
	override void methodProcessedVoidRequired() {}

	@EnvelopeMethod(required=false)
	override void methodEnvelopeVoidNotRequired() {}

	@EnvelopeMethod
	override void methodEnvelopeVoidRequired() {}

	@PriorityEnvelopeMethod(value=600, required=false)
	override void methodPriorityEnvelopeVoidNotRequired() {}

	@PriorityEnvelopeMethod(600)
	override void methodPriorityEnvelopeVoidRequired() {}

}

@TraitClassAutoUsing
abstract class TraitClassRequiringPriorityEnvelope {

	@PriorityEnvelopeMethod(value=200, required=true)
	override void methodPriorityEnvelopeVoidRequired1() {}

	@PriorityEnvelopeMethod(value=100, required=true)
	override void methodPriorityEnvelopeVoidRequired2() {}

}

@TraitClassAutoUsing
abstract class TraitClassNotRequiringPriorityEnvelope {

	@PriorityEnvelopeMethod(value=100, required=false)
	override void methodPriorityEnvelopeVoidRequired1() {}

	@PriorityEnvelopeMethod(value=200, required=false)
	override void methodPriorityEnvelopeVoidRequired2() {}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassRequiredFlagMissing implements ITraitClassRequiredFlag, ITraitClassRequiringPriorityEnvelope, ITraitClassNotRequiringPriorityEnvelope {
}

@ExtendedByAuto
@ApplyRules
abstract class AbstractExtendedClassRequiredFlagMissing implements ITraitClassRequiredFlag {
}

@ExtendedByAuto
@ApplyRules
abstract class AbstractExtendedClassRequiredFlagMissingExplicit implements ITraitClassRequiredFlag {

	override abstract void methodProcessedVoidRequired()
	override abstract void methodEnvelopeVoidRequired()
	override abstract void methodPriorityEnvelopeVoidRequired()

}

abstract class AbstractExtendedClassRequiredFlagMissingExplicitBase {

	def abstract void methodProcessedVoidRequired()
	def abstract void methodEnvelopeVoidRequired()
	def abstract void methodPriorityEnvelopeVoidRequired()

}

@ExtendedByAuto
@ApplyRules
abstract class AbstractExtendedClassRequiredFlagMissingExplicitDerived extends AbstractExtendedClassRequiredFlagMissingExplicitBase implements ITraitClassRequiredFlag {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtendedClassRequiredFlagMissing")
			val clazz2 = findClass("virtual.AbstractExtendedClassRequiredFlagMissing")
			val clazz3 = findClass("virtual.AbstractExtendedClassRequiredFlagMissing")
			val clazz4 = findClass("virtual.AbstractExtendedClassRequiredFlagMissing")

			val clazzProblems1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val clazzProblems2 = (clazz2.primarySourceElement as ClassDeclaration).problems
			val clazzProblems3 = (clazz3.primarySourceElement as ClassDeclaration).problems
			val clazzProblems4 = (clazz4.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(4, clazzProblems1.size)
			assertEquals(4, clazzProblems1.map[severity].filter[it == Severity.ERROR].size)
			assertTrue(clazzProblems1.map[message].exists[it.contains("methodProcessedVoidRequired")])
			assertTrue(clazzProblems1.map[message].exists[it.contains("methodEnvelopeVoidRequired")])
			assertTrue(clazzProblems1.map[message].exists[it.contains("methodPriorityEnvelopeVoidRequired")])
			assertTrue(clazzProblems1.map[message].exists[it.contains("methodPriorityEnvelopeVoidRequired2")])

			assertEquals(2, clazzProblems2.size)
			assertEquals(2, clazzProblems2.map[severity].filter[it == Severity.ERROR].size)
			assertTrue(clazzProblems2.map[message].exists[it.contains("methodProcessedVoidRequired")])
			assertTrue(clazzProblems2.map[message].exists[it.contains("methodEnvelopeVoidRequired")])

			assertEquals(2, clazzProblems3.size)
			assertEquals(2, clazzProblems3.map[severity].filter[it == Severity.ERROR].size)
			assertTrue(clazzProblems3.map[message].exists[it.contains("methodProcessedVoidRequired")])
			assertTrue(clazzProblems3.map[message].exists[it.contains("methodEnvelopeVoidRequired")])

			assertEquals(2, clazzProblems4.size)
			assertEquals(2, clazzProblems4.map[severity].filter[it == Severity.ERROR].size)
			assertTrue(clazzProblems4.map[message].exists[it.contains("methodProcessedVoidRequired")])
			assertTrue(clazzProblems4.map[message].exists[it.contains("methodEnvelopeVoidRequired")])

			assertEquals(10, allProblems.size)

		]

	}

	@Test
	def void testMissingRequiredBecauseOfPrivateInBase() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

import virtual.intf.ITraitClassRequiring

@TraitClassAutoUsing
abstract class TraitClassRequiring {

	@ProcessedMethod(processor=EPVoidPre, required=true)
	override void methodProcessedVoidRequired() {}

	@EnvelopeMethod(required=true)
	override void methodEnvelopeVoidRequired() {}

	@PriorityEnvelopeMethod(value=100, required=true)
	override void methodPriorityEnvelopeVoidRequired() {}

}

class ExtendedClassPrivateShallNotBeExtended {

	private def void methodProcessedVoidRequired() {}

	private def void methodEnvelopeVoidRequired() {}

	private def void methodPriorityEnvelopeVoidRequired() {}

	def void useMethods() {
		methodProcessedVoidRequired
		methodEnvelopeVoidRequired
		methodPriorityEnvelopeVoidRequired
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassHavingPrivateNotExtended extends ExtendedClassPrivateShallNotBeExtended implements ITraitClassRequiring {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassHavingPrivateNotExtended")

			val clazzProblems = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(3, clazzProblems.size)
			assertEquals(3, clazzProblems.map[severity].filter[it == Severity.ERROR].size)
			assertTrue(clazzProblems.map[message].exists[it.contains("methodProcessedVoidRequired")])
			assertTrue(clazzProblems.map[message].exists[it.contains("methodEnvelopeVoidRequired")])
			assertTrue(clazzProblems.map[message].exists[it.contains("methodPriorityEnvelopeVoidRequired")])

			assertEquals(3, allProblems.size)

		]

	}

	@Test
	def void testDefaultValueProviderNecessary() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

@TraitClassAutoUsing
abstract class TraitClassRequiredFlag {

	@EnvelopeMethod(required=false)
	override void methodEnvelopeVoidNotRequired() {}

	@EnvelopeMethod(required=false)
	override String methodEnvelopeStringNotRequired() { "" }

	@PriorityEnvelopeMethod(value=600, required=false)
	override void methodPriorityEnvelopeVoidNotRequired() {}

	@PriorityEnvelopeMethod(value=600, required=false)
	override String methodPriorityEnvelopeStringNotRequired() { "" }

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassRequiredFlag")

			val problemsMethod1 = (clazz.findDeclaredMethod("methodEnvelopeStringNotRequired").
				primarySourceElement as MethodDeclaration).problems
			val problemsMethod2 = (clazz.findDeclaredMethod("methodPriorityEnvelopeStringNotRequired").
				primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod1.size)
			assertEquals(Severity.ERROR, problemsMethod1.get(0).severity)
			assertTrue(problemsMethod1.get(0).message.contains("default value provider"))

			assertEquals(1, problemsMethod2.size)
			assertEquals(Severity.ERROR, problemsMethod2.get(0).severity)
			assertTrue(problemsMethod2.get(0).message.contains("default value provider"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testNoDefaultValueProviderIfRequired() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.DefaultValueProvider

class SimpleDefaultValueProvider20 implements DefaultValueProvider<Integer> {

	override Integer getDefaultValue() {
		return 20
	}

}

@TraitClassAutoUsing
abstract class TraitClassRequiredFlag {

	@EnvelopeMethod(required=true, defaultValueProvider=SimpleDefaultValueProvider20)
	override Integer methodEnvelopeStringRequired() { 0 }

	@PriorityEnvelopeMethod(value=600, required=true, defaultValueProvider=SimpleDefaultValueProvider20)
	override Integer methodPriorityEnvelopeStringRequired() { 0 }

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassRequiredFlag")

			val problemsMethod1 = (clazz.findDeclaredMethod("methodEnvelopeStringRequired").
				primarySourceElement as MethodDeclaration).problems
			val problemsMethod2 = (clazz.findDeclaredMethod("methodPriorityEnvelopeStringRequired").
				primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod1.size)
			assertEquals(Severity.ERROR, problemsMethod1.get(0).severity)
			assertTrue(problemsMethod1.get(0).message.contains("default value provider must not be provided"))

			assertEquals(1, problemsMethod2.size)
			assertEquals(Severity.ERROR, problemsMethod2.get(0).severity)
			assertTrue(problemsMethod2.get(0).message.contains("default value provider must not be provided"))

			assertEquals(2, allProblems.size)

		]

	}

}
