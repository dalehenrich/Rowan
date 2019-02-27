Class {
	#name : 'ZnCharacterEncoderTests',
	#superclass : 'TestCase',
	#category : 'Zinc-Character-Encoding-Tests'
}

{ #category : 'accessing' }
ZnCharacterEncoderTests class >> asciiCharacterSource [
	^ ($A to: $Z), ($a to: $z), ($0 to: $9), '.-_/*+=|,;?!$&<>^%#', '    '
]

{ #category : 'accessing' }
ZnCharacterEncoderTests class >> latin1CharacterSource [
	^ ($A to: $Z), ($a to: $z), ($0 to: $9), '.-_/*+=|,;?!$&<>^%#', '       ', 'éèçüäßñ'
]

{ #category : 'accessing' }
ZnCharacterEncoderTests class >> stringOfSize: size fromSource: source [
	"self stringOfSize: 1024 fromSource: self unicodeCharacterSource"
	
	^ String new: size streamContents: [ :out | 
		size timesRepeat: [ out nextPut: source atRandom ] ]
]

{ #category : 'accessing' }
ZnCharacterEncoderTests class >> unicodeCharacterSource [
	^ ($A to: $Z), ($a to: $z), ($0 to: $9), '.-_/*+=|,;?!$&<>^%#', '         ', 'éèçüäßñα', '€∏'
]

{ #category : 'public' }
ZnCharacterEncoderTests >> assertCharacterCollection: anObject equals: otherObj [
	"allow comparison between unitcode and legacy strings in legacy mode"

	self
		assert: (anObject isEquivalent: otherObj)
		description: anObject printString , ' is not equal to ' , otherObj printString.
]

{ #category : 'private' }
ZnCharacterEncoderTests >> decodeBytes: bytes with: encoder [

	"GemStone does not support streamed decoding ... hack for tests"
	"^ bytes decodeFromUTF8"

	"Uncomment the following code for decoding"

	| input |
	input := bytes readStream.
	^ String streamContents: [ :stream |
		[ input atEnd ] whileFalse: [ 
			stream nextPut: (encoder nextFromStream: input) ] ]
]

{ #category : 'private' }
ZnCharacterEncoderTests >> encodeString: string with: encoder [
"
	^ ByteArray streamContents: [ :stream |
		stream nextPutAll: string encodeAsUTF8 ]
"

	^ ByteArray streamContents: [ :stream |
		string do: [ :each |
			encoder nextPut: each toStream: stream ] ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testAllByteEncoderDomains [
	| encoder characterDomain byteDomain encoded |
	ZnByteEncoder knownEncodingIdentifiers do: [ :identifier |
		encoder := ZnCharacterEncoder newForEncoding: identifier.
		self assert: encoder identifier equals: identifier.
		self assert: encoder isStrict.
		self assert: encoder isLenient not.
		self assert: (encoder encodeString: 'hello') equals: #[104 101 108 108 111] .
		self assert: (encoder decodeBytes: #[104 101 108 108 111] ) equals: 'hello'.
		characterDomain := encoder characterDomain.
		byteDomain := encoder byteDomain.
		characterDomain do: [ :each |
			self assert: (encoder encodedByteCountFor: each) equals: 1.
			encoded := ByteArray streamContents: [ :out | encoder nextPut: each toStream: out ].
			self assert: encoded size equals: 1.
			self assert: (byteDomain includes: encoded first) ].
		byteDomain do: [ :each |
			self assert: (characterDomain includes: (encoder nextFromStream: (ByteArray with: each) readStream)) ] ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testBeLenient [
	| encoder unmapped |
	encoder := ZnCharacterEncoder newForEncoding: 'iso-8859-1'.
	unmapped := (128 to: 159) asByteArray.
	self should: [ encoder encodeString: unmapped asString ] raise: ZnCharacterEncodingError.
	self should: [ encoder decodeBytes: unmapped ] raise: ZnCharacterEncodingError.
	encoder beLenient.
	self assert: (encoder encodeString: unmapped asString) equals: unmapped.
	self assert: (encoder decodeBytes: unmapped) equals: unmapped asString.
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testByteDecoding [
	| encoder bytes |
	encoder := ZnUTF8Encoder new.
	bytes := encoder encodeString: 'élève en Français'.
	self assert: (bytes decodeWith: encoder) equals: (encoder decodeBytes: bytes).
	self assert: (bytes decodeWith: #utf8) equals: (encoder decodeBytes: bytes).
	self assert: bytes utf8Decoded equals: (encoder decodeBytes: bytes)
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testCodePointEncodingDecoding [
"	| encoder input output |
	input := {}.
	'Düsseldorf Königsallee' do: [:each | input add: each codePoint ].
	self assert: input isCollection.
	self assert: (input allSatisfy: [:each | each _isInteger ]).
	#(utf8 ) do: [ :each |
		encoder := each asZnCharacterEncoder.
		output := encoder encodeCodePoints: input.
		self assert: output isCollection.
		self assert: (output allSatisfy: [ :e | e _isInteger and: [ e between: 0 and: 255 ] ] ).
		self assert: (encoder encodedByteCountForCodePoints: input) equals: output size.
		self assert: (encoder decodeAsCodePoints: output) equals: input ]"

	| encoder input output |
	input := 'Düsseldorf Königsallee' asByteArray asArray.
	self assert: input isCollection.
	self assert: (input allSatisfy: [:ea | ea _isInteger]).
	#(utf8 "utf16 utf32 latin1 null") do: [ :each |
		encoder := each asZnCharacterEncoder.
		output := encoder encodeCodePoints: input.
		self assert: output isCollection.
		self assert: (output allSatisfy: [ :e | e _isInteger and: [ e between: 0 and: 255 ] ] ).
		self assert: (encoder encodedByteCountForCodePoints: input) equals: output size.
		self assert: (encoder decodeAsCodePoints: output) equals: input ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testCodePointStreams [
	| string codePoints bytes result result2 |
	string := 'Düsseldorf Königsallee'.
	codePoints := string asByteArray asArray.
	self assert: codePoints isCollection.
	self assert: (codePoints allSatisfy: [:ea | ea isKindOf: Integer]).
	#(utf8 "utf16 utf32 latin1 null") do: [ :each |
		bytes := ByteArray streamContents: [ :out |
			(ZnCodePointWriteStream on: out encoding: each)
				nextPutAll: codePoints ].
		result2 := each asZnCharacterEncoder encodeString: string.
		self assert: bytes equals: result2.
		result := (ZnCodePointReadStream on: bytes readStream encoding: each) upToEnd.
		self assert: result equals: codePoints.
		self assert: (codePoints collect: [:ea | ea asCharacter] as: String) equals: string ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testConvencienceMethods [
	| encoder string |
	encoder := ZnUTF8Encoder new.
	string := 'élève en Français'.
	self assertCharacterCollection: (encoder decodeBytes: (encoder encodeString: string)) equals: string.
	self assert: (encoder encodedByteCountForString: string) = 20.
	
	#( 'ccc' 'ççç' 'c' 'ç' 'çc' 'cç' ) do: [ :each |
		self assertCharacterCollection: (encoder decodeBytes: (encoder encodeString: each)) equals: each ]

"	| encoder string |
	encoder := ZnUTF8Encoder new.
	string := 'élève en Français'. 
	self assert: (encoder decodeBytes: (encoder encodeString: string)) equals: string.
	self assert: (encoder encodedByteCountForString: string) = 20.
	
	#( 'ccc' 'ççç' 'c' 'ç' 'çc' 'cç' ) do: [ :each |
		self assert: (encoder decodeBytes: (encoder encodeString: each)) equals: each ]"
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testDefault [
	| string bytes |  
	self assert: ZnCharacterEncoder default equals: ZnUTF8Encoder default.
	string := 'Der Weg zur Hölle ist mit guten Vorsätzen gepflastert.'.
	bytes := ZnUTF8Encoder new encodeString: string.
	ZnDefaultCharacterEncoder 
		value: ZnUTF8Encoder new
		during: [ 
			self 
				assertString: (ZnCharacterEncoder default decodeBytes: bytes) 
				equalsString: string ].
	ZnDefaultCharacterEncoder 
		value: ZnUTF8Encoder new
		during: [ 
			self 
				assertString: ((ZnCharacterEncoder newForEncoding: 'unknown') decodeBytes: bytes) 
				equalsString: string ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testDetectEncoding [
	| bytes |
	bytes := 'abc' asByteArray.
	self assert: (ZnCharacterEncoder detectEncoding: bytes) equals: ZnCharacterEncoder ascii.
	bytes := ZnCharacterEncoder iso88591 encodeString: 'Les élèves Français'.
	self assert: (ZnCharacterEncoder detectEncoding: bytes) equals: ZnCharacterEncoder iso88591.
	bytes := ZnCharacterEncoder utf8 encodeString: 'Les élèves Français'.
	self assert: (ZnCharacterEncoder detectEncoding: bytes) equals: ZnCharacterEncoder utf8.
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testKnownEncodingIdentifiers [
	| all minimal asciiString |
	all := ZnCharacterEncoder knownEncodingIdentifiers asSet.
	minimal := #(utf8) asSet.
	"make sure at least a minimal set is present"
	self assert: (all  select: [ :each | minimal includes: each ]) equals: minimal.
	asciiString := String withAll: ((($a asciiValue to: $z asciiValue) , 
		($A asciiValue to: $Z asciiValue) , ($0 asciiValue to: $9 asciiValue)) collect: [:each | Character codePoint: each ]).
	"make sure that each identifier can be used to instanciate a decoder,
	and that those decoders at least work on a ASCII string in both directions"
	all do: [ :each |
		| encoder bytes |
		encoder := ZnCharacterEncoder newForEncoding: each.
		bytes := encoder encodeString: asciiString.
		self assert: ((encoder decodeBytes: bytes) isEquivalent: asciiString) ]


"	| all minimal asciiString |
	all := ZnCharacterEncoder knownEncodingIdentifiers asSet.
	minimal := #(utf8 latin1 null ascii iso88591) asSet.
	self assert: (all intersection: minimal) equals: minimal.
	asciiString := String withAll: ($a to: $z) , ($A to: $Z) , ($0 to: $9).
	all do: [ :each |
		| encoder bytes |
		encoder := ZnCharacterEncoder newForEncoding: each.
		bytes := encoder encodeString: asciiString.
		self assert: (encoder decodeBytes: bytes) equals: asciiString ] "
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testLatin1Encoder [
	| encoder string bytes |
	encoder := ZnCharacterEncoder newForEncoding: 'latin1'.
	string := 'élève en Français'.
	bytes := #(233 108 232 118 101 32 101 110 32 70 114 97 110 231 97 105 115) asByteArray.
	self assert: (encoder encodeString: string) equals: bytes.
	self assert: (encoder decodeBytes: bytes) equals: string
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testLatin2Encoder [
	"Example characters taken from http://en.wikipedia.org/wiki/Latin2"
	
	| encoder inputBytes outputBytes inputString outputString |
	encoder := ZnCharacterEncoder newForEncoding: 'latin2'.
	inputString := String 
		with: (16r0154 asCharacter) with: (16r0110 asCharacter) 
		with: ( 16r0155 asCharacter) with: (16r0111 asCharacter).
	inputBytes := #(192 208 224 240) asByteArray.
	outputBytes := self encodeString: inputString with: encoder.
	self assert: outputBytes = inputBytes.
	outputString := self decodeBytes: inputBytes with: encoder.
	self assert: outputString = inputString
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testNextPutAllStartingAtToStream [
	| encoder |
	encoder := ZnUTF8Encoder new.
	#( 'ccc' 'ççç' 'c' 'ç' 'çc' 'cç' 'çç' ) do: [ :each |
		#( ( '' '' ) ( 'ABC' '' ) ( '' 'ABC' ) ( 'ABC' 'ABC' ) 
			( 'AéC' '' ) ( '' 'AèC' ) ( 'AéC' 'AèC' ) 
			( 'AXC' 'AèC' ) ( 'AéC' 'AXC' ) 
			( 'PRE' 'ç' ) ) do: [ :extra |
				| prefix postfix string bytes |
				prefix := extra first.
				postfix := extra last.
				string := prefix, each, postfix.
				bytes := ByteArray streamContents: [ :out |
					encoder next: each size putAll: string startingAt: prefix size + 1 toStream: out ].
				self assertCharacterCollection: (encoder decodeBytes: bytes) equals: each ] ]

"	| encoder |
	encoder := ZnUTF8Encoder new.
	#( 'ccc' 'ççç' 'c' 'ç' 'çc' 'cç' 'çç' ) do: [ :each |
		#( ( '' '' ) ( 'ABC' '' ) ( '' 'ABC' ) ( 'ABC' 'ABC' ) 
			( 'AéC' '' ) ( '' 'AèC' ) ( 'AéC' 'AèC' ) 
			( 'AXC' 'AèC' ) ( 'AéC' 'AXC' ) 
			( 'PRE' 'ç' ) ) do: [ :extra |
				| prefix postfix string bytes |
				prefix := extra first.
				postfix := extra last.
				string := prefix, each, postfix.
				bytes := ByteArray streamContents: [ :out |
					encoder next: each size putAll: string startingAt: prefix size + 1 toStream: out ].
				self assert: (encoder decodeBytes: bytes) equals: each ] ]"
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testNullEncoder [
	| encoder bytes string |
	encoder := ZnNullEncoder new.
	bytes := self encodeString: 'abc' with: encoder.
	self assert: bytes = #(97 98 99) asByteArray.
	string := self decodeBytes: #(65 66 67) asByteArray with: encoder.
	self assert: string = 'ABC'
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testReadIntoStartingAtCountFromStream [
	| encoder |
	encoder := ZnUTF8Encoder new.
	#( 'ccc' 'ççç' 'c' 'ç' 'çc' 'cç' 'çç' ) do: [ :each |
		#( ( '' '' ) ( 'ABC' '' ) ( '' 'ABC' ) ( 'ABC' 'ABC' ) 
			( 'AéC' '' ) ( '' 'AèC' ) ( 'AéC' 'AèC' ) 
			( 'AXC' 'AèC' ) ( 'AéC' 'AXC' ) 
			( 'PRE' 'ç' ) ) do: [ :extra |
				| prefix postfix string bytes buffer read |
				prefix := extra first.
				postfix := extra last.
				string := prefix, each.
				bytes := encoder encodeString: string, postfix.
				buffer := String new: string size.
				read := encoder readInto: buffer startingAt: 1 count: string size fromStream: bytes readStream.
				self assert: buffer equals: string.
				self assert: read equals: string size ] ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testReadIntoStartingAtCountFromStreamAtEnd [
	| input encoder bytes readStream string read |
	encoder := ZnUTF8Encoder new.
	input := 'élève'.
	bytes := encoder encodeString: input.
	readStream := bytes readStream.
	string := String new: 5 withAll: $_.
	read := encoder readInto: string startingAt: 1 count: 10 fromStream: readStream.
	self assert: string equals: input.
	self assert: read equals: 5
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testReadIntoStartingAtCountFromStreamWide [
	| encoder |

self flag: 'TODO: Need to figure out how to handle WideString'.

	encoder := ZnUTF8Encoder new.
	{ 'abc', (String withAll: { 300 asCharacter. 400 asCharacter. 500 asCharacter}), 'xyz' } do: [ :each |
			| bytes buffer notified read |
			bytes := encoder encodeString: each.
			buffer := String new: each size.
			notified := false.
			[ read := encoder readInto: buffer startingAt: 1 count: each size fromStream: bytes readStream ]
				on: ZnByteStringBecameWideString 
				do: [ :notification |
					self deny: notified.
					notified := true.
					buffer := notification wideString.
					notification resume ].
			self assert: notified.
			self assert: buffer equals: each.
			self assert: read equals: each size ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testReadIntoStartingAtCountFromStreamWithOffset [
	| input encoder bytes readStream string read |
	encoder := ZnUTF8Encoder new.
	input := '_élève_'.
	bytes := encoder encodeString: input.
	readStream := bytes readStream.
	readStream next.
	string := String new: 7 withAll: $_.
	read := encoder readInto: string startingAt: 2 count: 5 fromStream: readStream.
	self assertCharacterCollection: string equals: input.
	self assert: read equals: 5.
	input := '_Français_'.
	bytes := encoder encodeString: input.
	readStream := bytes readStream.
	readStream next.
	string := String new: 10 withAll: $_.
	read := encoder readInto: string startingAt: 2 count: 8 fromStream: readStream.
	self assert: string equals: input.
	self assert: read equals: 8
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testStringEncoding [
	| encoder string |
	encoder := ZnUTF8Encoder new.
	string := 'élève en Français'.
	self assert: (string encodeWith: encoder) equals: (encoder encodeString: string).
	self assert: (string encodeWith: #utf8) equals: (encoder encodeString: string).
	self assert: string encodeAsUTF8 asByteArray equals: (encoder encodeString: string)

"	| encoder string |
	encoder := ZnUTF8Encoder new.
	string := 'élève en Français'.
	self assert: (string encodeWith: encoder) equals: (encoder encodeString: string).
	self assert: (string encodeWith: #utf8) equals: (encoder encodeString: string).
	self assert: string utf8Encoded equals: (encoder encodeString: string)"
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF16Back [
	| encoder stream |
	encoder := ZnUTF16Encoder new.
	stream := (encoder encodeString: 'Les élèves Françaises') readStream.
	self should: [ encoder backOnStream: stream ] raise: Error.
	4 timesRepeat: [ encoder nextFromStream: stream ].
	self assert: (encoder nextFromStream: stream) equals: $é.
	encoder backOnStream: stream.
	self assert: (encoder nextFromStream: stream) equals: $é.
	10 timesRepeat: [ encoder nextFromStream: stream ].
	13 timesRepeat: [ encoder backOnStream: stream ].
	self assert: (encoder nextFromStream: stream) equals: $s
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF16EncoderBigEndian [
	| string bytes encoder |
	string := 'élève en Français'.
	bytes := ByteArray readHexFrom:
		'00E9006C00E80076006500200065006E0020004600720061006E00E7006100690073'.
	encoder := ZnUTF16Encoder new.
	self assert: encoder isBigEndian.
	self assert: (encoder encodeString: string) equals: bytes.
	self assert: (encoder decodeBytes: bytes) equals: string
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF16EncoderByteOrderMark [
	| string bytes encoder encoded |
	string := 'foo'.
	bytes := ByteArray readHexFrom: 'FEFF0066006f006f'.
	encoder := ZnUTF16Encoder new.
	self assert: encoder isBigEndian.
	encoded := ByteArray streamContents: [ :out |
		encoder nextPutByteOrderMarkToStream: out.
		encoder next: string size putAll: string startingAt: 1 toStream: out ].
	self assert: encoded equals: bytes.
	self assert: (encoder decodeBytes: bytes) equals: string.
	encoder beLittleEndian.
	self assert: encoder isLittleEndian.
	self assert: (encoder decodeBytes: bytes) equals: string.
	self assert: encoder isBigEndian.
	1 to: bytes size by: 2 do: [ :each | bytes swap: each with: each + 1 ].
	self assert: (encoder decodeBytes: bytes) equals: string.
	self assert: encoder isLittleEndian
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF16EncoderLittleEndian [
	| string bytes encoder |
	string := 'élève en Français'.
	bytes := ByteArray readHexFrom:
		'E9006C00E80076006500200065006E0020004600720061006E00E700610069007300'.
	encoder := ZnUTF16Encoder new.
	encoder beLittleEndian.
	self assert: encoder isLittleEndian.
	self assert: (encoder encodeString: string) equals: bytes.
	self assert: (encoder decodeBytes: bytes) equals: string
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF16EncoderWide1 [
	| string bytes encoder |
	string := (Character codePoint: 16r1d11e) asString. "MUSICAL SYMBOL G CLEF"
	bytes := ByteArray readHexFrom: 'D834DD1E'.
	encoder := ZnUTF16Encoder new.
	self assert: encoder isBigEndian.
	self assert: (encoder encodeString: string) equals: bytes.
	self assert: (encoder decodeBytes: bytes) equals: string
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF32EncoderExampleFromD100 [
	| string bytes encoder |
	string := #(16r0000004D 16r00000430 16r00004E8C 16r00010302) collect: [:ea | ea asCharacter] as: String.
	bytes := ByteArray readHexFrom: '4D000000300400008C4E000002030100'.
	encoder := #utf32 asZnCharacterEncoder.
	encoder beLittleEndian.
	self assert: encoder isLittleEndian.
	self assert: (encoder encodeString: string) equals: bytes.
	self assert: (encoder decodeBytes: bytes) equals: string
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF32EncoderExampleFromD101 [
	| string encoder bytesBigEndianWithBom bytesLittleEndianWithBom |
	string := #(16r0000004D 16r00000430 16r00004E8C 16r00010302) collect: [:ea | ea asCharacter] as: String.
	encoder := #utf32 asZnCharacterEncoder.
	encoder beLittleEndian.
	"start with the wrong endianness (LE)"
	bytesBigEndianWithBom := ByteArray readHexFrom: '0000FEFF0000004D0000043000004E8C00010302'.
	"the correct endianness (BE) should be detected"
	self assert: (encoder decodeBytes: bytesBigEndianWithBom) equals: string.
	self assert: encoder isBigEndian.
	"start with the wrong endianness (BE)"
	bytesLittleEndianWithBom := ByteArray readHexFrom: 'FFFE00004D000000300400008C4E000002030100'.
	"the correct endianness (LE) should be detected"
	self assert: (encoder decodeBytes: bytesLittleEndianWithBom) equals: string.
	self assert: encoder isLittleEndian.
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF32EncoderExampleFromD99 [
	| string bytes encoder |
	string := #(16r0000004D 16r00000430 16r00004E8C 16r00010302) collect: [:ea | ea asCharacter] as: String.
	bytes := ByteArray readHexFrom: '0000004D0000043000004E8C00010302'.
	encoder := #utf32 asZnCharacterEncoder.
	encoder beBigEndian.
	self assert: encoder isBigEndian.
	self assert: (encoder encodeString: string) equals: bytes.
	self assert: (encoder decodeBytes: bytes) equals: string
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF32EncoderSimple [
	| string bytes encoder |
	string := 'élève en Français'.
	bytes := ByteArray readHexFrom: '000000e90000006c000000e8000000760000006500000020000000650000006e000000200000004600000072000000610000006e000000e7000000610000006900000073'.
	encoder := #utf32 asZnCharacterEncoder.
	self assert: encoder isBigEndian.
	self assert: (encoder encodedByteCountForString: string) equals: 17 * 4.
	self assert: (encoder encodeString: string) equals: bytes.
	self assert: (encoder decodeBytes: bytes) equals: string
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF32EncoderWide [
	| encoder |
	encoder := ZnUTF32Encoder new.
	{ 
		'abc'. 
		'élève en Français'. 
		'Pra-ská' copy at: 4 put: (Character value: 382); yourself. 
		(Character codePoint: 16r1d11e) asString. "MUSICAL SYMBOL G CLEF"
		'' } do: [ :each | 
			| bytes |
			bytes := self encodeString: each with: encoder. 
			self assert: (encoder decodeBytesIntoWideString: bytes) equals: each ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8Back [
	| encoder stream |
	encoder := ZnUTF8Encoder new.
	stream := (encoder encodeString: 'Les élèves Françaises') readStream.
	self should: [ encoder backOnStream: stream ] raise: Error.
	4 timesRepeat: [ encoder nextFromStream: stream ].
	self assert: (encoder nextFromStream: stream) equals: $é.
	encoder backOnStream: stream.
	self assert: (encoder nextFromStream: stream) equals: $é.
	10 timesRepeat: [ encoder nextFromStream: stream ].
	13 timesRepeat: [ encoder backOnStream: stream ].
	self assert: (encoder nextFromStream: stream) equals: $s
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8Boundaries [
	"Test encoding and decoding of the characters at the boundaries between 1, 2, 3, and 4 multi-byte sequences.
	Values taken from http://en.wikipedia.org/wiki/Utf8#Description with the new RFC 3629 limit"
	
	| utf8Encoder string encoded |
	utf8Encoder := ZnUTF8Encoder new.
	#( (0 16r7f) 
		(16r80 16r07FF) 
		(16r0800 16rFFFF) 
		(16r10000 16r10FFFF) 
	) doWithIndex: [ :boundaries :byteCount |
		boundaries do: [ :each |
			string := String with: each asCharacter.
			encoded := utf8Encoder encodeString: string. 
			self assertCharacterCollection: (utf8Encoder decodeBytes: encoded) equals: string.
	"		self assert: (utf8Encoder decodeBytes: encoded) equals: string."
			self assert: encoded size equals: byteCount ] ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8ByteOrderMark [
	"The Unicode Byte Order Mark (BOM) should be skipped."
	
	| bom string bytes encoder decodedString |
	encoder := ZnUTF8Encoder new.
	string := 'élève en Français'.
	bytes := encoder encodeStringWithByteOrderMark: string.
	self assertString: (encoder decodeBytes: bytes) equalsString: string.
	
	string := 'Foo'.
	bytes := encoder encodeStringWithByteOrderMark: string.
	decodedString := String new: string size.
	ZnUTF8Encoder new 
		readInto: decodedString startingAt: 1 count: string size fromStream: bytes readStream. 
	self assertString: decodedString equalsString: string.
	
	bom := encoder encodeStringWithByteOrderMark: ''.
	self should: [ encoder decodeBytes: bom ] raise: Error
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8Encoder [
	"The examples are taken from http://en.wikipedia.org/wiki/UTF-8#Description"
	
	| encoder inputBytes outputBytes inputString outputString |
	encoder := ZnUTF8Encoder new.
	inputString := String with: $$ with: (16r00A2 asCharacter) with: (16r20AC asCharacter) with: (16r024B62 asCharacter).
	inputBytes := #(16r24 16rC2 16rA2 16rE2 16r82 16rAC 16rF0 16rA4 16rAD 16rA2) asByteArray.
	outputBytes := self encodeString: inputString with: encoder.
	self assert: outputBytes = inputBytes.
	outputString := self decodeBytes: inputBytes with: encoder.
	self assertCharacterCollection: outputString equals: inputString
"	self assert: outputString = inputString"
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8EncoderAuto [
	| encoder inputString bytes outputString |
	encoder := ZnUTF8Encoder new.
	inputString := String withAll: ((1 to: 3072) collect: [ :each | Character codePoint: each ]).
	bytes := self encodeString: inputString with: encoder. 
	outputString := self decodeBytes: bytes with: encoder.
	self assertCharacterCollection: inputString equals: outputString
"	self assert: inputString = outputString"
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8EncoderByteCount [	
	| encoder |
	encoder := ZnUTF8Encoder new.
	self assert: (encoder encodedByteCountFor: $$) = 1.
	self assert: (encoder encodedByteCountFor: (16r00A2 asCharacter)) = 2.
	self assert: (encoder encodedByteCountFor: (16r20AC asCharacter)) = 3.
	self assert: (encoder encodedByteCountFor: (16r024B62 asCharacter)) = 4
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8EncoderIncomplete [
	"The examples are taken from http://en.wikipedia.org/wiki/UTF-8#Description"
	
	| encoder |
	encoder := ZnUTF8Encoder new.
	#( (16rC2 16rA2) (16rE2 16r82 16rAC) (16rF0 16rA4 16rAD 16rA2) ) do: [ :each |
		2 to: each size do: [ :count |
			self 
				should: [ encoder decodeBytes: (each allButLast: count - 1) ] 
				raise: ZnCharacterEncodingError ] ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8EncoderRandom [
	#(unicodeCharacterSource latin1CharacterSource asciiCharacterSource) do: [ :source |
		| string bytes result |
		string := self class stringOfSize: 256 fromSource: source.
		bytes := string utf8Encoded.
		result := bytes utf8Decoded.
		self assertString: result equalsString: string ]
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8EncoderWide [
	| encoder |
	encoder := ZnUTF8Encoder new.
	{ 'abc'. 'élève en Français'. 'Pra-ská' copy at: 4 put: (Character codePoint: 382); yourself. '' }
		do: [ :each | | bytes |
			bytes := self encodeString: each with: encoder. 
			self assertCharacterCollection: (encoder decodeBytes: bytes) equals: each ]
"			self assert: (encoder decodeBytesIntoWideString: bytes) equals: each ]"
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8Overlong [
	"Overlong encoding, aka Non shortest form characters should be rejected.
	See http://en.wikipedia.org/wiki/UTF-8#Overlong_encodings"
	
	self 
		should: [ ZnUTF8Encoder new decodeBytes: #[ 16rF0 16r82 16r82 16rAC ] ] 
		raise: ZnCharacterEncodingError.
	self 
		should: [ ZnUTF8Encoder new decodeBytes: #(193 129 193 130 193 131 ) ] 
		raise: ZnCharacterEncodingError.
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8ReadFaultyInput [
	"Although not recommended, it is possible to read faulty UTF-8 encoded input by resuming ZnInvalidUTF8"
	
	"illegal leading byte"
	self 
		should: [ #[102 111 111 160 102 111 111] utf8Decoded ] 
		raise: ZnInvalidUTF8.
	self 
		assert: ([ #[102 111 111 160 102 111 111] utf8Decoded ] on: ZnInvalidUTF8 do: [ :exception | exception resume ]) 
		equals: 'foo?foo'.
	self 
		assert: ([ #[102 111 111 160 102 111 111] utf8Decoded ] on: ZnInvalidUTF8 do: [ :exception | exception resume: $_ codePoint ]) 
		equals: 'foo_foo'.
	
	"illegal continuation byte"
	self 
		should: [ #[102 111 111 195 0 102 111 111] utf8Decoded ] 
		raise: ZnInvalidUTF8.
	self 
		assert: ([ #[102 111 111 195 0 102 111 111] utf8Decoded ] on: ZnInvalidUTF8 do: [ :exception | exception resume ]) 
		equals: 'foo?foo'.

	"incomplete input"
	self 
		should: [ #[102 111 111 195 ] utf8Decoded ] 
		raise: ZnIncomplete.
	self 
		assert: ([ #[102 111 111 195 ] utf8Decoded ] on: ZnInvalidUTF8 , ZnIncomplete do: [ :exception | exception resume ]) 
		equals: 'foo?'
]

{ #category : 'testing' }
ZnCharacterEncoderTests >> testUTF8SurrogateCodePointsShouldFail [
	| encoder surrogateCodePoint |
	encoder := #utf8 asZnCharacterEncoder.
	surrogateCodePoint := 16rD801.
	self assert: (encoder isSurrogateCodePoint: surrogateCodePoint).
	self 
		should: [ encoder encodeString: surrogateCodePoint asCharacter asString ]
		raise: ZnInvalidUTF8.
	self 
		should: [ encoder decodeBytes: #[237 160 129] ]
		raise: ZnCharacterEncodingError
]