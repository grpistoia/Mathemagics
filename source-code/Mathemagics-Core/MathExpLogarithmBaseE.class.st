"
Class part:

	Natural Logarithm. This class represents the logarithm with base 'e' (Euler's number) of an expression. All other information is in the super class, since this class is mainly for printing and parsing reasons.

		MathExpression from: 'ln( x )'.
		MathExpression from: 'e logarithm (e^y)'.
"
Class {
	#name : #MathExpLogarithmBaseE,
	#superclass : #MathExpLogarithm,
	#category : #'Mathemagics-Core-FunctionsBasic'
}

{ #category : #mathematics }
MathExpLogarithmBaseE class >> logarithmBase [
	"Some calculations will simplify based on this"
	^ MathExpUniversalConstant e.
]

{ #category : #mathematics }
MathExpLogarithmBaseE class >> mathSymbol [
	^ #ln.
]

{ #category : #mathematics }
MathExpLogarithmBaseE class >> mathSymbolSmalltalk [
	"Because of the parent class.. override"
	^ self mathSymbol.
]

{ #category : #converting }
MathExpLogarithmBaseE >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ rightSide asNumber ln.
]
