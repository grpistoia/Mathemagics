"
This is a very small help and information related with this package.

Should appear in the Help Browser.
"
Class {
	#name : #MathemagicsHelp,
	#superclass : #CustomHelp,
	#category : #'Mathemagics-Core-Help'
}

{ #category : #accessing }
MathemagicsHelp class >> bookName [
	^'Mathemagics'
]

{ #category : #pages }
MathemagicsHelp class >> contactAuthor [
	"Very basics"
	| fullText |

	"Easier to indent"
	fullText := 
'
Dont hesitate to contact me in case of doubts, errors, or if you are interested in collaborating:

Author 	:	Gustavo R Pistoia
Discord	:	grpistoia
Github 	:	grpistoia
Gmail  	:	grpistoia@

December 2020'.
	
	"build a help topic"
	^ HelpTopic title: 'Contact Author' contents: fullText readStream nextChunkText.
]

{ #category : #pages }
MathemagicsHelp class >> introduction [
	"Very basics"
	| fullText |

	"Easier to indent"
	fullText := 
'
This package allow you to express Mathematical expressions (formulas) with Math''s syntax. That means, you can write Pi rather than "Float pi", use variables, use power as ^, and using Math''s precedence.
The package is smart to know how to parse the text but also how to interact with Smalltalk. Therefore transcompiling to Block or calculating a value will use the correct methods.

Best way to start is looking at MathExpression methods and the provided Calculator.
Other information can be found in the GitHub page at the end of this page.

Here are some examples:

Define an expression with bare constructors:

	MathExpPower leftSide: (MathExpVariable symbol: #x) rightSide: (MathExpNumber value: 2).

Define an expression using Number''s like methods:

	(MathExpVariable x ** 3) negated.

Define an expression with the built-in parser:

	MathExpression from: ''x*x - (pi * -1) + x*8/1''.

Simplify an expression:

	(MathExpression from: ''x + x + x + 20 + x'') simplify.
	
Derivative

	(MathExpression from: ''3 * ln(x^4)'') derivativeFor: #x.
	
Convert expression to block

	(MathExpression from: ''x * x + y + y'') simplify asBlock.

'.
	
	"build a help topic"
	^ HelpTopic title: 'Introduction' contents: fullText readStream nextChunkText.
]

{ #category : #accessing }
MathemagicsHelp class >> pages [
	^ #(introduction #contactAuthor).
]

{ #category : #'see class side' }
MathemagicsHelp >> seeClassSide [
]
