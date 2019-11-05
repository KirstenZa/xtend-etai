package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.Collection
import java.util.Map
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.services.TypeLookup

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>This annotation can mark field, for which also <code>GetterRule</code>, <code>SetterRule</code> or
 * <code>AdderRule</code> is annotated. It ensures via assertions that <code>null</code> cannot be assigned or added, 
 * at least not via setter/adder. It is ensured the same way, that such a value can also not be retrieved via
 * getter.</p>
 * 
 * <p>Please note, that this annotation should not be used together with {@link BidirectionalRule} because used
 * algorithms require to temporarily disconnect bidirectional connections. This means, that <code>null</code> must
 * be set.</p>
 * 
 * @see GetterRule
 * @see SetterRule
 * @see AdderRule
 */
@Target(ElementType.FIELD)
@Active(NotNullRuleProcessor)
annotation NotNullRule {

	/**
	 * <p>Determines if <code>null</code> is allowed for the value of the field itself.</p>
	 */
	boolean notNullSelf = true

	/**
	 * <p>This flag is only relevant if the annotation is used together with {@link AdderRule}.</p>
	 * 
	 * <p>Determines if <code>null</code> is allowed as element of a collection (<code>java.util.Collection</code>) or as the key of a key/value pair (<code>java.util.Map</code>).</p>
	 */
	boolean notNullKeyOrElement = false

	/**
	 * <p>This flag is only relevant if the annotation is used together with {@link AdderRule}.</p>
	 * 
	 * <p>Determines if <code>null</code> is allowed as value of a key/value pair (<code>java.util.Map</code>).</p>
	 */
	boolean notNullValue = false

}

/**
 * <p>Active Annotation Processor for {@link NotNullRule}.</p>
 * 
 * @see SetterRule
 */
class NotNullRuleProcessor extends RuleProcessor<FieldDeclaration, MutableFieldDeclaration> {

	final static public String VALUE_NULL_SETTER_ERROR = "Value of field \"%s\" cannot been set to null"
	final static public String VALUE_NULL_GETTER_ERROR = "Value of field \"%s\" cannot be retrieved because it has been set to null, which is not allowed"
	final static public String VALUE_NULL_GETTER_KEY_ERROR = "Value of field \"%s\" cannot be retrieved because a contained element/key has been set to null, which is not allowed"
	final static public String VALUE_NULL_GETTER_VALUE_ERROR = "Value of field \"%s\" cannot be retrieved because a contained value has been set to null, which is not allowed"
	final static public String VALUE_NULL_ADDER_ERROR = "Cannot add null to \"%s\""
	final static public String VALUE_NULL_ADDER_PUT_KEY_ERROR = "Cannot add null to \"%s\" (key)"
	final static public String VALUE_NULL_ADDER_PUT_VALUE_ERROR = "Cannot add null to \"%s\" (value)"

	static class NotNullRuleInfo {

		public boolean notNullSelf = true
		public boolean notNullKeyOrElement = false
		public boolean notNullValue = false

	}

	override protected getProcessedAnnotationType() {
		NotNullRule
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration || annotatedNamedElement instanceof MethodDeclaration
	}

	/**
	 * <p>Retrieves information from annotation (@NotNullRule).</p>
	 */
	static def NotNullRuleInfo getNotNullInfo(FieldDeclaration annotatedField, extension TypeLookup context) {

		val notNullRuleInfo = new NotNullRuleInfo
		val annotationNotNullRule = annotatedField.getAnnotation(NotNullRule)

		notNullRuleInfo.notNullSelf = annotationNotNullRule.getBooleanValue("notNullSelf")
		notNullRuleInfo.notNullKeyOrElement = annotationNotNullRule.getBooleanValue("notNullKeyOrElement")
		notNullRuleInfo.notNullValue = annotationNotNullRule.getBooleanValue("notNullValue")

		return notNullRuleInfo

	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		val notNullRuleInfo = xtendField.getNotNullInfo(context)

		// check that field has (not inferred) type
		if (xtendField.type === null || xtendField.type.inferred) {
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» does not support fields with inferred type''')
			return
		}

		// check if in context of getter/setter rules		
		if (notNullRuleInfo.notNullSelf && !xtendField.hasAnnotation(SetterRule) &&
			!xtendField.hasAnnotation(GetterRule))
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must be used together with @GetterRule or @SetterRule if notNullSelf is set''')

		// check if in context of adder rules
		if ((notNullRuleInfo.notNullKeyOrElement || notNullRuleInfo.notNullValue) &&
			!xtendField.hasAnnotation(AdderRule))
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must be used together with @AdderRule if notNullKeyOrElement or notNullValue is set''')

		// check for concrete types
		if (notNullRuleInfo.notNullKeyOrElement &&
			!context.newTypeReference(Collection).type.
				isAssignableFromConsiderUnprocessed(xtendField.type?.type, context) &&
			!context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(xtendField.type?.type, context))
			xtendField.addError('''If flag notNullKeyOrElement is set, the field must be a collection or map''')
		if (notNullRuleInfo.notNullValue &&
			!context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(xtendField.type?.type, context))
			xtendField.addError('''If flag notNullValue is set, the field must be a map''')

		// check if not used with primitive types
		if (xtendField.type.primitive)
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must not be used with primitive types''')

	}

}
