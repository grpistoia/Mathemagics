"
Opens the correct calculator. That way you dont need to know if the version is already implemented for Spec1 or Spec2 or something else.

	""This opens the calculator empty""
	Calculator open. a CalculatorSpec1


	""This shows some demo expressions""
	Calculator example4_UsingParser.

Contact:
	Gustavo Pistoia.
	See help class for more information.
"
Class {
	#name : #Calculator,
	#superclass : #Object,
	#category : #'Mathemagics-Tools-Apps'
}

{ #category : #'instance creation' }
Calculator class >> example1_NoHistory [
	"Just to be able to click in the icon.. same as #open"
	^ self open.
]

{ #category : #'instance creation' }
Calculator class >> example2_UsingLongConstructors [
	"Notice this is the hardest way to create the expressions.. by hand."
	| myApp demos |

	"Create the calculator and show"
	myApp := self open.
	
	"A few examples to show the parser"
	demos := OrderedCollection new.
	"cos(pi/2) : Notice '2' is converted as expression on the fly when is a parameter"
	"Also.. this returns a perfect zero where { Float halfPi cos } does not "
	demos add: (MathExpCosine on: (MathExpDivision leftSide: MathExpUniversalConstant pi rightSide: 2)).

	"THIS METHOD NEEDS TO BE IMPLEMENTED IN CALCULATORS.."
	(myApp class canUnderstand: #setHistoryStart:) ifTrue: [ myApp setHistoryStart: demos ].
]

{ #category : #'instance creation' }
Calculator class >> example3_UsingOperators [
	"Notice this is the Smalltalky way to create the expressions.. cascading messages."
	| myApp demos |

	"Create the calculator and show"
	myApp := self open.	
	
	"A few examples to show the parser"
	demos := OrderedCollection new.
	"25 sqrt in Smalltalk doesnt match 25 ** 0.5"
	demos add: (MathExpNumber value: 25) sqrt.
	demos add: (MathExpNumber value: 25) ** 0.5.
	"3 * ln(e^x) : Notice I use math operations to create a multiplication, skipping the constructors"
	demos add: MathExpNumber three * (MathExpVariable x exp ln).
	"1 / y + phi : Notice I other operations such as reciprocal are also answered"
	demos add: MathExpVariable y reciprocal + MathExpConstantGoldenRatio new.
		
	"THIS METHOD NEEDS TO BE IMPLEMENTED IN CALCULATORS.."
	(myApp class canUnderstand: #setHistoryStart:) ifTrue: [ myApp setHistoryStart: demos ].
]

{ #category : #'instance creation' }
Calculator class >> example4_UsingParser [
	"Notice this is the simplest and more intuitive way to create the expressions.. with the parser."
	| myApp demos |

	"Create the calculator and show"
	myApp := self open.	
	
	"A few examples to show the parser"
	demos := OrderedCollection new.
	demos add: (MathExpression from: 'cos(pi/2)'). "Smalltalk wouldnt return 0"
	demos add: (MathExpression from: 'x / log(10^x) + x'). "log of a base becomes nothing"
	demos add: (MathExpression from: '(6 * x^y ) / (3 * x)'). "reduces to x"
	demos add: (MathExpression from: 'sqr( -volume ) / volume'). "long variables"
	demos add: (MathExpression from: 'sqrt(x ^ 2) ^ 3'). "Notice sqrt is like power"
	
	"THIS METHOD NEEDS TO BE IMPLEMENTED IN CALCULATORS.."
	(myApp class canUnderstand: #setHistoryStart:) ifTrue: [ myApp setHistoryStart: demos ].
]

{ #category : #'world menu' }
Calculator class >> menuCommandOn: aBuilder [
	<worldMenu>
	(aBuilder item: self asString)
		action: [ self open ];
		order: 15;
		parent: #Tools;
		help: 'Opens a calculator.';
		iconName: #keymapBrowser.
]

{ #category : #'instance creation' }
Calculator class >> open [
	"Start a fresh calculator"
	^ CalculatorSpec1 open.
]

{ #category : #'see class side' }
Calculator >> seeClassSide [
]
