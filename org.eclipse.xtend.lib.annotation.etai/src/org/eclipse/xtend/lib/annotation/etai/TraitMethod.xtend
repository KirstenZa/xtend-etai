package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.services.TypeLookup

import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>Determines a trait method, i.e. a method within a trait class,
 * which will be part of the extended class.</p>
 * 
 * <p>It also determines that an implementation of the annotated trait method
 * is not allowed in the extended class.</p>
 * 
 * @see TraitClass
 */
@Target(ElementType.METHOD, ElementType.FIELD)
@Active(ExclusiveMethodProcessor)
annotation ExclusiveMethod {

	/**
	 * If the "set final" flag is set to true, the extended class will implement this
	 * method with the final modifier.
	 */
	boolean setFinal = false

	/**
	 * If this flag is set to true, the trait method will not be redirected, if redirection
	 * specifications are present in the extended class.
	 * 
	 * @see TraitMethodRedirection
	 */
	boolean disableRedirection = false

}

/**
 * <p>Determines a trait method, i.e. a method within a trait class,
 * which will be part of the extended class.</p>
 * 
 * <p>It also determines that the annotated trait method is also allowed in the extended
 * class. For order of calling and combining results of both methods, a processor must
 * be specified.</p>
 * 
 * @see TraitClass
 */
@Target(ElementType.METHOD, ElementType.FIELD)
@Active(ProcessedMethodProcessor)
annotation ProcessedMethod {

	/**
	 * <p>If the annotated trait method may also exist in the extended class, a trait method
	 * processor must be specified in addition.</p>
	 * 
	 * <p>An object of this class will be responsible for computing both methods in respect of 
	 * order, blocking a call (also short-circuit evaluation) and combining results.</p>
	 * 
	 * <p>The given class must provide a constructor, which does not require arguments.</p>
	 * 
	 * @see TraitMethodProcessor
	 */
	Class<?> processor

	/**
	 * If the "required flag" is set to true, the extended class must already implement this
	 * method as well.
	 */
	boolean required = false

	/**
	 * If the "set final" flag is set to true, the extended class will implement this
	 * method with the final modifier.
	 */
	boolean setFinal = false

	/**
	 * If this flag is set to true, the trait method will not be redirected, if redirection
	 * specifications are present in the extended class.
	 * 
	 * @see TraitMethodRedirection
	 */
	boolean disableRedirection = false

}

/**
 * <p>Determines a trait method, i.e. a method within a trait class,
 * which will be part of the extended class.</p>
 * 
 * <p>It also determines that it will become an "envelope" method and it will replace the
 * method within the extended class. The method of the extended class can be called
 * by "methodName$extended" within the envelope method. This way,
 *  the trait method can envelop and control the extended
 * method.</p>
 * 
 * <p>A default value provider can be specified for non-void methods in addition.
 * This provider will be used in case that the extended class does
 * not implement the method. If no default value provider is available,
 * the extended class must implement the method.</p>
 * 
 * @see TraitClass
 */
@Target(ElementType.METHOD, ElementType.FIELD)
@Active(EnvelopeMethodProcessor)
annotation EnvelopeMethod {

	/**
	 * <p>If the annotated trait method is an envelope method, a default value provider
	 * can be specified in addition. This provider will be used in case that the extended
	 * class does not implement the method. If not default value provider is available,
	 * the extended class must implement the method.</p>
	 * 
	 * <p>The given class must provide a constructor, which does not require arguments.</p>
	 * 
	 * @see DefaultValueProvider
	 */
	Class<?> defaultValueProvider = Object

	/**
	 * If the "required flag" is set to true, the extended class must already implement this
	 * method as well.
	 */
	boolean required = true

	/**
	 * <p>If the "set final" flag is set to true, the extended class will implement this
	 * method with the final modifier.</p>
	 * 
	 * <p>This prevents overriding the method in subclasses, which could break the idea of 
	 * having an envelope around methods, which are implemented in the extended class.</p>
	 */
	boolean setFinal = true

	/**
	 * <p>If this flag is set to true, the trait method will not be redirected, if redirection
	 * specifications are present in the extended class.</p>
	 * 
	 * @see TraitMethodRedirection
	 */
	boolean disableRedirection = true

}

/**
 * <p>Determines a trait method, i.e. a method within a trait class,
 * which will be part of the extended class.</p>
 * 
 * <p>It also determines that the annotated trait method must be implemented in
 * the extended class (or any derived trait class).</p>
 * 
 * <p>The trait method annotated with this implementation policy must be declared abstract.</p>
 * 
 * <p>In addition to this, the trait method could change the visibility of a
 * method already existing in the extended class.</p>
 * 
 * @see TraitClass
 */
@Target(ElementType.METHOD)
@Active(RequiredMethodProcessor)
annotation RequiredMethod {
}

/**
 * Active Annotation Processor for any trait method
 * 
 * @see TraitClass
 */
abstract class AbstractTraitMethodAnnotationProcessor extends AbstractMemberProcessor {

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration || annotatedNamedElement instanceof MethodDeclaration
	}

	/**
	 * Check if method is a trait method (or a field has an according annotation).
	 */
	static def isTraitMethod(AnnotationTarget annotationTarget) {

		ExclusiveMethodProcessor.isExclusiveMethod(annotationTarget) ||
			ProcessedMethodProcessor.isProcessedMethod(annotationTarget) ||
			EnvelopeMethodProcessor.isEnvelopeMethod(annotationTarget) ||
			RequiredMethodProcessor.isRequiredMethod(annotationTarget)

	}

	/**
	 * Count number of trait method annotations
	 */
	static def numberOfTraitMethodAnnotations(MethodDeclaration annotatedMethod) {

		var int counter = 0

		if (ExclusiveMethodProcessor.isExclusiveMethod(annotatedMethod))
			counter++
		if (ProcessedMethodProcessor.isProcessedMethod(annotatedMethod))
			counter++
		if (EnvelopeMethodProcessor.isEnvelopeMethod(annotatedMethod))
			counter++
		if (RequiredMethodProcessor.isRequiredMethod(annotatedMethod))
			counter++

		return counter

	}

	/**
	 * Copies the trait method annotation (if existent) from the given source including
	 * all attributes and returns a new annotation reference.
	 */
	static def AnnotationReference copyAnnotation(AnnotationTarget annotationTarget,
		extension TransformationContext context) {

		if (annotationTarget instanceof MethodDeclaration || annotationTarget instanceof FieldDeclaration) {
			if (ExclusiveMethodProcessor.isExclusiveMethod(annotationTarget))
				return ExclusiveMethodProcessor.copyAnnotation(annotationTarget, context)
			else if (ProcessedMethodProcessor.isProcessedMethod(annotationTarget))
				return ProcessedMethodProcessor.copyAnnotation(annotationTarget, context)
			else if (EnvelopeMethodProcessor.isEnvelopeMethod(annotationTarget))
				return EnvelopeMethodProcessor.copyAnnotation(annotationTarget, context)
			else if (RequiredMethodProcessor.isRequiredMethod(annotationTarget))
				return RequiredMethodProcessor.copyAnnotation(annotationTarget, context)
		}

		return null

	}

	override void doValidate(MemberDeclaration annotatedMember, extension ValidationContext context) {

		super.doValidate(annotatedMember, context)

		var MemberDeclaration xtendMember = annotatedMember.primarySourceElement as MemberDeclaration

		if (!(xtendMember.declaringType instanceof ClassDeclaration) ||
			!(xtendMember.declaringType as ClassDeclaration).isTraitClass) {
			annotatedMember.
				addError('''A trait method can only be declared within a trait class (annotated with @TraitClass or @TraitClassAutoUsing)''')
			return
		}

		if (xtendMember instanceof MethodDeclaration) {

			// check if trait methods has valid properties
			if (xtendMember.visibility == Visibility.PRIVATE)
				xtendMember.addError("A trait method must not be declared private")

			if (xtendMember.returnType === null || xtendMember.returnType.inferred == true)
				xtendMember.addError("A trait method must explicitly specify the return type")
			if (xtendMember.final == true)
				xtendMember.addError("A trait method must not be declared final")
			if (xtendMember.static == true)
				xtendMember.addError("A trait method must not be declared static")

			// only one trait method annotation must be used
			if (xtendMember.numberOfTraitMethodAnnotations > 1)
				xtendMember.addError("Only one trait method annotation must be applied")

		} else if (xtendMember instanceof FieldDeclaration) {

			if (xtendMember.final == true)
				xtendMember.addError("A trait method must not be declared final")
			if (xtendMember.static == true)
				xtendMember.addError("A trait method must not be declared static")

			if (!xtendMember.hasAnnotation(GetterRule) && !xtendMember.hasAnnotation(SetterRule) &&
				!xtendMember.hasAnnotation(AdderRule) && !xtendMember.hasAnnotation(RemoverRule))
				xtendMember.addError(
					"A trait method annotation can only applied to a field, if it is also annotated by @GetterRule, @SetterRule, @AdderRule or @RemoverRule")

		}

	}

}

/**
 * Active Annotation Processor for {@link ExclusiveMethod}
 * 
 * @see ExclusiveMethod
 */
class ExclusiveMethodProcessor extends AbstractTraitMethodAnnotationProcessor {

	/** 
	 * Helper class for storing information about trait method.
	 */
	static class ExclusiveMethodInfo {

		public boolean setFinal = false
		public boolean disableRedirection = false

	}

	protected override getProcessedAnnotationType() {
		ExclusiveMethodProcessor
	}

	/**
	 * Check if method is an exclusive method (or a field has an according annotation).
	 */
	static def isExclusiveMethod(AnnotationTarget annotationTarget) {
		annotationTarget.hasAnnotation(ExclusiveMethod)
	}

	/**
	 * Retrieves information from annotation (@ExclusiveMethod).
	 */
	static def getExclusiveMethodInfo(MethodDeclaration annotatedMethod, extension TypeLookup context) {

		val exclusiveMethodInfo = new ExclusiveMethodInfo
		val annotationExclusiveMethod = annotatedMethod.getAnnotation(ExclusiveMethod)

		if (annotationExclusiveMethod !== null) {

			exclusiveMethodInfo.setFinal = annotationExclusiveMethod.getBooleanValue("setFinal")
			exclusiveMethodInfo.disableRedirection = annotationExclusiveMethod.getBooleanValue("disableRedirection")

		}

		return exclusiveMethodInfo

	}

	/**
	 * Copies the annotation (compatible to this processor) from the given source (if existent) including
	 * all attributes and returns a new annotation reference
	 */
	static def AnnotationReference copyAnnotation(AnnotationTarget annotationTarget,
		extension TransformationContext context) {

		val annotationExclusiveMethod = annotationTarget.getAnnotation(ExclusiveMethod)

		if (annotationExclusiveMethod === null)
			return null

		return ExclusiveMethod.newAnnotationReference [
			setBooleanValue("setFinal", annotationExclusiveMethod.getBooleanValue("setFinal"))
			setBooleanValue("disableRedirection", annotationExclusiveMethod.getBooleanValue("disableRedirection"))
		]

	}

	override void doValidate(MemberDeclaration annotatedMember, extension ValidationContext context) {

		super.doValidate(annotatedMember, context)

		var MemberDeclaration xtendMember = annotatedMember.primarySourceElement as MemberDeclaration

		if (xtendMember instanceof MethodDeclaration) {

			// check for abstract modifier
			if (xtendMember.abstract == true)
				xtendMember.addError("Exclusive method must not be declared abstract")

		}

	}

}

/**
 * Active Annotation Processor for {@link ProcessedMethod}
 * 
 * @see ProcessedMethod
 */
class ProcessedMethodProcessor extends AbstractTraitMethodAnnotationProcessor {

	/** 
	 * Helper class for storing information about trait method.
	 */
	static class ProcessedMethodInfo {

		public TypeDeclaration processor = null
		public boolean required = false
		public boolean setFinal = false
		public boolean disableRedirection = false

	}

	protected override getProcessedAnnotationType() {
		ProcessedMethodProcessor
	}

	/**
	 * Check if method is a processed method (or a field has an according annotation).
	 */
	static def isProcessedMethod(AnnotationTarget annotationTarget) {
		annotationTarget.hasAnnotation(ProcessedMethod)
	}

	/**
	 * Retrieves information from annotation (@ProcessedMethod).
	 */
	static def getProcessedMethodInfo(MethodDeclaration annotatedMethod, extension TypeLookup context) {

		val processedMethodInfo = new ProcessedMethodInfo
		val annotationProcessedMethod = annotatedMethod.getAnnotation(ProcessedMethod)

		if (annotationProcessedMethod !== null) {

			val processor = annotationProcessedMethod.getClassValue("processor")
			if (processor !== null)
				processedMethodInfo.processor = processor.type as TypeDeclaration
			processedMethodInfo.required = annotationProcessedMethod.getBooleanValue("required")
			processedMethodInfo.setFinal = annotationProcessedMethod.getBooleanValue("setFinal")
			processedMethodInfo.disableRedirection = annotationProcessedMethod.getBooleanValue("disableRedirection")

		}

		return processedMethodInfo

	}

	/**
	 * Copies the annotation (compatible to this processor) from the given source (if existent) including
	 * all attributes and returns a new annotation reference
	 */
	static def AnnotationReference copyAnnotation(AnnotationTarget annotationTarget,
		extension TransformationContext context) {

		val annotationProcessedMethod = annotationTarget.getAnnotation(ProcessedMethod)

		if (annotationProcessedMethod === null)
			return null

		return ProcessedMethod.newAnnotationReference [
			setClassValue("processor", annotationProcessedMethod.getClassValue("processor"))
			setBooleanValue("required", annotationProcessedMethod.getBooleanValue("required"))
			setBooleanValue("setFinal", annotationProcessedMethod.getBooleanValue("setFinal"))
			setBooleanValue("disableRedirection", annotationProcessedMethod.getBooleanValue("disableRedirection"))
		]

	}

	override void doValidate(MemberDeclaration annotatedMember, extension ValidationContext context) {

		super.doValidate(annotatedMember, context)

		val traitMethodProcessorType = TraitMethodProcessor.findTypeGlobally

		var MemberDeclaration xtendMember = annotatedMember.primarySourceElement as MemberDeclaration

		if (xtendMember instanceof MethodDeclaration) {

			val processedMethodInfo = xtendMember.getProcessedMethodInfo(context)

			// check for abstract modifier
			if (xtendMember.abstract == true)
				xtendMember.addError("Processed method must not be declared abstract")

			if (processedMethodInfo.processor !== null) {

				// processor must be specified (non-void)
				if (processedMethodInfo.processor.qualifiedName == Object.canonicalName) {
					xtendMember.addError(
						"A processed method, which may also appear in extended class (non-exclusive), must also specify a processor")
				}

				// processor must have the correct type
				if (!(processedMethodInfo.processor instanceof ClassDeclaration) ||
					!(processedMethodInfo.processor as ClassDeclaration).getSuperTypeClosure(null, null, true, context).
						contains(traitMethodProcessorType))
					xtendMember.addError("The given processor is not implementing the TraitMethodProcessor interface")

			}

		}

	}

}

/**
 * Active Annotation Processor for {@link EnvelopeMethod}
 * 
 * @see EnvelopeMethod
 */
class EnvelopeMethodProcessor extends AbstractTraitMethodAnnotationProcessor {

	/** 
	 * Helper class for storing information about trait method.
	 */
	static class EnvelopeMethodInfo {

		public TypeDeclaration defaultValueProvider = null
		public boolean required = true
		public boolean setFinal = true
		public boolean disableRedirection = false

	}

	protected override getProcessedAnnotationType() {
		EnvelopeMethodProcessor
	}

	/**
	 * Check if method is an envelope method (or a field has an according annotation).
	 */
	static def isEnvelopeMethod(AnnotationTarget annotationTarget) {
		annotationTarget.hasAnnotation(EnvelopeMethod)
	}

	/**
	 * Retrieves information from annotation (@EnvelopeMethod).
	 */
	static def getEnvelopeMethodInfo(MethodDeclaration annotatedMethod, extension TypeLookup context) {

		val envelopeMethodInfo = new EnvelopeMethodInfo
		val annotationEnvelopeMethod = annotatedMethod.getAnnotation(EnvelopeMethod)

		if (annotationEnvelopeMethod !== null) {

			val defaultValueProvider = annotationEnvelopeMethod.getClassValue("defaultValueProvider")
			if (defaultValueProvider !== null)
				envelopeMethodInfo.defaultValueProvider = defaultValueProvider.type as TypeDeclaration
			envelopeMethodInfo.required = annotationEnvelopeMethod.getBooleanValue("required")
			envelopeMethodInfo.setFinal = annotationEnvelopeMethod.getBooleanValue("setFinal")
			envelopeMethodInfo.disableRedirection = annotationEnvelopeMethod.getBooleanValue("disableRedirection")

		}

		return envelopeMethodInfo

	}

	/**
	 * Copies the annotation (compatible to this processor) from the given source (if existent) including
	 * all attributes and returns a new annotation reference
	 */
	static def AnnotationReference copyAnnotation(AnnotationTarget annotationTarget,
		extension TransformationContext context) {

		val annotationEnvelopeMethod = annotationTarget.getAnnotation(EnvelopeMethod)

		if (annotationEnvelopeMethod === null)
			return null

		return EnvelopeMethod.newAnnotationReference [
			setClassValue("defaultValueProvider", annotationEnvelopeMethod.getClassValue("defaultValueProvider"))
			setBooleanValue("required", annotationEnvelopeMethod.getBooleanValue("required"))
			setBooleanValue("setFinal", annotationEnvelopeMethod.getBooleanValue("setFinal"))
			setBooleanValue("disableRedirection", annotationEnvelopeMethod.getBooleanValue("disableRedirection"))
		]

	}

	override void doValidate(MemberDeclaration annotatedMember, extension ValidationContext context) {

		super.doValidate(annotatedMember, context)

		val defaultValueProviderType = DefaultValueProvider.findTypeGlobally

		var MemberDeclaration xtendMember = annotatedMember.primarySourceElement as MemberDeclaration

		if (xtendMember instanceof MethodDeclaration) {

			val envelopeMethodInfo = xtendMember.getEnvelopeMethodInfo(context)

			// check for abstract modifier
			if (xtendMember.abstract == true)
				xtendMember.addError("Envelope method must not be declared abstract")

			if (envelopeMethodInfo.defaultValueProvider !== null) {

				// required flag and default value provider must be consistent
				val isVoid = xtendMember.returnType === null || xtendMember.returnType.isVoid()
				if (!isVoid && envelopeMethodInfo.required == false &&
					envelopeMethodInfo.defaultValueProvider.qualifiedName == Object.canonicalName)
					xtendMember.addError(
						"A non-void envelope method must either set the required flag to true or specify a default value provider")

				if (isVoid && envelopeMethodInfo.defaultValueProvider.qualifiedName != Object.canonicalName)
					xtendMember.addError("A void envelope method must not specify a default value provider")

				// default value provider must be a class
				if (!(envelopeMethodInfo.defaultValueProvider instanceof ClassDeclaration)) {
					xtendMember.addError("The given default value provider is not a class declaration")
					return
				}

				// default value provider must have the correct type
				if (envelopeMethodInfo.defaultValueProvider.qualifiedName != Object.canonicalName &&
					!(envelopeMethodInfo.defaultValueProvider as ClassDeclaration).getSuperTypeClosure(null, null, true,
						context).contains(defaultValueProviderType))
					xtendMember.addError(
						"The given default value provider is not implementing the DefaultValueProvider interface")

			}

		}

	}

}

/**
 * Active Annotation Processor for {@link RequiredMethod}
 * 
 * @see RequiredMethod
 */
class RequiredMethodProcessor extends AbstractTraitMethodAnnotationProcessor {

	/**
	 * Check if method is an required method (or a field has an according annotation).
	 */
	static def isRequiredMethod(AnnotationTarget annotationTarget) {
		annotationTarget.hasAnnotation(RequiredMethod)
	}

	protected override getProcessedAnnotationType() {
		RequiredMethodProcessor
	}

	/**
	 * Copies the annotation (compatible to this processor) from the given source (if existent) including
	 * all attributes and returns a new annotation reference
	 */
	static def AnnotationReference copyAnnotation(AnnotationTarget annotationTarget,
		extension TransformationContext context) {

		val annotationRequiredMethod = annotationTarget.getAnnotation(RequiredMethod)

		if (annotationRequiredMethod === null)
			return null

		return RequiredMethod.newAnnotationReference

	}

	override void doValidate(MemberDeclaration annotatedMember, extension ValidationContext context) {

		super.doValidate(annotatedMember, context)

		var MemberDeclaration xtendMember = annotatedMember.primarySourceElement as MemberDeclaration

		if (xtendMember instanceof MethodDeclaration) {

			// check for abstract modifier
			if (xtendMember.abstract == false)
				xtendMember.addError("Required method must be declared abstract")

		}

	}

}
