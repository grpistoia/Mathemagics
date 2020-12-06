"
Class part:

	This class represents the trigonometric function ""sine"". Support a numeric value { sin(0.7) } or a mathematical constant { sin(pi) } or any other subexpression { sin(y + 3*pi) }. When calculates is assumed the subexpression is expressed in radians.

Properties:

	- Support some automated simplifications { sin(pi) => 0 }.

		(MathExpression from: ' sin(0) ') simplify.

Responsibility part:

	- Sending #isNumber, it will return true if the subexpression can evaluate to number
	- Sending #simplify will expand the expression if an addition is provided { sin( x + a ) }
	- The derivative of this expression is { sin( u )' = u' * cos(u)' }

		(MathExpression from: ' sin(x^3) ') derivativeFor: 'x'.		""Will return { 3*x^2*(cos(x^3)) }""

"
Class {
	#name : #MathExpSine,
	#superclass : #MathExpTrigonometricFunction,
	#category : #'Mathemagics-Core-FunctionsCircle'
}

{ #category : #mathematics }
MathExpSine class >> mathSymbol [
	^ #sin.
]

{ #category : #converting }
MathExpSine >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ subexpression asNumber sin.
]

{ #category : #converting }
MathExpSine >> derivativeFor: aVariableExpression [
	"dx(sin(u)) = dx(u) * cos(u)"

	| u dxU dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := subexpression simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxFx := dxU * (u cos).
	^ dxFx simplify.
]

{ #category : #private }
MathExpSine >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"sin(arcsin(x)) => x"
	(subexpression class == MathExpArcSine) ifTrue: [ ^ self simplifyInto: (subexpression subexpression) trail: aTrail ].

	"{ sin(a + b) = cos(a)*sin(b) + sin(a)*cos(b) } AT THE MOMENT NOT HELPING"
	"(subexpression isClassddition) | (subexpression isClassSubtraction) ifTrue: [
		| a b |
		a := subexpression leftSide.
		b := subexpression rightSide.
		(subexpression isClassSubtraction) ifTrue: [ b := b negated ].
		^ (self trackOn: (a cos * b sin) + (a sin * b cos)) simplify.
	]."

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]
