Extension { #name : 'RwComponentProjectDefinition' }

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> defaultSymbolDictName [

	^ self projectRef defaultSymbolDictName
]

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> defaultSymbolDictName: symDictName [

	self projectRef defaultSymbolDictName: symDictName
]

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> defaultUseSessionMethodsForExtensions [

	^ self projectRef defaultUseSessionMethodsForExtensions
]

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> defaultUseSessionMethodsForExtensions: aBool [

	self projectRef defaultUseSessionMethodsForExtensions: aBool
]

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> methodEnvForPackageNamed: packageName [

	^self projectRef methodEnvForPackageNamed: packageName
]

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> packageNameToPlatformPropertiesMap [

	^self projectRef packageNameToPlatformPropertiesMap
]

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> packageNameToPlatformPropertiesMap: aDictionary [

	^self projectRef packageNameToPlatformPropertiesMap: aDictionary
]

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> register [

	Rowan image 
		loadedProjectNamed: self name
		ifAbsent: [
			| newLoadedProject |
			newLoadedProject := RwGsLoadedSymbolDictComponentProject newForProjectReferenceDefinition: self projectRef.
			Rowan image addLoadedProject: newLoadedProject ]
]

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> setSymbolDictName: symbolDictName forPackageNamed: packageName [

	^self projectRef setSymbolDictName: symbolDictName forPackageNamed: packageName
]

{ #category : '*rowan-gemstone-components-extensions' }
RwComponentProjectDefinition >> symbolDictNameForPackageNamed: packageName [

	^self projectRef symbolDictNameForPackageNamed: packageName
]