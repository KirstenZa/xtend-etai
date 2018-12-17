package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.MethodDeclarationRenamed
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
import org.eclipse.xtend.lib.macro.services.TypeLookup

import static org.eclipse.xtend.lib.annotation.etai.utils.TypeMap.*

import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>Via this annotation the application of a trait method can be redirected to
 * another subsidiary method. For example, if a method <code>foo</code> is annotated by this
 * annotation and the value is set to <code>fooInternal</code>, each trait
 * class with trait method <code>foo</code> will extend <code>fooInternal</code>
 * instead of <code>foo</code>.</p>
 * 
 * <p>The typical use case is, that the annotated method <code>foo</code> will become a
 * surrounding method (envelope method) and would call the method <code>fooInternal</code>,
 * which is why <code>fooInternal</code> is called the subsidiary method.
 * 
 * @see ExclusiveMethod
 * @see EnvelopeMethod
 * @see ProcessedMethod
 */
@Target(ElementType.METHOD)
@Active(TraitMethodRedirectionProcessor)
annotation TraitMethodRedirection {

	/**
	 * <p>The name of the subsidiary method.</p>
	 * 
	 * <p>The method must match the annotated method in terms of
	 * parameters, return types, etc.</p>
	 */
	String value

	/**
	 * If a trait method is redirected, its declared visibility in the trait
	 * class will not be used. Instead, the visibility set for the redirection will
	 * be used.
	 */
	Visibility visibility = Visibility.PROTECTED

}

/**
 * Active Annotation Processor for {@link TraitMethodRedirection}
 * 
 * @see TraitMethodRedirection
 */
class TraitMethodRedirectionProcessor extends AbstractMethodProcessor implements QueuedTransformationParticipant<MutableMethodDeclaration> {

	/** 
	 * Helper class for storing information about trait method redirection.
	 */
	static class TraitMethodRedirectionInfo {

		public String redirectedMethodName = null
		public Visibility redirectedVisibility = Visibility.PROTECTED

	}

	protected override Class<?> getProcessedAnnotationType() {
		TraitMethodRedirectionProcessor
	}

	/**
	 * Retrieves information from annotation (@TraitMethodRedirection).
	 */
	static def getTraitMethodRedirectionInfo(MethodDeclaration annotatedMethod, extension TypeLookup context) {

		val extensionRedirectionInfo = new TraitMethodRedirectionInfo
		val annotationTraitMethodRedirection = annotatedMethod.getAnnotation(TraitMethodRedirection)

		if (annotationTraitMethodRedirection !== null) {

			extensionRedirectionInfo.redirectedMethodName = annotationTraitMethodRedirection.getStringValue("value")
			extensionRedirectionInfo.redirectedVisibility = Visibility.valueOf(
				annotationTraitMethodRedirection.getEnumValue("visibility").simpleName)

		}

		return extensionRedirectionInfo

	}

	override void doRegisterGlobals(MethodDeclaration annotatedMethod, RegisterGlobalsContext context) {

		super.doRegisterGlobals(annotatedMethod, context)

		if (annotatedMethod.declaringType instanceof ClassDeclaration) {

			// retrieve class of method
			val classWithAnnotatedMethod = annotatedMethod.declaringType as ClassDeclaration

			// start processing of this element
			ProcessQueue.startTrack(ProcessQueue.PHASE_EXTENSION_REDIRECTION, classWithAnnotatedMethod,
				classWithAnnotatedMethod.qualifiedName)

		}

	}

	override void doTransform(MutableMethodDeclaration annotatedMethod, extension TransformationContext context) {

		super.doTransform(annotatedMethod, context)

		if (annotatedMethod.declaringType instanceof ClassDeclaration) {

			val classWithAnnotatedMethod = annotatedMethod.declaringType as MutableClassDeclaration

			// queue processing
			ProcessQueue.processTransformation(ProcessQueue.PHASE_EXTENSION_REDIRECTION, this, annotatedMethod,
				classWithAnnotatedMethod.qualifiedName, context)

		}

	}

	override boolean doTransformQueued(int phase, MutableMethodDeclaration annotatedMethod, BodySetter bodySetter,
		extension TransformationContext context) {

		val classWithAnnotatedMethod = annotatedMethod.declaringType as MutableClassDeclaration
		val extensionRedirectionInfo = annotatedMethod.getTraitMethodRedirectionInfo(context)

		// create type map from type hierarchy
		val typeMap = new TypeMap
		fillTypeMapFromTypeHierarchy(classWithAnnotatedMethod, typeMap, context)

		// create a new method to which the annotated method is redirecting to (abstract), if not already declared
		val annotatedMethodRedirected = new MethodDeclarationRenamed(annotatedMethod,
			extensionRedirectionInfo.redirectedMethodName, extensionRedirectionInfo.redirectedVisibility)
		if (classWithAnnotatedMethod.getMethodClosure(null, null, true, false, false, true, context).getMatchingMethod(
			annotatedMethodRedirected, TypeMatchingStrategy.MATCH_INVARIANT, TypeMatchingStrategy.MATCH_INVARIANT,
			false, typeMap, context) === null) {
			val methodRedirectedTo = classWithAnnotatedMethod.copyMethod(annotatedMethod, true, false, false, false,
				false, false, typeMap, context)
			methodRedirectedTo.simpleName = extensionRedirectionInfo.redirectedMethodName
			methodRedirectedTo.visibility = extensionRedirectionInfo.redirectedVisibility
			methodRedirectedTo.abstract = true
		}

		return true

	}

	override void doValidate(MethodDeclaration annotatedMethod, extension ValidationContext context) {

		super.doValidate(annotatedMethod, context)

		val xtendMethod = annotatedMethod.primarySourceElement as MethodDeclaration

		if (!(xtendMethod.declaringType instanceof ClassDeclaration)) {
			annotatedMethod.
				addError('''Annotation @«processedAnnotationType.simpleName» can only be used for methods within classes''')
			return
		}

		// analysis of method name and visibility
		val extensionRedirectionInfo = annotatedMethod.getTraitMethodRedirectionInfo(context)
		if (extensionRedirectionInfo.redirectedMethodName.nullOrEmpty)
			xtendMethod.addError('''Specified method name must not be null''')
		if (extensionRedirectionInfo.redirectedVisibility == Visibility.PRIVATE)
			xtendMethod.addError('''Specified visibility must not be private''')

		// must not be used for trait classes
		if (xtendMethod.declaringType instanceof ClassDeclaration &&
			(xtendMethod.declaringType as ClassDeclaration).isTraitClass)
			xtendMethod.addError('''Trait method redirection cannot be used in context of a trait class''')

		// check specific properties of annotated method
		if (xtendMethod.static == true)
			xtendMethod.addError('''Trait method redirection can only be applied to non-static methods''')

	}

}
