"
Class part:

	This is to have some generic conversion messages. Trigonometric functions are very complex, so this class is just to have a single point of access, more than behavior. When calculates is assumed the subexpression is expressed in radians.

Properties:

	- It will try to round when possible. For instance: { (Float pi / 2) cos } does not return zero but this operation does.
	- Support some automated simplifications { sin(pi * 2) => sin(0) }.

		(MathExpression from: ' sin(pi/2 + pi*8) ') simplify.

"
Class {
	#name : #MathExpTrigonometricFunction,
	#superclass : #MathExpUnary,
	#category : #'Mathemagics-Core-FunctionsCircle'
}

{ #category : #testing }
MathExpTrigonometricFunction class >> isAbstract [
	^ self == MathExpTrigonometricFunction.
]

{ #category : #private }
MathExpTrigonometricFunction >> runSimplifyRulesTrailOn: aTrail [
	"For radians, 2Pi or more can be reduced { sin(8*Pi + Pi/2) => sin(Pi/2) }"

	self subexpression ifNumber: [
		| numericValue signedFactor delta |
		"Get the complicated number.. probably 4pi"
		numericValue := self subexpression asNumber.
		"more than 2*pi?"
		(numericValue abs >= Float twoPi) ifTrue: [
			"How many times to remove pi-ness?"
			signedFactor := (numericValue / Float twoPi) truncated.
			delta := MathExpUniversalConstant pi * (signedFactor * 2).
			"Remove the round-the-clock 2*pi loops.."
			^ self simplifyInto: (self rewriteOn: subexpression - delta)  trail: aTrail.
		].
	].

	"Trigonometric functions manipulate messy numbers.. I attempt to recover from that.."
	self ifNumber: [
		| unpreciseNumber |
		unpreciseNumber := self asNumber.
		"Some trig functions dont get exact 0.. is an aproximation anyway.."
		(unpreciseNumber closeTo: 0) ifTrue: [ ^ MathExpNumber zero ].
		(unpreciseNumber closeTo: 1) ifTrue: [ ^ MathExpNumber one ].
		(unpreciseNumber closeTo: -1) ifTrue: [ ^ MathExpNumber minusOne ].
		"related with Pi"
		(unpreciseNumber closeTo: Float pi) ifTrue: [ ^ MathExpUniversalConstant pi ].
		(unpreciseNumber closeTo: Float pi negated) ifTrue: [ ^ MathExpUniversalConstant pi negated ].
		(unpreciseNumber closeTo: Float halfPi) ifTrue: [ ^ MathExpUniversalConstant pi / 2 ]. 
		(unpreciseNumber closeTo: Float halfPi negated) ifTrue: [ ^ MathExpUniversalConstant pi negated / 2 ]. 
	].

	"Generic simplification"
	^ super runSimplifyRulesTrailOn: aTrail.
]
