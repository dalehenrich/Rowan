Class {
	#name : 'RwResolvedRepositoryV2',
	#superclass : 'RwAbstractResolvedProjectV2',
	#category : 'Rowan-DefinitionsV2'
}

{ #category : 'repository' }
RwResolvedRepositoryV2 >> branches [
	^ self _projectRepository branches
]

{ #category : 'repository' }
RwResolvedRepositoryV2 >> checkout: aCommittish [
	^ self _projectRepository checkout: aCommittish
]

{ #category : 'repository' }
RwResolvedRepositoryV2 >> commitId [
	^ self _projectRepository commitId
]

{ #category : 'repository' }
RwResolvedRepositoryV2 >> createBranch: branchName [
	^ self _projectRepository createBranch: branchName
]

{ #category : 'repository' }
RwResolvedRepositoryV2 >> fetch [
	^ self _projectRepository fetch
]

{ #category : 'printing' }
RwResolvedRepositoryV2 >> printOn: aStream [
	super printOn: aStream.
	projectRepository
		ifNotNil: [ 
			aStream
				nextPutAll: ' for ';
				nextPutAll: self _projectRepository name ]
]

{ #category : 'repository' }
RwResolvedRepositoryV2 >> pull: remoteName branch: branchName [
	^ self _projectRepository pull: remoteName branch: branchName
]

{ #category : 'repository' }
RwResolvedRepositoryV2 >> push: remoteName branch: branchName [
	^ self _projectRepository push: remoteName branch: branchName
]

{ #category : 'repository' }
RwResolvedRepositoryV2 >> remote [
	^ self _projectRepository remote
]
