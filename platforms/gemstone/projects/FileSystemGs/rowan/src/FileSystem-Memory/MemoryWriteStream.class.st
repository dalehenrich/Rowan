"
I am like a WriteStream but I have more capacities than it.
I am closer to a FileStream so I delegate some operations to my handle (collection instance variable)
"
Class {
	#name : 'MemoryWriteStream',
	#superclass : 'WriteStreamPortable',
	#category : 'FileSystem-Memory'
}

{ #category : 'testing' }
MemoryWriteStream >> isReadOnly [
	
	^ false
]

{ #category : 'accessing' }
MemoryWriteStream >> readOnlyCopy [
	
	^ collection readStreamPortable

]

{ #category : 'positioning' }
MemoryWriteStream >> truncate [
	collection truncate
]

{ #category : 'positioning' }
MemoryWriteStream >> truncate: anInteger [ 
	collection truncate: anInteger 
	
]
