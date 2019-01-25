package org.eclipse.xtend.lib.annotation.etai

import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableNamedElement
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * Base class for activate annotation class processors (for auto adaption rules annotated on classes).
 */
abstract class RuleProcessor<T extends NamedElement, U extends MutableNamedElement> extends AbstractProcessor<T, U> {

	override void doValidate(T annotatedNamedElement, extension ValidationContext context) {

		super.doValidate(annotatedNamedElement, context)

		val xtendDeclaration = annotatedNamedElement.primarySourceElement as NamedElement

		// check if in context of ApplyRules
		val classWithDeclaration = if (xtendDeclaration instanceof ClassDeclaration)
				xtendDeclaration
			else if (xtendDeclaration instanceof MemberDeclaration)
				xtendDeclaration.declaringType
			else if (xtendDeclaration instanceof ParameterDeclaration)
				xtendDeclaration.declaringExecutable.declaringType
			else
				throw new IllegalArgumentException(
				'''Internal error: Annotation for rule processor cannot be applied to «xtendDeclaration.class»''')

		// check if in context of ApplyRules
		if (!classWithDeclaration.hasAnnotation(ApplyRules))
			xtendDeclaration.
				addError('''Annotation @«processedAnnotationType.simpleName» must be used in context of a class with annotation @ApplyRules''')

	}

}
