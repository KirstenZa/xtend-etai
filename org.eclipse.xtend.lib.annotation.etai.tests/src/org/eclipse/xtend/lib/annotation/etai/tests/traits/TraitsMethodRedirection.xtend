package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedRedirectionNewWithExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionDisposeSimple
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionEnvelope
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionNew
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionPre1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionPre2
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionPre3
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionPre4
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionPre5
import java.lang.reflect.Modifier
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

import static extension org.eclipse.xtend.lib.macro.declaration.Visibility.*
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionPre6

@TraitClassAutoUsing
abstract class TraitMethodRedirectionEnvelope {

	@EnvelopeMethod(setFinal=false, disableRedirection=false)
	override int dispose() {
		TraitTestsBase.TEST_BUFFER += "E1"
		val result = 1 + this.dispose$extended
		TraitTestsBase.TEST_BUFFER += "E2"
		return result
	}

}

@TraitClassAutoUsing
abstract class TraitMethodRedirectionPre1 {

	@ProcessedMethod(processor=IntegerCombinatorAddPre)
	protected def int dispose() {
		TraitTestsBase.TEST_BUFFER += "P1"
		return 2
	}

}

@TraitClassAutoUsing
abstract class TraitMethodRedirectionPre2 {

	@ProcessedMethod(processor=IntegerCombinatorAddPre)
	protected def int dispose() {
		TraitTestsBase.TEST_BUFFER += "P2"
		return 4
	}

}

@TraitClassAutoUsing
abstract class TraitMethodRedirectionPre3 {

	@ProcessedMethod(processor=IntegerCombinatorAddPre)
	override int dispose() {
		TraitTestsBase.TEST_BUFFER += "P3"
		return 8
	}

}

@TraitClassAutoUsing
abstract class TraitMethodRedirectionPre4 {

	@ProcessedMethod(processor=IntegerCombinatorAddPre)
	def package int dispose() {
		TraitTestsBase.TEST_BUFFER += "P4"
		return 16
	}

}

@TraitClassAutoUsing
abstract class TraitMethodRedirectionPre5 {

	@EnvelopeMethod(setFinal=false, required=true, disableRedirection=false)
	protected def int dispose() {

		TraitTestsBase.TEST_BUFFER += "I1"
		val result = 32 + this.dispose$extended
		TraitTestsBase.TEST_BUFFER += "I2"
		return result

	}

}

@TraitClassAutoUsing
abstract class TraitMethodRedirectionPre6 {

	@ExclusiveMethod
	protected def int dispose() {

		TraitTestsBase.TEST_BUFFER += "UX"
		return 1

	}

}

abstract class ExtendedRedirectionPreBase {

	def int dispose() {
		TraitTestsBase.TEST_BUFFER += "A"
		return 1000
	}

}

@ExtendedByAuto
abstract class ExtendedRedirectionBase extends ExtendedRedirectionPreBase implements ITraitMethodRedirectionEnvelope {

	@TraitMethodRedirection(value="disposeInternal", visibility=Visibility.PROTECTED)
	override int dispose() {
		return super.dispose() + disposeInternal()
	}

	package def int disposeInternal() {
		TraitTestsBase.TEST_BUFFER += "B"
		return 2000
	}

}

@ExtendedByAuto
class ExtendedRedirectionDerived1 extends ExtendedRedirectionBase implements ITraitMethodRedirectionPre1 {

	protected override int disposeInternal() {
		val result = super.disposeInternal
		TraitTestsBase.TEST_BUFFER += "C"
		return result + 4000
	}

}

class ExtendedRedirectionDerived2 extends ExtendedRedirectionDerived1 {

	protected override int disposeInternal() {
		val result = super.disposeInternal()
		TraitTestsBase.TEST_BUFFER += "D"
		return result + 8000
	}

}

@ExtendedByAuto
class ExtendedRedirectionDerived3 extends ExtendedRedirectionDerived2 implements ITraitMethodRedirectionPre2, ITraitMethodRedirectionPre3 {

	@TraitMethodRedirection(value="disposeInternal2", visibility=Visibility.PUBLIC)
	protected override int disposeInternal() {
		return super.disposeInternal + disposeInternal2
	}

	protected def int disposeInternal2() {
		TraitTestsBase.TEST_BUFFER += "E"
		return 16000
	}

}

@ExtendedByAuto
abstract class ExtendedRedirectionDerived4 extends ExtendedRedirectionDerived3 implements ITraitMethodRedirectionPre4 {

	@TraitMethodRedirection(value="disposeInternal3", visibility=Visibility.DEFAULT)
	override int disposeInternal2() {
		return super.disposeInternal2 + disposeInternal3
	}

	abstract package def int disposeInternal3()

}

class ExtendedRedirectionDerived5 extends ExtendedRedirectionDerived4 {

	package override int disposeInternal3() {
		val result = super.disposeInternal3
		TraitTestsBase.TEST_BUFFER += "F"
		return result + 32000
	}

}

@ExtendedByAuto
class ExtendedRedirectionDerived6 extends ExtendedRedirectionDerived5 implements ITraitMethodRedirectionPre5 {

	final package override int disposeInternal3() {
		val result = super.disposeInternal3()
		TraitTestsBase.TEST_BUFFER += "G"
		return result + 64000
	}

}

@TraitClassAutoUsing
abstract class TraitMethodRedirectionDisposeSimple {

	@ProcessedMethod(processor=EPVoidPre)
	override void dispose() {
		TraitTestsBase.TEST_BUFFER += "E1"
	}

}

abstract class NonExtendedBaseWithRedirection {

	@TraitMethodRedirection("disposeInternal")
	def void dispose() {
		TraitTestsBase.TEST_BUFFER += "A"
		disposeInternal
	}

	abstract protected def void disposeInternal()

}

@ExtendedByAuto
class NonExtendedBaseWithRedirectionDerived extends NonExtendedBaseWithRedirection implements ITraitMethodRedirectionDisposeSimple {

	protected override void disposeInternal() {
		TraitTestsBase.TEST_BUFFER += "B"
	}

}

@TraitClassAutoUsing
abstract class TraitMethodRedirectionNew {

	@ProcessedMethod(processor=EPVoidPre)
	override void dispose() {
		TraitTestsBase.TEST_BUFFER += "A"
	}

	@ProcessedMethod(processor=EPVoidPre)
	protected def void anotherMethod() {
		TraitTestsBase.TEST_BUFFER += "B"
	}

	@ProcessedMethod(processor=EPVoidPre)
	protected def void anotherMethod2() {
	}

}

abstract class ExtendedRedirectionNewBase {

	@TraitMethodRedirection(value="disposeInternal", visibility=Visibility.PUBLIC)
	def void dispose() {
		TraitTestsBase.TEST_BUFFER += "C"
	}

	@TraitMethodRedirection(value="anotherMethod2Internal", visibility=Visibility.PROTECTED)
	def void anotherMethod2() {
	}

}

@ExtendedByAuto
class ExtendedRedirectionNew extends ExtendedRedirectionNewBase implements ITraitMethodRedirectionNew {
}

@ExtendedByAuto
@ExtractInterface
class ExtendedRedirectionNewWithExtractInterface extends ExtendedRedirectionNewBase implements ITraitMethodRedirectionNew {
}

@ExtendedByAuto
class ExtendedMultipleRedirection implements ITraitMethodRedirectionNew {

	@TraitMethodRedirection(value="disposeInternal")
	override void dispose() {
		TraitTestsBase.TEST_BUFFER += "X"
		disposeInternal()
	}

	@TraitMethodRedirection(value="disposeInternal2")
	def void disposeInternal() {
		TraitTestsBase.TEST_BUFFER += "Y"
		disposeInternal2()
	}

	def void disposeInternal2() {
		TraitTestsBase.TEST_BUFFER += "Z"
	}

}

@ExtendedByAuto
abstract class ExtendedAbstractRedirectionBase implements ITraitMethodRedirectionNew {

	@TraitMethodRedirection(value="disposeInternal")
	abstract override void dispose()

	def void disposeInternal() {
		TraitTestsBase.TEST_BUFFER += "X"
	}

}

class ExtendedAbstractRedirectionDerived extends ExtendedAbstractRedirectionBase {

	override void dispose() {
		TraitTestsBase.TEST_BUFFER += "Y"
		super.disposeInternal
	}

}

@ExtendedByAuto
class ExtendedWithRedirectionOfExclusive implements ITraitMethodRedirectionPre6 {

	@TraitMethodRedirection(value="dispose2", visibility=PUBLIC)
	def int dispose() {

		TraitTestsBase.TEST_BUFFER += "AB"
		return 2

	}

}

@ExtendedByAuto
class ExtendedWithRedirectionProtected implements ITraitMethodRedirectionPre1 {

	@TraitMethodRedirection(value="disposeInternal", visibility=PROTECTED)
	protected def int dispose() {
		TraitTestsBase.TEST_BUFFER += "X"
		disposeInternal
		return 2
	}

}

@ExtendedByAuto
class ExtendedWithRedirectionPublic extends ExtendedWithRedirectionProtected implements ITraitMethodRedirectionPre3 {
}

class TraitsMethodRedirectionTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testBasicRedirection() {

		val obj = new ExtendedRedirectionDerived2
		assertEquals(15003, obj.dispose)
		assertEquals("AP1E1BE2CD", TEST_BUFFER)

	}

	@Test
	def void testBasicRedirectionMultiple() {

		val obj = new ExtendedRedirectionDerived6
		assertEquals(127063, obj.dispose)
		assertEquals("AP1E1BE2CDP3P2EI1P4FGI2", TEST_BUFFER)

	}

	@Test
	def void testNonExtendedBaseWithRedirection() {

		val obj = new NonExtendedBaseWithRedirectionDerived
		obj.dispose
		assertEquals("AE1B", TEST_BUFFER)

	}

	@Test
	def void testRedirectionNew() {

		val ExtendedRedirectionNewBase obj = new ExtendedRedirectionNew
		obj.dispose
		obj.disposeInternal;
		(obj as ExtendedRedirectionNew).anotherMethod
		assertEquals("CAB", TEST_BUFFER)

	}

	@Test
	def void testRedirectionNewViaInterface() {

		val IExtendedRedirectionNewWithExtractInterface intf = new ExtendedRedirectionNewWithExtractInterface
		intf.dispose
		intf.disposeInternal
		intf.anotherMethod2
		assertEquals("CA", TEST_BUFFER)

	}

	@Test
	def void testRedirectionNewInterface() {

		assertEquals(2, IExtendedRedirectionNewWithExtractInterface.declaredMethods.size)
		assertEquals(1,
			IExtendedRedirectionNewWithExtractInterface.declaredMethods.filter[name == "disposeInternal"].size)
		assertEquals(1,
			IExtendedRedirectionNewWithExtractInterface.declaredMethods.filter[name == "anotherMethod2"].size)

		assertEquals(1, ExtendedRedirectionNewWithExtractInterface.declaredMethods.filter [
			name == "anotherMethod2Internal"
		].size)

	}

	@Test
	def void testRedirectionVisibility() {

		assertTrue(Modifier.isProtected(ExtendedRedirectionDerived3.getDeclaredMethod("disposeInternal").modifiers))
		assertTrue(Modifier.isPublic(ExtendedRedirectionDerived3.getDeclaredMethod("disposeInternal2").modifiers))
		assertTrue(
			!Modifier.isPublic(ExtendedRedirectionDerived4.getDeclaredMethod("disposeInternal3").modifiers) &&
				!Modifier.isProtected(ExtendedRedirectionDerived4.getDeclaredMethod("disposeInternal3").modifiers) &&
				!Modifier.isPrivate(ExtendedRedirectionDerived4.getDeclaredMethod("disposeInternal3").modifiers))
		assertTrue(
			!Modifier.isPublic(ExtendedRedirectionDerived6.getDeclaredMethod("disposeInternal3").modifiers) &&
				!Modifier.isProtected(ExtendedRedirectionDerived6.getDeclaredMethod("disposeInternal3").modifiers) &&
				!Modifier.isPrivate(ExtendedRedirectionDerived6.getDeclaredMethod("disposeInternal3").modifiers))

	}

	@Test
	def void testMultipleRedirection() {

		val obj = new ExtendedMultipleRedirection
		obj.dispose
		assertEquals("XYAZ", TEST_BUFFER)

	}

	@Test
	def void testAbstractRedirection() {

		val obj = new ExtendedAbstractRedirectionDerived
		obj.dispose
		assertEquals("YAX", TEST_BUFFER)

	}

	@Test
	def void testRedirectionOfExclusive() {

		val obj = new ExtendedWithRedirectionOfExclusive
		assertEquals(2, obj.dispose)
		assertEquals(1, obj.dispose2)
		assertEquals("ABUX", TraitTestsBase.TEST_BUFFER)

	}

	@Test
	def void testRedirectionProtectedToPublic() {

		assertTrue(Modifier.isProtected(ExtendedWithRedirectionPublic.getDeclaredMethod("disposeInternal").modifiers))

		val obj = new ExtendedWithRedirectionPublic
		assertEquals(2, obj.dispose)
		assertEquals("XP3P1", TraitTestsBase.TEST_BUFFER)

	}

	@Test
	def void testRedirectionApplicationErrors() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection
import org.eclipse.xtend.lib.macro.declaration.Visibility

interface InterfaceWithRedirection {

	@TraitMethodRedirection("methodInternal")
	def void method() {}

}

@TraitClassAutoUsing
abstract class RedirectedTraitClass {

	@TraitMethodRedirection("methodInternal")
	@ExclusiveMethod
	override void method() {}

	@ExclusiveMethod
	override void methodInternal() {}

}

class RedirectedExtendedClass {

	@TraitMethodRedirection("methodInternal1")
	static def void method1() {}

	static def void methodInternal1() {}

	@TraitMethodRedirection(value="methodInternal2", visibility=Visibility.PRIVATE)
	def void method2() {}

	def void methodInternal2() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val interfaceWithRedirection = findInterface("virtual.InterfaceWithRedirection")
			val clazzExtension = findClass("virtual.RedirectedTraitClass")
			val clazzExtended = findClass("virtual.RedirectedExtendedClass")

			val problemsInterfaceMethod = (interfaceWithRedirection.findDeclaredMethod("method").
				primarySourceElement as MethodDeclaration).problems
			val problemsTraitMethod = (clazzExtension.findDeclaredMethod("method").
				primarySourceElement as MethodDeclaration).problems
			val problemsExtendedMethod1 = (clazzExtended.findDeclaredMethod("method1").
				primarySourceElement as MethodDeclaration).problems
			val problemsExtendedMethod2 = (clazzExtended.findDeclaredMethod("method2").
				primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(4, allProblems.size)

			assertEquals(1, problemsInterfaceMethod.size)
			assertEquals(Severity.ERROR, problemsInterfaceMethod.get(0).severity)
			assertTrue(problemsInterfaceMethod.get(0).message.contains("class"))

			assertEquals(1, problemsTraitMethod.size)
			assertEquals(Severity.ERROR, problemsTraitMethod.get(0).severity)
			assertTrue(problemsTraitMethod.get(0).message.contains("trait class"))

			assertEquals(1, problemsExtendedMethod1.size)
			assertEquals(Severity.ERROR, problemsExtendedMethod1.get(0).severity)
			assertTrue(problemsExtendedMethod1.get(0).message.contains("non-static"))

			assertEquals(1, problemsExtendedMethod2.size)
			assertEquals(Severity.ERROR, problemsExtendedMethod2.get(0).severity)
			assertTrue(problemsExtendedMethod2.get(0).message.contains("private"))

		]

	}

	@Test
	def void testTraitMethodRedirectionFinal() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection

import virtual.intf.IRedirectedTraitClass

@TraitClassAutoUsing
abstract class RedirectedTraitClass {

	@ProcessedMethod(processor=EPVoidPre)
	override void method() {}

}

class RedirectedExtendedClassBase {

	@TraitMethodRedirection("methodInternal")
	def void method() {
		methodInternal()
	}

	final def void methodInternal() {}

}

@ExtendedByAuto
class RedirectedExtendedClassDerived extends RedirectedExtendedClassBase implements IRedirectedTraitClass {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.RedirectedExtendedClassDerived")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("final"))

		]

	}

	@Test
	def void testRedirectionCyclicError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod

import virtual.intf.IThisExtension

@TraitClassAutoUsing
abstract class ThisExtension {

	@ProcessedMethod(processor=EPVoidPre)
	override void dispose() {
	}

}

abstract class ThisExtendedBase1 {

	@TraitMethodRedirection("disposeInternal")
	def void dispose() {
	}

	@TraitMethodRedirection("dispose")
	def void disposeInternal() {
	}

}

@ExtendedByAuto
class ThisExtendedDerived1 extends ThisExtendedBase1 implements IThisExtension {
}

abstract class ThisExtendedBase2 {

	@TraitMethodRedirection("dispose")
	def void dispose() {
	}

}

@ExtendedByAuto
class ThisExtendedDerived2 extends ThisExtendedBase2 implements IThisExtension {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazzDerived1 = findClass("virtual.ThisExtendedDerived1")
			val clazzDerived2 = findClass("virtual.ThisExtendedDerived2")

			val problemsClassDerived1 = (clazzDerived1.primarySourceElement as ClassDeclaration).problems
			val problemsClassDerived2 = (clazzDerived2.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, allProblems.size)

			assertEquals(1, problemsClassDerived1.size)
			assertEquals(Severity.ERROR, problemsClassDerived1.get(0).severity)
			assertTrue(problemsClassDerived1.get(0).message.contains("cycle"))

			assertEquals(1, problemsClassDerived2.size)
			assertEquals(Severity.ERROR, problemsClassDerived2.get(0).severity)
			assertTrue(problemsClassDerived2.get(0).message.contains("cycle"))

		]

	}

	@Test
	def void testRedirectionEnvelopeRequiresImplementation() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection

import virtual.intf.ITraitMethodRedirectionRequired

@TraitClassAutoUsing
abstract class TraitMethodRedirectionRequired {

	@EnvelopeMethod(setFinal=false, required=true, disableRedirection=false) 
	override void dispose() {}

}

abstract class ExtendedRedirectionBase {

	@TraitMethodRedirection("disposeInternal")
	def void dispose() {}

}

@ExtendedByAuto
abstract class ExtendedRedirection extends ExtendedRedirectionBase implements ITraitMethodRedirectionRequired {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedRedirection")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("requires"))

		]

	}

}
