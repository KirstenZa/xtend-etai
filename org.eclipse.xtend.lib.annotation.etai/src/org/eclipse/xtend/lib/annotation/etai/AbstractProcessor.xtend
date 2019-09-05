package org.eclipse.xtend.lib.annotation.etai

import java.util.List
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.ValidationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableNamedElement
import org.eclipse.xtend.lib.macro.declaration.NamedElement

/**
 * <p>Base class for activate ETAI annotation processors.</p>
 */
abstract class AbstractProcessor<T extends NamedElement, U extends MutableNamedElement> implements RegisterGlobalsParticipant<T>, TransformationParticipant<U>, ValidationParticipant<T> {

	override void doRegisterGlobals(List<? extends T> annotatedNamedElements,
		extension RegisterGlobalsContext context) {

		for (annotatedNamedElement : annotatedNamedElements) {
			if (annotatedNamedElementSupported(annotatedNamedElement))
				doRegisterGlobals(annotatedNamedElement, context);
		}

	}

	def void doRegisterGlobals(T annotatedNamedElement, extension RegisterGlobalsContext context) {}

	override void doTransform(List<? extends U> annotatedMutableNamedElements,
		extension TransformationContext context) {

		for (annotatedMutableNamedElement : annotatedMutableNamedElements) {
			if (annotatedNamedElementSupported(annotatedMutableNamedElement))
				doTransform(annotatedMutableNamedElement, context);
		}

	}

	def void doTransform(U annotatedMutableNamedElement, extension TransformationContext context) {}

	override void doValidate(List<? extends T> annotatedNamedElements, extension ValidationContext context) {

		for (annotatedNamedElement : annotatedNamedElements) {

			if (!annotatedNamedElementSupported(annotatedNamedElement))
				annotatedNamedElement.
					addError('''Annotation @«getProcessedAnnotationType.simpleName» cannot be applied to «annotatedNamedElement.class»''')
			else
				doValidate(annotatedNamedElement, context)

		}

	}

	def void doValidate(T annotatedNamedElement, extension ValidationContext context) {}

	/**
	 * <p>Returns <code>true</code> if type of annotated element is supported.</p>
	 */
	abstract def boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement)

	/**
	 * <p>Retrieves the processed annotation type.</p>
	 */
	abstract protected def Class<?> getProcessedAnnotationType()

}

/**
 * <p>Base class for activate annotation processors for classes.</p>
 */
abstract class AbstractClassProcessor extends AbstractProcessor<ClassDeclaration, MutableClassDeclaration> {

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof ClassDeclaration
	}

}

/**
 * <p>Base class for activate annotation processors for methods.</p>
 */
abstract class AbstractMethodProcessor extends AbstractProcessor<MethodDeclaration, MutableMethodDeclaration> {

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof MethodDeclaration
	}

}

/**
 * <p>Base class for activate annotation processors for members.</p>
 */
abstract class AbstractMemberProcessor extends AbstractProcessor<MemberDeclaration, MutableMemberDeclaration> {

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof MemberDeclaration
	}

}
