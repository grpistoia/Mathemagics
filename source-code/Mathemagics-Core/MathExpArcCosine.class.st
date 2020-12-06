"
Class part:

	This class represents the inverse of the trigonometric function ""cosine"". Notice that ""arccos"" has a range between -1 and 1 since the ""cosine"" will only return a number on that range.

Properties:

	- Support some automated simplifications { arcCos(cos(pi) => pi }.

		(MathExpression from: ' arcCos(0) ') asNumber.

Responsibility part:

	- Sending #isNumber, it will return true if the subexpression can evaluate to number
	- The derivative of this expression is { arcCos( u )' = u' * ( -1 / sqrt( 1 - u^2 ) ) }

		(MathExpression from: ' arcCos(x) ') derivativeFor: $x.		""Will return { -1 / sqrt(-x^2 + 1) } ""
"
Class {
	#name : #MathExpArcCosine,
	#superclass : #MathExpTrigonometricFunction,
	#category : #'Mathemagics-Core-FunctionsCircle'
}

{ #category : #mathematics }
MathExpArcCosine class >> mathSymbol [
	"Most people write it lowercase"
	^ #arccos.
]

{ #category : #mathematics }
MathExpArcCosine class >> mathSymbolSmalltalk [
	^ #arcCos.
]

{ #category : #converting }
MathExpArcCosine >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ subexpression asNumber arcCos.
]

{ #category : #converting }
MathExpArcCosine >> derivativeFor: aVariableExpression [
	"dx(arcCos(u)) = dx(u) * ( -1 / sqrt( 1 - u^2 ) )"

	| u dxU dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := subexpression simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxFx := dxU * ( MathExpNumber minusOne / ( ( MathExpNumber one - (u ** MathExpNumber two) ) sqrt ) ).
	^ dxFx simplify.
]

{ #category : #private }
MathExpArcCosine >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	self flag: #mayReturnFormulaInstead.
	"arccos(cos(x)) => x  .. is actually { arccos( cos x ) = x + 2*k*pi } but made simple here"
	(subexpression class == MathExpCosine) ifTrue: [ ^ self simplifyInto: (subexpression subexpression) trail: aTrail ].

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]
