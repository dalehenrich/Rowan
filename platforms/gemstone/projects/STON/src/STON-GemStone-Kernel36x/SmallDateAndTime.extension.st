Extension { #name : 'SmallDateAndTime' }

{ #category : '*ston-gemstone-kernel36x' }
SmallDateAndTime class >> stonName [
	"Need to use a well-known class name. Instances of DateAndTime converted to SmallDateAndTime if in range"
	
	^ 'DateAndTime'
]
