"
Class part:

	This class represents an expression raised to the power two { sqr(x) = x^2 }, therefore just a sub-category of the super class. All other information is in the super class, since this class is mainly for printing and parsing reasons.

		MathExpression from: 'sqrt(5)'.			""Don't confuse with sqr = 5^2""
"
Class {
	#name : #MathExpSquareRoot,
	#superclass : #MathExpPower,
	#category : #'Mathemagics-Core-FunctionsBasic'
}

{ #category : #mathematics }
MathExpSquareRoot class >> mathSymbol [
	^ #sqrt.
]

{ #category : #mathematics }
MathExpSquareRoot class >> mathSymbolPro [
	"The square root symbol (not written here due to FileOut load issue)"
	^ Unicode value: 16r221A.
]

{ #category : #mathematics }
MathExpSquareRoot class >> mathSymbolSmalltalk [
	"Force to use the same at this level (parent is different)"
	^ self mathSymbol.
]

{ #category : #converting }
MathExpSquareRoot >> asNumber [
	"Workaround: I dont use power but force sqrt because seems to do better."
	^ leftSide asNumber sqrt

	"I use sqrt because is more accurate.."
	"25 sqrt ==> 5".
	"25 ** (1/2) ==> 5"
	"25 ** 0.5 ==> 4.999999999999999  !!!??"
]

{ #category : #printing }
MathExpSquareRoot >> codeOn: aStream [
	"This just calls methods that repeat quite a bit of logic"

	"left side"
	self utilCodeTerm: leftSide onto: aStream.

	"Put the mathematical symbol in between"
	self utilCodeSymbolOnto: aStream.

	"No need to code the right side"
]
