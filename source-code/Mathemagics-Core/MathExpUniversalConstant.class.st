"
Class part:

	This class allows holding a number (normally an irrational number) that has a Mathematical name (such as 'pi' or sqrt(2) }.

Properties:

	- The derivative of a constant is zero.
	- The call of #asNumber will call the #value that will calculate the value on demand (*).
	- The parser will create each time you write either the name or symbol:

		MathExpression from: ' pi '.
		MathExpression from: ' phi '.
		MathExpression from: ' ln(e) '.

	Read the superclass for more information.
"
Class {
	#name : #MathExpUniversalConstant,
	#superclass : #MathExpValue,
	#category : #'Mathemagics-Core-Numeric'
}

{ #category : #'mathematical constants' }
MathExpUniversalConstant class >> e [
	"Euler's number"
	^ MathExpConstantEulerNumber new.
]

{ #category : #testing }
MathExpUniversalConstant class >> isAbstract [
	^ self == MathExpUniversalConstant.
]

{ #category : #'mathematical constants' }
MathExpUniversalConstant class >> phi [
	"Golden ratio"
	^ MathExpConstantGoldenRatio new.
]

{ #category : #'mathematical constants' }
MathExpUniversalConstant class >> pi [
	"Archimedes' constant"
	^ MathExpConstantPi new.
]

{ #category : #evaluating }
MathExpUniversalConstant class >> value [
	"I shouldn't need to create the class to know the value.."
	self subclassResponsibility.
]

{ #category : #comparing }
MathExpUniversalConstant >> hash [
	"Used by the queue inside the parser"
	^ self class hash.
]

{ #category : #mathematics }
MathExpUniversalConstant >> termOrder [
	"Check superclass for more information"
	^ 'K' , (self mathSymbol asString).
]

{ #category : #evaluating }
MathExpUniversalConstant >> value [
	"Implemented on the class side.. for subclasses"
	^ self class value.
]
