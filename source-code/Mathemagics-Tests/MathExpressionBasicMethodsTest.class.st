"
My responsability is to test the mathematical expressions.

I focus on loose single methods, not in the subclasses of the mathematical expression tree.

Simple math methods (+|-|/|*|=) were already tested, no need to repeat.
"
Class {
	#name : #MathExpressionBasicMethodsTest,
	#superclass : #MathExpressionBaseTest,
	#category : #'Mathemagics-Tests-Expressions'
}

{ #category : #tests }
MathExpressionBasicMethodsTest >> testAsBlock [
	| fx bk |
	"The comparison of blocks didnt quite work here.. probably some context that I dont need to compare, so I do as Strings"
	fx := MathExpression from: 'sin(pi/2) * 8'.
	bk := [ (Float pi / 2) sin * 8 ].
	self assert: fx asBlock asString equals: bk asString.

	"Surprise! .. Sin(pi/2) = 1.0"
	self assert: fx simplify asBlock asString equals: [ 8 ] asString.

	"With one variable.. (not using 'x' because is an attribute of this class for testing"
	fx := MathExpression from: 'sin(z) + 987'.
	self assert: fx asBlock asString equals: [ :z | z sin + 987 ] asString.

	"With one variable used twice"
	fx := MathExpression from: 'sin(z) + z^2'.
	self assert: fx asBlock asString equals: [ :z | z sin + (z ** 2) ] asString.

	"More variables.. (and I will assume more than 2 continues to work)"
	fx := MathExpression from: 'sin(n) + m^2 + 8*o'.
	self assert: fx asBlock asString equals: [ :m :n :o | n sin + (m ** 2) + (8*o) ] asString.

	"Log is a bit special.. (ln, log, log:)"
	fx := MathExpLogarithm leftSide: MathExpNumber eight rightSide: MathExpNumber two.
	self assert: fx asBlock asString equals: [ 8 log: 2 ] asString.

	"Log is a bit special.. (ln, log, log:)"
	fx := MathExpLogarithm leftSide: 10 rightSide: (MathExpVariable symbol: #v).
	self assert: fx asBlock asString equals: [ :v | v log ] asString.
	fx := (MathExpVariable symbol: #w) log.
	self assert: fx asBlock asString equals: [ :w | w log ] asString.

	"Log is a bit special.. (ln, log, log:)"
	fx := MathExpLogarithm leftSide: e rightSide: (MathExpVariable symbol: $v).
	self assert: fx asBlock asString equals: [ :v | v ln ] asString.
	fx := (MathExpVariable symbol: $w) ln.
	self assert: fx asBlock asString equals: [ :w | w ln ] asString.

	"Square root now supported"
	fx := (MathExpVariable symbol: $w) sqrt.
	self assert: fx asBlock asString equals: [ :w | w sqrt ] asString.

	"Sqr now supported"
	fx := (MathExpVariable symbol: $w) sqr.
	self assert: fx asBlock asString equals: [ :w | w squared ] asString.

	"Similar to squared"
	fx := (MathExpVariable symbol: $z) ** 2.
	self assert: fx asBlock asString equals: [ :z | z ** 2 ] asString.
	
	"Squared now supported"
	fx := (MathExpVariable symbol: $w) squared.
	self assert: fx asBlock asString equals: [ :w | w ** 2 ] asString.

	"Cubed now supported"
	fx := (MathExpVariable symbol: $w) cubed.
	self assert: fx asBlock asString equals: [ :w | w ** 3 ] asString.


]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testAsFraction [
	| fx |
	"Try non fraction"
	fx := x asFraction.
	self assert: fx equals: x / MathExpNumber one.

	"Function non fraction"
	fx := x cos asFraction.
	self assert: fx equals: (x cos) / MathExpNumber one.

	"Variable fraction return itself"
	fx := (x / y) asFraction.
	self assert: fx equals: x / y.

	"Return itself"
	fx := (x / 8) asFraction.
	self assert: fx equals: x / 8.

	"Reciprocal return itself"
	fx := (MathExpNumber two / MathExpNumber three) asFraction.
	self assert: fx equals: MathExpNumber two / 3.

	"Two number divided.. remain like that or .. becomes real Fraction?"
	fx := ((x ** 2) reciprocal) asFraction.
	self assert: fx equals: MathExpNumber one / (x ** 2).

	"Same but from parser"
	fx := MathExpression from: 'cos(pi) / sin(x)'.
	x := fx variable: 'x'.
	self assert: fx equals: pi cos / (x sin).
	self assert: fx isNumber not.
	self assert: (fx variables size) equals: 1.
	self assert: (fx variables includes: x).
]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testAsMathExpression [
	| fx |

	(Number canUnderstand: #asMathExpression) ifFalse: [ ^ self ].

	"Building an expression return itself"
	fx := x reciprocal * 8 / (y sin).
	self assert: fx asMathExpression equals: fx.
	self assert: fx asMathExpression equals: fx.

	"Same but from parser"
	fx := MathExpression from: 'x ^ 4 - 1234.56789'.
	self assert: fx asMathExpression equals: fx.
	self assert: fx asMathExpression equals: fx.

	"Depends if the user installed this (is not compulsory)"
	fx := 8 asMathExpression * x.
	self assert: fx asMathExpression equals: fx.
	self assert: fx asMathExpression equals: fx.
]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testAsNumber [
	| fx |
	"Already tested before anyway"
	fx := MathExpNumber one + (MathExpNumber two * MathExpNumber three * MathExpNumber four * MathExpNumber five).
	self assert: fx asNumber equals: 1 + (2 * 3 * 4 * 5).

	"Depends if the user installed this (is not compulsory)"
	fx := MathExpression from: 'sin(pi/2) * 8'.
	self assert: fx asNumber equals: ((Float pi / 2) sin * 8) asNumber.
]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testDegree [
	| fx |
	"Add x(s)"
	fx := MathExpression from: '8'.
	self assert: fx degree equals: 0.

	fx := MathExpression from: 'sin(pi)'.
	self assert: fx degree equals: 0.

	fx := MathExpression from: 'x - 9'.
	self assert: fx degree equals: 1.

	fx := MathExpression from: 'x^2 - 9'.
	self assert: fx degree equals: 2.

	fx := MathExpression from: 'x^2 - x'.
	self assert: fx degree equals: 2.

	fx := MathExpression from: 'x^2 + x^3'.
	self assert: fx degree equals: 3.

	fx := MathExpression from: 'x^2 / x^3'. "I havent simplified it yet.. so.. remains 3.. right?"
	self assert: fx degree equals: 3.
]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testEvaluateWith [
	| blocky fx halfPiPlus |
	
	"build a function having x"
	fx := MathExpression from: 'x ^ 3 + 5 * x ** 2 - 6'.
	self assert: (fx variable: $x) equals: x.
	self assert: (fx variables includes: x).
	"Just to show.. complex formulas are not as simple as they look in a block"
	blocky := [ :w | w ** 3 + (w ** 2 * 5) - 6 ].
	self assert: (fx evaluate: 'x' with: 4) asNumber equals: (blocky value: 4).

	"Actually this should also work even though is.. really pointless because I have the variable already"
	fx := (x ** 3) + (MathExpNumber five * (x ** 2) - 6).
	self assert: (fx variables includes: x).
	self assert: (fx variable: $x) equals: x.
	"Surely should work.. surely.."
	self assert: (fx evaluate: 'x' with: 7) asNumber equals: ( (7 ** 3) + (7 ** 2 * 5) - 6 ).
	
	"Tricky ones.. "
	fx := (two * (x**two)) + (five * x) + (x cos).
	self assert: (fx evaluate: #x with: 40) asNumber equals: 3400 + (40 - (12 * Float pi)) cos.
	
	"Tricky ones.. "
	fx := (x sin).
	self assert: (fx evaluate: #x with: (Float pi * 10 + 0.5)) asNumber equals: 0.5 sin.

	"Tricky ones.. "
	fx := (x sin).
	self assert: (fx evaluate: #x with: (Float pi * 10 + 0.5) negated) asNumber equals: -0.5 sin.
	
	"Float around"
	halfPiPlus := Float halfPi + Float twoPi.
	fx := (x cos).
	self assert: (fx evaluate: #x with: halfPiPlus) equals: zero.
	
	halfPiPlus := Float halfPi + Float twoPi.
	fx := (x cos).
	self assert: (fx evaluate: #x with: halfPiPlus negated) equals: zero.
	
	
	
]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testIsAssociative [
	| fx |
	fx := (x + y).
	self assert: fx isAssociative.

	fx := (x * y).
	self assert: fx isAssociative.

	fx := (x - y).
	self assert: fx isAssociative not.

	fx := (x / y).
	self assert: fx isAssociative not.
]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testIsCommutative [
	| fx |
	fx := (x + y).
	self assert: fx isCommutative.

	fx := (x * y).
	self assert: fx isCommutative.

	fx := (x - y).
	self assert: fx isCommutative not.

	fx := (x / y).
	self assert: fx isCommutative not.
]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testIsCommutativeOnBrackets [
	| fx |
	fx := (x + MathExpNumber five) + (x + MathExpNumber four).
	self assert: fx isCommutative.
	self assert: fx simplify equals: (MathExpNumber two * x) + (5 + 4 "notice these are Number").

	fx := (x + MathExpNumber five) + (MathExpNumber four + x).
	self assert: fx isCommutative.
	self assert: fx simplify equals: (MathExpNumber two * x) + (5 + 4 "notice these are Number").

	fx := (MathExpNumber five + x) + (MathExpNumber four + x).
	self assert: fx isCommutative.
	self assert: fx simplify equals: (MathExpNumber two * x) + (5 + 4 "notice these are Number").
]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testIsDistributive [
	| fx |
	fx := (x + y).
	self assert: fx isDistributive not.

	fx := (x * y).
	self assert: fx isDistributive.

	fx := (x - y).
	self assert: fx isDistributive not.

	fx := (x / y).
	self assert: fx isDistributive not.
]

{ #category : #tests }
MathExpressionBasicMethodsTest >> testVariableSearch [
	| fx |
	"build a function having x"
	fx := x sin + x.
	x value: nil.
	self assert: fx isNumber not.
	self assert: (fx variables size) equals: 1.
	self assert: (fx variables includes: x).

	"evaluate and see if continues to work"
	x value: 45 degreesToRadians.
	self assert: (fx variables includes: x).
	self assert: fx isNumber.
	self assert: fx asNumber equals: (45 degreesToRadians sin + 45 degreesToRadians).

	"Same but from parser"
	fx := MathExpression from: 'cos(x) / (pi * x) - x'.
	x := fx variable: 'x'.
	self assert: fx isNumber not.
	self assert: (fx variables size) equals: 1.
	self assert: (fx variables includes: x).

]
