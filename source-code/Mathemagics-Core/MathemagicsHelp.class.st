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
MathemagicsHelp class >> bookDescription [
	^ self heading: 'Information about the ' , self bookName , ' package and examples.'.
]

{ #category : #accessing }
MathemagicsHelp class >> bookName [
	^ 'Mathemagics'.
]

{ #category : #accessing }
MathemagicsHelp class >> key [
	^ self bookName.
]

{ #category : #pages }
MathemagicsHelp class >> page01onIntroduction [
	"Very basics"
	| title fullText |

	"Easier to indent"
	title := 'Introduction to ' , self bookName.		
	fullText := 
'
This package allows you to express Mathematical expressions (formulas) with Mathematics syntax and precedence. That means, you can write Pi rather than "Float pi", use variables, use power as ^, and use Mathematics precedence.

The package knows how to parse the text special characters but also how to interact with correspondent messages in Smalltalk. Therefore transcompiling to Block or calculating a value will use the correct methods.

Best way to start is looking at MathExpression methods, the test classes or the Calculator.
More information can be found in the GitHub page.

'.
	
	"build a help topic"
	^ HelpTopic title: title contents: (self heading: title), fullText readStream nextChunkText.
]

{ #category : #pages }
MathemagicsHelp class >> page02onCodeExamples [
	"Very basics"
	| title fullText |

	"Easier to indent"
	title := 'Examples'.		
	fullText := 
'
Here are the ways to create Mathematical expressions and some messages availables:

Define an expression with bare constructors (not recommended):

	MathExpPower leftSide: (MathExpVariable symbol: #x) rightSide: (MathExpNumber value: 2).

Define an expression using Number''s like methods:

	MathExpVariable x squared reciprocal.

Define an expression with the built-in parser:

	MathExpression from: ''cos(x + pi)''.

Simplify an expression:

	(MathExpression from: ''x*x - (pi * -1) + x*8/1'') simplify.
	
Derivative

	(MathExpression from: ''3 * ln(x^4)'') derivativeFor: #x.
	
Convert expression to block

	(MathExpression from: ''x * x + y + y'') simplify asBlock.

'.
	
	"build a help topic"
	^ HelpTopic title: title contents: (self heading: title), fullText readStream nextChunkText.
]

{ #category : #pages }
MathemagicsHelp class >> page03onLicense [
	"Very basics"
	| title fullText |

	"Easier to indent"
	title := 'License & Warranty'.
	fullText := 
'
Find the license and warranty at https://github.com/grpistoia/Mathemagics

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'.
	
	"build a help topic"
	^ HelpTopic title: title contents: (self heading: title), fullText readStream nextChunkText.
]

{ #category : #pages }
MathemagicsHelp class >> page04onAbout [
	"Very basics"
	| title fullText |

	"Easier to indent"
	title := 'About..'.
	fullText := 
'
Don''t hesitate to contact me in case of doubts, unwanted features, ideas or if you are interested in collaborating.

Author.. Gustavo R. Pistoia
Github.. grpistoia
Gmail... grpistoia@

For more information visit: https://github.com/grpistoia/Mathemagics

December 2020
'.
	
	"build a help topic"
	^ HelpTopic title: title contents: (self heading: title), fullText readStream nextChunkText.
]

{ #category : #accessing }
MathemagicsHelp class >> pages [
	^ #(#page01onIntroduction #page02onCodeExamples #page03onLicense #page04onAbout).
]

{ #category : #'see class side' }
MathemagicsHelp >> seeClassSide [
]
