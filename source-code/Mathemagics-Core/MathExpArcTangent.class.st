"
Class part:

	This class represents the inverse of the trigonometric function ""tangent"". Notice that ""arctan"" has a range between -1 and 1 since the ""tangent"" will only return a number on that range.

Properties:

	- Support some automated simplifications { arcTan(tan(pi) => pi }.

		(MathExpression from: ' arcTan(1) ') asNumber.

Responsibility part:

	- Sending #isNumber, it will return true if the subexpression can evaluate to number
	- The derivative of this expression is { arcTan( u )' = u' * ( +1 / ( u^2 + 1 ) ) }

		(MathExpression from: ' arcTan(x) ') derivativeFor: $x.			""Will return { 1 / ( x^2 + 1) } ""
"
Class {
	#name : #MathExpArcTangent,
	#superclass : #MathExpTrigonometricFunction,
	#category : #'Mathemagics-Core-FunctionsCircle'
}

{ #category : #mathematics }
MathExpArcTangent class >> mathSymbol [
	"Most people write it lowercase"
	^ #arctan.
]

{ #category : #mathematics }
MathExpArcTangent class >> mathSymbolSmalltalk [
	^ #arcTan.
]

{ #category : #converting }
MathExpArcTangent >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ subexpression asNumber arcTan.
]

{ #category : #converting }
MathExpArcTangent >> derivativeFor: aVariableExpression [
	"dx(arcSin(u)) = dx(u) * ( +1 / ( u^2 + 1 ) )"

	| u dxU dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := subexpression simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxFx := dxU * ( MathExpNumber one / ( (u ** MathExpNumber two) + MathExpNumber one ) ).
	^ dxFx simplify.
]

{ #category : #private }
MathExpArcTangent >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	self flag: #mayReturnFormulaInstead.
	"arctan(tan(x)) => x"
	(subexpression class = MathExpTangent) ifTrue: [ ^ self simplifyInto: (subexpression subexpression) trail: aTrail ].

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]
