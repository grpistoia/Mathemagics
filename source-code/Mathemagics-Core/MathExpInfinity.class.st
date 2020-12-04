"
For the Class part:

	Represents cases like logarithm: zero. Mainly for presentation.

For the Responsibility part:

	You shouldn't instance this class. See superclass.
"
Class {
	#name : #MathExpInfinity,
	#superclass : #MathExpValueUnclear,
	#category : #'Mathemagics-Core-Numeric'
}

{ #category : #mathematics }
MathExpInfinity class >> mathSymbol [
	"Allow entering the text."
	^ #Infinity.
]

{ #category : #mathematics }
MathExpInfinity class >> mathSymbolPro [
	"The symbol (not written here due to FileOut load issue)"
	^ Unicode value: 16r221E.
]

{ #category : #'see class side' }
MathExpInfinity >> seeClassSide [
]
