"
SUnit tests for file handles, the tests may be found in superclass
"
Class {
	#name : 'FileHandleTest',
	#superclass : 'FileSystemHandleTest',
	#category : 'FileSystem-Tests-Disk-Base'
}

{ #category : 'running' }
FileHandleTest >> createFileSystem [
	"Force the filesystem to be created for each test.
	 Normally use: 'FileSystem disk' which returns the cached file system"
	^ FileSystem store: DiskStore activeClass createDefault
]

{ #category : 'running' }
FileHandleTest >> reopenForRead [
	handle close.
	handle := reference openOptions: FileOptions read.
	handle assureOpen
]

{ #category : 'tests' }
FileHandleTest >> testFileWriteError [
	" This test may be not needed depending on what happens with BinaryFileStream "
	| stream  |
	stream := FileSystem disk binaryWriteStreamOn: (FileSystem disk workingDirectory / 'foo.txt') path.
	stream close.
	self should: [stream  nextPutAll: 'abdef'] raise: FileWriteError
]

{ #category : 'tests' }
FileHandleTest >> testTruncate [
	| out |
	out := #(1 2 3 4 5) asByteArray.
	handle at: 1 write: out startingAt: 1 count: 5.
	self assert: handle size = 5.
	handle truncateTo: 3. "This actually sets the position."
	"When truncate is implemented in the file, this test will fail as the size should be 3"
	self assert: handle size = 5
]

{ #category : 'tests' }
FileHandleTest >> testWriteStream [
	| stream |
	stream := handle binaryStream.
	self assert: (stream isKindOf: BinaryFileStream).
	self assert: (stream respondsTo: #nextPut:)
]