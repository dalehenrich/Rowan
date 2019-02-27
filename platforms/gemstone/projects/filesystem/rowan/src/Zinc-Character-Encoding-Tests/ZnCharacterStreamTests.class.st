Class {
	#name : 'ZnCharacterStreamTests',
	#superclass : 'TestCase',
	#category : 'Zinc-Character-Encoding-Tests'
}

{ #category : 'testing' }
ZnCharacterStreamTests >> assertUpToAll: array [
	| utf8Stream |
	utf8Stream := self utf8ReadStreamOn: array first.
	self assert: (array first readStream upToAll: array second) equals: array third.
	self assert: (utf8Stream upToAll: array second) equals: array third
]

{ #category : 'private' }
ZnCharacterStreamTests >> decodeBytes: bytes with: encoder [
	| input |
	input := bytes readStream.
	^ String streamContents: [ :stream |
		[ input atEnd ] whileFalse: [ 
			stream nextPut: (encoder nextFromStream: input) ] ]
]

{ #category : 'private' }
ZnCharacterStreamTests >> encodeString: string with: encoder [
	^ ByteArray streamContents: [ :stream |
		string do: [ :each |
			encoder nextPut: each toStream: stream ] ]
]

{ #category : 'testing' }
ZnCharacterStreamTests >> testNextLine [
	| stream |
	stream := ZnCharacterReadStream on: 'abc' asByteArray readStream.
	self assert: stream nextLine equals: 'abc'.
	self assert: stream nextLine  equals: nil.
	stream := ZnCharacterReadStream on: '' asByteArray readStream.
	self assert: stream nextLine equals: nil.
	stream := ZnCharacterReadStream on: ({ 
		$a. Character cr. 
		$b. Character lf. 
		$c } collect: [:ea | ea charCode]) readStream.
	self assert: stream nextLine equals: 'a'.
	self assert: stream nextLine equals: 'b'.
	self assert: stream nextLine equals: 'c'.
	self assert: stream nextLine equals: nil.
	stream := ZnCharacterReadStream on: ( { 
		$a. Character cr. Character lf.  
		$b. Character cr. Character lf. 
		$c. Character cr. Character lf }  collect: [:ea | ea charCode]) readStream.
	self assert: stream nextLine equals: 'a'.
	self assert: stream nextLine equals: 'b'.
	self assert: stream nextLine equals: 'c'.
	self assert: stream nextLine equals: nil.
	stream := ZnCharacterReadStream on: ({ 
		$a. Character cr. Character lf.  
		Character cr. Character lf. 
		$c. Character cr. Character lf }  collect: [:ea | ea charCode]) readStream.
	self assert: stream nextLine equals: 'a'.
	self assert: stream nextLine equals: ''.
	self assert: stream nextLine equals: 'c'.
	self assert: stream nextLine equals: nil.
]

{ #category : 'testing' }
ZnCharacterStreamTests >> testPeek [
	| string bytes readStream |
	string := 'élève en Français'.
	bytes := ZnUTF8Encoder new encodeString: string.
	readStream := ZnBufferedReadStream on: (ZnCharacterReadStream on: bytes readStreamPortable).
	self assert: readStream peek equals: 'é' first.
	self assert: readStream peek equals: 'é' first.
	self assert: readStream next equals: 'é' first.
	readStream skip: 'lève ' size.
	self assert: readStream peek equals: $e.
	self assert: (readStream next: 'en Français' size) equals: 'en Français'
]

{ #category : 'testing' }
ZnCharacterStreamTests >> testReadStream [
	| stream |
	stream := ZnBufferedReadStream on: (ZnCharacterReadStream on: 'ABC' asByteArray readStreamPortable).
	stream sizeBuffer: 3.
	self deny: stream atEnd.
	self deny: stream isBinary.
	self assert: stream next = $A.
	self deny: stream atEnd.
	self assert: stream peek = $B.
	self deny: stream atEnd.
	self assert: stream peek = $B.
	self deny: stream atEnd.
	self assert: stream next = $B.
	self deny: stream atEnd.
	self assert: stream next = $C.
	self assert: stream atEnd.
	self assert: stream next isNil.
	self assert: stream peek isNil
]

{ #category : 'testing' }
ZnCharacterStreamTests >> testSimpleUTF8ReadStream [
	| string bytes stream |
	string := 'élève en Français'.
	bytes := ZnUTF8Encoder new encodeString: string.
	stream := ZnBufferedReadStream on: (ZnCharacterReadStream on: bytes readStreamPortable).
	stream sizeBuffer: string size.
	self 
		assert:stream upToEnd
		equals: string
]

{ #category : 'testing' }
ZnCharacterStreamTests >> testSimpleUTF8WriteStream [
	| string bytes stream |
	string := 'élève en Français'.
	bytes := ZnUTF8Encoder new encodeString: string.
	stream := (ZnCharacterWriteStream on: ByteArray new writeStreamPortable).
	stream nextPutAll: string.
	self 
		assert: stream wrappedStream contents
		equals: bytes asByteArray
]

{ #category : 'testing' }
ZnCharacterStreamTests >> testUpToAll [
	true ifTrue: [ "upToAll: not supported for buffered streams ... skip test for now" ^ self ].
	#(
		('' '' '')
		('' 'ß' '')
		('' 'ße' '')
		('ß' '' '')
		('ße' '' '')
		('ß' 'ß' '')
		('ße' 'ß' '')
		('ß' 'ße' 'ß')
		('ß' 'e' 'ß')
		('ße' 'e' 'ß')
		('ßen' 'e' 'ß')
		('ßen' 'en' 'ß')
		('ßend' 'en' 'ß')
		('iße' 'e' 'iß')
		('ißen' 'e' 'iß')
		('ißen' 'en' 'iß')
		('ißend' 'en' 'iß')
		('iß' 'ß' 'i')
		('iße' 'ß' 'i')
		('eißen' 'ßend' 'eißen')
		('abcdefgh' 'cd' 'ab')
		('a' '' '')
		('a' 'a' '')
		('a' 'b' 'a')
		('ab' '' '')
		('ab' 'a' '')
		('ab' 'b' 'a')
		('ab' 'c' 'ab')
		('ab' 'ab' '')
		('abc' '' '')
		('abc' 'a' '')
		('abc' 'b' 'a')
		('abc' 'c' 'ab')
		('abc' 'd' 'abc')
		('abc' 'ab' '')
		('abc' 'bc' 'a')
		('abc' 'cd' 'abc')
	) do: [ :array | self assertUpToAll: array ]
]

{ #category : 'testing' }
ZnCharacterStreamTests >> testUpToAllTwice [
	| utf8Stream stream |
	true ifTrue: [ "upToAll: not supported for buffered streams ... skip test for now" ^ self ].
	utf8Stream := self utf8ReadStreamOn: 'eißendeße'.
	self assert: (utf8Stream upToAll: 'ße') equals: 'ei'.
	self assert: (utf8Stream upToAll: 'ße') equals: 'nde'.

	stream := 'eißendeße' readStreamPortable.
	self assert: (stream upToAll: 'ße') equals: 'ei'.
	self assert: (stream upToAll: 'ße') equals: 'nde'
]

{ #category : 'testing' }
ZnCharacterStreamTests >> testUTF8ReadStreamReadInto [
	| string bytes stream buffer |
	string := 'élève en Français'.
	bytes := ZnUTF8Encoder new encodeString: string.
	stream := ZnCharacterReadStream on: bytes readStream.
	buffer := String new: string size.
	stream next: string size into: buffer. 
	self assert: buffer equals: string.
	self assert: stream atEnd.
	string := 'Czech in Czech is {1}e{2}tina.' format: { 269 asCharacter. 353 asCharacter }.
	bytes := ZnUTF8Encoder new encodeString: string.
	stream := ZnCharacterReadStream on: bytes readStream.
	buffer := String new: string size.
	stream next: string size into: buffer. 
	self assert: buffer equals: string.
	self assert: stream atEnd
]

{ #category : 'private' }
ZnCharacterStreamTests >> utf8ReadStreamOn: string [
	| bytes stream |
	bytes := ZnUTF8Encoder new encodeString: string.
	stream := ZnBufferedReadStream on: (ZnCharacterReadStream
		on: bytes readStreamPortable
		encoding: #utf8).
	stream sizeBuffer: string size.
	^stream
]