package org.eclipse.xtend.lib.annotation.etai

/**
 * Interface for objects which provide a default value. According objects can be used
 * for envelope methods.
 * 
 * @see EnvelopeMethod
 */
interface DefaultValueProvider<T> {

	/**
	 * Evaluate the stored method call and returns the result.
	 */
	def T getDefaultValue()

}
