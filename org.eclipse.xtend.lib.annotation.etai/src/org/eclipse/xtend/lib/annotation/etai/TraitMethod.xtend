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
	 * <p>If the "set final" flag is set to true, the extended class will implement this
	 * method with the final modifier.</p>
	 */
	boolean setFinal = false

	/**
	 * <p>If this flag is set to true, the trait method will not be redirected if redirection
	 * specifications are present in the extended class.</p>
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
	 * <p>The given class must provide a constructor that does not require arguments.</p>
	 * 
	 * @see TraitMethodProcessor
	 */
	Class<?> processor

	/**
	 * <p>If the "required flag" is set to true, the extended class must implement this
	 * method as well.</p>
	 */
	boolean required = false

	/**
	 * <p>If the "set final" flag is set to true, the extended class will implement this
	 * method with the final modifier.</p>
	 */
	boolean setFinal = false

	/**
	 * <p>If this flag is set to true, the trait method will not be redirected if redirection
	 * specifications are present in the extended class.</p>
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
 * by <code>methodName$extended</code> within the envelope method. This way,
 * the trait method can envelop and control the extended
 * method.</p>
 * 
 * <p>A default value provider can be specified for non-void methods in addition.
 * This provider will be used in case that the extended class does
 * not implement the method. If no default value provider is available,
 * the extended class must implement the method.</p>
 * 
 * @see TraitClass
 */
@Target(ElementType.METHOD)
@Active(EnvelopeMethodProcessor)
annotation EnvelopeMethod {

	/**
	 * <p>If the annotated trait method is a non-<code>void</code> envelope method, a
	 * default value provider can be specified in addition. This provider will be used
	 * to retrieve a (return) value in case that the extended class does not implement the
	 * method. If no default value provider is available, the extended class must implement
	 * the method.</p>
	 * 
	 * <p>The given class must provide a constructor that does not require arguments.</p>
	 * 
	 * @see DefaultValueProvider
	 */
	Class<?> defaultValueProvider = Object

	/**
	 * <p>If the "required flag" is set to true, the extended class must implement this
	 * method as well.</p>
	 * 
	 * <p>If this annotation is used on a non-<code>void</code> method, this parameter must be
	 * either set to <code>true</code> or a default value provider is available.</p>
	 */
	boolean required = true

	/**
	 * <p>If the "set final" flag is set to true, the extended class will implement this
	 * method with the final modifier.</p>
	 * 
	 * <p>This prevents overriding the method in subclasses, which could break the idea of 
	 * having an envelope around methods that are implemented in the extended class.</p>
	 */
	boolean setFinal = true

	/**
	 * <p>If this flag is set to true, the trait method will not be redirected if redirection
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
 * <p>It also determines that the annotated trait method specifies a priority in relation to
 * a potential method in the extended class or the same trait method in other
 * trait classes. If the priority value is higher than the priority value of another method, it
 * will be executed earlier then the other method. If lower, the other way around. An error will be
 * reported if multiple trait classes with trait methods which share the same priority value
 * are used.</p>
 * 
 * <p>The potential method in the extended class is always considered to have a priority value of 0.
 * This is also the lowest value allowed. The highest allowed value is 
 * <code>java.lang.MAX_VALUE - 1</code>.</p>
 * 
 * <p>Apart from this, the priority envelope method is processed in a similar way as
 * {@link EnvelopeMethod}. That means that a trait method with high priority will replace any 
 * other method with lower priority. However, the method with the very next lower priority can
 * explicitly called by <code>methodName$extended</code> within the priority envelope method. 
 * This way, the trait method can envelop and control methods with lower priority.</p>
 * 
 * <p>A default value provider can be specified for non-void methods in addition.
 * This provider will be used in case that the extended class does
 * not implement the method. If no default value provider is available,
 * the extended class must implement the method.</p>
 * 
 * <p>The potential method in the extended class is always considered to have a priority value of 0.</p>
 * 
 * <p>Because of the used implementation, a class extended by a trait applying priority methods must
 * also specify {@link ApplyRules}. Therefore, please also note, that it is not possible to
 * skip the call of a priority method by deriving from the extended class and
 * re-implementing the method without calling its <code>super</code> method. The call of
 * priority methods is implemented via rule and applied automatically.</p>
 * 
 * @see TraitClass
 * @see EnvelopeMethod
 * @see ApplyRules
 */ 
@Target(ElementType.METHOD)
@Active(PriorityEnvelopeMethodProcessor)
annotation PriorityEnvelopeMethod {

	/**
	 * <p>The priority value of the priority envelope method.</p>
	 */
	int value

	/**
	 * <p>If the annotated trait method is a non-<code>void</code> priority envelope method, a
	 * default value provider can be specified in addition. This provider will be used
	 * to retrieve a (return) value in case that the extended class does not implement the
	 * method or there is not other priority envelope method with lower priority applied. 
	 * If no default value provider is available, such an implementation must exist.
	 * the method.</p>
	 * 
	 * <p>The given class must provide a constructor that does not require arguments.</p>
	 * 
	 * @see DefaultValueProvider
	 */
	Class<?> defaultValueProvider = Object

	/**
	 * <p>If the "required flag" is set to true, the extended class must implement this
	 * method as well.</p>
	 * 
	 * <p>Alternatively, the extended class applies another trait class with the same
	 * priority envelope method, but lower priority.</p>
	 * 
	 * <p>If this annotation is used on a non-<code>void</code> method, this parameter must be
	 * either set to <code>true</code> or a default value provider must be available.</p> 
	 */
	boolean required = true

}

/**
 * <p>Determines a trait method, i.e. a method within a trait class,
 * which will be part of the extended class.</p>
 * 
 * <p>It also determines that the annotated trait method must be implemented in
 * the extended class (or any derived class).</p>
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
 * <p>Active Annotation Processor for any trait method.</p>
 * 
 * @see TraitClass
 */
abstract class AbstractTraitMethodAnnotationProcessor extends AbstractMemberProcessor {

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration || annotatedNamedElement instanceof MethodDeclaration
	}

	/**
	 * <p>Checks if method is a trait method (or a field has an according annotation).</p>
	 */
	static def isTraitMethod(AnnotationTarget annotationTarget) {

		ExclusiveMethodProcessor.isExclusiveMethod(annotationTarget) ||
			ProcessedMethodProcessor.isProcessedMethod(annotationTarget) ||
			EnvelopeMethodProcessor.isEnvelopeMethod(annotationTarget) ||
			PriorityEnvelopeMethodProcessor.isPriorityEnvelopeMethod(annotationTarget) ||
			RequiredMethodProcessor.isRequiredMethod(annotationTarget)

	}

	/**
	 * <p>Counts number of trait method annotations.</p>
	 */
	static def numberOfTraitMethodAnnotations(MethodDeclaration annotatedMethod) {

		var int counter = 0

		if (ExclusiveMethodProcessor.isExclusiveMethod(annotatedMethod))
			counter++
		if (ProcessedMethodProcessor.isProcessedMethod(annotatedMethod))
			counter++
		if (EnvelopeMethodProcessor.isEnvelopeMethod(annotatedMethod))
			counter++
		if (PriorityEnvelopeMethodProcessor.isPriorityEnvelopeMethod(annotatedMethod))
			counter++
		if (RequiredMethodProcessor.isRequiredMethod(annotatedMethod))
			counter++

		return counter

	}

	/**
	 * <p>Copies the trait method annotation (if existent) from the given source including
	 * all attributes and returns a new annotation reference.</p>
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
			else if (PriorityEnvelopeMethodProcessor.isPriorityEnvelopeMethod(annotationTarget))
				return PriorityEnvelopeMethodProcessor.copyAnnotation(annotationTarget, context)
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
			if (xtendMember.visibility == Visibility::PRIVATE)
				xtendMember.addError("A trait method must not be declared private")

			if (xtendMember.returnType === null || xtendMember.returnType.inferred == true)
				xtendMember.addError("A trait method must explicitly specify the return type")
			if (xtendMember.static == true)
				xtendMember.addError("A trait method must not be declared static")

			// only one trait method annotation must be used
			if (xtendMember.numberOfTraitMethodAnnotations > 1)
				xtendMember.addError("Only one trait method annotation must be applied")

		} else if (xtendMember instanceof FieldDeclaration) {

			if (xtendMember.static == true)
				xtendMember.addError("A trait method must not be declared static")

			if (!xtendMember.hasAnnotation(GetterRule) && !xtendMember.hasAnnotation(SetterRule) &&
				!xtendMember.hasAnnotation(AdderRule) && !xtendMember.hasAnnotation(RemoverRule))
				xtendMember.addError(
					"A trait method annotation can only applied to a field if it is also annotated by @GetterRule, @SetterRule, @AdderRule or @RemoverRule")

		}

	}

}

/**
 * <p>Active Annotation Processor for {@link ExclusiveMethod}.</p>
 * 
 * @see ExclusiveMethod
 */
class ExclusiveMethodProcessor extends AbstractTraitMethodAnnotationProcessor {

	/** 
	 * <p>Helper class for storing information about trait method.</p>
	 */
	static class ExclusiveMethodInfo {

		public boolean setFinal = false
		public boolean disableRedirection = false

	}

	protected override getProcessedAnnotationType() {
		ExclusiveMethodProcessor
	}

	/**
	 * <p>Checks if method is an exclusive method (or a field has an according annotation).</p>
	 */
	static def isExclusiveMethod(AnnotationTarget annotationTarget) {
		annotationTarget.hasAnnotation(ExclusiveMethod)
	}

	/**
	 * <p>Retrieves information from annotation (@ExclusiveMethod).</p>
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
	 * <p>Copies the annotation (compatible to this processor) from the given source (if existent) including
	 * all attributes and returns a new annotation reference.</p>
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
 * <p>Active Annotation Processor for {@link ProcessedMethod}.</p>
 * 
 * @see ProcessedMethod
 */
class ProcessedMethodProcessor extends AbstractTraitMethodAnnotationProcessor {

	/** 
	 * <p>Helper class for storing information about trait method.</p>
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
	 * <p>Checks if method is a processed method (or a field has an according annotation).</p>
	 */
	static def isProcessedMethod(AnnotationTarget annotationTarget) {
		annotationTarget.hasAnnotation(ProcessedMethod)
	}

	/**
	 * <p>Retrieves information from annotation (@ProcessedMethod).</p>
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
	 * <p>Copies the annotation (compatible to this processor) from the given source (if existent) including
	 * all attributes and returns a new annotation reference.</p>
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
						"A processed method that may also appear in extended class (non-exclusive) must also specify a processor")
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
 * <p>Active Annotation Processor for {@link EnvelopeMethod}.</p>
 * 
 * @see EnvelopeMethod
 */
class EnvelopeMethodProcessor extends AbstractTraitMethodAnnotationProcessor {

	/** 
	 * <p>Helper (base) class for storing information about trait method.</p>
	 */
	static class EnvelopeMethodInfoBase {

		public TypeDeclaration defaultValueProvider = null
		public boolean required = true

	}

	/** 
	 * <p>Helper class for storing information about trait method.</p>
	 */
	static class EnvelopeMethodInfo extends EnvelopeMethodInfoBase {

		public boolean setFinal = true
		public boolean disableRedirection = false

	}

	protected override getProcessedAnnotationType() {
		EnvelopeMethodProcessor
	}

	/**
	 * <p>Checks if method is an envelope method (or a field has an according annotation).</p>
	 */
	static def isEnvelopeMethod(AnnotationTarget annotationTarget) {
		annotationTarget.hasAnnotation(EnvelopeMethod)
	}

	/**
	 * <p>Retrieves (base) information from annotation.</p>
	 */
	def EnvelopeMethodInfoBase getEnvelopeMethodInfoBase(MethodDeclaration annotatedMethod,
		extension TypeLookup context) {

		return getEnvelopeMethodInfo(annotatedMethod, context)

	}

	/**
	 * <p>Retrieves information from annotation (@EnvelopeMethod).</p>
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
	 * <p>Copies the annotation (compatible to this processor) from the given source (if existent) including
	 * all attributes and returns a new annotation reference</p>
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

			val envelopeMethodInfoBase = xtendMember.getEnvelopeMethodInfoBase(context)

			// check for abstract modifier
			if (xtendMember.abstract == true)
				xtendMember.addError("Envelope method must not be declared abstract")

			if (envelopeMethodInfoBase.defaultValueProvider !== null) {

				// required flag and default value provider must be consistent
				val isVoid = xtendMember.returnType === null || xtendMember.returnType.isVoid()
				if (!isVoid && envelopeMethodInfoBase.required == false &&
					envelopeMethodInfoBase.defaultValueProvider.qualifiedName == Object.canonicalName)
					xtendMember.addError(
						"A non-void envelope method must either set the required flag to true or specify a default value provider")

				// no default value provider for void methods
				if (isVoid && envelopeMethodInfoBase.defaultValueProvider.qualifiedName != Object.canonicalName)
					xtendMember.addError("A void envelope method must not specify a default value provider")

				// no default value provider if method required
				if (envelopeMethodInfoBase.required == true &&
					envelopeMethodInfoBase.defaultValueProvider.qualifiedName != Object.canonicalName)
					xtendMember.addError(
						"A default value provider must not be provided if method is required in extended class")

				// default value provider must have the correct type
				if (envelopeMethodInfoBase.defaultValueProvider.qualifiedName != Object.canonicalName &&
					(!(envelopeMethodInfoBase.defaultValueProvider instanceof ClassDeclaration) ||
						!(envelopeMethodInfoBase.defaultValueProvider as ClassDeclaration).
							getSuperTypeClosure(null, null, true, context).contains(defaultValueProviderType)))
					xtendMember.addError(
						"The given default value provider is not implementing the DefaultValueProvider interface")

			}

		}

	}

}

/**
 * <p>Active Annotation Processor for {@link PriorityEnvelopeMethod}.</p>
 * 
 * @see PriorityEnvelopeMethod
 */
class PriorityEnvelopeMethodProcessor extends EnvelopeMethodProcessor {

	/** 
	 * <p>Helper class for storing information about trait method.</p>
	 */
	static class PriorityEnvelopeMethodInfo extends EnvelopeMethodProcessor.EnvelopeMethodInfoBase {

		public int priority = 0

	}

	/**
	 * <p>Checks if method is an priority method (or a field has an according annotation).</p>
	 */
	static def isPriorityEnvelopeMethod(AnnotationTarget annotationTarget) {
		annotationTarget.hasAnnotation(PriorityEnvelopeMethod)
	}

	protected override getProcessedAnnotationType() {
		PriorityEnvelopeMethodProcessor
	}

	/**
	 * <p>Retrieves (base) information from annotation.</p>
	 */
	override EnvelopeMethodInfoBase getEnvelopeMethodInfoBase(MethodDeclaration annotatedMethod,
		extension TypeLookup context) {

		return getPriorityEnvelopeMethodInfo(annotatedMethod, context)

	}

	/**
	 * <p>Retrieves information from annotation (@PriorityEnvelopeMethod).</p>
	 */
	static def getPriorityEnvelopeMethodInfo(MethodDeclaration annotatedMethod, extension TypeLookup context) {

		val priorityEnvelopeMethodInfo = new PriorityEnvelopeMethodInfo
		val annotationPriorityEnvelopeMethod = annotatedMethod.getAnnotation(PriorityEnvelopeMethod)

		if (annotationPriorityEnvelopeMethod !== null) {

			priorityEnvelopeMethodInfo.priority = annotationPriorityEnvelopeMethod.getIntValue("value")
			val defaultValueProvider = annotationPriorityEnvelopeMethod.getClassValue("defaultValueProvider")
			if (defaultValueProvider !== null)
				priorityEnvelopeMethodInfo.defaultValueProvider = defaultValueProvider.type as TypeDeclaration
			priorityEnvelopeMethodInfo.required = annotationPriorityEnvelopeMethod.getBooleanValue("required")

		}

		return priorityEnvelopeMethodInfo

	}

	/**
	 * <p>Copies the annotation (compatible to this processor) from the given source (if existent) including
	 * all attributes and returns a new annotation reference.</p>
	 */
	static def AnnotationReference copyAnnotation(AnnotationTarget annotationTarget,
		extension TransformationContext context) {

		val annotationPriorityEnvelopeMethod = annotationTarget.getAnnotation(PriorityEnvelopeMethod)

		if (annotationPriorityEnvelopeMethod === null)
			return null

		return PriorityEnvelopeMethod.newAnnotationReference [
			setIntValue("value", annotationPriorityEnvelopeMethod.getIntValue("value"))
			setClassValue("defaultValueProvider",
				annotationPriorityEnvelopeMethod.getClassValue("defaultValueProvider"))
			setBooleanValue("required", annotationPriorityEnvelopeMethod.getBooleanValue("required"))
		]

	}

	override void doValidate(MemberDeclaration annotatedMember, extension ValidationContext context) {

		super.doValidate(annotatedMember, context)

		var MemberDeclaration xtendMember = annotatedMember.primarySourceElement as MemberDeclaration

		if (xtendMember instanceof MethodDeclaration) {

			val priorityEnvelopeMethodInfo = xtendMember.getPriorityEnvelopeMethodInfo(context)

			// check priority value
			if (priorityEnvelopeMethodInfo.priority <= 0 || priorityEnvelopeMethodInfo.priority === Integer::MAX_VALUE)
				xtendMember.addError("Priority value must be higher than 0 and lower than java.lang.Integer.MAX_VALUE")

		}

	}

}

/**
 * <p>Active Annotation Processor for {@link RequiredMethod}.</p>
 * 
 * @see RequiredMethod
 */
class RequiredMethodProcessor extends AbstractTraitMethodAnnotationProcessor {

	/**
	 * <p>Checks if method is an required method (or a field has an according annotation).</p>
	 */
	static def isRequiredMethod(AnnotationTarget annotationTarget) {
		annotationTarget.hasAnnotation(RequiredMethod)
	}

	protected override getProcessedAnnotationType() {
		RequiredMethodProcessor
	}

	/**
	 * <p>Copies the annotation (compatible to this processor) from the given source (if existent) including
	 * all attributes and returns a new annotation reference.</p>
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
