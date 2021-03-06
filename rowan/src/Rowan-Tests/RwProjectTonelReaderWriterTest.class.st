Class {
	#name : 'RwProjectTonelReaderWriterTest',
	#superclass : 'RwProjectFiletreeTonelReaderWriterTest',
	#category : 'Rowan-Tests'
}

{ #category : 'private' }
RwProjectTonelReaderWriterTest >> _classExtensionRemovedArtifactFileReference: repositoryRoot [

	^ repositoryRoot / 'rowan' / 'src' / 'Issue361-Extension1' / 'Issue361Class1.extension.st'
]

{ #category : 'private' }
RwProjectTonelReaderWriterTest >> _classMovedArtifactFileReference: repositoryRoot [

	^ repositoryRoot / 'rowan' / 'src' / 'Issue361-Core' / 'Issue361Class2.class.st'
]

{ #category : 'private' }
RwProjectTonelReaderWriterTest >> _classRemovedArtifactFileReference: repositoryRoot [

	^ repositoryRoot / 'rowan' / 'src' / 'Issue361-Core' / 'Issue361Class1.class.st'
]

{ #category : 'private' }
RwProjectTonelReaderWriterTest >> _packageRemovedArtifactFileReference: repositoryRoot [

	^ repositoryRoot / 'rowan' / 'src' / 'Issue361-Extension2'
]

{ #category : 'private' }
RwProjectTonelReaderWriterTest >> _repositoryFormat [

	^ 'tonel'
]
