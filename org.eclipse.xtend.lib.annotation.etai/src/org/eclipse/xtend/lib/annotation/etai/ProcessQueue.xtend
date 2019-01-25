package org.eclipse.xtend.lib.annotation.etai

import org.eclipse.xtend.lib.annotation.etai.utils.LogUtils
import org.eclipse.xtend.lib.annotation.etai.utils.StringUtils
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.CompilationUnit
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableAnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity

/**
 * Transformation processors which can be queued shall implement this interface.
 */
interface QueuedTransformationParticipant<T extends MutableAnnotationTarget> {

	/**
	 * <p>This method is called in order to start the transformation process.</p>
	 * 
	 * <p>It returns, if it was possible to start it.</p>
	 */
	def boolean doTransformQueued(int phase, T annotatedElement, BodySetter bodySetter,
		extension TransformationContext context)

}

/**
 * Class which is able to control annotation processing.
 */
class ProcessQueue {

	static public final int PHASES = 7

	static public final int PHASE_EXTENSION_REDIRECTION = 0

	static public final int PHASE_AUTO_ADAPT = 1

	static public final int PHASE_EXTRACT_INTERFACE = 2

	static public final int PHASE_TRAIT_CLASS = 3

	static public final int PHASE_EXTENDED_BY = 4

	static public final int PHASE_AUTO_ADAPT_CHECK = 5

	static public final int PHASE_IMPLEMENT_DEFAULT = 6

	/**
	 * Storage class for pending transformations.
	 */
	static protected class Transformation {

		QueuedTransformationParticipant<MutableAnnotationTarget> processor
		MutableAnnotationTarget annotatedElement
		String registeredName
		extension TransformationContext context

	}

	static protected var List<Map<CompilationUnit, List<String>>> PHASE_TRACKER_TRANSFORMATION = null
	static protected var List<Map<CompilationUnit, List<Transformation>>> PHASE_PENDING_TRANSFORMATION = null

	static protected val bodySetter = new BodySetter

	/**
	 * Static initializers are not available in xtend. This is a workaround method.
	 */
	static protected def void init() {

		PHASE_TRACKER_TRANSFORMATION = new ArrayList<Map<CompilationUnit, List<String>>>(PHASES)
		PHASE_PENDING_TRANSFORMATION = new ArrayList<Map<CompilationUnit, List<Transformation>>>(PHASES)
		for (i : 1 .. PHASES) {
			PHASE_TRACKER_TRANSFORMATION.add(new HashMap<CompilationUnit, List<String>>)
			PHASE_PENDING_TRANSFORMATION.add(new HashMap<CompilationUnit, List<Transformation>>)
		}

	}

	/**
	 * This method must be called if transformation process of given element is registered,
	 * but has not been finished, yet.
	 */
	static def void startTrack(int phase, ClassDeclaration annotatedClass, String registeredName) {

		// ensure that collections are constructed (static initializers are not available)
		if (PHASE_TRACKER_TRANSFORMATION === null)
			init()

		var Map<CompilationUnit, List<String>> mapCompilationUnit
		var List<String> setElement

		mapCompilationUnit = PHASE_TRACKER_TRANSFORMATION.get(phase)
		setElement = mapCompilationUnit.get(annotatedClass.compilationUnit)
		if (setElement === null) {
			setElement = new ArrayList<String>
			mapCompilationUnit.put(annotatedClass.compilationUnit, setElement)
		}

		// add qualified name to name set
		setElement.add(registeredName)

		LogUtils.log(
			Severity.
				INFO, '''Transformation tracking started (Phase: «phase») for «annotatedClass.qualifiedName» => [«registeredName»]''')

	}

	/**
	 * Must be called if transformation process of given element has finished.
	 */
	static protected def void stopTrackTransformation(int phase, AnnotationTarget annotatedElement,
		String registeredName) {

		// will happen in case of errors (e.g. duplicate class names)
		if (PHASE_TRACKER_TRANSFORMATION.get(phase).get(annotatedElement.compilationUnit) === null)
			return;

		// remove qualified name from name set
		PHASE_TRACKER_TRANSFORMATION.get(phase).get(annotatedElement.compilationUnit).remove(registeredName)

		// remove whole compilation unit, if nothing is left
		if (PHASE_TRACKER_TRANSFORMATION.get(phase).get(annotatedElement.compilationUnit).size == 0)
			PHASE_TRACKER_TRANSFORMATION.get(phase).remove(annotatedElement.compilationUnit)

	}

	/**
	 * This method is called for performing a transformation. Thereby, it handles all queuing and it also postpones the
	 * transformation, if it is currently not possible.
	 */
	static def void processTransformation(int phase, QueuedTransformationParticipant<?> processor,
		MutableAnnotationTarget annotatedElement, String registeredName, TransformationContext context) {

		// queue transformation and process afterwards
		queueTransformation(phase, processor, annotatedElement, registeredName, context)
		processPendingTransformations(annotatedElement.compilationUnit, context)

	}

	/**
	 * Process pending transformations (all allowed ones).
	 */
	static protected def void processPendingTransformations(CompilationUnit compilationUnit,
		TransformationContext context) {

		var boolean transformationPerformed
		do {

			transformationPerformed = false

			// go through all relevant phases
			for (var currentPhase = 0; currentPhase <= getMaxAllowedTransformationPhase(compilationUnit) &&
				!transformationPerformed; currentPhase++) {

				val mapCompilationUnit = PHASE_PENDING_TRANSFORMATION.get(currentPhase)
				val listTransformations = mapCompilationUnit.get(compilationUnit)
				if (listTransformations !== null) {

					// resume transformation
					var int currentTransformation = 0
					while (!transformationPerformed && listTransformations.size > currentTransformation) {

						val transformation = listTransformations.get(currentTransformation)

						try {

							LogUtils.log(
								Severity.
									INFO, '''Transformation starting (Phase: «currentPhase») for «IF transformation.annotatedElement instanceof TypeDeclaration»«(transformation.annotatedElement as TypeDeclaration).qualifiedName»«ELSE»«transformation.annotatedElement.simpleName» in «IF transformation.annotatedElement instanceof MemberDeclaration»«(transformation.annotatedElement as MemberDeclaration).declaringType.qualifiedName»«ENDIF»«ENDIF» => [«transformation.registeredName»] «compilationUnit.filePath»''')

							LogUtils.changeIndentation(1)
							try {

								// perform individual transformation and check, if it could be performed
								transformationPerformed = transformation.processor.doTransformQueued(currentPhase,
									transformation.annotatedElement, bodySetter, transformation.context)

							} finally {
								LogUtils.changeIndentation(-1)
							}

						} catch (Exception exception) {

							// catch exceptions and treat as performed
							transformationPerformed = true
							context.addError(transformation.annotatedElement,
								"Active annotation processor error during transformation in phase " + currentPhase +
									":\n\n" + StringUtils.getStackTrace(exception))

							LogUtils.log(
								Severity.
									INFO, '''Transformation error (Phase: «currentPhase») for «IF transformation.annotatedElement instanceof TypeDeclaration»«(transformation.annotatedElement as TypeDeclaration).qualifiedName»«ELSE»«transformation.annotatedElement.simpleName» in «IF transformation.annotatedElement instanceof MemberDeclaration»«(transformation.annotatedElement as MemberDeclaration).declaringType.qualifiedName»«ENDIF»«ENDIF» => [«transformation.registeredName»] «compilationUnit.filePath»:
										«StringUtils.getStackTrace(exception)»''')

						}

						if (transformationPerformed) {

							LogUtils.log(
								Severity.
									INFO, '''Transformation performed (Phase: «currentPhase») for «IF transformation.annotatedElement instanceof TypeDeclaration»«(transformation.annotatedElement as TypeDeclaration).qualifiedName»«ELSE»«transformation.annotatedElement.simpleName» in «IF transformation.annotatedElement instanceof MemberDeclaration»«(transformation.annotatedElement as MemberDeclaration).declaringType.qualifiedName»«ENDIF»«ENDIF» => [«transformation.registeredName»] «compilationUnit.filePath»''')

							// if transformation has been performed, stop tracking
							ProcessQueue.stopTrackTransformation(currentPhase, transformation.annotatedElement,
								transformation.registeredName)

							// remove transformation
							listTransformations.remove(currentTransformation)

						} else {

							LogUtils.log(
								Severity.
									INFO, '''Transformation was not performed (Phase: «currentPhase») for «IF transformation.annotatedElement instanceof TypeDeclaration»«(transformation.annotatedElement as TypeDeclaration).qualifiedName»«ELSE»«transformation.annotatedElement.simpleName» in «IF transformation.annotatedElement instanceof MemberDeclaration»«(transformation.annotatedElement as MemberDeclaration).declaringType.qualifiedName»«ENDIF»«ENDIF» => [«transformation.registeredName»] «compilationUnit.filePath»''')

							currentTransformation++

						}

					}

				}

			}

		} while (transformationPerformed)

		// flush method bodies
		bodySetter.flush

	}

	/**
	 * Returns if element with given qualified name is transformation tracked in
	 * the specified phase and compilation unit.
	 */
	static def boolean isTrackedTransformation(int phase, CompilationUnit compilationUnit,
		String qualifiedNameElement) {

		val setElement = PHASE_TRACKER_TRANSFORMATION.get(phase).get(compilationUnit)
		return (setElement !== null && setElement.contains(qualifiedNameElement))

	}

	/**
	 * Returns the highest transformation phase which is still allowed in given compilation unit.
	 */
	static protected def int getMaxAllowedTransformationPhase(CompilationUnit compilationUnit) {

		for (var checkPhase = 0; checkPhase < PHASES - 1; checkPhase++) {
			val setElement = PHASE_TRACKER_TRANSFORMATION.get(checkPhase).get(compilationUnit)
			if (setElement !== null && !setElement.isEmpty)
				return checkPhase
		}
		return PHASES - 1

	}

	/**
	 * This method will queue a transformation for a later point in time. Queued transformations
	 * will be called automatically as soon as all previously scheduled transformation are stopped.
	 */
	static protected def void queueTransformation(int phase, QueuedTransformationParticipant<?> processor,
		MutableAnnotationTarget annotatedElement, String registeredName, TransformationContext context) {

		// transformation must be stored
		// and added to list of pending transformations
		val transformation = new Transformation
		transformation.processor = processor as QueuedTransformationParticipant<MutableAnnotationTarget>
		transformation.annotatedElement = annotatedElement
		transformation.registeredName = registeredName
		transformation.context = context

		val mapCompilationUnit = PHASE_PENDING_TRANSFORMATION.get(phase)
		var listTransformations = mapCompilationUnit.get(annotatedElement.compilationUnit)
		if (listTransformations === null) {
			listTransformations = new ArrayList<Transformation>
			mapCompilationUnit.put(annotatedElement.compilationUnit, listTransformations)
		}

		listTransformations.add(transformation)

	}

}
