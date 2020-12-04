"
Class part:

	This class allows assigning a name to a unknown value (such as 'x' or 'a'} and assign a value on demand to evaluate the expression.

	It has been defined that Variables are single letters 'x', 'n' etc. A digit after the letter is allowed 'x1', 'z2', etc.
	Universal Constants have priority, therefore 'e' will not be parsed as Variable but as the Euler number. Similar with 'pi' for instance.

Properties:

	- The derivative of a Variable is 1.
	- Variables are used in the #derivativeFor method. You may pass either the Variable itself, the String name, or a Character or Symbol
	- The call of #asNumber will call the #value that wil return the stored value.
	- Simplifying an expression when a variable is set, will replace that variable with a number.
	- The parser will it create each time is NOT a Universal Constant. :

		MathExpression from: ' x + y '.                 ""Two variables""
		MathExpression from: ' 3 * x ^ 2 + 4 *x + 5 '.  ""One variable used twice""
		MathExpression from: ' a + 20 '.                ""The 'a' is a variable""
		MathExpression from: ' e ^ 2 '.                 ""The 'e' is Euler constant""
		MathExpression from: ' volume '.                ""A variable called 'volume' is possible""

	Read the superclass for more information.
"
Class {
	#name : #MathExpVariable,
	#superclass : #MathExpValue,
	#type : #variable,
	#instVars : [
		'value',
		'symbol'
	],
	#category : #'Mathemagics-Core-Numeric'
}

{ #category : #mathematics }
MathExpVariable class >> mathSymbol [
	"This is the symbol used to write the expression in Maths (forget Smalltalk format here)"
	^ nil.

	"This depends on the instance, so the class returns nil to skip it."
]

{ #category : #validation }
MathExpVariable class >> nameRegexp [
	"This is the regular expression to ensure the name is supported. Originally only supported a letter but.. why not call a variable 'volume'!?"
	^ '[a-z]{1,20}[0-9]{0,1}'.

	"NOTE: Can be used by the user to check a string, and to ensure a parser is consistent."
]

{ #category : #'instance creation' }
MathExpVariable class >> symbol: aSymbol [
	"The name of the variable. I dont use 'name' because Smalltalk got upset."
	^ self new symbol: aSymbol.
]

{ #category : #'instance creation' }
MathExpVariable class >> symbol: aSymbol value: aValue [
	"Create the variable with a name and value."
	^ (self symbol: aSymbol) value: aValue.
]

{ #category : #validation }
MathExpVariable class >> variableNameValidation: aVariableName [
	"This is the regular expression to ensure the name is supported: x, y, z1"

	"The full validation method will check you dont use 'e' or 'pi'"
	^ MathExpUniversalConstant allSubclasses
		detect: [ :eachMathConstant | eachMathConstant mathSymbols includes: aVariableName asSymbol ]
		ifFound: [ ^ false ]
		ifNone: [ aVariableName asString matchesRegex: self nameRegexp ].
]

{ #category : #'instance creation' }
MathExpVariable class >> x [
	"Return a new instance, not singleton, because someone else may use the variable in another expression"
	"You can keep the variable and use it in the expression multiple times, as the parser does."
	^ self symbol: $x. "can be char"
]

{ #category : #'instance creation' }
MathExpVariable class >> y [
	"Return a new instance, not singleton, because someone else may use the variable in another expression"
	"You can keep the variable and use it in the expression multiple times, as the parser does."
	^ self symbol: 'y'. "can be string"
]

{ #category : #'instance creation' }
MathExpVariable class >> z [
	"Return a new instance, not singleton, because someone else may use the variable in another expression"
	"You can keep the variable and use it in the expression multiple times, as the parser does."
	^ self symbol: #z. "can be symbol"
]

{ #category : #comparing }
MathExpVariable >> = anExpression [
	"same old.."
	self == anExpression ifTrue: [ ^ true ].

	"If the expression was build manually with two variable named the same but different value"
	"I will just take the name.. or symbol.... (self value = anExpression value)"
	^ (self class = anExpression class) and: [ (symbol asSymbol = anExpression symbol) ].
]

{ #category : #mathematics }
MathExpVariable >> degree [
	"A degree of a polynomial starts is considered from the variable power to something. A constant power to something is not part of it."
	^ 1.
]

{ #category : #converting }
MathExpVariable >> derivativeFor: aVariableExpression [
	"I allow to pass a Character, Symbol, String or the Variable itself"
	self assert: aVariableExpression isNotNil description: 'Variable in derivative needed but nil received'.

	"| fx x | x := MathExpVariable x. fx := x ** 2. fx derivativeFor: x"
	(self = aVariableExpression) ifTrue: [ ^ MathExpNumber one ].

	"Althought {MathExpVariable x = #x} if false, we do want derivative to accept a symbol, is easier."
	(aVariableExpression isKindOf: MathExpValue)
		ifFalse: [ ^ self derivativeFor: (MathExpression safeguard: aVariableExpression) ].

	"If not the variable, anythign else (like a constant or another variable) is zero"
	^ MathExpNumber zero.
]

{ #category : #comparing }
MathExpVariable >> hash [
	"Used by the queue inside the parser"
	^ ((self class hash hashMultiply) + symbol hash) hashMultiply + value hash.
]

{ #category : #mathematics }
MathExpVariable >> mathSymbol [
	"Variables always print the symbol (even on coding)"
	^ self symbol.
]

{ #category : #mathematics }
MathExpVariable >> mathSymbolSmalltalk [
	"Variables always print the symbol (even on coding)"
	^ self symbol.
]

{ #category : #private }
MathExpVariable >> runSimplifyRulesTrailOn: aTrail [
	"The derivate assume you set a value to a variable... behaves like constant. This should do the same."
	self ifNumber: [ ^ MathExpNumber value: self asNumber ].
	"remains the same"
	^ self.
]

{ #category : #accessing }
MathExpVariable >> symbol [
	"The name of the variable. I dont use 'name' because Smalltalk got upset."
	^ symbol.
]

{ #category : #accessing }
MathExpVariable >> symbol: aSymbol [
	"Normally a variable gets assigned a name during initialization, and only the value changes during evaluation"
	self assert: symbol isNil description: 'Variable cannot change name to keep equations consistent (use replace instead)'.

	self assert: aSymbol isSymbol | aSymbol isString | aSymbol isCharacter.

	"You cant name a variable 'i' or 'e' or 'pi' .. "
	self assert: (self class variableNameValidation: aSymbol)
			description: 'Variable cannot be named "' , aSymbol asString , '" because conflicts with other symbol.'.

	"Stores as string to compare easy, because sometimes is easier to use $x or 'x' or #x"
	symbol := aSymbol asSymbol.

	"NOTE: Notice I do not force variables to keep their name. In math sometimes we rename them."
]

{ #category : #mathematics }
MathExpVariable >> termOrder [
	"Check superclass for more information"
	^ 'B' , (symbol asString).
]

{ #category : #evaluating }
MathExpVariable >> value [
	"Direct access to the value, may be therefore nil"
	^ value.
]

{ #category : #converting }
MathExpVariable >> value: aValue [
	"Variables are OK to be set, specially during the evaluation."
	self assert: (aValue isNil | aValue isNumber) description: 'Variables can only hold a Number, not "' , aValue className , '"'.

	value := aValue ifNotNil: [ aValue asNumber ].

	"NOTE: Derivative, simplification and other mathematical processes treat numbers, Mathematical Constants and Variables different."
]

{ #category : #accessing }
MathExpVariable >> variables [
	"Should return a Set of variables from this expression downward (may compound backwards)"
	^ (super variables) add: self; yourself.
]
