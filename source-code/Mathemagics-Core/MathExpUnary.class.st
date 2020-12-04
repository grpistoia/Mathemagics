"
Class part:

	Designed to support unary operations, typically sine, cosine, sign change, etc.

Responsibility part:

	Most of the behaviour is related with the printing and formalises what unary is.

Public API and Key Messages:

	Most of the methods in the super class already define the behaviour of subclasses. Tried to keep the subexpression object private because the unary may do something speciall, for instance { sin(pi) = 0 }.

Internal Representation and Key Implementation Points:

	For now there are not many subclasses, mainly are unary functions.
"
Class {
	#name : #MathExpUnary,
	#superclass : #MathExpression,
	#instVars : [
		'subexpression'
	],
	#category : #'Mathemagics-Core-Base'
}

{ #category : #testing }
MathExpUnary class >> isAbstract [
	^ self == MathExpUnary.
]

{ #category : #'instance creation' }
MathExpUnary class >> on: aValueOrExpression [
	"This constructor will create and set the subexpression to guarantee consistency."
	^ self new subexpression: aValueOrExpression.
]

{ #category : #comparing }
MathExpUnary >> = anExpression [
	"Exactly same class and same subexpression"
	^ (self == anExpression) 
		or: [ (self class == anExpression class) and: [ self subexpression = anExpression subexpression ] ].
]

{ #category : #printing }
MathExpUnary >> codeOn: aStream [
	"Safer to add parenthesis in case has key methods { sin( 8 log: 2 ) => (8 log: 2) sin }"
	self utilPrintParenthesisBeginOn: aStream. "("
	subexpression codeOn: aStream. "x"
	self utilPrintParenthesisEndOn: aStream. ")"
	self utilPrintSpaceOn: aStream.
	self utilMathSymbolCodedOn: aStream. "sin"
]

{ #category : #mathematics }
MathExpUnary >> degree [
	"The degree of a unary is basically the one from the subexpression { sin(x^2) => 2 }"
	"Just to make it obvious, reason for this method"
	^ subexpression degree.
]

{ #category : #comparing }
MathExpUnary >> hash [
	"Used by the queue inside the parser"
	^ self class hash hashMultiply + subexpression hash.
]

{ #category : #testing }
MathExpUnary >> isNumber [
	"Quick search without having to calculate the expression"
	^ subexpression isNumber.
	
	"NOTE: This is default.. some may override.. for instance.. 0 is a number but log(0) is not"
]

{ #category : #printing }
MathExpUnary >> printOn: aStream [
	"Most unary have a name and parenthesis and the subexpression inside { cos(x+2) }"
	self utilMathSymbolPrintedOn: aStream. "sin, cos, tan, etc.  (etc is not a function.. means.. etcetera!)"
	self utilPrint: subexpression useParenthesis: (self class isFunction) onto: aStream. "x"
]

{ #category : #converting }
MathExpUnary >> replace: searchExpression with: replaceExpression [
	"Used to replace a subexpression for another."
	| temp |

	"First I compare myself"
	(self = searchExpression) ifTrue: [ ^ replaceExpression ].

	"It will rebuild if the subexpression has changed"
	temp := subexpression replace: searchExpression with: replaceExpression.
	(subexpression ~= temp) ifTrue: [ ^ self rewriteOn: temp ].

	"Return itself if no replacement"
	^ self.
]

{ #category : #private }
MathExpUnary >> rewriteOn: anExpression [
	"This create a new instance from the same class, from scratch, is not clone, is new"
	^ (self class) on: anExpression.
]

{ #category : #private }
MathExpUnary >> runSimplifyRulesTrailOn: aTrail [
	"By default, it will simplify the subexpression and create a new one if that was successful. Subclasses probably do something prior this."
	| temp |

	"Check if I can calculate and if the number is not .. a monster"
	self convertToNumber: [ :result | ^ MathExpNumber value: result ].

	"Return a new expression if really is different (after simplification)"
	temp := subexpression simplify.
	(subexpression == temp) ifFalse: [ ^ self simplifyInto: (self rewriteOn: temp) trail: aTrail ].

	"No choice to try to expand terms that may help simplifying"
	self isExpandable ifTrue: [
		"This is a trial because we cant foresee all combinations are better"
		temp :=self expand.
		"Only simplify if I got something different"
		(self == temp) ifFalse: [ ^ self simplifyInto: temp trail: aTrail ].
	].

	"Ran out of options"
	^ self.
]

{ #category : #accessing }
MathExpUnary >> settings: selectedSettings [
	"Normally global is enough but you can choose differently."
	super settings: selectedSettings.
	subexpression settings: selectedSettings.
]

{ #category : #private }
MathExpUnary >> subexpression [
	"Designed to be handled by each related class, shouldnt need accessing from outside"
	^ subexpression.
]

{ #category : #private }
MathExpUnary >> subexpression: anExpression [
	"In case a number or a string with a number is send, it will wrap as constant first. Should be called on construction only."
	subexpression := (MathExpression safeguard: anExpression).
]

{ #category : #mathematics }
MathExpUnary >> termOrder [
	"Check superclass for more information"
	| temp |
	"Add text after just for consistency { x + cos(x) + sin(y) } "
	temp := (subexpression termOrder) , (self mathSymbol asString).
	(self class isFunction) ifTrue: [ temp := 'F' , temp ].
	^ temp.
]

{ #category : #accessing }
MathExpUnary >> variables [
	"The unary subexpression may contain variables, so returns just that."
	^ subexpression variables.
]
