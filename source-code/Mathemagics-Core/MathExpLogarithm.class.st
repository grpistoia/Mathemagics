"
Class part:

	This class represents the logarithm of an expression. The base of the logarithm is normally a number, and therefore is considered a binary operation.
	There is this philosophical concept... is the 'ln' or 'log' looks like unary but is a written form of ' log{base e} ( x )'.
	In Smalltalk the base is on the 'right side' or the parameter of the message: { 8 log: 2 }	=> 3 since 2^3 = 8.

	That was done to keep consistency with { 100 log }	=> with the default base 10

	But is inconsistent with the typical Mathematical form: { LOG{base} Number }. For that reason I kept the same as in Mathematics, the 'left side' of the binary expression is the base, the 'right side' is the number.

		(MathExpression from: 'log(100)') asNumber.
		(MathExpression from: 'ln(e^2548)') simplify.

	On the parser side, although this is a binary construction, we normally use it as a function.
	For clarity purposes, the parser will expect 'logarithm' for N base. For instance: { MathExpression from: '4 logarithm 16' => 2 }
	The parser will automatically convert to another subclass for clarity purposes. For instance: { MathExpression from: 'e logarithm x' => ln(x) }

Properties:

	- Logarithm of 1 is always 0
	- Logarithm of a number on the same base is always 1
	- Logarithm does not support zero
	- Simplify itself if the base is the same as the number { ln(e^x) => x }
	- Logarithm of 1 is always zero  { log{a} (1) => 0 }
	- Logarithm base 'a' of 'a' is always one  { log{a} (a) => 1 }

Responsibility part:

	- Sending #isNumber, it will return true it can evaluate to number (inner Variables have a value assigned too)
	- Sending #simplify will reduce to zero when applied to 1 { log{a}(1) => 0 }
	- Sending #simplify will reduce to one when applied a number same as base { log{a}(1) => 0 }
	- Sending #simplify will reduce to the exponent when applied to a power same as the base { ln{a}(a^x) => x }
	- The derivative of this expression is { log{base}( u )' = u' / ( u * ln(base} ) }.
	- Notice any log derivative has ln(b). Therefore { ln(u) = 'u / (u * ln(base) ) = 'u / (u * ln(e) ) = 'u / u}

		(MathExpression from: 'log(x^2)') derivativeFor: 'x'.
		(MathExpression from: 'ln(x)') derivativeFor: $x.
"
Class {
	#name : #MathExpLogarithm,
	#superclass : #MathExpBinary,
	#category : #'Mathemagics-Core-FunctionsBasic'
}

{ #category : #'instance creation' }
MathExpLogarithm class >> base: aLeftExpression exponent: aRightExpression [
	"For clarity, just calls the standard constructor"
	^ self leftSide: aLeftExpression rightSide: aRightExpression.
]

{ #category : #testing }
MathExpLogarithm class >> isBuiltIn [
	"Tells if this logarithm comes in the VM like log or ln"
	^ (Number canUnderstand: self mathSymbol).
]

{ #category : #testing }
MathExpLogarithm class >> isFunction [
	"These expect parenthesis basically"
	^ self inheritsFrom: MathExpLogarithm.
]

{ #category : #testing }
MathExpLogarithm class >> isSingleTerm [
	"The Logarithm is binary { 8 log: 2 } but subclasses do not look like that { ln(8) }."
	^ self isFunction.
]

{ #category : #private }
MathExpLogarithm class >> leftSide: aLeftExpression rightSide: aRightExpression [
	"For consistency... I check here.."
	| base argument |
	base := MathExpression safeguard: aLeftExpression.
	argument := MathExpression safeguard: aRightExpression.

	"Mini creation pattern."
	("dont use self" MathExpLogarithm subclasses) do: [ 	:subClass |
		"Ensure the subclass was not manually created wrong { ln{10}(x) but log(x) }"
		(self ~= subClass) & (base = subClass logarithmBase) ifTrue: [
			"Create the subclass on each side.."
			^ subClass leftSide: base rightSide: argument
		].
	].

	"Whatever is the base and the expression"
	^ super leftSide: base rightSide: argument.
]

{ #category : #mathematics }
MathExpLogarithm class >> logarithmBase [
	"Subclasses should havea fix base .. at this level is unknown"
	self subclassResponsibility.
]

{ #category : #mathematics }
MathExpLogarithm class >> mathSymbol [
	"The smalltalk one is not standard #log: so I use a word"
	^ #logarithm.
]

{ #category : #mathematics }
MathExpLogarithm class >> mathSymbolSmalltalk [
	"This one is actually deprecated in Smalltalk but I overrode it for clarity.. pseudo compatible"
	^  #log:.
]

{ #category : #'instance creation' }
MathExpLogarithm class >> on: aValueOrExpression [
	"This constructor will create and set the subexpression to guarantee consistency."
	^ self leftSide: self logarithmBase rightSide: aValueOrExpression.
]

{ #category : #accessing }
MathExpLogarithm >> argument [
	"Just for clarity.."
	^ rightSide.
]

{ #category : #converting }
MathExpLogarithm >> asNumber [
	"Lazy evaluation, assumed called after isNumber."
	^ (rightSide asNumber) log: (leftSide asNumber).

	"NOTE: In Math we write { log(base)(expression) } but in Smalltalk is { expression log: base }."
	"The parser tries to accept as Mathematics, so it will expect the base first."
]

{ #category : #accessing }
MathExpLogarithm >> base [
	"Just for clarity.."
	^ leftSide.
]

{ #category : #printing }
MathExpLogarithm >> codeOn: aStream [
	"Basically.. is just binary except for cases like #ln we make it look unary."
	
	"Understands me?"
	(self class isBuiltIn) ifFalse: [ ^ super codeOn: aStream. ].

	"right side ..   8 log: 2  ... x ln"
	self utilCodeTerm: rightSide onto: aStream.
	"Put the mathematical symbol .. there is no need to write the base"
	self utilCodeSymbolOnto: aStream.
]

{ #category : #converting }
MathExpLogarithm >> derivativeFor: aVariableExpression [
	"dx(log{b} (u)) = dx(u) / (u * ln b)"

	| b u dxU dxFx |
	"Derivative of a constant is zero"
	self ifNumber: [ ^ MathExpNumber zero ].

	b := leftSide simplify.
	u := rightSide simplify.
	dxU := u derivativeFor: aVariableExpression.
	dxFx := (dxU) / ( u * ( b ln ) ).
	^ dxFx simplify.
]

{ #category : #testing }
MathExpLogarithm >> isNumber [
	"Is number as far as the denominator is not a zero, otherwise same as super"
	^ (super isNumber) and: [ (leftSide asNumber > 1.0) & (rightSide asNumber > 0.0) ].
]

{ #category : #printing }
MathExpLogarithm >> printOn: aStream [
	"For N-Based logarithm only.. put the number before.. and continue with the rest (slightly different than Power)"
	(self class isFunction) ifFalse: [
		self utilPrint: leftSide onto: aStream. "2"
		self utilPrintSpaceOn: aStream.
	].
	self utilMathSymbolPrintedOn: aStream. "log"
	self utilPrint: rightSide useParenthesis: true onto: aStream. "x"
]

{ #category : #private }
MathExpLogarithm >> runLogarithmSimplification [
	"to be 100% I can proceed"
	self assert: self supportLogarithmSimplification.
	"log{base}( base ^ x ) => x"
	^ rightSide rightSide.
]

{ #category : #private }
MathExpLogarithm >> runSimplifyRulesTrailOn: aTrail [
	"Specific to this operation, then default"

	"Notice this is priority... { log(0) } -> undefined."
	(self argument isZero) ifTrue: [ ^ MathExpUndefined new ].

	"{ log{a} (1) => 0 }"
	(self argument isOne) ifTrue: [ ^ MathExpNumber zero ].

	"{ log{a} (a) => 1 } .. logarithm in base 'a' of 'a' is 1.0"
	(self base = self argument) ifTrue: [ ^ MathExpNumber one ].

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]

{ #category : #testing }
MathExpLogarithm >> supportLogarithmSimplification [
	"log{base}( base ^ x ) => x"
	^ (rightSide isKindOf: MathExpPower) and: [ leftSide = rightSide leftSide ].
	
	"NOTE: Not using class comparison because of the subclasses"
]
