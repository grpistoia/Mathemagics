"
Class part:

	Represents 'Phi' also called Golden Ratio (two quantities are in the golden ratio if their ratio is the same as the ratio of their sum to the larger of the two quantities).

Properties:

	- The parser use the mathSymbol and mathSymbolOptional to recognise this special constant:

		MathExpression from: ' phi '.
		MathExpression from: ' phi * x '.

	Read the superclass for more information.
"
Class {
	#name : #MathExpConstantGoldenRatio,
	#superclass : #MathExpUniversalConstant,
	#category : #'Mathemagics-Core-Numeric'
}

{ #category : #mathematics }
MathExpConstantGoldenRatio class >> mathSymbol [
	^ #phi.
]

{ #category : #mathematics }
MathExpConstantGoldenRatio class >> mathSymbolPro [
	"Math symbol (not written here due to FileOut load issue)"
	^ Unicode value: 16r03D5. "(could be also 16r0278 or 16r03A6)"
]

{ #category : #evaluating }
MathExpConstantGoldenRatio class >> value [
	"No need to reinvent the wheel.. used as object but lazy evaluated"
	^ (1 + (5 sqrt)) / 2.
]

{ #category : #'see class side' }
MathExpConstantGoldenRatio >> seeClassSide [
]
