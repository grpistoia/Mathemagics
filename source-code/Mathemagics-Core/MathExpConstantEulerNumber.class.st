"
Class part:

	Represents the Euler number marked as 'e' in the expressions

Properties:

	- The parser use the mathSymbol to recognise this special constant:

		MathExpression from: ' e ^ 3 '.
		(MathExpression from: ' ln(e^x)') simplify.

	Read the superclass for more information.
"
Class {
	#name : #MathExpConstantEulerNumber,
	#superclass : #MathExpUniversalConstant,
	#category : #'Mathemagics-Core-Numeric'
}

{ #category : #mathematics }
MathExpConstantEulerNumber class >> mathSymbol [
	"NOTE: Unicode value: 16r2107 is not in the list in Pharo"
	^ #e.
]

{ #category : #evaluating }
MathExpConstantEulerNumber class >> value [
	"No need to reinvent the wheel.. used as object but lazy evaluated"
	^ Float e.
]

{ #category : #mathematics }
MathExpConstantEulerNumber >> mathSymbolSmalltalk [
	"When is an instance, the codeOn will print the Smalltalk way"
	^ 'Float e'.
]

{ #category : #'see class side' }
MathExpConstantEulerNumber >> seeClassSide [
]
