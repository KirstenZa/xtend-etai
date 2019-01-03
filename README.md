# Table of Contents

- [ETAI Library - Tutorial](#etai-library---tutorial)
  * [Introduction](#introduction)
  * [Interface Extraction](#interface-extraction)
    + [Overview](#overview)
    + [Basic Usage of Interface Extraction](#basic-usage-of-interface-extraction)
    + [Adapt Interface Extraction](#adapt-interface-extraction)
    + [Behavior of Interface Extraction in Hierarchies](#behavior-of-interface-extraction-in-hierarchies)
  * [Automatic Modification of Classes](#automatic-modification-of-classes)
    + [Overview](#overview-1)
    + [Generate Accessors and Mutators](#generate-accessors-and-mutators)
      - [Generate Getter and Setter Methods](#generate-getter-and-setter-methods)
      - [Generate Adder and Remover Methods](#generate-adder-and-remover-methods)
      - [Getter Methods for Collections and Maps: *collectionPolicy*](#getter-methods-for-collections-and-maps---collectionpolicy-)
      - [*null* Checks](#-null--checks)
      - [Change Methods](#change-methods)
      - [Bidirectional Connections](#bidirectional-connections)
      - [Multi-Threading and Mutators](#multi-threading-and-mutators)
    + [Generate the Implementation of Constructors and Methods](#generate-the-implementation-of-constructors-and-methods)
    + [Reimplement Constructors and Methods with Adapted Parameter and Return Types](#reimplement-constructors-and-methods-with-adapted-parameter-and-return-types)
      - [Reimplement Constructors without Parameters](#reimplement-constructors-without-parameters)
    + [Deactivate and Change Rules](#deactivate-and-change-rules)
    + [Generate Factory Methods](#generate-factory-methods)
      - [Initialization after Object has been Constructed Completely](#initialization-after-object-has-been-constructed-completely)
      - [Factory Method](#factory-method)
    + [Generate Factories](#generate-factories)
    + [Generate Default Implementations of Missing Methods](#generate-default-implementations-of-missing-methods)
    + [Adaption Rule Specification](#adaption-rule-specification)
      - [Adaption Functions](#adaption-functions)
      - [Predefined Adaption Variables](#predefined-adaption-variables)
      - [Adaption Function: *alternative*](#adaption-function---alternative-)
    + [Use Adaption Variables](#use-adaption-variables)
  * [Traits](#traits)
    + [Overview](#overview-2)
    + [Basic Usage of Trait Classes](#basic-usage-of-trait-classes)
    + [Exclusive Methods](#exclusive-methods)
    + [Required Methods](#required-methods)
    + [Processed Methods](#processed-methods)
      - [Standard Trait Method Processors](#standard-trait-method-processors)
      - [Implement Own Trait Method Processor](#implement-own-trait-method-processor)
    + [Envelope Methods](#envelope-methods)
      - [Default Value Provider](#default-value-provider)
    + [Additional Flags for Trait Methods](#additional-flags-for-trait-methods)
      - [Flag: *required*](#flag---required-)
      - [Flag: *setFinal*](#flag---setfinal-)
    + [Redirection of Trait Methods](#redirection-of-trait-methods)
    + [Constructor Methods and Construction Process](#constructor-methods-and-construction-process)
      - [Automatic Generation of Constructors](#automatic-generation-of-constructors)
    + [*this* within Trait Classes](#-this--within-trait-classes)
      - [Calling Methods inside of Trait Classes](#calling-methods-inside-of-trait-classes)
      - [Usage of *\$extendedThis*](#usage-of----extendedthis-)
    + [Trait Classes and Inheritance](#trait-classes-and-inheritance)
      - [Calling Trait Methods of Parent Class within Trait Classes](#calling-trait-methods-of-parent-class-within-trait-classes)
      - [Base Trait Classes](#base-trait-classes)
      - [Trait Classes using Trait Classes](#trait-classes-using-trait-classes)

# ETAI Library - Tutorial

## Introduction

The ETAI library contains several [Active Annotations for Xtend](https://eclipse.org/xtend/documentation/204_activeannotations.html). The major purpose of the provided Active Annotations is to avoid boilerplate code by providing different means. These means include the automatic **extraction** of interfaces from classes, an extension mechanism for classes by methods of so-called **trait** classes, and the automatic **adaption** and **implementation** of methods and constructors. Based on these keywords, this Active Annotation library is called ETAI.

## Interface Extraction

### Overview

Interface Extraction is a small, but very useful feature of the ETAI library. It can **automatically extract an interface** (also called **mirror interface** in this context) for a given class. For this, the class just has to be annotated by ***@ExtractInterface***. Of course, the interface extraction supports some options to adjust the concrete behavior.

Defining and working with interfaces is very important in modern software development. The separation of implementation and interface will help to manage software complexity and especially offer flexibility in later project stages. Algorithms shall rather work on basis of abstract objects with a defined interface instead of concrete ones.

For many types of software components it is very hard to define interfaces in early phases and prototyping. Such interfaces will not be stable during the development process. This results in work overhead, because both implementation and interface must be maintained. Therefore, a meaningful usage of interfaces is even omitted at this point in time, so creating and using interfaces will cause work in refactoring phases.

Extracting interfaces automatically in early project stages will solve this problem. If necessary, interface and implementation can be decoupled in later phases by writing the interface manually. There is no real overhead for the programmer until then.

Interface Extraction is already available as an example of Xtend's Active Annotation abilities (see [\@Extract](https://www.eclipse.org/xtend/documentation/204_activeannotations.html)). However, the interface extraction implementation within the ETAI library supports a broader amount of Java constructs and offers slightly more features. Generics are fully supported, for example. In addition, it is smoothly working together with other ETAI features.
				
### Basic Usage of Interface Extraction

In the following example a simple interface extraction is used. The annotation ***@ExtractInterface*** is applied to a class called *Lion*. Therefore, a mirror interface *ILion* is generated automatically. By default, this interface is located in a sub package called *intf*. The name of the interface or sub package can be influenced by options as shown in the latter examples (see [Adapt Interface Extration](#adapt-interface-extraction)).

The generated mirror interface *ILion* gets all ***public*** methods (abstract and non-abstract) of *Lion* by default. Also Javadoc comments of the methods in *Lion* will be copied to the interface. Non-public methods will not show up in the interface. Finally, the class *Lion* will be adapted in order to implement the interface *ILion*.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface

@ExtractInterface
class Lion {

	private def String noise() {
		"Roar!"
	}
	
	override void roar(intensity : int) {
		for (i : 0 ..< intensity)
			System.out.println('''«noise()»''');
	}

}
```


##### Input (Diagram)

![](images/PlantUML_ExtractInterface_Simple_In.png)

##### Output (Diagram)

![](images/PlantUML_ExtractInterface_Simple_Out.png)

##### Important

> Please note, that methods which shall be extracted must already be declared with ***override*** not *def*, even if they do not show up in any base class or another interface. This is due to the fact that the generated mirror interface which contains the method must already be assumed.

##### Limitation

> A class using *@ExtractInterface* must **not be placed in the default package**.
>
> It is also necessary to explicitly define all types for methods, because **types cannot be inferred for the extraction process**.

### Adapt Interface Extraction

There are two possibilities to influence the extraction of the mirror interface. Firstly, methods can be excluded, i.e., they will not become part of the extracted interface. Secondly, it can be specified how the name of the extracted interface is generated and in which package it is put.

If a *public* method shall not be placed in the mirror interface, it must be annotated by ***@NoInterfaceExtract***.

In order to influence the name and package of the mirror interface the parameter ***name*** of the *@ExtractInterface* annotation must be set. This parameter is also available for *@TraitClass*.

The value of *name* must be a string and can be considered as *naming rule*:

* If the naming rule does not contain any special character, the string represents the fully qualified name of the mirror interface.
* If the naming rule starts with a *"#"* symbol, it contains a relative prefix. For example, if *name* is set to *"#subpack.I"* for a class *mainpack.Foo*, the mirror interface will be generated in a package called *mainpack.subpack* and the mirror interface's name will be *IFoo*. If the class is an inner class, the mirror interface will be in the same enclosing class.
* If the naming rule starts with a *"@"* symbol, it contains an absolute prefix. For example, if *name* is set to *"@apack.I"* for a class *mainpack.Foo*, the mirror interface will be generated in a package called *apack* and the interface's name will be *IFoo*.

The default value (applied if nothing is set) of *name* is *"#intf.I"*, so the mirror interface is put into a sub package *intf* (relative to the annotated class) and has the prefix *"I"*.

The following example shows how both the usage of *@NoInterfaceExtract* and setting *name* to specific values.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.NoInterfaceExtract

import external.IAnimal

@ExtractInterface(name = "external.IAnimal")
class Animal { 
}

@ExtractInterface(name = "#internal.")
class Dog implements IAnimal {
	
	override void bark() { /* ... */ }
	
	@NoInterfaceExtract
	def void bite() { /* ... */ }
	 
}
```


##### Input (Diagram)

![](images/PlantUML_ExtractInterface_Adapting_In.png)

##### Output (Diagram)

![](images/PlantUML_ExtractInterface_Adapting_Out.png)

##### Hint

*@NoInterfaceExtract* can also be used for fields, if they also apply annotations for generating methods, e.g. *@GetterRule* (see [Generate Getter and Setter Methods](#generate-getter-and-setter-methods)).

##### Limitation

*@NoInterfaceExtract* cannot be used within trait classes, for which also an interface is extracted (cp. [Basic Usage of Trait Classes](#basic-usage-of-trait-classes)).

### Behavior of Interface Extraction in Hierarchies

The extraction of mirror interfaces also takes the **type hierarchy** of the class with *@ExtractInterface* annotation into account. For example, the implemented interfaces of the annotated class will also be the base for the mirror interface.

In addition, **methods of parent classes and their implemented interfaces** are processed as if they were in the annotated class. A recursive algorithm takes care that also elements in parents are extracted. It can stop, however, if another parent class with *@ExtractInterface* annotation is found.

The example below shows this. The extracted mirror interface *IMammal* extends *IAnimal*, because this has been defined for *Mammal*. Another showcase is the mirror interface *ILion*. In this case, *Lion* does not directly define implemented interfaces. However, its base class *BigCat* does implement *ILargeAnimal*, which is why *ILion* is extending this interface. In addition, *ILion* is extending *ICat*, because *Cat* is a parent class of *Lion*. Because *ICat* itself is a mirror interface, *ILion* can rely on extraction mechanisms and does not need to extend another interface deeper in the class hierarchy.

In a similar way, the class structure is analyzed for defining methods in the mirror interfaces. For example, *ILion* contains method *hintInPack*, because it is defined within *Lion*. It also contains method *roar*, because it is defined in its parent class *BigCat*. On the other side, it does not contain method *getHome*, because it is already contained in mirror interface *IAnimal*. The same applies for method *feed*, which is in mirror interface *IMammal*.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface

@ExtractInterface
abstract class Mammal implements IAnimal {
	override void feed() { /* ... */ }
}

@ExtractInterface
abstract class Cat extends Mammal implements IMammalPredator {}

abstract class BigCat extends Cat implements ILargeAnimal {
	def String roar() { /* ... */ }
}

@ExtractInterface
class Lion extends BigCat {
	override String getHome() { "Africa" }
	override void huntInPack() {}
}
```
```java
package virtual.intf

import virtual.intf.IMammal

interface IAnimal {
	def String getHome()
}

interface ILargeAnimal extends IAnimal {}

interface IPredator extends IAnimal {}

interface IMammalPredator extends IPredator, IMammal {}
```


##### Input (Diagram)

![](images/PlantUML_ExtractInterface_Hierarchy_In.png)

##### Output (Diagram)

![](images/PlantUML_ExtractInterface_Hierarchy_Out.png)

## Automatic Modification of Classes

### Overview

The ETAI library provides several means for modifying classes and derived classes automatically, especially for generating boilerplate code.

The modification is usually driven by **rules** which support the following use cases:

- generation of **factory methods and factory classes**,
- generation of **getter, setter, adder and remover methods** for regular fields, collections and maps including features like *null*-checks, calling methods on changes or maintaining bidirectional connections
- **adaption of return types and parameter types** of methods/constructors based on the current class in the class hierarchy and
- **adaption of the methods/constructors implementations** based on the current class in the class hierarchy.

In order to enable the modification of classes and derived classes based on rules, it is necessary to attach ***@ApplyRules*** to the class which specifies such rules as well as to any derived class.

The **generation of default implementations of methods found in interfaces** is also possible with the ETAI library and described in the following. However, this generation is not based on rules and does not require *@ApplyRules* therefore.

##### Important

> Please note, that once *@ApplyRules* is attached to a class all derived classes **must** also use this annotation. This will be checked via assertions during runtime.

### Generate Accessors and Mutators

Coding getter and setter methods is common in object-oriented programming and especially Java. For example, there is usually a method *getAge* for accessing field *age* or a method *setName* for changing field *name*. This is a requirement for keeping the principle of encapsulation.

However, such methods are a prototype of boilerplate code and as a consequence many code generation technologies support the automatic generation. Even Xtend provides some exemplary active annotations, which perform this job.

The ETAI library also provides some active annotations. In contrast to the basic implementation, which is shipping with Xtend, there are more features and the annotations will fit to other mechanisms of the ETAI library. 

In order to enable the **generation of getter and setter**, specific rules (active annotations) must be attached to the fields of a class. Available rules will be explained in the following sub sections.

Besides getters and setters the ETAI library also supports a special treatment for fields, which have the type *java.util.Collection* (or any derived type like *java.util.List* and *java.util.Set*) and *java.util.Map* (or any derived type). The usage of such types allows the **generation of so-called adder and remover** methods, which can be used to add/put or remove values to/from the collections/maps.

In the following, getter methods will also be referenced as **accessors**. Setter, adder and remover methods will also be called **mutators**. 

Active annotations for generating accessors and mutators can only be applied to **non-*public* fields**. However, the methodology supports *static* fields. In this case, the generated methods will also be *static*. 

The generated methods will perform their basic job, of course. In addition, they are able to

- perform ***null* checks**, e.g. fields can require that will never get the value *null*,
- **call other methods on changes**, e.g. in order to trigger additional effects,
- synchronize with an "opposite" field in case of **bidirectional connections**.

All topics will be covered by later sub sections.

##### Hint

> Some annotations like *@ExclusiveMethod* (or other trait methods, see [Traits](#traits)), *@TypeAdaptionRule* (see [Reimplement Constructors and Methods with Adapted Parameter and Return Types](#reimplement-constructors-and-methods-with-adapted-parameter-and-return-types)) or *@NoInterfaceExtract* (see [Adapt Interface Extraction](#adapt-interface-extraction)) are related to methods and must annotate methods therefore. However, they can also annotate fields, if these fields apply annotations for generating accessors or mutators. In such a case, the annotations behave as if they would be annotated to the generated methods.
>
> For example, if *@ExclusiveMethod* and *@GetterRule* are used together for a field in a trait class, a getter method will be generated as exclusive trait method of that trait class, i.e. each class extended by this trait class will receive this getter method.

#### Generate Getter and Setter Methods

The generation of getter and setter methods can be triggered by the annotation of ***@GetterRule*** and ***@SetterRule***. Both annotations can be used independently, i.e., if only *@GetterRule* is used, only a getter method will be generated.

In contrast to the common pattern, the generated setter method will return a *boolean* value. A result of *true* means that the actual value of the field has been changed. On contrary, *false* means that the value has not been changed. This can happen, if the new value (resp. reference) would have been the same as the old one. However, there are also other possibilities that the value is not changed in context of [change methods](#change-methods).

The following example shows class *Person* which specifies the field *name* and uses *@GetterRule* and *@SetterRule* for it. Therefore, the methods *getName* and *setName* are generated. They allow for accessing the field's value and modifying the field's value.

The example also shows the usage of parameter ***visibility***. It is available for all rules for generating accessors and mutators, i.e. not only getter and setter methods, but also adder and remover methods. The parameter can be set to *PUBLIC* and *PROTECTED*. In the example, *@SetterRule* requires the generated setter to be *protected*. By default, all generated accessors and mutators are generated *public*.  

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule

@ApplyRules
class Person {

	@GetterRule
	@SetterRule(visibility=PROTECTED)
	String name

}
```


##### Input (Diagram)

![](images/PlantUML_Modification_GetterSetter_In.png)

##### Output (Diagram)

![](images/PlantUML_Modification_GetterSetter_Out.png)

##### Hint

> The names for generating getter and setter methods are based on the name of the field and cannot be adjusted. Of course, the naming rules consider the most common pattern, e.g. like specified for JavaBeans (see [JavaBeans](http://download.oracle.com/otndocs/jcp/7224-javabeans-1.01-fr-spec-oth-JSpec/), chapter "Design Patterns for Properties"). The according naming conventions are also supported by [Xtend](https://www.eclipse.org/xtend/documentation/) (see "Property Access").
>
> The example above shows that the field *name* leads to the getter *getName* and setter *setName*. However, in case of a *boolean* field *X* (not *Boolean*) the generated getter would be called *isX*.

#### Generate Adder and Remover Methods

If a field has type *java.util.Collection* (or any derived type like *java.util.List* and *java.util.Set*) or *java.util.Map* (or any derived type), it is possible to apply the annotations ***@AdderRule*** and ***@RemoverRule***. They trigger the generation of methods for adding resp. removing elements to/from the *Collection*/*Map*.

Both annotations support the *boolean* parameters ***single*** and ***multiple***. They control which types of methods will be generated: if *single* is *true*, methods for adding/removing single elements are generated, if *multiple* is *true*, methods for adding/removing multiple elements are generated. At least one of both options must be set to *true*.   

The following tables show which methods are generated for a field named *X* based on the type (with element type *E* resp. key/value types *K*/*V*) and the applied annotation. 

| Method (*@AdderRule*)        | *single* /<br>*multiple* | Type  | Description                         |
| -------------------------- |:------:|:--------:|------------------------------------:|
| ***boolean addToX(E element)*** | *single* | *Collection* | *element* will be added to collection *X* (if the type is *List*, it will be added to the end of the list) |
| ***boolean addToX(int index, E element)*** | *single* | *List* | *element* will be added to list *X* at the specified *index* |
| ***V putToX(K key, V value)*** | *single* | *Map* | *value* for *key* will be put to to map *X*, the old value (resp. *null* if not available) will be replaced and returned by the method |
| ***boolean addAllToX(Collection&lt;E&gt; c)*** | *multiple* | *Collection* | the whole collection *c* will be added to collection *X* (if the type is *List*, it will be added to the end of the list) |
| ***boolean addAllToX(int index, Collection&lt;E&gt; c)*** | *multiple* | *List* | the whole collection *c* will be added to list *X* at the specified *index* |
| ***void putAllToX(Map&lt;? extends K,? extends V&gt; m)*** | *multiple* | *Map* | all entries of map *m* will be put to map<nobr>&nbsp;<nobr>*X* |

| Method (*@RemoverRule*)      | *single* /<br>*multiple* | Type  | Description                         |
| -------------------------- |:------:|:--------:|------------------------------------:|
| ***boolean removeFromX(int index)*** | *single* | *List* | the element with the specified *index* will be removed from list *X* |
| ***boolean removeFromX(E element)*** | *single* | *Collection* | *element* will be removed from collection *X* (if the element is contained multiple times, the first occurrence will be replaced) |
| ***V removeFromX(K key)*** | *single* | *Map* | the entry for the given *key* will be removed from map *X* (returns the removed value or *null* if it did not exist) |
| ***boolean removeAllFromX(Collection&lt;E&gt; c)*** | *multiple* | *Collection* | all elements in collection *c* will be removed from collection *X* (if an element is contained multiple times, all occurrences will be removed) |
| ***boolean/void clearX()*** | *multiple* | *Collection*<nobr>&nbsp;<nobr>/<br>*Map* | the whole collection / map *X* will be emptied |

All methods which return a *boolean* value will report, if there has been any change in the *Collection* (this is not available for *Map*). This can happen, for example, if the new element has already been contained in a *Set*. However, there are also other possibilities in context of [change methods](#change-methods).

An example will be shown in the following sections.

##### Important

> The generated methods do not check or take care that the used *Collection* or *Map* exists or is constructed. It should be ensured that the field is initialized directly or inside the constructor and never gets *null*.

##### Limitation

> It is not recommended to use wildcards and upper bounds for the field's collection type, e.g. *java.util.List<? extends Object>*. Basically, it would not be possible to generate concrete methods in order to add or remove elements then. For example, it is not sure that the given concrete type (*Object* in the example) can be put into the collection. Even using method *add* for the connection itself is not possible. However, the ETAI will still generate methods with the given upper bound. The correct usage must be ensured by the programmer therefore.

#### Getter Methods for Collections and Maps: *collectionPolicy*

Adder and remover methods as shown in the previous section can be used in order to modify collections/maps. However, there usually is the need to access elements of these collections/maps as well.

This can be achieved by applying a *@GetterRule* to the collection/map. Once it is returned by the getter, it can be used to access its elements. However, this might bypass the idea of encapsulation, because the returned reference can also be used to modify the collection/map without using the generated adder and remover methods.

Therefore, *@GetterRule* supports a parameter called ***collectionPolicy***. Setting this parameter can influence how the collection/map is returned, and it can be protected this way. The following values are supported and have the described effect:

- ***UNMODIFIABLE*** (default): the collection/map is returned inside of a read-only wrapper.
- ***UNMODIFIABLE_COPY***: a copy of the collection/map is returned inside of a read-only wrapper.
- ***DIRECT***: the collection/map is returned directly, i.e., there is no protection.

Returning a collection/map inside of a read-only wrapper means that an unmodifiable collection/map is constructed via *java.util.Collections*. Depending on the type of the collection/map the method *unmodifiableList*, *unmodifiableSet*, *unmodifiableSortedSet*, *unmodifiableCollection*, *unmodifiableMap* or *unmodifiableSortedMap* is used. 

The following example shows the usage of *@GetterRule*, *@AdderRule* and *@RemoverRule* together with a list called *paragraphs*. Both *@AdderRule* and *@RemoverRule* have the parameter *single* set to *true*, which is the default. Parameter *multiple*, however, is set to *true* only for *@RemoverRule*. These settings together with type *java.util.List* result in the generated methods shown in the output diagram. 

The parameter *collectionPolicy* is set to *UNMODIFIABLE_COPY* for the generation of the getter. This means that the getter shall return a read-only copy of the list. This way, there is no problem with concurrent modifications when iterating through the elements of *paragraphs* (or rather a snapshot of it) and changing it at the same time. Therefore, the exemplary code shown in *duplicateParagraph* works without exception.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule

@ApplyRules
class Text {

	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	@AdderRule
	@RemoverRule(multiple=true)
	java.util.List<String> paragraphs = new java.util.ArrayList<String>
	

}

class TextDuplicator {
	
	def duplicateParagraphs(Text text) {		
		for (paragraph : text.paragraphs)
			text.addToParagraphs("COPY: " + paragraph)
	}

}
```


##### Input (Diagram)

![](images/PlantUML_Modification_GetterAdderRemover_In.png)

##### Output (Diagram)

![](images/PlantUML_Modification_GetterAdderRemover_Out.png)

#### *null* Checks

In context of accessors (*@GetterRule*) and mutators (*@SetterRule* and *@AdderRule*) it is possible to **protect against setting fields to *null*, adding *null* to collections/maps or retrieving a *null* value from the field or even the collection/map**. This protection can be activated by annotating the according field with ***@NotNullRule*** in addition.

The annotation supports three *boolean* parameters:

- ***notNullSelf*** (default *true*): the value of the field itself must not be set to *null* (via setter) and when retrieving the value (via getter), it must not be *null*.
- ***notNullKeyOrElement*** (default *false*): it is not allowed to add a *null* element to a collection resp. to add a *null* key to a map (via adder).
- ***notNullValue*** (default *false*): it is not allowed to add a *null* value to a map (via adder).

If the specified *null* rule is violated, which can detected during the according method call (getter, setter or adder method), an *AssertionError* will be thrown. This requires assertions to be activated (see [Enabling and Disabling Assertions](https://docs.oracle.com/javase/7/docs/technotes/guides/language/assert.html#enable-disable)).

The code example below shows the usage of *NotNullRule* twice. Firstly, it is not possible to set the name of a *Person* object to *null*. In addition, if a name with value *null* is be retrieved via getter (actually the field has this value directly after the object has been constructed), an error will be thrown.

Secondly, the set *addresses* cannot retrieved, if it is *null* or contains a *null* element. When adding new elements to the set, it is checked that they are not *null* as well.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.NotNullRule

@ApplyRules
class Person {

	@GetterRule
	@SetterRule
	@NotNullRule
	String name
	
	@GetterRule
	@AdderRule
	@RemoverRule
	@NotNullRule(notNullKeyOrElement=true)
	java.util.Set<String> addresses = new java.util.HashSet<String>

}
```


##### Hint

It is also ensured that only non-*null* values/keys can be retrieved from collections/maps using the generated getter method. This can only be achieved by checking each element of the collection/map before returning the reference. As this is a very time consuming operation this feature should be considered as convenient helper for testing purposes and only be used for small collections/maps.  

##### Important

There is no protection, if the field/collection/map is modified or accessed directly without getter, setter or adder.

#### Change Methods

Before/after the value of a field or the content of a collection is changed, it is sometimes necessary to **trigger some additional checks or actions**. In this case, it is possible to write a non-generated mutator method accordingly. However, triggering additional checks or actions is also possible, if generating mutators via *@SetterRule*, *@AdderRule* or *@RemoverRule*.

All rules for generating mutator methods support some additional parameters of type *String*, e.g. parameter *afterChange* is supported by *@SetterRule*. Their purpose is to hold the name of a method, which must be available in context of the generated mutator method (*static* or non-*static*). The method must also comply with one of several allowed signatures. If such a parameter is set, the referenced method is called inside the generated mutator method. It is even possible to block a change.

The specified method name can use the *%* symbol. This symbol will be replaced automatically by the field's name applying also the camel case schema.

The following table shows an overview of available parameters together with the point in time in which the referenced method is called:

| Rule        | Parameter | Trigger                             |
| ----------- |-----------|------------------------------------:|
| *@SetterRule* | *beforeChange* | before the field's value is going to be changed |
| *@SetterRule* | *afterChange* | after the field's value has been changed |
| *@AdderRule* | *beforeAdd* | before one or more elements are going to be added to the collection |
| *@AdderRule* | *beforeElementAdd* | before an element is going to be added to the collection |
| *@AdderRule* | *afterElementAdd* | after an element has been added to the collection |
| *@AdderRule* | *afterAdd* | after one or more elements have been added to the collection |
| *@RemoverRule* | *beforeRemove* | before one or more elements is going to be removed from the collection |
| *@RemoverRule* | *beforeElementRemove* | before an element is going to be removed from the collection |
| *@RemoverRule* | *afterElementRemove* | after an element has been removed from the collection |
| *@RemoverRule* | *afterRemove* | after one or more elements have been removed from the collection |

Please note, that multiple methods can be called during one call of a generated mutator. For example, if a field's value is going to be set to a new value, i.e. the value differs from the old one, the method referenced by *beforeChange* will be called before the actual change, and the *boolean* result of this call can even block the change. After the change has been performed the method referenced by *afterChange* will be called.

If adding multiple elements to a collection, the method referenced by *beforeElementAdd* is called **for each element**. Afterwards, the method referenced by *beforeAdd* will be called. Thereby, adding elements can be blocked individually or entirely. For each element, which has actually been added, the method referenced by *afterElementAdd* will be called then. Finally, *afterAdd* will be called, if there are elements, which have been added. For removing elements the same schema is applied.

All referenced methods must have one of multiple possible signatures. Depending on the signature, information about the change will be available inside the method. The following table shows all supported signatures. The meaning of the individual signature elements will be explained below the table.

| Parameter     | Signature of the called method                   |
|---------------|-------------------------------------------------:|
| *beforeChange*&nbsp;/<br>*afterChange* | *void X()*
| *beforeChange*&nbsp;/<br>*afterChange* | *void X(T newValue)*
| *beforeChange*&nbsp;/<br>*afterChange* | *void X(T oldValue, T newValue)*
| *beforeChange*&nbsp;/<br>*afterChange* | *void X(String fieldName, T oldValue, T newValue)*
| *beforeAdd*&nbsp;/<br>*afterAdd*&nbsp;/<br>*beforeRemove*&nbsp;/<br>*afterRemove* | *void X()*
| *beforeAdd*&nbsp;/<br>*afterAdd*&nbsp;/<br>*beforeRemove*&nbsp;/<br>*afterRemove* | *void X(List&lt;T&gt; elements)*
| *beforeAdd*&nbsp;/<br>*afterAdd*&nbsp;/<br>*beforeRemove*&nbsp;/<br>*afterRemove* | *void X(String fieldName, List&lt;T&gt; elements)*
| supported for *List* only:<br>&nbsp;&nbsp;*beforeAdd*&nbsp;/<br>&nbsp;&nbsp;*afterAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeRemove*&nbsp;/<br>&nbsp;&nbsp;*afterRemove* | *void X(List&lt;Integer&gt; indices, List&lt;T&gt; elements)*
| supported for *List* only:<br>&nbsp;&nbsp;*beforeAdd*&nbsp;/<br>&nbsp;&nbsp;*afterAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeRemove*&nbsp;/<br>&nbsp;&nbsp;*afterRemove* | *void X(String fieldName, List&lt;Integer&gt; indices, List&lt;T&gt; elements)*
| not supported for *List*:<br>&nbsp;&nbsp;*beforeAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeRemove* | *void X(List&lt;T&gt; oldElements, List&lt;T&gt; elements)*
| not supported for *List*:<br>&nbsp;&nbsp;*beforeAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeRemove* | *void X(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; elements)*
| supported for *List* only:<br>&nbsp;&nbsp;*beforeAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeRemove* | *void X(List&lt;T&gt; oldElements, List&lt;Integer&gt; indices, List&lt;T&gt; elements)*
| supported for *List* only:<br>&nbsp;&nbsp;*beforeAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeRemove* | *void X(String fieldName, List&lt;T&gt; oldElements, List&lt;Integer&gt; indices, List&lt;T&gt; elements)*
| not supported for *List*:<br>&nbsp;&nbsp;*afterAdd*&nbsp;/<br>&nbsp;&nbsp;*afterRemove* | *void X(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;T&gt; elements)*
| not supported for *List*:<br>&nbsp;&nbsp;*afterAdd*&nbsp;/<br>&nbsp;&nbsp;*afterRemove* | *void X(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;T&gt; elements)*
| supported for *List* only:<br>&nbsp;&nbsp;*afterAdd*&nbsp;/<br>&nbsp;&nbsp;*afterRemove* | *void X(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;Integer&gt; indices, List&lt;T&gt; elements)*
| supported for *List* only:<br>&nbsp;&nbsp;*afterAdd*&nbsp;/<br>&nbsp;&nbsp;*afterRemove* | *void X(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, List&lt;Integer&gt; indices, List&lt;T&gt; elements)*
| *beforeElementAdd*&nbsp;/<br>*afterElementAdd*&nbsp;/<br>*beforeElementRemove*&nbsp;/<br>*afterElementRemove* | *void X(T element)*
| *beforeElementAdd*&nbsp;/<br>*afterElementAdd*&nbsp;/<br>*beforeElementRemove*&nbsp;/<br>*afterElementRemove* | *void X(String fieldName, T element)*
| supported for *List* only:<br>&nbsp;&nbsp;*beforeElementAdd*&nbsp;/<br>&nbsp;&nbsp;*afterElementAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeElementRemove*&nbsp;/<br>&nbsp;&nbsp;*afterElementRemove* | *void X(int index, T element)*
| supported for *List* only:<br>&nbsp;&nbsp;*beforeElementAdd*&nbsp;/<br>&nbsp;&nbsp;*afterElementAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeElementRemove*&nbsp;/<br>&nbsp;&nbsp;*afterElementRemove* | *void X(String fieldName, int index, T element)*
| not supported for *List*:<br>&nbsp;&nbsp;*beforeElementAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeElementRemove* | *void X(List&lt;T&gt; oldElements, T element)*
| not supported for *List*:<br>&nbsp;&nbsp;*beforeElementAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeElementRemove* | *void X(String fieldName, List&lt;T&gt; oldElements, T element)*
| supported for *List* only:<br>&nbsp;&nbsp;*beforeElementAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeElementRemove* | *void X(List&lt;T&gt; oldElements, int index, T element)*
| supported for *List* only:<br>&nbsp;&nbsp;*beforeElementAdd*&nbsp;/<br>&nbsp;&nbsp;*beforeElementRemove* | *void X(String fieldName, List&lt;T&gt; oldElements, int index, T element)*
| not supported for *List*:<br>&nbsp;&nbsp;*afterElementAdd*&nbsp;/<br>&nbsp;&nbsp;*afterElementRemove* | *void X(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, T element)*
| not supported for *List*:<br>&nbsp;&nbsp;*afterElementAdd*&nbsp;/<br>&nbsp;&nbsp;*afterElementRemove* | *void X(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, T element)*
| supported for *List* only:<br>&nbsp;&nbsp;*afterElementAdd*&nbsp;/<br>&nbsp;&nbsp;*afterElementRemove* | *void X(List&lt;T&gt; oldElements, List&lt;T&gt; newElements, int index, T element)*
| supported for *List* only:<br>&nbsp;&nbsp;*afterElementAdd*&nbsp;/<br>&nbsp;&nbsp;*afterElementRemove* | *void X(String fieldName, List&lt;T&gt; oldElements, List&lt;T&gt; newElements, int index, T element)*

The following elements are used in the table above:

- *X*: the name of the called method
- *T*: the type of the annotated field resp. the type of the collection's element
- *fieldName*: the name of the field/collection which shall be changed
- *oldValue*: the old value of the field
- *newValue*: the new value of the field (which has or has not already been set)
- *element* / *elements*: the element(s) which shall be/have been added/removed to/from the collection (read-only)
- *oldElements*: the element(s) which have been in the collection before the change (read-only)
- *newElements*: the element(s) which will be in the collection after the change (read-only)
- *index* / *indices*: the index/indices of the elements(s) which shall be added/removed to/from the collection

All methods which are triggered before a change also support return type *boolean* in addition to *void*. If *boolean* is used, the return value of the method will **control, if the change is allowed and shall be performed**. If *false* is returned, the change will be aborted. In case of methods called for individual elements of a bigger change (e.g. *beforeElementAdd*) only adding/removing this particular element will be skipped.

Please note, that not all kind of actions should be performed within change methods. For example, throwing exceptions might be problematic (see [Bidirectional Connections](#bidirectional-connections)). Also the currently changed value resp. the currently altered collection should not be changed again within the change method. This might lead to (endless) recursive calls. Therefore, there is even a protection against concurrent changes at least if mutator methods are called. For example, inside a change method for a field *A* triggered by setter *setA* another call of *setA* will not change *A* and return *false*.

The following code example shows how change methods can be used and also how a (logically) equivalent Java code would look like. It applies *beforeChange* and *afterChange* together with *@SetterRule* (field *percentage*) and *afterAdd* together with *@AdderRule* (field *log*).

In case of *percentage* the *beforeChange* method *percentageChange* checks, if the new value is between 0 and 100. If not, it will not be applied (but also no error is thrown). If the value is actually changed, method *percentageChanged* will be called. In the example, this method does not need any information and just wants to report a change, so no parameter is specified.

Field *log* is a *String* list. After new strings have been added, *afterAdd* method *addedToList* is called. It gets information about all added strings and their indices within *log*, and it reports these changes as well.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule

@ApplyRules
class Progress {

	@SetterRule(beforeChange="%Change", afterChange="%Changed")
	double percentage

	@AdderRule(afterAdd="addedToList", single=false, multiple=true)
	java.util.List<String> log = new java.util.ArrayList<String>

	protected def boolean percentageChange(double newPercentage) {
		if (newPercentage < 0.0 || newPercentage > 100.0)
			return false
		return true
	}

	protected def void percentageChanged() {
		System.out.println("Percentage changed!")
	}

	protected def void addedToList(String fieldname,
			java.util.List<Integer> indices,
			java.util.List<String> elements) {
		for (var i = 0; i < indices.size; i++)
			System.out.println('''Added "«elements.get(i)»" to list ''' +
				'''«fieldname» at index «indices.get(i)»''')
	}

}
```


##### Output (Code - Logical)

```java
package virtual;

public class Progress {

	private double percentage;
	private java.util.List<String> log = new java.util.ArrayList<String>();

	public boolean setPercentage(double $percentage) {
		if (this.percentage != $percentage) {
			if (!percentageChange($percentage))
				return false;
			this.percentage = $percentage;
			percentageChanged();
			return true;
		}
		return false;
	}

	public boolean addAllToLog(int $index, java.util.Collection<? extends String> $c) {
		if ($c.isEmpty())
			return false;
		java.util.List<String> addedElements = new java.util.ArrayList<String>($c);
		java.util.List<Integer> addedIndices = new java.util.ArrayList<Integer>();
		for (int i = $index; i < $index + $c.size(); i++)
			addedIndices.add(i);
		log.addAll($index, $c);
		addedToList("log", addedIndices, addedElements);
		return true;
	}

	public boolean addAllToLog(java.util.Collection<? extends String> $c) {
		return addAllToLog(log.size(), $c);
	}

	protected boolean percentageChange(double newPercentage) {
        if (newPercentage < 0.0 || newPercentage > 100.0)
            return false;
        return true;
    }

    protected void percentageChanged() {
        System.out.println("Percentage changed!");
    }
    
    protected void addedToList(final String fieldname,
    		final java.util.List<Integer> indices,
    		final java.util.List<String> elements) {
        for (int i = 0; (i < indices.size()); i++)
        	System.out.println("Added \"" + elements.get(i) + "\" to list " +
                fieldname + " at index " + indices.get(i));
    }

}
```


##### Limitation

> It is not possible to use change methods for maps.

#### Bidirectional Connections

In object-oriented data models it is often required that two objects link to each other (bidirectional connection). In object-oriented programming this would mean that a reference is set from both sides, e.g. by calling a setter method for both objects. If it is known that a bidirectional connection must be established, however, it would be sufficient to call one setter, because **setting the bidirectional connection from the other side (opposing side) can be done automatically**.

The ETAI library supports the generation of mutator methods, which can handle bidirectional connections automatically, i.e., setting a reference on one side is sufficient. To enable this feature it is necessary to add rule ***@BidirectionalRule*** to a field, which references to another (opposing) object. As value of the rule a string must be provided. The string designated the field in the opposing object, which represents the opposing side of the bidirectional connection. 

If the mutator of a field annotated by *@BidirectionalRule* is called, also the opposing object will get according information about the connection. This information will be stored inside the field named in *@BidirectionalRule* by calling an appropriate mutator of the opposing object. This way, both objects contain a reference to each other and a bidirectional connection is established.

In object-oriented data modeling (bidirectional) associations with **0..1:1, 0..1:n and m:n multiplicities** can be modeled. These schemas can be reproduced via *@BidirectionalRule*. If both sides use a simple reference, the 0..1:1 schema will be applied and setter methods on both sides are expected (e.g. via *@SetterRule*). If one side uses a simple reference and the other side a set of references (*java.util.Set*), the 0..1:n schema will be applied. The side containing a set of references is required to have adder and remover methods for single references (e.g. via *@AdderRule*/*@RemoverRule* and *single* set to *true*), the other side is required to have a setter method again. Finally, if both sides have a set of references, the m:n schema will be applied and adder/remover methods are required on both sides.

An example for realizing a 0..1:n association is shown below. On one side, there is field *location* in class *City*, and on the other side, there is field *cities* in class *Country* and they refer to each other. If a *City* object sets a *Country* object as *location*, this *City* object will be added to the *cities* set within the *Country* object. The *City* object will also be removed from any *cities* set it has been before. The other way around, if a *Country* object adds a *City* object to *cities*, this *Country* object will be set as *location* for the *City* object. This behavior is also reflected in the exemplary output code shown below.

##### Input (Code)

```java
package virtual;

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.BidirectionalRule

@ApplyRules
class City {

	@GetterRule
	@SetterRule
	@BidirectionalRule("cities")
	Country location

}

@ApplyRules
class Country {

	@GetterRule
	@AdderRule
	@RemoverRule
	@BidirectionalRule("location")
	java.util.Set<City> cities = new java.util.HashSet<City>

}
```


##### Output (Code - Logical)

```java
package virtual;

public class City {

	private Country location;

	public Country getLocation() {
		return location;
	}

	public boolean setLocation(Country $location) {
		if (this.location != $location) {
			Country oldValue = this.location;
			this.location = $location;
			if (oldValue != null)
				oldValue.removeFromCities(this);
			if ($location != null)
				$location.addToCities(this);
			return true;
		}
		return false;
	}

}
```


```java
package virtual;

public class Country {

	private java.util.Set<City> cities = new java.util.HashSet<City>();

	public java.util.Set<City> getCities() {
		return java.util.Collections.unmodifiableSet(cities);
	}

	public boolean addToCities(City $element) {
		if (cities.contains($element))
			return false;
		cities.add($element);
		$element.setLocation(this);
		return true;
	}

	public boolean removeFromCities(City $element) {
		if (!cities.contains($element))
			return false;
		cities.remove($element);
		$element.setLocation(null);
		return true;
	}

}
```


##### Hint

> It is not necessary that both sides declare a *@BidirectionalRule*. This way, it is possible to implement the mutator(s) on one side manually. Setting up the bidirectional connection from this side, however, should also be coded manually then.

##### Limitation

> If a new bidirectional connection shall be established, potential old connections must be cut. With the currently implemented logic this would mean that some fields must be set to *null* at least temporarily. Therefore, it is not possible to perfectly reproduce 1:1 or 1:n associations, e.g. by using *@NotNullRule* in addition (see [*null* Checks](#null-checks)). 
>
> In addition to this, if bidirectional connections are used, the usage of [change methods](#change-methods), which are called before a change, might be restricted. For example, during the call of such a change methods the current connection state might be inconsistent, because the internal algorithms are still processing a consistent connection state using mutator methods. Therefore, throwing exceptions there should be avoided.

#### Multi-Threading and Mutators

Calling generated mutators cannot be seen as atomic operation. Mutators can have complex operations behind, e.g. in order to create a consistent state of bidirectional connections (see [Bidirectional Connections](#bidirectional-connections)). Therefore, generated accessors and mutators should not be used in multi-threading scenarios except additional **synchronization mechanisms** are added. Such mechanisms can be added by applying annotation ***@SynchronizationRule***.

If this rule is applied, the generated accessor and mutator functionality will be embedded in a block with a fair reentrant read/write lock (*java.util.concurrent.locks.ReentrantReadWriteLock*). This means that multiple calls of one accessor from different thread can run in parallel, but one call of a mutator will block all accessor and mutator calls from other threads (not from this thread) until the change has been finalized.

*@SynchronizationRule* must specify the name of the lock via its *value*. The applied name is used to acquire a lock from a global namespace. This means that fields using *@SynchronizationRule* with the same name actually use the same lock. In general, the locking mechanism does not work object-centric but class-centric, so accessing the same field of two different objects in different threads can block each other.

If the example from the section for [bidirectional connections](#bidirectional-connections) is used in a multi-threading environment, it should apply *@SynchronizationRule* for *location* and *cities* with the same lock name. This is shown in the code below.

##### Input (Code)

```java
package virtual;

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.BidirectionalRule
import org.eclipse.xtend.lib.annotation.etai.SynchronizationRule

@ApplyRules
class City {

	@GetterRule
	@SetterRule
	@BidirectionalRule("cities")
	@SynchronizationRule("virtual.CityCountry")
	Country location

}

@ApplyRules
class Country {

	@GetterRule
	@AdderRule
	@RemoverRule
	@BidirectionalRule("location")
	@SynchronizationRule("virtual.CityCountry")
	java.util.Set<City> cities = new java.util.HashSet<City>

}
```


##### Hint

In particular, the usage of a shared lock name in *@SynchronizationRule* can be very important, if using *@BidirectionalRule* in a multi-threading environment. If changes are initiated from different threads, deadlocks can occur. This problem can be resolved by using the same lock (name) on both sides.

### Generate the Implementation of Constructors and Methods

It is possible to **generate method or constructor implementations in derived classes based on an adaption rule** specified in a parent class. This rule is annotated on an abstract or non-abstract method by using ***@ImplAdaptionRule***. By default, each derived class will implement this method then using this rule.

The adaption rule is given by a string assigned to the ***value*** of *@ImplAdaptionRule*. It must follow the schema described in [Adaption Rule Specification](#adaption-rule-specification). The string will be evaluated during code generation and the evaluation result will be the (Java) code of the generated method's body.

There is also another supported parameter: ***typeExistenceCheck***. With this parameter another adaption rule can be specified. It is also evaluated whenever an implementation shall be generated. However, before the latter actually happens, the result of the evaluation based on *typeExistenceCheck* will be checked. If it does not resolve to an existing (qualified) type, the implementation will not be generated.

A very simple use case is shown in the example below. The methods *getClassName* and *createSoundObject* shall be generated in derived classes of *Animal* based on the name of the derived class. For example, the method *getClassName* of *AnimalDog* will return the string *"virtual.AnimalDog"* while *getClassName* of *AnimalLion* will return *"virtual.AnimalLion"* without the usage of Java Reflection.

The method *createSoundObject* will create a corresponding *Sound* object, e.g. *SoundDog* for *AnimalDog* and *SoundLion* for *AnimalLion*. Within *AnimalZebra* this method is not generated, because the rule also specified an appropriate *typeExistenceCheck*, but the resulting type *virtual.SoundZebra* does not exist.
 
##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ImplAdaptionRule

abstract class Sound {}

class SoundDog extends Sound {}

class SoundLion extends Sound {}

@ApplyRules
abstract class Animal {

	@ImplAdaptionRule("
		apply(return \");
		appendVariable(var.class.qualified);
		append(\";)")
	abstract def String getClassName()
	
	@ImplAdaptionRule(
		value="
			applyVariable(var.class.simple);
			replaceAll(Animal,);
			prepend(return new Sound);
			append(();)
		",
		typeExistenceCheck="
			applyVariable(var.class.qualified);
			replaceAll(Animal,Sound)
		")
	def Sound createSoundObject() { return null; }
	
}

@ApplyRules
class AnimalDog extends Animal {}

@ApplyRules
class AnimalLion extends Animal {}

@ApplyRules
class AnimalZebra extends Animal {}
```


##### Input (Diagram)

![](images/PlantUML_Modification_Implementation_In.png)

##### Output (Diagram)

![](images/PlantUML_Modification_Implementation_Out.png)

### Reimplement Constructors and Methods with Adapted Parameter and Return Types

With type adaption rules it is possible to **adjust the return type of a method** within derived classes. This means that wrapper method with the adapted types are generated, i.e., they are simply calling the method of the super class and returning its result, but they have another return type. For **parameter types the same principle can be used for constructors** (i.e. it is also possible for [Constructor Methods](#constructor-methods-and-construction-process)) **or *static* methods, which also apply *@ImplAdaptionRule***.

Usually, the reason for adapting types by such rules is to reflect the limitation of the returned type in the derived class's method or the limitation of a parameter type when constructing an object of the derived class (see [Covariance](https://en.wikipedia.org/wiki/Covariance_and_contravariance_(computer_science))).

The example below shows such use cases. The method *getSound* in class *Animal* returns the stored *sound* object. The architectural idea is that this object shall have different types based on the concrete animal class, e.g. it has type *SoundDog* for *AnimalDog* or *SoundLion* for *AnimalLion*. Therefore, the method *getSound* shall specify these concrete types in sub classes of *Animal*. This enables simpler code when getting more concrete objects, but would also require boilerplate code in each sub class.

This can be solved by applying the annotation ***@TypeAdaptionRule*** to method *getSound* in class *Animal*. Annotating the method itself means that the return type (and not any parameter type) shall be adapted in derived classes. Because of this annotation *getMethod* is generated automatically with adapted return types in the classes *SoundDog* and *SoundLion*. The generated methods just take the result of the original method and cast it to the adapted type. Of course, the architectural conditions mentioned above must be fulfilled in order to have such casts working for sure.

The name of the adapted return type is actually processed using the ***value*** in *@TypeAdaptionRule*. This value is an [Adaption Rule Specification](#adaption-rule-specification). Please note, that for *AnimalZebra* this rule would result in a type called *virtual.SoundZebra*. Because the generation process actually **searches this type, but cannot find it, the type remains unchanged**. Therefore, there is no need to generate *getMethod* in *AnimalZebra*.

The parameter in the constructor of class *Animal* is annotated by *@TypeAdaptionRule* as well. According to the principles above, the constructor is generated for child classes and the annotated parameter type is adapted. In this case it means that *AnimalDog* can only be constructed by passing a *SoundDog* object and *AnimalLion* by passing a *SoundLion* object. The passed objects are automatically passed to the parent class's constructor, of course.

Please note again, that there is a special behavior for constructors. Although there is no type *SoundZebra* for *AnimalZebra*, which means that there is no type change for the constructor in *AnimalZebra*, it is still generated in order to enable the construction of *AnimalZebra*. Hence, there is **no need for implementing the constructor in *AnimalZebra* manually**.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

abstract class Sound {}

class SoundDog extends Sound {}

class SoundLion extends Sound {}

@ApplyRules
abstract class Animal {

	Sound sound

	new(
		@TypeAdaptionRule("
		applyVariable(var.class.qualified);
		replaceAll(Animal,Sound)")
		Sound sound
	) {
		this.sound = sound
	}

	@TypeAdaptionRule("
		applyVariable(var.class.qualified);
		replaceAll(Animal,Sound)")
	def Sound getSound() { return sound }

}

@ApplyRules
class AnimalDog extends Animal {}

@ApplyRules
class AnimalLion extends Animal {}

@ApplyRules
class AnimalZebra extends Animal {}
```


##### Input (Diagram)

![](images/PlantUML_Modification_Type_In.png)

##### Output (Diagram)

![](images/PlantUML_Modification_Type_Out.png)

##### Important

> The type resulting from the [Adaption Rule Specification](#adaption-rule-specification) should be fully qualified in order to avoid namespace problems.

##### Hint

> The described methodology does not only work within regular class hierarchies. Also classes extended by trait classes with (trait) methods using *@TypeAdaptionRule* will apply such rules and types will be adapted in further processing.

##### Limitation

> The adaption of type parameters within generic types is usually only possible, if using wildcards. For example, the return type *java.util.List<Sound>* cannot be adapted to *java.util.List<SoundDog>*, but *java.util.List<? extends Sound>* can be adapted to *java.util.List<? extends SoundDog>*.
>
> This must also be respected, if using collection types, *@TypeAdaptionRule* and the generation of accessors and mutators (see [Generate Accessors and Mutators](#generate-accessors-and-mutators)) together.

#### Reimplement Constructors without Parameters

The example in [Reimplement Constructors and Methods with Adapted Parameter and Return Types](#reimplement-constructors-and-methods-with-adapted-parameter-and-return-types) shows how constructors in derived classes, which basically have no functionality in addition, can be implemented automatically based on constructors in the parent class. This can be triggered by the type adaption rule on a parameter.

However, this use case can be valid even without adapting parameter types. For this, there is the annotation ***CopyConstructorRule***, which can be applied to several constructors in the base class. Each **annotated constructor will be implemented automatically in derived classes**, if there is no other manually implemented constructor.

An example can be found in the following section.

### Deactivate and Change Rules

Rules are usually applied for each derived class. However, there are several rules to avoid or change automatic class modification and even to stop for further derived classes.

In case of **methods, adaption is affected** (relating to further derivation) as soon as a derived class overrides it, i.e., there is a (manual) implementation of a method with the same name. In the class with the overridden method, there will be no adaption, of course. For further derived classes there are three possibilities:

1. Adaption will be **changed**, if the implemented method applies another adaption rule, i.e., the new adaption rule is applied.
2. Adaption will be **continued** unchanged, if the implemented method applies the annotation ***@AdaptedMethod***.
3. Adaption will be **stopped** in other cases.

In case of **constructors, adaption is affected** (relating to further derivation) as soon as a derived class implements any constructor. Any adaption rule for constructors is obsolete after that. However, it is possible to attach a new adaption rule to an implemented constructors again. This adaption rule will be considered for further derivation then.

The example below shows some of these cases. Method *getSound* in class *Animal* is annotated by *@TypeAdaptionRule*. It is already overridden in class *AnimalCarnivora*. However, it is annotated by *@AdaptedMethod* there, so adaption is not stopped and the method gets automatically generated in *AnimalFelidae*. The same method is overridden again in *AnimalLion*, but not annotated by *@AdaptedMethod* this time. Therefore, in the derived class *AnimalLionSouthAfrica* it is not generated.

Also the behavior for constructors is shown. Adaption is in place because *@TypeAdaptionRule* and *@CopyConstructorRule* (see [Reimplement Constructors without Parameters](#reimplement-constructors-without-parameters)) are applied to the two constructors in *Animal*, so both constructors are generated in *AnimalCarnivora* and *AnimalFelidae*. Later, in class *AnimalLion* there is one constructor implemented manually. Therefore, no constructor is generated in *AnimalLionSouthAfrica*, which is why a constructor must be implemented there by hand. 

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.AdaptedMethod
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

abstract class Sound {}

abstract class SoundCarnivora extends Sound {
	def void check() { /* ... */ }
}

abstract class SoundFelidae extends SoundCarnivora {}

abstract class SoundLion extends SoundFelidae {}

class SoundLionSouthAfrica extends SoundLion {}

@ApplyRules
abstract class Animal {

	Sound sound

	@CopyConstructorRule
	new() {
		this.sound = null
	}

	new(
		@TypeAdaptionRule("
		applyVariable(var.class.qualified);
		replaceAll(Animal,Sound)")
		Sound sound
	) {
		this.sound = sound
	}
	
	@TypeAdaptionRule("
		applyVariable(var.class.qualified);
		replaceAll(Animal,Sound)")
	def Sound getSound() { return sound }

}

@ApplyRules
abstract class AnimalCarnivora extends Animal {
	@AdaptedMethod
	override SoundCarnivora getSound() {
		val soundCarnivora = super.sound as SoundCarnivora
		soundCarnivora.check
		return soundCarnivora
	}
}

@ApplyRules
abstract class AnimalFelidae extends AnimalCarnivora {}

@ApplyRules
abstract class AnimalLion extends AnimalFelidae {

	new(SoundLion soundLion) {
		super(soundLion)
	}

	override SoundLion getSound() {
		return super.getSound() as SoundLion
	}

}

@ApplyRules
class AnimalLionSouthAfrican extends AnimalLion {
	new(SoundLion soundLion) {
		super(soundLion)
	}
}
```


##### Input (Diagram)

![](images/PlantUML_Modification_Deactivate_In.png)

##### Output (Diagram)

![](images/PlantUML_Modification_Deactivate_Out.png)

### Generate Factory Methods

The ETAI library supports the **generation of factory methods**, i.e. methods for creating an object instead of using constructors. This feature enables [Constructor Methods](#constructor-methods-and-construction-process) in trait classes (see [Automatic Generation of Constructors](#automatic-generation-of-constructors)), and it can be useful, if additional code shall be executed automatically after object construction (see [Initialization after Object has been Constructed Completely](#initialization-after-object-has-been-constructed-completely)), or the factory methods become part of a factory (see [Generate Factories](#generate-factories)).

In order to generate factory methods, a class and derived classes must enable adaption (*@ApplyRules*). Afterwards, the first class in the type hierarchy, which shall get a factory method, must be annotated by a rule represented by ***@FactoryMethodRule***. All derived classes will also get a factory method according to the same rule. However, the rule can be changed by derived classes by annotating it again with other options. It can even be deactivated by annotating *@FactoryMethodRule* to a derived class and setting parameter *factoryMethod* to an empty string.

The annotation *@FactoryMethodRule* supports several parameters, which allow for different patterns, e.g. a naming pattern or if the method shall be generated inside a factory class (see [Generate Factories](#generate-factories)). The name of the generated factory method can be defined by parameter ***factoryMethod***. It supports a special character *%*, which is replaced by the name of the class, in which the factory method is generated.

The generated factory methods will reflect the parameters of the given constructors and factory methods will call them accordingly. This also works in scenarios, where this rule is combined with other rules and concepts of the ETAI library, i.e., it might be that constructors are not present in the Xtend code, because they will be generated as well (cp. [Reimplement Constructors without Parameters](#reimplement-constructors-without-parameters) or [Constructor Methods and Construction Process](#constructor-methods-and-construction-process)).

As soon as factory methods are generated, **constructors become *protected***, i.e., classes usually can only be created via factory method from outside.

#### Initialization after Object has been Constructed Completely

If there is code, which shall be **executed after the object has been constructed completely**, the parameter ***initMethod*** can help. With this parameter the name of a method can be specified. This method will be called automatically after the complete construction, no matter which factory method has been called. Thereby, the word "complete" is important, because this actually means that it is save to call any method, which is not possible within constructors (cp. [Calling Methods from a Constructor](https://www.javaspecialists.eu/archive/Issue210.html)). However, **the method must not have parameters or a return value (*void*)**.

In the example, class *Animal* specifies a factory method rule, which is why two factory methods are generated based on the two constructors of *Animal*. It also shows method *init*, which is called automatically after the object has been constructed via factory method. 

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule

@ApplyRules
@FactoryMethodRule(factoryMethod="create%", initMethod="init")
class Animal {
	
	int age
	
	@CopyConstructorRule
	new() { this.age = 0 }
	
	@CopyConstructorRule
	new(int age) { this.age  = age }
	
	def void init() {}
	
}
```


##### Input (Diagram)

![](images/PlantUML_Modification_Factory_Method_In.png)

##### Output (Diagram)

![](images/PlantUML_Modification_Factory_Method_Out.png)

#### Factory Method  

The return type of the generated factory method usually matches the class it is generated for (see the example in [Initialization after Object has been Constructed Completely](#initialization-after-object-has-been-constructed-completely)).

However, it is possible to influence the return type of the generated methods. This can be accomplished via an adaption rule specification (see [Adaption Rule Specification](#adaption-rule-specification)) in parameter ***returnTypeAdaptionRule*** of *@FactoryMethodRule*. If the specified string is not empty, the rule will be applied in order to determine the return type of the factory method.

If the application of the adaption rule specification would lead to a string, which does not represent a locatable type, the generation does not consider the adaption rule.

### Generate Factories

Another parameter of *@FactoryMethodRule* (see [Generate Factory Methods](#generate-factory-methods)) is ***factoryInstance***. If it is non-empty, an inner class *Factory* (*private*) will be generated for all adapted classes. This class represents a **factory class** (see [Factory](https://en.wikipedia.org/wiki/Factory_(object-oriented_programming))). In this case, the factory method will not be in the adapted class directly, but inside the factory class.

A *public*, *static* instance of this class will be made available via the adapted class as well. The name of this instance is given by *factoryInstance*. The variable will be declared *final* (or read-only) unless parameter ***factoryInstanceFinal*** of *@FactoryMethodRule* is explicitly set to *false*.

If generating factory classes, it can also be helpful to provide an interface for them, which allows for supporting the [Abstract Factory Pattern](https://en.wikipedia.org/wiki/Abstract_factory_pattern). The type of such an interface can be specified by setting the ***factoryInterface*** parameter.

An alternative to *factoryInterface* is ***factoryInterfaceVariable*** (both must not be used). In case of *factoryInterfaceVariable*, the name of the factory class's interface is not fixed, but will be equal to the value of an adaption variable (see [Use Adaption Variables](#use-adaption-variables)) in context of the adapted class. The name of the adaption variable is given by *factoryInterfaceVariable*. If the referred adaption variable is not set, an interface will not be applied.

By default, the generated factory classes will not use inheritance, i.e. the factory class generated for class *A* will not be the parent class (*extends*) for the factory class generated for class *B* which extends *A*. Inheritance can lead to the problem that the *B*-factory has to override the (factory) methods of the *A*-factory, which might be *abstract* methods, if *A* is *abstract*. This can result in errors, if *B* does not implement the same constructor as *A* (e.g. parameters changed). In this case, the factory method in the *B*-factory has other parameters compared to the factory method in the *A*-factory. However, if inheritance of generated factory classes is not an issue, this feature can be enabled by setting parameter ***factoryClassDerived*** of *@FactoryMethodRule* to *true*.

The example below shows the generation of factory classes. The rule specification can be found on *Animal*. Based on this, *AnimalLion* and *AnimalDog* generate two factory classes. Both implement their interface *IAnimalFactory*, and both can be referenced by a *static* attribute called *FACTORY*. Finally, method *main* shows how an *AnimalLion* object can be constructed.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule

interface IAnimalFactory {
	def Animal create(int age)
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", factoryInstance="FACTORY",
	factoryInterface=IAnimalFactory, factoryClassDerived=true)
abstract class Animal {

	int age

	@CopyConstructorRule
	new(int age) { this.age = age }

}

@ApplyRules
class AnimalLion extends Animal {}

@ApplyRules
class AnimalDog extends Animal {}

class App {
	static def main(String[] args) {
		val IAnimalFactory animalFactory = AnimalLion.FACTORY
		val animal = animalFactory.create(12)
	}
}
```


##### Input (Diagram)

![](images/PlantUML_Modification_Factory_Class_In.png)

##### Output (Diagram)

![](images/PlantUML_Modification_Factory_Class_Out.png)

### Generate Default Implementations of Missing Methods

The default implementation feature of the ETAI library can be used for **generating default implementations of methods automatically**. This is useful for simplifying the implementation of mock classes in testing scenarios, for example.

In order to use this feature, a non-abstract class is annotated by *@ImplementDefault*. Afterwards, **default methods** are generated in the Java code for all **missing methods**. Please note, that this feature is not based on rules and therefore does not require *@ApplyRules*.

The term "missing methods" refers to methods, which are declared *abstract* in a parent class (or in an implemented interface) and are not implemented, yet. The term "default method" means a method, which is empty and does not do anything in general. At least an appropriate value will be returned, if the method specifies a return type.

For all numerical return types the returned value is a representation of zero. For *boolean* the value *false* is returned. And finally for all non-primitive types, *null* is returned, e.g. for *String* or even *Integer*.  

The following example shows how to enable default implementation. The class *ElephantMock* does not implement any method. Because of the abstract method in the parent class *AnimalBase* and obligations due to the implemented interface *IElephant*, some methods like *getWeight* must be implemented. However, this is done automatically, so after applying ***@ImplementDefault*** there actually exists a (default) method *getWeight* which returns zero.

Please note, that generated default methods are annotated by ***@DefaultImplementation***, which might be available using reflection during runtime. 

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ImplementDefault

interface IElephant {
	def void trumpet()
}

abstract class AnimalBase {
	abstract def float getWeight()
	abstract def String getName()
}

@ImplementDefault
class Elephant extends AnimalBase implements IElephant {
}
```


##### Input (Diagram)

![](images/PlantUML_ImplementDefault_Simple_In.png)

##### Output (Diagram)

![](images/PlantUML_ImplementDefault_Simple_Out.png)

### Adaption Rule Specification

Some features of the ETAI library require the specification of an *adaption rule* (cp. [Generate the Implementation of Constructors and Methods](#generate-the-implementation-of-constructors-and-methods) or [Reimplement Constructors and Methods with Adapted Parameter and Return Types](#reimplement-constructors-and-methods-with-adapted-parameter-and-return-types)).

An adaption rule specification is stored in a string, which contains **adaption function calls**. Thereby, each adaption function call looks similar to a regular Java function call. Multiple adaption function calls are separated by ";".

When applying an adaption rule the adaption function calls are executed sequentially and each function manipulates the **current value**, which is a string and starts *empty*. After the last adaption function call, this value represents also the *result*.

The following diagram describes this principle. The basis is this adaption rule specification:

| **apply(Test);append(MyWorld);replace(My,Hello)** |
|:-------------------------:|

![](images/PlantUML_AdaptionFunctions_Principle.png)

#### Adaption Functions

The following table lists supported *adaption functions*:

| Function                  | Description                                                    |
| ------------------------- |---------------------------------------------------------------:|
| ***apply(x)*** | *x* will replace the *current value* |
| ***append(x)*** | *x* will be appended to the *current value* |
| ***prepend(x)*** | *x* will be prepended to the *current value* |
| ***applyVariable(x)*** | adaption variable *x* (see [Use Adaption Variables](#use-adaption-variables)) will be queried and replace the *current value* |
| ***appendVariable(x)*** | adaption variable *x* (see [Use Adaption Variables](#use-adaption-variables)) will be queried and be appended to the *current value* |
| ***prependVariable(x)*** | adaption variable *x* (see [Use Adaption Variables](#use-adaption-variables)) will be queried and be prepended to the *current value* |
| ***replace(x,y)*** | in the *current value* all occurrences of *x* will be replaced by<nobr>&nbsp;<nobr>*y* |
| ***replaceAll(x,y)*** | in the *current value* all occurrences of *x* will be replaced by *y* (support of [regular expressions](https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html#sum)) |
| ***replaceFirst(x,y)*** | in the *current value* the first occurrence of *x* will be replaced by *y* (support of [regular expressions](https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html#sum)) |
| ***addTypeParam(x)*** | *specific for type adaption rules*: *x* is an adaption rule specification (nested rule), which will be evaluated and (if not empty) added as type parameter to the *current value* |
| ***addTypeParamWildcardExtends(x)*** | *specific for type adaption rules*: *x* is an adaption rule specification (nested rule), which will be evaluated and (if not empty) added as type parameter to the *current value* using the format "? extends *result-of-x*"  |
| ***addTypeParamWildcardSuper(x)*** | *specific for type adaption rules*: *x* is an adaption rule specification (nested rule), which will be evaluated and (if not empty) added as type parameter to the *current value* using the format "? super *result-of-x*"  |
| ***alternative(x)*** | see [Adaption Function: *alternative*](#adaption-function-alternative) |

#### Predefined Adaption Variables

Within adaption rule specifications it is possible to access the values of **adaption variables**. They can be set and changed freely in context of a class hierarchy (see [Use Adaption Variables](#use-adaption-variables)). However, there are also predefined variables, which are usually automatically set in relation to the current generation context. An example can be found here: [Reimplement Constructors and Methods with Adapted Parameter and Return Types](#reimplement-constructors-and-methods-with-adapted-parameter-and-return-types).

The following table shows existing predefined adaption variables:

| Adaption Variable         | Value                                                    |
| ------------------------- |---------------------------------------------------------------:|
| ***var.package*** | the package name |
| ***var.class.simple*** | the class name (unqualified) |
| ***var.class.qualified*** | the fully qualified class name |
| ***var.class.abstract*** | if the class is abstract "true", otherwise "false" |
| ***var.class.typeparameters*** | the name of all type parameter (comma-separated) |
| ***var.class.typeparameters.count*** | the number of type parameters |
| ***var.class.typeparameter.1*** | the name of type parameter *#1* (if available) |
| ***var.class.typeparameter.2*** | the name of type parameter *#2* (if available) |
| *...* | |
| ***var.class.typeparameter.x*** | the name of type parameter *#x* (if available) |
| ***const.bracket.round.open*** | round bracket, open, "("<br>(enables workaround to access this character in specific situations) |
| ***const.bracket.round.close*** | round bracket, closed, "("<br>(enables workaround to access this character in specific situations) |

#### Adaption Function: *alternative*

The adaption function *alternative* can only be applied for type adaption rules (see [Reimplement Constructors and Methods with Adapted Parameter and Return Types](#reimplement-constructors-and-methods-with-adapted-parameter-and-return-types)) and is special. It **must be the last call** within an adaption rule specification (except other *alternative* calls) and opens an **alternative result path**. In general, within *alternative(x)* another adaption rule specification can be nested.

If the evaluation of the adaption rule until an *alternative* call does not result in a string which represents a valid type, the adaption rule within *alternative* will be evaluated and used as result (if valid).

The following diagram exemplifies this adaption rule specification:

| **apply(X1);alternative(replace(1,2));alternative(replace(2,3))** |
|:-------------------------:|

![](images/PlantUML_AdaptionFunctions_Alternative.png)

##### Limitation

> The adaption function *alternative* is applicable only on top-level (no further nesting).

### Use Adaption Variables

Within adaption rule specifications it is possible to access so-called **adaption variables**, e.g. via function *appendVariable* (see [Adaption Functions](#adaption-functions)). There are predefined adaption variables (see [Predefined Adaption Variables](#predefined-adaption-variables)), but it also possible to define own adaption variables and set values.

In order to set an adaption variable, the annotation ***@SetAdaptionVariable*** must be applied to a class. The variables which are set this way will be available for rule specifications within the annotated class and any derived class. Of course, a derived class can also override the value of the adaption variable using *@SetAdaptionVariable* again.

The following example shows how to set and override the adaption variables *var.cat.female* and *var.cat.striped*. They are also used in an *@ImplAdaptionRule*.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ImplAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.SetAdaptionVariable

@ApplyRules
@SetAdaptionVariable("
	var.cat.striped=false")
abstract class AnimalCat {

	@ImplAdaptionRule("
		apply(return \");
		appendVariable(var.cat.female);
		append(\";)")
	static def String getFemaleName() { return "Queen"; }
	
	@ImplAdaptionRule("
		apply(return );
		appendVariable(var.cat.striped);
		append(;)")
	abstract def boolean isStriped()

}

@ApplyRules
@SetAdaptionVariable("
	var.cat.female=Tigress,
	var.cat.striped=true")
class AnimalTiger extends AnimalCat {}

@ApplyRules
@SetAdaptionVariable("var.cat.female=Lioness")
class AnimalLion extends AnimalCat {}
```


##### Input (Diagram)

![](images/PlantUML_Modification_Variables_In.png)

##### Output (Diagram)

![](images/PlantUML_Modification_Variables_Out.png)

## Traits

### Overview

Extending classes via trait classes is the most powerful feature of the ETAI library. With the traits mechanism, it is possible to directly "inject" methods from so-called **trait classes** into classes beyond regular Java inheritance mechanisms. Thereby, trait classes can also specify and use attributes, i.e., **stateful extension** via trait classes is possible. It feels a little bit like [multiple inheritance](https://en.wikipedia.org/wiki/Multiple_inheritance) known from other languages like C++ and is an adaption of the [Traits](https://en.wikipedia.org/wiki/Trait_(computer_programming)) or [Mixin](https://en.wikipedia.org/wiki/Mixin) concept.

### Basic Usage of Trait Classes

Each regular (Xtend) class can be extended by trait classes besides usual class inheritance. This means that annotated methods of the trait classes will be "injected" into the **extended class**. This happens during code generation of the Java code. Actually, the generated code will call the method of the trait class by using a delegation pattern, i.e., internally an object of trait type is maintained. This way, methods of trait classes can also access and use attributes, which are defined inside the trait class.

A trait class must be declared *abstract* and annotated by ***@TraitClass***. This implicates several effects. First, a mirror interface will be extracted exactly as if *@ExtractInterface* is annotated (cp. [Interface Extraction](#interface-extraction)). Second, trait classes support attributes, but they do not support the specification of non-private, non-static methods and constructors. Non-*private*, non-*static* methods must be so-called **trait methods** and annotated accordingly. There are:

- [Exclusive Methods](#exclusive-methods)
- [Processed Methods](#processed-methods)
- [Required Methods](#required-methods)
- [Envelope Methods](#envelope-methods)

Private or static methods can be used as usual.

Instead of constructors, trait classes must specify so-called **constructor methods** (see [Constructor Methods and Construction Process](#constructor-methods-and-construction-process)). Basically, they are a fifth type of trait method.

In order to extend a class by a trait class, **the mirror interface of the trait class must be included in the list of implemented interfaces** (*implements*) of the class which shall be extended. In addition, the this class must be annotated by ***@ExtendedByAuto***.

The example below shows a class named *Dog* which is extended by trait class *XNamed*. This trait class shall simply offer attribute *name* and the according methods *getName* and *setName* for any class, which is extended by this trait class. In order to extend dog this way, it *implements* the mirror interface *IXNamed*. Therefore it gets *getName* and *setName*, which can be used for any *Dog* object.

Internally, *getName* and *setName* delegate to the methods implemented in *XNamed* via *delegate\$XNamed*. The attribute *name* can logically be considered as part of class *Dog*, but there is no access to it except via getter/setter. The used annotation *@ExclusiveMethod* for the trait methods *getName* and *setName* is explained in [Exclusive Methods](#exclusive-methods). 

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClass

import virtual.intf.IXNamed

abstract class Animal {
    int age
    def int getAge() {age}
    def void setAge(int age) {this.age = age}
    abstract def void move()
}

@TraitClass
abstract class XNamed {

    String name

    @ExclusiveMethod
    override String getName() {name}

    @ExclusiveMethod
    override void setName(String name) {this.name = name}

}

@ExtendedByAuto
class Dog extends Animal implements IXNamed {
	override void move() {/*...*/}
}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Simple_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Simple_Out_Logical.png)

##### Output (Diagram - Technical / Java)

![](images/PlantUML_ExtendedBy_Simple_Out_Java.png)

##### Hint

> Historically, the annotation ***@ExtendedBy*** was the only way to apply trait classes. With *@ExtendedBy* such trait classes can explicitly be specified within the annotation itself (*value*). However, it was not possible to enable the usage of Java Generics this way.
>
> Therefore, other possibilities have been investigated including the usage of a string. The easiest way, however, was to request the specification of the mirror interfaces of trait classes via *implements* in addition. The annotation *@ExtendedByAuto* does not demand the specification of any trait class, but it scans the listed interfaces for trait classes (resp. their mirror interfaces) and applies all of them automatically.
>
> **Java Generics are fully supported** now.

### Exclusive Methods

**Exclusive methodes** are the simplest type of trait methods. They are annotated by ***@ExclusiveMethod*** and demand that the **extended class does not have an implementation** of the method, yet. Logically, it can be considered that the exclusive method is simply copied ("injected").

An example can be found in [Basic Usage of Trait Classes](#basic-usage-of-trait-classes). If class *Dog* in that example implemented a method *getName* itself already, there would be an error reported by the active annotation processor.

### Required Methods

Another type of trait methods are **required methods** which are annotated by ***@RequiredMethod***. They must not be implemented and can be considered as a **way to define *abstract* methods** within trait classes and serve a very similar purpose, e.g. the declared method can already be used in algorithms of the trait class.

Primarily, the possibility to specify required methods is just a simplification, because it is not necessary to create and apply additional interfaces. In addition, it is also possible to demand methods, which are not *public*. This cannot be realized via interfaces.

In the example, there are three declarations of required methods within *XFlying*. They can be used in method *fly*, but they must be implemented somewhere in the extended class's hierarchy. This is ensured via different mechanisms, which is why three examples are shown. For *isHealthy* nothing happens during generation, because it is already implemented in the base class *Bird*. The method *getFlyingSpeedFactor* is included in the mirror interface *IXFlying*, which is a base mechanism for *public* trait methods. Finally, there are several cases where implementation must be ensured by generating an *abstract* method in the extended class. Such a scenario is illustrated by the *protected* method *isFledged*, which is included in *Raptor* therefore. Because it is generated with keyword *abstract* there, it must be implemented later on.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClass

import virtual.intf.IXFlying

abstract class Bird {
	int age
	def protected boolean isHealthy() {true}
	def int getAge() {age}
}

@TraitClass
abstract class XFlying {

	@ExclusiveMethod
	override void fly() {
		if (isHealthy && isFledged && flyingSpeedFactor > 0) {/*...*/}
	}

	@RequiredMethod
	abstract protected def boolean isHealthy()

	@RequiredMethod
	abstract protected def boolean isFledged()
	
	@RequiredMethod
	abstract override double getFlyingSpeedFactor()

}

@ExtendedByAuto
abstract class Raptor extends Bird implements IXFlying {
}


class Eagle extends Raptor {
	override protected boolean isFledged() { age >= 1 }
	override double getFlyingSpeedFactor() { 100.0 }
}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Required_Method_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Required_Method_Out_Logical.png)

### Processed Methods

**Processed methods** allow that the method is already implemented in the extended class. They must be annotated in the trait class by ***@ProcessedMethod***.

This means that next to the method in the trait class, **the same method might exist in the extended class**. If this is not the case, the method in simply injected (see [Exclusive Methods](#exclusive-methods)). If the method exists in both classes the execution order must be coordinated and the final result based on two return values must be calculated. For that reason, a processed method needs to specify a **trait method processor**. This way it can be defined, if only one of the methods shall be executed or the return value shall be combined, for example.

With such a processor a huge variety of scenarios can be realized. They can be implemented individually (see [Implement Own Trait Method Processor](#implement-own-trait-method-processor)), but there are also standard ones (see [Standard Trait Method Processors](#standard-trait-method-processors)).

#### Standard Trait Method Processors

The following trait method processors are predefined and ready-to-use (package *org.eclipse.xtend.lib.annotation.etai*):

| Trait Method Processor    | Return Type     | Description                                                    |
| ------------------------- |:----------:|---------------------------------------------------------------:|
| ***EPDefault*** | any | If the trait method exists in the extended class, the extended class will override the functionality in the trait class, i.e. the functionality in the trait class just represents a default behavior. |
| ***EPOverride*** | any | The trait method overrides a potential method in the extended class. |
| ***EPVoidPre*** | *void* | The trait method is executed before a potential method in the extended class. |
| ***EPVoidPost*** | *void* | The trait method is executed after a potential method in the extended class. |
| ***EPVoidFinally*** | *void* | The trait method is executed after a potential method in the extended class, even if there has been an exception. |
| ***EPBooleanPreAnd*** | *boolean* | The trait method is executed before a potential method in the extended class. If such a method exists in the extended class, it will only be executed, if the result of the trait method is *true* (short-circuit evaluation). Afterwards, both results are combined via AND operation. |
| ***EPBooleanPostAnd*** | *boolean* | The trait method will only be executed after a potential method in the extended class, if the result of such a method is *true* (short-circuit evaluation). Afterwards, both results are combined via AND operation. If such a method does not exist, only the trait method will be called. |
| ***EPBooleanPreOr*** | *boolean* | The trait method is executed before a potential method in the extended class. If such a method exists in the extended class, it will only be executed, if the result of the trait method is *false* (short-circuit evaluation). Afterwards, both results are combined via OR operation. |
| ***EPBooleanPostOr*** | *boolean* | The trait method will only be executed after a potential method in the extended class, if the result of such a method is *false* (short-circuit evaluation). Afterwards, both results are combined via OR operation. If such a method does not exist, only the trait method will be called. |
| ***EPFirstNotNullPre*** | non-*void* | The functionality of the trait class will be processed first. If there is a result, which is not *null*, this result will be returned immediately. If the result is *null*, the functionality of the extended class (if existing) will be processed afterwards and the latter result will be returned. |
| ***EPFirstNotNullPost*** | non-*void* | The functionality of the extended class (if existing) will be processed first. If there is a result, which is not *null*, this result will be returned immediately. If the result is *null* (or there is no method in the extended class), the functionality of the trait class will be processed afterwards and the latter result will be returned. |
| ***EPExtendedResultPre*** | non-*void* | The functionality of the trait class will be processed first. Afterwards, the functionality of the extended class (if existing) will be processed. The returned result will be the result from the functionality of the extended class, if this functionality exists. Otherwise, the result from the functionality of the trait class will be used. |
| ***EPExtendedResultPost*** | non-*void* | The functionality of the extended class (if existing) will be processed first. Afterwards, the functionality of the trait class will be processed. The returned result will be the result from the functionality of the extended class, if this functionality exists. Otherwise, the result from the functionality of the trait class will be used. |
| ***EPTraitClassResultPre*** | non-*void* | The functionality of the trait class will be processed first. Afterwards, the functionality of the extended class (if existing) will be processed. The returned result will be the result from the functionality of the trait class. The result from the functionality of the extended class will be ignored. |
| ***EPTraitClassResultPost*** | non-*void* | The functionality of the extended class (if existing) will be processed first. Afterwards, the functionality of the trait class will be processed. The returned result will be the result from the functionality of the trait class. The result from the functionality of the extended class will be ignored. |

In the example below, the consequences of three different standard trait method processors is shown.

First of all, the processed methods *getHuntingMethods* and *getHunters* both apply processor *EPDefault*. This means, that *XHunter* specifies two methods representing default behavior, which is used, if the extended class does not specify an own behavior. Therefore, the extended class *Lion* completely applies *getHuntingMethods* from *XHunter*, but uses its own *getHunters* method.

Another possibility is show by processed method *canHunt* which applies *EPBooleanPreAnd*. This way, in context of *Lion* both implementations of *canHunt* (from *XHunter* and *Lion* itself) are logically executed and combined via AND operation.

Finally, the processed method *hunt* shows a possible usage for *void* methods. On call of method *hunt*, the processor *EPVoidPost* ensures, that the implementation of *hunt* within *Lion* is executed first. Afterwards, the implementation of *hunt* within *XHunter* is executed.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.EPBooleanPreAnd
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass

import virtual.intf.IAnimal
import virtual.intf.IXHunter

@ExtractInterface
abstract class Animal {
	boolean adult
	boolean male
	override boolean isAdult() { adult }
	override boolean isMale() { male }
}

@TraitClass
abstract class XHunter implements IAnimal {

    @ProcessedMethod(processor=EPDefault)
    override String getHuntingMethods() {
        "pursue"
    }

    @ProcessedMethod(processor=EPDefault)
    override String getHunters() {
        "individuals"
    }
    
    @ProcessedMethod(processor=EPBooleanPreAnd)
    override boolean canHunt() {
        isAdult
    }

    @ProcessedMethod(processor=EPVoidPost)
    override void hunt(String prey) {
        System.out.println('''Hunting «prey»...''')
    }

}

@ExtendedByAuto
class Lion extends Animal implements IXHunter {

    override String getHunters() {
        "pack,lioness"
    }
    
    override boolean canHunt() {
        return !isMale
    }

    override void hunt(String prey) {
        System.out.println("Roar!")
    }

}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Processed_Method_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Processed_Method_Out_Logical.png)

#### Implement Own Trait Method Processor

As shown in the previous section, there are some standard processors which cover basic use cases. However, in case of more complex return types and accompanying requirements for combining return values and executing the methods, these use cases might not fit. Then it is necessary to write an own trait method processor.

A trait method processor must implement the interface ***TraitMethodProcessor*** and therefore its method ***call***. If a trait class's method *myMethod* gets annotated by *@ProcessedMethod* together with a trait method processor, the processor's *call* method will get responsible for executing the implementation of *myMethod* in the trait class and the potential implementation in the extended class. So it is wrapping the original implementations. For example, if the implementation of *call* is empty, actually nothing from the original implementations of *myMethod* will be executed.

Method *call* gets two arguments of type ***LazyEvaluation***: ***expressionTraitClass*** and ***expressionExtendedClass***. Both are actually [function objects](https://en.wikipedia.org/wiki/Function_object) which already bind the arguments for calling the original methods. Argument ***expressionExtendedClass* might be *null***, if there is no according method in the extended class. If such a method is required, by the way, it is possible to set attribute *required* of *@ProcessedMethod* to *true* (see [Flag: *required*](#flag-required)).

Objects of type *LazyEvaluation* offer method *eval*. If calling this method for *expressionTraitClass*, the implementation of the original method in the trait class is executed. If calling this method for *expressionExtendedClass*, the implementation of the original method in the extended class is executed. The return value of both executions is returned by *eval* and can be used and modified within *call*. In the end, also ***call* has to return a value**, which then represents the final result.

If the original method has return type *void*, *call* is simply expected to return *null*.

Besides method *eval* type *LazyEvaluation* offers the following methods:

- *int getNumberOfArguments()*: returns the number of arguments bound to the call of the original method
- *Object getArgument(int index)*: returns the argument (with the specified *index*) bound to the call
- *void setArgument(int index, Object value)*: changes the argument (with the specified *index*) bound to the call
- *Object getExecutingObject()*: returns the object executing the original method
- *java.lang.reflect.Method getMethod()*: returns the original method (e.g. can be used to check the method name)

The following code shows an exemplary trait method processor *ProcessorStringCommaSeparated*. It shall execute the original method of the extended class first and the original method of the trait class afterwards. It concatenates both resulting strings with a separating comma in between and returns the concatenated string.

This trait method processor is used for method *getCharacteristics* of all three trait classes *XFlying*, *XTalking* and *XColorful*. Class *Parrot* is extended by these trait classes, so in the end, it gets a method *getCharacteristics* which returns *"flying,talking,colorful"*, i.e. the individual results combined by *ProcessorStringCommaSeparated*.

The example also shows what happens, if multiple trait classes with the same processed method are applied. The extension starts with trait class  *XFlying*. This class logically introduces the first implementation of *getCharacteristics*. Second, *XTalking* is applied, so its method *getCharacteristics* gets combined with the first implementation (via *ProcessorStringCommaSeparated*). Finally, *XColorful* has another implementation of *getCharacteristics*, which again is combined with the combination before (also via *ProcessorStringCommaSeparated*). This represents the final logical behavior of the method *getCharacteristics*, which is injected into *Parrot*. 

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor

import virtual.intf.IXColorful
import virtual.intf.IXFlying
import virtual.intf.IXTalking

class ProcessorStringCommaSeparated implements TraitMethodProcessor {

	override Object call(
			LazyEvaluation expressionTraitClass,
			LazyEvaluation expressionExtendedClass) {
		if (expressionExtendedClass === null)
			return expressionTraitClass.eval() as String
		else
			return expressionExtendedClass.eval() as String + "," + 
				expressionTraitClass.eval() as String
	}

}

@TraitClass
abstract class XFlying {

	@ProcessedMethod(processor=ProcessorStringCommaSeparated)
	override String getCharacteristics() { "flying"	}

}

@TraitClass
abstract class XTalking {

	@ProcessedMethod(processor=ProcessorStringCommaSeparated)
	override String getCharacteristics() { "hunting" }

}

@TraitClass
abstract class XColorful {

	@ProcessedMethod(processor=ProcessorStringCommaSeparated)
	override String getCharacteristics() { "colorful" }

}

@ExtendedByAuto
class Parrot implements IXFlying, IXTalking, IXColorful {}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Processed_Method_Own_Processor_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Processed_Method_Own_Processor_Out_Logical.png)

### Envelope Methods

**Envelope methods** are annotated by ***@EnvelopeMethod***. They are similar to processed methods with *EPOverride* as processor (see [Standard Trait Method Processors](#standard-trait-method-processors)). This means, that any matching method of the extended class is overridden/masked by the envelope method. However, with envelope methods **it is possible to explicitly call the overridden method**. For that purpose, an envelope method can call ***method\$extended***, where *method* must be replaced by the actual method name.

In the example below, class *Frog* is shown, which already implements method *eat*. However, the same method is specified by its trait class *XEater*. It is marked as envelope method, so if called for a *Frog* object, the *eat* method of *XEater* will be executed first. However, it calls *eat\$extended*, i.e., also the original *eat* method of *Frog* is executed there. 

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClass

import virtual.intf.IXEater

@TraitClass
abstract class XEater {

	@EnvelopeMethod
	override String eat(String prey) {
		System.out.println('''LOG: start eating: «prey»''')
		val res = eat$extended(prey)
		System.out.println('''LOG: stop eating: «prey»''')
		System.out.println('''LOG: result: «res»''')
		return res
	}

}

@ExtendedByAuto
class Frog implements IXEater {

	override String eat(String prey) {
		if("fly".equals(prey)) "Yummy!" else "Yikes!"
	}

}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Envelope_Method_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Envelope_Method_Out_Logical.png)

#### Default Value Provider

Applying an envelope method usually requires that the extended class implements a matching method, because the envelope wants to call it (*method\$extended*). However, it might be ok that there is no such method in the extended class. If this is the case, the envelope must specify a **default value provider**. This provider has to provide a (default) value. If the method of the extended class is called, but such a method does not exist, this default value will be queried and used as if it is returned by the method.

The default value provider can be set by parameter ***defaultValueProvider*** of *@EnvelopeMethod*, whereby the potential value is a class. The given class must implement the interface ***DefaultValueProvider&lt;T&gt;***, where *T* can be replaced by the actual type of the provided default value. As a consequence, the class must implement method *getDefaultValue* which just has to return the default value.

An exemplary implementation of a default value provider is shown below. Because *Rabbit* does not implement method *eat*, but the trait class *XEater* calls *eat\$extended*, the default value *"ok"* is returned for a call of *eat*. This resulting value is caused by *StringOkProvider*.

If a default value provider is given, it is also meaningful to set the *required* flag of the *@EnvelopeMethod* annotation to *false* (see [Flag: required](#flag-required)).

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.DefaultValueProvider

import virtual.intf.IXEater

class StringOkProvider implements DefaultValueProvider<String> {

	override String getDefaultValue() { "ok" }

}

@TraitClass
abstract class XEater {

	@EnvelopeMethod(defaultValueProvider=StringOkProvider, required=false)
	override String eat(String prey) {
		System.out.println('''LOG: start eating: «prey»''')
		val res = eat$extended(prey)
		System.out.println('''LOG: stop eating: «prey»''')
		System.out.println('''LOG: result: «res»''')
		return res
	}

}

@ExtendedByAuto
class Rabbit implements IXEater {}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Envelope_Method_Default_Value_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Envelope_Method_Default_Value_Out_Logical.png)

### Additional Flags for Trait Methods

Some trait method annotations offer additional configuration parameters. They will be explained in the following.

#### Flag: *required*

It is possible for *@ProcessedMethod* and *@EnvelopeMethod* to **demand that the extended class already implements this method**. It is not sufficient, if there is only an abstract method.

In order to activate this demand, the flag ***required*** must be set in the annotation of the trait method.

In certain situations, it is not possible to change the value of this flag. For example, it must be set to *true* in case of *@EnvelopeMethod*, because the envelope method is able to call the method in the extended class. However, if a default value provider is given, it can be set to *false* (cp. [Default Value Provider](#default-value-provider)).

#### Flag: *setFinal*

For *@ExclusiveMethod*, *@ProcessedMethod* and *@EnvelopeMethod* the flag ***setFinal*** can be set. If it is set to *true*, the method **matching method in the extended class will be declared *final***.

Afterwards, the method cannot be overridden any more. This way, the trait class can **ensure that there is no derivation** in context of the extended class. This can be very important for processed methods or envelope methods. In case of *@EnvelopeMethod* the parameter *setFinal* is even set to *true* by default.

Sometimes, a trait method wants to guarantee that it is, for example, executed in the very beginning or the very end (*@ProcessedMethod*) of the whole algorithm, or a trait method wants to wrap the implementation of the extended class (*@EnvelopeMethod*) completely. This can only be guaranteed, if the method is set to *final*.

If it is necessary that child classes influence the functionality of a method, but it has been set to *final*, a possible solution would be to delegate the execution flow to another (internal) method. This pattern and also some more details concerning *setFinal* are shown in the example in [Redirection of Trait Methods](#redirection-of-trait-methods). 

### Redirection of Trait Methods

It is possible to specify **rules so that a trait method is renamed** before it is actually injected into the extended class. This can be done by a feature called **trait method redirection**.

If a method in the extended class is annotated by ***@TraitMethodRedirection***, which specifies a new method name via *String* *value*, each matching trait method will be renamed to this name before it is extending the class. In addition, it will become a new visibility, which is also specified by *@TraitMethodRedirection* via parameter *visibility* (default: *PROTECTED*). 

The redirection directive will be valid for the class in which it actually is set and for derived classes. However, as soon as the annotated method is overridden, the directive can be changed. Either the redirection is deactivated, if there is no *@TraitMethodRedirection* any more, or the values of the new annotation are used.

However, **trait methods can ignore the redirection**. For this, there is a parameter *disableRedirection*, which can be specified together with *@EnvelopeMethod*, *@ProcessedMethod* or *@ExclusiveMethod*. If the flag is set to to *true*, which is the default value for *@EnvelopeMethod*, any setting by *@TraitMethodRedirection* is ignored.

The following example shows redirection together with a use case. Trait class *XMoveLogger* specifies envelope method *move*. Its purpose is to log calls of method *move*. There shall be a log message before and after any other functionality within *move*, i.e. the envelope method must surround everything else. In order to ensure this, the flag *setFinal* is set to *true* (default) in *@EnvelopeMethod* and also redirection is disabled by setting *disableRedirection* to *true*. Because *move* becomes *final* in *Animal*, overriding is not possible any more, so the requirements mentioned above are always fulfilled.

However, it is intended that the functionality of *move* is overridden in child classes, which is why an internal method *moveInternal* is specified and called from within *move*. In case other trait classes want to extend *move* as well, a redirection to *moveInternal* is configured. Therefore, the processed method *move* of *XMoveDigger* adjusts *moveInternal* instead of *move*.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection

import virtual.intf.IXMoveDigger
import virtual.intf.IXMoveLogger

@TraitClass
abstract class XMoveLogger {

	@EnvelopeMethod
	override void move() {
		System.out.println("start moving...")
		move$extended
		System.out.println("stop moving...")
	}

}

@TraitClass
abstract class XMoveDigger {

	@ProcessedMethod(processor=EPVoidPost)
	override void move() {
		System.out.println("digging...")
	}

}

@ExtendedByAuto
abstract class Animal implements IXMoveLogger {

	@TraitMethodRedirection("moveInternal")
	override void move() {
		moveInternal
	}

	def protected void moveInternal() {
		System.out.println("moving...")
	}

}

@ExtendedByAuto
class Mole extends Animal implements IXMoveDigger {

	override protected void moveInternal() {
		super.moveInternal
		System.out.println("through the ground...")
	}

}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Method_Redirection_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Method_Redirection_Out_Logical.png)

##### Output (Diagram - Technical / Java)

![](images/PlantUML_ExtendedBy_Method_Redirection_Out_Java.png)

##### Hint

> Redirection allows that an exclusive method is renamed **before** it is checked, if it already exists in the extended class. 

### Constructor Methods and Construction Process

As trait classes can have a state, it might be necessary that this state is initialized as soon as an according object is constructed. Therefore, it is possible to define **constructor methods** by annotating methods in trait classes with ***@ConstructorMethod***. Initialization code can be placed in such methods then.

The name of a constructor method can be chosen freely. It has no impact on the generated code from a logical perspective. However, it must be declared *protected* and non-*static* and have return type *void*.

A constructor method can be thought of as constructor for the trait class, so exactly one constructor method for each trait class **must be called when an object extended by this trait is constructed**. This means that in each constructor of the extended class such a call must exist. There is an **assertion during runtime**, which checks this prerequisite. This requirement is not applicable, of course, if there is no constructor method or only one constructor method without any parameter in a trait class. In the latter case, the constructor method is called automatically at the beginning of processing the object construction.

For calling constructor methods, if applicable, **construction helper methods** are generated within the extended class. They are named ***new\$TraitClass*** where *TraitClass* is the name of the trait class containing the constructor methods. Such a helper method is generated for each constructor method. They are distinguished - exactly like constructors - only by parameters and their major purpose is to call the constructor method of the trait class.

This is also shown in the example below. Trait class *XWithName* specifies two constructor methods. Because *Cat* is extended by this trait class, two construction helper methods named *new\$XWithName* are generated. One of them must be called within each constructor of *Cat*. This is actually done. Attribute *name* gets a value during object construction for sure this way.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod

import virtual.intf.IXWithName

@TraitClass
abstract class XWithName {

	String name

	@ConstructorMethod
	protected def void createWithoutName() { this.name = "*noname*" }

	@ConstructorMethod
	protected def void createWithName(String name) { this.name = name }

	@ExclusiveMethod
	override String getName() { name } 

}

@ExtendedByAuto
class Cat implements IXWithName {
	
	int age

	new() {
		this.age = 0
		new$XWithName()
	}

	new(int age, String name) {
		this.age = age
		new$XWithName(name)
	}

	def int getAge() { age }

}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Constructor_Method_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Constructor_Method_Out_Logical.png)

##### Output (Diagram - Technical / Java)

![](images/PlantUML_ExtendedBy_Constructor_Method_Out_Java.png)

#### Automatic Generation of Constructors

In combination with [modification features](#automatic-modification-of-classes) of the ETAI library, there are possibilities to **ease the use of trait classes with construction methods**. The previous section has shown that construction helper methods must be called within constructors of the extended class. Such calls follow a specific pattern very often:

- the construction helper methods are called at the end of the constructor and
- the parameters needed by construction helper methods are added to the constructor's parameter lists and later passed to the construction helper methods.

If this pattern is needed, a **construct rule** can be applied. With this rule no change in the extended class concerning the construction of applied trait classes is required. However, it can only be used in combination with the [generation of factory methods](#generate-factory-methods). The generated factory methods of the extended class (and child classes) will automatically call constructor methods of trait classes, if the extended class is annotated by ***@ConstructRuleAuto***. Also the application of *@ApplyRules* is needed (see [Automatic Modification of Classes](#automatic-modification-of-classes)).

Parameters of constructor methods are fully supported by this technique. They are simply added to the generated factory methods. In the trivial case that there is only one constructor method in the trait class and one constructor in the extended class, the parameters of the constructor methods are added to the end of the constructor's parameter list and then transferred to the generated factory method. In cases where multiple constructor methods, multiple (or no) constructors in the extended class or even multiple trait classes exist, cross products are calculated during code generation in order to generate factory methods and their parameter lists. The order of parameters is based on the order of applying trait classes, whereas parameters of the extended class's constructor always start the parameter list.

This is shown in the following example. There are two trait classes *XWithSize* and *XWithName* which require a construction with a *size* and *name* (optional). The extended class *Cat* brings its own constructor with *age* (also optional). In fact, also a base class *Animal* is involved, but it does not affect the principle and therefore is ignored in this textual description.

The mentioned parameters are combined in order to generate the *create* factory methods. There are four factory methods because of the two optional parameters *name* and *age*. One of these factory methods supports the specification of all three parameters *age*, *size* and *name*, of course. All parameters are forwarded to the according implementation.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructRuleAuto
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.TraitClass

import virtual.intf.IXWithSize
import virtual.intf.IXWithName

@TraitClass
abstract class XWithSize {

	double size

	@ConstructorMethod
	protected def void createWithSize(double size) { this.size = size }

	@ExclusiveMethod
	override double getSize() { size }

}

@TraitClass
abstract class XWithName {

	String name

	@ConstructorMethod
	protected def void createWithoutName() { this.name = "*noname*" }

	@ConstructorMethod
	protected def void createWithName(String name) { this.name = name }

	@ExclusiveMethod
	override String getName() { name }

}

@ApplyRules
@ConstructRuleAuto
@ExtendedByAuto
@FactoryMethodRule(factoryMethod="create")
abstract class Animal implements IXWithSize {}

@ApplyRules
@ConstructRuleAuto
@ExtendedByAuto
class Cat extends Animal implements IXWithName {

	int age

	new() {
		this.age = 0
	}

	new(int age) {
		this.age = age
	}

	def int getAge() { age }

}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Construct_Rule_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Construct_Rule_Out_Logical.png)

##### Output (Diagram - Technical / Java)

![](images/PlantUML_ExtendedBy_Construct_Rule_Out_Java.png)

##### Hint

> There are more fine-granular possibilities to control the automatic generation of factory methods as described above. The origin of *@ConstructRuleAuto* is the annotation ***@ConstructRule***. This annotation expects that a list of classes is given by its *value*. The listed classes must be trait classes. For all listed trait classes the extended class and child classes are not expected to call corresponding construction helper methods. Generated factory methods are adapted accordingly (as described above). The annotation *@ConstructRuleAuto* is just a shortcut, which automatically applies these rules for all trait classes which extend the annotated class.
>
> In addition to this, there is the annotation ***@ConstructRuleDisable***. It can be applied, if a construct rule for a specific trait class is active, i.e., factory methods would be adapted in order to call corresponding construction helper methods. This is not a valid use case for classes which apply *@ConstructRule* or *@ConstructRuleAuto*, but for child classes, because construct rules are also inherited. If construction helper methods must be called manually again there, e.g. because calculations must be performed or parameters shall be controlled completely, a construct rule can be disabled for the specified trait classes via *@ConstructRuleDisable* and its *value*.

##### Limitation

> Of course, the automatic combination of parameters can lead to ambiguous factory methods. In this case, the described technique cannot be used and construction must be implemented manually. 

### *this* within Trait Classes

Trait classes can be thought of as extension for the class annotating it. Logically, if the annotated class is instantiated, we imagine one created object which contains all traits. It has the type the extended classes and trait classes (or rather their mirror interfaces). Technically, however, the object is composed of multiple sub objects including one object for each trait class (cp. [Basic Usage of Trait Classes](#basic-usage-of-trait-classes)).

#### Calling Methods inside of Trait Classes

Of course, if the keyword *this* is used within methods of trait classes, it will technically not reference the object, we logically construct, but the technical instantiation of the trait class. This can lead to several logical problems, e.g. when calling methods. Due to several internal mechanisms some of these logical problems have been solved.

For example, if a **trait method *methodX* within a trait class *A* calls *this.methodY***, whereas *methodY* is a trait method which is also in *A*, it does not necessarily mean that *methodY* of *A* is called. Imagine that *methodY* in *A* is a default method (cp. [Standard Trait Method Processors](#standard-trait-method-processors)), but the class extended by *A* has its own *methodY* implemented. In this case, it would usually be **expected that *methodY* of the extended class is called**, even if the call is within the trait class.

**The ETAI library can ensure this**. Technically, this is possible by renaming methods and adding helper methods within trait classes during Java code generation.

However, there is a **possibility to call the original method within the trait class explicitly**. This is even necessary in some use cases. For example, if the implementation of a method in the parent class shall be (re-)used. If trait method *methodX* wants to use the implementation of *methodX* in *B*, which is a parent class of *A*, it must call ***super.methodX\$impl*** instead of *super.methodX*. Using the latter usually even ends in an endless recursion. So, only **by adding *\$impl* the real implementation of a trait method can be called** from within a trait class.

The following showcase exemplifies this. Method *attack* within trait class *XPredator* calls *sound*. However, the method *sound* within *XPredator* is not called directly. In case of a *Tiger* object, it actually is called in the end, because *Tiger* does not specify any method. In context of a *Wolf* object, however, the *sound* method of the *Wolf* class is called.

The example also shows that method *sound* in *XPredator* wants to call the base functionality in *XAnimal*. For this it is using *super.attack\$impl*.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto

import virtual.intf.IXPredator

@TraitClass
abstract class XAnimal {

	@ExclusiveMethod
	override void attack() {
		System.out.println("-attacking-");
	}

}

@TraitClass
abstract class XPredator extends XAnimal {

	@ProcessedMethod(processor=EPDefault)
	override void sound() {
		System.out.println("Roar!")
	}

	@ExclusiveMethod
	override void attack() {
		super.attack$impl
		sound()
	}

}

@ExtendedByAuto
class Wolf implements IXPredator {

	override void sound() {
		System.out.println("Howl!")
	}

}

@ExtendedByAuto
class Tiger implements IXPredator {}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_This_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_This_Out_Logical.png)

##### Output (Diagram - Technical / Java)

![](images/PlantUML_ExtendedBy_This_Out_Java.png)

#### Usage of *\$extendedThis*

It is tricky to perform type checks regarding *this* within trait classes. As described above, *this* does not reference the logical object, which is extended by the trait class.

In order to perform type checks, ***\$extendedThis*** instead of *this* should be used:

| *if (\$extendedThis instanceof Type)* |
|:-------------------------:|

##### Hint

> *\$extendedThis* always references the extended class. Actually, *\$extendedThis* is a generated method with the trait class's mirror interface as return type, because the extended class also implements this interface. The method returns *\$extendedThis\$data* (see example in previous section). This member variable is automatically set accordingly during construction of the object.

### Trait Classes and Inheritance

Trait classes support inheritance and **most known techniques can be used as usual**. For example, it is possible to override trait methods and even changing the type of a trait method is sometimes possible. For example, it is possible to change a trait method from *@ExclusiveMethod* to *@ProcessedMethod*, but not from *@EnvelopeMethod* to anything else.

It is also important to know that **a trait class cannot be applied twice in the hierarchy of extended classes**. This is also a problem, if applied trait classes are not exactly equal, but there is a relationship, e.g. a trait class *A* is derived from trait class *B* (or the other way around). Then, it is not possible to extend a class by *A* and *B* together. 

The following sub sections show some more specifics regarding trait classes and inheritance.

#### Calling Trait Methods of Parent Class within Trait Classes

There is an important rule for calling trait methods in trait parent classes:

- If you want to call *super.method()* within a trait class, use **super.method\$impl** instead. This will apply, **if *method* is a trait method, but not a constructor method**.

The background and more details are explained in [Calling Methods inside of Trait Classes](#calling-methods-inside-of-trait-classes).

#### Base Trait Classes

If a class is declared *abstract* it is not possible to construct corresponding objects. However, writing such classes is still meaningful as some base functionality for derived classes can be implemented there.

This schema is also be applicable for trait classes, i.e. it is possible to declare trait classes with base functionality, but it should not be possible to use them already. The keyword *abstract*, however, is not suitable, because each trait class is declared *abstract* anyways as it should not be possible to construct them.

Therefore, it is possible to set flag *baseClass* in annotation *@TraitClass*. If it is set to *true*, it will not be possible to apply this trait class in order to extend another class. It can only be used as a base in order to derive other trait classes.

#### Trait Classes using Trait Classes

Trait classes can extend regular classes but not other trait classes via *@ExtendedByAuto*. However, there is a concept which solves this issue for the most part.

The ETAI library allows to declare that a **trait class *A* uses another trait class *B***. This way, methods in *B* can be called in context of methods of trait class *A*. This is possible, because it will be ensured that a class, which is extended by trait class *A*, is also extended by *B*. As soon as a class is extended by *A*, there is a check, if the class (or any parent class) has also been extended by *B*. If not, the extension by *B* will automatically be applied. In the end, the logically constructed object contains all required methods, which is why all calls are successful and work as expected. Internally, delegation and redirection of calls are used again. 

In order to specify that a trait class *A* is using trait class *B*, it is necessary for *A* to implement the mirror interfaces of *B* (*implements*), which follows the pattern of extending a regular class by a trait class. Instead of annotating a trait class by *@TraitClass*, it must be annotated by ***@TraitClassAutoUsing***. Of course, using multiple trait classes is supported.

The following example shows how class *Bird* is extended by trait class *XExtendedAttributes*. This trait class uses other trait classes: *XWithSpeed* and *XBasicAttributes*. *XBasicAttributes* again uses other trait classes, which finally results in the fact that *Bird* is extended by *XWithName*, *XWithAge* and *XWithSpeed*. It is also be extended by *XBasicAttributes* and *XExtendedAttributes*, of course, but in the end these trait classes are empty and they represent only an abstraction layer for combining further trait classes. An important fact, however, is that *XWithName* and *XWithAge* have already extended the base class *Animal*, which is why they are technically not extending *Bird* again.

Trait class *XWithSpeed* also shows that it is actually possible to call methods of used trait classes. Method *getSpeed* calls method *getAge*, which is implemented in *XWithAge*. This is possible, because it is ensured that the class which is extended by *XWithSpeed* will also be extended by *XWithAge*, so the corresponding implementation of *getAge* will be available in the constructed object.

##### Input (Code)

```java
package virtual

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.IXBasicAttributes
import virtual.intf.IXExtendedAttributes
import virtual.intf.IXWithAge
import virtual.intf.IXWithName
import virtual.intf.IXWithSpeed

@TraitClass
abstract class XWithName {

	String name

	@ExclusiveMethod
	override String getName() { name }

	@ExclusiveMethod
	override void setName(String name) { this.name = name }

}

@TraitClass
abstract class XWithAge {
	
	int age

	@ExclusiveMethod
	override int getAge() { age }

	@ExclusiveMethod
	override void setAge(int age) { this.age = age }
	
}

@TraitClassAutoUsing
abstract class XWithSpeed implements IXWithAge {
	
	double speed

	@ExclusiveMethod
	override double getSpeed() { if (age < 0 ) 0 else speed }

	@ExclusiveMethod
	override void setSpeed(double speed) { this.speed = speed }
	
}

@TraitClassAutoUsing
abstract class XBasicAttributes implements IXWithName, IXWithAge {}

@TraitClassAutoUsing
abstract class XExtendedAttributes implements IXBasicAttributes, IXWithSpeed {}

@ExtendedByAuto
abstract class Animal implements IXBasicAttributes {}

@ExtendedByAuto
class Bird extends Animal implements IXExtendedAttributes {}
```


##### Input (Diagram)

![](images/PlantUML_ExtendedBy_Using_In.png)

##### Output (Diagram - Logical)

![](images/PlantUML_ExtendedBy_Using_Out_Logical.png)

##### Hint

> Specifying the usage of other trait classes is also possible via parameter *using* of *@TraitClass*. The annotation *@TraitClassAutoUsing* is just a way to avoid a manual declaration by scanning the listed interfaces and using all trait classes found via their mirror interface (cp. with *@ExtendedByAuto* and *@ExtendedBy* in [Basic Usage of Trait Classes](#basic-usage-of-trait-classes)). 