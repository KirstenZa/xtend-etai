package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeMatchingStrategy
import org.eclipse.xtend.lib.annotation.etai.utils.TypeMap
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.eclipse.xtend.lib.macro.services.TypeLookup
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.AbstractTraitMethodAnnotationProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ConstructorMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.EnvelopeMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.RequiredMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.TypeMap.*
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeErasureMethod

/**
 * <p>Marks trait classes.</p>
 * 
 * <p>A trait class can be used for extending another class by adding methods
 * from the trait class. The class will be extended by all trait methods of the 
 * trait class ({@link ExclusiveMethod}, {@link ProcessedMethod}, {@link EnvelopeMethod},
 * {@link RequiredMethod}).</p>
 * 
 * <p>A trait class will automatically get a mirror interface as if the {@link ExtractInterface}
 * annotation would be applied.</p>
 * 
 * <p>All methods specified by (additional) interfaces of the trait class (<code>implements</code>)
 * will be implemented automatically. These implemented methods will delegate calls to methods in classes
 * which will be extended by this trait class.</p>
 * 
 * <p>All public, non-static methods must be annotated by a trait method ({@link ExclusiveMethod},
 * {@link ProcessedMethod}, {@link EnvelopeMethod}, {@link RequiredMethod}) or an constructor 
 * method ({@link ConstructorMethod}). Because of the automatically generated mirror interface and 
 * the delegation mechanism described previously, they will be renamed to
 * <code>originalName$impl</code>.</p>
 * 
 * <p>In specific situations, e.g. a type check via <code>instanceof</code>,
 * the expression <code>$extendedThis</code> should be 
 * used inside the trait class instead of keyword <code>this</code>.</p>
 * 
 * @see ExtractInterface
 * @see ExtendedBy
 * @see ExclusiveMethod
 * @see ProcessedMethod
 * @see EnvelopeMethod
 * @see RequiredMethod
 */
@Target(ElementType.TYPE)
@Active(TraitClassProcessor)
annotation TraitClass {

	/**
	 * <p>This flag marks a trait class as base class. There are two major reasons
	 * for specifying a trait class as base class:</p>
	 * 
	 * <ul>
	 * <li>it cannot be used for extending another class
	 * <li>internal optimizations are possible (less methods, which are automatically implemented)
	 * </ul>
	 */
	boolean baseClass = false

	/**
	 * For extracting the interface, a name (rule) can be specified.
	 * 
	 * @see ExtractInterface
	 */
	String name = "#intf.I"

	/**
	 * <p>This setting can specify additional trait classes, which are additionally applied
	 * to a class, which shall be extended by the annotated trait classes. The specified trait 
	 * classes are "used" by this trait class and its methods can be used accordingly.</p>
	 * 
	 * <p>The automatically extracted interfaces of "used" trait
	 * classes must be added to the list of implemented interfaces of the annotated
	 * trait class.</p>
	 */
	Class<?> [] using = #[]

}

/**
 * <p>This annotation works like {@link TraitClass}.</p>
 * 
 * <p>However, "used" trait classes are found automatically by
 * analyzing the list of implemented interfaces. If a given interface
 * is the (extracted) mirror interface of a trait class {@link TraitClass},
 * this trait class will be "used".</p>
 * 
 * @see TraitClass
 */
@Target(ElementType.TYPE)
@Active(TraitClassAutoUsingProcessor)
annotation TraitClassAutoUsing {

	/**
	 * @see TraitClass#baseClass
	 */
	boolean baseClass = false

	/**
	 * For extracting the interface, a name (rule) can be specified.
	 * 
	 * @see ExtractInterface
	 */
	String name = "#intf.I"

}

/**
 * Annotation for a renamed trait method, which will get the body of the
 * originally implemented trait method, if available.
 */
@Target(ElementType.METHOD)
annotation TraitClassMethodImpl {
}

/**
 * This annotation is put onto methods within trait classes,
 * which have been generated for delegation purpose. Each of those
 * methods will call the same method within the extended class, which
 * might result in a call of the method implementation within the
 * trait class again.
 * 
 * @see TraitClassMethodImpl
 */
@Target(ElementType.METHOD)
annotation TraitClassDelegationMethod {
}

/**
 * This annotation is put onto methods within trait classes,
 * which have been generated for calling the extended method. Usually,
 * when programming the envelope method, a call to this method
 * is expected.
 */
@Target(ElementType.METHOD)
annotation TraitClassExtendedCallHelperMethod {
}

/**
 * This annotation is put onto constructors within trait classes,
 * which have been generated for delegation purpose. Each of
 * those constructors will call a constructor method.
 */
@Target(ElementType.CONSTRUCTOR)
annotation TraitClassDelegationConstructor {
}

/**
 * Active Annotation Processor for {@link TraitClass}
 * 
 * @see TraitClass
 */
class TraitClassProcessor extends ExtractInterfaceProcessor implements QueuedTransformationParticipant<MutableClassDeclaration> {

	final static public String EXTENDED_THIS_FIELD_NAME = "$extendedThis$data"
	final static public String EXTENDED_THIS_METHOD_NAME = "$extendedThis"

	final static public String TRAIT_METHOD_IMPL_NAME_SUFFIX = "$impl"
	final static public String EXTENDED_METHOD_CALL_NAME_SUFFIX = "$extended"

	final static public Set<String> TRAIT_CLASS_TO_BE_PROCESSED = new HashSet<String>

	protected override Class<?> getProcessedAnnotationType() {
		TraitClass
	}

	/**
	 * <p>Retrieves the trait classes directly specified for "usage" in the given (trait) class.</p>
	 * 
	 * <p>A trait classes is specified by putting its interface to the list of implemented
	 * interfaces (<code>implements</code>).</p>
	 * 
	 * @see #getTraitClassesDirectlyUsedByTraitClassClosure
	 * @see #getTraitClassesUsedByTraitClassClosure
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> List<TypeReference> getTraitClassesDirectlyUsedByTraitClass(
		ClassDeclaration traitClass, List<String> errorsDirectSpecification, extension T context) {

		if (traitClass === null || !traitClass.isTraitClass)
			return new ArrayList<TypeReference>

		var List<TypeReference> typeReferences = new ArrayList<TypeReference>()

		// retrieve explicitly specified trait classes
		var List<String> specifiedTraitClassesNames = null
		if (!traitClass.isTraitClassAutoUsing) {

			specifiedTraitClassesNames = new ArrayList<String>

			val specifiedTraitClasses = traitClass.getAnnotation(TraitClass).getClassArrayValue("using")

			// add names of trait classes
			for (specifiedTraitClass : specifiedTraitClasses) {

				if (specifiedTraitClass.type instanceof ClassDeclaration &&
					(specifiedTraitClass.type as ClassDeclaration).isTraitClass)
					specifiedTraitClassesNames.add(specifiedTraitClass.name)
				else
					errorsDirectSpecification?.
						add('''Type "«specifiedTraitClass.name»" is not a trait class, i.e. it does not use @TraitClass or @TraitClassAutoUsing''')

			}

		}

		// add type references based on used interfaces
		addTraitClassesOfMirrorInterfaces(traitClass, errorsDirectSpecification, typeReferences,
			specifiedTraitClassesNames, context)

		// report error, if there are specified "used" trait classes, which are not specified as implemented interface
		if (errorsDirectSpecification !== null && specifiedTraitClassesNames !== null)
			if (specifiedTraitClassesNames.size > 0)
				errorsDirectSpecification?.
					add('''Trait class "«specifiedTraitClassesNames.get(0)»" specified as "used", but not found in list of implemented interfaces''')

		return typeReferences

	}

	/**
	 * <p>Retrieves the trait classes directly specified for "usage" in the given trait class and parent classes.</p>
	 * 
	 * <p>A trait classes is specified by putting its interface to the list of implemented
	 * interfaces (<code>implements</code>).</p>
	 * 
	 * <p>If duplicates shall be removed, {@link ProcessUtils#unifyTypeReferences} must be called afterwards.</p>
	 * 
	 * @see #getTraitClassesDirectlyUsedByTraitClass
	 * @see ProcessUtils#unifyTypeReferences
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> List<TypeReference> getTraitClassesDirectlyUsedByTraitClassClosure(
		ClassDeclaration traitClass, List<String> errorsDirectSpecification, extension T context) {

		val result = new ArrayList<TypeReference>
		for (currentClass : traitClass.getSuperClasses(true))
			result += currentClass.getTraitClassesDirectlyUsedByTraitClass(errorsDirectSpecification, context)
		return result

	}

	/** 
	 * <p>Retrieves the trait classes specified for "usage" in the given trait class and parent classes.</p>
	 * 
	 * <p>A trait classes is specified by putting its interface to the list of implemented
	 * interfaces (<code>implements</code>).</p>
	 * 
	 * <p>This method includes indirectly specified trait classes, i.e. they are specified by directly
	 * specified trait classes.</p>
	 * 
	 * <p>For a class which is extended by the given trait class it will be ensured that it is
	 * also extended by the trait classes returned by this method.</p>
	 * 
	 * <p>The method will not return duplicates, i.e. later occurrences of the same trait class will be dropped.
	 * This is also done in order to protect from recursions caused by programming errors.</p>
	 * 
	 * @see #getTraitClassesDirectlyUsedByTraitClass
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> List<TypeReference> getTraitClassesUsedByTraitClassClosure(
		ClassDeclaration traitClass,
		List<String> errors,
		extension T context
	) {

		val result = new ArrayList<TypeReference>

		// include filter, which ensures that classes in own type hierarchy are not returned,
		// which is valid for more complex scenarios
		getTraitClassesUsedByTraitClassClosureInternal(traitClass, result, errors, traitClass.getSuperClasses(true),
			context)

		return result

	}

	/**
	 * Internal method for retrieving list of (directly and indirectly) for "usage" specified trait classes.
	 */
	private static def <T extends TypeLookup & TypeReferenceProvider> void getTraitClassesUsedByTraitClassClosureInternal(
		ClassDeclaration traitClass,
		List<TypeReference> result,
		List<String> errors,
		List<ClassDeclaration> noFollow,
		extension T context
	) {

		// retrieve directly used trait classes (closure)
		val directlyUsedTraitClasses = traitClass.getTraitClassesDirectlyUsedByTraitClassClosure(null, context)

		val validDirectlyAppliedTraitClasses = new ArrayList<ClassDeclaration>

		// filter for valid classes
		for (directlyUsedTraitClass : directlyUsedTraitClasses) {

			val directlyUsedTraitClassType = directlyUsedTraitClass.type as ClassDeclaration

			// check if class is valid and shall be added to the result
			if (directlyUsedTraitClassType !== null && !noFollow.contains(directlyUsedTraitClassType)) {

				validDirectlyAppliedTraitClasses.add(directlyUsedTraitClassType)

				// add to the end of the result, also if already contained
				val indexOfFoundUsed = result.map[type].indexOf(directlyUsedTraitClass.type)
				if (indexOfFoundUsed != -1)
					result.remove(indexOfFoundUsed)
				result += directlyUsedTraitClass

			}

		}

		// continue recursion
		for (validDirectlyAppliedTraitClass : validDirectlyAppliedTraitClasses) {

			// protect from recursion
			noFollow.add(validDirectlyAppliedTraitClass)

			try {

				// do not process current trait class any more (might be circular relationship)
				validDirectlyAppliedTraitClass.
					getTraitClassesUsedByTraitClassClosureInternal(result, errors, noFollow, context)

			} finally {

				noFollow.remove(noFollow.length - 1)

			}

		}

	}

	/**
	 * Check if class is a trait class.
	 */
	static def boolean isTraitClass(ClassDeclaration annotatedClass) {
		annotatedClass.hasAnnotation(TraitClass) || annotatedClass.isTraitClassAutoUsing
	}

	/**
	 * Returns true, if the class is annotated by {@link TraitClassAutoUsing}.
	 * 
	 * @see TraitClassAutoUsing
	 */
	static def boolean isTraitClassAutoUsing(ClassDeclaration annotatedClass) {
		return annotatedClass.hasAnnotation(TraitClassAutoUsing)
	}

	/**
	 * Check if trait class is a base class.
	 */
	static def isTraitBaseClass(ClassDeclaration annotatedClass) {

		// retrieve data from annotation	 	
		var annotationTraitClass = annotatedClass.getAnnotation(TraitClass)
		if (annotationTraitClass === null)
			annotationTraitClass = annotatedClass.getAnnotation(TraitClassAutoUsing)
		if (annotationTraitClass === null)
			throw new IllegalArgumentException('''Class «annotatedClass.qualifiedName» is not a trait class, so checking attributes is not possible''')

		return annotationTraitClass.getBooleanValue("baseClass")

	}

	/**
	 * Returns <code>true</code>, if the trait class is still unprocessed.
	 * If it returns <code>true</code>, the type hierarchy is not complete, so checks must be
	 * processed specifically. 
	 */
	static def boolean isUnprocessedTraitClass(String annotatedClass) {

		if (TRAIT_CLASS_TO_BE_PROCESSED.contains(annotatedClass))
			return true

		return false

	}

	/**
	 * Returns the method name for the trait method (after renaming).
	 */
	static def getTraitMethodImplName(MethodDeclaration annotatedMethod) {
		annotatedMethod.simpleName + TRAIT_METHOD_IMPL_NAME_SUFFIX
	}

	/**
	 * Returns the method name for calling the extended method (inside envelope method).
	 */
	static def getExtendedMethodCallName(MethodDeclaration annotatedMethod) {
		annotatedMethod.simpleName + EXTENDED_METHOD_CALL_NAME_SUFFIX
	}

	/**
	 * Returns if trait class contains trait class constructor methods.
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> hasConstructorMethod(
		ClassDeclaration annotatedClass,
		extension T context
	) {

		return annotatedClass.getConstructorMethods(context).size > 0;

	}

	/**
	 * Returns all trait class constructor methods.
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> getConstructorMethods(
		ClassDeclaration annotatedClass,
		extension T context
	) {

		val result = new ArrayList<MethodDeclaration>
		for (constructorMethod : annotatedClass.getDeclaredMethodsResolved(true, false, false, context))
			if (constructorMethod.isConstructorMethod)
				result += constructorMethod
		return result;

	}

	/**
	 * Returns if trait class contains trait class constructors, which are not empty.
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> hasNonEmptyConstructorMethod(
		ClassDeclaration annotatedClass,
		extension T context
	) {

		for (constructorMethod : annotatedClass.getDeclaredMethodsResolved(true, false, false, context))
			if (constructorMethod.isConstructorMethod && constructorMethod.parameters.size > 0)
				return true;
		return false;

	}

	/**
	 * Returns the trait methods from the specified trait class (using not considered).
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<MethodDeclaration> getTraitMethodClosure(
		ClassDeclaration traitClass, TypeMap typeMap, extension T context) {

		return traitClass.getMethodClosure(null, [
			false
		], true, false, false, true, context).filter [
			it.isTraitMethod
		].unifyMethodDeclarations(TypeMatchingStrategy.MATCH_INHERITANCE_CONSTRUCTOR_METHOD,
			TypeMatchingStrategy.MATCH_INHERITANCE, covariantReturnType.curry(context), false, typeMap, context)

	}

	override void doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {

		super.doRegisterGlobals(annotatedClass, context)

		// track if class (and interface) has already been processed,
		// i.e. the type hierarchy has been set correctly and methods have been generated
		TRAIT_CLASS_TO_BE_PROCESSED.add(annotatedClass.qualifiedName)

		// start processing of this element
		ProcessQueue.startTrack(ProcessQueue.PHASE_TRAIT_CLASS, annotatedClass, annotatedClass.qualifiedName)

	}

	override void doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		// process mirror interface (apply @ExtractInterface)
		annotatedClass.addAnnotation(ExtractInterface.newAnnotationReference)

		super.doTransform(annotatedClass, context)

		// queue processing
		ProcessQueue.processTransformation(ProcessQueue.PHASE_TRAIT_CLASS, this, annotatedClass,
			annotatedClass.qualifiedName, context)

	}

	override boolean doTransformQueued(int phase, MutableClassDeclaration annotatedClass, BodySetter bodySetter,
		extension TransformationContext context) {

		try {

			doTransformQueuedTraitClass(phase, annotatedClass, bodySetter, context)

		} finally {

			// stop tracking (hierarchy is complete now)
			TRAIT_CLASS_TO_BE_PROCESSED.remove(annotatedClass)

		}

		return true

	}

	def void doTransformQueuedTraitClass(int phase, MutableClassDeclaration annotatedClass, BodySetter bodySetter,
		extension TransformationContext context) {

		if (phase == ProcessQueue.PHASE_EXTRACT_INTERFACE) {

			super.doTransformQueued(phase, annotatedClass, bodySetter, context)
			return

		}

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// do not continue, if there is already an error
		if (xtendClass.problems.findFirst[it.severity == Severity.ERROR] !== null)
			return

		// retrieve mirror interface type reference
		val mirrorInterfaceName = annotatedClass.getMirrorInterfaceName
		val mirrorInterfaceType = findInterface(mirrorInterfaceName)
		val mirrorInterfaceTypeRef = mirrorInterfaceType.newTypeReference(annotatedClass.typeParameters.map [
			it.newSelfTypeReference
		])

		// consider non-abstract
		if (!annotatedClass.isTraitBaseClass)
			annotatedClass.abstract = false

		// create type map from type hierarchy
		val typeMap = new TypeMap
		fillTypeMapFromTypeHierarchy(annotatedClass, typeMap, context)

		// create additional fields and methods
		val extendedThisMethod = annotatedClass.addMethod(EXTENDED_THIS_METHOD_NAME) [

			static = false
			visibility = Visibility.PROTECTED
			returnType = mirrorInterfaceTypeRef

			// documentation
			docComment = '''The "extended this" method will return the reference to the extended object. This reference must be used instead of a regular "this" in specific cases (e.g. type checks with "instanceof").'''

		]
		if (xtendClass.extendedClass === null || xtendClass.extendedClass.type.qualifiedName == Object.canonicalName) {

			// create fields for delegation object
			annotatedClass.addField(EXTENDED_THIS_FIELD_NAME) [

				static = false
				visibility = Visibility.PRIVATE
				type = mirrorInterfaceTypeRef

				// documentation
				docComment = '''The "extended this" reference will hold the reference to the extended object. This reference must be used instead of a regular "this" in specific cases (e.g. type checks with "instanceof").'''

			]

			extendedThisMethod.body = '''return «EXTENDED_THIS_FIELD_NAME»;''';

		} else {

			extendedThisMethod.body = '''return («mirrorInterfaceTypeRef.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false,context)») super.«EXTENDED_THIS_METHOD_NAME»();''';

		}

		// retrieve all envelop method in trait class hierarchy
		val envelopeMethods = annotatedClass.getTraitMethodClosure(typeMap, context).filter [
			it.isEnvelopeMethod
		]

		// generate helper method for envelope method in order to call method in extended class
		for (envelopeMethod : envelopeMethods) {

			// retrieve envelope information
			val envelopeInfo = envelopeMethod.getEnvelopeMethodInfo(context)

			// create new method which is able to call the functionality of extended class
			// inside of envelope method
			val newMethod = annotatedClass.copyMethod(envelopeMethod, true, false, false, false, false, false, typeMap,
				context)

			// rename method and set private
			newMethod.simpleName = envelopeMethod.getExtendedMethodCallName
			newMethod.visibility = Visibility.PROTECTED

			// create parameter name and type name list
			val paramNameList = envelopeMethod.parametersNames
			val paramTypeNameList = envelopeMethod.getParametersTypeNames(TypeErasureMethod.REMOVE_GENERICS, false,
				context)

			// documentation
			newMethod.docComment = '''This is a helper method for calling «envelopeMethod.getJavaDocLinkTo(context)» of extended class.'''

			// specify annotation
			newMethod.addAnnotation(TraitClassExtendedCallHelperMethod.newAnnotationReference)

			// create body
			val isVoid = newMethod.returnType === null || newMethod.returnType.isVoid()
			val defaultValueProviderObj = if (envelopeInfo.defaultValueProvider.qualifiedName != Object.canonicalName)
					"new " + envelopeInfo.defaultValueProvider.qualifiedName + "()"
				else
					"null"

			bodySetter.setBody(
				newMethod, '''«IF !isVoid»return («newMethod.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false,context)»)«ENDIF»
						org.eclipse.xtend.lib.annotation.etai.utils.ReflectUtils.callExtendedMethod(«EXTENDED_THIS_METHOD_NAME»(), "«envelopeMethod.getExtendedMethodImplName(annotatedClass)»",
						«defaultValueProviderObj»,
						«isVoid»,
						new Class<?> [] { «paramTypeNameList.map[it + ".class"] .join(", ")» },
						new Object [] { «paramNameList.join(", ")» });''', context)

		}

		// go through all trait methods and constructors of trait class
		for (method : annotatedClass.getDeclaredMethodsResolved(true, false, false, context)) {

			if (method.isTraitMethod) {

				// rename if the method does not have implementation policy "required",
				// because if "required" the method is abstract and does not need renaming
				if (!method.isRequiredMethod) {

					// copying the body to a new method instead of real renaming avoids
					// some problems with "override" and warnings
					// (original method will be reused by delegation mechanism)
					val implMethod = annotatedClass.copyMethod(method, true, false, false, false, false, false, typeMap,
						context)

					// set visibility
					implMethod.visibility = Visibility.PUBLIC

					// documentation
					implMethod.docComment = '''This is the trait class implementation of method «method.getJavaDocLinkTo(context)».'''

					// specify annotation
					implMethod.addAnnotation(TraitClassMethodImpl.newAnnotationReference)

					// rename new method and move body from trait method to new method
					implMethod.simpleName = method.traitMethodImplName

					// move body
					bodySetter.moveBody(implMethod, method, context)

				}

				if (!method.isEnvelopeMethod) {

					// search for method in hierarchy which is an envelope method
					var ExecutableDeclaration foundEnvelopeMethod = method
					while (foundEnvelopeMethod !== null && foundEnvelopeMethod instanceof MethodDeclaration &&
						!(foundEnvelopeMethod as MethodDeclaration).isEnvelopeMethod)
						foundEnvelopeMethod = getMatchingExecutableInClass(
							(foundEnvelopeMethod.declaringType as ClassDeclaration).extendedClass?.
								type as ClassDeclaration, foundEnvelopeMethod,
							TypeMatchingStrategy.MATCH_INHERITANCE_CONSTRUCTOR_METHOD,
							TypeMatchingStrategy.MATCH_INHERITANCE, true, false, true, false, false, typeMap, context)

					if (foundEnvelopeMethod !== null)
						xtendClass.
							addError('''Method "«method.getMethodAsString(false, context)»" has been annotated by @EnvelopeMethod in a super type, so also this type must be used here''')

				}

			}

		}

		for (constructorMethod : annotatedClass.getConstructorMethods(context)) {

			// generate dedicated constructor, which will call constructor method
			val newConstructor = annotatedClass.addConstructor [
				visibility = Visibility.PUBLIC
			]

			// add parameter to retrieve delegation reference
			newConstructor.addParameter(EXTENDED_THIS_FIELD_NAME, mirrorInterfaceTypeRef)

			// copy parameters
			val paramNameList = constructorMethod.parametersNames
			constructorMethod.copyParameters(newConstructor, 0, false, null, context)

			// documentation
			newConstructor.docComment = '''This constructor delegates to constructor method «constructorMethod.getJavaDocLinkTo(context)».'''

			// specific annotation for new constructor
			newConstructor.addAnnotation(TraitClassDelegationConstructor.newAnnotationReference)

			// rename new method and move body from trait method to new method
			bodySetter.setBody(newConstructor, '''this(«EXTENDED_THIS_FIELD_NAME», (org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.IConstructorParamDummySetExtendedThis) null);
							«constructorMethod.simpleName»(«paramNameList.join(", ")»);
						''', context)

		}

		// generate basic constructor, which will just get delegation object and will not handle other functionality
		val basicConstructor = annotatedClass.addConstructor [

			addParameter(EXTENDED_THIS_FIELD_NAME, mirrorInterfaceTypeRef)
			val dummyReference = ProcessUtils.IConstructorParamDummySetExtendedThis.newTypeReference
			val newDummyParameter = addParameter(ProcessUtils.IConstructorParamDummySetExtendedThis.DUMMY_VARIABLE_NAME,
				dummyReference)
			newDummyParameter.addSuppressWarningUnused(context)

			visibility = Visibility.PUBLIC

			docComment = '''This is the basic constructor for trait classes, which is called for each construction.'''

		]

		// add body to set delegation reference
		bodySetter.setBody(
			basicConstructor, '''«IF xtendClass.extendedClass !== null && xtendClass.extendedClass.type.qualifiedName != Object.canonicalName»super(«EXTENDED_THIS_FIELD_NAME», (org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.IConstructorParamDummySetExtendedThis) null);«ELSE»
					this.«EXTENDED_THIS_FIELD_NAME» = «EXTENDED_THIS_FIELD_NAME»;«ENDIF»''', context)

		// specific annotation for new constructor
		basicConstructor.addAnnotation(TraitClassDelegationConstructor.newAnnotationReference)

		// track methods which will require delegates
		var List<MethodDeclaration> delegationMethodBlueprints = new ArrayList<MethodDeclaration>

		// a delegate must be generated for all methods in interfaces
		for (superType : annotatedClass.getSuperTypeClosure(null, null, false, context))
			if (superType instanceof InterfaceDeclaration)
				delegationMethodBlueprints.addAll(superType.getDeclaredMethodsResolved(true, false, false, context))

		// a delegate must also be generated for each method found in trait class hierarchy (including "using")
		delegationMethodBlueprints.addAll(annotatedClass.getTraitMethodClosure(typeMap, context))
		for (traitClass : annotatedClass.getTraitClassesUsedByTraitClassClosure(null, context))
			delegationMethodBlueprints.addAll(
				(traitClass.type as ClassDeclaration).getTraitMethodClosure(typeMap, context))

		// unify delegate methods
		delegationMethodBlueprints = delegationMethodBlueprints.unifyMethodDeclarations(
			TypeMatchingStrategy.MATCH_INHERITANCE_CONSTRUCTOR_METHOD, TypeMatchingStrategy.MATCH_INHERITANCE,
			covariantReturnType.curry(context), false, typeMap, context)

		// go through all methods, which require delegation
		for (delegationMethodBlueprint : delegationMethodBlueprints) {

			// use already existing method as "new method" in the following algorithm
			// (this avoids some problems with "override" and warnings)
			val MutableMethodDeclaration existingMethod = annotatedClass.getDeclaredMethodsResolved(
				true,
				false,
				false,
				context
			).getMatchingMethod(
				delegationMethodBlueprint,
				TypeMatchingStrategy.MATCH_INVARIANT,
				TypeMatchingStrategy.MATCH_ALL,
				false,
				typeMap,
				context
			) as MutableMethodDeclaration

			val delegationMethod = if (existingMethod !== null)
					existingMethod
				else
					annotatedClass.copyMethod(delegationMethodBlueprint, true, false, false, false, false, false,
						typeMap, context)

			// delegation method must not be abstract
			delegationMethod.abstract = false

			// mark as overridden, if original method is marked (and not a specific case, e.g. a protected method copied from a used trait class)
			if (!delegationMethod.hasAnnotation(Override) &&
				(delegationMethodBlueprint.declaringType != annotatedClass &&
					delegationMethodBlueprint.hasAnnotation(Override) &&
					delegationMethodBlueprint.visibility == Visibility.PUBLIC))
				delegationMethod.addAnnotation(Override.newAnnotationReference)

			// add annotation (this is a delegation method)	
			delegationMethod.addAnnotation(TraitClassDelegationMethod.newAnnotationReference)

			// add annotation (this method shall not stop type adaption)
			if ((existingMethod === null || (existingMethod !== null && existingMethod.hasAnnotation(AdaptedMethod))) &&
				!delegationMethod.hasAnnotation(AdaptedMethod))
				delegationMethod.addAnnotation(AdaptedMethod.newAnnotationReference)

			// generate method body, which calls method of extended class
			val methodFinal = delegationMethod
			val isVoid = delegationMethod.returnType === null || delegationMethod.returnType.isVoid()

			// create parameters name list
			val paramNameList = delegationMethodBlueprint.parametersNames

			// create parameters type name list
			val paramTypeNameList = delegationMethodBlueprint.getParametersTypeNames(TypeErasureMethod.REMOVE_GENERICS,
				false, context)

			// do not delegate, but call original target, if called via "super"
			val callSuperTargetCode = '''if (this.getClass() != «annotatedClass.qualifiedName».class)
						try {
							«IF !isVoid»return («methodFinal.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false,false, context)») «ENDIF»java.lang.invoke.MethodHandles.lookup().unreflectSpecial(org.eclipse.xtend.lib.annotation.etai.utils.ReflectUtils.getPrivateMethodExactMatch(
								«annotatedClass.qualifiedName».class,
								"«delegationMethod.traitMethodImplName»",
									new Class<?> [] { «paramTypeNameList.map[it + ".class"] .join(", ")» }),
								«annotatedClass.qualifiedName».class
								).invoke(
									this«IF paramNameList.size > 0»,«ENDIF»
									«paramNameList.join(", ")»
								);
						} catch (java.lang.Throwable _e) {
							throw org.eclipse.xtext.xbase.lib.Exceptions.sneakyThrow(_e);
						}
					else
						'''

			// body depends on visibility
			if (delegationMethodBlueprint.visibility == Visibility.PUBLIC) {

				// cast is necessary to support covariance
				val delegateCasted = '''(«EXTENDED_THIS_METHOD_NAME»())'''

				// method is accessible
				bodySetter.setBody(
					delegationMethod, '''«callSuperTargetCode»«IF !isVoid»return («methodFinal.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false,false, context)») «ENDIF» «delegateCasted».«delegationMethodBlueprint.simpleName»(«paramNameList.join(", ")»);''',
					context)

			} else {

				bodySetter.setBody(
					delegationMethod, '''«callSuperTargetCode»«IF !isVoid»return («methodFinal.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false,false, context)»)«ENDIF»
						org.eclipse.xtend.lib.annotation.etai.utils.ReflectUtils.callExtendedMethod(«EXTENDED_THIS_METHOD_NAME»(),"«methodFinal.simpleName»",
						null,
						«isVoid»,
						new Class<?> [] { «paramTypeNameList.map[it + ".class"] .join(", ")» },
						new Object [] { «paramNameList.join(", ")» });''', context)

			}

		}

	}

	override void doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// return because there is a general type problem
		if (xtendClass.extendedClass !== null && !(xtendClass.extendedClass.type instanceof ClassDeclaration))
			return;

		// check that only one annotation of the same class is applied
		if (getProcessedAnnotationType() === TraitClassAutoUsing && annotatedClass.hasAnnotation(TraitClass))
			xtendClass.addError('''Cannot apply both @TraitClass and @TraitClassAutoUsing''')

		// parent class of trait class must also be trait class
		if (xtendClass.extendedClass !== null && !(xtendClass.extendedClass.type as ClassDeclaration).isTraitClass &&
			xtendClass.extendedClass.type.qualifiedName != Object.canonicalName)
			xtendClass.addError('''Parent class of trait class must also be a trait class''')

		// trait class must not be abstract
		if (!xtendClass.abstract)
			xtendClass.addError('''Trait class must be declared abstract''')

		// must not specify constructors
		if (xtendClass.declaredConstructors.size > 0)
			xtendClass.declaredConstructors.get(0).addError(
				'''Trait class must not specify any constructor (use @ConstructorMethod)''')

		// go through fields
		for (field : xtendClass.declaredFields) {

			// fields with automatically generated getter/setter must specify trait method annotation
			if ((field.hasAnnotation(GetterRule) || field.hasAnnotation(SetterRule) || field.hasAnnotation(AdderRule) ||
				field.hasAnnotation(RemoverRule)) && field.isTraitMethod == false && field.isStatic == false)
				field.
					addError('''Within a trait class non-static getter/setter/adder/remover methods must be trait methods''')

		}

		// go through trait methods
		for (method : xtendClass.getDeclaredMethodsResolved(true, false, false, context)) {

			// method must have a valid name (some mechanism depend on naming of methods)
			if (method.simpleName.contains("$"))
				method.addError('''Trait method has an invalid name (symbol '$' must not be used)''')

			if (method.isTraitMethod == false) {

				// all non-static methods must be trait methods
				if (method.static == false && method.visibility != Visibility.PRIVATE)
					if (!method.isConstructorMethod)
						method.
							addError('''Within a trait class a non-static, non-private method in a trait class must be a trait method''')

			}

		}

		// check directly used trait classes
		val errors = new ArrayList<String>
		val directlyUsedTraitClassesRefs = annotatedClass.getTraitClassesDirectlyUsedByTraitClass(errors, context)
		if (xtendClass.reportErrors(errors, context))
			return;

		val superTypesThis = annotatedClass.getSuperClasses(true)
		if (directlyUsedTraitClassesRefs !== null)
			for (directlyUsedTraitClassRefs : directlyUsedTraitClassesRefs) {

				// check if used types are valid trait classes
				val directlyUsedTraitClass = directlyUsedTraitClassRefs.type as ClassDeclaration

				val superTypesUsed = directlyUsedTraitClass.getSuperClasses(true)

				// check type hierarchy
				if (superTypesThis.contains(directlyUsedTraitClass))
					xtendClass.
						addError('''Cannot apply trait class «directlyUsedTraitClass.simpleName» because it is in own type hierarchy''')
				else if (superTypesUsed.contains(annotatedClass))
					xtendClass.
						addError('''Cannot apply trait class «directlyUsedTraitClass.simpleName» because it is a derived class from this class''')
				else {

					val superTypesWithoutThis = annotatedClass.getSuperClasses(false)
					var boolean foundError = false
					for (superType : superTypesWithoutThis) {

						if (!foundError && superType.isTraitClass && superTypesUsed.contains(superType)) {
							xtendClass.
								addError('''Cannot apply trait class «directlyUsedTraitClass.simpleName» because they have a common base (trait) class «superType.simpleName»''')
							foundError = true
						}

					}

				}

			}

	}

}

/**
 * Active Annotation Processor for {@link TraitClassAutoUsingProcessor}
 * 
 * @see TraitClassAutoUsing
 */
class TraitClassAutoUsingProcessor extends TraitClassProcessor {

	protected override getProcessedAnnotationType() {
		TraitClassAutoUsing
	}

}
