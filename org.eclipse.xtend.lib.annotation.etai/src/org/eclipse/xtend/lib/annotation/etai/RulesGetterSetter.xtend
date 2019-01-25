package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.Collection
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallCollectionNameMultipleIndexBoolean
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallCollectionNameMultipleIndexVoid
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallCollectionNameSingleIndexBoolean
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallCollectionNameSingleIndexVoid
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallValueChangeBoolean
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallValueChangeVoid
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeMatchingStrategy
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.services.TypeLookup
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*
import org.eclipse.xtend.lib.annotation.etai.NotNullRuleProcessor.NotNullRuleInfo

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
	Visibility visibility = Visibility.PUBLIC

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
 * <p>The generated method will return <code>true</code>, if the value or reference (<code>equals</code> is not used)
 * has actually been changed, and <code>false</code>, if not.</p>
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
	Visibility visibility = Visibility.PUBLIC

	/**
	 * <p>It is possible to call a method, if the field's value is going to be changed. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the change.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case, if the symbol
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
	 * <li><code>T</code> is an arbitrary type, which should be compatible with the field's type
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
	 * <p>It is possible to call a method, if the field's value has been changed. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the change.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case, if the symbol
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
	 * <li><code>T</code> is an arbitrary type, which should be compatible with the field's type
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
 * <p>This annotation can mark a (private) field, whose type is derived from <code>java.util.Collection</code> or
 * <code>java.util.Map</code>. For this field, methods for adding items to the collection
 * (resp. putting items to the map) will be generated.</p>
 * 
 * <p>Depending on the configuration, the following methods will be generated.</p>
 * <ul>
 * <li><code>boolean addToX(E element)</code> (if <code>java.util.Collection</code> and <code>single</code> is <code>true</code>)
 * <li><code>boolean addToX(int index, E element)</code> (if <code>java.util.List</code> and <code>single</code> is <code>true</code>)
 * <li><code>V putToX(K key, V value)</code> (if <code>java.util.Map</code> and <code>single</code> is <code>true</code>)
 * <li><code>boolean addAllToX(java.util.Collection&lt;E&gt; c)</code> (if <code>java.util.Collection</code> and <code>multiple</code> is <code>true</code>)
 * <li><code>boolean addAllToX(int index, java.util.Collection&lt;E&gt; c)</code> (if <code>java.util.List</code> and <code>multiple</code> is <code>true</code>)
 * <li><code>void putAllToX(Map&lt;? extends K,? extends V&gt; m)</code> (if <code>java.util.Map</code> and <code>multiple</code> is <code>true</code>)
 * </ul>
 * 
 * <p>Thereby <code>X</code> is the name of the field. A description of the individual generated (mostly wrapper) methods and
 * their return values can be taken from <code>java.util.Collection</code>, <code>java.util.List</code> resp.
 * <code>java.util.Map</code>. In general, all <code>boolean</code> return values will report, if there has been a change in the
 * collection (not available for maps).</p>
 * 
 * <p>The annotation can be combined with annotations like {@link NotNullRule}.</p>
 * 
 * @see RemoverRule
 * @see NotNullRule
 */
@Target(ElementType.FIELD)
@Active(AdderRuleProcessor)
annotation AdderRule {

	/**
	 * <p>Determines if methods for adding single elements shall be generated (e.g. add).</p>
	 * 
	 * @see AdderRule
	 */
	boolean single = true

	/**
	 * <p>Determines if methods for adding multiple elements shall be generated (e.g. addAll).</p>
	 * 
	 * @see AdderRule
	 */
	boolean multiple = false

	/**
	 * <p>Determines the visibility of the generated method.</p>
	 */
	Visibility visibility = Visibility.PUBLIC

	/**
	 * <p>It is possible to call a method, if an element is going to be added. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the addition.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case, if the symbol
	 * is not at the first position).</p>
	 * 
	 * <p>The method specified by this attribute, is called <em>before</em> the element will be
	 * added. Thereby, it is ensured that it would be added (i.e. it is not already contained in
	 * a <code>java.util.Set</code>).</p>
	 * 
	 * <p>The searched method can have different signatures depending on the data needed. However,
	 * there should not be multiple methods used at the same time. Possible signatures are:</p>
	 * 
	 * <ul>
	 * <li><code>boolean fieldNameBeforeElementAdd(T addedElement)</code>
	 * <li><code>boolean fieldNameBeforeElementAdd(String fieldName, T addedElement)</code>
	 * <li><code>boolean fieldNameBeforeElementAdd(int index, T addedElement)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeElementAdd(String fieldName, int index, T addedElement)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeElementAdd(List&lt;T&gt; oldElements, T addedElement)</code> - not supported for lists
	 * <li><code>boolean fieldNameBeforeElementAdd(String fieldName, List&lt;T&gt; oldElements, T addedElement)</code> - not supported for lists
	 * <li><code>boolean fieldNameBeforeElementAdd(List&lt;T&gt; oldElements, int index, T addedElement)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeElementAdd(String fieldName, List&lt;T&gt; oldElements, int index, T addedElement)</code> - only supported for lists
	 * </ul>
	 * 
	 * Further details:
	 * <ul>
	 * <li><code>T</code> is an arbitrary type, which should be compatible with the field's collection type
	 * <li><code>fieldName</code> contains the name of the field/collection
	 * <li><code>addedElement</code> contains the (potentially) added element
	 * <li><code>oldElements</code> contains all elements in the collection before the change (read-only)
	 * <li><code>index</code> contains the index where the element is going to be added
	 * </ul>
	 * 
	 * <p>The method does not necessarily have to specify <code>boolean</code> as return type.
	 * If it is specified with return type <code>boolean</code>, however, the method can
	 * return <code>false</code> in order to prevent adding the given element. If
	 * <code>true</code> is returned, the element will be added as expected.</p>
	 * 
	 * <p>This feature is only supported by collections. It is not supported, if a map is annotated.</p>
	 * 
	 * @see AdderRule#afterElementAdd
	 * @see AdderRule#beforeAdd
	 */
	String beforeElementAdd = ""

	/**
	 * <p>It is possible to call a method, if an element has been added. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the addition.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case, if the symbol
	 * is not at the first position).</p>
	 * 
	 * <p>The method specified by this attribute, is called <em>after</em> the element
	 * has been added.</p>
	 * 
	 * <p>The searched method can have different signatures depending on the data needed. However,
	 * there should not be multiple methods used at the same time. Possible signatures are:</p>
	 * 
	 * <ul>
	 * <li><code>void fieldNameElementAdded(T addedElement)</code>
	 * <li><code>void fieldNameElementAdded(String fieldName, T addedElement)</code>
	 * <li><code>void fieldNameElementAdded(int index, T addedElement)</code> - only supported for lists
	 * <li><code>void fieldNameElementAdded(String fieldName, int index, T addedElement)</code> - only supported for lists
	 * <li><code>void fieldNameElementAdded(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, T addedElement)</code> - not supported for lists
	 * <li><code>void fieldNameElementAdded(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, T addedElement)</code> - not supported for lists
	 * <li><code>void fieldNameElementAdded(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, int index, T addedElement)</code> - only supported for lists
	 * <li><code>void fieldNameElementAdded(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, int index, T addedElement)</code> - only supported for lists
	 * </ul>
	 * 
	 * Further details:
	 * <ul>
	 * <li><code>T</code> is an arbitrary type, which should be compatible with the field's collection type
	 * <li><code>fieldName</code> contains the name of the field/collection
	 * <li><code>addedElement</code> contains the added element
	 * <li><code>oldElements</code> contains all elements in the collection before the change (read-only)
	 * <li><code>newElements</code> contains all elements in the collection after the change (read-only)
	 * <li><code>index</code> contains the index where the element has been added
	 * </ul>
	 * 
	 * @see AdderRule#beforeElementAdd
	 * @see AdderRule#afterAdd
	 */
	String afterElementAdd = ""

	/**
	 * <p>This attribute offers similar possibilities as {@link AdderRule#beforeElementAdd}.</p>
	 * 
	 * <p>The called method, however, must have one of the following signatures:</p>
	 * 
	 * <ul>
	 * <li><code>boolean fieldNameBeforeAdd()</code>
	 * <li><code>boolean fieldNameBeforeAdd(List&lt;T&gt; addedElements)</code>
	 * <li><code>boolean fieldNameBeforeAdd(String fieldName, List&lt;T&gt; addedElements)</code>
	 * <li><code>boolean fieldNameBeforeAdd(List&lt;Integer&gt; indices, List&lt;T&gt; addedElements)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeAdd(String fieldName, List&lt;Integer&gt; indices, List&lt;T&gt; addedElements)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeAdd(List&lt;T&gt; oldElements, List&lt;T&gt; addedElements)</code> - not supported for lists
	 * <li><code>boolean fieldNameBeforeAdd(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; addedElements)</code> - not supported for lists
	 * <li><code>boolean fieldNameBeforeAdd(List&lt;T&gt; oldElements, List&lt;Integer&gt; indices, List&lt;T&gt; addedElements)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeAdd(String fieldName, List&lt;T&gt; oldElements, List&lt;Integer&gt; indices, List&lt;T&gt; addedElements)</code> - only supported for lists
	 * </ul>
	 * 
	 * <p>The main difference is that the found method is not called for each element, but for all elements
	 * which are going to be added.</p>
	 * 
	 * <p>If a method based on {@link AdderRule#beforeElementAdd} and a method based on this attribute
	 * are found, the method based on this attribute will be called after the method for each individual
	 * element.</p>
	 * 
	 * <p>In addition to parameters described in the mentioned {@link AdderRule#beforeElementAdd}, the referenced
	 * methods here also support:</p>
	 * <li><code>addedElements</code> contains all (potentially) added elements in the collection before the change (read-only)
	 * <li><code>indices</code> contains all (potentially) added indices in the collection before the change (read-only, in the same order as <code>addedElements</code>)
	 * 
	 * @see AdderRule#beforeElementAdd
	 * @see AdderRule#afterAdd
	 */
	String beforeAdd = ""

	/**
	 * <p>This attribute offers similar possibilities as {@link AdderRule#afterElementAdd}.</p>
	 * 
	 * <p>The called method, however, must have one of the following signatures:</p>
	 * 
	 * <ul>
	 * <li><code>void fieldNameAdded()</code>
	 * <li><code>void fieldNameAdded(List&lt;T&gt; addedElements)</code>
	 * <li><code>void fieldNameAdded(String fieldName, List&lt;T&gt; addedElements)</code>
	 * <li><code>void fieldNameAdded(List&lt;Integer&gt; indices, List&lt;T&gt; addedElements)</code> - only supported for lists
	 * <li><code>void fieldNameAdded(String fieldName, List&lt;Integer&gt; indices, List&lt;T&gt; addedElements)</code> - only supported for lists
	 * <li><code>void fieldNameAdded(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;T&gt; addedElements)</code> - not supported for lists
	 * <li><code>void fieldNameAdded(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;T&gt; addedElements)</code> - not supported for lists
	 * <li><code>void fieldNameAdded(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;Integer&gt; indices, List&lt;T&gt; addedElements)</code> - only supported for lists
	 * <li><code>void fieldNameAdded(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;Integer&gt; indices, List&lt;T&gt; addedElements)</code> - only supported for lists
	 * </ul>
	 * 
	 * <p>The main difference is that the found method is not called for each element, but for all elements
	 * which have been added.</p>
	 * 
	 * <p>If a method based on {@link AdderRule#afterElementAdd} and a method based on this attribute
	 * are found, the method based on this attribute will be called after the method for each individual
	 * element.</p>
	 * 
	 * <p>In addition to parameters described in the mentioned {@link AdderRule#afterElementAdd}, the referenced
	 * methods here also support:</p>
	 * <li><code>addedElements</code> contains all added elements in the collection before the change (read-only)
	 * <li><code>indices</code> contains all added indices in the collection before the change (read-only, in the same order as <code>addedElements</code>)
	 * 
	 * @see AdderRule#afterElementAdd
	 * @see AdderRule#beforeAdd
	 */
	String afterAdd = ""

}

/**
 * <p>This annotation can mark a (private) field, whose type is derived from <code>java.util.Collection</code> or
 * <code>java.util.Map</code>. For this field, methods for removing items from the collection/map will be
 * generated.</p>
 * 
 * <p>Depending on the configuration, the following methods will be generated.</p>
 * <ul>
 * <li><code>boolean removeFromX(int index)</code> (if <code>java.util.List</code> and <code>single</code> is <code>true</code>)
 * <li><code>boolean removeFromX(E element)</code> (if <code>java.util.Collection</code> and <code>single</code> is <code>true</code>)
 * <li><code>V removeFromX(K key)</code> (if <code>java.util.Map</code> and <code>single</code> is <code>true</code>)
 * <li><code>boolean removeAllFromX(java.util.Collection&lt;E&gt; c)</code> (if <code>java.util.Collection</code> and <code>multiple</code> is <code>true</code>)
 * <li><code>void/boolean clearX()</code> (if <code>multiple</code> is <code>true</code>)
 * </ul>
 * 
 * <p>Thereby <code>X</code> is the name of the field. A description of the individual generated methods can be taken from
 * <code>java.util.Collection</code>, <code>java.util.List</code> resp. <code>java.util.Map</code>. In general, all
 * <code>boolean</code> return values will report, if there has been a change in the collection (not available for maps).</p>
 * 
 * @see AdderRule
 */
@Target(ElementType.FIELD)
@Active(RemoverRuleProcessor)
annotation RemoverRule {

	/**
	 * <p>Determines if methods for removing single elements shall be generated (e.g. remove).</p>
	 * 
	 * @see RemoverRule
	 */
	boolean single = true

	/**
	 * <p>Determines if methods for removing multiple elements shall be generated (e.g. clear).</p>
	 * 
	 * @see RemoverRule
	 */
	boolean multiple = false

	/**
	 * <p>Determines the visibility of the generated method.</p>
	 */
	Visibility visibility = Visibility.PUBLIC

	/**
	 * <p>It is possible to call a method, if an element is going to be removed. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the addition.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case, if the symbol
	 * is not at the first position).</p>
	 * 
	 * <p>The method specified by this attribute, is called <em>before</em> the element will be
	 * removed. Thereby, it is ensured that there is an element, which can be removed.</p>
	 * 
	 * <p>The searched method can have different signatures depending on the data needed. However,
	 * there should not be multiple methods used at the same time. Possible signatures are:</p>
	 * 
	 * <ul>
	 * <li><code>boolean fieldNameBeforeElementRemove(T removedElement)</code>
	 * <li><code>boolean fieldNameBeforeElementRemove(String fieldName, T removedElement)</code>
	 * <li><code>boolean fieldNameBeforeElementRemove(int index, T removedElement)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeElementRemove(String fieldName, int index, T removedElement)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeElementRemove(List&lt;T&gt; oldElements, T removedElement)</code> - not supported for lists
	 * <li><code>boolean fieldNameBeforeElementRemove(String fieldName, List&lt;T&gt; oldElements, T removedElement)</code> - not supported for lists
	 * <li><code>boolean fieldNameBeforeElementRemove(List&lt;T&gt; oldElements, int index, T removedElement)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeElementRemove(String fieldName, List&lt;T&gt; oldElements, int index, T removedElement)</code> - only supported for lists
	 * </ul>
	 * 
	 * Further details:
	 * <ul>
	 * <li><code>T</code> is an arbitrary type, which should be compatible with the field's collection type
	 * <li><code>fieldName</code> contains the name of the field/collection
	 * <li><code>removedElement</code> contains the (potentially) removed element
	 * <li><code>oldElements</code> contains all elements in the collection before the change (read-only)
	 * <li><code>index</code> contains the index where the element is going to be removed
	 * </ul>
	 * 
	 * <p>The method does not necessarily have to specify <code>boolean</code> as return type.
	 * If it is specified with return type <code>boolean</code>, however, the method can
	 * return <code>false</code> in order to prevent removing the given element. If
	 * <code>true</code> is returned, the element will be removed as expected.</p>
	 * 
	 * <p>This feature is only supported by collections. It is not supported, if a map is annotated.</p>
	 * 
	 * @see RemoverRule#afterElementRemove
	 * @see RemoverRule#beforeRemove
	 */
	String beforeElementRemove = ""

	/**
	 * <p>It is possible to call a method, if an element has been removed. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the addition.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case, if the symbol
	 * is not at the first position).</p>
	 * 
	 * <p>The method specified by this attribute, is called <em>after</em> the element
	 * has been removed.</p>
	 * 
	 * <p>The searched method can have different signatures depending on the data needed. However,
	 * there should not be multiple methods used at the same time. Possible signatures are:</p>
	 * 
	 * <ul>
	 * <li><code>void fieldNameElementRemoved(T removedElement)</code>
	 * <li><code>void fieldNameElementRemoved(String fieldName, T removedElement)</code>
	 * <li><code>void fieldNameElementRemoved(int index, T removedElement)</code> - only supported for lists
	 * <li><code>void fieldNameElementRemoved(String fieldName, int index, T removedElement)</code> - only supported for lists
	 * <li><code>void fieldNameElementRemoved(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, T removedElement)</code> - not supported for lists
	 * <li><code>void fieldNameElementRemoved(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, T removedElement)</code> - not supported for lists
	 * <li><code>void fieldNameElementRemoved(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, int index, T removedElement)</code> - only supported for lists
	 * <li><code>void fieldNameElementRemoved(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, int index, T removedElement)</code> - only supported for lists
	 * </ul>
	 * 
	 * Further details:
	 * <ul>
	 * <li><code>T</code> is an arbitrary type, which should be compatible with the field's collection type
	 * <li><code>fieldName</code> contains the name of the field/collection
	 * <li><code>removedElement</code> contains the removed element
	 * <li><code>oldElements</code> contains all elements in the collection before the change (read-only)
	 * <li><code>newElements</code> contains all elements in the collection after the change (read-only)
	 * <li><code>index</code> contains the index where the element has been removed
	 * </ul>
	 * 
	 * @see RemoverRule#beforeElementRemove
	 * @see RemoverRule#afterRemove
	 */
	String afterElementRemove = ""

	/**
	 * <p>This attribute offers similar possibilities as {@link RemoverRule#beforeElementRemove}.</p>
	 * 
	 * <p>The called method, however, must have one of the following signatures:</p>
	 * 
	 * <ul>
	 * <li><code>boolean fieldNameBeforeRemove()</code>
	 * <li><code>boolean fieldNameBeforeRemove(List&lt;T&gt; removedElements)</code>
	 * <li><code>boolean fieldNameBeforeRemove(String fieldName, List&lt;T&gt; removedElements)</code>
	 * <li><code>boolean fieldNameBeforeRemove(List&lt;Integer&gt; indices, List&lt;T&gt; removedElements)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeRemove(String fieldName, List&lt;Integer&gt; indices, List&lt;T&gt; removedElements)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeRemove(List&lt;T&gt; oldElements, List&lt;T&gt; removedElements)</code> - not supported for lists
	 * <li><code>boolean fieldNameBeforeRemove(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; removedElements)</code> - not supported for lists
	 * <li><code>boolean fieldNameBeforeRemove(List&lt;T&gt; oldElements, List&lt;Integer&gt; indices, List&lt;T&gt; removedElements)</code> - only supported for lists
	 * <li><code>boolean fieldNameBeforeRemove(String fieldName, List&lt;T&gt; oldElements, List&lt;Integer&gt; indices, List&lt;T&gt; removedElements)</code> - only supported for lists
	 * </ul>
	 * 
	 * <p>The main difference is that the found method is not called for each element, but for all elements
	 * which are going to be removed.</p>
	 * 
	 * <p>If a method based on {@link RemoverRule#beforeElementRemove} and a method based on this attribute
	 * are found, the method based on this attribute will be called after the method for each individual
	 * element.</p>
	 * 
	 * <p>In addition to parameters described in the mentioned {@link RemoverRule#beforeElementRemove}, the referenced
	 * methods here also support:</p>
	 * <li><code>removedElements</code> contains all (potentially) removed elements in the collection before the change (read-only)
	 * <li><code>indices</code> contains all (potentially) removed indices in the collection before the change (read-only, in the same order as <code>removedElements</code>)
	 * 
	 * <p>The method does not necessarily have to specify <code>boolean</code> as return type.
	 * If it is specified with return type <code>boolean</code>, however, the method can
	 * return <code>false</code> in order to prevent removing the given elements. If
	 * <code>true</code> is returned, the elements will be removed as expected.</p>
	 * 
	 * @see RemoverRule#beforeElementRemove
	 * @see RemoverRule#afterRemove
	 */
	String beforeRemove = ""

	/**
	 * <p>This attribute offers similar possibilities as {@link RemoverRule#afterElementRemove}.</p>
	 * 
	 * <p>The called method, however, must have one of the following signatures:</p>
	 * 
	 * <ul>
	 * <li><code>void fieldNameRemoved()</code>
	 * <li><code>void fieldNameRemoved(List&lt;T&gt; removedElements)</code>
	 * <li><code>void fieldNameRemoved(String fieldName, List&lt;T&gt; removedElements)</code>
	 * <li><code>void fieldNameRemoved(List&lt;Integer&gt; indices, List&lt;T&gt; removedElements)</code> - only supported for lists
	 * <li><code>void fieldNameRemoved(String fieldName, List&lt;Integer&gt; indices, List&lt;T&gt; removedElements)</code> - only supported for lists
	 * <li><code>void fieldNameRemoved(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;T&gt; removedElements)</code> - not supported for lists
	 * <li><code>void fieldNameRemoved(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;T&gt; removedElements)</code> - not supported for lists
	 * <li><code>void fieldNameRemoved(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;Integer&gt; indices, List&lt;T&gt; removedElements)</code> - only supported for lists
	 * <li><code>void fieldNameRemoved(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;Integer&gt; indices, List&lt;T&gt; removedElements)</code> - only supported for lists
	 * </ul>
	 * 
	 * <p>The main difference is that the found method is not called for each element, but for all elements
	 * which have been removed.</p>
	 * 
	 * <p>If a method based on {@link RemoverRule#afterElementRemove} and a method based on this attribute
	 * are found, the method based on this attribute will be called after the method for each individual
	 * element.</p>
	 * 
	 * <p>In addition to parameters described in the mentioned {@link RemoverRule#afterElementRemove}, the referenced
	 * methods here also support:</p>
	 * <li><code>removedElements</code> contains all removed elements in the collection before the change (read-only)
	 * <li><code>indices</code> contains all removed indices in the collection before the change (read-only, in the same order as <code>removedElements</code>)
	 * 
	 * @see RemoverRule#afterElementRemove
	 * @see RemoverRule#beforeRemove
	 */
	String afterRemove = ""

}

/**
 * <p>This annotation can mark field, for which also <code>GetterRule</code>, <code>SetterRule</code> or
 * <code>AdderRule</code> is annotated. It ensures via assertions that <code>null</code> cannot be assigned or added, 
 * at least not via setter/adder. It is ensured the same way, that such a value can also not be retrieved via
 * getter.</p>
 * 
 * <p>Please note, that this annotation should not be used together with {@link BidirectionalRule}, because used
 * algorithms require to temporarily disconnect bidirectional connections. This means, that <code>null</code> must
 * be set.</p>
 * 
 * @see GetterRule
 * @see SetterRule
 * @see AdderRule
 */
@Target(ElementType.FIELD)
@Active(NotNullRuleProcessor)
annotation NotNullRule {

	/**
	 * <p>Determines if <code>null</code> is allowed for the value of the field itself.</p>
	 */
	boolean notNullSelf = true

	/**
	 * <p>This flag is only relevant, if the annotation is used together with {@link AdderRule}.</p>
	 * 
	 * <p>Determines if <code>null</code> is allowed as element of a collection (<code>java.util.Collection</code>) or as the key of a key/value pair (<code>java.util.Map</code>).</p>
	 */
	boolean notNullKeyOrElement = false

	/**
	 * <p>This flag is only relevant, if the annotation is used together with {@link AdderRule}.</p>
	 * 
	 * <p>Determines if <code>null</code> is allowed as value of a key/value pair (<code>java.util.Map</code>).</p>
	 */
	boolean notNullValue = false

}

/**
 * <p>This attribute can be set, if the field has applied a setter or adder/remover rule. In addition,
 * the field's type must be a simple type reference or a set of type references.</p>
 * 
 * <p>With this rule 1:0..1, 1:n or n:m relations between types can be realized.</p>
 * 
 * <p>The rule ensures that the "opposite field" in another object adjusted automatically as soon as
 * the annotated field is changed.</p>
 * 
 * <p>For example, if there are classes <code>A</code> and <code>B</code>.
 * Class <code>A</code> has a field <code>b</code> (type <code>B</code>) and class <code>B</code> has
 * a field <code>a</code> (type <code>A</code>). The target in this case is a 1:0..1 relationship
 * between these classes via these fields. Therefore, both are annotated by this rule. In addition,
 * setters for both fields are generated. If now field <code>b</code> of an object <code>a1</code>
 * (type <code>A</code>) is changed to an object <code>b1</code> (type <code>A</code>), field 
 * <code>a</code> of <code>b1</code> will also be changed to <code>a1</code>. For this, the according
 * (generated) setter will be called. </p>
 * 
 * <p>This schema works in a similar way for 1:n or m:n relationships, i.e. there are fields of type
 * <code>java.util.Set</code>, which must be parameterized in order to find the "opposite field".
 * The major difference is that adders/removers must be called for sets.</p>
 * 
 * <p>Of course, the called mechanisms also ensure that previous bidirectional connections are disconnected,
 * if necessary. Therefore, it can be dangerous to use the {@link NotNullRule} together with this rule, e.g.
 * in case of a 1:0..1 relationship both sides should not be annotated accordingly.</p>
 * 
 * <p>While the mechanisms in general do not search for fields but for the setter/adders/removers in the
 * "opposite class", the rule should be used with generated setter/adders/removers. Of course, the rule
 * should also be annotated on both sides in a correlating way.</p>
 * 
 * <p>If this annotation is used, it should be avoided to throw exceptions within change methods, which are
 * called before the actual change, e.g. set via <code>beforeSet</code> in {@link SetterRule}. 
 * When executing them, there might be inconsistent connection states. If throwing an exception, this
 * state would remain.</p>
 */
@Target(ElementType.FIELD)
@Active(BidirectionalRuleProcessor)
annotation BidirectionalRule {

	/**
	 * <p>This attribute specifies the name of the "opposite" field via <code>String</code>.</p>
	 */
	String value = ""

}

/**
 * <p>This attribute can be set in order to synchronize getter/setter/adder/remover operations
 * for a field. With the attribute a named for the lock must be specified. This lock name is considered in a global
 * namespace, i.e. different fields can share the same lock by using the same name. This can
 * be important in context of setter/adder/remover operations which have to create/remove bidirectional
 * connections. In this case, both sides (fields) should use the same lock name, if
 * thread-safe behavior is required.</p>
 * 
 * <p>Internally, fair reentrant read/write locks are used, i.e. multiple getter methods can run in parallel.</p>
 * 
 * @see BidirectionalRule
 */
@Target(ElementType.FIELD)
@Active(SynchronizationRuleProcessor)
annotation SynchronizationRule {

	/**
	 * <p>This attribute specifies the name of the lock, which shall be used (global namespace).</p>
	 */
	String value = ""

}

/**
 * <p>Base class for setter/getter annotation processors.</p>
 */
abstract class GetterSetterRuleProcessor extends RuleProcessor<FieldDeclaration, MutableFieldDeclaration> {

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration
	}

	/** 
	 * Helper class for storing information about rule.
	 */
	static abstract class GetterSetterRuleInfo {

		public Visibility visibility = Visibility.PUBLIC

	}

	/** 
	 * This helper class considers a parameter declaration for a virtual method 
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
	 * This helper class considers a method declaration on basis of a field (annotated by getter/setter rule) 
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

		override getVisibility() { if(supportsBidirectional) return visibility else return Visibility.PRIVATE }

		override isDeprecated() { return false }

		override findAnnotation(Type annotationType) { return fieldDeclaration.findAnnotation(annotationType) }

		override getAnnotations() { return fieldDeclaration.annotations }

		override getCompilationUnit() { return fieldDeclaration.compilationUnit }

		/**
		 * This method returns, if the method represented by this class will take care about bidirectional settings.
		 */
		def boolean supportsBidirectional() {
			return true
		}

		/**
		 * This method returns the basic implementation of the method represented by this class.
		 */
		abstract def String getBasicImplementation()

		/** Returns the not null rule information from the annotated field. */
		def NotNullRuleInfo getNotNullRuleInfo() {

			if (fieldDeclaration.hasAnnotation(NotNullRule))
				return NotNullRuleProcessor.getNotNullInfo(fieldDeclaration, context)
			return null

		}

	}

	/**
	 * Retrieves information from annotation.
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
	 * Retrieves info from annotation (non-static)
	 */
	abstract def GetterSetterRuleInfo getInfo(FieldDeclaration annotatedField, extension TypeLookup context)

	/**
	 * Replaces the placeholder symbol "%" in a given method name string with the field's name, whereas
	 * the first letter will be upper case, if "%" is NOT at the first place.
	 */
	static def String insertFieldName(FieldDeclaration fieldDeclaration, String methodNameWithPlaceholder) {

		var result = methodNameWithPlaceholder

		if (result.startsWith("%"))
			result = fieldDeclaration.simpleName + result.substring(1, result.length)

		result = result.replaceAll("\\%", fieldDeclaration.simpleName.toFirstUpper)

		return result

	}

	/**
	 * Returns the name of the opposite field or <code>null</code>, if not specified.
	 */
	static def String getOppositeFieldName(FieldDeclaration fieldDeclaration, extension TypeLookup context) {

		if (fieldDeclaration.hasAnnotation(BidirectionalRule))
			BidirectionalRuleProcessor::getBidirectionalRuleInfo(fieldDeclaration, context).oppositeField
		else
			null

	}

	/**
	 * Returns the synchronization lock name for this field or <code>null</code>, if not specified.
	 */
	static def String getSynchronizationLockName(FieldDeclaration fieldDeclaration, extension TypeLookup context) {

		if (fieldDeclaration.hasAnnotation(SynchronizationRule))
			SynchronizationRuleProcessor::getSynchronizationRuleInfo(fieldDeclaration, context).lockName
		else
			null

	}

	/**
	 * Returns the code which shall be used to refer to "this" (is "$extendedThis()" within trait classes)
	 */
	static def String getThisCode(FieldDeclaration fieldDeclaration) {

		// special return value inside of trait class
		if (fieldDeclaration.declaringType.hasAnnotation(TraitClass))
			return "$extendedThis()"

		return "this"

	}

	/**
	 * Retrieves a method, which shall be called on a specific event (e.g. changing the value of a field,
	 * adding an element to the field's collection etc.).
	 * 
	 * The method can be specified by a name (supporting wildcards) and the given parameter filter.
	 * 
	 * If matching method can be found, <code>null</code> is returned.
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodCallX(
		FieldDeclaration annotatedField,
		String eventDescription,
		String methodName,
		(Iterable<? extends ParameterDeclaration>)=>Boolean methodParamFilter,
		Class<?> requiredFieldType,
		List<String> errors,
		extension T context
	) {

		if (requiredFieldType !== null &&
			!context.newTypeReference(requiredFieldType).type.
				isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)) {

			if (!methodName.isNullOrEmpty)
				errors?.add('''Field "«annotatedField.simpleName»" does not support event "«eventDescription»"''')
			return null

		}

		if (methodName.isNullOrEmpty)
			return null

		val classDeclaration = annotatedField.declaringType as ClassDeclaration

		// retrieve all methods which could be called
		val allMethods = classDeclaration.getMethodClosure(null, null, true, true, true, true, context)

		// filter for methods with name matching to specified one (considering placeholders for the field's name)
		// and unify (no need for type matching)
		val methodNameToSearch = insertFieldName(annotatedField, methodName)
		val methodsWithMatchingNameAndTypes = allMethods.filter [
			simpleName == methodNameToSearch
		].filter[methodParamFilter.curry(parameters).apply].unifyMethodDeclarations(TypeMatchingStrategy.MATCH_ALL,
			TypeMatchingStrategy.MATCH_ALL, null, false, null, context)

		if (methodsWithMatchingNameAndTypes.size == 0) {
			errors?.
				add('''Cannot find method "«methodNameToSearch»", which shall be called on event "«eventDescription»" for field "«annotatedField.simpleName»"''')
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
		if (xtendField.visibility == Visibility.PUBLIC)
			xtendField.
				addError('''A field with @«getProcessedAnnotationType().simpleName» must not be declared public''')

		// check for abstract modifier
		if (getterSetterRuleInfo.visibility != Visibility.PUBLIC &&
			getterSetterRuleInfo.visibility != Visibility.PROTECTED)
			xtendField.addError('''Only public and protected methods can be generated''')

	}

}

/**
 * Active Annotation Processor for {@link GetterRule}
 * 
 * @see GetterRule
 */
class GetterRuleProcessor extends GetterSetterRuleProcessor {

	static class GetterRuleInfo extends GetterSetterRuleInfo {

		public CollectionGetterPolicy collectionPolicy = CollectionGetterPolicy.UNMODIFIABLE

	}

	/**
	 * Specifies characteristics of getX / isX method virtually. 
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
	 * Retrieves information from annotation (@GetterRule).
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
 * Active Annotation Processor for {@link SetterRule}
 * 
 * @see SetterRule
 */
class SetterRuleProcessor extends GetterSetterRuleProcessor {

	static class SetterRuleInfo extends GetterSetterRuleInfo {

		public String beforeChange = ""
		public String afterChange = ""

	}

	/**
	 * Specifies characteristics of setX method virtually. 
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
					«IF supportsBidirectional && !oppositeFieldName.isNullOrEmpty»"«oppositeFieldName»"«ELSE»null«ENDIF»,
					«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''

		}

	}

	protected override getProcessedAnnotationType() {
		SetterRule
	}

	/**
	 * Retrieves information from annotation (@GetterRule).
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
	 * This method embeds a method call for setter events (code) in the appropriate object. 
	 */
	static def String getSetterMethodCallEmbedded(MethodDeclaration methodDeclaration, Class<?> interfaceType,
		boolean isBoolean, FieldDeclaration fieldDeclaration, String parameters,
		extension TypeReferenceProvider context) {

		val methodDeclarationBoolean = (context.primitiveBoolean == methodDeclaration.returnType)
		val objectTypeString = fieldDeclaration.type.getTypeReferenceAsString(true, false, false, true, context)
		return '''new org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.«interfaceType.simpleName»<«objectTypeString»>() {
				@Override
				public «IF isBoolean»boolean«ELSE»void«ENDIF» call(«objectTypeString» oldValue, «objectTypeString» newValue) {
					«IF isBoolean && methodDeclarationBoolean»return «ENDIF»«methodDeclaration.simpleName»(«parameters»);
					«IF isBoolean && !methodDeclarationBoolean»return true;«ENDIF»
				}
			}'''

	}

	/**
	 * Get method for event "before change"
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
	 * Gets the call (string) of the method for event "before change"
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
	 * Get method for event "after change"
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
	 * Gets the call (string) of the method for event "after change"
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

/**
 * Base class for adder/remover annotation processors.
 */
abstract class AdderRemoverRuleProcessor extends GetterSetterRuleProcessor {

	static class AdderRemoverRuleInfo extends GetterSetterRuleInfo {

		public boolean single = true
		public boolean multiple = false

	}

	/** 
	 * This helper class considers a method declaration on basis of a field (annotated by adder/remover rule) 
	 */
	static abstract class MethodDeclarationFromAdderRemover<T extends TypeLookup & TypeReferenceProvider> extends MethodDeclarationFromGetterSetter<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		/**
		 * Returns a string for casting the given collection type to a compatible one.
		 */
		protected def String getCastedCollectionTypeStringForChanging(Class<?> collectionType) {

			if (fieldDeclaration.type.actualTypeArguments.size == 2) {
				if ((fieldDeclaration.type.actualTypeArguments.get(0).isWildCard &&
					fieldDeclaration.type.actualTypeArguments.get(0).upperBound !== null) ||
					(fieldDeclaration.type.actualTypeArguments.get(1).isWildCard &&
						fieldDeclaration.type.actualTypeArguments.get(1).upperBound !== null))
					return "(" + context.newTypeReference(collectionType, #[
								{
						if (fieldDeclaration.type.actualTypeArguments.get(0).isWildCard &&
							fieldDeclaration.type.actualTypeArguments.get(0).upperBound !== null)
							fieldDeclaration.type.actualTypeArguments.get(0).upperBound
						else
							fieldDeclaration.type.actualTypeArguments.get(0)
					}, {
						if (fieldDeclaration.type.actualTypeArguments.get(1).isWildCard &&
							fieldDeclaration.type.actualTypeArguments.get(1).upperBound !== null)
							fieldDeclaration.type.actualTypeArguments.get(1).upperBound
						else
							fieldDeclaration.type.actualTypeArguments.get(1)
					}]).getTypeReferenceAsString(true, false, false, false, context) + ")"

			}

			if (fieldDeclaration.type.actualTypeArguments.size == 1) {
				if (fieldDeclaration.type.actualTypeArguments.get(0).isWildCard &&
					fieldDeclaration.type.actualTypeArguments.get(0).upperBound !== null)
					return "(" +
						context.newTypeReference(collectionType,
							fieldDeclaration.type.actualTypeArguments.get(0).upperBound).
							getTypeReferenceAsString(true, false, false, false, context) + ")"

			}

			return ""

		}

		protected def TypeReference getCollectionTypeArgument(int index) {
			return getCollectionTypeArgument(fieldDeclaration, index, context)
		}

		protected def String getCollectionTypeArgumentAsString(int index) {
			return getCollectionTypeArgumentAsString(fieldDeclaration, index, context)
		}

	}

	/**
	 * Retrieves the type arguments of the field's collection/map type. Thereby, it considers wild cards and
	 * boundaries. If no information is available, <code>java.lang.Object</code> as type reference is returned.
	 */
	static def TypeReference getCollectionTypeArgument(FieldDeclaration fieldDeclaration, int index,
		TypeReferenceProvider context) {

		return if (fieldDeclaration.type.actualTypeArguments.size >= index + 1) {
			if (fieldDeclaration.type.actualTypeArguments.get(index).isWildCard &&
				fieldDeclaration.type.actualTypeArguments.get(index).upperBound !== null) {
				fieldDeclaration.type.actualTypeArguments.get(index).upperBound
			} else {
				fieldDeclaration.type.actualTypeArguments.get(index)
			}
		} else {
			context.object
		}

	}

	/**
	 * Retrieves the type arguments of the field's collection/map type as a string.
	 * 
	 * @see #getCollectionTypeArgument
	 */
	static def String getCollectionTypeArgumentAsString(FieldDeclaration fieldDeclaration, int index,
		TypeReferenceProvider context) {

		return getCollectionTypeArgument(fieldDeclaration, index, context).getTypeReferenceAsString(true, false, false,
			false, context)

	}

	/**
	 * This method embeds a method call for collection events (code) in the appropriate object. 
	 */
	static def String getCollectionMethodCallEmbedded(MethodDeclaration methodDeclaration, Class<?> interfaceType,
		boolean isBoolean, boolean multiple, FieldDeclaration fieldDeclaration, String parameters,
		extension TypeReferenceProvider context) {

		val methodDeclarationBoolean = (context.primitiveBoolean == methodDeclaration.returnType)
		return '''new org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.«interfaceType.simpleName»<«getCollectionTypeArgumentAsString(fieldDeclaration, 0, context)»>() {
				@Override
				public «IF isBoolean»boolean«ELSE»void«ENDIF» call(«IF multiple»java.util.List<«getCollectionTypeArgumentAsString(fieldDeclaration, 0, context)»> $_elements«ELSE»«getCollectionTypeArgument(fieldDeclaration, 0, context)» $_element«ENDIF», «IF multiple»java.util.List<Integer> $_indices«ELSE»int $_index«ENDIF», java.util.List<«getCollectionTypeArgumentAsString(fieldDeclaration, 0, context)»> $_oldElements«IF !isBoolean», java.util.List<«getCollectionTypeArgumentAsString(fieldDeclaration, 0, context)»> $_newElements«ENDIF») {
					«IF isBoolean && methodDeclarationBoolean»return «ENDIF»«methodDeclaration.simpleName»(«parameters»);
					«IF isBoolean && !methodDeclarationBoolean»return true;«ENDIF»
				}
			}'''

	}

	static def void fillInfoFromAnnotationBase(AnnotationReference annotationGetterSetterRule,
		AdderRemoverRuleInfo adderRemoverRuleInfo, extension TypeLookup context) {

		GetterSetterRuleProcessor.fillInfoFromAnnotationBase(annotationGetterSetterRule, adderRemoverRuleInfo, context)

		if (adderRemoverRuleInfo === null)
			return;

		adderRemoverRuleInfo.single = annotationGetterSetterRule.getBooleanValue("single")
		adderRemoverRuleInfo.multiple = annotationGetterSetterRule.getBooleanValue("multiple")

	}

	abstract override AdderRemoverRuleInfo getInfo(FieldDeclaration annotatedField, extension TypeLookup context)

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		var FieldDeclaration xtendField = annotatedField.primarySourceElement as FieldDeclaration

		val adderRemoverRuleInfo = getInfo(xtendField, context)

		// check if flags are consistent
		if (adderRemoverRuleInfo.single == false && adderRemoverRuleInfo.multiple == false)
			xtendField.addError('''Cannot set both flags "single" and "multiple" to false''')

		// check if used with collection
		if (xtendField.type !== null &&
			!context.newTypeReference(Collection).type.
				isAssignableFromConsiderUnprocessed(xtendField.type?.type, context) &&
			!context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(xtendField.type?.type, context))
			xtendField.
				addError('''Annotation @«getProcessedAnnotationType.simpleName» can only be used with collection or map type''')

	}

}

/**
 * Active Annotation Processor for {@link AdderRule}
 * 
 * @see AdderRule
 */
class AdderRuleProcessor extends AdderRemoverRuleProcessor {

	final static public String INCOMPLETE_ADD_ERROR = "Used collection type violated expectation that the performed add operation actually has added the given elements"

	static class AdderRuleInfo extends AdderRemoverRuleInfo {

		public String beforeAdd = null
		public String afterAdd = null
		public String beforeElementAdd = null
		public String afterElementAdd = null

	}

	protected override getProcessedAnnotationType() {
		AdderRule
	}

	/**
	 * This helper class considers a method declaration on basis of a field (annotated by adder rule) 
	 */
	static abstract class MethodDeclarationFromAdder<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdderRemover<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		protected def String getBasicImplementation(String preCode, String elements, String index) {

			val notNullRuleInfo = getNotNullRuleInfo
			val oppositeFieldName = getOppositeFieldName(fieldDeclaration, context)
			val synchronizationLockName = getSynchronizationLockName(fieldDeclaration, context)

			if (this instanceof MethodDeclarationFromAdder_PutTo<?> ||
				this instanceof MethodDeclarationFromAdder_PutAllTo<?>)
				return '''«preCode»
					«IF !(this instanceof MethodDeclarationFromAdder_PutAllTo<?>)»return «ENDIF»org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.putToMap(
						«IF !fieldDeclaration.isStatic»this.«ENDIF»«fieldDeclaration.simpleName»,
						«elements»,
						"«fieldDeclaration.simpleName»",
						«IF fieldDeclaration.isStatic»null«ELSE»«getThisCode(fieldDeclaration)»«ENDIF»,
						«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullKeyOrElement»«ELSE»false«ENDIF»,
						«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullValue»«ELSE»false«ENDIF»,
						«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''
			else
				return '''«preCode»
					return org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.addTo«IF index === null && context.newTypeReference(List).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type, context)»List«ELSE»Collection«ENDIF»(
						«IF !fieldDeclaration.isStatic»this.«ENDIF»«fieldDeclaration.simpleName», «elements», «IF index !== null || !context.newTypeReference(List).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type, context)»«IF index === null»0«ELSE»«index»«ENDIF»,«ENDIF»
						«getMethodCallBeforeElementAdd(fieldDeclaration, context)»,
						«getMethodCallBeforeAdd(fieldDeclaration, context)»,
						«getMethodCallAfterElementAdd(fieldDeclaration, context)»,
						«getMethodCallAfterAdd(fieldDeclaration, context)»,
						"«fieldDeclaration.simpleName»",
						«IF fieldDeclaration.isStatic»null«ELSE»«getThisCode(fieldDeclaration)»«ENDIF»,
						«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullKeyOrElement»«ELSE»false«ENDIF»,
						«IF supportsBidirectional && !oppositeFieldName.isNullOrEmpty»"«oppositeFieldName»"«ELSE»null«ENDIF»,
						«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''

		}

	}

	/**
	 * Specifies characteristics of addToX method virtually. 
	 */
	static class MethodDeclarationFromAdder_AddTo<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdder<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { return context.primitiveBoolean }

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(new ParameterDeclarationForVirtualMethod(this, getCollectionTypeArgument(0), "$element"))
			return result

		}

		override getDocComment() {
			return '''This is a generated adder method for adding an element to {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "addTo" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {

			return getBasicImplementation('''java.util.List<«getCollectionTypeArgumentAsString(0)»> $elements = new java.util.ArrayList<«getCollectionTypeArgumentAsString(0)»>();
					$elements.add($element);''', "$elements", null)

		}

	}

	/**
	 * Specifies characteristics of addToX (indexed) method virtually. 
	 */
	static class MethodDeclarationFromAdder_AddToIndexed<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdder_AddTo<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(new ParameterDeclarationForVirtualMethod(this, context.primitiveInt, "$index"))
			result.addAll(super.parameters)
			return result

		}

		override getDocComment() {
			return '''This is a generated adder method for adding an element to {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)} at the specified index.'''
		}

		override String getBasicImplementation() {

			return getBasicImplementation('''java.util.List<«getCollectionTypeArgumentAsString(0)»> $elements = new java.util.ArrayList<«getCollectionTypeArgumentAsString(0)»>();
					$elements.add($element);''', "$elements", "$index")

		}

	}

	/**
	 * Specifies characteristics of putToX method virtually. 
	 */
	static class MethodDeclarationFromAdder_PutTo<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdder<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { return getCollectionTypeArgument(1) }

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(new ParameterDeclarationForVirtualMethod(this, getCollectionTypeArgument(0), "$key"))
			result.add(new ParameterDeclarationForVirtualMethod(this, getCollectionTypeArgument(1), "$value"))
			return result

		}

		override getDocComment() {
			return '''This is a generated adder method for putting a key/value pair to {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "putTo" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {
			return getBasicImplementation('''java.util.Map<«getCollectionTypeArgumentAsString(0)», «getCollectionTypeArgumentAsString(1)»> $m = new java.util.HashMap<«getCollectionTypeArgumentAsString(0)», «getCollectionTypeArgumentAsString(1)»>();
					$m.put($key, $value);''', "$m", null)
		}

	}

	/**
	 * Specifies characteristics of addAllToX method virtually. 
	 */
	static class MethodDeclarationFromAdder_AddAllTo<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdder_AddTo<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { return context.primitiveBoolean }

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(
				new ParameterDeclarationForVirtualMethod(this,
					context.newTypeReference(Collection,
						context.newWildcardTypeReference(getCollectionTypeArgument(0))), "$c"))
			return result

		}

		override getDocComment() {
			return '''This is a generated adder method for adding multiple elements to {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "addAllTo" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {
			return getBasicImplementation("", "$c", null)
		}

	}

	/**
	 * Specifies characteristics of addAllToX (indexed) method virtually. 
	 */
	static class MethodDeclarationFromAdder_AddAllToIndexed<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdder_AddAllTo<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(new ParameterDeclarationForVirtualMethod(this, context.primitiveInt, "$index"))
			result.addAll(super.parameters)
			return result

		}

		override getDocComment() {
			return '''This is a generated adder method for adding multiple element to {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)} at the specified index.'''
		}

		override String getBasicImplementation() {
			return getBasicImplementation("", "$c", "$index")
		}

	}

	/**
	 * Specifies characteristics of putAllToX method virtually. 
	 */
	static class MethodDeclarationFromAdder_PutAllTo<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdder<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { context.primitiveVoid }

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(
				new ParameterDeclarationForVirtualMethod(this,
					context.newTypeReference(Map,
						#[context.newWildcardTypeReference(getCollectionTypeArgument(0)),
							context.newWildcardTypeReference(getCollectionTypeArgument(1))]), "$m"))
			return result

		}

		override getDocComment() {
			return '''This is a generated adder method for putting multiple key/value pairs to {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "putAllTo" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {
			return getBasicImplementation("", "$m", null)
		}

	}

	/**
	 * Retrieves information from annotation (@AdderRule).
	 */
	static def AdderRuleInfo getAdderInfo(FieldDeclaration annotatedField, extension TypeLookup context) {

		val adderRuleInfo = new AdderRuleInfo
		val annotationSetterRule = annotatedField.getAnnotation(AdderRule)

		fillInfoFromAnnotationBase(annotationSetterRule, adderRuleInfo, context)

		adderRuleInfo.beforeAdd = annotationSetterRule.getStringValue("beforeAdd")
		adderRuleInfo.afterAdd = annotationSetterRule.getStringValue("afterAdd")
		adderRuleInfo.beforeElementAdd = annotationSetterRule.getStringValue("beforeElementAdd")
		adderRuleInfo.afterElementAdd = annotationSetterRule.getStringValue("afterElementAdd")

		return adderRuleInfo

	}

	/**
	 * Get method for event "before add"
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodBeforeAdd(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"before add",
			getAdderInfo(annotatedField, context).beforeAdd,
			[
				it.length == 0 || (it.length == 1 && context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 2 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 2 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 3 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 4 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type))
			],
			Collection,
			errors,
			context
		)

	}

	/**
	 * Gets the call (string) of the method for event "before add"
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallBeforeAdd(
		FieldDeclaration annotatedField, extension T context) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		val method = getMethodBeforeAdd(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, MethodCallCollectionNameMultipleIndexBoolean, true, true,
			annotatedField, if (method.parameters.length == 0)
				''''''
			else if (method.parameters.length == 1)
				'''$_elements'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_elements'''
			else if (method.parameters.length == 2 && indexSupported)
				'''$_indices, $_elements'''
			else if (method.parameters.length == 2 && !indexSupported)
				'''$_oldElements, $_elements'''
			else if (method.parameters.length == 3 && indexSupported &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_indices, $_elements'''
			else if (method.parameters.length == 3 && !indexSupported &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_oldElements, $_elements'''
			else if (method.parameters.length == 3)
				'''$_oldElements, $_indices, $_elements'''
			else if (method.parameters.length == 4)
				'''"«annotatedField.simpleName»", $_oldElements, $_indices, $_elements'''
			else
				throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" before adding to field "«annotatedField.simpleName»": unknown signature'''),
			context)

	}

	/**
	 * Get method for event "after add"
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodAfterAdd(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"after add",
			getAdderInfo(annotatedField, context).afterAdd,
			[
				it.length == 0 || (it.length == 1 && context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 2 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 3 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 4 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(it.length == 4 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(it.length == 5 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(4).type))
			],
			Collection,
			errors,
			context
		)

	}

	/**
	 * Gets the call (string) of the method for event "after add"
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallAfterAdd(
		FieldDeclaration annotatedField, extension T context) {

		val method = getMethodAfterAdd(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, MethodCallCollectionNameMultipleIndexVoid, false, true,
			annotatedField, if (method.parameters.length == 0)
				''''''
			else if (method.parameters.length == 1)
				'''$_elements'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_elements'''
			else if (method.parameters.length == 2)
				'''$_indices, $_elements'''
			else if (method.parameters.length == 3 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_indices, $_elements'''
			else if (method.parameters.length == 3)
				'''$_oldElements, $_newElements, $_elements'''
			else if (method.parameters.length == 4 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_oldElements, $_newElements, $_elements'''
			else if (method.parameters.length == 4)
				'''$_oldElements, $_newElements, $_indices, $_elements'''
			else if (method.parameters.length == 5)
				'''"«annotatedField.simpleName»", $_oldElements, $_newElements, $_indices, $_elements'''
			else
				throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" after adding to field "«annotatedField.simpleName»": unknown signature'''),
			context)

	}

	/**
	 * Get method for event "before element add"
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodBeforeElementAdd(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"before element add",
			getAdderInfo(annotatedField, context).beforeElementAdd,
			[
				it.length == 1 ||
					(it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type)) ||
					(it.length == 2 && indexSupported && it.get(0).type == context.primitiveInt) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(it.length == 2 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(it.length == 3 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(it.length == 4 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						it.get(2).type == context.primitiveInt)
			],
			Collection,
			errors,
			context
		)

	}

	/**
	 * Gets the call (string) of the method for event "before element add"
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallBeforeElementAdd(
		FieldDeclaration annotatedField, extension T context) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		val method = getMethodBeforeElementAdd(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, MethodCallCollectionNameSingleIndexBoolean, true, false,
			annotatedField, if (method.parameters.length == 1)
				'''$_element'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_element'''
			else if (method.parameters.length == 2 && method.parameters.get(0).type == context.primitiveInt)
				'''$_index, $_element'''
			else if (method.parameters.length == 2)
				'''$_oldElements, $_element'''
			else if (method.parameters.length == 3 && indexSupported &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_index, $_element'''
			else if (method.parameters.length == 3 && !indexSupported &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_oldElements, $_element'''
			else if (method.parameters.length == 3)
				'''$_oldElements, $_index, $_element'''
			else if (method.parameters.length == 4)
				'''"«annotatedField.simpleName»", $_oldElements, $_index, $_element'''
			else
				throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" before adding to field "«annotatedField.simpleName»" (element): unknown signature'''),
			context)

	}

	/**
	 * Get method for event "after element add"
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodAfterElementAdd(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"after element add",
			getAdderInfo(annotatedField, context).afterElementAdd,
			[
				it.length == 1 ||
					(it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type)) ||
					(it.length == 2 && indexSupported && it.get(0).type == context.primitiveInt) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(it.length == 3 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 4 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 4 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						it.get(2).type == context.primitiveInt) ||
					(it.length == 5 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						it.get(3).type == context.primitiveInt)
			],
			Collection,
			errors,
			context
		)

	}

	/**
	 * Gets the call (string) of the method for event "after element add"
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallAfterElementAdd(
		FieldDeclaration annotatedField, extension T context) {

		val method = getMethodAfterElementAdd(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, MethodCallCollectionNameSingleIndexVoid, false, false,
			annotatedField, if (method.parameters.length == 1)
				'''$_element'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_element'''
			else if (method.parameters.length == 2)
				'''$_index, $_element'''
			else if (method.parameters.length == 3 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_index, $_element'''
			else if (method.parameters.length == 3)
				'''$_oldElements, $_newElements, $_element'''
			else if (method.parameters.length == 4 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_oldElements, $_newElements, $_element'''
			else if (method.parameters.length == 4)
				'''$_oldElements, $_newElements, $_index, $_element'''
			else if (method.parameters.length == 5)
				'''"«annotatedField.simpleName»", $_oldElements, $_newElements, $_index, $_element'''
			else
				throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" after adding to field "«annotatedField.simpleName»" (element): unknown signature'''),
			context)

	}

	override AdderRuleInfo getInfo(FieldDeclaration annotatedField, extension TypeLookup context) {
		return getAdderInfo(annotatedField, context)
	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		// check event methods for errors
		val errors = new ArrayList<String>
		getMethodBeforeAdd(annotatedField, errors, context)
		getMethodAfterAdd(annotatedField, errors, context)
		getMethodBeforeElementAdd(annotatedField, errors, context)
		getMethodAfterElementAdd(annotatedField, errors, context)
		xtendField.reportErrors(errors, context)

	}

}

/**
 * Active Annotation Processor for {@link RemoverRule}
 * 
 * @see RemoverRule
 */
class RemoverRuleProcessor extends AdderRemoverRuleProcessor {

	final static public String INCOMPLETE_REMOVE_ERROR = "Used collection type violated expectation that the performed remove operation actually has removed the given elements"

	static class RemoverRuleInfo extends AdderRemoverRuleInfo {

		public String beforeRemove = null
		public String afterRemove = null
		public String beforeElementRemove = null
		public String afterElementRemove = null

	}

	protected override getProcessedAnnotationType() {
		RemoverRule
	}

	/** 
	 * This helper class considers a method declaration on basis of a field (annotated by remover rule) 
	 */
	static abstract class MethodDeclarationFromRemover<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdderRemover<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		protected def String getBasicImplementation(String preCode, String elementName, String index,
			boolean multiple) {

			val oppositeFieldName = getOppositeFieldName(fieldDeclaration, context)
			val synchronizationLockName = getSynchronizationLockName(fieldDeclaration, context)

			return '''«preCode»
				return org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.removeFromCollection(
					«fieldDeclaration.simpleName», «elementName», «index», «multiple»,
					«getMethodCallBeforeElementRemove(fieldDeclaration, context)»,
					«getMethodCallBeforeRemove(fieldDeclaration, context)»,
					«getMethodCallAfterElementRemove(fieldDeclaration, context)»,
					«getMethodCallAfterRemove(fieldDeclaration, context)»,
					"«fieldDeclaration.simpleName»",
					«IF fieldDeclaration.isStatic»null«ELSE»«getThisCode(fieldDeclaration)»«ENDIF»,
					«IF supportsBidirectional && !oppositeFieldName.isNullOrEmpty»"«oppositeFieldName»"«ELSE»null«ENDIF»,
					«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''

		}

	}

	/**
	 * Specifies characteristics of removeFromX method virtually. 
	 */
	static class MethodDeclarationFromRemover_RemoveFrom<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromRemover<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() {

			if (context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type,
				context)) {
				return getCollectionTypeArgument(1)
			} else {
				return context.primitiveBoolean
			}

		}

		protected def String getFirstParameterName() {

			if (context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type,
				context))
				return "$key"
			else
				return "$element"

		}

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(
				new ParameterDeclarationForVirtualMethod(this, getCollectionTypeArgument(0), getFirstParameterName()))
			return result

		}

		override getDocComment() {

			if (context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type,
				context))
				return '''This is a generated remover method for removing a key/value pair from {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)} via key.'''
			else
				return '''This is a generated remover method for removing an element from {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''

		}

		override getSimpleName() {
			return "removeFrom" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {

			if (context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type,
				context)) {

				val synchronizationLockName = getSynchronizationLockName(fieldDeclaration, context)

				return '''return org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.removeFromMap(
					«fieldDeclaration.simpleName», «getFirstParameterName()»,
					"«fieldDeclaration.simpleName»",
					«IF fieldDeclaration.isStatic»null«ELSE»«getThisCode(fieldDeclaration)»«ENDIF»,
					«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''

			} else {

				return getBasicImplementation('''java.util.List<«getCollectionTypeArgumentAsString(0)»> $elements = new java.util.ArrayList<«getCollectionTypeArgumentAsString(0)»>();
					$elements.add($element);''', "$elements", "null", false)

			}

		}

	}

	/**
	 * Specifies characteristics of removeFromX (indexed) method virtually. 
	 */
	static class MethodDeclarationFromRemover_RemoveFromIndexed<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromRemover_RemoveFrom<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() {

			return context.primitiveBoolean

		}

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(new ParameterDeclarationForVirtualMethod(this, context.primitiveInt, "$index"))
			return result

		}

		override getDocComment() {
			return '''This is a generated remover method for removing an element from {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)} at the specified index.'''
		}

		override getSimpleName() {
			return "removeFrom" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {
			return getBasicImplementation('''java.util.List<«getCollectionTypeArgumentAsString(0)»> $elements = new java.util.ArrayList<«getCollectionTypeArgumentAsString(0)»>(«fieldDeclaration.simpleName»);''',
				"null", "$index", false)
		}

	}

	/**
	 * Specifies characteristics of removeFromX (indexed) method virtually. 
	 */
	static class MethodDeclarationFromRemover_RemoveAllFrom<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromRemover_RemoveFrom<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { return context.primitiveBoolean }

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(
				new ParameterDeclarationForVirtualMethod(this,
					context.newTypeReference(Collection,
						context.newWildcardTypeReference(getCollectionTypeArgument(0))), "$c"))
			return result

		}

		override getDocComment() {
			return '''This is a generated remover method for removing multiple elements from {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "removeAllFrom" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {
			return getBasicImplementation("", "$c", "null", true)
		}

	}

	/**
	 * Specifies characteristics of clearX method virtually. 
	 */
	static class MethodDeclarationFromRemover_Clear<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromRemover_RemoveFrom<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { return context.primitiveBoolean }

		override getParameters() {
			return new ArrayList<ParameterDeclaration>
		}

		override getDocComment() {
			return '''This is a generated remover method for clearing all elements from {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "clear" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {

			if (context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type,
				context)) {

				val synchronizationLockName = getSynchronizationLockName(fieldDeclaration, context)

				return '''return org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.clearMap(
					«fieldDeclaration.simpleName»,
					"«fieldDeclaration.simpleName»",
					«IF fieldDeclaration.isStatic»null«ELSE»«getThisCode(fieldDeclaration)»«ENDIF»,
					«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''

			} else {

				return getBasicImplementation('''java.util.List<«getCollectionTypeArgumentAsString(0)»> $elements = new java.util.ArrayList<«getCollectionTypeArgumentAsString(0)»>(«fieldDeclaration.simpleName»);''',
					"$elements", "null", true)

			}

		}

	}

	/**
	 * Retrieves information from annotation (@RemoverRule).
	 */
	static def RemoverRuleInfo getRemoverInfo(FieldDeclaration annotatedField, extension TypeLookup context) {

		val removerRuleInfo = new RemoverRuleInfo
		val annotationSetterRule = annotatedField.getAnnotation(RemoverRule)

		fillInfoFromAnnotationBase(annotationSetterRule, removerRuleInfo, context)

		removerRuleInfo.beforeRemove = annotationSetterRule.getStringValue("beforeRemove")
		removerRuleInfo.afterRemove = annotationSetterRule.getStringValue("afterRemove")
		removerRuleInfo.beforeElementRemove = annotationSetterRule.getStringValue("beforeElementRemove")
		removerRuleInfo.afterElementRemove = annotationSetterRule.getStringValue("afterElementRemove")

		return removerRuleInfo

	}

	/**
	 * Get method for event "before remove"
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodBeforeRemove(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"before remove",
			getRemoverInfo(annotatedField, context).beforeRemove,
			[
				it.length == 0 || (it.length == 1 && context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 2 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 2 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 3 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 4 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type))
			],
			Collection,
			errors,
			context
		)

	}

	/**
	 * Gets the call (string) of the method for event "before remove"
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallBeforeRemove(
		FieldDeclaration annotatedField, extension T context) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		val method = getMethodBeforeRemove(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, MethodCallCollectionNameMultipleIndexBoolean, true, true,
			annotatedField, if (method.parameters.length == 0)
				''''''
			else if (method.parameters.length == 1)
				'''$_elements'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_elements'''
			else if (method.parameters.length == 2 && indexSupported)
				'''$_indices, $_elements'''
			else if (method.parameters.length == 2 && !indexSupported)
				'''$_oldElements, $_elements'''
			else if (method.parameters.length == 3 && indexSupported &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_indices, $_elements'''
			else if (method.parameters.length == 3 && !indexSupported &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_oldElements, $_elements'''
			else if (method.parameters.length == 3)
				'''$_oldElements, $_indices, $_elements'''
			else if (method.parameters.length == 4)
				'''"«annotatedField.simpleName»", $_oldElements, $_indices, $_elements'''
			else
				throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" before removing from field "«annotatedField.simpleName»": unknown signature'''),
			context)

	}

	/**
	 * Get method for event "after remove"
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodAfterRemove(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"after remove",
			getRemoverInfo(annotatedField, context).afterRemove,
			[
				it.length == 0 || (it.length == 1 && context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 2 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 3 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 4 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(it.length == 4 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(it.length == 5 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(4).type))
			],
			Collection,
			errors,
			context
		)

	}

	/**
	 * Gets the call (string) of the method for event "after remove"
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallAfterRemove(
		FieldDeclaration annotatedField, extension T context) {

		val method = getMethodAfterRemove(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, MethodCallCollectionNameMultipleIndexVoid, false, true,
			annotatedField, if (method.parameters.length == 0)
				''''''
			else if (method.parameters.length == 1)
				'''$_elements'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_elements'''
			else if (method.parameters.length == 2)
				'''$_indices, $_elements'''
			else if (method.parameters.length == 3 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_indices, $_elements'''
			else if (method.parameters.length == 3)
				'''$_oldElements, $_newElements, $_elements'''
			else if (method.parameters.length == 4 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_oldElements, $_newElements, $_elements'''
			else if (method.parameters.length == 4)
				'''$_oldElements, $_newElements, $_indices, $_elements'''
			else if (method.parameters.length == 5)
				'''"«annotatedField.simpleName»", $_oldElements, $_newElements, $_indices, $_elements'''
			else
				throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" after removing from field "«annotatedField.simpleName»": unknown signature'''),
			context)

	}

	/**
	 * Get method for event "before element remove"
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodBeforeElementRemove(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"before element remove",
			getRemoverInfo(annotatedField, context).beforeElementRemove,
			[
				it.length == 1 ||
					(it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type)) ||
					(it.length == 2 && indexSupported && it.get(0).type == context.primitiveInt) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(it.length == 2 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(it.length == 3 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(it.length == 4 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						it.get(2).type == context.primitiveInt)
			],
			Collection,
			errors,
			context
		)

	}

	/**
	 * Gets the call (string) of the method for event "before element remove"
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallBeforeElementRemove(
		FieldDeclaration annotatedField, extension T context) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		val method = getMethodBeforeElementRemove(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, MethodCallCollectionNameSingleIndexBoolean, true, false,
			annotatedField, if (method.parameters.length == 1)
				'''$_element'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_element'''
			else if (method.parameters.length == 2 && method.parameters.get(0).type == context.primitiveInt)
				'''$_index, $_element'''
			else if (method.parameters.length == 2)
				'''$_oldElements, $_element'''
			else if (method.parameters.length == 3 && indexSupported &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_index, $_element'''
			else if (method.parameters.length == 3 && !indexSupported &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_oldElements, $_element'''
			else if (method.parameters.length == 3)
				'''$_oldElements, $_index, $_element'''
			else if (method.parameters.length == 4)
				'''"«annotatedField.simpleName»", $_oldElements, $_index, $_element'''
			else
				throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" before removing from field "«annotatedField.simpleName»" (element): unknown signature'''),
			context)

	}

	/**
	 * Get method for event "after element remove"
	 * 
	 * @see GetterSetterRuleProcessor#getMethodCallX
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> MethodDeclaration getMethodAfterElementRemove(
		FieldDeclaration annotatedField,
		List<String> errors,
		extension T context
	) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"after element remove",
			getRemoverInfo(annotatedField, context).afterElementRemove,
			[
				it.length == 1 ||
					(it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type)) ||
					(it.length == 2 && indexSupported && it.get(0).type == context.primitiveInt) ||
					(it.length == 3 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(it.length == 3 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(it.length == 4 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(it.length == 4 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						it.get(2).type == context.primitiveInt) ||
					(it.length == 5 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						it.get(3).type == context.primitiveInt)
			],
			Collection,
			errors,
			context
		)

	}

	/**
	 * Gets the call (string) of the method for event "before element remove"
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallAfterElementRemove(
		FieldDeclaration annotatedField, extension T context) {

		val method = getMethodAfterElementRemove(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, MethodCallCollectionNameSingleIndexVoid, false, false,
			annotatedField, if (method.parameters.length == 1)
				'''$_element'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_element'''
			else if (method.parameters.length == 2)
				'''$_index, $_element'''
			else if (method.parameters.length == 3 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_index, $_element'''
			else if (method.parameters.length == 3)
				'''$_oldElements, $_newElements, $_element'''
			else if (method.parameters.length == 4 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_oldElements, $_newElements, $_element'''
			else if (method.parameters.length == 4)
				'''$_oldElements, $_newElements, $_index, $_element'''
			else if (method.parameters.length == 5)
				'''"«annotatedField.simpleName»", $_oldElements, $_newElements, $_index, $_element'''
			else
				throw new IllegalArgumentException('''Unable to call method "«method.simpleName»" after removing from field "«annotatedField.simpleName»" (element): unknown signature'''),
			context)

	}

	override RemoverRuleInfo getInfo(FieldDeclaration annotatedField, extension TypeLookup context) {
		return getRemoverInfo(annotatedField, context)
	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		// check event methods for errors
		val errors = new ArrayList<String>
		getMethodBeforeRemove(annotatedField, errors, context)
		getMethodAfterRemove(annotatedField, errors, context)
		getMethodBeforeElementRemove(annotatedField, errors, context)
		getMethodAfterElementRemove(annotatedField, errors, context)
		xtendField.reportErrors(errors, context)

	}

}

/**
 * Active Annotation Processor for {@link NotNullRule}
 * 
 * @see SetterRule
 */
class NotNullRuleProcessor extends RuleProcessor<FieldDeclaration, MutableFieldDeclaration> {

	final static public String VALUE_NULL_SETTER_ERROR = "Value of field \"%s\" cannot been set to null"
	final static public String VALUE_NULL_GETTER_ERROR = "Value of field \"%s\" cannot be retrieved, because it has been set to null, which is not allowed"
	final static public String VALUE_NULL_GETTER_KEY_ERROR = "Value of field \"%s\" cannot be retrieved, because a contained element/key has been set to null, which is not allowed"
	final static public String VALUE_NULL_GETTER_VALUE_ERROR = "Value of field \"%s\" cannot be retrieved, because a contained value has been set to null, which is not allowed"
	final static public String VALUE_NULL_ADDER_ERROR = "Cannot add null to \"%s\""
	final static public String VALUE_NULL_ADDER_PUT_KEY_ERROR = "Cannot add null to \"%s\" (key)"
	final static public String VALUE_NULL_ADDER_PUT_VALUE_ERROR = "Cannot add null to \"%s\" (value)"

	static class NotNullRuleInfo {

		public boolean notNullSelf = true
		public boolean notNullKeyOrElement = false
		public boolean notNullValue = false

	}

	override protected getProcessedAnnotationType() {
		NotNullRule
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration || annotatedNamedElement instanceof MethodDeclaration
	}

	/**
	 * Retrieves information from annotation (@NotNullRule).
	 */
	static def NotNullRuleInfo getNotNullInfo(FieldDeclaration annotatedField, extension TypeLookup context) {

		val notNullRuleInfo = new NotNullRuleInfo
		val annotationNotNullRule = annotatedField.getAnnotation(NotNullRule)

		notNullRuleInfo.notNullSelf = annotationNotNullRule.getBooleanValue("notNullSelf")
		notNullRuleInfo.notNullKeyOrElement = annotationNotNullRule.getBooleanValue("notNullKeyOrElement")
		notNullRuleInfo.notNullValue = annotationNotNullRule.getBooleanValue("notNullValue")

		return notNullRuleInfo

	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		val notNullRuleInfo = xtendField.getNotNullInfo(context)

		// check that field has (not inferred) type
		if (xtendField.type === null || xtendField.type.inferred) {
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» does not support fields with inferred type''')
			return
		}

		// check if in context of getter/setter rules		
		if (notNullRuleInfo.notNullSelf && !xtendField.hasAnnotation(SetterRule) &&
			!xtendField.hasAnnotation(GetterRule))
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must be used together with @GetterRule or @SetterRule, if notNullSelf is set''')

		// check if in context of adder rules
		if ((notNullRuleInfo.notNullKeyOrElement || notNullRuleInfo.notNullValue) &&
			!xtendField.hasAnnotation(AdderRule))
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must be used together with @AdderRule, if notNullKeyOrElement or notNullValue is set''')

		// check for concrete types
		if (notNullRuleInfo.notNullKeyOrElement &&
			!context.newTypeReference(Collection).type.
				isAssignableFromConsiderUnprocessed(xtendField.type?.type, context) &&
			!context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(xtendField.type?.type, context))
			xtendField.addError('''If flag notNullKeyOrElement is set, the field must be a collection or map''')
		if (notNullRuleInfo.notNullValue &&
			!context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(xtendField.type?.type, context))
			xtendField.addError('''If flag notNullValue is set, the field must be a map''')

		// check if not used with primitive types
		if (xtendField.type.primitive)
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must not be used with primitive types''')

	}

}

/**
 * Active Annotation Processor for {@link BidirectionalRule}
 * 
 * @see SetterRule
 * @see AdderRule
 * @see RemoverRule
 */
class BidirectionalRuleProcessor extends RuleProcessor<FieldDeclaration, MutableFieldDeclaration> {

	static class BidirectionalRuleInfo {

		public String oppositeField = null

	}

	override protected getProcessedAnnotationType() {
		BidirectionalRule
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration
	}

	/**
	 * Retrieves information from annotation (@BidirectionalRule).
	 */
	static def BidirectionalRuleInfo getBidirectionalRuleInfo(FieldDeclaration annotatedField,
		extension TypeLookup context) {

		val bidirectionalRuleProcessorInfo = new BidirectionalRuleInfo
		val annotationBidirectionalRule = annotatedField.getAnnotation(BidirectionalRule)

		bidirectionalRuleProcessorInfo.oppositeField = annotationBidirectionalRule.getStringValue("value")

		return bidirectionalRuleProcessorInfo

	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		val bidirectionalRuleProcessorInfo = xtendField.getBidirectionalRuleInfo(context)

		// check that field has also setter or adder together with remover
		if (!xtendField.hasAnnotation(SetterRule) &&
			!(xtendField.hasAnnotation(AdderRule) && xtendField.hasAnnotation(RemoverRule))) {
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must only be used, if also @SetterRule or @AdderRule together with @RemoverRule are used''')
			return
		}

		// check that bidirectional field is set
		if (bidirectionalRuleProcessorInfo.oppositeField.nullOrEmpty) {
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must specify name of opposite field''')
			return
		}

		// check used type
		val isSet = context.newTypeReference(Set).type.
			isAssignableFromConsiderUnprocessed(xtendField.type?.type, context)
		var TypeReference oppositeType
		if (isSet) {

			// sets must specify type argument
			if (xtendField.type.actualTypeArguments.size == 0) {
				xtendField.
					addError('''Annotation @«processedAnnotationType.simpleName» must only be used for sets, if also a type argument is applied (i.e. the type of the opposite type must be known)''')
				return
			}

			oppositeType = xtendField.type.actualTypeArguments.get(0)

		} else {

			oppositeType = xtendField.type

		}

		// analyze further in case of type parameter ("extends" is expected)
		if (oppositeType.type !== null && oppositeType.type instanceof TypeParameterDeclaration &&
			(oppositeType.type as TypeParameterDeclaration).upperBounds.size == 1)
			oppositeType = (oppositeType.type as TypeParameterDeclaration).upperBounds.get(0)

		// ensure that type is class/interface
		if (oppositeType === null || oppositeType.type === null ||
			!(oppositeType.type instanceof ClassDeclaration || oppositeType.type instanceof InterfaceDeclaration)) {

			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must only be used, if opposite interface/class type is specified''')
			return

		}

		// ensure that no trait class is referenced (directly)
		if (oppositeType.type instanceof ClassDeclaration && (oppositeType.type as ClassDeclaration).hasAnnotation(TraitClass)) {

			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must not be used, if opposite type is a trait class (in spite of that its interface can be used)''')
			return

		}

		val oppositeTypeDeclaration = oppositeType.type as TypeDeclaration

		// check if opposite field (resp. setter/adder/remover) exist
		var List<MethodDeclaration> oppositeMethods
		if (oppositeType.type instanceof ClassDeclaration)
			oppositeMethods = (oppositeTypeDeclaration as ClassDeclaration).getMethodClosure(
				null,
				null,
				true,
				true,
				true,
				true,
				context
			)
		else
			oppositeMethods = (oppositeTypeDeclaration as InterfaceDeclaration).getMethodClosure(
				null,
				true,
				true,
				true,
				true,
				context
			)

		if (oppositeMethods.findFirst [
			it.simpleName == "set" + bidirectionalRuleProcessorInfo.oppositeField.toFirstUpper &&
				it.parameters.size == 1
		] === null && (
			oppositeMethods.findFirst [
			it.simpleName == "addTo" + bidirectionalRuleProcessorInfo.oppositeField.toFirstUpper &&
				it.parameters.size == 1
		] === null || oppositeMethods.findFirst [
			it.simpleName == "removeFrom" + bidirectionalRuleProcessorInfo.oppositeField.toFirstUpper &&
				it.parameters.size == 1
		] === null)) {

			xtendField.
				addError('''Cannot find appropriate method (setter/adder/remover) for bidirectional connections in opposite class "«oppositeTypeDeclaration.simpleName»"''')
			return

		}

	}

}

/**
 * Active Annotation Processor for {@link SynchronizationRule}
 * 
 * @see GetterRule 
 * @see SetterRule
 * @see AdderRule
 * @see RemoverRule
 */
class SynchronizationRuleProcessor extends RuleProcessor<FieldDeclaration, MutableFieldDeclaration> {

	static class SynchronizationRuleInfo {

		public String lockName = null

	}

	override protected getProcessedAnnotationType() {
		SynchronizationRule
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration
	}

	/**
	 * Retrieves information from annotation (@SynchronizationRule).
	 */
	static def SynchronizationRuleInfo getSynchronizationRuleInfo(FieldDeclaration annotatedField,
		extension TypeLookup context) {

		val synchronizationRuleProcessorInfo = new SynchronizationRuleInfo
		val annotationSynchronizationRule = annotatedField.getAnnotation(SynchronizationRule)

		synchronizationRuleProcessorInfo.lockName = annotationSynchronizationRule.getStringValue("value")

		return synchronizationRuleProcessorInfo

	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		val synchronizationRuleInfo = xtendField.getSynchronizationRuleInfo(context)

		// check that value of annotation (name of the lock) is not null or empty
		if (synchronizationRuleInfo.lockName.isNullOrEmpty) {
			xtendField.addError('''Annotation @«processedAnnotationType.simpleName» must specify a name for the lock''')
			return
		}

		// check that field has also setter, getter, adder or remover
		if (!xtendField.hasAnnotation(SetterRule) && !xtendField.hasAnnotation(GetterRule) &&
			!xtendField.hasAnnotation(AdderRule) && !xtendField.hasAnnotation(RemoverRule)) {
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must only be used, if also @GetterRule, @SetterRule, @AdderRule or @RemoverRule are used''')
			return
		}

	}

}
