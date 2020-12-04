"
Class part:

	Represents 'Pi' also called Archimedes' constant.

Properties:

	- It is designed to support further simplifications such as { cos(x+pi) => -cos(x) }
	- The parser use the mathSymbol and mathSymbolOptional to recognise this special constant:

	MathExpression from: ' pi '.
	MathExpression from: (Unicode value: 16r03A0).  ""symbol not written here due to Unicode issue""

	Read the superclass for more information.
"
Class {
	#name : #MathExpConstantPi,
	#superclass : #MathExpUniversalConstant,
	#category : #'Mathemagics-Core-Numeric'
}

{ #category : #mathematics }
MathExpConstantPi class >> mathSymbol [
	^ #pi.
]

{ #category : #mathematics }
MathExpConstantPi class >> mathSymbolPro [
	"Math symbol (not written here due to FileOut load issue)"
	^ Unicode value: 16r03C0.
]

{ #category : #evaluating }
MathExpConstantPi class >> value [
	"No need to reinvent the wheel.. used as object but lazy evaluated"
	^ Float pi.
]

{ #category : #mathematics }
MathExpConstantPi >> mathSymbolSmalltalk [
	"When is an instance, the codeOn will print the Smalltalk way"
	^ 'Float pi'.
]

{ #category : #'see class side' }
MathExpConstantPi >> seeClassSide [
]
