package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.services.TypeLookup

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>This attribute can be set in order to synchronize getter/setter/adder/remover operations
 * for a field. With the attribute a named for the lock must be specified. This lock name is considered in a global
 * namespace, i.e., different fields can share the same lock by using the same name. This can
 * be important in context of setter/adder/remover operations which have to create/remove bidirectional
 * connections. In this case, both sides (fields) should use the same lock name if
 * thread-safe behavior is required.</p>
 * 
 * <p>Internally, fair reentrant read/write locks are used, i.e., multiple getter methods can run in parallel.</p>
 * 
 * @see BidirectionalRule
 */
@Target(ElementType.FIELD)
@Active(SynchronizationRuleProcessor)
annotation SynchronizationRule {

	/**
	 * <p>This attribute specifies the name of the lock that shall be used (global namespace).</p>
	 */
	String value = ""

}

/**
 * <p>Active Annotation Processor for {@link SynchronizationRule}.</p>
 * 
 * @see GetterRule 
 * @see SetterRule
 * @see AdderRule
 * @see RemoverRule
 */
class SynchronizationRuleProcessor extends RuleProcessor<FieldDeclaration, MutableFieldDeclaration> {

	static class SynchronizationRuleInfo {

		public String lockName = null

	}

	override protected getProcessedAnnotationType() {
		SynchronizationRule
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration
	}

	/**
	 * <p>Retrieves information from annotation (@SynchronizationRule).</p>
	 */
	static def SynchronizationRuleInfo getSynchronizationRuleInfo(FieldDeclaration annotatedField,
		extension TypeLookup context) {

		val synchronizationRuleProcessorInfo = new SynchronizationRuleInfo
		val annotationSynchronizationRule = annotatedField.getAnnotation(SynchronizationRule)

		synchronizationRuleProcessorInfo.lockName = annotationSynchronizationRule.getStringValue("value")

		return synchronizationRuleProcessorInfo

	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		val synchronizationRuleInfo = xtendField.getSynchronizationRuleInfo(context)

		// check that value of annotation (name of the lock) is not null or empty
		if (synchronizationRuleInfo.lockName.isNullOrEmpty) {
			xtendField.addError('''Annotation @«processedAnnotationType.simpleName» must specify a name for the lock''')
			return
		}

		// check that field has also setter, getter, adder or remover
		if (!xtendField.hasAnnotation(SetterRule) && !xtendField.hasAnnotation(GetterRule) &&
			!xtendField.hasAnnotation(AdderRule) && !xtendField.hasAnnotation(RemoverRule)) {
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must only be used if also @GetterRule, @SetterRule, @AdderRule or @RemoverRule are used''')
			return
		}

	}

}
