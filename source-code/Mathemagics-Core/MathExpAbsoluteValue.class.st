"
Class part:

	This class represents the trigonometric function ""absolute value"". Support a numeric value { abs(0.5) } or a mathematical constant { abs(pi) } or any other subexpression { abs(x) }.

	Notice this function is compatible with Smalltalk. Some say abs(0) should be undefined since zero is neither negative or positive. Smalltalk's abs return zero on zero, and this function will do the same. If you need differently you can implement a subclass. Another potential design is to keep track of the special considerations inside the expression itself.

Properties:

	- Understands that even Power cancel this operation { abs(x^2) => x^2 }.
	- Absolute of positive numbers also cancel this operation { abs(pi) = pi }.
	- Support some automated simplifications { abs(5) => 5 }.

		(MathExpression from: ' abs(pi) ').
		(MathExpression from: ' abs(pi) ') simplify.
		(MathExpression from: ' abs(+5) ') simplify.
		(MathExpression from: ' abs(-4) ') simplify.
		(MathExpression from: ' abs(-x) ') simplify.
		(MathExpression from: ' abs(-pi) ') simplify.

Responsibility part:

	- Sending #isNumber, it will return true if the subexpression can evaluate to number (inner Variables have a value assigned too)
	- The derivative of this expression is { abs( u )' = u' * u / abs(u) }
	
		(MathExpression from: ' abs(x-1) ') derivativeFor: 'x'.
		
"
Class {
	#name : #MathExpAbsoluteValue,
	#superclass : #MathExpUnary,
	#category : #'Mathemagics-Core-FunctionsBasic'
}

{ #category : #mathematics }
MathExpAbsoluteValue class >> mathSymbol [
	"The parenthesis are added later, and this is also used for parsing text"
	^ #abs.
]

{ #category : #converting }
MathExpAbsoluteValue >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ subexpression asNumber abs.
]

{ #category : #converting }
MathExpAbsoluteValue >> derivativeFor: aVariableExpression [
	"dx(abs(u)) = dx(u) * u / | u |"

	| u dxU dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	u := subexpression simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxFx := dxU * u / ( u abs ).
	^ dxFx simplify.
]

{ #category : #private }
MathExpAbsoluteValue >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"{ abs(Negative(fx()) = > abs(fx()) } in case fx() is negative"
	(subexpression class = MathExpNegative)
		ifTrue: [ ^ self simplifyInto: (subexpression subexpression abs) trail: aTrail ].

	"{ abs(K) <=> K >= 0 => K}"
	((subexpression isMathConstant) and: [ subexpression value positive ]) ifTrue: [ ^ subexpression ].

	"{ abs(+/-a) = a } .. when the value is just a number.. no need to keep it"
	(subexpression isNumericConstant) ifTrue: [ ^ MathExpNumber value: (subexpression value abs) ].

	"{ abs(x^2) = x^2 }"
	((subexpression isKindOf: MathExpPower) and: [ subexpression evenIntegerPower ])
		ifTrue: [ ^ self simplifyInto: subexpression trail: aTrail ].

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]
