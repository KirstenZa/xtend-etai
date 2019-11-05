package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPBooleanPreAnd
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithSetterChangeBase2
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassWithSetterChange
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassWithSetterChangeAndMethods
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassWithSetterChangeRedirect
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.eclipse.xtend.lib.annotation.etai.tests.adaption.ClassWithSetterChangeMultiUse.*
import static org.eclipse.xtend.lib.annotation.etai.tests.adaption.ClassWithSetterChangeStatic.*
import static org.junit.Assert.*

class ClassWithSimpleEquals {

	int value

	new(int value) {
		this.value = value
	}

	def int getValue() {
		return value
	}

	override boolean equals(Object other) {
		if (this === other)
			return true
		if (other instanceof ClassWithSimpleEquals)
			return this.value == other.value
		return false
	}

}

@ApplyRules
class ClassWithSetterChange {

	public int calledBefore = 0
	public int calledAfter = 0

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	int dataWithSetter1 = 12

	protected static def boolean dataWithSetter1BeforeChange(int newValue) {
		return newValue != 0
	}

	protected def void dataWithSetter1Changed(int oldValue, int newValue) {
		calledAfter++
		assertEquals(12, oldValue)
		assertEquals(30, newValue)
	}

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	int dataWithSetter2 = 12

	protected def boolean dataWithSetter2BeforeChange(int oldValue, int newValue) {
		calledBefore++
		return oldValue != 12 || newValue != 0
	}

	private def void dataWithSetter2Changed(int newValue) {
		calledAfter++
		assertEquals(30, newValue)
	}

	@SetterRule(beforeChange="beforeChange%", afterChange="afterChange%")
	@GetterRule
	int dataWithSetter3 = 12

	private def void beforeChangeDataWithSetter3() {
		calledBefore++
	}

	protected def void afterChangeDataWithSetter3() {
		calledAfter++
	}

	@SetterRule(beforeChange="beforeChange4", afterChange="afterChange4")
	@GetterRule
	int dataWithSetter4 = 12

	protected def boolean beforeChange4(String fieldName, int oldValue, int newValue) {
		calledBefore++
		assertEquals("dataWithSetter4", fieldName)
		return oldValue != 12 || newValue != 0
	}

	protected def void afterChange4(String fieldName, int oldValue, int newValue) {
		calledAfter++
		assertEquals("dataWithSetter4", fieldName)
		assertEquals(12, oldValue)
		assertEquals(30, newValue)
	}

	@SetterRule(beforeChange="%BeforeChange")
	@GetterRule
	int dataWithSetter5 = 12

	protected def boolean dataWithSetter5BeforeChange() {
		calledBefore++
		return true
	}

	@SetterRule(afterChange="%Changed")
	@GetterRule
	int dataWithSetter6 = 12

	def void dataWithSetter6Changed() {
		calledAfter++
	}

	@SetterRule(afterChange="%Changed")
	@GetterRule
	ClassWithSimpleEquals dataWithSetterSimpleEquals = null

	def void dataWithSetterSimpleEqualsChanged() {
		calledAfter++
	}

}

@ApplyRules
class ClassWithSetterChangeCollectionMap {

	public int calledAfter = 0

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	List<Integer> collectionWithSetter = new ArrayList<Integer>

	protected static def boolean collectionWithSetterBeforeChange(List<Integer> newValue) {
		return newValue !== null && newValue.size > 0 && newValue.get(0) > 10
	}

	protected def void collectionWithSetterChanged(Collection<Integer> oldValue, List<Integer> newValue) {
		calledAfter++
		assertNotNull(oldValue)
		assertNotNull(newValue)
		assertTrue(oldValue !== newValue)
		assertTrue(newValue.get(0) > 10)
	}

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	Map<String, Double> mapWithSetter = new HashMap<String, Double>

	protected static def boolean mapWithSetterBeforeChange(Map<String, Double> newValue) {
		return newValue !== null && newValue.size >= 2 && newValue.containsKey("test") && newValue.get("test") > 5.0
	}

	protected def void mapWithSetterChanged(Map<String, Double> oldValue, Map<String, Double> newValue) {
		calledAfter++
		assertNotNull(oldValue)
		assertNotNull(newValue)
		assertTrue(oldValue !== newValue)
		assertTrue(newValue.get("test") > 5.0)
	}

}

@ApplyRules
class ClassWithSetterChangeStatic {

	static public int calledBefore = 0
	static public int calledAfter = 0

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	static int dataWithSetter1 = 12

	static protected def boolean dataWithSetter1BeforeChange(int newValue) {
		calledBefore++
		return newValue != 0
	}

	static protected def void dataWithSetter1Changed(int oldValue, int newValue) {
		calledAfter++
		assertEquals(12, oldValue)
		assertEquals(30, newValue)
	}

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	static int dataWithSetter2 = 12

	static protected def boolean dataWithSetter2BeforeChange(int oldValue, int newValue) {
		calledBefore++
		return oldValue != 12 || newValue != 0
	}

	static protected def void dataWithSetter2Changed(int newValue) {
		calledAfter++
		assertEquals(30, newValue)
	}

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	static int dataWithSetter3 = 12

	static protected def void dataWithSetter3BeforeChange() {
		calledBefore++
	}

	static protected def void dataWithSetter3Changed() {
		calledAfter++
	}

	@SetterRule(beforeChange="beforeChange4", afterChange="afterChange4")
	@GetterRule
	static int dataWithSetter4 = 12

	static private def boolean beforeChange4(String fieldName, int oldValue, int newValue) {
		calledBefore++
		assertEquals("dataWithSetter4", fieldName)
		return oldValue != 12 || newValue != 0
	}

	static private def void afterChange4(String fieldName, int oldValue, int newValue) {
		calledAfter++
		assertEquals("dataWithSetter4", fieldName)
		assertEquals(12, oldValue)
		assertEquals(30, newValue)
	}

	@SetterRule(beforeChange="%BeforeChange")
	@GetterRule
	static int dataWithSetter5 = 12

	static protected def boolean dataWithSetter5BeforeChange() {
		calledBefore++
		return true
	}

	@SetterRule(afterChange="%Changed")
	@GetterRule
	static int dataWithSetter6 = 12

	static protected def void dataWithSetter6Changed() {
		calledAfter++
	}

}

@ApplyRules
class ClassWithSetterChangeMultiUse {

	public static int calledBefore = 0
	public int calledAfter = 0

	@SetterRule(beforeChange="beforeChangeMultiUse", afterChange="afterChagneMultiUse")
	@GetterRule
	int dataWithSetterInt = 14

	@SetterRule(beforeChange="beforeChangeMultiUse", afterChange="afterChagneMultiUse")
	@GetterRule
	String dataWithSetterString = "x"

	static protected def boolean beforeChangeMultiUse(String fieldName, Object oldValue, Object newValue) {
		calledBefore++
		assertTrue((fieldName == "dataWithSetterInt" && oldValue instanceof Integer && newValue instanceof Integer) ||
			(fieldName == "dataWithSetterString" && oldValue instanceof String && newValue instanceof String))
		if (newValue == 20)
			return false
		return true
	}

	protected def void afterChagneMultiUse(Object newValue) {
		calledAfter++
		assertTrue(newValue == 15 || newValue == "y")
	}

}

class ClassWithSetterChangeBase1 {

	protected def boolean dataWithSetterBeforeChange(int newValue) {
		return newValue != 0
	}

}

@ExtractInterface
class ClassWithSetterChangeBase2 {

	override void dataWithSetterChanged(int oldValue, int newValue) {
	}

}

@ApplyRules
abstract class ClassWithSetterChangeDerivedAbstract extends ClassWithSetterChangeBase1 implements IClassWithSetterChangeBase2 {

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	int dataWithSetter = 12

}

@ApplyRules
class ClassWithSetterChangeDerived extends ClassWithSetterChangeDerivedAbstract {

	public int calledAfter = 0

	override void dataWithSetterChanged(int oldValue, int newValue) {
		calledAfter++
		assertEquals(12, oldValue)
		assertEquals(30, newValue)
	}

}

@TraitClass
abstract class TraitClassWithSetterChange {

	int calledBefore = 0
	int calledAfter = 0

	@ExclusiveMethod
	protected def void dataWithSetter1BeforeChange(int newValue) {
		calledBefore++
	}

	@ExclusiveMethod
	override void dataWithSetter1Changed(int oldValue, int newValue) {
		calledAfter++
	}

	@ProcessedMethod(processor=EPBooleanPreAnd)
	protected def boolean dataWithSetter2BeforeChange(int newValue) {
		calledBefore++
		return newValue != 0
	}

	@ExclusiveMethod
	protected def void dataWithSetter2Changed(int oldValue, int newValue) {
		calledAfter++
		assertEquals(12, oldValue)
		assertEquals(30, newValue)
	}

	@ExclusiveMethod
	override int getCalledBefore() {
		return calledBefore
	}

	@ExclusiveMethod
	override int getCalledAfter() {
		return calledAfter
	}

}

@ApplyRules
@ExtendedByAuto
class ClassWithSetterChangeInTrait implements ITraitClassWithSetterChange {

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	int dataWithSetter1 = 12

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	int dataWithSetter2 = 12

	protected def boolean dataWithSetter2BeforeChange(int newValue) {
		return newValue != 1
	}

}

@TraitClass
abstract class TraitClassWithSetterChangeRedirect {

	int calledAfter = 0

	@ExclusiveMethod
	protected def boolean xxx(int newValue) {
		return newValue != 0
	}

	@ExclusiveMethod
	override void xxx(int oldValue, int newValue) {
		calledAfter++
	}

	@ExclusiveMethod
	override int getCalledAfter() {
		return calledAfter
	}

}

@ApplyRules
@ExtendedByAuto
class ClassWithSetterChangeInTraitRedirect implements ITraitClassWithSetterChangeRedirect {

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	int dataWithSetter = 12

	@TraitMethodRedirection(value="dataWithSetterBeforeChange", visibility=Visibility::PROTECTED)
	protected def boolean xxx(int newValue) {
		return false;
	}

	@TraitMethodRedirection(value="dataWithSetterChanged", visibility=Visibility::PROTECTED)
	override void xxx(int oldValue, int newValue) {
	}

}

@ApplyRules
@TraitClassAutoUsing
abstract class TraitClassWithSetterChangeAndMethods implements ITraitClassWithSetterChange {

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	@ExclusiveMethod
	int dataWithSetter1 = 12

	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@GetterRule
	@ExclusiveMethod
	int dataWithSetter2 = 12

	@ProcessedMethod(processor=EPBooleanPreAnd)
	protected def boolean dataWithSetter2BeforeChange(int newValue) {
		return newValue != 2
	}

}

@ExtendedByAuto
@ApplyRules
class ClassWithSetterChangeInTraitComplete implements ITraitClassWithSetterChangeAndMethods {
}

@ApplyRules
class ClassWithSetterChangeNoConcurrent {

	@SetterRule(afterChange="%Changed")
	@GetterRule
	int dataWithSetter1 = 12

	@SetterRule(afterChange="%Changed")
	@GetterRule
	int dataWithSetter2 = 56

	protected def void dataWithSetter1Changed() {
		setDataWithSetter2(99)

		if (dataWithSetter1 > 50) {
			dataWithSetter1++
			val newObj = new ClassWithSetterChangeNoConcurrent
			newObj.setDataWithSetter1(2)
			assertEquals(4, newObj.dataWithSetter1)
		} else {
			dataWithSetter1 += 2
		}

	}

	protected def void dataWithSetter2Changed() {
		if (setDataWithSetter1(44))
			dataWithSetter2 += 1
		else
			dataWithSetter2 += 2
	}

}

class GetterSetterChangeTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testChangeBasic() {

		val obj = new ClassWithSetterChange

		assertFalse(obj.dataWithSetter1 = 0)
		assertEquals(12, obj.dataWithSetter1)
		assertTrue(obj.dataWithSetter1 = 30)
		assertEquals(30, obj.dataWithSetter1)

		assertFalse(obj.dataWithSetter2 = 0)
		assertEquals(12, obj.dataWithSetter2)
		assertTrue(obj.dataWithSetter2 = 30)
		assertEquals(30, obj.dataWithSetter2)

		assertTrue(obj.dataWithSetter3 = 0)
		assertEquals(0, obj.dataWithSetter3)

		assertFalse(obj.dataWithSetter4 = 0)
		assertEquals(12, obj.dataWithSetter4)
		assertTrue(obj.dataWithSetter4 = 30)
		assertEquals(30, obj.dataWithSetter4)

		assertTrue(obj.dataWithSetter5 = 0)
		assertEquals(0, obj.dataWithSetter5)

		assertTrue(obj.dataWithSetter6 = 0)
		assertEquals(0, obj.dataWithSetter6)

		assertEquals(6, obj.calledBefore)
		assertEquals(5, obj.calledAfter)

		assertTrue(obj.dataWithSetterSimpleEquals = new ClassWithSimpleEquals(20))
		assertEquals(20, obj.dataWithSetterSimpleEquals.value)
		assertEquals(6, obj.calledAfter)

		assertTrue(obj.dataWithSetterSimpleEquals = new ClassWithSimpleEquals(30))
		assertEquals(30, obj.dataWithSetterSimpleEquals.value)
		assertEquals(7, obj.calledAfter)

		val newValue = new ClassWithSimpleEquals(30)

		assertTrue(obj.dataWithSetterSimpleEquals = newValue)
		assertEquals(30, obj.dataWithSetterSimpleEquals.value)
		assertEquals(8, obj.calledAfter)

		assertFalse(obj.dataWithSetterSimpleEquals = newValue)
		assertEquals(30, obj.dataWithSetterSimpleEquals.value)
		assertEquals(8, obj.calledAfter)

	}

	@Test
	def void testChangeCollectionMap() {

		{

			val obj = new ClassWithSetterChangeCollectionMap

			assertFalse(obj.collectionWithSetter = new ArrayList<Integer>())
			assertEquals(0, obj.collectionWithSetter.size)
			assertFalse(obj.collectionWithSetter = #[0])
			assertEquals(0, obj.collectionWithSetter.size)
			assertTrue(obj.collectionWithSetter = #[21])
			assertEquals(1, obj.collectionWithSetter.size)
			assertEquals(21, obj.collectionWithSetter.get(0))
			assertEquals(1, obj.calledAfter)

		}

		{

			val obj = new ClassWithSetterChangeCollectionMap

			val newMap = new HashMap<String, Double>()

			assertFalse(obj.mapWithSetter = new HashMap<String, Double>())
			assertEquals(0, obj.mapWithSetter.size)
			assertFalse(obj.mapWithSetter = newMap)
			assertEquals(0, obj.mapWithSetter.size)

			newMap.put("test", 3.0)
			newMap.put("x", 10.0)

			assertFalse(obj.mapWithSetter = newMap)
			assertEquals(0, obj.mapWithSetter.size)

			newMap.put("test", 10.0)

			assertTrue(obj.mapWithSetter = newMap)
			assertEquals(2, obj.mapWithSetter.size)
			assertEquals(10.0, obj.mapWithSetter.get("x"), 0.1)
			assertEquals(10.0, obj.mapWithSetter.get("test"), 0.1)
			assertEquals(1, obj.calledAfter)

		}

	}

	@Test
	def void testChangeStatic() {

		assertFalse(ClassWithSetterChangeStatic::dataWithSetter1 = 0)
		assertEquals(12, ClassWithSetterChangeStatic::dataWithSetter1)
		assertTrue(ClassWithSetterChangeStatic::dataWithSetter1 = 30)
		assertEquals(30, ClassWithSetterChangeStatic::dataWithSetter1)

		assertFalse(ClassWithSetterChangeStatic::dataWithSetter2 = 0)
		assertEquals(12, ClassWithSetterChangeStatic::dataWithSetter2)
		assertTrue(ClassWithSetterChangeStatic::dataWithSetter2 = 30)
		assertEquals(30, ClassWithSetterChangeStatic::dataWithSetter2)

		assertTrue(ClassWithSetterChangeStatic::dataWithSetter3 = 0)
		assertEquals(0, ClassWithSetterChangeStatic::dataWithSetter3)

		assertFalse(ClassWithSetterChangeStatic::dataWithSetter4 = 0)
		assertEquals(12, ClassWithSetterChangeStatic::dataWithSetter4)
		assertTrue(ClassWithSetterChangeStatic::dataWithSetter4 = 30)
		assertEquals(30, ClassWithSetterChangeStatic::dataWithSetter4)

		assertTrue(ClassWithSetterChangeStatic::dataWithSetter5 = 0)
		assertEquals(0, ClassWithSetterChangeStatic::dataWithSetter5)

		assertTrue(ClassWithSetterChangeStatic::dataWithSetter6 = 0)
		assertEquals(0, ClassWithSetterChangeStatic::dataWithSetter6)

		assertEquals(8, ClassWithSetterChangeStatic::calledBefore)
		assertEquals(5, ClassWithSetterChangeStatic::calledAfter)

	}

	@Test
	def void testChangeMultiUse() {

		ClassWithSetterChangeMultiUse::calledBefore = 0

		val obj = new ClassWithSetterChangeMultiUse

		assertFalse(obj.dataWithSetterInt = 20)
		assertEquals(14, obj.dataWithSetterInt)
		assertTrue(obj.dataWithSetterInt = 15)
		assertEquals(15, obj.dataWithSetterInt)

		assertEquals("x", obj.dataWithSetterString)
		assertTrue(obj.dataWithSetterString = "y")
		assertEquals("y", obj.dataWithSetterString)
		assertFalse(obj.dataWithSetterString = "y")

		assertEquals(3, ClassWithSetterChangeMultiUse::calledBefore)
		assertEquals(2, obj.calledAfter)

	}

	@Test
	def void testChangeDerived() {

		val obj = new ClassWithSetterChangeDerived

		assertFalse(obj.dataWithSetter = 0)
		assertEquals(12, obj.dataWithSetter)
		assertTrue(obj.dataWithSetter = 30)
		assertEquals(30, obj.dataWithSetter)

		assertEquals(1, obj.calledAfter)

	}

	@Test
	def void testChangeMethodsInTrait() {

		val obj1 = new ClassWithSetterChangeInTrait

		assertTrue(obj1.dataWithSetter1 = 0)
		assertEquals(0, obj1.dataWithSetter1)
		assertTrue(obj1.dataWithSetter1 = 30)
		assertEquals(30, obj1.dataWithSetter1)

		assertFalse(obj1.dataWithSetter2 = 0)
		assertEquals(12, obj1.dataWithSetter2)
		assertFalse(obj1.dataWithSetter2 = 1)
		assertEquals(12, obj1.dataWithSetter2)
		assertTrue(obj1.dataWithSetter2 = 30)
		assertEquals(30, obj1.dataWithSetter2)

		assertEquals(5, obj1.calledBefore)
		assertEquals(3, obj1.calledAfter)

		val obj2 = new ClassWithSetterChangeInTraitComplete

		assertTrue(obj2.dataWithSetter1 = 0)
		assertEquals(0, obj2.dataWithSetter1)
		assertTrue(obj2.dataWithSetter1 = 30)
		assertEquals(30, obj2.dataWithSetter1)
		assertFalse(obj2.dataWithSetter2 = 0)
		assertEquals(12, obj2.dataWithSetter2)
		assertFalse(obj2.dataWithSetter2 = 2)
		assertEquals(12, obj2.dataWithSetter2)
		assertTrue(obj2.dataWithSetter2 = 30)
		assertEquals(30, obj2.dataWithSetter2)

		assertEquals(5, obj2.calledBefore)
		assertEquals(3, obj2.calledAfter)

	}

	@Test
	def void testChangeMethodsInTraitRedirection() {

		val obj = new ClassWithSetterChangeInTraitRedirect

		assertFalse(obj.dataWithSetter = 0)
		assertEquals(12, obj.dataWithSetter)
		assertTrue(obj.dataWithSetter = 30)
		assertEquals(30, obj.dataWithSetter)

		assertEquals(1, obj.calledAfter)

	}

	@Test
	def void testChangeMethodsNoConcurrentChange() {

		val obj = new ClassWithSetterChangeNoConcurrent
		obj.dataWithSetter1 = 266

		assertEquals(267, obj.dataWithSetter1)
		assertEquals(101, obj.dataWithSetter2)

	}

	@Test
	def void testMethodNotFoundError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.SetterRule

@ApplyRules
class ClassWithSetter {

	@SetterRule(beforeChange="m1", afterChange="m2")
	double dataWithSetter = 12.1

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ClassWithSetter")

			val problemsAttributeDataWithSetter = (clazz.findDeclaredField("dataWithSetter").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(2, problemsAttributeDataWithSetter.size)
			assertEquals(Severity.ERROR, problemsAttributeDataWithSetter.get(0).severity)
			assertTrue(problemsAttributeDataWithSetter.get(0).message.contains("Cannot find"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithSetter.get(1).severity)
			assertTrue(problemsAttributeDataWithSetter.get(1).message.contains("Cannot find"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testMultipleMethodCandidatesError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.SetterRule

@ApplyRules
class ClassWithSetterBeforeChange {

	@SetterRule(beforeChange="change")
	double dataWithSetter = 12.1

	protected def boolean change(double newValue) {
		true
	} 

	protected def void change(double oldValue, double newValue) {
	} 

}

@ApplyRules
class ClassWithSetterAfterChange {

	@SetterRule(afterChange="change")
	double dataWithSetter = 12.1

	protected def boolean change(double newValue) {
		true
	} 

	protected def boolean change(double oldValue, double newValue) {
		true
	} 

}

@ApplyRules
class ClassWithSetterBeforeAfterChange {

	@SetterRule(beforeChange="changed", afterChange="changed")
	double dataWithSetter = 12.1

	protected def void changed(double newValue) {
	} 

}

		'''.compile [

			val extension ctx = transformationContext

			val clazzBefore = findClass("virtual.ClassWithSetterBeforeChange")
			val clazzAfter = findClass("virtual.ClassWithSetterAfterChange")

			val problemsAttributeBefore = (clazzBefore.findDeclaredField("dataWithSetter").
				primarySourceElement as FieldDeclaration).problems
			val problemsAttributeAfter = (clazzAfter.findDeclaredField("dataWithSetter").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsAttributeBefore.size)
			assertEquals(Severity.ERROR, problemsAttributeBefore.get(0).severity)
			assertTrue(problemsAttributeBefore.get(0).message.contains("candidates"))

			assertEquals(1, problemsAttributeAfter.size)
			assertEquals(Severity.ERROR, problemsAttributeAfter.get(0).severity)
			assertTrue(problemsAttributeAfter.get(0).message.contains("candidates"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testMarkAsRead() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.SetterRule

@ApplyRules
class ClassWithSetter {

	@SetterRule(beforeChange="change")
	double dataWithSetter = 12.1

	private def boolean change(double newValue) {
		true
	} 

}

		'''.compile [

			// no warning "not used" for method change
			assertEquals(0, allProblems.size)

		]

	}

}
