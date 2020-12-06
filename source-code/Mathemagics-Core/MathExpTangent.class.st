"
Class part:

	This class represents the trigonometric function ""tangent"". Support a numeric value { tan(0.9) } or a mathematical constant { tan(pi) } or any other subexpression { tan(z + 0.5*pi) }. When calculates is assumed the subexpression is expressed in radians.

Properties:

	- Support some automated simplifications { tan(0) => 0 }.

		(MathExpression from: ' tan(pi) ') simplify.

Responsibility part:

	- Sending #isNumber, it will return true if the subexpression can evaluate to number
	- Sending #simplify will expand the expression if an addition is provided { tan( x + a ) }
	- The derivative of this expression is { tan( u )' = ( sin(u) / cos(u) ) ' }

		(MathExpression from: ' tan(x) ') derivativeFor: 'x'.     ""Will return {  1/(cos(x)^2) } when only 'x' is the subexpression""
		(MathExpression from: ' tan(x^2) ') derivativeFor: 'x'.   ""Go ahead.. you do it before evaluating""

Note: Secant and Cosecant are not yet implemented.
"
Class {
	#name : #MathExpTangent,
	#superclass : #MathExpTrigonometricFunction,
	#category : #'Mathemagics-Core-FunctionsCircle'
}

{ #category : #mathematics }
MathExpTangent class >> mathSymbol [
	^ #tan.
]

{ #category : #converting }
MathExpTangent >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ subexpression asNumber tan.
]

{ #category : #converting }
MathExpTangent >> derivativeFor: aVariableExpression [
	"dx(tan(u)) = dx(sin(u)/cos(u)) .. but .. 1/cos(u)^2 <=> [u = x]"

	| u dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	"For simplicity and checks.."
	u := subexpression simplify.

	"Simpler case"
	(u class isVariable and: [ (u derivativeFor: aVariableExpression) = MathExpNumber one ])
		ifTrue: [ ^ MathExpNumber one / (u cos ** MathExpNumber two) ].

	"Generic case ends with { sin2+cos2 }"
	dxFx := ((u sin) / (u cos)) derivativeFor: aVariableExpression.
	^ dxFx simplify.
]

{ #category : #testing }
MathExpTangent >> isNumber [
	"Cannot calculate"
	^ super isNumber and: [ subexpression cos isNotZero ].
]

{ #category : #private }
MathExpTangent >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"arctan(tan(x)) => x"
	(subexpression class == MathExpArcTangent) ifTrue: [ ^ self simplifyInto: (subexpression subexpression) trail: aTrail ].

	"Notice { (Float pi / 2) tan } is returning a number and not infinity..."
	(subexpression equalsHalfPi) | (subexpression equalsMinusHalfPi) ifTrue: [ ^ MathExpUndefined new ].

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]
