/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import java.util.List
import java.util.Map

@ExtractInterface
class TestClassWildcards {

	override void method1(List<? extends TestClassWildcards> x) {}

	override void method2(List<? super TestClassWildcards> x) {}

	override void method3(List<?> x) {}

}

@ExtractInterface
class TestClassTypeArrays {

	override void method1(String [] arg) {}

	override void method2(String [][] arg) {}

}

@ExtractInterface
class TestClassTypeArguments {

	override <T extends TestClassTypeArguments> T method1() {}

	override <T extends TestClassTypeArguments> void method2(List<T> arg) {}

	override <T extends TestClassTypeArguments> void method3(List<Map<T, T>> arg) {}

	override <T> T method4(List<List<T>> arg1, List<Map<T, T>> arg2) {}

}

@ExtractInterface
class TestClassTypeArgumentsAndWildcards {

	override <T> void method1(List<Map<T, T>> arg) {}

	override <T extends TestClassTypeArguments> void method2(List<? extends T> arg) {}

	override <T extends TestClassTypeArguments> void method3(
		List<Map<? super TestClassTypeArguments, ? extends TestClassTypeArguments>> arg) {}

	override <T extends TestClassTypeArguments> void method4(
		List<Map<? super TestClassTypeArguments, ? extends TestClassTypeArguments>> [] arg) {}

	override <T extends TestClassTypeArguments> void method5(
		List<Map<? super TestClassTypeArguments, ? extends TestClassTypeArguments>> [][] arg) {}

}
