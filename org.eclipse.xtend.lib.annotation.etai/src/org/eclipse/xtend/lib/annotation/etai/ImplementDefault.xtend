package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import java.util.ArrayList
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeMatchingStrategy
import org.eclipse.xtend.lib.annotation.etai.utils.TypeMap
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static org.eclipse.xtend.lib.annotation.etai.utils.TypeMap.*

import static extension org.eclipse.xtend.lib.annotation.etai.EnvelopeMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ProcessedMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.RequiredMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * Implements all methods which are not implemented (yet) in the annotated non-abstract class
 * via default implementations (i.e. just return default values of method's return type).
 */
@Target(ElementType.TYPE)
@Active(ImplementDefaultProcessor)
annotation ImplementDefault {
}

/**
 * A method, which has been implemented because of the ({@link ImplementDefault}) annotation,
 * will be marked by this annotation
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
annotation DefaultImplementation {
}

/**
 * Active Annotation Processor for {@link DefaultImplementation}
 * 
 * @see ExtractInterface
 */
class ImplementDefaultProcessor extends AbstractClassProcessor implements QueuedTransformationParticipant<MutableClassDeclaration> {

	protected override Class<?> getProcessedAnnotationType() {
		ImplementDefault
	}

	override void doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {

		super.doRegisterGlobals(annotatedClass, context)

		// start processing of this element
		ProcessQueue.startTrack(ProcessQueue.PHASE_IMPLEMENT_DEFAULT, annotatedClass, annotatedClass.qualifiedName)

	}

	override void doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		super.doTransform(annotatedClass, context)

		// queue processing
		ProcessQueue.processTransformation(ProcessQueue.PHASE_IMPLEMENT_DEFAULT, this, annotatedClass,
			annotatedClass.qualifiedName, context)

	}

	override boolean doTransformQueued(int phase, MutableClassDeclaration annotatedClass, BodySetter bodySetter,
		extension TransformationContext context) {

		// create type map from type hierarchy
		val typeMap = new TypeMap
		fillTypeMapFromTypeHierarchy(annotatedClass, typeMap, context)

		// retrieve all methods, which are implemented
		val methodsImplemented = new ArrayList<MethodDeclaration>(
			annotatedClass.getMethodClosure(null, [false], true, false, false, true, context).filter[!it.abstract].
				toList)

		// retrieve all methods, which are not implemented (abstract)
		val methodsToBeImplemented = new ArrayList<MethodDeclaration>(
			annotatedClass.getMethodClosure(null, [true], true, false, false, true, context).filter[it.abstract].toList)

		// add methods from trait classes (which are relevant)
		for (traitClass : annotatedClass.getTraitClassesSpecifiedForExtendedClosure(null, context))
			for (traitMethod : (traitClass.type as ClassDeclaration).getTraitMethodClosure(typeMap, context))
				if (traitMethod.isRequiredMethod && traitMethod.visibility != Visibility.PUBLIC)
					methodsToBeImplemented.add(traitMethod)
				else if ((traitMethod.isProcessedMethod &&
					traitMethod.getProcessedMethodInfo(context).required == true) ||
					(traitMethod.isEnvelopeMethod && traitMethod.getEnvelopeMethodInfo(context).required == true
						))
					methodsToBeImplemented.add(
						new ExtendedByProcessor.MethodDeclarationRenamed(traitMethod,
							traitMethod.getExtendedMethodImplName(traitClass.type as ClassDeclaration),
							Visibility.PRIVATE)
					)

		// implement all abstract methods...
		for (methodNotImplemented : methodsToBeImplemented) {

			// ... except an implementation can be found 
			if (methodsImplemented.getMatchingMethod(methodNotImplemented,
				TypeMatchingStrategy.MATCH_INHERITANCE_CONSTRUCTOR_METHOD, TypeMatchingStrategy.MATCH_INHERITANCE,
				false, typeMap, context) === null) {

				// maybe an abstract method exists in current class (adaption), which can be used
				// otherwise a new method must be created (by copying)
				var implementedMethod = annotatedClass.getMatchingExecutableInClass(methodNotImplemented,
					TypeMatchingStrategy.MATCH_INHERITANCE_CONSTRUCTOR_METHOD, TypeMatchingStrategy.MATCH_INHERITANCE,
					false, false, true, false, false, typeMap, context) as MutableMethodDeclaration
				if (implementedMethod === null)
					implementedMethod = annotatedClass.copyMethod(methodNotImplemented, true, false, true, false, false,
						false, typeMap, context)

				// the implemented method will not be abstract
				implementedMethod.abstract = false

				// mark method via annotation
				implementedMethod.addAnnotation(DefaultImplementation.newAnnotationReference)

				// mark as "adapted method"
				if (!implementedMethod.hasAnnotation(AdaptedMethod))
					implementedMethod.addAnnotation(AdaptedMethod.newAnnotationReference)

				// create method's body
				if (implementedMethod.returnType == context.primitiveVoid)
					bodySetter.setBody(implementedMethod, '''''', context)
				else if (implementedMethod.returnType == context.primitiveBoolean)
					bodySetter.setBody(implementedMethod, '''return false;''', context)
				else if (implementedMethod.returnType == context.primitiveInt)
					bodySetter.setBody(implementedMethod, '''return 0;''', context)
				else if (implementedMethod.returnType == context.primitiveDouble)
					bodySetter.setBody(implementedMethod, '''return 0.0d;''', context)
				else if (implementedMethod.returnType == context.primitiveFloat)
					bodySetter.setBody(implementedMethod, '''return 0.0f;''', context)
				else if (implementedMethod.returnType == context.primitiveChar)
					bodySetter.setBody(implementedMethod, '''return '\0';''', context)
				else if (implementedMethod.returnType == context.primitiveLong)
					bodySetter.setBody(implementedMethod, '''return 0L;''', context)
				else if (implementedMethod.returnType == context.primitiveShort)
					bodySetter.setBody(implementedMethod, '''return 0;''', context)
				else if (implementedMethod.returnType == context.primitiveByte)
					bodySetter.setBody(implementedMethod, '''return 0;''', context)
				else
					bodySetter.setBody(implementedMethod, '''return null;''', context)

				// add to implemented methods, so it is not implemented again
				methodsImplemented.add(implementedMethod)

			}

		}

		return true

	}

	override void doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// default implementation can only applied to non-abstract classes
		if (xtendClass.abstract)
			xtendClass.addError('''Cannot implement default methods in abstract class''')

	}

}
