package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>Constructors within trait classes must be annotated by this annotation.</p>
 * 
 * <p>Only protected, non-static, void methods can be
 * annotated by this annotation. Then, real constructors that will call the annotated
 * method will be generated for the trait class. The
 * whole construction process will be forwarded to the annotated method (also called
 * trait class constructor).</p>
 * 
 * <p>The construction of a trait class is always handled by the extended class,
 * which must trigger the construction within its constructors (if there is no
 * default constructor for the trait class and auto adaption with construction
 * injection is not activated). In order to trigger the construction,
 * a generated method that follows a specific name pattern must be called.</p>
 * 
 * <p>For example, if a class <code>X</code> is extended by a trait class
 * <code>A</code> that has a trait class constructor with one integral parameter
 * within the constructors of <code>X</code>, there must be a call like
 * <code>new$A(intParam)</code>.</p>
 * 
 * <p>Calling trait class constructors of a parent must be handled by the 
 * annotated method.</p>
 * 
 * @see ConstructRule
 * @see TraitClass
 */
@Target(ElementType.METHOD)
@Active(ConstructorMethodProcessor)
annotation ConstructorMethod {
}

/**
 * <p>Active Annotation Processor for {@link ConstructorMethod}.</p>
 * 
 * @see ConstructorMethod
 */
class ConstructorMethodProcessor extends AbstractMethodProcessor {

	protected override getProcessedAnnotationType() {
		ConstructorMethodProcessor
	}

	/**
	 * <p>Checks if method is a trait class constructor.</p>
	 */
	static def isConstructorMethod(MethodDeclaration annotatedMethod) {
		annotatedMethod.hasAnnotation(ConstructorMethod)
	}

	/**
	 * <p>Copies the annotation (compatible to this processor) from the given source including
	 * all attributes and returns a new annotation reference.</p>
	 */
	static def AnnotationReference copyAnnotation(AnnotationTarget annotationTarget,
		extension TransformationContext context) {

		return ConstructorMethod.newAnnotationReference

	}

	override void doValidate(MethodDeclaration annotatedMethod, extension ValidationContext context) {

		super.doValidate(annotatedMethod, context)

		var MethodDeclaration xtendMethod = annotatedMethod.primarySourceElement as MethodDeclaration

		if (!(xtendMethod.declaringType instanceof ClassDeclaration) ||
			!(xtendMethod.declaringType as ClassDeclaration).isTraitClass) {
			annotatedMethod.
				addError('''Trait class constructor can only be declared within a trait class (annotated with @TraitClass or @TraitClassAutoUsing)''')
			return
		}

		// check if trait methods has valid properties
		if (xtendMethod.visibility != Visibility::PROTECTED)
			xtendMethod.addError("Trait class constructors must be declared protected")
		if (xtendMethod.static == true)
			xtendMethod.addError("Trait class constructors must not be declared static")

		// must be a void method (or inferred type)
		if (xtendMethod.returnType != context.primitiveVoid) {
			xtendMethod.addError("Return type of trait class constructor must be void")
		}

		// some variable names must not be used
		for (parameter : xtendMethod.parameters) {
			val parameterName = parameter.simpleName
			if (parameterName !== null && (parameterName == TraitClassProcessor.EXTENDED_THIS_FIELD_NAME ||
				parameterName.startsWith(ProcessUtils.IConstructorParamDummy.DUMMY_VARIABLE_NAME_PREFIX)))
				xtendMethod.
					addError('''Parameter name "«parameter.simpleName»" is not allowed for trait class constructors''')
		}

	}

}
