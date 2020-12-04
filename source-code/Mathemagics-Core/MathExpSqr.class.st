"
Class part:

	This class represents an expression raised to the power two { sqr(x) = x^2 }, therefore just a sub-category of the super class. All other information is in the super class, since this class is mainly for printing and parsing reasons.

		MathExpression from: 'sqr(5)'.
		MathExpression from: 'squared(5)'.
"
Class {
	#name : #MathExpSqr,
	#superclass : #MathExpPower,
	#category : #'Mathemagics-Core-FunctionsBasic'
}

{ #category : #mathematics }
MathExpSqr class >> instantiationMethod [
	"I use #sqr... because #squared is { x^2 } but is more appropriate for asBlock"
	^ self mathSymbol.
	
	"NOTE: I want to instantiate with #sqr not with #squared."
]

{ #category : #mathematics }
MathExpSqr class >> mathSymbol [
	^ #sqr.
]

{ #category : #mathematics }
MathExpSqr class >> mathSymbolSmalltalk [
	"Prints and codes with this"
	^ #squared.
]

{ #category : #printing }
MathExpSqr >> codeOn: aStream [
	"This just calls methods that repeat quite a bit of logic"

	"left side"
	self utilCodeTerm: leftSide onto: aStream.

	"Put the mathematical symbol in between"
	self utilCodeSymbolOnto: aStream.

	"No need to code the right side"
]

{ #category : #private }
MathExpSqr >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"Only if you simplify I will dare to change { sqr(x) => x^2 }. I dont do the same for sqrt."
	(rightSide = MathExpNumber two) ifTrue: [ ^ self simplifyInto: (leftSide ** 2) trail: aTrail ].
	
	"I reached here, allow the generic simplification to proceed.."
	^ super runSimplifyRulesTrailOn: aTrail.
]
