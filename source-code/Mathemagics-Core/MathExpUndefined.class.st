"
For the Class part: 

	Represents cases like division by zero.

For the Responsibility part:

	You shouldn't instance this class. See superclass.
"
Class {
	#name : #MathExpUndefined,
	#superclass : #MathExpValueUnclear,
	#category : #'Mathemagics-Core-Numeric'
}

{ #category : #mathematics }
MathExpUndefined class >> mathSymbol [
	"Apparently in Math the undefined is a down arrow but nobody will expect that."
	^ #Undefined.
]

{ #category : #'see class side' }
MathExpUndefined >> seeClassSide [
]
