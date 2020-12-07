"
Class part: The idea is to have a unique place where we define all formulas, mathematical ones, physics, finance, and so forth. We can use the ""protocol"" to group them, and keep expanding this pseudo repository. After all, how many times we actually type the same formula. Now with the ability of returning an expression (in the future a Formula object itself), we don't need to code the same thing over and over.

Responsibility: Group formulas by type, and evaluate the formulas on demand. Formulas should receive parameters that could be Number or a mathematical expression. In time we could pass an expression to a formula and all should miraculously work (this part is where software and religion merge).

EXAMPLE 1: Build something like:  { f(x) = x^2 - 5*x - 14 }

	| x fx |
	x := MathExpVariable x.
	fx := self quadraticEquationOnX: x withA: 3 withB: 10 withC: -8.

	returns... f(x) = a*x^2 + b*x + c = 3*x^2 + 10*x - 8

EXAMPLE 2: Calculate the area of a circle with a radious 'r'

	| r a |
	r := MathExpVariable symbol: 'r'.
	a := self circleAreaForRadius: r.

	returns... a = pi * r^2

Collaborators Part: Relies heavily on MathExpressions and the Number class/subclasses.

Public API: Since it is really a Library, all behaviour is creational and would be on the class side.

Key Messages: Look at the protocols.

Implementation Points: Please implement new methods to support a Number or a Mathematical Expression.
"
Class {
	#name : #FormulaLibrary,
	#superclass : #Object,
	#category : #'Mathemagics-Tools-Formulas'
}

{ #category : #geometry }
FormulaLibrary class >> circleAreaForRadius: r [
	"The area of a circle with radius r is: pi * r^2"
	^ (MathExpUniversalConstant pi * ((MathExpression safeguard: r) squared)) simplify.

	"self circleAreaForRadius: 4"
	"self circleAreaForRadius: (MathExpVariable y)"
]

{ #category : #geometry }
FormulaLibrary class >> circleCircumferenceForRadius: r [
	"The circumference of a circle with radius r is: 2 * pi * r"
	^ MathExpNumber two * MathExpUniversalConstant pi * (MathExpression safeguard: r).

	"self circleCircumferenceForRadius: 3"
	"self circleCircumferenceForRadius: MathExpVariable y"
]

{ #category : #mathematics }
FormulaLibrary class >> pythagoreanEquationForA: a andB: b [
	"Returns the expression representing c = sqrt( a^2 + b^2 )"
	| a2 b2 |
	a2 := (MathExpression safeguard: a) squared.
	b2 := (MathExpression safeguard: b) squared.
	^ ((a2 + b2) squareRoot) simplify.

	"self pythagoreanEquationForA: 3 andB: 4"
]

{ #category : #mathematics }
FormulaLibrary class >> quadraticEquationOnX: x withA: a withB: b withC: c [
	"Returns the expression representing f(x) = a*x^2 + b*x + c"
	| vX term1 term2 term3 fx |
	vX := MathExpression safeguard: x.
	term1 := (MathExpression safeguard: a) * (vX squared).
	term2 := (MathExpression safeguard: b) * vX.
	term3 := (MathExpression safeguard: c).
	fx := term1 + term2 + term3.
	^ fx simplify.

	"NOTE: Remember you can pass a Variable and set the #value of the variable and then just use #asNumber"
	"self quadraticEquationOnX: (MathExpVariable x) withA: 2 withB: 5 withC: 3"
]

{ #category : #finance }
FormulaLibrary class >> simpleInterestOnPrincipal: principal withInterestPerPeriod: percentage onTotalPeriods: periods [
	"Total (principal plus interest) for the 'rate' during the 'periods'"
	| p r t |
	p := MathExpression safeguard: principal.
	r := (MathExpression safeguard: percentage) / MathExpNumber oneHundred.
	t := MathExpression safeguard: periods.
	^ (p * r * t) simplify.

	"self simpleInterestOnPrincipal: 200000 withInterestPerPeriod: 30 onTotalPeriods: 30 "
]

{ #category : #finance }
FormulaLibrary class >> simpleInterestPlusPrincipal: principal withInterestPerPeriod: percentage onTotalPeriods: periods [
	"Total (principal plus interest) for the 'rate' during the 'periods'"
	| p r t |
	p := MathExpression safeguard: principal.
	r := (MathExpression safeguard: percentage) / MathExpNumber oneHundred.
	t := MathExpression safeguard: periods.
	^ p * ((r * t) + 1) simplify.

	"self simpleInterestPlusPrincipal: 200000 withInterestPerPeriod: 3 onTotalPeriods: 30 "
]

{ #category : #geometry }
FormulaLibrary class >> sphereSurfaceAreaForRadius: r [
	"The surface area of a sphere with radius r is: 4 * pi * r^2."
	^ (MathExpNumber four * (MathExpUniversalConstant pi) * ((MathExpression safeguard: r) squared)) simplify.

	"self sphereSurfaceAreaForRadius: 3"
	"self sphereSurfaceAreaForRadius: MathExpVariable y"
]

{ #category : #geometry }
FormulaLibrary class >> sphereVolumeForRadius: r [
	"The volume of a sphere with radius r is: 4/3 * pi * r^3."
	^ ((MathExpNumber four / MathExpNumber three) * (MathExpUniversalConstant pi) * ((MathExpression safeguard: r) cubed)) simplify.

	"self sphereVolumeForRadius: 8"
	"self sphereVolumeForRadius: MathExpVariable x"
]

{ #category : #'see class side' }
FormulaLibrary >> seeClassSide [
]
