Class {
	#name : 'RwProjectDefinitionV2',
	#superclass : 'RwAbstractProjectDefinitionV2',
	#category : 'Rowan-Components'
}

{ #category : 'instance creation' }
RwProjectDefinitionV2 class >> fromLoadSpecification: aRwProjectLoadSpecificationV2 [
	| projectReferenceDefintion |
	projectReferenceDefintion := RwProjectReferenceDefinitionV2
		fromLoadSpecification: aRwProjectLoadSpecificationV2.
	^ self basicNew
		properties:
				(Dictionary new
						add: 'name' -> aRwProjectLoadSpecificationV2 projectName;
						add: 'projectRef' -> projectReferenceDefintion;
						yourself);
		packages: Dictionary new;
		projectDefinitionSourceProperty: RwLoadedProject _projectSourceValueNewProject;
		yourself
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> _deleteTool [

	^ Rowan projectTools delete
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> _loadTool [

	^ Rowan projectTools loadV2
]

{ #category : 'visiting' }
RwProjectDefinitionV2 >> acceptVisitor: aVisitor [

	^ aVisitor visitComponentProjectDefinition: self
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> addComponentNamed: aComponentName comment: commentString [

	| component |
	component := self 
		components at: aComponentName 
		ifAbsentPut: [ RwProjectLoadComponentV2 newNamed: aComponentName for: self projectName ].
	^ component 
		addDefinedGroupName: self defaultGroupName includeGroups: #();
		comment: commentString;
		yourself
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> addComponentNamed: aComponentName definedGroupNames: groupNameDict comment: commentString [
	| component |
	component := self components
		at: aComponentName
		ifAbsentPut: [ RwProjectLoadComponentV2 newNamed: aComponentName for: self projectName ].
	groupNameDict
		keysAndValuesDo: [ :groupName :includeGroups | component defineGroupNamed: groupName toIncludeGroups: includeGroups ].
	component comment: commentString.
	^ component
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> addPackageNamed: packageName [

	self shouldNotImplement
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> addPackageNamed: packageName toComponentNamed: componentName withConditions: conditionArray andGroupName: groupName [
	| package component |
	self
		componentNamed: componentName
		ifAbsent: [ self error: 'The component ' , componentName printString , ' is undefined' ].
	package := RwPackageDefinition newNamed: packageName.
	self _addPackage: package.
	component := self components
		at: componentName
		ifAbsentPut: [ RwProjectLoadComponentV2 newNamed: componentName for: self name ].
	component
		conditionalPackagesAtConditions: conditionArray
		andGroup: groupName
		addPackageNames: {packageName}.
	^ package
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> addPackageNamed: packageName toComponentNamed: componentName withConditions: conditionArray andGroupName: groupName gemstoneDefaultSymbolDictionaryForUser: aSymbolDictAssoc [
	| package component |
	self
		componentNamed: componentName
		ifAbsent: [ self error: 'The component ' , componentName printString , ' is undefined' ].
	package := RwPackageDefinition newNamed: packageName.
	self _addPackage: package.
	component := self components
		at: componentName
		ifAbsentPut: [ RwProjectLoadComponentV2 newNamed: componentName for: self name ].
	component
		conditionalPackageMapSpecsAtGemStoneUserId: aSymbolDictAssoc key
			andPackageName: packageName
			setSymbolDictNameTo: aSymbolDictAssoc value;
		conditionalPackagesAtConditions: conditionArray
			andGroup: groupName
			addPackageNames: {packageName}.
	^ package
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> addPackages: somePackageNames forComponent: aComponent [
	"not sure I like how this is used ... the component structure needs to be kept in sync with packages, so this is not quite the route to go, unless we ensure that the component has an entry for the package"

	"see similar comment in addRawPackageNamed:"

	"should be sent from the component visitor ... not unexpected to have a duplicate, but the new
		component --- presumably freshly read from disk --- wins"

	| componentName |
	componentName := aComponent name.
	(self components at: componentName ifAbsent: [  ])
		ifNil: [ self components at: componentName put: aComponent ]
		ifNotNil: [ :theComponent | 
			theComponent ~~ aComponent
				ifTrue: [ 
					"newest component wins"
					self components at: componentName put: aComponent ] ].
	somePackageNames asSet
		do: [ :packageName | self _addPackage: (RwPackageDefinition newNamed: packageName) ]
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> addPackagesNamed: packageNames toComponentNamed: componentName withConditions: conditionArray andGroupName: groupName [


	^ packageNames collect: [:packageName | 
		self addPackageNamed: packageName toComponentNamed: componentName withConditions: conditionArray andGroupName: groupName ]
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> addPackagesNamed: packageNames toComponentNamed: componentName withConditions: conditionArray andGroupName: groupName  gemstoneDefaultSymbolDictionaryForUser: aSymbolDictAssoc [

	^ packageNames collect: [:packageName | 
		self addPackageNamed: packageName toComponentNamed: componentName withConditions: conditionArray andGroupName: groupName  gemstoneDefaultSymbolDictionaryForUser: aSymbolDictAssoc ]
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> addRawPackageNamed: packageName [
	"not sure I like how this is used ... the component structure needs to be kept in sync with packages, so this is not quite the route to go, unless we ensure that the component has an entry for the package"

	"see similar comment in addPackages:forComponent:"

	^ self _addPackage: (RwPackageDefinition newNamed: packageName)
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> clone [
	"clone remote git project to disk"

	self cloneRepository.
	^ self read						"refresh receiver from the cloned repository and answer project definition set that contains reciever along with any dependent projects"
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> cloneRepository [
	"clone remote git project to disk"

	self projectRef clone
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> componentsPath [

	^ self projectRef componentsPath
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> componentsPath: aDirectoryPathString [

	^ self projectRef componentsPath: aDirectoryPathString
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> componentsRoot [
	^ self projectRef componentsRoot
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> create [
	"write the project structure to disk, if it doesn't already exist"

	Rowan projectTools create
		createComponentProject: self.
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> export [

	Rowan projectTools writeV2 writeProjectDefinition: self
]

{ #category : 'exporting' }
RwProjectDefinitionV2 >> exportComponents [

	self components isEmpty ifTrue: [
		self addComponentNamed: self defaultComponentName comment: '' ].
	self components values do: [:component|
		component exportToUrl: 'file:',  self componentsRoot pathString, '/' ].
	self components isEmpty
		ifTrue: [
			"add README.md as placeholder to ensure that the directory is preserved by git"
			(self componentsRoot /  'README', 'md') writeStreamDo: [ :fileStream | ] ]
]

{ #category : 'exporting' }
RwProjectDefinitionV2 >> exportPackages: diskProjectSetDefinition packagesRoot: packagesRoot packageFormat: packageFormat packageConvention: packageConvention [
	| projectSetDefinition visitor projectSetModification writerVisitorClass |
	packagesRoot / 'properties' , 'st'
		writeStreamDo: [ :fileStream | 
			fileStream
				nextPutAll: '{ ';
				lf;
				tab;
				nextPutAll: '#format : ' , packageFormat printString , ',';
				lf;
				tab;
				nextPutAll: '#convention : ' , packageConvention printString;
				lf;
				nextPutAll: '}';
				lf ].	"write out packages"
	writerVisitorClass := packageFormat = 'tonel'
		ifTrue: [ RwModificationTonelWriterVisitorV2 ]
		ifFalse: [ RwModificationFiletreeWriterVisitorV2 ].
	projectSetDefinition := RwProjectSetDefinition new.
	projectSetDefinition addDefinition: self.
	projectSetModification := projectSetDefinition
		compareAgainstBase: diskProjectSetDefinition.
	visitor := writerVisitorClass new
		packagesRoot: packagesRoot;
		yourself.

	visitor visit: projectSetModification
]

{ #category : 'exporting' }
RwProjectDefinitionV2 >> exportPackagesTo: packagesRoot packageFormat: packageFormat packageConvention: packageConvention [
	"attempt to do incremental write to disk, however, if disk cannot be read, write all packages to disk"

	| projectSetDefinition |
	projectSetDefinition := [ (self class newForProjectReference: self projectRef) readProjectSet ]
		on: Error
		do: [ :ignored | RwProjectSetDefinition new ].
	self
		exportPackages: projectSetDefinition
		packagesRoot: packagesRoot
		packageFormat: packageFormat
		packageConvention: packageConvention
]

{ #category : 'exporting' }
RwProjectDefinitionV2 >> exportProjects [

	self projectNames do: [:projectName |
		self error: 'not yet implemented' ].
	self projectNames isEmpty
		ifTrue: [
			"add README.md as placeholder to ensure that the directory is preserved by git"
			(self projectsRoot /  'README', 'md') writeStreamDo: [ :fileStream | ] ]
]

{ #category : 'exporting' }
RwProjectDefinitionV2 >> exportSpecification [

	self projectRef exportSpecification
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> gitRoot: aGitRootReferenceOrString [ 

	^ self projectRef gitRoot: aGitRootReferenceOrString
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> key [
	"Answer an object that can be used to uniquely identify myself in the context of my container."

	^self projectName
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> load [
	"load the receiver into the image"

	^ self _loadTool loadProjectDefinition: self
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> load: instanceMigrator [
	"load the receiver into the image"

	^ self _loadTool loadProjectDefinition: self instanceMigrator: instanceMigrator
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> loadedCommitId [

	^ self projectRef loadedCommitId
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> packageConvention [

	^ self projectRef packageConvention
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> packageConvention: aString [

	self projectRef packageConvention: aString
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> packageFormat [

	^ self projectRef packageFormat
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> packageFormat: aString [

	self projectRef packageFormat: aString
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> packageFormatIfAbsent: aBlock [

	^ self projectRef packageFormatIfAbsent: aBlock
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> packageNameToPlatformPropertiesMap: aDictionary [

	^self projectRef packageNameToPlatformPropertiesMap: aDictionary
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> packagesPath [

	^ self projectRef packagesPath
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> packagesPath: aString [

	^ self projectRef packagesPath: aString
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> packagesRoot [

	^ self projectRef packagesRoot
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> projectAlias [
	^ self projectRef projectAlias
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectAlias: aStringOrNil [
	"project alias is used as the name of the root directory for the project ... necessary if the project is 
		embedded in another project's git repository or you want use a non-default directory on disk"

	self projectRef projectAlias: aStringOrNil
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectHome [

	^ self projectRef projectHome
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectHome: aProjectHomeReferenceOrString [

	^ self projectRef projectHome: aProjectHomeReferenceOrString
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectLoadSpecification [
	^ self projectRef projectLoadSpecification
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> projectName [
	^ self propertyAt: 'name'
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> projectName: aString [
	self propertyAt: 'name' put: aString
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectNames [

	^ self projectRef projectNames
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectNames: anArray [

	self projectRef projectNames: anArray
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectRef [

	^ self propertyAt: 'projectRef' ifAbsent: [ ]
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectRef: aRwProjectReferenceDefinition [

	^ self propertyAt: 'projectRef' put: aRwProjectReferenceDefinition
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> projectsPath [

	^ self projectRef projectsPath
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> projectsPath: aString [

	^ self projectRef projectsPath: aString
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectSpecification [
	^ self projectRef projectSpecification
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> projectSpecification: aProjectSpecification [
	^ self projectRef projectSpecification: aProjectSpecification
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> projectsRoot [

	^ self projectRef projectsRoot
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> projectUrl [

	^ self projectRef projectUrl
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> read: platformConfigurationAttributes [
	"refresh the contents of the receiver ... the reciever will match the definitions on disk based on the default component and group names"

	"return a project definition set that will contain the project definition along with any dependent project definitions"

	^ Rowan projectTools read
		readProjectSetForComponentProjectDefinition: self 
			withConfigurations: self defaultConfigurationNames
			groupNames: self defaultGroupNames
			platformConfigurationAttributes: platformConfigurationAttributes
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> readPackageNames: packageNames [

	"drop all existing packages on the floor and replace with fresh versions of the packageNames read from disk"

	| format visitorClass |
	packages := Dictionary new. 
	format := self 
		packageFormatIfAbsent: [  
			| formatFromDisk |
			formatFromDisk := (RwAbstractReaderWriterVisitor _repositoryPropertyDictFor: self packagesRoot)
				at: #format ifAbsent: [ 'tonel' ].
			self packageFormat: formatFromDisk.
			formatFromDisk ].
	visitorClass := format = 'tonel'
		ifTrue: [ RwRepositoryComponentProjectTonelReaderVisitor ]
		ifFalse: [ RwRepositoryComponentProjectFiletreeReaderVisitor ].
	^ visitorClass new
		packageNames: packageNames;
		visit: self.
]

{ #category : 'tool api' }
RwProjectDefinitionV2 >> readProjectSet [

	^ Rowan projectTools read  readProjectSetForComponentProjectDefinition: self
]

{ #category : 'actions' }
RwProjectDefinitionV2 >> readProjectSetForPackageNames: packageNames [

	"drop all existing packages on the floor and replace with fresh versions of the packageNames read from disk"

	| format visitorClass |
	packages := Dictionary new. 
	format := self 
		packageFormatIfAbsent: [  
			| formatFromDisk |
			formatFromDisk := (RwAbstractReaderWriterVisitor _repositoryPropertyDictFor: self packagesRoot)
				at: #format ifAbsent: [ 'tonel' ].
			self packageFormat: formatFromDisk.
			formatFromDisk ].
	visitorClass := format = 'tonel'
		ifTrue: [ RwRepositoryComponentProjectTonelReaderVisitor ]
		ifFalse: [ RwRepositoryComponentProjectFiletreeReaderVisitor ].
	^ visitorClass new
		packageNames: packageNames;
		visit: self.
]

{ #category : 'reading' }
RwProjectDefinitionV2 >> readProjectSetReadTool: readTool withConfigurations: theConfigNames groupNames: theGroupNames [

	^ readTool
		readProjectSetForComponentProjectDefinition: self
			withConfigurations: theConfigNames 
			groupNames: theGroupNames
]

{ #category : 'accessing' }
RwProjectDefinitionV2 >> removePackage: aPackageDefinition [

	super removePackage: aPackageDefinition
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> repositoryRoot [
	"Root directory of the project. The configsPath, repoPath, specsPath, and projectsPath are specified relative to the repository root."

	^ self projectRef repositoryRoot
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> repositoryRoot: aFileReferenceOrPath [
	"Root directory of the project. The configsPath, repoPath, specsPath, and projectsPath are specified relative to the repository root."

	^ self projectRef repositoryRoot: aFileReferenceOrPath
]

{ #category : 'temporary compat' }
RwProjectDefinitionV2 >> repositoryRootPath [

	^ self repositoryRoot fullName
]

{ #category : 'temporary compat' }
RwProjectDefinitionV2 >> specification [

self deprecated: 'temporary patch .. sender should be replaced with projectRef'.
	^ self projectRef asSpecification
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> specsPath [

	^ self projectRef specsPath
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> specsPath: aDirectoryPathString [

	self projectRef specsPath: aDirectoryPathString
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> specsRoot [

	^ self projectRef specsRoot
]

{ #category : 'loading' }
RwProjectDefinitionV2 >> updateLoadedCommitId [

	self projectRef updateLoadedCommitId
]

{ #category : 'properties' }
RwProjectDefinitionV2 >> useGit [

	^ self projectRef useGit
]