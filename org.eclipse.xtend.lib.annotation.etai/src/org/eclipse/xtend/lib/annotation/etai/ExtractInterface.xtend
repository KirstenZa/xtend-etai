package org.eclipse.xtend.lib.annotation.etai

import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeMatchingStrategy
import org.eclipse.xtend.lib.annotation.etai.utils.TypeMap
import org.eclipse.xtend.lib.annotation.etai.utils.TypeUtils
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.Set
import java.util.regex.Pattern
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableInterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.services.TypeLookup
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.TypeMap.*

/**
 * Extracts an interface (called mirror interface) for all locally declared public methods.
 * 
 * @see NoInterfaceExtract
 */
@Target(ElementType.TYPE)
@Active(ExtractInterfaceProcessor)
annotation ExtractInterface {

	/**
	 * <p>For extracting the interface, a name (rule) can be specified. In general, there are
	 * three ways for specifying the name: as a qualified name, as a relative prefix and as an absolute
	 * prefix.</p>
	 * 
	 * <p>If the specified name does not contain any special character, it is considered
	 * as the fully qualified name of the interface, which shall be extracted.</p>
	 * 
	 * <p>If the specified name starts with a <code>#</code> symbol, it contains a relative prefix.
	 * For example, if the relative prefix is set to <code>subpack.I</code> for a class <code>mainpack.Foo</code>,
	 * the interface will be generated in a package called <code>mainpack.subpack</code> and the interface's name
	 * will be <code>IFoo</code>. If the class is an inner class, the extracted interface will be
	 * in the same enclosing class.</p>
	 * 
	 * <p>If the specified name starts with a <code>@</code> symbol, it contains an absolute prefix.
	 * For example, if the absolute prefix is set to <code>apack.I</code> for a class <code>mainpack.Foo</code>,
	 * the interface will be generated in a package called <code>apack</code> and the interface's name
	 * will be <code>IFoo</code>.</p>
	 */
	String name = "#intf.I"

}

/**
 * A method can get this annotation in order to get not extracted to an interface.
 * 
 * @see ExtractInterface
 */
@Target(ElementType.METHOD)
annotation NoInterfaceExtract {
}

/**
 * Annotation for an interface, which has been extracted and generated from a class.
 * 
 * @see ExtractInterface
 */
@Target(ElementType.TYPE)
annotation ExtractedInterface {

	/**
	 * Stores the class the interface has been extracted from
	 */
	Class<?> extractedClass

}

/**
 * Active Annotation Processor for {@link ExtractInterface}
 * 
 * @see ExtractInterface
 */
class ExtractInterfaceProcessor extends AbstractClassProcessor implements QueuedTransformationParticipant<MutableClassDeclaration> {

	final static public Map<String, ClassDeclaration> MIRROR_INTERFACE_TO_BE_PROCESSED = new HashMap<String, ClassDeclaration>
	final static public Set<String> EXTRACT_INTERFACE_TO_BE_PROCESSED = new HashSet<String>
	final static public Map<String, String> CACHED_EXTRACTED_INTERFACE_NAMES = new HashMap<String, String>

	protected override Class<?> getProcessedAnnotationType() {
		ExtractInterface
	}

	/**
	 * Returns <code>true</code>, if the interface extracted by {@link ExtractInterface} is still unprocessed.
	 * If it returns <code>true</code>, the type hierarchy is not complete, so type checks must be
	 * processed specifically. 
	 */
	static def boolean isUnprocessedMirrorInterface(String interfaceName) {

		if (MIRROR_INTERFACE_TO_BE_PROCESSED.containsKey(interfaceName))
			return true

		return false

	}

	/**
	 * Returns <code>true</code>, if the class annotated by {@link ExtractInterface} is still unprocessed.
	 * If it returns <code>true</code>, the type hierarchy is not complete, so type checks must be
	 * processed specifically. 
	 */
	static def boolean isUnprocessedClassExtraction(String className) {

		if (EXTRACT_INTERFACE_TO_BE_PROCESSED.contains(className))
			return true

		return false

	}

	/**
	 * Returns the trait class for a given mirror interface.
	 * 
	 * It will return <code>null</code>, if this is not the mirror interface for a trait class.
	 */
	static def ClassDeclaration getTraitClassForMirrorInterface(InterfaceDeclaration interfaceDeclaration) {

		if (interfaceDeclaration.qualifiedName.isUnprocessedMirrorInterface) {

			val classDeclaration = interfaceDeclaration.qualifiedName.getClassOfUnprocessedMirrorInterface()
			if (classDeclaration.isTraitClass)
				return classDeclaration

		} else {

			if (interfaceDeclaration.hasAnnotation(ExtractedInterface)) {
				val classDeclaration = interfaceDeclaration.getClassOfProcessedMirrorInterface()
				if (classDeclaration.isTraitClass)
					return classDeclaration
			}

		}

		return null

	}

	/**
	 * Returns the corresponding class of the mirror interface (which must have been processed already).
	 */
	static def ClassDeclaration getClassOfProcessedMirrorInterface(InterfaceDeclaration interfaceDeclaration) {

		val extractInterfaceAnnotation = interfaceDeclaration.getAnnotation(ExtractedInterface)
		val extractedClass = extractInterfaceAnnotation.getClassValue("extractedClass")
		return extractedClass.type as ClassDeclaration

	}

	/**
	 * Returns the class annotated by {@link ExtractInterface} which extracts the interface with the
	 * specified name. 
	 */
	static def ClassDeclaration getClassOfUnprocessedMirrorInterface(String interfaceName) {

		return MIRROR_INTERFACE_TO_BE_PROCESSED.get(interfaceName)

	}

	/**
	 * Returns the (qualified) mirror interface name for the annotated class.
	 * This method requires the class of the annotation which specifies the mirror interface prefix. 
	 */
	static def String getMirrorInterfaceName(ClassDeclaration annotatedClass) {

		// check for cached name
		val cachedName = CACHED_EXTRACTED_INTERFACE_NAMES.get(annotatedClass.qualifiedName)
		if (cachedName !== null)
			return cachedName

		// determine annotation, which shall be checked
		var extractInterfaceAnnotation = annotatedClass.getAnnotation(ExtractInterface)
		if (extractInterfaceAnnotation === null)
			extractInterfaceAnnotation = annotatedClass.getAnnotation(TraitClassAutoUsing)
		if (extractInterfaceAnnotation === null)
			extractInterfaceAnnotation = annotatedClass.getAnnotation(TraitClass)
		if (extractInterfaceAnnotation === null)
			return null

		var String result

		// retrieve prefix value
		var nameRule = extractInterfaceAnnotation.getStringValue("name")

		// prevent crashes
		if (nameRule.nullOrEmpty)
			nameRule = "#intf.I"

		// consider different name (rule) types
		if (nameRule.startsWith("#")) {

			nameRule = nameRule.substring(1, nameRule.length)

			// in inner classes the prefix must not contain package names
			if (annotatedClass.declaringType !== null)
				nameRule = nameRule.substring(nameRule.lastIndexOf('.') + 1)

			result = TypeUtils.removeSimpleNameFromQualifiedName(annotatedClass.qualifiedName) + nameRule +
				annotatedClass.simpleName

		} else if (nameRule.startsWith("@")) {

			nameRule = nameRule.substring(1, nameRule.length)

			result = nameRule + annotatedClass.simpleName

		} else {

			result = nameRule

		}

		// cache result
		CACHED_EXTRACTED_INTERFACE_NAMES.put(annotatedClass.qualifiedName, result)

		return result

	}

	/**
	 * Returns if given class has a mirror interface.
	 */
	static def boolean hasMirrorInterface(ClassDeclaration annotatedClass) {
		annotatedClass.hasAnnotation(ExtractInterface) || annotatedClass.isTraitClass
	}

	/**
	 * Filters out those methods which define the annotation,
	 * that specifies that the method shall not be extracted to an interface.
	 */
	static def withoutNoInterfaceExtract(Iterable<? extends MethodDeclaration> methods) {
		return methods.filter [
			!it.hasAnnotation(NoInterfaceExtract)
		]
	}

	/**
	 * @bug This method is necessary because there is no way to register a class / interface with
	 * type parameters, i.e. extract interface does not work together with type parameters, if
	 * there are cyclic dependencies and the classes are within one xtend file.
	 * (cp. Bug 491687 in Eclipse's Bugzilla.)
	 */
	def void addTypeParametersDuringRegistration(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {

		val typeLookup = context.class.getMethod("getTypeLookup").invoke(context) as TypeLookup
		val mirrorInterface = typeLookup.findInterface(
			annotatedClass.getMirrorInterfaceName) as MutableInterfaceDeclaration

		mirrorInterface.mutate [
			annotatedClass.cloneTypeParametersWithoutUpperBounds(mirrorInterface, null, null)
		]

	}

	/**
	 * Returns the methods of the annotated class, which should be extracted. The result can contain duplicates,
	 * which must be removed in a later step. 
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<MethodDeclaration> getMethodExtractionCandidates(
		ClassDeclaration annotatedClass, TypeMap typeMap, extension T context) {

		// collect methods which must be added to the mirror interface
		// (also methods from supertypes are considered, if they do not have an ExtractInterface annotation)
		val methods = annotatedClass.getMethodClosure([
			it.qualifiedName != Object.canonicalName && (it === annotatedClass || !it.hasAnnotation(ExtractInterface))
		], [false], true, context)

		val result = new ArrayList<MethodDeclaration>

		// filter for non-static, public methods, which do not have disabled extraction
		for (method : methods.filter [
			visibility == Visibility.PUBLIC && static == false && !hasAnnotation(NoInterfaceExtract)
		]) {
			result.add(method)
		}

		return result

	}

	/**
	 * <p>Adds the list of given methods to the given interface declaration.</p>
	 * 
	 * <p>The method does not add a method, if it is already available in the interface or
	 * through any super interface.</p>
	 */
	static def addMethodsToInterface(
		MutableInterfaceDeclaration interfaceDeclaration,
		Iterable<? extends MethodDeclaration> methods,
		TypeMap typeMap,
		extension TransformationContext context
	) {

		val interfaceMethods = interfaceDeclaration.getMethodClosure([true], false, context)

		for (method : methods) {

			// do only add, if there is no other method with same name, parameters and
			// return type in this interface or any super interface already
			if (!interfaceMethods.exists [
				it.methodEquals(method, TypeMatchingStrategy.MATCH_INVARIANT, typeMap, context)
			]) {

				val newMethod = interfaceDeclaration.addMethod(method.simpleName) [

					docComment = method.docComment

					// copy type parameter declarations and update type map
					method.cloneTypeParameters(it, typeMap, context)

					returnType = copyTypeReference(method.returnType, typeMap, context)
					exceptions = method.exceptions
					primarySourceElement = method

				]

				method.copyParameters(newMethod, 0, typeMap, context)

			}

		}

	}

	/**
	 * Returns all super interfaces of the interface extracted by the given class.
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<TypeReference> getMirrorInterfaceExtends(
		ClassDeclaration annotatedClass,
		TypeMap typeMap,
		extension T context
	) {

		val resultExtends = new ArrayList<TypeReference>

		// sum all interfaces of the annotated class
		val implementedInterfaces = new ArrayList<TypeReference>
		for (implementedInterface : annotatedClass.implementedInterfaces)
			implementedInterfaces.add(copyTypeReference(implementedInterface, typeMap, context))

		// mirror interface must extend extracted interface
		resultExtends.addAll(implementedInterfaces)

		// add interfaces of parent classes
		var currentParent = annotatedClass.extendedClass?.type as ClassDeclaration
		while (currentParent !== null) {

			if (currentParent.hasMirrorInterface) {

				// if parent class has mirror interface, implement this mirror interface and stop
				val relevantMirrorInterfaceName = currentParent.getMirrorInterfaceName
				resultExtends.addAll(
					#[
						findTypeGlobally(relevantMirrorInterfaceName).newTypeReference(annotatedClass.extendedClass.
							actualTypeArguments.map [
								copyTypeReference(it, typeMap, context)
							])])
				return resultExtends

			} else {

				// add all implemented interfaces of this parent class
				val implementedInterfacesOfParentClass = new ArrayList<TypeReference>
				for (implementedInterfaceOfParentClass : currentParent.implementedInterfaces)
					implementedInterfacesOfParentClass.add(
						copyTypeReference(implementedInterfaceOfParentClass, typeMap, context))

				// mirror interface must extend extracted interface
				resultExtends.addAll(implementedInterfacesOfParentClass)

			}

			currentParent = currentParent.extendedClass?.type as ClassDeclaration

		}

		return resultExtends

	}

	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {

		super.doRegisterGlobals(annotatedClass, context)

		val interfaceName = annotatedClass.getMirrorInterfaceName
		context.registerInterface(interfaceName)

		// workaround: add type parameters to registered interface
		addTypeParametersDuringRegistration(annotatedClass, context)

		// track if class (and interface) has already been processed, i.e. the type hierarchy has been set correctly
		MIRROR_INTERFACE_TO_BE_PROCESSED.put(interfaceName, annotatedClass)
		EXTRACT_INTERFACE_TO_BE_PROCESSED.add(annotatedClass.qualifiedName)

		// start processing of this element
		ProcessQueue.startTrack(ProcessQueue.PHASE_EXTRACT_INTERFACE, annotatedClass, interfaceName)

	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		super.doTransform(annotatedClass, context)

		// queue processing
		ProcessQueue.processTransformation(ProcessQueue.PHASE_EXTRACT_INTERFACE, this, annotatedClass,
			annotatedClass.getMirrorInterfaceName, context)

	}

	override boolean doTransformQueued(int phase, MutableClassDeclaration annotatedClass, BodySetter bodySetter,
		extension TransformationContext context) {

		val mirrorInterfaceName = annotatedClass.getMirrorInterfaceName
		if (mirrorInterfaceName === null || findTypeGlobally(mirrorInterfaceName) === null)
			return true

		try {

			doTransformQueuedExtractInterface(phase, mirrorInterfaceName, annotatedClass, bodySetter, context)

		} finally {

			// stop tracking (hierarchy is complete now)
			EXTRACT_INTERFACE_TO_BE_PROCESSED.remove(annotatedClass)
			MIRROR_INTERFACE_TO_BE_PROCESSED.remove(mirrorInterfaceName)

		}

		return true

	}

	def void doTransformQueuedExtractInterface(int phase, String interfaceName, MutableClassDeclaration annotatedClass,
		BodySetter bodySetter, extension TransformationContext context) {

		val mirrorInterfaceType = findInterface(interfaceName)

		mirrorInterfaceType.primarySourceElement = annotatedClass

		// create type map from type hierarchy
		val typeMap = new TypeMap
		fillTypeMapFromTypeHierarchy(annotatedClass, typeMap, context)

		// add type arguments as specified in class and map
		val typeParameterIterator = mirrorInterfaceType.typeParameters.iterator
		for (typeParameter : annotatedClass.typeParameters) {
			val newTypeParameter = typeParameterIterator.next
			typeMap.putClone(typeParameter, newTypeParameter.newTypeReference, context)
		}

		// specify annotation
		mirrorInterfaceType.addAnnotation(ExtractedInterface.newAnnotationReference [
			setClassValue("extractedClass", annotatedClass.newTypeReference)
		])

		// set interfaces which are extended by mirror interface
		mirrorInterfaceType.extendedInterfaces = getMirrorInterfaceExtends(annotatedClass, typeMap, context)

		// refine upper bound of type maps
		annotatedClass.cloneTypeParametersRefineUpperBounds(mirrorInterfaceType, typeMap, context)

		// add the mirror interface to the list of implemented interfaces
		val mirrorInterfaceTypeRef = mirrorInterfaceType.newTypeReference(annotatedClass.typeParameters.map [
			it.newSelfTypeReference
		])
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[mirrorInterfaceTypeRef]

		// collect methods which must be added to the mirror interface
		val methodsExtractionCandidates = getMethodExtractionCandidates(annotatedClass, typeMap, context)

		// add the public methods to the interface
		mirrorInterfaceType.addMethodsToInterface(
			methodsExtractionCandidates.unifyMethodDeclarations(TypeMatchingStrategy.MATCH_COVARIANT, null, typeMap,
				context), typeMap, context)

		// add documentation
		mirrorInterfaceType.docComment = (if (annotatedClass.docComment !== null)
			annotatedClass.docComment + "\n\n"
		else
			"") + '''Interface extracted from «annotatedClass.getJavaDocLinkTo(context)»'''

	}

	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// retrieve annotation
		var extractInterfaceAnnotation = annotatedClass.getAnnotation(ExtractInterface)
		if (extractInterfaceAnnotation === null)
			extractInterfaceAnnotation = annotatedClass.getAnnotation(TraitClassAutoUsing)
		if (extractInterfaceAnnotation === null)
			extractInterfaceAnnotation = annotatedClass.getAnnotation(TraitClass)
		if (extractInterfaceAnnotation === null)
			return

		// check name rule
		val nameRule = extractInterfaceAnnotation.getStringValue("name")
		if (!Pattern.matches('''[@#]?([\p{IsLatin}_$][\p{Alnum}_$]*[.]?)+''', nameRule))
			xtendClass.addError('''Invalid name for extracting interface has been set''')
		else if (!nameRule.startsWith("#") && !nameRule.contains("."))
			xtendClass.
				addError('''Name for extracting interface must not lead to an interface in the default package''')

		// class must not be in default package because an extracted interface in sub package might not
		// find the same types as the class
		if (!annotatedClass.qualifiedName.contains('.'))
			xtendClass.
				addError('''Annotation @«getProcessedAnnotationType.simpleName» must not be used for classes within the default package''')

		// annotation @NoInterfaceExtract must not be used in trait classes
		if (xtendClass.isTraitClass)
			if (xtendClass.getDeclaredMethodsResolved(context).exists [
				it.hasAnnotation(NoInterfaceExtract)
			])
				xtendClass.addError('''Annotation @NoInterfaceExtract must not be used for trait classes''')

		// methods must not have an inferred return type
		for (method : xtendClass.getDeclaredMethodsResolved(context).withoutNoInterfaceExtract) {

			if ((method.returnType === null || method.returnType.inferred) && method.visibility == Visibility.PUBLIC)
				method.
					addError('''Method "«method.simpleName»" of must not have an inferred type, because it must be extracted to an interface''')

		}

	}

}