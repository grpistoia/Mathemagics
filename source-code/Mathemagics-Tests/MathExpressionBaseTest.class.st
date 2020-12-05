"
The tests will normally create expressions, variables and cache highly used numbers, therefore a main class was created to avoid repetition.

Notice this class has some constants that are reused in all tests.
"
Class {
	#name : #MathExpressionBaseTest,
	#superclass : #TestCase,
	#instVars : [
		'prettySettings',
		'testSettings',
		'x',
		'y',
		'pi',
		'e',
		'minusTwo',
		'minusOne',
		'zero',
		'one',
		'two',
		'three',
		'four',
		'five',
		'six',
		'seven',
		'eight',
		'nine',
		'ten'
	],
	#category : #'Mathemagics-Tests-Debug'
}

{ #category : #'building suites' }
MathExpressionBaseTest class >> buildSuite [
	"The #isAbstract is not working right.."
	| suite |	
	"Only the suppa"
	(self == MathExpressionBaseTest) ifFalse: [ ^ super buildSuite ].
	
	"Build a mini test with all subclasses tests.."
	suite := TestSuite named: self name asString.
	self allSubclasses do: [ :each | each isAbstract ifFalse: [ suite addTest: each buildSuiteFromSelectors ] ].
	^ suite.
]

{ #category : #testing }
MathExpressionBaseTest class >> isAbstract [ 
	"Interesting discovery.. runs the test in the subclasses.."
	^ super isAbstract. "self == MathExpressionBaseTest."
	
	"NOTE: In Pharo 8 only works once until the icon is changed to (c)"
]

{ #category : #running }
MathExpressionBaseTest >> setUp [
	super setUp.
	
	"Since setUp is called on each test I will recreate variables with no value assigned"
	x := MathExpVariable x.
	y := MathExpVariable y.

	"I am lazy"
	e := MathExpUniversalConstant e.
	pi := MathExpUniversalConstant pi.

	"To reduce code.. and looks prettier"
	minusTwo := MathExpNumber minusTwo.
	minusOne := MathExpNumber minusOne.
	zero := MathExpNumber zero.
	one := MathExpNumber one.
	two := MathExpNumber two.
	three := MathExpNumber three.
	four := MathExpNumber four.
	five := MathExpNumber five.
	six := MathExpNumber six.
	seven := MathExpNumber seven.
	eight := MathExpNumber eight.
	nine := MathExpNumber nine.
	ten := MathExpNumber ten.

	"I put the likely default.. but user may change.."
	prettySettings := MathemagicsSettings new. "I create my default"
	prettySettings prettyMathSymbols: true.
	prettySettings spacedBracketed: true.
	prettySettings numbersLeadProducts: true.
	prettySettings spacedTerms: true.

	"This I make it different on purpose"
	testSettings := MathemagicsSettings new.
	testSettings prettyMathSymbols: false.
	testSettings spacedBracketed: false.
	testSettings numbersLeadProducts: false.
	testSettings spacedTerms: false.
]
