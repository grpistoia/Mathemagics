"
Class part:

	This class represents the negative sign in front of a Variable { -x } or a Function { - sin(x) } and normally parenthesis { -( x+1) }. Normally numeric constants { -( 5) } will simplify themselves without asking, but mathematical constants will remain the same { -pi }.

	Negative has a special case for the parser due to the ambiguity with Subtraction, using both the minus sign (-). This has been resolve with the minimum amount possible of IFs and special cases. It does therefore implement two mathSymbols { #- and #negated } to resolve internally that ambiguity.

Properties:

	- Supports many cases of negated expressions { - pi } .. { - sin(x) } .. { - ( x - 8 )  } .. { - ( - 5 ) }
	- Supports automated convertion to a numeric number when required { - ( 5 ) => -5 }
	- Supports the parser to prioritise the unary sign operator versus other operators { +4 + -6 => 4 - 6 }
	- Supports Maths priority of the unary sign that is higher than multiplication only lower to exponential { -3 ^ 2 = -(3^2) = -9 }

Responsibility part:

	- It will resolve by sending #negated standard Smalltalk message to the instance.
	- Sending #isNumber, it will return true if the subexpression can evaluate to number (inner Variables have a value assigned too)
	- Sending #simplify will reduce itself to when nested { - ( - ( x ) ) => x }
	- Sending #simplify will become part of the addition if  possible { - ( a + x ) = -a - b }
	- Sending #simplify will become part of the multiplication if  possible { - ( a * x ) = -a * b }
	- The derivative of this expression is the same as part of a subtraction { (0 - u) ' = 0' - u' = u' => ( - u )' = - u' }

Note: Negated allows to print the same parsed expression (evaluate without #simplify) and to resolve on demand (evaluate all below):

	(MathExpression from: ' - ( -1*3  - 5 * x ) ') simplify.		""Will return { 5*x - 3 }""

"
Class {
	#name : #MathExpNegative,
	#superclass : #MathExpUnary,
	#category : #'Mathemagics-Core-BasicOperators'
}

{ #category : #mathematics }
MathExpNegative class >> mathSymbol [
	"Same as subtraction, but normally is printed right next to the number or variable."
	^ #-.
]

{ #category : #mathematics }
MathExpNegative class >> mathSymbolSmalltalk [
	"Allows the parser to distinguish it"
	^ #negated.
]

{ #category : #mathematics }
MathExpNegative class >> precedence [
	"More than multiply but less than power, for instance { 2 * -3 } solves { -3 } first"
	^ MathExpMultiplication precedence + 1.

	"NOTE: Seems like { -2 ^ 4 } should be { 16 }, but in mathematics is considered that the expression is the same as { 0 - 2 ^ 4 }. Differs from Smalltalk/Excel."
]

{ #category : #converting }
MathExpNegative >> asNumber [
	"Lazy evaluation, assumed called after isNumber. If reached this point, the expression was not simplified, or contained a variable."
	^ subexpression asNumber negated.
]

{ #category : #printing }
MathExpNegative >> codeOn: aStream [
	"Same to printing really"
	| hasParenthesis |
	"Parenthesis may be needed"
	hasParenthesis := (subexpression wantsParenthesisUnder: self) | (subexpression class isBinaryOperator).

	"The sign, parenthesis, subexpression, parenthesis"
	hasParenthesis ifTrue: [ self utilPrintParenthesisBeginOn: aStream ].
	subexpression codeOn: aStream.
	self utilPrintSpaceOn: aStream.
	self utilMathSymbolCodedOn: aStream.
	hasParenthesis ifTrue: [ self utilPrintParenthesisEndOn: aStream ].
]

{ #category : #converting }
MathExpNegative >> derivativeFor: aVariableExpression [
	"dx(-u) = - dx(u)"

	| dxU dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	dxU := subexpression derivativeFor: aVariableExpression.
	dxFx := dxU negated.
	^ dxFx simplify.
]

{ #category : #converting }
MathExpNegative >> expand [
	"Usually special cases that as not associative or commutative { 3 + (5 - x) => 3 + 5 - x }"

	"- ( -x ) .. although normally self resolved"
	subexpression class = MathExpNegative ifTrue: [ ^ subexpression subexpression ].
	"- (a + b)"
	subexpression class = MathExpAddition ifTrue: [ ^ (subexpression leftSide negated) - (subexpression rightSide) ].
	"- (a - b)"
	subexpression class = MathExpSubtraction ifTrue: [ ^ (subexpression leftSide negated) + (subexpression rightSide) ].
	"- (a * b)"
	subexpression class = MathExpMultiplication ifTrue: [
		"Normally is written like { x * 2 }"
		(subexpression rightSide isNumber)
			ifTrue: [ ^ (subexpression leftSide) * (subexpression rightSide negated) ].
		(subexpression leftSide isNumber)
			ifFalse: [ ^ (subexpression leftSide negated) * (subexpression rightSide) ]
	].
	"- (a / b)"
	subexpression class = MathExpDivision ifTrue: [
		"Can have a number in the divident or divisor .. check "
		(subexpression leftSide isNotNumber) & (subexpression rightSide isNumber)
			ifTrue: [ ^ (subexpression leftSide) / (subexpression rightSide negated) ].
		(subexpression leftSide isNumber) & (subexpression rightSide isNotNumber)
			ifTrue: [ ^ (subexpression leftSide negated) / (subexpression rightSide) ]
	].

	"Only +-*/ are expandable but I let you add functions later"
	^ super expand.
]

{ #category : #testing }
MathExpNegative >> isExpandable [
	"Can pass it on to a subexpression"
	^ subexpression canRewriteCommutative.
]

{ #category : #mathematics }
MathExpNegative >> negated [
	"This ends up simplifying the expression, on the fly, before sending the simplify message { -(-x) => x }"
	^ subexpression.
]

{ #category : #printing }
MathExpNegative >> printOn: aStream [
	"Add a minus symbol to the expression but I may need parenthesis"

	"The sign, parenthesis, subexpression, parenthesis"
	self utilMathSymbolPrintedOn: aStream.
	self utilPrint: subexpression useParenthesis: (subexpression wantsParenthesisUnder: self) onto: aStream.
]

{ #category : #private }
MathExpNegative >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"{ - ( - ( a ) ) = a }"
	(subexpression class = self class) ifTrue: [ ^ self simplifyInto: (subexpression subexpression) trail: aTrail ].

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]

{ #category : #printing }
MathExpNegative >> wantsParenthesisUnder: parentExpression [
	"I personally dont like ifTrue:[^true] so I check and combine.."
	| result |
	"default"
	result := (super wantsParenthesisUnder: parentExpression).
	"- ( - x )"
	result := result or: [ parentExpression class == MathExpNegative ].
	"x - (-y)"
	result := result or: [ (parentExpression class == MathExpSubtraction) and: [ parentExpression rightSide == self ] ].
	^ result.
]
