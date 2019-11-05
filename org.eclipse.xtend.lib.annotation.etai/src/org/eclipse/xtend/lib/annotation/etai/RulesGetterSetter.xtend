package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.Collection
import java.util.List
import org.eclipse.xtend.lib.annotation.etai.NotNullRuleProcessor.NotNullRuleInfo
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallValueChangeBoolean
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallValueChangeVoid
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeErasureMethod
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeMatchingStrategy
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.services.TypeLookup
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>Different strategies for returning a collection/map via getter method.</p>
 * 
 * @see GetterRule
 */
enum CollectionGetterPolicy {

	/**
	 * <p>The collection/map is returned directly.</p>
	 */
	DIRECT,

	/**
	 * <p>The collection/map is returned inside of a read-only wrapper.</p>
	 */
	UNMODIFIABLE,

	/**
	 * <p>The copied (read-only) collection/map is returned.</p>
	 */
	UNMODIFIABLE_COPY

}

/**
 * <p>This annotation can mark a (private) field. For this field, a getter method will be generated (applying the
 * Java Bean naming convention).</p>
 * 
 * <p>It can be combined with annotations like {@link TypeAdaptionRule} or {@link NotNullRule}.</p>
 * 
 * @see SetterRule
 * @see NotNullRule
 * @see TypeAdaptionRule
 */
@Target(ElementType.FIELD)
@Active(GetterRuleProcessor)
annotation GetterRule {

	/**
	 * <p>Determines the visibility of the generated method.</p>
	 */
	Visibility visibility = Visibility::PUBLIC

	/**
	 * <p>Determines the strategy how a collection (derived from <code>java.util.Collection</code> or
	 * <code>java.util.Map</code>) is returned by this getter.</p>
	 * 
	 * @see CollectionGetterPolicy
	 */
	CollectionGetterPolicy collectionPolicy = CollectionGetterPolicy.UNMODIFIABLE

}

/**
 * <p>This annotation can mark a (private) field. For this field, a setter method will be generated (applying the
 * Java Bean naming convention).</p>
 * 
 * <p>The generated method will return <code>true</code> if the value or reference (<code>equals</code> is not used)
 * has actually been changed, and <code>false</code> if not.</p>
 * 
 * <p>It can be combined with annotations like {@link TypeAdaptionRule} or {@link NotNullRule}.</p>
 * 
 * @see GetterRule
 * @see NotNullRule
 * @see TypeAdaptionRule
 */
@Target(ElementType.FIELD)
@Active(SetterRuleProcessor)
annotation SetterRule {

	/**
	 * <p>Determines the visibility of the generated method.</p>
	 */
	Visibility visibility = Visibility::PUBLIC

	/**
	 * <p>It is possible to call a method if the field's value is going to be changed. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the change.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case if the symbol
	 * is not at the first position).</p>
	 * 
	 * <p>The method specified by this attribute, is called <em>before</em> the change
	 * has been applied.</p>
	 * 
	 * <p>The searched method can have different signatures depending on the data needed. However,
	 * there should not be multiple methods used at the same time. Possible signatures are:</p>
	 * 
	 * <ul>
	 * <li><code>boolean fieldNameBeforeChange()</code>
	 * <li><code>boolean fieldNameBeforeChange(T newValue)</code>
	 * <li><code>boolean fieldNameBeforeChange(T oldValue, T newValue)</code>
	 * <li><code>boolean fieldNameBeforeChange(String fieldName, T oldValue, T newValue)</code>
	 * </ul>
	 * 
	 * Further details:
	 * <ul>
	 * <li><code>T</code> is an arbitrary type that should be compatible with the field's type
	 * <li><code>fieldName</code> contains the name of the changed field
	 * <li><code>oldValue</code> contains the previous (= current) value of the field
	 * <li><code>newValue</code> contains the (potentially) new value of the field
	 * </ul>
	 * 
	 * <p>The method does not necessarily have to specify <code>boolean</code> as return type.
	 * If it is specified with return type <code>boolean</code>, however, the method can
	 * return <code>false</code> in order to prevent a change of the field's value. If it
	 * returns <code>true</code>, the value will be changed as expected.</p>
	 * 
	 * @see SetterRule#afterChange
	 */
	String beforeChange = ""

	/**
	 * <p>It is possible to call a method if the field's value has been changed. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the change.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case if the symbol
	 * is not at the first position).</p>
	 * 
	 * <p>The method specified by this attribute, is called <em>after</em> the change
	 * has been applied.</p>
	 * 
	 * <p>The searched method can have different signatures depending on the data needed. However,
	 * there should not be multiple methods used at the same time. Possible signatures are:</p>
	 * 
	 * <ul>
	 * <li><code>void fieldNameChanged()</code>
	 * <li><code>void fieldNameChanged(T newValue)</code>
	 * <li><code>void fieldNameChanged(T oldValue, T newValue)</code>
	 * <li><code>void fieldNameChanged(String fieldName, T oldValue, T newValue)</code>
	 * </ul>
	 * 
	 * Further details:
	 * <ul>
	 * <li><code>T</code> is an arbitrary type that should be compatible with the field's type
	 * <li><code>fieldName</code> contains the name of the changed field
	 * <li><code>oldValue</code> contains the previous value of the field
	 * <li><code>newValue</code> contains the new value of the field
	 * </ul>
	 * 
	 * @see SetterRule#beforeChange
	 */
	String afterChange = ""

}

/**
 * <p>Base class for setter/getter annotation processors.</p>
 */
abstract class GetterSetterRuleProcessor extends RuleProcessor<FieldDeclaration, MutableFieldDeclaration> {

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration
	}

	/** 
	 * <p>Helper class for storing information about rule.</p>
	 */
	static abstract class GetterSetterRuleInfo {

		public Visibility visibility = Visibility::PUBLIC

	}

	/** 
	 * <p>This helper class considers a parameter declaration for a virtual method.</p>
	 */
	static class ParameterDeclarationForVirtualMethod implements ParameterDeclaration {

		ExecutableDeclaration executableDeclaration
		TypeReference typeReference
		String simpleName

		new(
			ExecutableDeclaration executableDeclaration,
			TypeReference typeReference,
			String simpleName
		) {

			this.executableDeclaration = executableDeclaration
			this.typeReference = typeReference
			this.simpleName = simpleName

		}

		override getDeclaringExecutable() { return executableDeclaration }

		override getType() { return typeReference }

		override findAnnotation(Type annotationType) { return null }

		override getAnnotations() { return new ArrayList<AnnotationReference> }

		override getCompilationUnit() { return executableDeclaration.compilationUnit }

		override getSimpleName() { return simpleName }

	}

	/** 
	 * <p>This helper class considers a method declaration on basis of a field (annotated by getter/setter rule).</p>
	 */
	static abstract class MethodDeclarationFromGetterSetter<T extends TypeLookup & TypeReferenceProvider> implements MethodDeclaration {

		protected FieldDeclaration fieldDeclaration
		protected Visibility visibility
		protected T context

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			this.fieldDeclaration = fieldDeclaration
			this.visibility = visibility
			this.context = context
		}

		override isAbstract() { return false }

		override isDefault() { return false }

		override isFinal() { return false }

		override isNative() { return false }

		override isStatic() { return fieldDeclaration.isStatic }

		override isStrictFloatingPoint() { return false }

		override isSynchronized() { return false }

		override getBody() { return null }

		override getExceptions() { return new ArrayList<TypeReference> }

		override isVarArgs() { return false }

		override getTypeParameters() { return new ArrayList<TypeParameterDeclaration> }

		override getDeclaringType() { return fieldDeclaration.declaringType }

		override getModifiers() { return null }

		override getVisibility() { return visibility }

		override isDeprecated() { return false }

		override findAnnotation(Type annotationType) { return fieldDeclaration.findAnnotation(annotationType) }

		override getAnnotations() { return fieldDeclaration.annotations }

		override getCompilationUnit() { return fieldDeclaration.compilationUnit }

		/**
		 * <p>This method returns the basic implementation of the method represented by this class.</p>
		 */
		abstract def String getBasicImplementation()

		/** <p>Returns the not null rule information from the annotated field.</p> */
		def NotNullRuleInfo getNotNullRuleInfo() {

			if (fieldDeclaration.hasAnnotation(NotNullRule))
				return NotNullRuleProcessor.getNotNullInfo(fieldDeclaration, context)
			return null

		}

	}

	/**
	 * <p>Retrieves information from annotation.</p>
	 */
	static def void fillInfoFromAnnotationBase(AnnotationReference annotationGetterSetterRule,
		GetterSetterRuleInfo getterSetterRuleInfo, extension TypeLookup context) {

		if (annotationGetterSetterRule === null)
			return

		val visibilityValue = annotationGetterSetterRule.getEnumValue("visibility")
		if (visibilityValue !== null)
			getterSetterRuleInfo.visibility = Visibility.valueOf(visibilityValue.simpleName)

	}

	/**
	 * <p>Retrieves info from annotation (non-static)</p>
	 */
	abstract def GetterSetterRuleInfo getInfo(FieldDeclaration annotatedField, extension TypeLookup context)

	/**
	 * <p>Replaces the placeholder symbol "%" in a given method name string with the field's name, whereas
	 * the first letter will be upper case if "%" is NOT at the first place.</p>
	 */
	static def String insertFieldName(FieldDeclaration fieldDeclaration, String methodNameWithPlaceholder) {

		var result = methodNameWithPlaceholder

		if (result.startsWith("%"))
			result = fieldDeclaration.simpleName + result.substring(1, result.length)

		result = result.replaceAll("\\%", fieldDeclaration.simpleName.toFirstUpper)

		return result

	}

	/**
	 * <p>Returns the name of the opposite field or <code>null</code> if not specified.</p>
	 */
	static def String getOppositeFieldName(FieldDeclaration fieldDeclaration, extension TypeLookup context) {

		if (fieldDeclaration.hasAnnotation(BidirectionalRule))
			BidirectionalRuleProcessor::getBidirectionalRuleInfo(fieldDeclaration, context).oppositeField
		else
			null

	}

	/**
	 * <p>Returns the synchronization lock name for this field or <code>null</code> if not specified.</p>
	 */
	static def String getSynchronizationLockName(FieldDeclaration fieldDeclaration, extension TypeLookup context) {

		if (fieldDeclaration.hasAnnotation(SynchronizationRule))
			SynchronizationRuleProcessor::getSynchronizationRuleInfo(fieldDeclaration, context).lockName
		else
			null

	}

	/**
	 * <p>Returns the code which shall be used to refer to "this" (is "$extendedThis()" within trait classes).</p>
	 */
	static def String getThisCode(FieldDeclaration fieldDeclaration) {

		// special return value inside of trait class
		if (fieldDeclaration.declaringType.hasAnnotation(TraitClass))
			return "$extendedThis()"

		return "this"

	}

	/**
	 * <p>Retrieves a method that shall be called on a specific event (e.g. changing the value of a field,
	 * adding an element to the field's collection etc.).</p>
	 * 
	 * <p>The method can be specified by a name (supporting wildcards) and the given parameter filter.</p>
	 * 
	 * <p>If matching method can be found, <code>null</code> is returned.</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodCallX(
		FieldDeclaration annotatedField,
		String eventDescription,
		String methodName,
		(Iterable<? extends ParameterDeclaration>)=>Boolean methodParamFilter,
		Collection<Class<?>> requiredFieldTypes,
		List<String> errors,
		extension T context
	) {

		if (requiredFieldTypes !== null && !requiredFieldTypes.exists [
			context.newTypeReference(it).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)
		]) {

			if (!methodName.isNullOrEmpty)
				errors?.add('''Field "«annotatedField.simpleName»" does not support event "«eventDescription»"''')
			return null

		}

		if (methodName.isNullOrEmpty)
			return null

		val classDeclaration = annotatedField.declaringType as ClassDeclaration

		// retrieve all methods which could be called
		val allMethods = classDeclaration.getMethodClosure(null, null, true, true, true, true, false, context)

		// filter for methods with name matching to specified one (considering placeholders for the field's name)
		// and unify (no need for type matching)
		val methodNameToSearch = insertFieldName(annotatedField, methodName)
		val methodsWithMatchingNameAndTypes = allMethods.filter [
			simpleName == methodNameToSearch
		].filter[methodParamFilter.curry(parameters).apply].unifyMethodDeclarations(
			TypeMatchingStrategy.MATCH_ALL_CONSTRUCTOR_METHOD, TypeMatchingStrategy.MATCH_ALL, null, false, null,
			context)

		if (methodsWithMatchingNameAndTypes.size == 0) {
			errors?.
				add('''Cannot find appropriate method "«methodNameToSearch»" that shall be called on event "«eventDescription»" for field "«annotatedField.simpleName»"''')
			return null
		}

		if (methodsWithMatchingNameAndTypes.size > 1)
			errors?.
				add('''Multiple method candidates found for being called on event "«eventDescription»" for field "«annotatedField.simpleName»"''')

		// method will be called (only if not in validation phase)
		if (errors === null && methodsWithMatchingNameAndTypes.get(0) instanceof MutableMethodDeclaration)
			(methodsWithMatchingNameAndTypes.get(0) as MutableMethodDeclaration).markAsRead

		return methodsWithMatchingNameAndTypes.get(0)

	}

	override doTransform(MutableFieldDeclaration annotatedField, extension TransformationContext context) {

		super.doTransform(annotatedField, context)

		// avoid "unused" warning
		annotatedField.markAsRead

	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		val getterSetterRuleInfo = getInfo(annotatedField, context)

		// check that field has (not inferred) type
		if (xtendField.type === null || xtendField.type.inferred)
			xtendField.
				addError('''@«getProcessedAnnotationType().simpleName» does not support fields with inferred type''')

		// check that field is not public
		if (xtendField.visibility == Visibility::PUBLIC)
			xtendField.
				addError('''A field with @«getProcessedAnnotationType().simpleName» must not be declared public''')

		// check for abstract modifier
		if (getterSetterRuleInfo.visibility != Visibility::PUBLIC &&
			getterSetterRuleInfo.visibility != Visibility::PROTECTED)
			xtendField.addError('''Only public and protected methods can be generated''')

	}

}

/**
 * <p>Active Annotation Processor for {@link GetterRule}.</p>
 * 
 * @see GetterRule
 */
class GetterRuleProcessor extends GetterSetterRuleProcessor {

	static class GetterRuleInfo extends GetterSetterRuleInfo {

		public CollectionGetterPolicy collectionPolicy = CollectionGetterPolicy.UNMODIFIABLE

	}

	/**
	 * <p>Specifies characteristics of getX / isX method virtually.</p> 
	 */
	static class MethodDeclarationFromGetter<T extends TypeLookup & TypeReferenceProvider> extends MethodDeclarationFromGetterSetter<T> {

		protected CollectionGetterPolicy collectionPolicy

		new(FieldDeclaration fieldDeclaration, Visibility visibility, CollectionGetterPolicy collectionPolicy,
			T context) {

			super(fieldDeclaration, visibility, context)

			this.collectionPolicy = collectionPolicy

		}

		override getReturnType() { return fieldDeclaration.type }

		override getParameters() {
			return new ArrayList<ParameterDeclaration>
		}

		override getDocComment() {
			return '''This is a generated getter method for retrieving {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {

			if (returnType == context.primitiveBoolean)
				return "is" + fieldDeclaration.simpleName.toFirstUpper
			else
				return "get" + fieldDeclaration.simpleName.toFirstUpper

		}

		override String getBasicImplementation() {

			val notNullRuleInfo = getNotNullRuleInfo
			val synchronizationLockName = getSynchronizationLockName(fieldDeclaration, context)

			return '''return org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.getValue(
					«IF !fieldDeclaration.isStatic»this.«ENDIF»«fieldDeclaration.simpleName»,
					org.eclipse.xtend.lib.annotation.etai.CollectionGetterPolicy.«collectionPolicy»,
					"«fieldDeclaration.simpleName»",
					«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullSelf»«ELSE»false«ENDIF»,
					«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullKeyOrElement»«ELSE»false«ENDIF»,
					«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullValue»«ELSE»false«ENDIF»,
					«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''

		}

	}

	protected override getProcessedAnnotationType() {
		GetterRule
	}

	/**
	 * <p>Retrieves information from annotation (@GetterRule).</p>
	 */
	static def GetterRuleInfo getGetterInfo(FieldDeclaration annotatedField, extension TypeLookup context) {

		val getterRuleInfo = new GetterRuleInfo
		val annotationGetterRule = annotatedField.getAnnotation(GetterRule)

		fillInfoFromAnnotationBase(annotationGetterRule, getterRuleInfo, context)

		val collectionGetterPolicyValue = annotationGetterRule.getEnumValue("collectionPolicy")
		if (collectionGetterPolicyValue !== null)
			getterRuleInfo.collectionPolicy = CollectionGetterPolicy.valueOf(collectionGetterPolicyValue.simpleName)

		return getterRuleInfo

	}

	override GetterRuleInfo getInfo(FieldDeclaration annotatedField, extension TypeLookup context) {
		return getGetterInfo(annotatedField, context)
	}

}

/**
 * <p>Active Annotation Processor for {@link SetterRule}.</p>
 * 
 * @see SetterRule
 */
class SetterRuleProcessor extends GetterSetterRuleProcessor {

	static class SetterRuleInfo extends GetterSetterRuleInfo {

		public String beforeChange = ""
		public String afterChange = ""

	}

	/**
	 * <p>Specifies characteristics of setX method virtually.</p>
	 */
	static class MethodDeclarationFromSetter<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromGetterSetter<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { return context.primitiveBoolean }

		override getParameters() {
			val result = new ArrayList<ParameterDeclaration>
			result.add(
				new ParameterDeclarationForVirtualMethod(this, fieldDeclaration.type,
					"$" + fieldDeclaration.simpleName))
			return result
		}

		override getDocComment() {
			return '''This is a generated setter method for setting {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "set" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {

			val notNullRuleInfo = getNotNullRuleInfo
			val oppositeFieldName = getOppositeFieldName(fieldDeclaration, context)
			val synchronizationLockName = getSynchronizationLockName(fieldDeclaration, context)

			return '''return org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.setValue(
					«IF !fieldDeclaration.isStatic»this.«ENDIF»«fieldDeclaration.simpleName», $«fieldDeclaration.simpleName»,
					new org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallBoolean() {
						@Override
							public boolean call() {
								return «fieldDeclaration.declaringType.qualifiedName».«IF !fieldDeclaration.isStatic»this.«ENDIF»«fieldDeclaration.simpleName» != $«fieldDeclaration.simpleName»;
							}
					},
					new org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallVoid() {
						@Override
							public void call() {
								«fieldDeclaration.declaringType.qualifiedName».«IF !fieldDeclaration.isStatic»this.«ENDIF»«fieldDeclaration.simpleName» = $«fieldDeclaration.simpleName»;
							}
					},
					«getMethodCallBeforeChange(fieldDeclaration, context)»,
					«getMethodCallAfterChange(fieldDeclaration, context)»,
					"«fieldDeclaration.simpleName»",
					«IF fieldDeclaration.isStatic»null«ELSE»«getThisCode(fieldDeclaration)»«ENDIF»,
					«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullSelf»«ELSE»false«ENDIF»,
					«IF !oppositeFieldName.isNullOrEmpty»"«oppositeFieldName»"«ELSE»null«ENDIF»,
					«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''

		}

	}

	protected override getProcessedAnnotationType() {
		SetterRule
	}

	/**
	 * <p>Retrieves information from annotation (@GetterRule).</p>
	 */
	static def SetterRuleInfo getSetterInfo(FieldDeclaration annotatedField, extension TypeLookup context) {

		val setterRuleInfo = new SetterRuleInfo
		val annotationSetterRule = annotatedField.getAnnotation(SetterRule)

		fillInfoFromAnnotationBase(annotationSetterRule, setterRuleInfo, context)

		setterRuleInfo.beforeChange = annotationSetterRule.getStringValue("beforeChange")
		setterRuleInfo.afterChange = annotationSetterRule.getStringValue("afterChange")

		return setterRuleInfo

	}

	override SetterRuleInfo getInfo(FieldDeclaration annotatedField, extension TypeLookup context) {
		return getSetterInfo(annotatedField, context)
	}

	/**
	 * <p>This method embeds a method call for setter events (code) in the appropriate object.</p>
	 */
	static def String getSetterMethodCallEmbedded(MethodDeclaration methodDeclaration, Class<?> interfaceType,
		boolean isBoolean, FieldDeclaration fieldDeclaration, String parameters,
		extension TypeReferenceProvider context) {

		val methodDeclarationBoolean = (context.primitiveBoolean == methodDeclaration.returnType)
		val objectTypeString = fieldDeclaration.type.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, true,
			context)
		return '''new org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.«interfaceType.simpleName»<«objectTypeString»>() {
				@Override
				public «IF isBoolean»boolean«ELSE»void«ENDIF» call(«objectTypeString» oldValue, «objectTypeString» newValue) {
					«IF isBoolean && methodDeclarationBoolean»return «ENDIF»«methodDeclaration.simpleName»(«parameters»);
					«IF isBoolean && !methodDeclarationBoolean»return true;«ENDIF»
				}
			}'''

	}

	/**
	 * <p>Get method for event "before change".</p>
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodBeforeChange(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		return getMethodCallX(
			annotatedField,
			"before change",
			getSetterInfo(annotatedField, context).beforeChange,
			[
				it.length == 0 || it.length == 1 || it.length == 2 ||
					(it.length == 3 && context.newTypeReference(String).isAssignableFrom(it.get(0).type))
			],
			null,
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "before change".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallBeforeChange(
		FieldDeclaration annotatedField, extension T context) {

		val method = getMethodBeforeChange(annotatedField, null, context)
		if (method === null)
			return '''null'''
		else if (method.parameters.length == 0)
			return getSetterMethodCallEmbedded(method, MethodCallValueChangeBoolean, true, annotatedField, "", context)
		else if (method.parameters.length == 1)
			return getSetterMethodCallEmbedded(method, MethodCallValueChangeBoolean, true,
				annotatedField, '''newValue''', context)
		else if (method.parameters.length == 2)
			return getSetterMethodCallEmbedded(method, MethodCallValueChangeBoolean, true,
				annotatedField, '''oldValue, newValue''', context)
		else if (method.parameters.length == 3)
			return getSetterMethodCallEmbedded(method, MethodCallValueChangeBoolean, true,
				annotatedField, '''"«annotatedField.simpleName»", oldValue, newValue''', context)
		else
			throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" before field "«annotatedField.simpleName»" is changed: unknown signature''')

	}

	/**
	 * <p>Get method for event "after change".</p>
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodAfterChange(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		return getMethodCallX(
			annotatedField,
			"after change",
			getSetterInfo(annotatedField, context).afterChange,
			[
				it.length == 0 || it.length == 1 || it.length == 2 ||
					(it.length == 3 && context.newTypeReference(String).isAssignableFrom(it.get(0).type))
			],
			null,
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "after change".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallAfterChange(
		FieldDeclaration annotatedField, extension T context) {

		val method = getMethodAfterChange(annotatedField, null, context)
		if (method === null)
			return '''null'''
		else if (method.parameters.length == 0)
			return getSetterMethodCallEmbedded(method, MethodCallValueChangeVoid, false, annotatedField, "", context)
		else if (method.parameters.length == 1)
			return getSetterMethodCallEmbedded(method, MethodCallValueChangeVoid, false, annotatedField, '''newValue''',
				context)
		else if (method.parameters.length == 2)
			return getSetterMethodCallEmbedded(method, MethodCallValueChangeVoid, false,
				annotatedField, '''oldValue, newValue''', context)
		else if (method.parameters.length == 3)
			return getSetterMethodCallEmbedded(method, MethodCallValueChangeVoid, false,
				annotatedField, '''"«annotatedField.simpleName»", oldValue, newValue''', context)
		else
			throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" after field "«annotatedField.simpleName»" has been changed: unknown signature''')

	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		// check event methods for errors
		val errors = new ArrayList<String>
		getMethodBeforeChange(annotatedField, errors, context)
		getMethodAfterChange(annotatedField, errors, context)
		xtendField.reportErrors(errors, context)

		// field must not be final
		if (xtendField.final == true)
			xtendField.addError("A field with setter rule must not be declared final")

	}

}
