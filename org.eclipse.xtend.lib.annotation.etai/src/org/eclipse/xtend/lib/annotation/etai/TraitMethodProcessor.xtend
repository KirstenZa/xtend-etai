package org.eclipse.xtend.lib.annotation.etai

import java.lang.reflect.Method
import java.util.ArrayList
import java.util.List
import java.util.Collection

/**
 * <p>Interface for objects which store method calls. The stored call shall then
 * be processed by invoking the <code>eval()</code> method.</p>
 */
interface LazyEvaluation {

	/**
	 * <p>Returns the number of arguments in the stored method.</p>
	 */
	def int getNumberOfArguments()

	/**
	 * <p>Returns the argument in the stored method with the given index.</p>
	 */
	def Object getArgument(int index)

	/**
	 * <p>Changes the argument in the stored method with the given index.</p>
	 */
	def void setArgument(int index, Object value)

	/**
	 * <p>Returns the object executing the stored method.</p>
	 */
	def Object getExecutingObject()

	/**
	 * <p>Returns the stored method.</p>
	 */
	def Method getMethod()

	/**
	 * <p>Evaluate the stored method call and returns the result.</p>
	 */
	def Object eval()

}

/**
 * <p>This is a standard implementation of the interface for storing method calls.</p> 
 * 
 * <p>Note that this class should only be used if implemented by an anonymous inner class inside
 * a method.</p>
 */
abstract class LazyEvaluationAbstract implements LazyEvaluation {

	List<Object> arguments = new ArrayList<Object>
	Object executingObject

	new(Object executingObject, Collection<Object> arguments) {

		this.executingObject = executingObject

		if (arguments !== null)
			this.arguments.addAll(arguments)

	}

	override Object getExecutingObject() {
		return executingObject
	}

	override int getNumberOfArguments() {
		return arguments.size
	}

	override Object getArgument(int index) {
		return arguments.get(index)
	}

	override void setArgument(int index, Object value) {
		arguments.set(index, value)
	}

	override Method getMethod() {
		return class.enclosingMethod
	}

}

/**
 * <p>If a trait method may also exist in the extended class, a trait method
 * processor must be specified in addition. An object implementing this interface
 * (the trait method processor) must then steer the processing.</p>
 * 
 * <p>The trait method processor can call both methods via the lazy evaluation interface, so
 * controlling the program flow is possible concerning call order, blocking a call
 * (also short-circuit evaluation) and combining results.</p>
 * 
 * <p>A class implementing this interface must have a parameterless constructor.</p>
 * 
 * @see ProcessedMethod
 */
interface TraitMethodProcessor {

	/**
	 * <p>By overriding this method it can be specified how the methods of the trait class and
	 * the trait class are called. Both calls are passed via a lazy evaluation object.</p>
	 * 
	 * @param expressionTraitClass		    the stored call for the method of the trait class
	 * @param expressionExtendedClass		the stored call for the method of the extended class
	 */
	def Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass)

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>If the trait method exists in the extended class, it will override the functionality in the
 * trait class, i.e., the functionality in the trait class represents the default behavior.</p>
 */
class EPDefault implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		if (expressionExtendedClass !== null)
			return expressionExtendedClass.eval()
		return expressionTraitClass.eval()

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>The trait method completely overrides methods within the extended class.</p>
 */
class EPOverride implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		return expressionTraitClass.eval()

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>The trait method (return type: void) is executed before a potential method within the extended class.</p>
 */
class EPVoidPre implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		expressionTraitClass.eval()
		if (expressionExtendedClass !== null)
			expressionExtendedClass.eval()
		return null

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>The trait method (return type: void) is executed after a potential method within the extended class.</p>
 */
class EPVoidPost implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		if (expressionExtendedClass !== null)
			expressionExtendedClass.eval()
		expressionTraitClass.eval()
		return null

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>The trait method (return type: void) is executed after a potential method within the extended class even if there has been an exception.</p>
 */
class EPVoidFinally implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		try {
			if (expressionExtendedClass !== null)
				expressionExtendedClass.eval()
		} finally {
			expressionTraitClass.eval()
		}
		return null

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>The trait method (return type: boolean) is executed before a potential method within the extended class.
 * If such a method exists in the extended class, it is also executed if the result of the trait method
 * is true (short-circuit evaluation) and both results are combined via AND operation.</p>
 */
class EPBooleanPreAnd implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		var Boolean result = expressionTraitClass.eval() as Boolean
		if (result == true && expressionExtendedClass !== null)
			result = expressionExtendedClass.eval() as Boolean
		return result

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>The trait method (return type: boolean) is executed after a potential method within the extended class,
 * if the result of such a method is true (short-circuit evaluation). Then, both results are combined
 * via AND operation. If such a method does not exist, only the trait method is called.</p>
 */
class EPBooleanPostAnd implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		var Boolean result
		if (expressionExtendedClass !== null)
			result = expressionExtendedClass.eval() as Boolean
		else
			result = true
		if (result == true)
			result = expressionTraitClass.eval() as Boolean
		return result

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>The trait method (return type: boolean) is executed before a potential method within the extended class.
 * If such a method exists in the extended class, it is also executed if the result of the trait method
 * is false (short-circuit evaluation) and both results are combined via OR operation.</p>
 */
class EPBooleanPreOr implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		var Boolean result = expressionTraitClass.eval() as Boolean
		if (result == false && expressionExtendedClass !== null)
			result = expressionExtendedClass.eval() as Boolean
		return result

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>The trait method (return type: boolean) is executed after a potential method within the extended class,
 * if the result of such a method is false (short-circuit evaluation). Then, both results are combined
 * via OR operation. If such a method does not exist, only the trait method is called.</p>
 */
class EPBooleanPostOr implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		var Boolean result
		if (expressionExtendedClass !== null)
			result = expressionExtendedClass.eval() as Boolean
		else
			result = false
		if (result == false)
			result = expressionTraitClass.eval() as Boolean
		return result

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>This trait method processor will process the functionality of the trait class first.
 * If there is a result that is not <code>null</code>, this result will be returned
 * immediately. If the result is <code>null</code>, the functionality of the extended class
 * will be processed afterwards and the latter result will be returned if the corresponding
 * functionality exists.</p>
 */
class EPFirstNotNullPre implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		val resultExtension = expressionTraitClass.eval()
		if (resultExtension !== null)
			return resultExtension

		if (expressionExtendedClass !== null)
			return expressionExtendedClass.eval()
		return null

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>This trait method processor will process the functionality of the extended class first if this
 * functionality exists. If there is a result that is not <code>null</code>, this result will be
 * returned immediately. If the result is <code>null</code>, the functionality of the trait class
 * will be processed afterwards and the latter result will be returned.</p>
 */
class EPFirstNotNullPost implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		val resultExtended = if (expressionExtendedClass !== null)
				expressionExtendedClass.eval()
			else
				null

		if (resultExtended !== null)
			return resultExtended

		return expressionTraitClass.eval()

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>This trait method processor will process the functionality of the trait class first, and
 * process the functionality of the extended class afterwards if this functionality exists.</p>
 * 
 * <p>The returned result will be the result from the functionality of the extended class if this functionality
 * exists. Otherwise, the result from the functionality of the trait class will be used.</p>
 */
class EPExtendedResultPre implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		if (expressionExtendedClass !== null) {
			expressionTraitClass.eval()
			return expressionExtendedClass.eval()
		} else {
			return expressionTraitClass.eval()
		}

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>This trait method processor will process the functionality of the extended class first,
 * if this functionality exists, and process the functionality of the trait class afterwards.</p>
 * 
 * <p>The returned result will be the result from the functionality of the extended class if this functionality
 * exists. Otherwise, the result from the functionality of the trait class will be used.</p>
 */
class EPExtendedResultPost implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		if (expressionExtendedClass !== null) {
			val result = expressionExtendedClass.eval()
			expressionTraitClass.eval()
			return result
		} else {
			return expressionTraitClass.eval()
		}

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>This trait method processor will process the functionality of the trait class first, and
 * process the functionality of the extended class afterwards if this functionality exists.</p>
 * 
 * <p>The returned result will be the result from the functionality of the trait class.
 * The result from the functionality of the extended class will be ignored.</p>
 */
class EPTraitClassResultPre implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		val result = expressionTraitClass.eval()
		if (expressionExtendedClass !== null)
			expressionExtendedClass.eval()
		return result

	}

}

/**
 * <p>Standard trait method processor:</p>
 * 
 * <p>This trait method processor will process the functionality of the trait class first, and
 * process the functionality of the extended class afterwards if this functionality exists.</p>
 * 
 * <p>The returned result will be the result from the functionality of the trait class.
 * The result from the functionality of the extended class will be ignored.</p>
 */
class EPTraitClassResultPost implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		if (expressionExtendedClass !== null)
			expressionExtendedClass.eval()
		return expressionTraitClass.eval()

	}

}
