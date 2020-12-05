"
My responsability is to test the mathematical expressions.

There are millions of combinations, which is the complex part of the whole mechanism, so this is done in three basic steps:
- Methods such as 'testMultiplication' run a few typical scenarios using the basic create methods of the class (MathExpMultiplication)
- Methods such as 'testMultiplicationSimplify' use the operators (a * b) instead of the declared constructor while testing the simplification.
- Methdos such as 'testMultiplicationDerivative' use the operators, and invoke derivation which also calls simplification.

In turn there would be tests for other combinations.
"
Class {
	#name : #MathExpressionClassesTest,
	#superclass : #MathExpressionBaseTest,
	#category : #'Mathemagics-Tests-Expressions'
}

{ #category : #tests }
MathExpressionClassesTest >> testAbsoluteValue [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |

	"abs(a) asNumber"
	temp1 := MathExpAbsoluteValue on: nine.
	self assert: temp1 asNumber equals: nine asNumber.

	"abs(b) asNumber"
	temp1 := MathExpAbsoluteValue on: minusTwo.
	self assert: temp1 asNumber equals: two asNumber.

	"abs(0) asNumber"
	temp1 := MathExpAbsoluteValue on: zero.
	self assert: temp1 asNumber equals: zero asNumber.

	"abs(x)"
	temp1 := MathExpAbsoluteValue on: y.
	self assert: temp1 equals: (y abs).
]

{ #category : #tests }
MathExpressionClassesTest >> testAbsoluteValueDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten abs.
	self assert: (fx derivativeFor: x) equals: zero.

	" abs( u )' = u' * (u / abs(u)) "
	fx := x abs.
	dx := x / (x abs).
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.

	" abs( x^2 )' = 2*x * x / abs(x^2) => 2*x^3 / abs(x^2) <=> x^2 is never negative => 2*x^3 / x^2 => 2*x"
	fx := (x ** two) abs.
	dx := two * x.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testAbsoluteValueSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	"Since abs() returns the 'positive form', it does not self-simplify otherwise would disappear"
	| temp1 |
	"abs(+a)"
	temp1 := five abs.
	self assert: temp1 simplify equals: five.
	"abs(-b)"
	temp1 := five negated abs.
	self assert: temp1 simplify equals: five.
	"abs(-0)"
	temp1 := zero negated abs.
	self assert: temp1 simplify equals: zero.  "Requires simplify for consistency"
	"abs(pi)"
	temp1 := pi abs.
	self assert: temp1 simplify equals: pi.
	"abs(-pi)"
	temp1 := pi negated abs.
	self assert: temp1 simplify equals: pi.
	"abs(-y)"
	temp1 := (MathExpVariable y negated) abs.
	self assert: temp1 simplify equals: y abs.
]

{ #category : #tests }
MathExpressionClassesTest >> testAddition [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 temp2 |
	"(a + b + c + d) asNumber"
	temp1 := (seven + eight) + (four + three) + two.
	self assert: temp1 asNumber equals: 7 + 8 + 4 + 3 + 2.
	self assert: temp1 simplify equals: (MathExpNumber value: 7 + 8 + 4 + 3 + 2).
	" (a + b) + c = a + (b + c) "
	temp1 := (three + seven) + nine.
	temp2 := three + (seven + nine).
	self assert: temp1 asNumber equals: temp2 asNumber.
	self assert: temp1 simplify equals: temp2 simplify.
	" a * (b + c) = a * b + a * c "
	temp1 := three * (seven + nine).
	temp2 := (three * seven) + (three * nine).
	self assert: temp1 asNumber equals: temp2 asNumber.
]

{ #category : #tests }
MathExpressionClassesTest >> testAdditionDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten + two.
	self assert: (fx derivativeFor: x) equals: zero.

	" ( u + v )' = u' + v' "
	fx := four + x.
	dx := one.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testAdditionSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	" 0 + n "
	temp1 := zero + six.
	self assert: temp1 simplify equals: six.
	" n + 0 "
	temp1 := five + zero.
	self assert: temp1 simplify equals: five.
	" a + x "
	temp1 := three + x.
	self assert: temp1 simplify equals: x + 3.
]

{ #category : #tests }
MathExpressionClassesTest >> testArcCosine [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"x arcCos"
	temp1 := MathExpArcCosine on: x.
	self assert: temp1 equals: x arcCos.
	
	"arcCos(a) asNumber"
	temp1 := zero arcCos.
	self assert: temp1 asNumber equals: Float halfPi.

	"cos(arcCos(x)) = x"
	temp1 := MathExpCosine on: (MathExpArcCosine on: x).
	self assert: temp1 simplify equals: x.
	
	"arcCos(cos(x)) => x .. or x + 2*k*pi in the future"
	temp1 := MathExpArcCosine on: (MathExpCosine on: x).
	self assert: temp1 simplify equals: x.

]

{ #category : #tests }
MathExpressionClassesTest >> testArcCosineDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := zero arcCos.
	self assert: (fx derivativeFor: x) equals: zero.

	" arcCos( u )' = see documentation "
	fx := x arcCos.
	dx := minusOne / ( (x ** two) negated + one ) sqrt.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testArcCosineSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"arcCos(cos(x))"
	temp1 := (x cos) arcCos.
	self assert: temp1 simplify equals: x.

	"Some convert to expression"
	temp1 := zero arcCos.
	self assert: temp1 simplify equals: pi / 2.
	"Some convert to expression"
	temp1 := one arcCos.
	self assert: temp1 simplify equals: zero.
	"Some convert to expression"
	temp1 := minusOne arcCos.
	self assert: temp1 simplify equals: pi.

	"Some convert to expression"
	temp1 := zero arcSin.
	self assert: temp1 simplify equals: zero.
	"Some convert to expression"
	temp1 := one arcSin.
	self assert: temp1 simplify equals: pi / 2.
	"Some convert to expression"
	temp1 := minusOne arcSin.
	self assert: temp1 simplify equals: pi negated / 2.
]

{ #category : #tests }
MathExpressionClassesTest >> testArcSine [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"x arcSin"
	temp1 := MathExpArcSine on: x.
	self assert: temp1 equals: x arcSin.
	
	"arcSin(a) asNumber"
	temp1 := one arcSin.
	self assert: temp1 asNumber equals: Float halfPi.

	"cos(arcSin(x)) = x"
	temp1 := MathExpSine on: (MathExpArcSine on: x).
	self assert: temp1 simplify equals: x.
	
	"arcSin(cos(x)) => x .. or x + 2*k*pi in the future"
	temp1 := MathExpArcSine on: (MathExpSine on: x).
	self assert: temp1 simplify equals: x.

]

{ #category : #tests }
MathExpressionClassesTest >> testArcSineDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := zero arcCos.
	self assert: (fx derivativeFor: x) equals: zero.


	" arcSin( u )' = see documentation "
	fx := x arcSin.
	dx := one / ( (x ** 2) negated  + 1 ) sqrt.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testArcSineSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"arcSin(sin(x))"
	temp1 := (x sin) arcSin.
	self assert: temp1 simplify equals: x.
	"arcSin(1)"
	temp1 := one arcSin.
	self assert: temp1 asNumber equals: (pi / 2) asNumber.
	"arcSin(0)"
	temp1 := zero arcSin.
	self assert: temp1 simplify equals: zero.
]

{ #category : #tests }
MathExpressionClassesTest >> testArcTangent [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"x arcTan"
	temp1 := MathExpArcTangent on: x.
	self assert: temp1 equals: x arcTan.
	
	"arcTan(a) asNumber"
	temp1 := one arcTan.
	self assert: temp1 asNumber equals: Float halfPi / 2.

	"cos(arcTan(x)) = x"
	temp1 := MathExpTangent on: (MathExpArcTangent on: x).
	self assert: temp1 simplify equals: x.
	
	"arcTan(cos(x)) => x .. or x + 2*k*pi in the future"
	temp1 := MathExpArcTangent on: (MathExpTangent on: x).
	self assert: temp1 simplify equals: x.

]

{ #category : #tests }
MathExpressionClassesTest >> testArcTangentDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := zero arcCos.
	self assert: (fx derivativeFor: x) equals: zero.


	" arcTan( u )' = see documentation "
	fx := x arcTan.
	dx := one / ( x ** two + one ).
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testArcTangentSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"arcTan(tan(x))"
	temp1 := (x tan) arcTan.
	self assert: temp1 simplify equals: x.
	"arcTan(1)"
	temp1 := one arcTan.
	self assert: temp1 asNumber equals: (1 arcTan).
	"arcTan(0)"
	temp1 := zero arcTan.
	self assert: temp1 simplify equals: zero.
]

{ #category : #tests }
MathExpressionClassesTest >> testCosine [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 a b |
	a := 40 degreesToRadians.
	b := a cos.
	"cos(a) asNumber"
	temp1 := MathExpCosine on: (MathExpNumber value: a).
	self assert: temp1 asNumber equals: b.
	"a cos"
	temp1 := (MathExpNumber value: a) cos.
	self assert: temp1 asNumber equals: b.
]

{ #category : #tests }
MathExpressionClassesTest >> testCosineDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten cos.
	self assert: (fx derivativeFor: x) equals: zero.


	" cos( u )' = -u' * sin(u)' "
	fx := (x ** three) cos.		"dx => -(x^3)' * sin(x^3) = -3*x^2 * sin(x^3)"
	dx := three * ((x ** 2) * ((x ** 3) sin negated)).
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testCosineSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"cos(0)"
	temp1 := zero cos.
	self assert: temp1 simplify equals: one.
	"cos(pi/2)"
	temp1 := (pi / 2) cos.
	self assert: temp1 simplify equals: zero.
	"cos(pi)"
	temp1 := pi cos.
	self assert: temp1 simplify equals: minusOne.
	"cos(-pi/2)"
	temp1 := (pi / -2) cos.
	self assert: temp1 simplify equals: zero.
	"cos(-pi)"
	temp1 := pi negated cos.
	self assert: temp1 simplify equals: minusOne.
]

{ #category : #tests }
MathExpressionClassesTest >> testDivision [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 temp2 |

	"(a / b ) asNumber"
	temp1 := eight / three.
	self assert: temp1 simplify class equals: MathExpNumber.
	self assert: temp1 simplify asNumber isFraction.
	self assert: temp1 simplify equals: (MathExpNumber value: 8/3).

	" (a / b) / c != a / (b / c) "
	temp1 := (three / seven) / nine.
	temp2 := three / (seven / nine).
	self assert: temp1 asNumber ~= temp2 asNumber.
	self assert: temp1 simplify ~= temp2 simplify.

	" a * (b / c) = a * b / c "
	temp1 := three * (seven / nine).
	temp2 := (three * seven) / nine.
	self assert: temp1 asNumber equals: temp2 asNumber.
]

{ #category : #tests }
MathExpressionClassesTest >> testDivisionDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten / two.
	self assert: (fx derivativeFor: x) equals: zero.

	" ( u / v )' = ( u' * v - u * v' ) / v^2 "
	fx := nine / x.
	dx := nine negated / (x ** 2).
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.

	fx := x / nine.
	dx := MathExpNumber value: 1/9.
	self assert: (fx derivativeFor: x) equals: dx.

	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testDivisionSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	" 0 / n "
	temp1 := zero / six.
	self assert: temp1 simplify equals: zero.
	" n / 1 "
	temp1 := seven / one.
	self assert: temp1 simplify equals: seven.
	" n / 0 "
	temp1 := five / zero.
	self assert: temp1 isNotNumber.

	" { (a/b) / (c/x) => (a*c) / (b*x) } Only for division "
	temp1 := (six / three) / (two / x).
	self assert: temp1 simplify equals: x.
	" { (a/x) / (b/c) }"
	temp1 := (six / x) / (two / three).
	self assert: temp1 simplify equals: (nine / x).
]

{ #category : #tests }
MathExpressionClassesTest >> testLogarithm [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| base value temp1 |
	"(base logarithm: val) asNumber"
	base := 4.
	value := (base ** 6).
	temp1 := MathExpLogarithm leftSide: base rightSide: value. "notice is opposite than Smalltalk"
	self assert: temp1 asNumber equals: (value log: base).
	self assert: temp1 simplify equals: (MathExpNumber value: (value log: base)).

	" ln(e^n) = n "
	base := Float e.
	value := (base ** 2).
	temp1 := MathExpLogarithm leftSide: base rightSide: value.
	self assert: temp1 equals: (MathExpLogarithmBaseE on: value).
	self assert: temp1 asNumber equals: (value log: base).
	self assert: temp1 simplify equals: (MathExpNumber value: (value log: base)).

	" log(10^n) = n "
	base := 10.
	value := (base ** 7).
	temp1 := MathExpLogarithm leftSide: base rightSide: value.
	self assert: temp1 equals: (MathExpLogarithmBaseTen on: value).
	self assert: temp1 asNumber equals: (value log: base).
	self assert: temp1 simplify equals: (MathExpNumber value: (value log: base)).
	
	" log{2}(8) => log2(8) .. binary logarithm autosimplification"
	base := 2.
	value := (base ** 3).
	temp1 := MathExpLogarithm leftSide: base rightSide: value.
	self assert: temp1 equals: (MathExpLogarithmBaseTwo on: value).
	self assert: temp1 asNumber equals: (value log: base).
	self assert: temp1 simplify equals: (MathExpNumber value: (value log: base)).
]

{ #category : #tests }
MathExpressionClassesTest >> testLogarithmDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten ln.
	self assert: (fx derivativeFor: x) equals: zero.

	" log{base}( u )' = u' / ( u * ln(base}' ) "

	" ln(x)' = log{e}(x)' = x' / (x * ln(e)) = 1 / x"
	fx := x ln.
	dx := x reciprocal.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.

	" log{10}( x^2 )' = 2*x / ( x^2 * ln(10}' ) "
	fx := (x ** 2) log.
	dx := (two / (ten ln)) * (one / x).
	self assert: (fx derivativeFor: x) equals: dx.

	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testLogarithmSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"log(10)"
	temp1 := (ten) log.
	self assert: temp1 simplify equals: one.
	"ln(e^x)"
	temp1 := (e ** x) ln.
	self assert: temp1 simplify equals: x.

	"ln( 2.718281828459045^x) .. a bit ugly.. depends on the decimals.. same as in Math"
	temp1 := (MathExpPower leftSide: Float e rightSide: x) ln.
	self assert: temp1 simplify equals: x.
	
	"log2(1)"
	temp1 := (one) log2.  "log2 is a special method for logarithm base 2"
	self assert: temp1 simplify equals: zero.
]

{ #category : #tests }
MathExpressionClassesTest >> testMultiplication [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 temp2 |
	"(a * b * c * d) asNumber"
	temp1 := (seven * eight) * (four * three) * two.
	self assert: temp1 asNumber equals: 7 * 8 * 4 * 3 * 2.
	self assert: temp1 simplify equals: (MathExpNumber value: 7 * 8 * 4 * 3 * 2).
	" (a * b) * c = a * (b * c) "
	temp1 := (three * seven) * nine.
	temp2 := three * (seven * nine).
	self assert: temp1 asNumber equals: temp2 asNumber.
	self assert: temp1 simplify equals: temp2 simplify.
	" a * (b * c) = a * b * a * c "
	temp1 := three * (seven * nine).
	temp2 := (three * seven) * nine.
	self assert: temp1 asNumber equals: temp2 asNumber.
]

{ #category : #tests }
MathExpressionClassesTest >> testMultiplicationDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten * two.
	self assert: (fx derivativeFor: x) equals: zero.

	" ( u * v )' = ( u' * v ) + ( u * v' ) "
	fx := ten * x.
	dx := ten.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.

	fx := x * eight.
	dx := eight.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testMultiplicationSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 temp2 |
	" 0 * n "
	temp1 := zero * six.
	self assert: temp1 simplify equals: zero.
	" n * 0 "
	temp1 := five * zero.
	self assert: temp1 simplify equals: zero.
	" 1 * n "
	temp1 := one * six.
	self assert: temp1 simplify equals: six.
	" n * 1 "
	temp1 := five * one.
	self assert: temp1 simplify equals: five.
	" x * a "
	temp1 := x * 3.
	temp2 := three * x.
	self assert: temp1 simplify equals: temp2.
]

{ #category : #tests }
MathExpressionClassesTest >> testNegative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"a negated asNumber"
	temp1 := seven negated.
	self assert: temp1 asNumber equals: -7.
	"- (a) asNumber"
	temp1 := MathExpNegative on: (seven).
	self assert: temp1 asNumber equals: -7.
	self assert: temp1 simplify equals: (MathExpNumber value: -7).
	" x negated "
	temp1 := x negated.
	self assert: temp1 equals: (MathExpNegative on: x).
]

{ #category : #tests }
MathExpressionClassesTest >> testNegativeDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := MathExpNegative on: (ten).
	self assert: (fx derivativeFor: x) equals: zero.

	" ( - ( u ) )' = - (u') "
	" (-x)' => -1 "
	fx := x negated.
	dx := minusOne.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.

	" ( -x^2 )' => -2*x .. notice #negated has lower priority than power in Maths"
	fx := (x ** 2) negated.
	dx := minusTwo * x.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.

	" ( (-x)^2 )' => -2*x .. notice #negated has lower priority than power in Maths"
	fx := x negated ** 2.
	dx := two * x.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testNegativeSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 temp2 |
	" x negated negated "
	temp1 := x negated negated.
	self assert: temp1 equals: x.
	" - ( - ( x ) )"
	temp1 := MathExpNegative on: (MathExpNegative on: x).
	self assert: temp1 simplify equals: x.
	" - (a + x) => -x - 3"
	temp1 := MathExpNegative on: (three + x).
	temp2 := x negated - three.
	self assert: temp1 simplify equals: temp2.
	" - (a * x) => -3 * x"
	temp1 := MathExpNegative on: (three * x).
	temp2 := three negated * x.
	self assert: temp1 simplify equals: temp2.
]

{ #category : #tests }
MathExpressionClassesTest >> testNumber [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| a temp1 |
	a := 789.
	"a asNumber"
	temp1 := MathExpNumber value: a.
	self assert: temp1 asNumber equals: a.
	"a negated asNumber"
	temp1 := (MathExpNumber value: a) negated.
	self assert: temp1 asNumber equals: a negated.
	"- (a) asNumber"
	temp1 := MathExpNegative on: a.
	self assert: temp1 asNumber equals: a negated.
	self assert: temp1 simplify equals: (MathExpNumber value: (0 - a)).
	" x negated "
	temp1 := x negated.
	self assert: temp1 equals: (MathExpNegative on: x).
]

{ #category : #tests }
MathExpressionClassesTest >> testNumberDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| c fx dx |

	" c' = 0.0 "
	c := seven.
	fx := c.
	dx := zero.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.

	" -c' = 0.0 "
	c := minusTwo.
	fx := c.
	dx := zero.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testNumberSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| a temp1 |
	a := 987.
	"a simplify"
	temp1 := MathExpNumber value: a.
	self assert: temp1 simplify equals: temp1.
	self assert: temp1 simplify asNumber equals: a.
]

{ #category : #tests }
MathExpressionClassesTest >> testPower [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 temp2 |
	"(a ^ b) asNumber"
	temp1 := nine ** four.
	self assert: temp1 asNumber equals: 9 ** 4.
	self assert: temp1 simplify equals: (MathExpPower leftSide: 9 rightSide: 4) simplify.
	"Polynomial tidy up: ax^2 + bx + c "

	temp1 := ( nine ) + ( x * three ) + ( x ** 2 * seven).
	temp2 := ( seven * ( x ** 2) ) + ( three * x ) + nine.
	self assert: temp1 simplify equals: temp2 simplify.
]

{ #category : #tests }
MathExpressionClassesTest >> testPowerDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten ** two.
	self assert: (fx derivativeFor: x) equals: zero.

	" ( u ^ v )' = ( u' * v * u^(v-1) ) + ( v' * ln(u) * u^v ) "
	" (x ^ e)' "
	fx := x ** e.		"dx => (1 * e * x^(e-1)) + (0 * ..) => e*x^(e-1)"
	dx := e * (x ** (e - one)).
	self assert: (fx derivativeFor: x) equals: dx.

	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.

	" (e ^ x)' "
	fx := e ** x.		"dx => (0 * e * e^(x-1)) + (1 * ln(e) * e^x) => e^x"
	dx := e ** x.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testPowerSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 temp2 |
	" 0 ^ n "
	temp1 := zero ** nine.
	self assert: temp1 simplify equals: zero.
	" n ^ 0 "
	temp1 := seven ** zero.
	self assert: temp1 simplify equals: one.
	" 1 ^ n "
	temp1 := one ** nine.
	self assert: temp1 simplify equals: one.
	" n ^ 1 "
	temp1 := seven ** one.
	self assert: temp1 simplify equals: seven.
	" x ** a "
	temp1 := x ** three.
	temp2 := x ** 3.
	self assert: temp1 simplify equals: temp2.
	" x ** a ** b "
	temp1 := x ** three ** four.
	temp2 := x ** (3 * 4).
	self assert: temp1 simplify equals: temp2.
	" x ** (a ** b) "
	temp1 := x ** (two ** five).
	temp2 := x ** (2 ** 5).
	self assert: temp1 simplify equals: temp2.
]

{ #category : #tests }
MathExpressionClassesTest >> testSine [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 a b |
	a := 40 degreesToRadians.
	b := a sin.
	"sin(a) asNumber"
	temp1 := MathExpSine on: (MathExpNumber value: a).
	self assert: temp1 asNumber equals: b.
	"a sin"
	temp1 := (MathExpNumber value: a) sin.
	self assert: temp1 asNumber equals: b.
]

{ #category : #tests }
MathExpressionClassesTest >> testSineDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten sin.
	self assert: (fx derivativeFor: x) equals: zero.

	" sin( u )' = u' * cos(u)' "
	fx := (x ** two) sin.		"dx => (x^2)' * cos(x^2) = 2*x * cos(x^2)"
	dx := two * (x * ((x ** two) cos)).
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testSineSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"sin(0)"
	temp1 := zero sin.
	self assert: temp1 simplify equals: zero.
	"sin(pi/2)"
	temp1 := (pi / 2) sin.
	self assert: temp1 simplify equals: one.
	"sin(pi)"
	temp1 := pi sin.
	self assert: temp1 simplify equals: zero.
	"sin(-pi/2)"
	temp1 := (pi / -2) sin.
	self assert: temp1 simplify equals: minusOne.
	"sin(-pi)"
	temp1 := pi negated sin.
	self assert: temp1 simplify equals: zero.
]

{ #category : #tests }
MathExpressionClassesTest >> testSqr [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"sqr(x)"
	temp1 := x sqr.
	self assert: temp1 class equals: MathExpSqr.
	self assert: temp1 leftSide equals: x.
	self assert: temp1 rightSide equals: two.
]

{ #category : #tests }
MathExpressionClassesTest >> testSqrDerivative [
	"Is the same class as Power so does not need much more test but just in case"
	| fx dx |
	" ( u ^ v )' = ( u' * v * u^(v-1) ) + ( v' * ln(u) * u^v ) "
	" ((x + 1) ^ 2)' => 1*2*(x+1) + 0 => 2 * (x + 1) => 2*x + 2"
	fx := (x + 1) sqr.
	dx := two * x + two.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testSqrSimplify [
	| temp1 temp2 |
	" sqr(x) ** b => x ** 2 ** b => x ** (2 * b) "
	temp1 := (x sqr) ** four.
	temp2 := x ** (2 * 4).
	self assert: temp1 simplify equals: temp2.
	
	"Compatible"
	temp1 := (x ** 2) ** four.
	temp2 := x ** (2 * 4).
	self assert: temp1 simplify equals: temp2.
]

{ #category : #tests }
MathExpressionClassesTest >> testSquareRoot [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"sqr(y)"
	temp1 := y sqrt.
	self assert: temp1 class equals: MathExpSquareRoot.
	self assert: temp1 leftSide equals: y.
	self assert: temp1 rightSide asNumber equals: 0.5. "May use 1/2 or 0.5.. not definitive yet"
]

{ #category : #tests }
MathExpressionClassesTest >> testSquareRootDerivative [
	"Is the same class as Power so does not need much more test but just in case"
	| fx dx |
	" ( u ^ v )' = ( u' * v * u^(v-1) ) + ( v' * ln(u) * u^v ) "
	" sqrt(x) ' => x^(1/2) => 1*(1/2)*x^(1/2-1) + 0 => 1/2 * x^(-1/2)"
	fx := x sqrt.
	"atm the 1/2 ends up at the end.. not biggy.. will fix later"
	dx := x ** (-0.5) * (0.5).
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testSquareRootSimplify [
	| temp1 temp2 |
	" sqrt(x) ** b => x ** (1/2) ** b => x ** (1/2 * b) "
	temp1 := (x sqrt) ** six.
	temp2 := x ** (1/2 * 6).
	self assert: temp1 simplify equals: temp2.
]

{ #category : #tests }
MathExpressionClassesTest >> testSubtraction [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 temp2 |
	"(a - b - c - d) asNumber"
	temp1 := seven - eight - four - three - two.
	self assert: temp1 asNumber equals: 7 - 8 - 4 - 3 - 2.
	self assert: temp1 simplify equals: (MathExpNumber value: 7 - 8 - 4 - 3 - 2).
	" (a - b) - c != a - (b - c) "
	temp1 := (three - seven) - nine.
	temp2 := three - (seven - nine).
	self assert: temp1 asNumber ~= temp2 asNumber.
	self assert: temp1 simplify ~= temp2 simplify.
	" a * (b - c) = a * b - a * c "
	temp1 := three * (seven - nine).
	temp2 := (three * seven) - (three * nine).
	self assert: temp1 asNumber equals: temp2 asNumber.
]

{ #category : #tests }
MathExpressionClassesTest >> testSubtractionDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten - two.
	self assert: (fx derivativeFor: x) equals: zero.

	" ( u - v )' = u' - v' "
	fx := nine - x.
	dx := minusOne.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testSubtractionSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 temp2 |
	" 0 - n "
	temp1 := zero - two.
	self assert: temp1 simplify equals: minusTwo.
	" n - 0 "
	temp1 := six - zero.
	self assert: temp1 simplify equals: six.
	" a + x "
	temp1 := three - x.
	temp2 := x negated + 3.
	self assert: temp1 simplify equals: temp2.
]

{ #category : #tests }
MathExpressionClassesTest >> testTangent [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 a b |
	a := 40 degreesToRadians.
	b := a tan.
	"tan(a) asNumber"
	temp1 := MathExpTangent on: (MathExpNumber value: a).
	self assert: temp1 asNumber equals: b.
	"a tan"
	temp1 := (MathExpNumber value: a) tan.
	self assert: temp1 asNumber equals: b.
]

{ #category : #tests }
MathExpressionClassesTest >> testTangentDerivative [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| fx dx |
	" ( c )' = 0"
	fx := ten tan.
	self assert: (fx derivativeFor: x) equals: zero.

	" tan( u )' = ( sin(u) / cos(u) ) "
	fx := x tan.			"dx => 1 / cos(x)^2"
	dx := (x cos ** 2) reciprocal.
	self assert: (fx derivativeFor: x) equals: dx.
	self assert: (fx derivativeFor: $x) equals: dx.
	self assert: (fx derivativeFor: #x) equals: dx.
	self assert: (fx derivativeFor: 'x') equals: dx.
]

{ #category : #tests }
MathExpressionClassesTest >> testTangentSimplify [
	"All tests use the instance side (not testing constructors, that is already tested by the operands)"
	| temp1 |
	"tan(0)"
	temp1 := zero tan.
	self assert: temp1 simplify equals: zero.
	"tan(pi/2)"
	temp1 := (pi / 2) tan.
	self assert: temp1 simplify equals: MathExpUndefined new.
	"tan(pi)"
	temp1 := pi tan.
	self assert: temp1 simplify equals: zero.
	"tan(-pi/2)"
	temp1 := (pi / -2) tan.
	self assert: temp1 simplify equals: MathExpUndefined new.
	"tan(-pi)"
	temp1 := pi negated tan.
	self assert: temp1 simplify equals: zero.
]
