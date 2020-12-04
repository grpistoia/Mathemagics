"
Class part:

	Common Logarithm. This class represents the logarithm with base 10 of an expression. All other information is in the super class, since this class is mainly for printing and parsing reasons.

		MathExpression from: 'log(100)'.
		MathExpression from: '10 logarithm x'.
"
Class {
	#name : #MathExpLogarithmBaseTen,
	#superclass : #MathExpLogarithm,
	#category : #'Mathemagics-Core-FunctionsBasic'
}

{ #category : #mathematics }
MathExpLogarithmBaseTen class >> logarithmBase [
	"Some calculations will simplify based on this"
	^ MathExpNumber ten.
]

{ #category : #mathematics }
MathExpLogarithmBaseTen class >> mathSymbol [
	^ #log.
]

{ #category : #mathematics }
MathExpLogarithmBaseTen class >> mathSymbolSmalltalk [
	"Because of the parent class.. override"
	^ self mathSymbol.
]

{ #category : #converting }
MathExpLogarithmBaseTen >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ rightSide asNumber log.
]
