"
This class audits individual classes
"
Class {
	#name : 'RwClsAuditTool',
	#superclass : 'RwClassTool',
	#category : 'Rowan-Tools-Core'
}

{ #category : 'audit' }
RwClsAuditTool >> _auditCategory: category forBehavior: aBehavior loadedClass: aLoadedClass [
	| packageConvention |
	packageConvention := aLoadedClass loadedProject packageConvention.

	^ packageConvention = 'RowanHybrid'
		ifTrue: [ 
			self
				_auditRowanHybridCategory: category
				forBehavior: aBehavior
				loadedClass: aLoadedClass ]
		ifFalse: [ 
			packageConvention = 'Rowan'
				ifTrue: [ 
					self
						_auditRowanCategory: category
						forBehavior: aBehavior
						loadedClass: aLoadedClass ]
				ifFalse: [ 
					self
						error:
							'package convention ' , packageConvention printString , ' not yet supported' ] ]
]

{ #category : 'audit' }
RwClsAuditTool >> _auditCategory: category selectors: aSelectorSet forBehavior: aBehavior loadedClass: aLoadedClass [
	| res |
	res := self _result.
	aSelectorSet
		do: [ :aSelector | 
			(self _auditSelector: aSelector forBehavior: aBehavior loadedClass: aLoadedClass)
				ifNotNil: [ :aRes | res addAll: aRes ] ].
	^ res
]

{ #category : 'audit' }
RwClsAuditTool >> _auditLoadedClassProperties: aLoadedClass forBehavior: aBehavior [
	"Check #( 'instvars', 'superclass', 'classinstvars',  'gs_SymbolDictionary', 'comment', 'classvars', 'pools', 'category')"

	| res aDict superclassName |
	res := self _result.
	superclassName := aBehavior superclass
		ifNil: [ 'nil' ]
		ifNotNil: [ :superCls | superCls name ].
	(aLoadedClass classSuperclass isEquivalent: superclassName)
		ifFalse: [ 
			res
				add:
					(RwAuditDetail
						for: aLoadedClass
						message: 'Superclass is different from loaded class') ].
	aLoadedClass classInstVarNames
		= (aBehavior instVarNames collect: [ :e | e asString ])
		ifFalse: [ 
			res
				add:
					(RwAuditDetail
						for: aLoadedClass
						message: 'instVarNames changed in compiled class v loaded class') ].
	aLoadedClass classClassVarNames
		=
			((aBehavior.classVars ifNil: [ SymbolDictionary new ]) keys
				collect: [ :e | e asString ]) asSortedCollection asArray
		ifFalse: [ 
			res
				add:
					(RwAuditDetail
						for: aLoadedClass
						message: 'ClassVars changed in compiled class v loaded class') ].
	aLoadedClass classPoolDictionaries
		=
			((aBehavior.poolDictionaries ifNil: [ Array new ]) collect: [ :e | e asString ])
		ifFalse: [ 
			res
				add:
					(RwAuditDetail
						for: aLoadedClass
						message: 'PoolDictionaries changed in compiled class v loaded class') ].
	(aLoadedClass classComment isEquivalent: aBehavior rwComment)
		ifFalse: [ 
			res
				add:
					(RwAuditDetail
						for: aLoadedClass
						message: 'Comment has changed in compiled class v loaded class') ].
	aLoadedClass classCategory = (aBehavior _classCategory ifNil: [ '' ])
		ifFalse: [ 
			res
				add:
					(RwAuditDetail
						for: aLoadedClass
						message: 'Class category has changed in compiled class v loaded class') ].
	(aDict := System myUserProfile
		resolveSymbol: aLoadedClass classSymbolDictionaryName asSymbol)
		ifNil: [ 
			res
				add:
					(RwAuditDetail
						for: aLoadedClass
						message:
							'Unable to find SymbolDictionary ' , aLoadedClass classSymbolDictionaryName) ]
		ifNotNil: [ :smbd | 
			smbd value
				at: aLoadedClass name asSymbol
				ifAbsent: [ 
					res
						add:
							aLoadedClass name
								-> 'Compiled class not found in symbol dictionary of loaded class' ] ].

	^ res
]

{ #category : 'audit' }
RwClsAuditTool >> _auditLoadedMethod: aLoadedMethod forBehavior: aClassOrMeta loadedClass: aLoadedClassOrExtension [
	"verify that compiled method is present for each loaded class method. return nil if no error"

	"we already check verifying selectors that compiled method matches loaded method"

	| res |
	res := self _result.
	(aClassOrMeta compiledMethodAt: aLoadedMethod name otherwise: nil)
		ifNil: [ 
			res
				add:
					(RwAuditDetail
						for: aLoadedClassOrExtension
						message: 'Missing compiled method>>' , aClassOrMeta printString, '>>', aLoadedMethod selector) ]
		ifNotNil: [ :aMethod | 
			aMethod == aLoadedMethod handle
				ifTrue: [ 
					| expected actual |
					((expected := aLoadedMethod methodCategory)
						equalsNoCase:
							(actual := aClassOrMeta categoryOfSelector: aMethod selector))
						ifFalse: [ 
							res
								add:
									(RwAuditDetail
										for: aClassOrMeta
										message:
											'Mismatched method category (expected: ' , expected printString , ' actual: '
												, actual printString , ')') ] ]
				ifFalse: [ 
					res
						add:
							(RwAuditDetail
								for: aLoadedClassOrExtension
								message:
									'Compiled method is not identical to loaded class method>>' , aLoadedMethod name) ] ].
	^ res
]

{ #category : 'audit' }
RwClsAuditTool >> _auditRowanCategory: category forBehavior: aBehavior loadedClass: aLoadedClass [
	| res |
	res := self _result.
	(aBehavior selectorsIn: category)
		do: [ :aSelector | 
			(aLoadedClass loadedMethodAt: aSelector isMeta: aBehavior isMeta)
				ifNil: [ 
					| foundExtensionClass |
					"should be an extension method"
					foundExtensionClass := false.
					(Rowan image loadedClassExtensionsForClass: aBehavior)
						do: [ :aLoadedClassExtension | 
							(aLoadedClassExtension loadedMethodAt: aSelector isMeta: aBehavior isMeta)
								ifNotNil: [ :aLoadedMethod | 
									res
										addAll:
											(self
												_auditLoadedMethod: aLoadedMethod
												forBehavior: aBehavior
												loadedClass: aLoadedClassExtension).
									foundExtensionClass := true ] ].
					foundExtensionClass
						ifFalse: [ 
							| notification |
							notification := (RwAuditMethodErrorNotification
								method: aSelector
								isMeta: aBehavior isMeta
								inClassNamed: aBehavior theNonMetaClass name
								isClassExtension: aLoadedClass isLoadedClassExtension
								intoPackageNamed: aLoadedClass packageName)
								description: 'Missing loaded method';
								yourself.
							notification signal
								ifTrue: [ 
									res
										add:
											(RwAuditDetail for: aBehavior message: 'Missing loaded method>>' , aSelector) ] ] ]
				ifNotNil: [ :aLoadedMethod | 
					res
						addAll:
							(self
								_auditLoadedMethod: aLoadedMethod
								forBehavior: aBehavior
								loadedClass: aLoadedClass) ] ].
	^ res
]

{ #category : 'audit' }
RwClsAuditTool >> _auditRowanHybridCategory: category forBehavior: aBehavior loadedClass: aLoadedClass [
	| aPackage res |
	"must be an extension. Do basic checks"
	aPackage := category copyFrom: 2 to: category size.
	res := self _result.
	(category notEmpty and: [ category first == $* ])
		ifTrue: [ 
			"must be an extension category. See if package exists"
			(aPackage asLowercase isEquivalent: aBehavior rowanPackageName asLowercase)
				ifTrue: [ 
					"aLoadedClass name , ' #' , category asString -> 'Extension category name can not be same as class package' "
					res
						add:
							(RwAuditDetail
								for: aLoadedClass
								message:
									'Extension category name <' , category , '>  must not match class package name.') ]
				ifFalse: [ 
					(Rowan image
						loadedClassExtensionsNamed: aBehavior thisClass name
						ifFound: [ :extensions | 
							extensions
								detect: [ :e | e loadedPackage name asLowercase isEquivalent: aPackage ]
								ifNone: [ nil ] ]
						ifAbsent: [ nil ]) isNil
						ifTrue: [ 
							res
								addAll:
									(self
										_auditCategory: category
										selectors: (aBehavior selectorsIn: category)
										forBehavior: aBehavior
										loadedClass: aLoadedClass) ]
						ifFalse: [ 
							res
								addAll:
									(self
										_auditCategory: category
										selectors: (aBehavior selectorsIn: category)
										forBehavior: aBehavior
										loadedClass: aLoadedClass) ] ] ]
		ifFalse: [ 
			aLoadedClass isLoadedClassExtension
				ifTrue: [ 
					res
						add:
							(RwAuditDetail
								for: aLoadedClass
								message:
									'Extension category name <' , category , '>  must begin with a `*`.') ].
			res
				addAll:
					(self
						_auditCategory: category
						selectors: (aBehavior selectorsIn: category)
						forBehavior: aBehavior
						loadedClass: aLoadedClass) ].
	^ res
]

{ #category : 'audit' }
RwClsAuditTool >> _auditSelector: aSelector forBehavior: aBehavior loadedClass: aLoadedClass [
	"#rentamed from _auidtClassSelector since functionality is same for instanance and class
 verify compiled method matches loaded method reference return nil if no problem found"

	| compiledMethod |
	compiledMethod := aBehavior compiledMethodAt: aSelector otherwise: nil.
	^ (Rowan image loadedMethodForMethod: compiledMethod ifAbsent: [  ])
		ifNil: [ 
			| notification |
			notification := (RwAuditMethodErrorNotification
				method: aSelector
				isMeta: aBehavior isMeta
				inClassNamed: aBehavior theNonMetaClass name
				isClassExtension: aLoadedClass isLoadedClassExtension
				intoPackageNamed: aLoadedClass loadedPackage name)
				description: 'Missing loaded method';
				yourself.
			notification signal
				ifTrue: [ 
					{(RwAuditDetail
						for: aBehavior
						message: 'Missing loaded method>>' , aSelector asString)} ]
				ifFalse: [ 
					"don't record audit error"
					{} ] ]
		ifNotNil: [ :loadedMethod | 
			self
				_auditLoadedMethod: loadedMethod
				forBehavior: aBehavior
				loadedClass: aLoadedClass ]
]

{ #category : 'audit' }
RwClsAuditTool >> _result [

	^Array new.

]

{ #category : 'audit' }
RwClsAuditTool >> auditLoadedClass: aLoadedClass [
	"look for methods compiled into class without Rowan API"

	| res aBehavior |
	res := self _result.
	(Rowan globalNamed: aLoadedClass name)
		ifNil: [ 
			"there is no matching Class for LoadedClass"
			res
				add:
					(RwAuditDetail
						for: aLoadedClass
						message: 'Missing gemstone class for loaded class ') ].
	aBehavior := aLoadedClass handle.
	res
		addAll:
			(self _auditLoadedClassProperties: aLoadedClass forBehavior: aBehavior).
	aBehavior
		categorysDo: [ :category :selectors | 
			res
				addAll:
					(self _auditCategory: category forBehavior: aBehavior loadedClass: aLoadedClass) ].
	aBehavior class
		categorysDo: [ :category :selectors | 
			res
				addAll:
					(self
						_auditCategory: category
						forBehavior: aBehavior class
						loadedClass: aLoadedClass) ].
	aLoadedClass
		loadedInstanceMethodsDo: [ :loadedProject :loadedPackage :loadedClass :aLoadedMethod | 
			(aBehavior compiledMethodAt: aLoadedMethod name otherwise: nil)
				ifNil: [ 
					res
						addAll:
							(self
								_auditLoadedMethod: aLoadedMethod
								forBehavior: aBehavior
								loadedClass: loadedClass) ] ]
		loadedClassMethodsDo: [ :loadedProject :loadedPackage :loadedClass :aLoadedMethod | 
			(aBehavior class compiledMethodAt: aLoadedMethod name otherwise: nil)
				ifNil: [ 
					res
						addAll:
							(self
								_auditLoadedMethod: aLoadedMethod
								forBehavior: aBehavior class
								loadedClass: loadedClass) ] ].
	^ res
]
