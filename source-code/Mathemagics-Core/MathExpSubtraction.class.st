"
Class part:

	This class represents the difference of two subexpressions (not necessarily just numbers).

Properties:

	- Does NOT supports associative property
	- Does NOT supports commutative property { a - b = b - a } but support similar by changing signs { a - b = - b + a }
	- Supports distributive property for multiplication { a * (b - c) = a * b - a * c }

Responsibility part:

	- Sending #isNumber, it will return true if both terms can evaluate to number (inner Variables have a value assigned too)
	- Sending #simplify will reduce itself to one term if the other equals zero { 0 - x =  - x + 0 => - x }
	- Sending #simplify will remove redundant negative sign and return an addition { a - (-b) => a + b }
	- Sending #simplify will become zero if the same term appears twice { x - x => 0 }
	- Sending #simplify the numbers will move to the end of the expression, same as in Polynomials, using commutative property { 3 - x => - x + 3 }
	- The derivative of this expression is { ( u - v )' = u' - v' }

"
Class {
	#name : #MathExpSubtraction,
	#superclass : #MathExpBinary,
	#category : #'Mathemagics-Core-BasicOperators'
}

{ #category : #mathematics }
MathExpSubtraction class >> mathSymbol [
	^ #-.
]

{ #category : #mathematics }
MathExpSubtraction class >> precedence [
	"Same as addition, meaning the order is left to right"
	^ MathExpAddition precedence.
]

{ #category : #converting }
MathExpSubtraction >> asCommutative [
	"Subtraction can change to negative Addition { a - x => a + (-x) }"
	^ leftSide + rightSide negated.
]

{ #category : #converting }
MathExpSubtraction >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ (leftSide asNumber) - (rightSide asNumber)
]

{ #category : #converting }
MathExpSubtraction >> derivativeFor: aVariableExpression [
	"dx(u+v) = dx(u) - dx(v)"

	| u v dxU dxV dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := leftSide simplify.
	v := rightSide simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxV := v derivativeFor: aVariableExpression.
	dxFx := dxU - dxV.
	^ dxFx simplify.
]

{ #category : #converting }
MathExpSubtraction >> expand [
	"This is the opposite of Factoring"
	| binarySide unarySide |
	binarySide := leftSide class isBasicOperator ifTrue: [ leftSide ] ifFalse: [ rightSide ].
	unarySide := leftSide class isBasicOperator ifTrue: [ rightSide ] ifFalse: [ leftSide ].

	self assert: self isCommutative not.

	"a - (b + c)"
	binarySide class = MathExpAddition ifTrue: [ ^ self asCommutative commuteTerms ].
	"a - (b - c)"
	binarySide class = MathExpSubtraction ifTrue: [ ^ self asCommutative commuteTerms ].
	"a - (b * c)"
	binarySide class = MathExpMultiplication ifTrue: [
		"x - (x * a) = (1 - a)*x ... notice.. x^2 + (2 * x) does not works the same.. must be same power"
		((unarySide isNotNumber) and: [ (unarySide = binarySide leftSide) | (unarySide = binarySide rightSide) ])
			ifTrue: [ ^ self factorFromSum ].
	].
	"a - (b / c)"
	binarySide class = MathExpDivision ifTrue: [
		"x - (x / a) = x * (1 - 1/a)"
		((unarySide isNotNumber) and: [ unarySide = binarySide leftSide ]) ifTrue: [ ^ self factorFromSum ].
	].

	"Only +-*/ are expandable but I let you add functions later"
	^ super expand.
]

{ #category : #private }
MathExpSubtraction >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"{ x - 0 => x }"
	(rightSide isZero) ifTrue: [ ^ self simplifyInto: leftSide trail: aTrail ].

	"{ 0 - x => -x }"
	(leftSide isZero) ifTrue: [ ^ self simplifyInto: (rightSide negated) trail: aTrail ].

	"Convert to zero .. { n - n = 0 }"
	(leftSide = rightSide) ifTrue: [ ^ MathExpNumber zero ].

	"{ a - (-b) => a + b } .. using negative/negated to do the work, but is not commutative"
	(rightSide strictlyNegative) ifTrue: [ ^ self simplifyInto: (leftSide + rightSide negated) trail: aTrail ].

	"{ a - x => -x + a } .. subtraction changes to addition so I track the change"
	self wantsSortedTerms ifTrue: [ ^ self simplifyInto: (self sortTermsIfNeeded) trail: aTrail ].

	"I reached here, allow the generic simplification to proceed.."
	^ super runSimplifyRulesTrailOn: aTrail.
]

{ #category : #converting }
MathExpSubtraction >> sortTermsIfNeeded [.
	"Simple { 4 - x } => { -x + 4 }. I keep track because is a new operation."
	^ self wantsSortedTerms ifTrue: [ ^ rightSide negated + leftSide ] ifFalse: [ ^ self ].
]

{ #category : #testing }
MathExpSubtraction >> wantsSortedTerms [
	"Ok, I know I am not associative or commutative.. but .. I still want to .."
	^ (leftSide termOrder) > (rightSide termOrder)
			and: [ self termOrder > (rightSide negated + leftSide) termOrder ].
]
