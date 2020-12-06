"
Class part:

	This class represents the sum of two subexpressions (not necessarily just numbers).

Properties:

	- Supports associative property { (a + b) + c = a + (b + c) }
	- Supports commutative property { a + b = b + a }
	- Supports distributive property for multiplication { a * (b + c) = a * b + a * c }

Responsibility part:

	- Sending #isNumber, it will return true if both terms can evaluate to number (inner Variables have a value assigned too)
	- Sending #simplify will reduce itself to one term if the other equals zero { 0 + x = x + 0 => x }
	- Sending #simplify will become multiplication if the same term appears twice { x + x => 2 * x }
	- Sending #simplify the numbers will move to the end of the expression, same as in Polynomials, using commutative property { 3 + x => x + 3 }
	- The derivative of this expression is { ( u + v )' = u' + v' }

"
Class {
	#name : #MathExpAddition,
	#superclass : #MathExpBinary,
	#category : #'Mathemagics-Core-BasicOperators'
}

{ #category : #mathematics }
MathExpAddition class >> mathSymbol [
	^ #+.
]

{ #category : #mathematics }
MathExpAddition class >> precedence [
	"Addition and subtraction get precedence after the default"
	^ MathExpression precedence + 1.
]

{ #category : #converting }
MathExpAddition >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ (leftSide asNumber) + (rightSide asNumber).
]

{ #category : #converting }
MathExpAddition >> derivativeFor: aVariableExpression [
	"dx(u+v) = dx(u) + dx(v)"

	| u v dxU dxV dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := leftSide simplify.
	v := rightSide simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxV := v derivativeFor: aVariableExpression.
	dxFx := dxU + dxV.
	^ dxFx simplify.
]

{ #category : #converting }
MathExpAddition >> expand [
	"This is the opposite of Factoring"
	| binarySide unarySide |
	binarySide := leftSide class isBasicOperator ifTrue: [ leftSide ] ifFalse: [ rightSide ].
	unarySide := leftSide class isBasicOperator ifTrue: [ rightSide ] ifFalse: [ leftSide ].

	"a + (b + c)"
	binarySide isClassAddition ifTrue: [ ^ self commuteTerms ].
	"a + (b - c)"
	binarySide isClassSubtraction ifTrue: [ ^ self commuteTerms ].
	"a + (b * c)"
	binarySide isClassMultiplication ifTrue: [
		"x + (x * a) = (1+a)*x ... notice.. x^2 + (2 * x) does not works the same.. must be same power"
		(unarySide = binarySide leftSide) | (unarySide = binarySide rightSide) ifTrue: [ ^ self factorFromSum ].
	].
	"a + (b / c)"
	binarySide isClassDivision ifTrue: [
		"x + (x / a) = x * (1 + 1/a)"
		(unarySide = binarySide leftSide) ifTrue: [ ^ self factorFromSum ].
	].

	"Only +-*/ are expandable but I let you add functions later"
	^ super expand.
]

{ #category : #private }
MathExpAddition >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"{ x + 0 => x }"
	(rightSide isZero) ifTrue: [ ^ self simplifyInto: leftSide trail: aTrail ].

	"{ 0 + x => x } .. rarely used due to commutative"
	(leftSide isZero) ifTrue: [ ^ self simplifyInto: rightSide trail: aTrail ].

	"{ a + x => x + a }"
	self wantsSortedTerms ifTrue: [ ^ self sortTermsIfNeeded runSimplifyRulesTrailOn: aTrail ].

	"Convert to multiplication .. { n + n => 2*n }"
	((rightSide isNumericConstant not) and: [ leftSide = rightSide ])
		ifTrue: [ ^ self simplifyInto: (leftSide * MathExpNumber two) trail: aTrail ].

	"{ x + (-y) => x - y } (addition changes to subtraction)"
	(rightSide strictlyNegative)
		ifTrue: [ ^ self simplifyInto: (leftSide - rightSide negated) trail: aTrail ].

	"I reached here, allow the generic simplification to proceed.."
	^ super runSimplifyRulesTrailOn: aTrail.
]

{ #category : #converting }
MathExpAddition >> sortTermsIfNeeded [
	"Simple { 3 + x } => { x + 3 }. I dont track becuase is the same operation."
	self wantsSortedTerms ifTrue: [ | temp | temp := leftSide. leftSide := rightSide. rightSide := temp. ].
	"Notice it is still the same.."
	^ self.
]
