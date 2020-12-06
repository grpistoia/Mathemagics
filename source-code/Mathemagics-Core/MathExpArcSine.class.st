"
Class part:

	This class represents the inverse of the trigonometric function ""sine"". Notice that ""arcsin"" has a range between -1 and 1 since the ""sine"" will only return a number on that range.

Properties:

	- Support some automated simplifications { arcSin(sin(pi) => pi }.

		(MathExpression from: ' arcSin(1) ') asNumber.

Responsibility part:

	- Sending #isNumber, it will return true if the subexpression can evaluate to number
	- The derivative of this expression is { arcSin( u )' = u' * ( +1 / sqrt( 1 - u^2 ) ) }

		(MathExpression from: ' arcSin(x) ') derivativeFor: $x.		""Will return { 1 / sqrt(-x^2 + 1) } ""
"
Class {
	#name : #MathExpArcSine,
	#superclass : #MathExpTrigonometricFunction,
	#category : #'Mathemagics-Core-FunctionsCircle'
}

{ #category : #mathematics }
MathExpArcSine class >> mathSymbol [
	"Most people write it lowercase"
	^ #arcsin.
]

{ #category : #mathematics }
MathExpArcSine class >> mathSymbolSmalltalk [
	^ #arcSin.
]

{ #category : #converting }
MathExpArcSine >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ subexpression asNumber arcSin.
]

{ #category : #converting }
MathExpArcSine >> derivativeFor: aVariableExpression [
	"dx(arcSin(u)) = dx(u) * ( +1 / sqrt( 1 - u^2 ) )"

	| u dxU dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := subexpression simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxFx := dxU * ( MathExpNumber one / ( ( MathExpNumber one - (u ** MathExpNumber two) ) sqrt ) ).
	^ dxFx simplify.
]

{ #category : #private }
MathExpArcSine >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	self flag: #mayReturnFormulaInstead.
	"arcsin(sin(x)) => x  .. is actually { arcsin( sin x ) = x + 2*k*pi } but made simple here"
	(subexpression class == MathExpSine) ifTrue: [ ^ self simplifyInto: (subexpression subexpression) trail: aTrail ].

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]
