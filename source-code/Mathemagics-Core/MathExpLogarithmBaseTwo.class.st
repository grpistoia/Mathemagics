"
Class part: Binary Logarithm. This class represents the logarithm with base 2 of an expression. All other information is in the super class, since this class is mainly for printing and parsing reasons.

	MathExpression from: 'log2(8)'.
	MathExpression from: '2 logarithm 8'.
	
Avoided the name MathExpBinaryLogarithm to avoid confusion with MathExpBinary. Also to group logarithms together.
"
Class {
	#name : #MathExpLogarithmBaseTwo,
	#superclass : #MathExpLogarithm,
	#category : #'Mathemagics-Core-FunctionsBasic'
}

{ #category : #mathematics }
MathExpLogarithmBaseTwo class >> instantiationMethod [
	^ self mathSymbol.
]

{ #category : #mathematics }
MathExpLogarithmBaseTwo class >> logarithmBase [
	"Some calculations will simplify based on this"
	^ MathExpNumber two.
]

{ #category : #mathematics }
MathExpLogarithmBaseTwo class >> mathSymbol [
	"Extra option.. a bit unusual but simpler to read"
	^ #log2.
]

{ #category : #mathematics }
MathExpLogarithmBaseTwo class >> mathSymbolSmalltalk [
	"Notice it wont create or code with this.. "
	^ nil.

]

{ #category : #mathematics }
MathExpLogarithmBaseTwo >> mathSymbolSmalltalk [
	"Ln and Log dont need this. This way you can create others in the future."	
	^ MathExpLogarithm mathSymbolSmalltalk.
	
	"NOTE: Something I couldnt express with super. I want the class side of the method."
]
