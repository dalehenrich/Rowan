Class {
	#name : 'RwGsSymbolDictionaryRegistryV2',
	#superclass : 'Object',
	#instVars : [
		'symbolDictionary',
		'packageRegistry',
		'methodRegistry'
	],
	#category : 'Rowan-GemStone-LoaderV2'
}

{ #category : 'accessing' }
RwGsSymbolDictionaryRegistryV2 class >> defaultProtocolString [

	^ 'as yet unclassified'
]

{ #category : 'installation' }
RwGsSymbolDictionaryRegistryV2 class >> globalSymbol [

	^ #'RwSymbolDictionaryRegistry'
]

{ #category : 'installation' }
RwGsSymbolDictionaryRegistryV2 class >> installIn: aSymbolDictionary [

	| registry |
	registry := self newForSymbolDictionary: aSymbolDictionary.
	aSymbolDictionary at: self globalSymbol put: registry.
	^ registry
]

{ #category : 'instance creation' }
RwGsSymbolDictionaryRegistryV2 class >> newForSymbolDictionary: aSymbolDictionary [

	^ self new
		_symbolDictionary: aSymbolDictionary;
		initialize;
		yourself

]

{ #category : 'accessing' }
RwGsSymbolDictionaryRegistryV2 class >> registry_ImplementationClass [

	^ RwGsSymbolDictionaryRegistry_ImplementationV2

]

{ #category : 'method - private api' }
RwGsSymbolDictionaryRegistryV2 >> _doDeleteCompiledMethodFromLoadedThings: compiledMethod for: behavior [

	"remove a compiled method from loaded things"

	^ self class registry_ImplementationClass _doDeleteCompiledMethodFromLoadedThings: compiledMethod for: behavior instance: self

]

{ #category : 'method - private api' }
RwGsSymbolDictionaryRegistryV2 >> _doDeleteCompiledMethodFromLoadedThings: compiledMethod for: behavior implementationClass: implementationClass [

	"remove a compiled method from loaded things"

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass _doDeleteCompiledMethodFromLoadedThings: compiledMethod for: behavior instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> _loadedClassFor: class noNewVersion: noNewVersionBlock [

	self
		_loadedClassFor: class
		noNewVersion: noNewVersionBlock
		newVersion: [ :loadedClass | 
			self
				error:
					'internal error - the value associated with the key ' , class name printString
						, ' is not identical to the given class' ]
]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> _loadedClassFor: class noNewVersion: noNewVersionBlock newVersion: newVersionBlock [

	| loadedClass classKey |
	(class isKindOf: Class)
		ifFalse: [ self error: 'internal error - expected a class' ].
	loadedClass := self 
		loadedClassForClass: class 
		ifAbsent: [ 
			self
				error:
					'internal error - No loaded class found for the class ' , class name printString ].
	classKey := loadedClass key asSymbol.
	self
		_symbolDictionaryAssociationAt: classKey
		ifPresent: [ :assoc | 
			assoc value == class
				ifTrue: [ ^ noNewVersionBlock cull: loadedClass cull: assoc ]
				ifFalse: [ ^ newVersionBlock cull: loadedClass cull: assoc ] ].

	self
		error:
			'internal error - there is no assocation present in the receiver for the given class '
				, classKey asString printString
]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> _symbolDictionary [

	^ symbolDictionary
]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> _symbolDictionary: aSymbolDictionary [

	symbolDictionary := aSymbolDictionary
]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> _symbolDictionaryAssociationAt: aKey ifPresent: oneArgBlock [

	"Lookup the given key in the receiver's symbolDictionary. If it is present, answer the value of evaluating the oneArgBlock with the symbol association associated with the key, otherwise answer nil."

	| anAssoc |
	anAssoc := self _symbolDictionary associationAt: aKey otherwise: nil.
	anAssoc ifNotNil: [ ^ oneArgBlock cull: anAssoc ].
	^ nil
]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addClassAssociation: assoc forClass: class toPackageNamed: packageName [

	"Copy the name association to the correct 
        SymbolDictionary in the live SymbolList.
        Create a LoadedClass for the new class, add it to the defining LoadedPackage."

	^ self class registry_ImplementationClass addClassAssociation: assoc forClass: class toPackageNamed: packageName instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addClassAssociation: assoc forClass: class toPackageNamed: packageName implementationClass: implementationClass [

	"Copy the name association to the correct 
        SymbolDictionary in the live SymbolList.
        Create a LoadedClass for the new class, add it to the defining LoadedPackage."

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass addClassAssociation: assoc forClass: class toPackageNamed: packageName instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addExtensionCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName [

	^ self class registry_ImplementationClass addExtensionCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addExtensionCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName implementationClass: implementationClass [

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass addExtensionCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addExtensionSessionMethods: methDict catDict: catDict for: behavior toPackageNamed: packageName implementationClass: implementationClass [

	"expecting only a single method to be in methDict/catDict"

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass addExtensionSessionMethods: methDict catDict: catDict for: behavior toPackageNamed: packageName instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addNewClassVersionToAssociation: newClass oldClassVersion: oldClass [
	"a new class version is being added to the association in the receiver previously occupied by the original class"

	self class registry_ImplementationClass
		addNewClassVersionToAssociation: newClass
		oldClassVersion: oldClass
		instance: self
]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addNewClassVersionToAssociation: newClass oldClassVersion: oldClass implementationClass: implementationClass [
	"a new class version is being added to the association in the receiver previously occupied by the original class"

	"Use for calls from classes in Rowan-GemStone-Loader package"

	implementationClass
		addNewClassVersionToAssociation: newClass
		oldClassVersion: oldClass
		instance: self
]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addNewCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName [

	^ self class registry_ImplementationClass addNewCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addNewCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName implementationClass: implementationClass [

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass addNewCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addNewUnmanagedClassVersionToAssociation: newClass oldClassVersion: oldClass toPackageNamed: aPackageName implementationClass: implementationClass [
	"a new class version is being added to the association in the receiver previously occupied by the original class"

	"Use for calls from classes in Rowan-GemStone-Loader package"

	implementationClass
		addNewUnmanagedClassVersionToAssociation: newClass
		oldClassVersion: oldClass
		toPackageNamed: aPackageName
		instance: self
]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addRecompiledMethod: newCompiledMethod [

	"add a recompiled compiled method to behavior and update the loaded things"

	^ self class registry_ImplementationClass addRecompiledMethod: newCompiledMethod instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addRecompiledMethod: newCompiledMethod implementationClass: implementationClass [

	"add a recompiled compiled method to behavior and update the loaded things"

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass addRecompiledMethod: newCompiledMethod instance: self

]

{ #category : 'private' }
RwGsSymbolDictionaryRegistryV2 >> addRecompiledSessionMethodMethod: newCompiledMethod implementationClass: implementationClass [

	"add a recompiled session method compiled method to behavior and update the loaded things"

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass addRecompiledSessionMethodMethod: newCompiledMethod instance: self

]

{ #category : 'package - patch api' }
RwGsSymbolDictionaryRegistryV2 >> createLoadedPackageFromDefinition: packageDefinition implementationClass: implementationClass [

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass createLoadedPackageFromDefinition: packageDefinition instance: self

]

{ #category : 'class - patch api' }
RwGsSymbolDictionaryRegistryV2 >> deleteClassFromPackage: class [

	"a class association is being deleted from the receiver remove it from the loaded things"

	^ self class registry_ImplementationClass deleteClassFromPackage: class instance: self

]

{ #category : 'class - patch api' }
RwGsSymbolDictionaryRegistryV2 >> deleteClassNamedFromPackage: className implementationClass: implementationClass [

	"a class association is being deleted from the receiver remove it from the loaded things"

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass deleteClassNamedFromPackage: className instance: self

]

{ #category : 'method - patch api' }
RwGsSymbolDictionaryRegistryV2 >> deleteCompiledMethod: compiledMethod from: behavior [

	"delete a compiled method from behavior and remove it from the loaded things"

	^ self class registry_ImplementationClass deleteCompiledMethod: compiledMethod from: behavior instance: self

]

{ #category : 'method - patch api' }
RwGsSymbolDictionaryRegistryV2 >> deleteMethod: selector for: behavior implementationClass: implementationClass [

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass deleteMethod: selector for: behavior instance: self

]

{ #category : 'method - patch api' }
RwGsSymbolDictionaryRegistryV2 >> deletePackage: packageName [

	^  self class registry_ImplementationClass deletePackage: packageName instance: self

]

{ #category : 'class disown api' }
RwGsSymbolDictionaryRegistryV2 >> disownClass: class [

	"Remove the specified class and all of it's packaged instance and class methods from the loaded things."

	^ self class registry_ImplementationClass disownClass: class instance: self

]

{ #category : 'class disown api' }
RwGsSymbolDictionaryRegistryV2 >> disownClassExtensions: class forLoadedPackage: loadedPackage [

	"Remove the extension methods in the named class for the named package"

	^ self class registry_ImplementationClass disownClassExtensions: class forLoadedPackage: loadedPackage instance: self

]

{ #category : 'class - patch api' }
RwGsSymbolDictionaryRegistryV2 >> ensureExtensionClassNamed: className existsForPackageNamed: packageName implementationClass: implementationClass [

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass ensureExtensionClassNamed: className existsForPackageNamed: packageName instance: self

]

{ #category : 'loaded queries' }
RwGsSymbolDictionaryRegistryV2 >> existingForClass: aClass [

	"Answer the registered LoadedClass for the given class."

	^ self
		existingForClass: aClass
		ifAbsent: [ self error: 'no loaded class found for ' , aClass name printString ]
]

{ #category : 'loaded queries' }
RwGsSymbolDictionaryRegistryV2 >> existingForClass: aClass ifAbsent: absentBlock [

	"Answer the registered LoadedClass for the given class."

	^ self loadedClassForClass: aClass ifAbsent: absentBlock
]

{ #category : 'session methods' }
RwGsSymbolDictionaryRegistryV2 >> homeSessionMethods [

	| package |
	package := self _symbolDictionary at: GsPackage globalName otherwise: nil.
	package ifNil: [ package := GsPackage installIn: self _symbolDictionary ].
	^ package
]

{ #category : 'initialization' }
RwGsSymbolDictionaryRegistryV2 >> initialize [

	| symbolDictObjectSecurityPolicy |
	packageRegistry := KeyValueDictionary new.	"keyed by package name"
	methodRegistry := IdentityKeyValueDictionary new.	"keyed by compiledMethod"

	symbolDictObjectSecurityPolicy := symbolDictionary objectSecurityPolicy.
	packageRegistry objectSecurityPolicy: symbolDictObjectSecurityPolicy.
	methodRegistry objectSecurityPolicy: symbolDictObjectSecurityPolicy.

]

{ #category : 'class - registration' }
RwGsSymbolDictionaryRegistryV2 >> loadedClassExtensionsForClass: aClass [
	^ self class registry_ImplementationClass loadedClassExtensionsForClass: aClass
]

{ #category : 'class - registration' }
RwGsSymbolDictionaryRegistryV2 >> loadedClassExtensionsForClass: aClass ifAbsent: absentBlock [
	^ self class registry_ImplementationClass loadedClassExtensionsForClass: aClass ifAbsent: absentBlock
]

{ #category : 'class - registration' }
RwGsSymbolDictionaryRegistryV2 >> loadedClassForClass: aClass [
	^ self class registry_ImplementationClass loadedClassForClass: aClass
]

{ #category : 'class - registration' }
RwGsSymbolDictionaryRegistryV2 >> loadedClassForClass: aClass ifAbsent: absentBlock [
	^ self class registry_ImplementationClass loadedClassForClass: aClass ifAbsent: absentBlock
]

{ #category : 'loaded queries' }
RwGsSymbolDictionaryRegistryV2 >> loadedHybridPackageNamed: hybridPackageName ifAbsent: absentBlock [

	^ self class registry_ImplementationClass loadedHybridPackageNamed: hybridPackageName ifAbsent: absentBlock instance: self

]

{ #category : 'loaded queries' }
RwGsSymbolDictionaryRegistryV2 >> loadedPackageNamed: packageName ifAbsent: absentBlock [

	^ self class registry_ImplementationClass loadedPackageNamed: packageName ifAbsent: absentBlock instance: self

]

{ #category : 'accessing' }
RwGsSymbolDictionaryRegistryV2 >> methodRegistry [

   ^methodRegistry

]

{ #category : 'method - patch api' }
RwGsSymbolDictionaryRegistryV2 >> moveCompiledMethod: compiledMethod toProtocol: newProtocol [

	"move a compiled method into a different protocol and update loaded things"

	^ self class registry_ImplementationClass moveCompiledMethod: compiledMethod toProtocol: newProtocol instance: self

]

{ #category : 'method - patch api' }
RwGsSymbolDictionaryRegistryV2 >> moveCompiledMethod: compiledMethod toProtocol: newProtocol implementationClass: implementationClass [

	"move a compiled method into a different protocol and update loaded things"

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass moveCompiledMethod: compiledMethod toProtocol: newProtocol instance: self

]

{ #category : 'method - patch api' }
RwGsSymbolDictionaryRegistryV2 >> movePackage: packageName to: symbolDictionaryName classesWithNewVersions: classesWithNewVersions [
	^ self class registry_ImplementationClass
		movePackage: packageName
		to: symbolDictionaryName
		classesWithNewVersions: classesWithNewVersions
		instance: self
]

{ #category : 'package - patch api' }
RwGsSymbolDictionaryRegistryV2 >> movePackage: packageName toProjectNamed: projectName [
	^ self class registry_ImplementationClass
		movePackage: packageName
		toProjectNamed: projectName
		instance: self
]

{ #category : 'accessing' }
RwGsSymbolDictionaryRegistryV2 >> packageRegistry [

   ^packageRegistry

]

{ #category : 'class - registration' }
RwGsSymbolDictionaryRegistryV2 >> registerLoadedClass: loadedClass forClass: aClass [
	^ self class registry_ImplementationClass registerLoadedClass: loadedClass forClass: aClass
]

{ #category : 'class - registration' }
RwGsSymbolDictionaryRegistryV2 >> registerLoadedClassExtension: loadedClass forClass: aClass [
	^ self class registry_ImplementationClass registerLoadedClassExtension: loadedClass forClass: aClass
]

{ #category : 'class - registration' }
RwGsSymbolDictionaryRegistryV2 >> unregisterLoadedClass: loadedClass forClass: aClass [
	^ self class registry_ImplementationClass unregisterLoadedClass: loadedClass forClass: aClass
]

{ #category : 'class - registration' }
RwGsSymbolDictionaryRegistryV2 >> unregisterLoadedClassExtension: loadedClassExtension forClass: aClass [
	^ self class registry_ImplementationClass unregisterLoadedClassExtension: loadedClassExtension forClass: aClass
]

{ #category : 'class - patch api' }
RwGsSymbolDictionaryRegistryV2 >> updateClassProperties: class [

	"class properties have changed, update the clas properties of the loaded things"

	^ self class registry_ImplementationClass updateClassProperties: class instance: self

]

{ #category : 'class - patch api' }
RwGsSymbolDictionaryRegistryV2 >> updateClassProperties: class  implementationClass: implementationClass [

	"class properties have changed, update the clas properties of the loaded things"

	"Use for calls from classes in Rowan-GemStone-Loader package"

	^ implementationClass updateClassProperties: class instance: self

]
