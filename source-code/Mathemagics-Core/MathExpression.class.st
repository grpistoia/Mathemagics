"
Class part:

	This is the root class to represent a mathematical expression (from something simple such a number or mathematical constant, to something complex like nested functions and polynomials).
	The idea is that you can send to a Mathematical Expression the same message you send to a Number. The difference is that a Mathematical Expression is not evaluated to Number straight away, and have interesting properties.

Responsibility: 

	To evaluate to a Number, hold subexpressions, delegate methods to them (such as #simplify), and to answer for generic messages (such as #sin, #asNumber, #printOn, etc).
	Notice that I write examples inside curly brackets for clarity reasons, so they are not visually confused with blocks or text.

CREATION EXAMPLES: Let's start by creating { sin(0.75) + x }.

	THE HARD WAY: Using each class constructor, although possible it's too complicated, so it is shown here for documentation:

		MathExpAddition leftSide: (MathExpSine on: (MathExpNumber value: 0.75)) rightSide: (MathExpVariable symbol: 'x').

	A SIMPLER WAY: Using similar operations as in Number class (assuming the initialization installed #asMathExpression on Number):

		0.75 asMathExpression sin + MathExpVariable x.

	THE NEW PARSER WAY: I implemented the Shunting Yard algorithm linked to MathExpression hierarchy. Notice I heavily rely on reflexion for it:

		MathExpression from: 'sin(0.75) + x'.

QUESTIONS:

	Question: Why would I worry about this mess if I can just use  y := [ :x | 0.75 sin + x ]  ?
	Answer: Sure, but this has additional abilities. It's also interesting we could have an alternative way, using objects to store the operations. Consider it a lazy evaluation mechanism, and allows the expression to answer questions.

	Question: If I parse { 1 + 2 * 3 } do I get  7 as in Mathematics, or 9 as in Smalltalk?
	Answer: You get { 7 }. The parser respects Mathematical priority. That includes the strange case { -2^4 } in Maths is { -16 } since negative has lower priority than power that runs first. In Smalltalk { -2 ** 4 } will return 16.

	Question: Can I use 'Pi' in the expression or other Mathematical Constants?
	Answer: Yes. You can also use Euler's number and Golden Ratio (phi) at this time. For instance, evaluate the following:

		MathExpression from: 'sin(pi) + x'.
				Will return { sin(pi)+x } but normally the Pi symbol will be displayed (not shown here due to Unicode issue).

	Question: You know what would be nice.. to simplify the expressions...
	Answer: Something like this?

		(MathExpression from: 'sin(pi) - 0 * x^2 + x * 1 - ln(e)') simplify.
				Will return  { x-1 }  because sin(pi) is zero; zero multiplied by x^2 is zero; and ln(e) is always 1.

	Question: Why do I need to call #simplify, why doesn't the parser do it automatically?
	Answer: It's visually very confusing to provide an expression and get something completely different back, and allows the calculator to show the input.

	Question: Any other use of those variables?
	Answer: Yes, Derivatives.

		(MathExpression from: 'x^3 + 5*x') derivativeFor: $x.
				Will return { 3*x^2 + 5 } since { d/dx( x^n ) = n * x^(n-1) }. Another notation is using apostrophe instead of d/dx.

		(MathExpression from: 'cos(x^5)') derivativeFor: 'x'.
				Will return { -5*x^4*sin(x^5) } since { cos(U)' = -U' * sin(U) }. Notice that derivative method accept a Variable, Character, String or Symbol.

	Question: Why some expressions don't get simplified any further ?
	Answer: Numbers are simplified to keep expressions as readable as possible. For instance, Irrational numbers are not expanded. For instance:

		(MathExpression from: '2 * 3') simplify.
				Will print { 6 }.

		(MathExpression from: '2 * 3 * pi') simplify.
				Will print { 6*pi } .. or the symbol for 'pi' ( which I avoid here in case gets dropped in the FileOut ).

	Question: But in the example above.. I want the value, not a simplified version!?
	Answer: Use #asNumber instead of #simplified.

		(MathExpression from: '2 * 3 * pi') asNumber.
				In that case you get a Number object. In the previous one you get an expression instance.

	Question: Can I get the variable from that parsed expression (not build manually), and assign values in a loop ?
	Answer: Yes
		| x y z |
		y := MathExpression from: 'sin(0.75) + x'.
		x := y variable: 'x'.
		""And this is the part you use in you loop..""
		x value: 1.
		y asNumber.

	Question: You know what would be awesome.. to be able to parse an expression and generate a block optimised for Roassal, for instance.
	Answer: Use #asBlock

		(MathExpression from: '1 + x^2') asBlock
				Will generate a block  [ :x | 1 + (x ** 2) ]. Notice that symbols like ^ are also supported for parser but are not used for blocks.

OTHER EXAMPLES:

	MathExpAddition leftSide: 5 rightSide: 7.
	5 asMathExpression - 7.
	MathExpNumber five * 7.
	MathExpUniversalConstant pi / MathExpVariable x.
	(MathExpConstantPi new + MathExpUniversalConstant pi) simplify.
	(MathExpNumber seven - 2 / 5) simplify.


Collaborators Part:

	The MathExpression tree is quite independent from other Smalltalk classes. The parser instead uses Dictionary, Stacks, and the MathExpression tree by reflexion.

Public API: 

	Basically all methods can be called on a Mathematical Expression. The only ones suggested to avoid calling directly are under the 'private' protocol, and they are the ones related with initialization. The reason is that some classes do change behaviour depending on the creation time, and although should remain consistent, may be not the best approach. For instance, you can create a Logarithm base 'e' on a variable 'x', but normally we will want to see 'ln(x)' rather than 'log{e}(x)'.

Key Messages: 

	Basically some in Number, plus the manipulation of an expression. Message like  #+ or #/ would work the same, and also you can ask #simplify to an expression to make itself clearer, or to run the #derivativeFor:aVariable.

Implementation Points: 

	A mathematical expression can be represented as a tree.
	- Some expressions are binary (i.e.: addition, power, etc) having a left and right subexpression.
	- Some are unary and therefore have one subexpression (i.e.: sine, cosine, etc).
	- Number are also stored as a mathematical expression, not only for consistency but for some basic behaviour. Consider numbers as unamed constants.
	- Mathematical Constants (such as 'Pi', or 'e') are also stored as a special mathematical expression. For instance, 'Pi' will print itself as a symbol pi. They are constant therefore not supposed to change the value.
	- Variables are another type of expression which we are happy to apply a value before evaluating the whole expression. There is functionality to evaluate them, extract them from a mathematical expression, differentiate and so forth.
	- At some point I thought renaming as ""Sum"", ""Difference"", ""Product"" and ""Quotient"". Those names are shorter but theoretically those are the results of the operation of those numbers.

"
Class {
	#name : #MathExpression,
	#superclass : #Object,
	#instVars : [
		'settings'
	],
	#category : #'Mathemagics-Core-Base'
}

{ #category : #parsing }
MathExpression class >> from: aMathExpressionTextInfixFormat [
	"Is only to reduce cascading.. but you could call the parser yourself"
	^ MathExpressionParser singletonParse: aMathExpressionTextInfixFormat.
]

{ #category : #parsing }
MathExpression class >> from: aMathExpressionTextInfixFormat settings: selectedSettings [
	"Apply the settings afterwards"
	| temp |
	temp := self from: aMathExpressionTextInfixFormat.
	temp settings: selectedSettings.
	^ temp.
]

{ #category : #'class initialization' }
MathExpression class >> initialize [
	"This is not compulsory, but adding the asMathExpression to Number allows things such as [ 0.5 asMathExpression sin -=> Sin(0.5) ] "
	| newMethod |
	"Only at this class"
	(self == MathExpression) ifFalse: [ ^ self ].
	"Add the code.."
	newMethod := Number compile: ( 'as' , self asString , String cr , String tab , '^ ' , self asString , ' safeguard: self.' ) classified: 'converting'.
	UIManager default inform: 'Added method in Number to quickly convert into expressions: ' , newMethod.

]

{ #category : #mathematics }
MathExpression class >> instantiationMethod [
	"Some rare occasions we dont want to instantiate with 'mathSymbolSmalltalk' but we always export with it"
	^ self mathSymbolSmalltalk.
	
	"Example: MathExpNegative uses two symbols: '-' and #negated. Instantiates the #negated."
	"But.. MathExpSqr uses two symbols: #sqr and #squared, instantiates with #sqr but exports with #squared"
]

{ #category : #testing }
MathExpression class >> isAbstract [
	^ self == MathExpression.
]

{ #category : #testing }
MathExpression class >> isAlsoUnarySign [
	"These ones are not only operations but collide with the unary signs"
	^ (self = MathExpAddition) | (self = MathExpSubtraction) | (self = MathExpNegative).
]

{ #category : #testing }
MathExpression class >> isBasicOperator [
	"Most simplification operations are for the 4 basic operations"
	^ { MathExpAddition . MathExpSubtraction . MathExpMultiplication . MathExpDivision  } includes: self.
]

{ #category : #testing }
MathExpression class >> isBinaryOperator [
	"Is an operator and has two terms. Preferred to have less implementations in subclasses, reason for the code style."
	^ self inheritsFrom: MathExpBinary.
]

{ #category : #testing }
MathExpression class >> isFunction [
	"Answer if the receiver is a function (atm only unary functions are defined)."
	self isSimpleOperator ifTrue: [ ^ false ].
	self == MathExpNegative ifTrue: [ ^ false ].
	^ (self inheritsFrom: MathExpUnary) | (self inheritsFrom: MathExpBinary).
	
	"NOTE: May move to individual methods"
]

{ #category : #testing }
MathExpression class >> isMathConstant [
	"Answer if the receiver is a mathematical constants such as Pi."
	^ self inheritsFrom: MathExpUniversalConstant.
]

{ #category : #testing }
MathExpression class >> isNumericConstant [
	"This represent a fix number.. such as 2.. -9.. but neither Variables nor Mathematical Constants such as Pi."
	^ self = MathExpNumber.
]

{ #category : #testing }
MathExpression class >> isSimpleOperator [
	"Answer if the receiver is an operator (therefore precedente becomes more relevant between them)."
	^ self isBasicOperator or: [ {  MathExpPower } includes: self ].

	"NOTE: In the future you can add // or something else."
]

{ #category : #testing }
MathExpression class >> isSingleTerm [
	"A single term, which could be a unary one { sin(x) } or a variable alone { x } or number, etc."
	"This is used for parsing and also for simplification."
	^ (self inheritsFrom: MathExpBinary) not.
]

{ #category : #testing }
MathExpression class >> isUnaryOperator [
	"Is an operator and has represents one term. Preferred to have less implementations in subclasses, reason for the code style."
	^ self inheritsFrom: MathExpUnary.
]

{ #category : #testing }
MathExpression class >> isVariable [
	"Answer if the receiver is a variable such as 'x'."
	^ self == MathExpVariable.
]

{ #category : #mathematics }
MathExpression class >> mathSymbol [
	"This is the symbol used to write the expression in Maths (forget Smalltalk format here)"
	"This is also a method that when is not nil will be expected by the parser"
	self subclassResponsibility.

	"Basically.. a number like 5.. a 'cos'.. a symbol like '+'"
	"The library will try to use the pretty print or the smalltalk version and default into this one."
]

{ #category : #mathematics }
MathExpression class >> mathSymbolPro [
	"This is the pretty math symbol which normally is extra Unicode (forget Smalltalk format here)"
	^ nil. "if not specified the mathSymbol is all what is needed"
]

{ #category : #mathematics }
MathExpression class >> mathSymbolSmalltalk [
	"This is what Smalltalk would understand for the Math Symbol. For instance: { 0.5 arcCos } rather than arcos"
	^ self mathSymbol. "if not specified the mathSymbol is all what is needed"

	"In some cases they are not the same: { 2 ^ 5 } but we smalltalk { 2 ** 5 }"
	"In some cases, there are two ways to write: { sqrt(2) vs the symbol }"
]

{ #category : #mathematics }
MathExpression class >> mathSymbols [
	"Combine all representations for the parser understand."
	| result |
	result := Set new: 3. "remove duplicates.. some methods do for overriding"
	self mathSymbol ifNotNil: [ :symbol | result add: symbol ].
	self mathSymbolPro ifNotNil: [ :symbol | result add: symbol ].
	self mathSymbolSmalltalk ifNotNil: [ :symbol | result add: symbol ].
	^ result.
]

{ #category : #private }
MathExpression class >> parenthesisBegin [
	"Used for printing, and also by parser"
	^ $(.
]

{ #category : #private }
MathExpression class >> parenthesisEnd [
	"Used for printing, and also by parser"
	^ $).
]

{ #category : #mathematics }
MathExpression class >> precedence [
	"A number to determine the precedence versus another expression.. for instance.. * runs prior +"
	^ 0.

	"NOTE: Is not called 'priority' on purpose. For parenthesis, people say they have high priority
	but actually they get solved last after all the inner expressions. So they will seem like low priority.
	Therefore, the parenthesis have lower precedence vs the inner expression (solved last)."
]

{ #category : #validation }
MathExpression class >> safeguard: objectToWrap [
	"Ensures to return an expression, no matter what is the input, a number, a number as text, a constant name, or an expression"

	"A) Notice that I do NOT use 'self' for this comparison, because on subclasses this becomes false!"
	(objectToWrap isKindOf: MathExpression) ifTrue: [ ^ objectToWrap ].

	"B) 12.34 => .. not using isNumber because evaluates and may fail"
	(objectToWrap isKindOf: Number) ifTrue: [ ^ MathExpNumber value: objectToWrap ].

	"C) Especially for derivative.. I allow a symbol like #x to become Variable"
	(MathExpVariable variableNameValidation: objectToWrap) ifTrue: [ ^ MathExpVariable symbol: objectToWrap ].

	"D) '23.45' => [Constant expression] 23.45"
	(MathExpNumber numberValidation: objectToWrap) ifTrue: [ ^ MathExpNumber numericToNumber: objectToWrap ].

	"Parser must have an undocumented 'feature'"
	self error: 'The class ' , objectToWrap className , ' valued "' , (objectToWrap asString) , '" couldn''t be processed.'.

	"NOTE: I don't want more methods in Object, there are so many already, I prefer to test for isKindOf rather than isXYZ because this is only used for parsing"
]

{ #category : #mathematics }
MathExpression >> * anExpression [
	"Creates another expression to represent the multiplication of the receiver and the argument"
	^ MathExpMultiplication leftSide: self rightSide: anExpression.
]

{ #category : #mathematics }
MathExpression >> ** anExpression [
	"Creates another expression to represent the power of the receiver to the argument"
	^ MathExpPower leftSide: self rightSide: anExpression.
]

{ #category : #mathematics }
MathExpression >> + anExpression [
	"Creates another expression to represent the sum of the receiver and the argument"
	^ MathExpAddition leftSide: self rightSide: anExpression.
]

{ #category : #mathematics }
MathExpression >> - anExpression [
	"Creates another expression to represent the difference between the receiver and the argument"
	^ MathExpSubtraction leftSide: self rightSide: anExpression.
]

{ #category : #mathematics }
MathExpression >> / anExpression [
	"Creates another expression to represent the division of the receiver by the argument"
	^ MathExpDivision leftSide: self rightSide: anExpression.
]

{ #category : #comparing }
MathExpression >> = anExpression [
	"Most classes delegate to the subexpression(s), so only a few implementations should be needed"
	self subclassResponsibility.
]

{ #category : #mathematics }
MathExpression >> abs [
	"Creates another expression to represent the absolute value of the receiver"
	^ MathExpAbsoluteValue on: self.
]

{ #category : #mathematics }
MathExpression >> arcCos [
	"Creates another expression to represent the arcCosine of the receiver"
	^ MathExpArcCosine on: self.
]

{ #category : #mathematics }
MathExpression >> arcSin [
	"Creates another expression to represent the arcSine of the receiver"
	^ MathExpArcSine on: self.
]

{ #category : #mathematics }
MathExpression >> arcTan [
	"Creates another expression to represent the arcSine of the receiver"
	^ MathExpArcTangent on: self.
]

{ #category : #converting }
MathExpression >> asBlock [
	"Returns a Smalltalk Block of code that you can use as another way to evaluate the expression (if not using #asNumber)."
	| temp |
	temp := String streamContents: [ :s |
		| allVariables |
		"Open block"
		s nextPut: $[; nextPut: Character space.
		"Variables (sort them by name since they are in a set.. always code tidy!"
		allVariables := self variables sorted: [ :v1 :v2  | v1 symbol < v2 symbol ].
		allVariables isNotEmpty ifTrue: [
			allVariables do: [ :v | s nextPut: $: ; nextPutAll: v symbol asString ; nextPut: Character space ].
			s nextPut: $| ; nextPut: Character space.
		].
		"Write the expression"
		self codeOn: s.
		"Close block"
		s nextPut: Character space; nextPut: $].
	].
	"Now I got the final code, make it a block.."
	^ BlockClosure readFromString: temp.
]

{ #category : #converting }
MathExpression >> asFraction [
	"With 'Fraction' means Division. Basically x as fraction is x/1 (mainly for simplification). Division should do nothing, of course."
	^ self / MathExpNumber one.
]

{ #category : #converting }
MathExpression >> asMathExpression [
	"The idea is to add 'asExpression' in Number class and create expressions without constructing them manually: { 3 asExpression cos }"
	^ self.
]

{ #category : #converting }
MathExpression >> asNumber [
	"Evaluates the mathematical expression into a number. That assumes all Variables have been assigned a value. Use #isNumber to check."
	self subclassResponsibility.
]

{ #category : #testing }
MathExpression >> asNumberSatisfy: aBlockCondition [
	"Recursively will calculate the value and compare. Saves you the check for isNumber and asNumber."
	"An expression such as { sin(x) } will return false."
	^ self isNumber and: [ aBlockCondition value: self asNumber ].

	"MathExpNumber two asNumberSatisfy: [ :value | value even ]"

	"NOTE: I didnt name this method 'isNumber:' because in NumberParser has different meaning."
]

{ #category : #converting }
MathExpression >> asPower [
	"Instead of coding simplification for x / x and x^2/x and so forth, it is easier to treat all as power."
	^ self ** MathExpNumber one.
]

{ #category : #converting }
MathExpression >> asProduct [
	"With 'Product' means Multiplication. Basically x as product is x*1 (mainly for simplification). Multiplication should do nothing, of course."
	^ self * MathExpNumber one.
]

{ #category : #testing }
MathExpression >> canRewriteCommutative [
	"Allow writing commutative (for instance.. a - b => a + (-b). Decided to compare class rather than 5 fixed methods."
	^ self class isBasicOperator.
]

{ #category : #printing }
MathExpression >> codeOn: aStream [
	"Code the mathematical expression as a Smalltalk Block, so can be executed, for instance in Roassal."
	self subclassResponsibility.
]

{ #category : #testing }
MathExpression >> convertToNumber: aResultBlock [
	"Is the value simple enough to display? For instance: sqrt(2) better keep like that rather than 1.4142135623730951"
	| total temp keepCurrent |

	self isNumber ifFalse: [ ^ self ]. "Must be number"

	"Calculate now.. may involve nested operations so do it once"
	total := [ self asNumber ] on: Exception do: [ ^ self ]. "To avoid fail new operations"

	"By now I am 100% sure is a Number (including a fraction)"

	"Swap?"
	(self class = MathExpNumber) ifFalse: [

		"Try to fix.. 0.05 asFraction >> (1152921504606847/2305843009213693952)"
		temp := total asFraction.
		keepCurrent := (total asString size <= temp asString size).
		keepCurrent ifFalse: [ total := temp ].

		"Smalltalk Fraction are simple as it can be.. otherwise.. not too many digits.. "
		(total isKindOf: Fraction) not & (MathExpNumber isEasyReadNumber: total) not ifTrue: [ ^ self ].

	].

	"Execute the block now"
	^ aResultBlock value: total.
]

{ #category : #mathematics }
MathExpression >> cos [
	"Creates another expression to represent the cosine of the receiver"
	^ MathExpCosine on: self.
]

{ #category : #mathematics }
MathExpression >> cubed [
	"Will answer something like: { x ^ 3 }"
	^ self ** MathExpNumber three.
]

{ #category : #mathematics }
MathExpression >> degree [
	"Degree of a polynomial."
	^ 0.
]

{ #category : #converting }
MathExpression >> derivativeFor: aVariableExpression [
	"Returns a new expression representing the derivative of the receiver for the variable { d/dx(x^2) = 2*x }"
	self subclassResponsibility.
]

{ #category : #testing }
MathExpression >> equalsHalfPi [
	"This is often used in trigonometric parts. I try to avoid 'asNumber' due to rounding."
	^ self asNumberSatisfy: [ :value | value closeTo: (Float pi / 2) ].
]

{ #category : #testing }
MathExpression >> equalsMinusHalfPi [
	"This is often used in trigonometric parts. I try to avoid 'asNumber' due to rounding."
	^ self asNumberSatisfy: [ :value | value closeTo: (Float pi / -2) ].
]

{ #category : #testing }
MathExpression >> equalsPi [
	"This is often used in trigonometric parts. I try to avoid 'asNumber' due to rounding."
	(self = MathExpUniversalConstant pi) ifTrue: [ ^ true ].
	^ self asNumberSatisfy: [ :value | value closeTo: Float pi ].
]

{ #category : #accessing }
MathExpression >> evaluate: aVariableName with: aValue [
	"Searchs by name and apply the value, returning the another expression."
	"Notice this is not the same as assigning a value to the variable and call asNumber. This reduces the expression to a manageable one"
	| foundVariable |
	foundVariable := self variable: aVariableName.
	foundVariable value: aValue asNumber.
	
	"Do not assume is a number, could have two variables, therefore simplify will do the best"
	^ self simplify.
	
	"NOTE: Calling assigning '40' to 'x' and calling asNumber on { x^10 } will calculate 10485760000000000."
	"But calling evaluate will determine that is best to keep the expression as a power for easy reading."
]

{ #category : #testing }
MathExpression >> even [
	"To have the same as Number."
	^ self asNumberSatisfy: [ :value | value even ].
]

{ #category : #mathematics }
MathExpression >> exp [
	"Creates another expression to represent the exponential of the receiver { e ^ x .. where 'e' is Euler's number }"
	^ MathExpUniversalConstant e ** self.
	
	"NOTE: Copied from Smalltalk but I must say is a bit of a strange method."
]

{ #category : #converting }
MathExpression >> expand [
	"This is the opposite of Factoring { a + (b * x) => a*b + a*x }."
	"To avoid checking each time returns self"
	^ self.
]

{ #category : #comparing }
MathExpression >> hash [
	"To implement on each subclass, each of them consider the equality differently (making it abstract here to ensure is implemented later)"
	self subclassResponsibility.
]

{ #category : #testing }
MathExpression >> ifNotNumber: numberBlock [
	"Rather than writing 'x isNotNumber ifTrue: [ .. ]' / 'x isNumber ifFalse: [ .. ]'"
	^ self isNumber ifFalse: numberBlock.
]

{ #category : #testing }
MathExpression >> ifNumber: numberBlock [
	"Rather than writing 'x isNumber ifTrue: [ .. ]'"
	^ self isNumber ifTrue: numberBlock.
]

{ #category : #testing }
MathExpression >> ifNumber: numberBlock ifNotNumber: notNumberBlock [
	"Rather than writing 'x isNumber ifTrue: [ .. ] ifFalse: [ .. ]'"
	^ self isNumber ifTrue: numberBlock ifFalse: notNumberBlock.
]

{ #category : #testing }
MathExpression >> isAssociative [
	"Mathematical property: Answer if { a + (b + x) => (a + b) + x }"
	^ (self class == MathExpAddition) | (self class == MathExpMultiplication).

	"Question: Why you put the class here?"
	"Answer: The associative operations wont change any time soon, simpler to read, less methods later"
]

{ #category : #testing }
MathExpression >> isCommutative [
	"Mathematical property: Answer if { a + x => x + a .. or .. x * b => b * x }"
	^ (self class == MathExpAddition) | (self class == MathExpMultiplication).

	"Question: Why you put the class here?"
	"Answer: The associative operations wont change any time soon, simpler to read, less methods later"
]

{ #category : #testing }
MathExpression >> isDistributive [
	"Mathematical property: Answer if { a * (b + c) => a * b + a * c }"
	^ self class == MathExpMultiplication.
]

{ #category : #testing }
MathExpression >> isExpandable [
	"This is the opposite of Factoring. Allows non associative and non commutative to get tidy up."
	^ false.
]

{ #category : #testing }
MathExpression >> isFraction [
	"A bit of a override for Number"
	^ (self isKindOf: MathExpDivision) or: [ self asNumberSatisfy: [ :value | value isFraction ] ].
]

{ #category : #testing }
MathExpression >> isMathConstant [
	"Some instances query for this, and parser too, therefore is on both sides to reduce code."
	^ self class isMathConstant.
]

{ #category : #testing }
MathExpression >> isMinusOne [
	"Recursively will calculate the value and compare. Saves you the check for isNumber and asNumber"
	^ self asNumberSatisfy: [ :value | value = -1 ].
]

{ #category : #testing }
MathExpression >> isNotNumber [
	"Simply here to reduce code and avoid the 'not' after a boolean"
	^ self isNumber not.
]

{ #category : #testing }
MathExpression >> isNotZero [
	"Recursively will calculate the value and compare. Saves you the check for isNumber and asNumber"
	^ self asNumberSatisfy: [ :value | value ~= 0 ].

	"Normally to avoid things like: { x / 0 => ! }"
]

{ #category : #testing }
MathExpression >> isNumber [
	"Evaluates if the mathematical expression is a number. That assumes all Variables have been assigned a value. Use #asNumber to get the value."
	self subclassResponsibility.
]

{ #category : #testing }
MathExpression >> isNumericConstant [
	"Some instances query for this, and parser too, therefore is on both sides to reduce code."
	^ self class isNumericConstant.
]

{ #category : #testing }
MathExpression >> isOne [
	"Recursively will calculate the value and compare. Saves you the check for isNumber and asNumber"
	^ self asNumberSatisfy: [ :value | value = 1 ].
]

{ #category : #testing }
MathExpression >> isZero [
	"Recursively will calculate the value and compare. Saves you the check for isNumber and asNumber"
	^ self asNumberSatisfy: [ :value | value = 0 ].
]

{ #category : #mathematics }
MathExpression >> ln [
	"Creates another expression to represent the natural logarithm of the receiver"
	^ MathExpLogarithmBaseE on: self.
]

{ #category : #mathematics }
MathExpression >> log [
	"Creates another expression to represent the base-10 logarithm of the receiver"
	^ MathExpLogarithmBaseTen on: self.
]

{ #category : #mathematics }
MathExpression >> log2 [
	"Creates another expression to represent the base-2 logarithm of the receiver"
	^ MathExpLogarithmBaseTwo on: self.

]

{ #category : #mathematics }
MathExpression >> log: anExpression [
	"This in Smalltalk is a bit confusing.. #log is base 10, #log: is base N"
	"Also gets confused with Object>>log: which is for logging."
	^ self logarithm: anExpression.
]

{ #category : #mathematics }
MathExpression >> logarithm: anExpression [
	"Creates another expression to represent the sum of the receiver and the argument"
	^ MathExpLogarithm leftSide: self rightSide: anExpression.
]

{ #category : #mathematics }
MathExpression >> mathSymbol [
	"This is the default symbol understood in Math for this expression { sin, cos, +, etc }."
	"Instance call this normally to print, which is also call on creation by the parser."
	^ self class mathSymbol.

	"NOTE: Normally the class knows what to do, since 1 class = 1 expression, except Numbers and Variables."
]

{ #category : #mathematics }
MathExpression >> mathSymbolPro [
	"Some symbols are per instance (like variables), but most are class level."
	^ self class mathSymbolPro.

	"NOTE: Normally the class knows what to do, since 1 class = 1 expression, except Numbers and Variables."
]

{ #category : #mathematics }
MathExpression >> mathSymbolSmalltalk [
	"Some symbols are per instance (like variables), but most are class level."
	^ self class mathSymbolSmalltalk.

	"NOTE: Normally the class knows what to do, since 1 class = 1 expression, except Numbers and Variables."
]

{ #category : #mathematics }
MathExpression >> negated [
	"Creates another expression to represent the negative value of the receiver { - x }"
	^ MathExpNegative on: self.

	"NOTE: The negative expression and the constant class may override this for simplicity"
]

{ #category : #testing }
MathExpression >> negative [
	"To have the same as Number."
	^ self asNumberSatisfy: [ :value | value < 0 ].
]

{ #category : #mathematics }
MathExpression >> nthRoot: anExpression [
	"Creates another expression to represent the nth root of the receiver"
	^ self ** (MathExpNumber one / anExpression).
]

{ #category : #testing }
MathExpression >> odd [
	"To have the same as Number."
	^ self asNumberSatisfy: [ :value | value odd ].
]

{ #category : #testing }
MathExpression >> positive [
	"To have the same as Number."
	^ self asNumberSatisfy: [ :value | value > 0 ].
	
	"NOTE: Smalltalk considers zero positive, not sure what that is about."
]

{ #category : #printing }
MathExpression >> printOn: aStream [
	"Print the mathematical expression as humans read it."
	"Notice this should be consistent with the way the parser expects such as: { 1 + 2 * 3 => 1 + (2 * 3) }."
	self subclassResponsibility.
]

{ #category : #mathematics }
MathExpression >> raisedTo: anExpression [
	"I coded opposite to Smalltalk because raisedTo is less used that **"
	^ self ** anExpression.
]

{ #category : #mathematics }
MathExpression >> reciprocal [
	"Same as in Number or in Fraction, divide one by the receiver"
	^ MathExpNumber one / self.
]

{ #category : #testing }
MathExpression >> relatedTo: anExpression [
  "Returns true for cases like { x + (x.y) } or { 5 + 8 }. This lets prepare for simplification"
  ^ (self = anExpression)
             "similar expression (generic)"
    or: [ (self termOrder = anExpression termOrder)
                "both just numbers (move to Number)"
          or: [ (self isNumericConstant & anExpression isNumericConstant)
                      "same type of thing (generic?)"
                or: [ ((self class = anExpression class) & (self variables & anExpression variables) isNotEmpty)
                            "share variable or term.. like.. x and x^2.. here is the fuss"
                      or: [ ((self termOrder includesSubstring: anExpression termOrder) |
											(anExpression termOrder includesSubstring: self termOrder)) &
                            ((self variables & anExpression variables) isNotEmpty) ]
                    ]
              ]
          ].

	"NOTE: A bit in a rush to complete may want some improvement"
]

{ #category : #converting }
MathExpression >> replace: searchExpression with: replaceExpression [
	"Used to replace a subexpression for another. Should be only required on first subclasses."
	"It would stop automatically once replaced, so it wont do recursive replace."
	"Notice it does not simplify automatically, that way can display progress."

	"Example: { y + x = 5 , y - x = 2 } solve for 'y' { y = 2 + x } => { (2 + x) + x = 5 }"
	self subclassResponsibility.
]

{ #category : #private }
MathExpression >> runSimplifyRulesTrailOn: aTrail [
	"Does the real simplification per operation. New operations should override this."
	self subclassResponsibility.
]

{ #category : #accessing }
MathExpression >> settings [
	"If set.. will return the one selected.. otherwise the system default."
	^ settings ifNil: [ MathemagicsSettings default ] ifNotNil: [ settings ].
]

{ #category : #accessing }
MathExpression >> settings: selectedSettings [
	"Normally global is enough but you can choose differently."
	settings := selectedSettings.
]

{ #category : #converting }
MathExpression >> simplify [
	"Returns a simpler expression equivalent to the receiver. Should not override this."
	^ self runSimplifyRulesTrailOn: nil. "lazy initialization"
]

{ #category : #private }
MathExpression >> simplifyInto: aNewForm trail: aTrail [
	"Register that this expression mutates to another.. and keep track is not a recursion freeze"
	
	"NOTE: This is never call on a variable or number, is really like a final method"
	| temp |

	"has the item.. stop recursion.. I choose the latest"
	aTrail ifNotNil: [ (aTrail includes: self) ifTrue: [ ^ aNewForm ] ].

	"If I was saving the creation.. has no choice now"
	temp := aTrail ifNil: [ Set new ].

	"track"
	temp add: self.

	"Because new expressions get created in many places, this is the best place to spread settings"
	aNewForm settings: self settings.

	"Call low-level simplify (programmer should override the method below)"
	^ aNewForm runSimplifyRulesTrailOn: temp.
]

{ #category : #mathematics }
MathExpression >> sin [
	"Creates another expression to represent the sine of the receiver"
	^ MathExpSine on: self.
]

{ #category : #mathematics }
MathExpression >> sqr [
	"Will answer something like: { sqr(x) } but not { x^2 }"
	^ MathExpSqr leftSide: self rightSide: MathExpNumber two.
	
	"NOTE: Create a specialised class to show as function"
]

{ #category : #mathematics }
MathExpression >> sqrt [
	"Use the special expression, but stil pass the right parameter.."
	^ MathExpSquareRoot leftSide: self rightSide: MathExpNumber oneHalf.
]

{ #category : #mathematics }
MathExpression >> squareRoot [
	"A bit clearer to read and avoid confusion with '5 sqr'.."
	^ self sqrt
]

{ #category : #mathematics }
MathExpression >> squared [
	"Will answer something like: { x ^ 2 } but not { sqr(x) }. The name to match 'cubed'."
	^ self ** MathExpNumber two.
]

{ #category : #mathematics }
MathExpression >> strictlyNegative [
	"You may think I wanted to look smart and do my version of strictlyPositive in Smalltalk, but noap"
	"Some expressions like the unary negative or a negative constant is always negative, but { -2*x } may not be"
	^ (self class = MathExpNegative) or: [ (self isMathConstant) | (self isNumericConstant) and: [ self asNumber negative ] ].

	"NOTE: Do we consider { - ( - 5 ) } negative? No, but { -5 } is negative although gets reduced to positive. Same here."
]

{ #category : #mathematics }
MathExpression >> tan [
	"Creates another expression to represent the tangent of the receiver"
	^ MathExpTangent on: self.
]

{ #category : #mathematics }
MathExpression >> termOrder [
	"String to allow quickly sorting terms in the expression without nested compare."
	
	"For instance.. { 4^z - 7^20 + 6 + x + x^2 + x^z + (-y) => x^z + x^2	4^z + x - y - 7^20 + 6 }"
	self subclassResponsibility.

	"This sort by variable and power, not by structure:"
	"A  - Power of a variable goes first"
	"B  - Variables"
	"C  - Power to variable exponents"
	"... (future gap)"
	"F  - Function on variables"
	"... (future gap)"
	"H  - Numbers (simplification)"
	"... (future gap)"
	"J  - Power of constants"
	"K? - Mathematical constants (Fpi)"
	"... (future gap)"
	"U  - Unclassified"

	"Notice other binaries do not affect sorting"
	"Unary will pass it to the subexpression"
]

{ #category : #printing }
MathExpression >> utilCodeSymbolOnto: aStream [
	"Utility method: Symbol goes with spaces"
	self utilPrintSpaceOn: aStream.
	self utilMathSymbolCodedOn: aStream.
	self utilPrintSpaceOn: aStream.
]

{ #category : #printing }
MathExpression >> utilCodeTerm: anObject onto: aStream [
	"Utility method: Same like the other method but with parenthesis because is extremely common and reduces IFs"
	self utilPrintParenthesisBeginOn: aStream.
	anObject codeOn: aStream.
	self utilPrintParenthesisEndOn: aStream.
]

{ #category : #printing }
MathExpression >> utilMathSymbolCodedOn: aStream [
	"Utility method: At least one of the two default symbols must be supported"
	self utilPrint: (self mathSymbolSmalltalk ifNil: [ self mathSymbol ] ) onto: aStream.
]

{ #category : #printing }
MathExpression >> utilMathSymbolPrintedOn: aStream [
	"Utility method: Simpler syntax and to avoid duplication"
	| symbolToPrint |
	"default.. easier code"
	symbolToPrint := self mathSymbol.
	(self settings prettyMathSymbols) and: [ self mathSymbolPro ifNotNil: [ :value | symbolToPrint := value ] ].
	"Use whatever you got"
	self utilPrint: symbolToPrint onto: aStream.
]

{ #category : #printing }
MathExpression >> utilPrint: anObject onto: aStream [
	"Utility method: Avoid the error between nextPut or nextPutAll, and clears the syntax, and avoid mistake of recursion printing self"
	(self == anObject) ifTrue: [ ^ self ].
	"For speed... a bit .. obsessive but.. also the Character prints quotes if converted as String!!!"
	anObject isCharacter ifTrue: [ aStream nextPut: anObject ] ifFalse: [ aStream nextPutAll: anObject asString ].
]

{ #category : #printing }
MathExpression >> utilPrint: anObject useParenthesis: useParenthesis onto: aStream [
	"Utility method: Same like the other method but with parenthesis because is extremely common and reduces IFs"
	useParenthesis ifTrue: [ self utilPrintParenthesisBeginOn: aStream ].
	self utilPrint: anObject onto: aStream.
	useParenthesis ifTrue: [ self utilPrintParenthesisEndOn: aStream ].
]

{ #category : #printing }
MathExpression >> utilPrintParenthesisBeginOn: aStream [
	"Utility method: Simpler syntax and to avoid duplication"
	self utilPrint: (self class parenthesisBegin) onto: aStream.
	(self settings spacedBracketed) ifTrue: [ self utilPrintSpaceOn: aStream ].
]

{ #category : #printing }
MathExpression >> utilPrintParenthesisEndOn: aStream [
	"Utility method: Simpler syntax and to avoid duplication"
	(self settings spacedBracketed) ifTrue: [ self utilPrintSpaceOn: aStream ].
	self utilPrint: (self class parenthesisEnd) onto: aStream.
]

{ #category : #printing }
MathExpression >> utilPrintSpaceOn: aStream [
	"Utility method: Simpler syntax and to avoid duplication"
	self utilPrint: (Character space) onto: aStream.
]

{ #category : #accessing }
MathExpression >> variable: aVariableName [
	"I allow to pass a Character, Symbol, String to find the variable"
	self assert: aVariableName isNotNil description: 'Variable name needed but nil received'.

	"Notice that I assume you have built the expression with a one variable per name. For instance, only one x variable."
	^ self variables detect: [ :each | each symbol asSymbol = aVariableName asSymbol ] ifFound: [ :found | ^ found ] ifNone: [ nil ].
]

{ #category : #accessing }
MathExpression >> variables [
	"Returns a #Set of variables from this expression downward. Since it is called on any expression, Constants return an empty set."
	^ self subclassResponsibility.
]

{ #category : #printing }
MathExpression >> wantsParenthesisUnder: parentExpression [
	"Container of the expression is passed. For instance, { -x } may want a parenthesis for { (-x)^2 } but { sin(-x) } already always write parenthesis."
	"Default behaviour: Wants parenthesis if this operation has less priority than the parent"
	^ (self class precedence) < (parentExpression class precedence) & (self class isFunction not).

	"NOTE: Functions appear across the hierarchy so the check is here, the tree is not based on function but on subexpressions"
]
