Class {
	#name : 'RwAbstractRepositoryDefinition',
	#superclass : 'RwDefinition',
	#category : 'Rowan-Components'
}

{ #category : 'private' }
RwAbstractRepositoryDefinition class >> _instanceClass: defaultInstanceClass [
	"default class only needed when receiver is the abstract class"

	self == RwAbstractRepositoryDefinition
		ifTrue: [ ^ defaultInstanceClass ].
	^ self
]

{ #category : 'instance creation' }
RwAbstractRepositoryDefinition class >> newForSpecification: aRwSpecification projectHome: projectHomeFileReferenceOrString [

	^ self 
		newNamed: aRwSpecification specName 
		forSpecification: aRwSpecification 
		projectHome: projectHomeFileReferenceOrString
]

{ #category : 'instance creation' }
RwAbstractRepositoryDefinition class >> newNamed: repositoryName forSpecification: aRwSpecification projectHome: projectHomeFileReferenceOrString [

	| cls projectHomeFileReference |
	projectHomeFileReference := projectHomeFileReferenceOrString asFileReference.
	cls := (aRwSpecification useGit and: [ projectHomeFileReference fileSystem isDiskFileSystem ])
		ifTrue: [ RwGitRepositoryDefinition ]
		ifFalse: [  projectHomeFileReference fileSystem rowanRepositoryDefinitionClass ].
	^ (self _instanceClass: cls)
		newNamed: aRwSpecification specName 
			forSpecification: aRwSpecification 
			repositoryRoot: projectHomeFileReference / aRwSpecification specName
]

{ #category : 'instance creation' }
RwAbstractRepositoryDefinition class >> newNamed: repositoryName forSpecification: aRwSpecification repositoryRoot: repoRoot [

	^ self
		newNamed: repositoryName 
			repositoryRoot: repoRoot
			projectUrl: aRwSpecification projectUrl
			committish: aRwSpecification repoSpec committish 
			committishType: aRwSpecification repoSpec committishType
]

{ #category : 'instance creation' }
RwAbstractRepositoryDefinition class >> newNamed: repositoryName repositoryRoot: repoRoot [ 

	^ self new
		name: repositoryName;
		repositoryRoot: repoRoot;
		yourself
]

{ #category : 'instance creation' }
RwAbstractRepositoryDefinition class >> newNamed: repositoryName repositoryRoot: repoRoot projectUrl: anUrlString [

	^ self new
		name: repositoryName;
		repositoryRoot: repoRoot;
		projectUrl: anUrlString;
		yourself
]

{ #category : 'instance creation' }
RwAbstractRepositoryDefinition class >> newNamed: repositoryName repositoryRoot: repoRoot projectUrl: anUrlString committish: committish committishType: committishType [

	^ self new
		name: repositoryName;
		repositoryRoot: repoRoot;
		projectUrl: anUrlString;
		committish: committish committishType: committishType;
		yourself
]

{ #category : 'private' }
RwAbstractRepositoryDefinition >> _fileSystem [

	self subclassResponsibility: #_fileSystem
]

{ #category : 'actions' }
RwAbstractRepositoryDefinition >> attach [

	self error: 'not yet implemented'
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> committish [

	^ self properties at: 'committish' ifAbsent: []
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> committish: aString committishType: committishTypeString [

	self properties at: 'committish' put: aString.
	self properties at: 'committishType' put: committishTypeString.
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> committishType [

	^ self properties at: 'committishType' ifAbsent: []
]

{ #category : 'actions' }
RwAbstractRepositoryDefinition >> create [

	self error: 'not yet implemented'
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> key [

	^properties at: 'name' ifAbsent: [nil]
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> name [

	^ self key
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> name: aString [ 

	properties at: 'name' put: aString
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> projectUrl [

	^ self properties at: 'projectUrl' ifAbsent: [ '' ]
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> projectUrl: anUrlString [

	anUrlString ifNil: [ ^ self properties removeKey: 'projectUrl' ifAbsent: [ ] ].
	self properties at: 'projectUrl' put: anUrlString
]

{ #category : 'testing' }
RwAbstractRepositoryDefinition >> repositoryExists [

	^ self repositoryRoot exists
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> repositoryRoot [

	^ self properties at: 'repositoryRoot'
]

{ #category : 'accessing' }
RwAbstractRepositoryDefinition >> repositoryRoot: pathStringOrReference [

	| fileRef |
	fileRef := pathStringOrReference asFileReference.
	self projectUrl: nil.
	self properties at: 'repositoryRoot' put: fileRef
]

{ #category : 'actions' }
RwAbstractRepositoryDefinition >> resolve [

	"attach to existing repository structure or create"

	self subclassResponsibility: #resolve
]