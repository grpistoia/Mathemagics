"
Class part:

	This class allows holding an integer or decimal number.

Properties:

	- The derivative of a constant is zero.
	- The call of #asNumber will return the #value stored.
	- The parser will create each time you write a number:

		MathExpression from: ' 9 '.
		MathExpression from: ' 2.345 '.
		MathExpression from: ' -1.23e-5'.
		MathExpression from: ' -2e3.5'.  ""Smalltalk fails here""
		MathExpression from: ' .8'.      ""Smalltalk fails here""
		MathExpression from: ' +9'.      ""Smalltalk fails here""

Public API and Key Messages:

	There are a few class methods to speed up creation of typical numbers.

	MathExpNumber two * MathExpNumber six.

Read the superclass for more information.
"
Class {
	#name : #MathExpNumber,
	#superclass : #MathExpValue,
	#instVars : [
		'value'
	],
	#category : #'Mathemagics-Core-Numeric'
}

{ #category : #mathematics }
MathExpNumber class >> eight [
	"Creates on the fly, but not singleton"
	^ self value: 8.
]

{ #category : #mathematics }
MathExpNumber class >> five [
	"Creates on the fly, but not singleton"
	^ self value: 5.
]

{ #category : #mathematics }
MathExpNumber class >> four [
	"Creates on the fly, but not singleton"
	^ self value: 4.
]

{ #category : #validation }
MathExpNumber class >> isEasyReadNumber: aNumber [
	"Basically an easy to read number. Makes expression easy.. compare 0.5 vs 3.1415^"
	^ (aNumber abs <= 10000) and: [ (aNumber * 1000) fractionPart = 0 ].
]

{ #category : #mathematics }
MathExpNumber class >> mathSymbol [
	"This is the symbol used to write the expression in Maths (forget Smalltalk format here)"
	^ nil.

	"This depends on the instance, so the class returns nil to skip it."
]

{ #category : #mathematics }
MathExpNumber class >> minusOne [
	"Creates on the fly, but not singleton"
	^ self value: -1.
]

{ #category : #mathematics }
MathExpNumber class >> minusTwo [
	"Creates on the fly, but not singleton"
	^ self value: -2.
]

{ #category : #mathematics }
MathExpNumber class >> nine [
	"Creates on the fly, but not singleton"
	^ self value: 9.
]

{ #category : #validation }
MathExpNumber class >> numberRegexp [
	"Regular expression to ensure the text represents a number."
	"Originally you can online this: '(\+|\-)?\d+(\.\d*)?((e|E)(\+|\-)?\d+)?'."
	"That does not allow missing zero that people type such as { .45 }"
	"Also does not allow decimal exponent which Smalltalk doesnt support { 3e2.5 }"
	"But with that, we cannot pass just { e2 } as a number or { . } which is were all goes South"

	"Here is my version. I let the missing number before the dot. What it says is.. at least one digit"
	"For the 'e' part.. you must type the leading zero and digits after if there is a dot"
	^ '(\+|\-)?\d*(\.\d*)?\d((e|E)(\+|\-)?\d+(\.\d+)?)?'

	"NOTE: Can be used by the user to check a string, and to ensure a parser is consistent."
]

{ #category : #validation }
MathExpNumber class >> numberValidation: aNumberAsText [
	"Just boolean if represents a number"
	^ aNumberAsText asString matchesRegex: self numberRegexp.
]

{ #category : #'instance creation' }
MathExpNumber class >> numericToNumber: aNumericInString [
	"This is called by MathExpression when is clear is a number inside and only that."
	| numericText split base exponent floatExp mathExp |

	self assert: (self numberValidation: aNumericInString).

	"I will manipulate this object. I do things Smalltalk actually doesnt do."
	numericText := aNumericInString asString.

	"If has '+.6' .. which Smalltalk doesnt understand... I add a zero before the dot"
	(numericText includesSubstring: '.') ifTrue: [
		numericText := ' ' , numericText.
		numericText := numericText
									copyWithRegex: '(\+|\-| ){1}(\.)'
									matchesTranslatedUsing: [ :c | c first asString , '0' , c second asString ].
	].

	"Smalltalk doesn accept '+3' and '+ 3'"
	numericText := numericText copyReplaceAll: '+' with: ''.

	"Not only trim.. but in case someone types '- nn'"
	numericText := numericText trim copyReplaceAll: ' ' with: ''.

	"Is not Scientific notation notatoin.. I can finish now.."
	(numericText includesSubstring: 'e') ifFalse: [ ^ self value: numericText asNumber ].

	"Scientific notation .. avoid 3e-4 could becomes 0.00030000000000000003.."
	" 3e-4 => 3*(10**(-4)) .. so I use this.. '1234e10' substrings: 'e' => #('1234' '10')"
	split := numericText substrings: 'e'.
	base := split first asNumber.
	exponent := split second asNumber.

	"Pharo doesnt support things like { 3e2.5 }. I let that happen because in Maths is fairly common."
	floatExp := exponent isInteger ifTrue: [ numericText asNumber ] ifFalse: [ (10 ** exponent) * base "warning.. rounding"].
	"express as MathExpression"
	 mathExp := (self ten ** exponent) * base.

	"added decimals.. keep the shorter"
	^ (mathExp asNumber asString size < floatExp asString size) ifTrue: [ mathExp ] ifFalse: [ self value: floatExp ].
]

{ #category : #mathematics }
MathExpNumber class >> one [
	"Creates on the fly, but not singleton"
	^ self value: 1.
]

{ #category : #mathematics }
MathExpNumber class >> oneHalf [
	"Creates on the fly, but not singleton"
	^ self value: 0.5.  "I dont use 1/2 because Number may raise a division"
	
	"NOTE: Is used also by #squareRoot and #sqrt"
]

{ #category : #mathematics }
MathExpNumber class >> oneHundred [
	"Creates on the fly, but not singleton"
	^ self value: 100.
]

{ #category : #mathematics }
MathExpNumber class >> seven [
	"Creates on the fly, but not singleton"
	^ self value: 7.
]

{ #category : #mathematics }
MathExpNumber class >> six [
	"Creates on the fly, but not singleton"
	^ self value: 6.
]

{ #category : #mathematics }
MathExpNumber class >> ten [
	"Creates on the fly, but not singleton"
	^ self value: 10.
]

{ #category : #mathematics }
MathExpNumber class >> three [
	"Creates on the fly, but not singleton"
	^ self value: 3.
]

{ #category : #mathematics }
MathExpNumber class >> two [
	"Creates on the fly, but not singleton"
	^ self value: 2.
]

{ #category : #'instance creation' }
MathExpNumber class >> value: aValue [
	"Go ahead.. store a Number.."
	^ self new value: aValue.
]

{ #category : #mathematics }
MathExpNumber class >> zero [
	"Creates on the fly, but not singleton"
	^ self value: 0.
]

{ #category : #comparing }
MathExpNumber >> hash [
	"Used by the queue inside the parser"
	^ (self class hash hashMultiply) + value hash.
]

{ #category : #mathematics }
MathExpNumber >> mathSymbol [
	"Number has an instance value, not fixed like constants"
	^ self value.
	"This one ends up overriding the class side."
]

{ #category : #mathematics }
MathExpNumber >> negated [
	"This ends up simplifying the expression before sending the simplify message { -(-3) => +3 }"
	^ self class value: (self value negated).
]

{ #category : #mathematics }
MathExpNumber >> termOrder [
	"Check superclass for more information"
	^ 'H'.
]

{ #category : #evaluating }
MathExpNumber >> value [
	"Direct access to the value, should be something already"
	^ value.
]

{ #category : #accessing }
MathExpNumber >> value: aValue [
	"Should be called on initialization only. Shouldn't change dynamically, use Variable for that."
	self assert: value isNil description: 'Number cannot change value, use Variables instead'.

	self assert: aValue isNumber description: 'Number can only hold real numbers not "' , aValue className , '"'.

	"Someone may have passed ... sin(0).. is OK.."
	value := aValue asNumber.

	"NOTE: Derivative, simplification and other mathematical processes treat numbers, Mathematical Constants and Variables different."

	"NOTE: At one point I supported getting Fraction, but then comparison with Division may become very strange. It not a problem on the process but on equals method only."
]

{ #category : #printing }
MathExpNumber >> wantsParenthesisUnder: parentExpression [
	"Respects the priority as the super does, except for { a - (-9) }"
	^ (value negative)
			and: [ { MathExpNegative . MathExpSubtraction } includes: (parentExpression class) ].
]
