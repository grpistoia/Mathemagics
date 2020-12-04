"
Class part:

	This class represents the trigonometric function ""cosine"". Support a numeric value { cos(0.5) } or a mathematical constant { cos(pi) } or any other subexpression { cos(x + pi/3) }. When calculates is assumed the subexpression is expressed in radians.

Properties:

	- Support some automated simplifications { cos(pi) => -1 }.

		(MathExpression from: ' cos(pi) ') simplify.

Responsibility part:

	- Sending #isNumber, it will return true if the subexpression can evaluate to number
	- Sending #simplify will expand the expression if an addition is provided { cos( x + a ) }
	- The derivative of this expression is { cos( u )' = - u' * sin(u)' }

		(MathExpression from: ' cos(x^2) ') derivativeFor: 'x'.		""Will return {  -2*x * sin(x^2) }""

"
Class {
	#name : #MathExpCosine,
	#superclass : #MathExpTrigonometricFunction,
	#category : #'Mathemagics-Core-FunctionsCircle'
}

{ #category : #mathematics }
MathExpCosine class >> mathSymbol [
	^ #cos.
]

{ #category : #converting }
MathExpCosine >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ subexpression asNumber cos.
]

{ #category : #converting }
MathExpCosine >> derivativeFor: aVariableExpression [
	"dx(cos(u)) = - dx(u) * sin(u)"

	| u dxU dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := subexpression simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxFx := dxU negated * (u sin).
	^ dxFx simplify.
]

{ #category : #private }
MathExpCosine >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"cos(arccos(x)) => x"
	(subexpression class = MathExpArcCosine) ifTrue: [ ^ self simplifyInto: (subexpression subexpression) trail: aTrail ].

	"{ cos(a + b) = cos(a)*cos(b) - sin(a)*sin(b) } AT THE MOMENT NOT HELPING"
	"(subexpression isKindOf: MathExpAddition) | (subexpression isKindOf: MathExpSubtraction) ifTrue: [
		| a b |
		a := subexpression leftSide.
		b := subexpression rightSide.
		(subexpression isKindOf: MathExpSubtraction) ifTrue: [ b := b negated ].
		^ (self trackOn: (a cos * b cos) - (a sin * b sin)) simplify.
	]."

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]
