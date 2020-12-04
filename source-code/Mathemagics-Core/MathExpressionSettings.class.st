"
For the Class part:

	This class represents a few generic settings for expressions that gets cascaded into each subexpression. Because we don't want to worry about settings each time we create an expression, default settings are used.

For the Responsibility part:

	Hold generic behavioural settings for each expression, that gets cascaded down to the subexpressions.

	For instance, mathematical expressions get written from the highest power to the lowest, such as { x^3 + x^2 + x + 1 }.
Notice that in the example that power are written in descending order. If the expression has two variables, they normally get written ascending, for example { x^2 + x + y + 4 }. An exception to the rule is multiplication, that because are commutative, numbers are written first { 3*x^2 } rather than { x^2*3 }. Internally the standard order is used and multiplication deals with the exception on printing.

For the Collaborators Part:

	MathExpression and any subclass.

Public API and Key Messages:

	Most cases this is transparent and you dont want to change. See comments in method if required, but mainly is just formatting.

Internal Representation and Key Implementation Points.

	At the moment a global instance of this setting is hold. I dont think makes sense to have multiple for each expression but can be done by just cascading inside the creation of each expression. Some mathematical expressions are global though, such as Pi, but they are not affected by those settings.

"
Class {
	#name : #MathExpressionSettings,
	#superclass : #Object,
	#instVars : [
		'numbersLeadProducts',
		'prettyMathSymbols',
		'spacedBracketed',
		'spacedTerms'
	],
	#classVars : [
		'Default',
		'UseSingletonParser'
	],
	#category : #'Mathemagics-Core'
}

{ #category : #accessing }
MathExpressionSettings class >> default [
	"This one holds the default settings but you can change if you like, and cascade down through the expressions"
	^ Default ifNil: [ Default := self new ].
]

{ #category : #accessing }
MathExpressionSettings class >> reset [
	"Destroy the defaults.. the next call will default"
	Default := nil.
	"Avoid the warning"
	^ self.
]

{ #category : #accessing }
MathExpressionSettings class >> useSingletonParser [
	"For debug, when I want to add classes and reload automatically"
	^ UseSingletonParser ifNil: [ UseSingletonParser := true ]
]

{ #category : #accessing }
MathExpressionSettings class >> useSingletonParser: aBoolean [
	UseSingletonParser := aBoolean
]

{ #category : #accessing }
MathExpressionSettings >> numbersLeadProducts [
	"I answer if to show { 2*x } rather than { x*2 } (which is the internal format)"
	"Default on first call rather than initialize everything"
	^ numbersLeadProducts ifNil: [ numbersLeadProducts := true ]
]

{ #category : #accessing }
MathExpressionSettings >> numbersLeadProducts: aBoolean [
	numbersLeadProducts := aBoolean
]

{ #category : #accessing }
MathExpressionSettings >> prettyMathSymbols [
	"I answer if you want to print symbol of Pi rather than the text 'pi' and others"
	"Default on first call rather than initialize everything"
	^ prettyMathSymbols ifNil: [ prettyMathSymbols := true ]
]

{ #category : #accessing }
MathExpressionSettings >> prettyMathSymbols: aBoolean [
	prettyMathSymbols := aBoolean
]

{ #category : #accessing }
MathExpressionSettings >> spacedBracketed [
	"I answer if you want to add spaces inside parenthesis like { ( a+b ) } rather than { (a+b) }"
	"Default on first call rather than initialize everything"
	^ spacedBracketed ifNil: [ spacedBracketed := false ]
]

{ #category : #accessing }
MathExpressionSettings >> spacedBracketed: aBoolean [
	spacedBracketed := aBoolean
]

{ #category : #accessing }
MathExpressionSettings >> spacedTerms [
	"I answer if you want to add spaces around +/- { a + b } rather than { a+b }"
	"Default on first call rather than initialize everything"
	^ spacedTerms ifNil: [ spacedTerms := true ]
]

{ #category : #accessing }
MathExpressionSettings >> spacedTerms: aBoolean [
	spacedTerms := aBoolean
]
