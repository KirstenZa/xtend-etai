package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.SynchronizationRule
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*
import java.util.ArrayList

@ApplyRules
class ClassForReentrantSynchronizationLock {

	@SetterRule(afterChange="%Changed")
	@GetterRule
	@SynchronizationRule("Data1")
	String data1

	@SetterRule(afterChange="%Changed")
	@GetterRule
	@SynchronizationRule("Data2")
	String data2

	protected def void data1Changed(String changedData1) {
		Thread.sleep((Math.random * 3.0) as long)
		data1 = data1 + "PlusX"
		Thread.sleep((Math.random * 3.0) as long)
	}

	protected def void data2Changed(String changedData2) {
		Thread.sleep((Math.random * 3.0) as long)
		data2 = data2 + "PlusY"
		Thread.sleep((Math.random * 3.0) as long)
	}

}

class SynchronizationTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testGetterSetterSynchronizationLocks() {

		val obj = new ClassWithSetterGetter

		val runnableChangeData = new Runnable() {

			override void run() {
				obj.dataWithSetter = 3.4
				obj.dataWithSetterAndGetter = "NameX"
				obj.dataWithSetter = 4.4
				obj.dataWithSetterAndGetter = obj.dataWithSetterAndGetter + "NameY"
				obj.dataWithSetter = 5.1
				obj.dataWithSetterAndGetter = "NameZ"
			}

		}

		val thread1 = new Thread(runnableChangeData)
		val thread2 = new Thread(runnableChangeData)
		thread1.start
		thread2.start
		thread1.join
		thread2.join

		assertEquals("NameZ", obj.dataWithSetterAndGetter)

	}

	@Test
	def void testAdderRemoverSynchronizationLocks() {

		val obj = new ClassWithAdderRemover

		val runnableChangeData = new Runnable() {

			override void run() {

				obj.putToDataWithAdderRemoverMap(4, 5.6)
				obj.putToDataWithAdderRemoverMap(7, 10.9)
				obj.clearDataWithAdderRemoverMap
				obj.putToDataWithAdderRemoverMap(5, 6.0)
				obj.removeFromDataWithAdderRemoverMap(5)
				obj.addToDataWithAdderRemoverList(0, 7)
				obj.removeFromDataWithAdderRemoverList(0)
				obj.addToDataWithAdderRemoverList(100)
				ClassWithAdderRemover::addToDataWithAdderRemoverListStatic(10)

			}

		}

		val thread1 = new Thread(runnableChangeData)
		val thread2 = new Thread(runnableChangeData)
		thread1.start
		thread2.start
		thread1.join
		thread2.join

		assertEquals(0, obj.dataWithAdderRemoverMap.size)
		assertArrayEquals(#[100, 100], obj.dataWithAdderRemoverList)
		assertArrayEquals(#[10, 10], ClassWithAdderRemover::dataWithAdderRemoverListStatic)

	}

	@Test
	def void testReentrantSynchronizationLocks() {

		val obj = new ClassForReentrantSynchronizationLock

		val runnableChangeData = new Runnable() {

			override void run() {
				obj.data1 = "Data1"
				obj.data2 = "Data1"
				obj.data1 = "Data2"
				obj.data2 = "Data2"
				obj.data1 = "Data3"
				obj.data2 = "Data3"
				obj.data1 = "Data4"
				obj.data2 = "Data4"
				obj.data1 = "Data5"
				obj.data2 = "Data5"
			}

		}

		val threads = new ArrayList(100);
		for (var i = 0; i < 100; i++)
			threads.add(new Thread(runnableChangeData));
		for (var i = 0; i < 100; i++)
			threads.get(i).start
		for (var i = 0; i < 100; i++)
			threads.get(i).join

		assertEquals("Data5PlusX", obj.data1)
		assertEquals("Data5PlusY", obj.data2)

	}

	@Test
	def void testSynchronizationUsageError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.SynchronizationRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

@ApplyRules
class ClassWithSynchronizationRule {

	@SynchronizationRule("LockName")
	int fieldNoGetterSetter

	@SynchronizationRule("")
	@GetterRule
	@SetterRule
	int fieldNoLockName

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithSynchronizationRule')

			val problemsFieldNoGetterSetter = (clazz.findDeclaredField("fieldNoGetterSetter").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldNoLockName = (clazz.findDeclaredField("fieldNoLockName").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldNoGetterSetter.size)
			assertEquals(Severity.ERROR, problemsFieldNoGetterSetter.get(0).severity)
			assertTrue(problemsFieldNoGetterSetter.get(0).message.contains("GetterRule"))

			assertEquals(1, problemsFieldNoLockName.size)
			assertEquals(Severity.ERROR, problemsFieldNoLockName.get(0).severity)
			assertTrue(problemsFieldNoLockName.get(0).message.contains("name"))

			assertEquals(2, allProblems.size)

		]

	}

}
