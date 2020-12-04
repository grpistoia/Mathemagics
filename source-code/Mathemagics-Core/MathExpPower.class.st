"
Class part:

	This class represents the exponentiation of two subexpressions (not necessarily just numbers). Left side is the base, right side is exponent.

Properties:

	- Does NOT supports associative property { a ^ (b ^ x) != (a ^ b) ^ x }
	- Does NOT supports commutative property { x ^ a != a ^ x }
	- Does NOT resolve zero power to zero { 0 ^ 0 => Undefined }
	- Support special grouping exponents { (x ^ a) ^ b = x ^ (a * b) }
	- Support identify treatment
	- Implements the #degree function used for polynomials { x^2 + x + c } will answer: 2

Responsibility part:

	- Sending #isNumber, it will return true if both terms can evaluate to number (inner Variables have a value assigned too)
	- Sending #simplify will reduce itself to the base the exponent is 1 { x ^ 1 => x }
	- Sending #simplify will reduce itself to one if the base is 1 regardless of the exponent { 1 ^ n => 1 }
	- Sending #simplify will consume a negative sign when the power is even { (-x) ^ 4 => x ^ 4 }
	- Sending #simplify understands power and logarithm { e ^ ln(x)  => x }
	- The derivative of this expression is { ( u ^ v )' = ( u' * v * u^(v-1) ) + ( v' * ln(u) * u^v ) }

Note: As you can see, things get very complicated specially for derivatives:

	(MathExpression from: ' 5 * x ^ 3  - 1/2 * x ^ 2 + e^x') derivativeFor: 'x'.		""Will return { 15* x^2 - x + e^x }""
	
"
Class {
	#name : #MathExpPower,
	#superclass : #MathExpBinary,
	#category : #'Mathemagics-Core-BasicOperators'
}

{ #category : #'instance creation' }
MathExpPower class >> base: aLeftExpression exponent: aRightExpression [
	"For clarity, just calls the standard constructor"
	^ self leftSide: aLeftExpression rightSide: aRightExpression.
]

{ #category : #testing }
MathExpPower class >> isSingleTerm [
	"The Power is binary { x^y } but subclasses do not look like that { sqr(x) }."
	^ self inheritsFrom: MathExpPower. "dont use self-class"
]

{ #category : #private }
MathExpPower class >> leftSide: aLeftExpression rightSide: aRightExpression [
	"For consistency... I check here.."
	| base exponent |
	base := MathExpression safeguard: aLeftExpression.
	exponent := MathExpression safeguard: aRightExpression.

	"Nobody wants to see sqr(x) but the exponent is not 2, so if that happens, I changed to x^n"
	"I do tolerate someone saying sqr(x) to remain and nor forced to x^2 except on simplification later on"

	"You are square but the exponent is not 2 ?"
	(self = MathExpSqr and: [exponent ~= MathExpNumber two]) ifTrue: [ ^ base ** exponent ].

	"You are square but the exponent is not 1/2 ?"
	(self = MathExpSquareRoot and: [exponent ~= MathExpNumber oneHalf]) ifTrue: [ ^ base ** exponent ].

	"Is OK to go ahead"
	^ super leftSide: base rightSide: exponent.
]

{ #category : #mathematics }
MathExpPower class >> mathSymbol [
	^ $^. "I cant write #^ so return a char"
]

{ #category : #mathematics }
MathExpPower class >> mathSymbolSmalltalk [
	^ #**.  "Allows to enter ** and code this in a block"
]

{ #category : #mathematics }
MathExpPower class >> precedence [
	"More than multiplication, division and unary negative { 2 * -3 ^ 4 } resolves power first, then negative, then multiplication, then sums."
	^ MathExpNegative precedence + 1.
]

{ #category : #converting }
MathExpPower >> asNumber [
	"Lazy evaluation, assumed called after isNumber. Let it fail if dividing raising zero to zero, you should check isNumber."
	^ (leftSide asNumber) raisedTo: (rightSide asNumber).
]

{ #category : #converting }
MathExpPower >> asPower [
	"I am a Power already"
	^ self.
]

{ #category : #accessing }
MathExpPower >> base [
	"Just for clarity.."
	^ leftSide.
]

{ #category : #mathematics }
MathExpPower >> degree [
	"Of course this overwrites the binary default behaviour. But only consider variables { x^3 } returns 3, but { 2^3 } doesnt"
	(leftSide isNotNumber) & (rightSide isNumber) ifTrue: [ ^ rightSide asNumber ].

	"Default behavior... basically undefined"
	^ super degree.
]

{ #category : #converting }
MathExpPower >> derivativeFor: aVariableExpression [
	"dx(u^v) = ( dx(u) * v * u^(v-1) ) + ( dx(v) * ln u * u^v ) = term1 + term2"

	| u v dxU dxV term1 term2 dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := leftSide simplify.
	v := rightSide simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxV := v derivativeFor: aVariableExpression.
	term1 := dxU * (v * (u ** (v - MathExpNumber one))).
	term2 := dxV * ((u ln) * (u ** v)).
	dxFx := (term1 simplify) + (term2 simplify). "saves some time simplifying.."
	^ dxFx simplify.
]

{ #category : #converting }
MathExpPower >> evenIntegerPower [
	"x^2 or x^4 .. etc.. meaning.. results is always positive"
	^ self exponent even and: [ self exponent asNumber isInteger ].
]

{ #category : #accessing }
MathExpPower >> exponent [
	"Just for clarity.."
	^ rightSide.
]

{ #category : #testing }
MathExpPower >> isNumber [
	"Power to a fraction"
	"Is number as far as the base and exponent are not both zero, otherwise it will crash"
	^ (super isNumber) and: [ (leftSide isNotZero) and: [ rightSide isNotZero ] ].
]

{ #category : #converting }
MathExpPower >> negativeIntegerPower [
	"x^-2 = 1/(x^2)"
	^ self exponent negative and: [ self exponent asNumber isInteger ].
]

{ #category : #printing }
MathExpPower >> printOn: aStream [
	"If I am power.. do the same as my superclass"
	(self class isFunction) ifFalse: [ ^ super printOn: aStream ].

	"Power did x^y, but here.. they behave like unary because we make it simpler to write"
	self utilMathSymbolPrintedOn: aStream. "sqr"
	self utilPrint: leftSide useParenthesis: true onto: aStream. "x"
]

{ #category : #testing }
MathExpPower >> runLogarithmSimplification [
	"to be 100% I can proceed"
	self assert: self supportLogarithmSimplification.
	"base ^ ( log{base}(x) ) => x"
	^ rightSide rightSide.
]

{ #category : #converting }
MathExpPower >> runPowerSimplification [
	| leftAsPower base leftExponent rightExponent |
	"to be 100% I can proceed"
	self assert: self supportPowerSimplification.

	"I am already in Power class but for consistency with other similar methods"
	leftAsPower := leftSide asPower.  "the base is the existing Power"

	"build the new expression"
	base := leftAsPower leftSide.
	leftExponent := leftAsPower rightSide.
	rightExponent := rightSide.

	"(x^n) ^ m => x^(n*m)"
	^ base ** (leftExponent * rightExponent).
]

{ #category : #private }
MathExpPower >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"Notice this is priority... { 0^0 } -> undefined."
	(self base isZero & self exponent isZero) ifTrue: [ ^ MathExpUndefined new ].

	"{ 0 raisedTo: 5 => 0 }"
	(self base isZero) ifTrue: [ ^ MathExpNumber zero ].

	"{ 1 raisedTo: 5 => 1 }"
	(self base isOne) ifTrue: [ ^ MathExpNumber one ].

	"{ 4 raisedTo: 0 => 1 }"
	(self exponent isZero) ifTrue: [ ^ MathExpNumber one ].

	"{ 10 raisedTo: 1 => 10 }"
	(self exponent isOne) ifTrue: [ ^ self simplifyInto: (self base) trail: aTrail ].

	"{ x raisedTo: -4 => 1/(x^4) }"
	(self negativeIntegerPower)
		ifTrue: [ ^ self simplifyInto: ((self base ** (self exponent negated)) reciprocal) trail: aTrail ].

	"{ (-4) raisedTo: evenNumber => +4 ^ evenNumber }. Notice the logic below supports (-x)^2 => x^2"
	(self evenIntegerPower and: [ self base strictlyNegative ])
		ifTrue: [ ^ self simplifyInto: (self base negated ** self exponent) trail: aTrail ].

	"You are x**0.5 best show sqrt(x)"
	(self class ~= MathExpSquareRoot & self exponent isNumber
		and: [self exponent asNumber = MathExpNumber oneHalf asNumber])
		ifTrue: [ ^ self simplifyInto: (self base squareRoot ) trail: aTrail ].

	"I reached here, allow the generic simplification to proceed.."
	^ super runSimplifyRulesTrailOn: aTrail.
]

{ #category : #testing }
MathExpPower >> supportLogarithmSimplification [
	"base ^ ( log{base}(x) ) => x"
	^ (rightSide isKindOf: MathExpLogarithm) and: [ leftSide = rightSide leftSide ].
]

{ #category : #testing }
MathExpPower >> supportPowerSimplification [
	"(x^n) ^ m => x^(n^m)"
	^ (leftSide isKindOf: self class).
]

{ #category : #mathematics }
MathExpPower >> termOrder [
	"This one is really the core, since mostly this is polinomials."
	| combinedTermOrder |
	"Check superclass for more information"
	combinedTermOrder := leftSide termOrder , rightSide termOrder.
	"x^?  .. goes first"
	leftSide ifNotNumber: [ ^ 'A' , combinedTermOrder ].
	 "n^x .. goes after "
	rightSide ifNotNumber: [ ^ 'C' , combinedTermOrder ].
	"a^b goes last since is constant"
	^ 'J' , combinedTermOrder.
]
