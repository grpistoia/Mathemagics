"
Class part:

	This class represents the division of two subexpressions (not necessarily just numbers).

Properties:

	- Does NOT supports associative property
	- Does NOT supports commutative property
	- Overrides #reciprocal
	- Support identify treatment
	- Supports similar distributive property for multiplication { a * (b / x) = (a * b) / x }
	- Supports special case of fraction of fractions { (a / b) / (c / d) => (a * d) / (b * c) }

Responsibility part:

	- Sending #isNumber, it will return true if both terms can evaluate to number (inner Variables have a value assigned too)
	- Sending #simplify will reduce itself to the numerator if the denominator is 1 { x / 1 => x }
	- Sending #simplify will reduce itself to the negative numerator if the denominator is -1 { x / -1 => -x }
	- Sending #simplify will reduce itself to zero if the numerator is 0 if the denominator is not zero { 0 / x => 0 } { ==> x != 0 }
	- Sending #simplify will become 1 if the numerator is the same as the denominator and not zeroes { x / x => 1 } { ==> x != 0 }
	- The derivative of this expression is { ( u / v )' = ( u' * v - u * v' ) / v^2 }	
"
Class {
	#name : #MathExpDivision,
	#superclass : #MathExpBinary,
	#category : #'Mathemagics-Core-BasicOperators'
}

{ #category : #'instance creation' }
MathExpDivision class >> dividend: aLeftExpression divisor: aRightExpression [
	"For clarity, just calls the standard constructor"
	^ self leftSide: aLeftExpression rightSide: aRightExpression.
]

{ #category : #mathematics }
MathExpDivision class >> mathSymbol [
	^ #/.
]

{ #category : #mathematics }
MathExpDivision class >> precedence [
	"Same as multiplying, meaning the order is left to right"
	^ MathExpMultiplication precedence.
]

{ #category : #converting }
MathExpDivision >> asCommutative [
	"Division can change to product { a/x => a * x^(-1) .. but 1/x => x^(-1) }"
	^ self asProduct.
]

{ #category : #converting }
MathExpDivision >> asFraction [
	"I am a fraction already"
	^ self.
]

{ #category : #converting }
MathExpDivision >> asNumber [
	"Lazy evaluation, assumed called after isNumber. Let it fail if dividing by zero, you should check isNumber."
	^ (leftSide asNumber) / (rightSide asNumber).
]

{ #category : #converting }
MathExpDivision >> asPower [
	"My callers expect a Power.. but.. basically.. { 1/x = x^-1} .. { 1/x^3 = x^-3} .. { 5/x^4 = 5*x^-4}"
	(self dividend isOne) ifTrue: [
		| powerUp |
		"first strip the divisor and.. imagine.. is a power"
		powerUp := self divisor asPower. "this may return x^1"
		"convert.."
		^ powerUp base ** (powerUp exponent negated).
	] ifFalse: [
		"Return  power... tough luck"
		^ self ** 1.
	].
]

{ #category : #converting }
MathExpDivision >> asProduct [
	"With 'Product' means Multiplication. This is another trick to help simplification: x/y = x*1/y = x*y^-1."
	^ leftSide * (rightSide reciprocal).
]

{ #category : #converting }
MathExpDivision >> derivativeFor: aVariableExpression [
	"dx(u/v) = (dx(u) * v - u * dx(v)) / v^2"

	| u v dxU dxV dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := leftSide simplify.
	v := rightSide simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxV := v derivativeFor: aVariableExpression.
	dxFx := ((dxU * v) - (u * dxV)) / (v ** MathExpNumber two).
	^ dxFx simplify.
]

{ #category : #accessing }
MathExpDivision >> dividend [
	"Just for clarity.."
	^ leftSide.
]

{ #category : #accessing }
MathExpDivision >> divisor [
	"Just for clarity.."
	^ rightSide
]

{ #category : #converting }
MathExpDivision >> expand [
	"This is the opposite of Factoring"
	| binarySide unarySide |
	binarySide := leftSide class isBasicOperator ifTrue: [ leftSide ] ifFalse: [ rightSide ].
	unarySide := leftSide class isBasicOperator ifTrue: [ rightSide ] ifFalse: [ leftSide ].

	"a / (b + c)"
	binarySide isClassAddition ifTrue: [ ^ self ]. "Nothing to do"
	"a / (b - c)"
	binarySide isClassSubtraction ifTrue: [ ^ self ]. "Nothing to do"
	"a / (b * c)"
	binarySide isClassMultiplication ifTrue: [
		"because is not commutative"
		(rightSide == binarySide)
		"x / (b * y) = (x/y) * (1/b) = (x/y) / b"
		ifTrue: [
			(unarySide relatedTo: binarySide leftSide) ifTrue: [ ^ (unarySide / binarySide leftSide) / (binarySide rightSide) ].
			(unarySide relatedTo: binarySide rightSide) ifTrue: [ ^ (unarySide / binarySide rightSide) / (binarySide leftSide) ].
		]
		"(b * x) / y = (x/y) * b"
		ifFalse: [
			(unarySide relatedTo: binarySide leftSide) ifTrue: [ ^ (binarySide leftSide / unarySide) * (binarySide rightSide) ].
			(unarySide relatedTo: binarySide rightSide) ifTrue: [ ^ (binarySide rightSide / unarySide) * (binarySide leftSide) ].
		].
	].
	"a / (b / c)"
	binarySide isClassDivision ifTrue: [
		"because is not commutative"
		(rightSide == binarySide)
		"a / (b / c) = (a / 1) / (b / c) = (a*c) / b"
		ifTrue: [
			^ (unarySide * binarySide rightSide) / (binarySide leftSide).
		]
		"(b / c) / a = (b / c) / (a / 1) = b / (a*c)"
		ifFalse: [
			^ (binarySide leftSide) / (unarySide * binarySide rightSide).
		]
	].

	"Only +-*/ are expandable but I let you add functions later"
	^ super expand.
]

{ #category : #testing }
MathExpDivision >> isNumber [
	"Is number as far as the denominator is not a zero, otherwise same as super"
	^ super isNumber and: [ rightSide isNotZero ].
]

{ #category : #mathematics }
MathExpDivision >> reciprocal [
	"Same as in Fraction .. save simplification by swapping numerator by denominator"
	^ rightSide / leftSide.

	"NOTE: Once more, I assume the numerator was not zero"
]

{ #category : #converting }
MathExpDivision >> runDivisionOfFractions [
	"Deals with cases such as { (a / b) / (c / d) => (a*d) / (c*b) }"
	| theNumerator theDenominator a b c d |

	theNumerator := leftSide asFraction.
	theDenominator := rightSide asFraction.

	a := theNumerator leftSide.
	b := theNumerator rightSide.
	c := theDenominator leftSide.
	d := theDenominator rightSide.

	^ (a * d) / (b * c).

	"NOTE: I dont use assert because actually it will still work for anything, since asFraction takes care of missing divisions"
]

{ #category : #converting }
MathExpDivision >> runDivisionOfProducts [
	"Deals with cases such as { (a * b) / (c * d) => (a/c) * (b/d) }"
	| theNumerator theDenominator a b c d |

	"this bit.. if you have something like { (x * y) / y } becomes.. { (x * y) / (y * 1) } "
	theNumerator := leftSide asProduct.
	theDenominator := rightSide asProduct.

	a := theNumerator leftSide asPower.  " x => x^1"
	b := theNumerator rightSide asPower.  " y => y^1"
	c := theDenominator leftSide reciprocal asPower.  " y => y^-1"
	d := theDenominator rightSide reciprocal asPower.  " 1 => 1^-1"

	"(a / c) * (b / d) = a^1 * c^-1 * b^1 * d^-1.. why? x ^ n * x ^ m = x  ^ (n+m)."
	"Turn to multiplication of powers.. that keep shape and reduce duplicates"
	^ ((a * c) * (b * d)) commuteTerms.

	"NOTE: I dont use assert because actually it will still work for anything, since asFraction takes care of missing divisions"
]

{ #category : #converting }
MathExpDivision >> runPowerSimplification [
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

	"x^n / x^m => x^(n-m)"
	^ base ** (leftExponent - rightExponent).
]

{ #category : #private }
MathExpDivision >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"Notice this is priority... { x/0 } -> undefined."
	(rightSide isZero) ifTrue: [ ^ MathExpUndefined new ].

	"{ 0 / x => 0  <=> x <> 0 }"
	(leftSide isZero) ifTrue: [ ^ MathExpNumber zero ].

	"{ x / 1 => x }"
	(rightSide isOne) ifTrue: [ ^ self simplifyInto: leftSide trail: aTrail ].

	"{ x / -1 => -x }"
	(rightSide isMinusOne) ifTrue: [ ^ self simplifyInto: (leftSide negated) trail: aTrail ].

	"{ a / -x => -a / x } .. by now I know the number is on the left side"
	(rightSide isNotNumber and: [ rightSide strictlyNegative ])
		ifTrue: [ ^ self simplifyInto: (leftSide negated / rightSide negated) trail: aTrail ].

	"{ (-x) / y => -(x / y) } .. I may simplify futher, for instance { -(x / x) }"
	(leftSide isNotNumber and: [ leftSide strictlyNegative ])
		ifTrue: [ ^ self simplifyInto: ((leftSide negated / rightSide) negated) trail: aTrail ].

	"final attempt"
	^ super runSimplifyRulesTrailOn: aTrail.
]

{ #category : #testing }
MathExpDivision >> supportDivisionOfFractions [
	"(a / b) / (c / d) => (a * d) / (b * c)"
	| theNumerator theDenominator a b c d |

	"One has to be a division"
	(leftSide isClassDivision) | (rightSide isClassDivision) ifFalse: [ ^ false ] .

	theNumerator := leftSide asFraction.
	theDenominator := rightSide asFraction.

	a := theNumerator leftSide.
	b := theNumerator rightSide.
	c := theDenominator leftSide.
	d := theDenominator rightSide.

	"Is there any term getting better after?.."
	^ 	((a relatedTo: b) not & (a relatedTo: d)) | ((c relatedTo: d) not & (b relatedTo: c)).
]

{ #category : #testing }
MathExpDivision >> supportDivisionOfProducts [
	"Deals with cases such as { (a * b) / (c * d) => (a/c) * (b/d) or (a/d) * (b/c) }"
	| theNumerator theDenominator a b c d |

	"One has to be binary.. may be multiplication or power or something"
	(leftSide isClassMultiplication) | (rightSide isClassMultiplication) ifFalse: [ ^ false ] .

	theNumerator := leftSide asProduct.
	theDenominator := rightSide asProduct.

	a := theNumerator leftSide.
	b := theNumerator rightSide.
	c := theDenominator leftSide.
	d := theDenominator rightSide.

	"Is there any term getting better after?.."
	^ 	((a relatedTo: c) and: [ theNumerator termOrder >= (a / c) termOrder ])
		|
		((a relatedTo: d) and: [ theNumerator termOrder >= (a / d) termOrder ])
		|
		((b relatedTo: d) and: [ theDenominator termOrder >= (b / d) termOrder ])
		|
		((b relatedTo: c) and: [ theDenominator termOrder >= (b / c) termOrder ])
]

{ #category : #testing }
MathExpDivision >> supportPowerSimplification [
	"x^n / x^m => x^(n-m)"
	^ (leftSide asPower leftSide) = (rightSide asPower leftSide).
]
