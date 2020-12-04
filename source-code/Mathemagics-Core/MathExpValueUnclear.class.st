"
For the Class part:

	I represent symbols that cannot be translated to numbers, such as Undefined or Infinity.

For the Responsibility part:

	I cannot evaluate asNumber and isNumber should always return false.
	These classes shouldnt be instanciated by the user, but normally by the simplifcation or other mechanisms.

Note: You shouldnt create a subclass of this or try to parse it. Those will be understood as variables. These classes are just for display of the text.
"
Class {
	#name : #MathExpValueUnclear,
	#superclass : #MathExpression,
	#category : #'Mathemagics-Core-Base'
}

{ #category : #mathematics }
MathExpValueUnclear class >> instantiationMethod [
	"Parser cannot instantiate these ones.. no point (and no method such as #Infinity)"
	^ nil.
]

{ #category : #testing }
MathExpValueUnclear class >> isAbstract [
	^ self == MathExpValueUnclear.
]

{ #category : #comparing }
MathExpValueUnclear >> = anExpression [
	"Nothign to compare except the class.. so all becomes the same"
	^ self class == anExpression class.
]

{ #category : #converting }
MathExpValueUnclear >> asNumber [
	"Guess.."
	ArithmeticError new signal: 'Cannot produce a value because the expression is ' , self mathSymbol asString.
]

{ #category : #printing }
MathExpValueUnclear >> codeOn: aStream [
	"Let it fail.."
	^ self asNumber.
]

{ #category : #converting }
MathExpValueUnclear >> derivativeFor: aVariableExpression [
	"Although you cannot differenciate the undefined.. I keep it as it to show to the user rather than exceptions"
	^ self.
]

{ #category : #comparing }
MathExpValueUnclear >> hash [
	"Is ok to point to the same object"
	^ self class hash.
]

{ #category : #testing }
MathExpValueUnclear >> isNumber [
	"This is really the point.. probalby should not override"
	^ false.
]

{ #category : #mathematics }
MathExpValueUnclear >> negated [
	"Just to avoid showing -undefined"
	^ self.
]

{ #category : #printing }
MathExpValueUnclear >> printOn: aStream [
	"Just print the name."
	self utilMathSymbolPrintedOn: aStream.
]

{ #category : #converting }
MathExpValueUnclear >> replace: searchExpression with: replaceExpression [
	"Used to replace a subexpression for another."

	"Simple case, return replacement if required"
	(self = searchExpression) ifTrue: [ ^ replaceExpression ].

	"Otherwise I keep the current"
	^ self.
]

{ #category : #private }
MathExpValueUnclear >> runSimplifyRulesTrailOn: aTrail [
	"I keep it as it to show to the user rather than exceptions"
	^ self.
]

{ #category : #'see class side' }
MathExpValueUnclear >> seeClassSide [
]

{ #category : #mathematics }
MathExpValueUnclear >> termOrder [
	"Check superclass for more information"
	^ 'U'.
]

{ #category : #accessing }
MathExpValueUnclear >> variables [
	"I keep it as it to show to the user rather than exceptions"
	^ Set new.
]

{ #category : #printing }
MathExpValueUnclear >> wantsParenthesisUnder: parentExpression [
	"Mmm... why not.. make it clear if it is inside other things { x*(undefined) }"
	^ true.
]
