"
Class part: 

	Designed to hold numeric values. Simple eh? Not really... has variables, numbers, and mathematical constants that are universal as Pi or Euler Number.

	- Normally a simple number in an expression is written like { x + 2.115 }
	- Some numbers and many irrational numbers get a name to avoid writing them: { x + pi }
	- Some irrational numbers we don't give names, such as ""square of 2"" but we avoid writing them: { x + sqr(2) }
	- Sometimes we just assign a letter { a, b, c } for known values and last letters in the alphabet for unknown { x, y, z }
	- And then we contradict ourselves and use letters for known values { c = speed of light, e = Euler number, i = sqrt(-1) }

	Subclasses:
	* MathExpValue is an expression designed to hold a potential value inside an expression or formula
	* MathExpNumber is a integer/decimal number that we normally write in the expression.
	* MathUniversalConstant is a named constant such as Pi, Phi, 'e', etc. It prints itself as a symbol and only evaluate at the very end.
	* MathExpVariable is a symbol that we use inside an expression or formula, and we assign values to evaluate the whole expression.

Responsibility part:

	- Print itself the best, simplest way possible.
	- Keep a value and use when calling #asNumber.
	- Interact with the parser to recognise the name or the math symbol.
	- Most subclasses are number (decimal, imaginary, irrational or something similar) therefore the derivative is always zero.

Public API and Key Messages:

	Basically all the superclass and a few tweaks for the parser recognition and printing.

Internal Representation and Key Implementation Points:

	The value may be a construction parameter, or a fix universal number, or dynamic as in Variables. The good news is that you dont need to deal with it, the parser will do it for you.
"
Class {
	#name : #MathExpValue,
	#superclass : #MathExpression,
	#category : #'Mathemagics-Core-Base'
}

{ #category : #testing }
MathExpValue class >> isAbstract [
	^ self == MathExpValue.
]

{ #category : #comparing }
MathExpValue >> = anExpression [
	"For performance.."
	(self == anExpression) ifTrue: [ ^ true ].

	"For simplicity.. if someone passed a Number such as 5.. I convert it"
	(anExpression isKindOf: MathExpression) ifFalse: [ ^ self = (MathExpression safeguard: anExpression) ].

	"EXTENSION: I consider to compare different subclasses such as Constant and Variable if their value match"
	(anExpression isKindOf: MathExpValue "dont use 'self class'") ifFalse: [ ^ false ].

	"Allow comparing Constant PI with a Variable valued PI, that in Math is the same (as far as they are not nil)"
	(self isNumber & anExpression isNumber) ifTrue: [ ^ self asNumber = anExpression asNumber ].

	"Compare symbols maybe"
	^ self value = anExpression value.
]

{ #category : #converting }
MathExpValue >> asNumber [
	"Value is a number or nil. Nil means.. the variable is not set."
	self value isNumber ifTrue: [ ^ self value asNumber ].
	"You should have called the isNumber first."
	self error: 'Cannot reduce the expression to a number due to :' , self asString.
]

{ #category : #printing }
MathExpValue >> codeOn: aStream [
	"It will try to print the value except for variables."
	self utilMathSymbolCodedOn: aStream.
]

{ #category : #converting }
MathExpValue >> derivativeFor: aVariableExpression [
	"The derivative of a constant is always zero { dx(5) = 0.0 }"
	^ MathExpNumber zero.
]

{ #category : #comparing }
MathExpValue >> hash [
	"Please override"
	self subclassResponsibility.
]

{ #category : #testing }
MathExpValue >> isNumber [
	"Delegate to the attribute holding value"
	^ self value isNumber.
]

{ #category : #mathematics }
MathExpValue >> mathSymbolSmalltalk [
	"By default print the value (I may do things like 'Float pi' later)"
	^ self value.
]

{ #category : #printing }
MathExpValue >> printOn: aStream [
	"It will try to print the value except for variables."
	self utilMathSymbolPrintedOn: aStream.
]

{ #category : #converting }
MathExpValue >> replace: searchExpression with: replaceExpression [
	"Used to replace a subexpression for another."

	"Simple case, return replacement if required"
	(self = searchExpression) ifTrue: [ ^ replaceExpression ].

	"Otherwise I keep the current"
	^ self.
]

{ #category : #private }
MathExpValue >> runSimplifyRulesTrailOn: aTrail [
	"The Variables and Constants should continue to return themselves, nothing I can do."
	^ self convertToNumber: [ :result | (self value == result) ifTrue: [ self ] ifFalse: [ MathExpNumber value: result ] ].
]

{ #category : #evaluating }
MathExpValue >> value [
	"The whole point of this class"
	self subclassResponsibility.
]

{ #category : #accessing }
MathExpValue >> variables [
	"Should return a Set of variables from this expression downward. The default behaviour would be empty in case there are more subclasses one day."
	^ Set new.
]

{ #category : #printing }
MathExpValue >> wantsParenthesisUnder: parentExpression [
	"Does not respect priority (numbers have the lowest) so they dont use parenthesis { e^2 .. or .. pi*2 }"
	^ false.
]
