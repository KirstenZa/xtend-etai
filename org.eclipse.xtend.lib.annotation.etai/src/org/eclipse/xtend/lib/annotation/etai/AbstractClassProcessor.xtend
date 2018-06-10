package org.eclipse.xtend.lib.annotation.etai

import java.util.List
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.ValidationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration

/**
 * Base class for activate annotation class processors.
 */
abstract class AbstractClassProcessor implements RegisterGlobalsParticipant<TypeDeclaration>, TransformationParticipant<MutableTypeDeclaration>, CodeGenerationParticipant<TypeDeclaration>, ValidationParticipant<TypeDeclaration> {

	override void doRegisterGlobals(List<? extends TypeDeclaration> annotatedTypes,
		extension RegisterGlobalsContext context) {
		for (annotatedType : annotatedTypes) {
			if (annotatedType instanceof ClassDeclaration)
				doRegisterGlobals(annotatedType, context);
		}
	}

	def void doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {}

	override void doTransform(List<? extends MutableTypeDeclaration> annotatedTypes,
		extension TransformationContext context) {
		for (annotatedType : annotatedTypes) {
			if (annotatedType instanceof MutableClassDeclaration)
				doTransform(annotatedType, context);
		}
	}

	def void doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {}

	override void doGenerateCode(List<? extends TypeDeclaration> annotatedTypes,
		extension CodeGenerationContext context) {
		for (annotatedType : annotatedTypes) {
			if (annotatedType instanceof ClassDeclaration)
				doGenerateCode(annotatedType, context);
		}
	}

	def void doGenerateCode(ClassDeclaration annotatedClass, extension CodeGenerationContext context) {}

	override void doValidate(List<? extends TypeDeclaration> annotatedTypes, extension ValidationContext context) {
		for (annotatedType : annotatedTypes) {
			if (annotatedType instanceof ClassDeclaration)
				doValidate(annotatedType, context)
			else
				annotatedType.
					addError('''Annotation @«getProcessedAnnotationType.simpleName» can only be used for classes''')
		}
	}

	def void doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {}

	/**
	 * Retrieves the processed annotation
	 */
	abstract protected def Class<?> getProcessedAnnotationType()

}
