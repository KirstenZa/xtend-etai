package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.Collection
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallCollectionNameMultipleIndexBoolean
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallCollectionNameMultipleIndexVoid
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallCollectionNameSingleIndexBoolean
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallCollectionNameSingleIndexVoid
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallMapNameMultipleBoolean
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallMapNameMultipleVoid
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallMapNameSingleBoolean
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallMapNameSingleVoid
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeErasureMethod
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.services.TypeLookup
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallMapNameSingleBooleanWithReplaced
import org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.MethodCallMapNameSingleVoidWithReplaced

/**
 * <p>This annotation can mark a (private) field, whose type is derived from <code>java.util.Collection</code> or
 * <code>java.util.Map</code>. For this field, methods for adding items to the collection
 * (or rather putting items to the map) will be generated.</p>
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
 * their return values can be taken from <code>java.util.Collection</code>, <code>java.util.List</code> or
 * <code>java.util.Map</code>. In general, all <code>boolean</code> return values will report if there has been a change in the
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
	Visibility visibility = Visibility::PUBLIC

	/**
	 * <p>It is possible to call a method if an element is going to be added. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the addition.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case if the symbol
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
	 * <li><code>T</code> is an arbitrary type that should be compatible with the field's collection type
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
	 * <p>This feature is only supported by collections. It is not supported if a map is annotated.</p>
	 * 
	 * @see AdderRule#afterElementAdd
	 * @see AdderRule#beforeAdd
	 */
	String beforeElementAdd = ""

	/**
	 * <p>It is possible to call a method if an element has been added. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the addition.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case if the symbol
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
	 * <li><code>T</code> is an arbitrary type that should be compatible with the field's collection type
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
 * <code>java.util.Collection</code>, <code>java.util.List</code> or <code>java.util.Map</code>. In general, all
 * <code>boolean</code> return values will report if there has been a change in the collection (not available for maps).</p>
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
	Visibility visibility = Visibility::PUBLIC

	/**
	 * <p>It is possible to call a method if an element is going to be removed. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the addition.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case if the symbol
	 * is not at the first position).</p>
	 * 
	 * <p>The method specified by this attribute, is called <em>before</em> the element will be
	 * removed. Thereby, it is ensured that there is an element that can be removed.</p>
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
	 * <li><code>T</code> is an arbitrary type that should be compatible with the field's collection type
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
	 * <p>This feature is only supported by collections. It is not supported if a map is annotated.</p>
	 * 
	 * @see RemoverRule#afterElementRemove
	 * @see RemoverRule#beforeRemove
	 */
	String beforeElementRemove = ""

	/**
	 * <p>It is possible to call a method if an element has been removed. 
	 * For this, a method with the specified name in the current class will be searched during
	 * code generation. If an appropriate method is found, it will be called with information
	 * about the addition.</p>
	 * 
	 * <p>The specified name can contain a <code>%</code> symbol. This symbol will be replaced
	 * by the name of the attached field (whereas the first letter will be upper case if the symbol
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
	 * <li><code>T</code> is an arbitrary type that should be compatible with the field's collection type
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
 * <p>Base class for adder/remover annotation processors.</p>
 */
abstract class AdderRemoverRuleProcessor extends GetterSetterRuleProcessor {

	static class AdderRemoverRuleInfo extends GetterSetterRuleInfo {

		public boolean single = true
		public boolean multiple = false

	}

	/** 
	 * <p>This helper class considers a method declaration on basis of a field (annotated by adder/remover rule).</p>
	 */
	static abstract class MethodDeclarationFromAdderRemover<T extends TypeLookup & TypeReferenceProvider> extends MethodDeclarationFromGetterSetter<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		/**
		 * <p>Returns a string for casting the given collection type to a compatible one.</p>
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
					}]).getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false, context) + ")"

			}

			if (fieldDeclaration.type.actualTypeArguments.size == 1) {
				if (fieldDeclaration.type.actualTypeArguments.get(0).isWildCard &&
					fieldDeclaration.type.actualTypeArguments.get(0).upperBound !== null)
					return "(" +
						context.newTypeReference(collectionType,
							fieldDeclaration.type.actualTypeArguments.get(0).upperBound).getTypeReferenceAsString(true,
							TypeErasureMethod.NONE, false, false, context) + ")"

			}

			return ""

		}

		protected def TypeReference getContainerTypeArgument(int index) {
			return getContainerTypeArgument(fieldDeclaration, index, context)
		}

		protected def String getContainerTypeArgumentAsString(int index) {
			return getContainerTypeArgumentAsString(fieldDeclaration, index, context)
		}

	}

	/**
	 * <p>Retrieves the type arguments of the field's collection/map type. Thereby, it considers wild cards and
	 * boundaries. If no information is available, <code>java.lang.Object</code> as type reference is returned.</p>
	 */
	static def TypeReference getContainerTypeArgument(FieldDeclaration fieldDeclaration, int index,
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
	 * <p>Retrieves the type arguments of the field's collection/map type as a string.</p>
	 * 
	 * @see #getContainerTypeArgument
	 */
	static def String getContainerTypeArgumentAsString(FieldDeclaration fieldDeclaration, int index,
		TypeReferenceProvider context) {

		return getContainerTypeArgument(fieldDeclaration, index, context).getTypeReferenceAsString(true,
			TypeErasureMethod.NONE, false, false, context)

	}

	/**
	 * <p>This method embeds a method call for collection events (code) in the appropriate object.</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getCollectionMethodCallEmbedded(
		MethodDeclaration methodDeclaration, Class<?> interfaceType, boolean isBoolean, boolean multiple, boolean isAdd,
		FieldDeclaration fieldDeclaration, String parameters, extension T context) {

		val methodDeclarationBoolean = (context.primitiveBoolean == methodDeclaration.returnType)

		val isMap = context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type,
			context)

		return '''new org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.«interfaceType.simpleName»<«getContainerTypeArgumentAsString(fieldDeclaration, 0, context)»«IF isMap», «getContainerTypeArgumentAsString(fieldDeclaration, 1, context)»«ENDIF»>() {
				@Override
				public «IF isBoolean»boolean«ELSE»void«ENDIF» call(«IF multiple»«IF isMap»java.util.Map<«getContainerTypeArgumentAsString(fieldDeclaration, 0, context)», «getContainerTypeArgumentAsString(fieldDeclaration, 1, context)»>«ELSE»java.util.List<«getContainerTypeArgumentAsString(fieldDeclaration, 0, context)»>«ENDIF» $_elements«ELSE»«IF isMap»java.util.Map.Entry<«getContainerTypeArgument(fieldDeclaration, 0, context)», «getContainerTypeArgument(fieldDeclaration, 1, context)»>«ELSE»«getContainerTypeArgument(fieldDeclaration, 0, context)»«ENDIF» $_element«ENDIF»
					«IF !isMap»,«IF multiple»java.util.List<Integer> $_indices«ELSE»int $_index«ENDIF»«ENDIF»
					«IF isMap && isAdd && !multiple», java.util.Map.Entry<«getContainerTypeArgument(fieldDeclaration, 0, context)», «getContainerTypeArgument(fieldDeclaration, 1, context)»> $_replacedElement«ENDIF»
					«IF !isMap», java.util.List<«getContainerTypeArgumentAsString(fieldDeclaration, 0, context)»> $_oldElements«ENDIF»
					«IF !isMap && !isBoolean», java.util.List<«getContainerTypeArgumentAsString(fieldDeclaration, 0, context)»> $_newElements«ENDIF») {
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
 * <p>Active Annotation Processor for {@link AdderRule}.</p>
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
	 * <p>This helper class considers a method declaration on basis of a field (annotated by adder rule).</p> 
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
					return org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.put«IF this instanceof MethodDeclarationFromAdder_PutAllTo<?>»All«ENDIF»ToMap(
						«IF !fieldDeclaration.isStatic»this.«ENDIF»«fieldDeclaration.simpleName»,
						«elements»,
						«getMethodCallBeforeElementAdd(fieldDeclaration, context)»,
						«getMethodCallBeforeAdd(fieldDeclaration, context)»,
						«getMethodCallAfterElementAdd(fieldDeclaration, context)»,
						«getMethodCallAfterAdd(fieldDeclaration, context)»,
						"«fieldDeclaration.simpleName»",
						«IF fieldDeclaration.isStatic»null«ELSE»«getThisCode(fieldDeclaration)»«ENDIF»,
						«IF !(this instanceof MethodDeclarationFromAdder_PutAllTo<?>)»null,«ENDIF»
						«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullKeyOrElement»«ELSE»false«ENDIF»,
						«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullValue»«ELSE»false«ENDIF»,
						«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''
			else
				return '''«preCode»
					return org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.addTo«IF index === null && context.newTypeReference(List).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type, context)»List«ELSE»Collection«ENDIF»(
						«IF !fieldDeclaration.isStatic»this.«ENDIF»«fieldDeclaration.simpleName»,
						«elements», «IF index !== null || !context.newTypeReference(List).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type, context)»«IF index === null»0«ELSE»«index»«ENDIF»,«ENDIF»
						«getMethodCallBeforeElementAdd(fieldDeclaration, context)»,
						«getMethodCallBeforeAdd(fieldDeclaration, context)»,
						«getMethodCallAfterElementAdd(fieldDeclaration, context)»,
						«getMethodCallAfterAdd(fieldDeclaration, context)»,
						"«fieldDeclaration.simpleName»",
						«IF fieldDeclaration.isStatic»null«ELSE»«getThisCode(fieldDeclaration)»«ENDIF»,
						«IF notNullRuleInfo !== null»«notNullRuleInfo.notNullKeyOrElement»«ELSE»false«ENDIF»,
						«IF !oppositeFieldName.isNullOrEmpty»"«oppositeFieldName»"«ELSE»null«ENDIF»,
						«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''

		}

	}

	/**
	 * <p>Specifies characteristics of addToX method virtually.</p>
	 */
	static class MethodDeclarationFromAdder_AddTo<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdder<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { return context.primitiveBoolean }

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(new ParameterDeclarationForVirtualMethod(this, getContainerTypeArgument(0), "$element"))
			return result

		}

		override getDocComment() {
			return '''This is a generated adder method for adding an element to {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "addTo" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {

			return getBasicImplementation('''java.util.List<«getContainerTypeArgumentAsString(0)»> $elements = new java.util.ArrayList<«getContainerTypeArgumentAsString(0)»>();
					$elements.add($element);''', "$elements", null)

		}

	}

	/**
	 * <p>Specifies characteristics of addToX (indexed) method virtually.</p>
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

			return getBasicImplementation('''java.util.List<«getContainerTypeArgumentAsString(0)»> $elements = new java.util.ArrayList<«getContainerTypeArgumentAsString(0)»>();
					$elements.add($element);''', "$elements", "$index")

		}

	}

	/**
	 * <p>Specifies characteristics of putToX method virtually.</p>
	 */
	static class MethodDeclarationFromAdder_PutTo<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdder<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { return getContainerTypeArgument(1) }

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(new ParameterDeclarationForVirtualMethod(this, getContainerTypeArgument(0), "$key"))
			result.add(new ParameterDeclarationForVirtualMethod(this, getContainerTypeArgument(1), "$value"))
			return result

		}

		override getDocComment() {
			return '''This is a generated adder method for putting a key/value pair to {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "putTo" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {
			return getBasicImplementation('''java.util.Map<«getContainerTypeArgumentAsString(0)», «getContainerTypeArgumentAsString(1)»> $m = new java.util.HashMap<«getContainerTypeArgumentAsString(0)», «getContainerTypeArgumentAsString(1)»>();
					$m.put($key, $value);''', "$m", null)
		}

	}

	/**
	 * <p>Specifies characteristics of addAllToX method virtually.</p>
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
						context.newWildcardTypeReference(getContainerTypeArgument(0))), "$c"))
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
	 * <p>Specifies characteristics of addAllToX (indexed) method virtually.</p> 
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
	 * <p>Specifies characteristics of putAllToX method virtually.</p>
	 */
	static class MethodDeclarationFromAdder_PutAllTo<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdder<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() { context.primitiveBoolean }

		override getParameters() {

			val result = new ArrayList<ParameterDeclaration>
			result.add(
				new ParameterDeclarationForVirtualMethod(this,
					context.newTypeReference(Map,
						#[context.newWildcardTypeReference(getContainerTypeArgument(0)),
							context.newWildcardTypeReference(getContainerTypeArgument(1))]), "$m"))
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
	 * <p>Retrieves information from annotation (@AdderRule).</p>
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
	 * <p>Get method for event "before add".</p>
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
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"before add",
			getAdderInfo(annotatedField, context).beforeAdd,
			[
				it.length == 0 ||
					(!isMap && it.length == 1 && context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(!isMap && !indexSupported && it.length == 2 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(!isMap && !indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 2 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 4 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(isMap && it.length == 1 && context.newTypeReference(Map).isAssignableFrom(it.get(0).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map).isAssignableFrom(it.get(1).type))

			],
			#[Collection, Map],
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "before add".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallBeforeAdd(
		FieldDeclaration annotatedField, extension T context) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		val method = getMethodBeforeAdd(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, if (isMap)
			MethodCallMapNameMultipleBoolean
		else
			MethodCallCollectionNameMultipleIndexBoolean, true, true, true, annotatedField,
			if (method.parameters.length == 0)
				''''''
			else if (method.parameters.length == 1)
				'''$_elements'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_elements'''
			else if (indexSupported && method.parameters.length == 2)
				'''$_indices, $_elements'''
			else if (!indexSupported && method.parameters.length == 2)
				'''$_oldElements, $_elements'''
			else if (indexSupported && method.parameters.length == 3 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_indices, $_elements'''
			else if (!indexSupported && method.parameters.length == 3 &&
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
	 * <p>Get method for event "after add".</p>
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
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"after add",
			getAdderInfo(annotatedField, context).afterAdd,
			[
				it.length == 0 ||
					(!isMap && it.length == 1 && context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(!isMap && !indexSupported && it.length == 3 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(!isMap && !indexSupported && it.length == 4 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(indexSupported && it.length == 2 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 4 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(indexSupported && it.length == 5 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(4).type)) ||
					(isMap && it.length == 1 && context.newTypeReference(Map).isAssignableFrom(it.get(0).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map).isAssignableFrom(it.get(1).type))
			],
			#[Collection, Map],
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "after add".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallAfterAdd(
		FieldDeclaration annotatedField, extension T context) {

		val isMap = context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type,
			context)

		val method = getMethodAfterAdd(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, if (isMap)
			MethodCallMapNameMultipleVoid
		else
			MethodCallCollectionNameMultipleIndexVoid, false, true, true, annotatedField,
			if (method.parameters.length == 0)
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
	 * <p>Get method for event "before element add".</p>
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
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"before element add",
			getAdderInfo(annotatedField, context).beforeElementAdd,
			[
				it.length == 1 ||
					(!isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 2 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 3 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(indexSupported && it.length == 2 && it.get(0).type == context.primitiveInt) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(indexSupported && it.length == 3 && indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(indexSupported && it.length == 4 && indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						it.get(2).type == context.primitiveInt) ||
					(isMap && it.length == 1 && context.newTypeReference(Map.Entry).isAssignableFrom(it.get(0).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(1).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(Map.Entry).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(1).type)) ||
					(isMap && it.length == 3 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(2).type))
			],
			#[Collection, Map],
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "before element add".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallBeforeElementAdd(
		FieldDeclaration annotatedField, extension T context) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		val method = getMethodBeforeElementAdd(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, if (isMap)
			MethodCallMapNameSingleBooleanWithReplaced
		else
			MethodCallCollectionNameSingleIndexBoolean, true, false, true, annotatedField,
			if (method.parameters.length == 1)
				'''$_element'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_element'''
			else if (method.parameters.length == 2 && method.parameters.get(0).type == context.primitiveInt)
				'''$_index, $_element'''
			else if (method.parameters.length == 2 && isMap)
				'''$_replacedElement, $_element'''
			else if (method.parameters.length == 2)
				'''$_oldElements, $_element'''
			else if (method.parameters.length == 3 && indexSupported &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_index, $_element'''
			else if (method.parameters.length == 3 && isMap)
				'''"«annotatedField.simpleName»", $_replacedElement, $_element'''
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
	 * <p>Get method for event "after element add".</p>
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
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"after element add",
			getAdderInfo(annotatedField, context).afterElementAdd,
			[
				it.length == 1 ||
					(!isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 3 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(!isMap && it.length == 4 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 2 && it.get(0).type == context.primitiveInt) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(indexSupported && it.length == 4 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						it.get(2).type == context.primitiveInt) ||
					(indexSupported && it.length == 5 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						it.get(3).type == context.primitiveInt) ||
					(isMap && it.length == 1 && context.newTypeReference(Map.Entry).isAssignableFrom(it.get(0).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(1).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(Map.Entry).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(1).type)) ||
					(isMap && it.length == 3 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(2).type))
			],
			#[Collection, Map],
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "after element add".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallAfterElementAdd(
		FieldDeclaration annotatedField, extension T context) {

		val isMap = context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type,
			context)

		val method = getMethodAfterElementAdd(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, if (isMap)
			MethodCallMapNameSingleVoidWithReplaced
		else
			MethodCallCollectionNameSingleIndexVoid, false, false, true, annotatedField,
			if (method.parameters.length == 1)
				'''$_element'''
			else if (method.parameters.length == 2 &&
				context.newTypeReference(String).isAssignableFrom(method.parameters.get(0).type))
				'''"«annotatedField.simpleName»", $_element'''
			else if (method.parameters.length == 2 && isMap)
				'''$_replacedElement, $_element'''
			else if (method.parameters.length == 2)
				'''$_index, $_element'''
			else if (method.parameters.length == 3 && isMap)
				'''"«annotatedField.simpleName»", $_replacedElement, $_element'''
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
 * <p>Active Annotation Processor for {@link RemoverRule}.</p>
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
	 * <p>This helper class considers a method declaration on basis of a field (annotated by remover rule).</p>
	 */
	static abstract class MethodDeclarationFromRemover<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromAdderRemover<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		protected def String getBasicImplementation(String preCode, String methodName, String elementName, String index,
			boolean supportOpposite, Boolean removeDuplicates) {

			val oppositeFieldName = getOppositeFieldName(fieldDeclaration, context)
			val synchronizationLockName = getSynchronizationLockName(fieldDeclaration, context)

			return '''«preCode»
				return org.eclipse.xtend.lib.annotation.etai.utils.GetterSetterUtils.«methodName»(
					«fieldDeclaration.simpleName»,
					«IF elementName !== null»«elementName»,«ENDIF»
					«IF index !== null»«index»,«ENDIF»
					«IF removeDuplicates !== null»«removeDuplicates»,«ENDIF»
					«getMethodCallBeforeElementRemove(fieldDeclaration, context)»,
					«getMethodCallBeforeRemove(fieldDeclaration, context)»,
					«getMethodCallAfterElementRemove(fieldDeclaration, context)»,
					«getMethodCallAfterRemove(fieldDeclaration, context)»,
					"«fieldDeclaration.simpleName»",
					«IF fieldDeclaration.isStatic»null«ELSE»«getThisCode(fieldDeclaration)»«ENDIF»,
					«IF supportOpposite»«IF !oppositeFieldName.isNullOrEmpty»"«oppositeFieldName»"«ELSE»null«ENDIF»,«ENDIF»
					«IF methodName == "removeFromMap"»null ,«ENDIF»
					«IF !synchronizationLockName.isNullOrEmpty»"«synchronizationLockName»"«ELSE»null«ENDIF»);'''

		}

	}

	/**
	 * <p>Specifies characteristics of removeFromX method virtually.</p>
	 */
	static class MethodDeclarationFromRemover_RemoveFrom<T extends TypeLookup & FileLocations & TypeReferenceProvider> extends MethodDeclarationFromRemover<T> {

		new(FieldDeclaration fieldDeclaration, Visibility visibility, T context) {
			super(fieldDeclaration, visibility, context)
		}

		override getReturnType() {

			if (context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(fieldDeclaration.type?.type,
				context)) {
				return getContainerTypeArgument(1)
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
				new ParameterDeclarationForVirtualMethod(this, getContainerTypeArgument(0), getFirstParameterName()))
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
				context))
				return getBasicImplementation('''java.util.Set<«getContainerTypeArgumentAsString(0)»> $elements = new java.util.HashSet<«getContainerTypeArgumentAsString(0)»>();
					$elements.add(«getFirstParameterName()»);''', "removeFromMap", "$elements", null, false, null)
			else
				return getBasicImplementation('''java.util.List<«getContainerTypeArgumentAsString(0)»> $elements = new java.util.ArrayList<«getContainerTypeArgumentAsString(0)»>();
					$elements.add(«getFirstParameterName()»);''', "removeFromCollection", "$elements", "null", true,
					false)

		}

	}

	/**
	 * <p>Specifies characteristics of removeFromX (indexed) method virtually.</p>
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
			return getBasicImplementation('''java.util.List<«getContainerTypeArgumentAsString(0)»> $elements = new java.util.ArrayList<«getContainerTypeArgumentAsString(0)»>(«fieldDeclaration.simpleName»);''',
				"removeFromCollection", "null", "$index", true, false)
		}

	}

	/**
	 * <p>Specifies characteristics of removeFromX (indexed) method virtually.</p>
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
						context.newWildcardTypeReference(getContainerTypeArgument(0))), "$c"))
			return result

		}

		override getDocComment() {
			return '''This is a generated remover method for removing multiple elements from {@link «(declaringType as ClassDeclaration).qualifiedName»#«fieldDeclaration.simpleName»»)}.'''
		}

		override getSimpleName() {
			return "removeAllFrom" + fieldDeclaration.simpleName.toFirstUpper
		}

		override String getBasicImplementation() {
			return getBasicImplementation("", "removeFromCollection", "$c", "null", true, true)
		}

	}

	/**
	 * <p>Specifies characteristics of clearX method virtually.</p>
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
				context))
				return getBasicImplementation("", "clearMap", null, null, false, null)
			else
				return getBasicImplementation("", "clearCollection", null, null, true, null)

		}

	}

	/**
	 * <p>Retrieves information from annotation (@RemoverRule).</p>
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
	 * <p>Get method for event "before remove".</p>
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
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"before remove",
			getRemoverInfo(annotatedField, context).beforeRemove,
			[
				it.length == 0 ||
					(!isMap && it.length == 1 && context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(!isMap && !indexSupported && it.length == 2 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(!isMap && !indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 2 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 4 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(isMap && it.length == 1 && context.newTypeReference(Map).isAssignableFrom(it.get(0).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map).isAssignableFrom(it.get(1).type))
			],
			#[Collection, Map],
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "before remove".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallBeforeRemove(
		FieldDeclaration annotatedField, extension T context) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		val method = getMethodBeforeRemove(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, if (isMap)
			MethodCallMapNameMultipleBoolean
		else
			MethodCallCollectionNameMultipleIndexBoolean, true, true, false, annotatedField,
			if (method.parameters.length == 0)
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
	 * <p>Get method for event "after remove".</p>
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
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"after remove",
			getRemoverInfo(annotatedField, context).afterRemove,
			[
				it.length == 0 ||
					(!isMap && it.length == 1 && context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(!isMap && !indexSupported && it.length == 3 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(!isMap && !indexSupported && it.length == 4 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(indexSupported && it.length == 2 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 4 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type)) ||
					(indexSupported && it.length == 5 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(3).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(4).type)) ||
					(isMap && it.length == 1 && context.newTypeReference(Map).isAssignableFrom(it.get(0).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map).isAssignableFrom(it.get(1).type))
			],
			#[Collection, Map],
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "after remove".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallAfterRemove(
		FieldDeclaration annotatedField, extension T context) {

		val isMap = context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type,
			context)

		val method = getMethodAfterRemove(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, if (isMap)
			MethodCallMapNameMultipleVoid
		else
			MethodCallCollectionNameMultipleIndexVoid, false, true, false, annotatedField,
			if (method.parameters.length == 0)
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
	 * <p>Get method for event "before element remove".</p>
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
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"before element remove",
			getRemoverInfo(annotatedField, context).beforeElementRemove,
			[
				it.length == 1 ||
					(!isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 2 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 3 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(indexSupported && it.length == 2 && it.get(0).type == context.primitiveInt) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(indexSupported && it.length == 4 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						it.get(2).type == context.primitiveInt) ||
					(isMap && it.length == 1 && context.newTypeReference(Map.Entry).isAssignableFrom(it.get(0).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(1).type))
			],
			#[Collection, Map],
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "before element remove".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallBeforeElementRemove(
		FieldDeclaration annotatedField, extension T context) {

		val indexSupported = context.newTypeReference(List).type.
			isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		val method = getMethodBeforeElementRemove(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, if (isMap)
			MethodCallMapNameSingleBoolean
		else
			MethodCallCollectionNameSingleIndexBoolean, true, false, false, annotatedField,
			if (method.parameters.length == 1)
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
	 * <p>Get method for event "after element remove".</p>
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
		val isMap = !indexSupported &&
			context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type, context)

		return getMethodCallX(
			annotatedField,
			"after element remove",
			getRemoverInfo(annotatedField, context).afterElementRemove,
			[
				it.length == 1 ||
					(!isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type)) ||
					(!isMap && it.length == 3 && !indexSupported &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type)) ||
					(!isMap && it.length == 4 && !indexSupported &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type)) ||
					(indexSupported && it.length == 2 && it.get(0).type == context.primitiveInt) ||
					(indexSupported && it.length == 3 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						it.get(1).type == context.primitiveInt) ||
					(indexSupported && it.length == 4 &&
						context.newTypeReference(List).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						it.get(2).type == context.primitiveInt) ||
					(indexSupported && it.length == 5 &&
						context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(1).type) &&
						context.newTypeReference(List).isAssignableFrom(it.get(2).type) &&
						it.get(3).type == context.primitiveInt) ||
					(isMap && it.length == 1 && context.newTypeReference(Map.Entry).isAssignableFrom(it.get(0).type)) ||
					(isMap && it.length == 2 && context.newTypeReference(String).isAssignableFrom(it.get(0).type) &&
						context.newTypeReference(Map.Entry).isAssignableFrom(it.get(1).type))
			],
			#[Collection, Map],
			errors,
			context
		)

	}

	/**
	 * <p>Gets the call (string) of the method for event "before element remove".</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> String getMethodCallAfterElementRemove(
		FieldDeclaration annotatedField, extension T context) {

		val isMap = context.newTypeReference(Map).type.isAssignableFromConsiderUnprocessed(annotatedField.type?.type,
			context)

		val method = getMethodAfterElementRemove(annotatedField, null, context)
		if (method === null)
			return '''null'''

		return getCollectionMethodCallEmbedded(method, if (isMap)
			MethodCallMapNameSingleVoid
		else
			MethodCallCollectionNameSingleIndexVoid, false, false, false, annotatedField,
			if (method.parameters.length == 1)
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
