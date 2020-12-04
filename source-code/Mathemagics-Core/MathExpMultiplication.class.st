"
Class part:

	This class represents the multiplication of two subexpressions (not necessarily just numbers).

Properties:

	- Supports associative property { a * (b * x) = (a * b) * x }
	- Supports commutative property { x * a = a * x }
	- Supports distributive property over addition and subtraction { a * (b + x) = a * b + a * x => a*x + c }
	- Support identify treatment
	- In constrast with addition which normally is expressed { x + a } the multiplication writes variables last { a * x }

Responsibility part:

	- Sending #isNumber, it will return true if both terms can evaluate to number (inner Variables have a value assigned too)
	- Sending #simplify will reduce itself if one of the terms is 1 { x * 1 => x }
	- Sending #simplify will reduce itself to the negated term if one is -1 { x * -1 => -x }
	- Sending #simplify will reduce itself to zero if one term is zero { 0 * x => 0 }
	- Sending #simplify will become a power if both terms are the same { x * x => x^2 }
	- The derivative of this expression is { ( u * v )' = ( u' * v ) + ( u * v' ) }

"
Class {
	#name : #MathExpMultiplication,
	#superclass : #MathExpBinary,
	#category : #'Mathemagics-Core-BasicOperators'
}

{ #category : #mathematics }
MathExpMultiplication class >> mathSymbol [
	^ #*.
]

{ #category : #mathematics }
MathExpMultiplication class >> mathSymbolPro [
	"Originally I put the little 'x' (Unicode value: 16r00D7) but is confusing with variables"
	^ Unicode value: 16r00B7.
]

{ #category : #'instance creation' }
MathExpMultiplication class >> multiplier: aLeftExpression multiplicand: aRightExpression [
	"For clarity, just calls the standard constructor"
	^ self leftSide: aLeftExpression rightSide: aRightExpression.
]

{ #category : #mathematics }
MathExpMultiplication class >> precedence [
	"Higher than addition"
	^ MathExpAddition precedence + 1.
]

{ #category : #converting }
MathExpMultiplication >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ (leftSide asNumber) * (rightSide asNumber).
]

{ #category : #converting }
MathExpMultiplication >> asProduct [
	"I am a product already, but ensure is sorted to reduce simplification"
	^ self sortTermsIfNeeded.
]

{ #category : #converting }
MathExpMultiplication >> derivativeFor: aVariableExpression [
	"dx(u*v) = (dx(u) * v) + (u * dx(v))"

	| u v dxU dxV dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := leftSide simplify.
	v := rightSide simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxV := v derivativeFor: aVariableExpression.
	dxFx := (dxU * v) + (u * dxV).
	^ dxFx simplify.
]

{ #category : #converting }
MathExpMultiplication >> expand [
	"This is the opposite of Factoring"
	| binarySide unarySide |
	binarySide := leftSide class isBasicOperator ifTrue: [ leftSide ] ifFalse: [ rightSide ].
	unarySide := leftSide class isBasicOperator ifTrue: [ rightSide ] ifFalse: [ leftSide ].

	self assert: self isCommutative.

	"a * (b + c)"
	binarySide class = MathExpAddition ifTrue: [ ^ (binarySide leftSide * unarySide) + (binarySide rightSide * unarySide) ].
	"a * (b - c)"
	binarySide class = MathExpSubtraction ifTrue: [ ^ (binarySide leftSide * unarySide) - (binarySide rightSide * unarySide) ].
	"a * (b * c)"
	binarySide class = MathExpMultiplication ifTrue: [ ^ self commuteTerms ].
	"a * (b / c)"
	binarySide class = MathExpDivision ifTrue: [ ^ (binarySide leftSide * unarySide) / (binarySide rightSide) ].

	"Only +-*/ are expandable but I let you add functions later"
	^ super expand.
]

{ #category : #accessing }
MathExpMultiplication >> multiplicand [
	"Just for clarity.."
	^ self rightSide
]

{ #category : #accessing }
MathExpMultiplication >> multiplier [
	"Just for clarity.."
	^ self leftSide
]

{ #category : #printing }
MathExpMultiplication >> printOn: aStream [
	"Because humans like complicating life, we print the numbers before variables in cases like { x * 3 }"
	| conditionToSwap |

	"Check one is number and the other is not. Cases like { 3 * 6 } or { x * y } remain the same"
	conditionToSwap := self settings numbersLeadProducts.
	"conditionToSwap := conditionToSwap and: [ leftSide isNotNumber ]. if says pi*8 still swaps"
	conditionToSwap := conditionToSwap and: [ rightSide isNumber ].
	conditionToSwap := conditionToSwap and: [ leftSide termOrder < rightSide termOrder ].

	conditionToSwap
		ifTrue: [ self printLeft: rightSide printRight: leftSide On: aStream ]
		ifFalse: [ self printLeft: leftSide printRight: rightSide On: aStream ].
]

{ #category : #private }
MathExpMultiplication >> runPowerSimplification [
	| leftAsPower rightAsPower base leftExponent rightExponent |
	"to be 100% I can proceed"
	self assert: self supportPowerSimplification.

	"I will use powers.. so do it once"
	leftAsPower := leftSide asPower.
	rightAsPower := rightSide asPower.

	"build the new expression"
	base := leftAsPower leftSide.
	leftExponent := leftAsPower rightSide.
	rightExponent := rightAsPower rightSide.

	"x^n * x^m => x^(n+m)"
	^ base ** (leftExponent + rightExponent).
]

{ #category : #private }
MathExpMultiplication >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"{ x * 0 = 0 * x => 0 }"
	(rightSide isZero | leftSide isZero) ifTrue: [ ^ MathExpNumber zero ].

	"{ x * 1 => x }"
	(rightSide isOne) ifTrue: [ ^ self simplifyInto: leftSide trail: aTrail ].

	"{ 1 * x => x } .. some cases speed up.."
	(leftSide isOne) ifTrue: [ ^ self simplifyInto: rightSide trail: aTrail ].

	"{ a * x => x * a } .. (variables always left)"
	self wantsSortedTerms ifTrue: [ ^ self sortTermsIfNeeded runSimplifyRulesTrailOn: aTrail ].

	"{ x * -1 => -x }"
	(rightSide isMinusOne and: [ self isExpandable not]) ifTrue: [ ^ self simplifyInto: (leftSide negated) trail: aTrail ].

	"{ -(x) * n => x * -n } .. by now I know the number is on the left side"
	(leftSide strictlyNegative) ifTrue: [ ^ self simplifyInto: (leftSide negated * rightSide negated) trail: aTrail ].

	"I reached here, allow the generic simplification to proceed.."
	^ super runSimplifyRulesTrailOn: aTrail.
]

{ #category : #converting }
MathExpMultiplication >> sortTermsIfNeeded [
	"Simple { 2 * x } => { x * 2 }. I dont track becuase is the same operation."
	self wantsSortedTerms ifTrue: [ | temp | temp := leftSide. leftSide := rightSide. rightSide := temp. ].
	"Notice it is still the same.."
	^ self.
]

{ #category : #testing }
MathExpMultiplication >> supportPowerSimplification [
	"x^n * x^m => x^(n+m)"
	^ (leftSide asPower leftSide) = (rightSide asPower leftSide).
]
