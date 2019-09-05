package org.eclipse.xtend.lib.annotation.etai

/**
 * <p>Interface for objects which provide a default value. According objects can be used
 * for envelope methods.</p>
 * 
 * @see EnvelopeMethod
 */
interface DefaultValueProvider<T> {

	/**
	 * <p>Evaluate the stored method call and returns the result.</p>
	 */
	def T getDefaultValue()

}

/** 
 * <p>Default value provider that returns <code>null</code> for any object type.</p>
 */
class DefaultValueProviderNull implements DefaultValueProvider<Object> {
	
	override Object getDefaultValue() { null }

}
