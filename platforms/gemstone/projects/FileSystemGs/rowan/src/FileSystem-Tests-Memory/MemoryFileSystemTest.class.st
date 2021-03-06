"
SUnit tests for MemoryFileSystem
"
Class {
	#name : 'MemoryFileSystemTest',
	#superclass : 'FileSystemTest',
	#category : 'FileSystem-Tests-Memory'
}

{ #category : 'initialize-release' }
MemoryFileSystemTest >> createFileSystem [
	^ FileSystem memory
]

{ #category : 'tests' }
MemoryFileSystemTest >> lastModificationTimeOf: fileReference [
	"DateAndTime primUTCMicrosecondsClock is not precise across all OS so put in slight delay between calling modificationTime"

	^ [ fileReference modificationTime ]
		ensure: [ (Delay forMilliseconds: 100) wait ]
]

{ #category : 'tests' }
MemoryFileSystemTest >> testCurrentEqual [
	| other another |
	another := FileSystem currentMemoryFileSystem.
	other := FileSystem currentMemoryFileSystem.
	self assert: other equals: another
]

{ #category : 'tests' }
MemoryFileSystemTest >> testIsMemoryFileSystem [
	self assert: filesystem isMemoryFileSystem.
	
]

{ #category : 'tests' }
MemoryFileSystemTest >> testModifiedTimeWhenFileCreated [
	self assert: (filesystem / 'file.txt') ensureCreateFile modificationTime notNil
]

{ #category : 'tests' }
MemoryFileSystemTest >> testModifiedTimeWhenFileModifiedByWriteStream [
	| modifiedTime fileReference |
	fileReference := (filesystem / 'file.txt') ensureCreateFile.
	modifiedTime := self lastModificationTimeOf: fileReference.
	fileReference writeStreamDo: [ :aStream | aStream nextPutAll: 'data' ].
	self assert: modifiedTime notNil.
	self deny: modifiedTime equals: fileReference modificationTime
]

{ #category : 'tests' }
MemoryFileSystemTest >> testModifiedTimeWhenFileModifiedWithBinaryWriteStream [
	| modifiedTime fileReference data |
	fileReference := (filesystem / 'file.txt') ensureCreateFile.
	modifiedTime := self lastModificationTimeOf: fileReference.
	data := 'some data'.
	fileReference binaryWriteStreamDo: [ :aStream | aStream nextPutAll: data ].
	self assert: modifiedTime notNil.
	self deny: modifiedTime equals: fileReference modificationTime.
	self
		assert: data asByteArray
		equals: (fileReference binaryReadStreamDo: [ :aStream | aStream upToEnd ]).
	self assert: data equals: (fileReference readStreamDo: [ :aStream | aStream contents ])
]

{ #category : 'tests' }
MemoryFileSystemTest >> testModifiedTimeWhenFileWrittenTo [
	| modifiedTime fileReference |
	fileReference := (filesystem / 'file.txt') ensureCreateFile.
	modifiedTime := self lastModificationTimeOf: fileReference.
	fileReference binaryWriteStreamDo: [ :aStream | aStream nextPutAll: 'data' ].
	self assert: modifiedTime notNil.
	self deny: modifiedTime equals: fileReference modificationTime
]

{ #category : 'tests' }
MemoryFileSystemTest >> testModifiedTimeWhenHandleTruncated [
	| modifiedTime fileReference handle |
	fileReference := (filesystem / 'file.txt') ensureCreateFile.
	handle := fileReference openWritable: true.
	modifiedTime := self lastModificationTimeOf: fileReference.
	handle truncate.
	self assert: modifiedTime notNil.
	self deny: modifiedTime equals: fileReference modificationTime
]

{ #category : 'tests' }
MemoryFileSystemTest >> testNotEqualWhenCreatingNewMemoryFileSystem [
	| other |
	other := FileSystem memory.
	self deny: other equals: filesystem
]

{ #category : 'tests' }
MemoryFileSystemTest >> testNotEqualWhenRequestingMemoryFileSystem [
	| other |
	other := self createFileSystem.
	self deny: other equals: filesystem
]
