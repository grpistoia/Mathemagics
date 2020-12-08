"
My responsability is to test the mathematical expression parser.

Where to start, when everything can combine with everything? I start by simple number combinations and operators, then unary negative, and so forth.

The idea is to make enough combinations on each operation / precedence / function.
"
Class {
	#name : #MathExpressionParserTest,
	#superclass : #MathExpressionBaseTest,
	#category : #'Mathemagics-Tests-Parsing'
}

{ #category : #tests }
MathExpressionParserTest >> test01Numbers [
	"Parsing numbers"
	self assert: (MathExpression from: '1') asNumber equals: 1.
	self assert: (MathExpression from: '-1') asNumber equals: -1.
	self assert: (MathExpression from: '+1') asNumber equals: 1.
	"+ and -"
	self assert: (MathExpression from: '+1234567890') asNumber equals: 1234567890.
	self assert: (MathExpression from: '-1234567890') asNumber equals: -1234567890.
	"Decimals"
	self assert: (MathExpression from: '012345.6789') asNumber equals: 12345.6789.
	self assert: (MathExpression from: '01234567.89') asNumber equals: 1234567.89.
	"Floating"
	self assert: (MathExpression from: '123.456e1') asNumber equals: 1234.56.
	self assert: (MathExpression from: '123.456e10') asNumber equals: 1234560000000.
	self assert: (MathExpression from: '123.456e-1') asNumber equals: 12.3456.
	self assert: (MathExpression from: '123.456e-5') asNumber equals: 0.00123456.
	"Basic parenthesis"
	self assert: (MathExpression from: '(987654.321)') asNumber equals: 987654.321.
	self assert: (MathExpression from: '(-9876.54321)') asNumber equals: -9876.54321.
	"Floating pain.. the e cannot get confused with Euler number 'e'"
	self assert: (MathExpression from: '2e0') asNumber equals: 2.
	self assert: (MathExpression from: '0.2e11') asNumber equals: 2e10.
	"Cannot be to type.. '.' .. or '.e2'.. but .5 is fine.."
	self should: [MathExpression from: '.'] raise: Exception.
	self should: [MathExpression from: 'e1'] raise: Exception.
	self should: [MathExpression from: '2e'] raise: Exception.
]

{ #category : #tests }
MathExpressionParserTest >> test02Constants [
	"Parsing some of the constants"
	self assert: (MathExpression from: '2e0') asNumber equals: 2.
	self assert: (MathExpression from: '0.2e11') asNumber equals: 2e10.

	"guarantee wont collide with .. 2e2 or something.."
	self assert: (MathExpression from: 'e') equals: e.
	self assert: (MathExpression from: 'e') equals: e value.

	self assert: (MathExpression from: 'pi') equals: pi.
	self assert: (MathExpression from: 'pi') asNumber equals: Float pi.

	self assert: (MathExpression from: 'phi') equals: MathExpUniversalConstant phi.
	self assert: (MathExpression from: 'phi') asNumber equals: MathExpUniversalConstant phi value.

	"The rest should continue working.."
	self assert: (MathExpression from: 'pi/2') asNumber equals: Float halfPi.
	self assert: (MathExpression from: 'e*e') asNumber equals: Float e ** 2.

]

{ #category : #tests }
MathExpressionParserTest >> test03Functions [
	"Testing functions"
	self assert: (MathExpression from: 'cos(45/180*3.141592653589793)') asNumber equals: 45 degreesToRadians cos.
	self assert: (MathExpression from: 'sin(90/180*pi)') asNumber equals: 90 degreesToRadians sin.
	self assert: (MathExpression from: 'ln(e)') asNumber equals: Float e ln.

	"These are very messy.. functions but not.."
	self assert: (MathExpression from: 'sin(x)') equals: x sin.
	self assert: (MathExpression from: 'sqrt(x)') equals: x sqrt.
	self assert: (MathExpression from: 'sqr(x)') equals: x sqr.
	self assert: (MathExpression from: 'x**2') equals: x ** 2.
	self assert: (MathExpression from: 'log(x)') equals: x log.
	self assert: (MathExpression from: 'log(w)') asBlock asString equals: [ :w | w log ] asString.
	self assert: (MathExpression from: 'ln(x)') equals: x ln.
	self assert: (MathExpression from: 'ln(w)') asBlock asString equals: [ :w | w ln ] asString.
	self assert: (MathExpression from: 'log2(x)') equals: x log2.
	self assert: (MathExpression from: 'log2(w)') asBlock asString equals: [ :w | 2 log: w ] asString.
	self assert: (MathExpression from: '5 log: 8') equals: (five log: eight).
	self assert: (MathExpression from: '5 logarithm 8') equals: (five log: eight).
	self assert: (MathExpression from: '2 logarithm x') equals: x log2.
	self assert: (MathExpression from: 'w log: 2') asBlock asString equals: [ :w | w log: 2 ] asString.

	self assert: (MathExpression from: ' 5 * ln(x) ') equals: x ln * 5.
]

{ #category : #tests }
MathExpressionParserTest >> test04Precedence [
	"No operators"
	self assert: (MathExpression from: '0') asNumber equals: 0.
	self assert: (MathExpression from: '1') asNumber equals: 1.
	"Smalltalk doesnt support this but people use it, so I support it too"
	self assert: (MathExpression from: '+1') asNumber equals: 1.
	"Negative"
	self assert: (MathExpression from: '-1') asNumber equals: -1.
	"Same priority"
	self assert: (MathExpression from: '1 + 2 - 3') asNumber equals: 1 + 2 - 3.
	self assert: (MathExpression from: '1 - 2 + 3') asNumber equals: 1 - 2 + 3.
	"Mixed priority"
	self assert: (MathExpression from: '2 * 4 + 3') asNumber equals: 2 * 4 + 3.
	self assert: (MathExpression from: '3 + 2 * 4') asNumber equals: 3 + (2 * 4).
	self assert: (MathExpression from: '3 + 8 / 2') asNumber equals: 3 + (8 / 2).
	self assert: (MathExpression from: '8 / 2 + 3') asNumber equals: (8 / 2) + 3.
	self assert: (MathExpression from: '8 / 2 * 3') asNumber equals: (8 / 2) * 3.
	self assert: (MathExpression from: '3 * 8 / 2') asNumber equals: (3 * 8) / 2.
	"Parenthesis change order"
	self assert: (MathExpression from: '3 + 2 * 4') asNumber equals: 3 + (2 * 4).
	self assert: (MathExpression from: '(3 + 2) * 4') asNumber equals: (3 + 2) * 4.
	"Power highest priority"
	self assert: (MathExpression from: '4 ^ 2') asNumber equals: 4 ** 2.
	self assert: (MathExpression from: '4 ^ -2') asNumber equals: 4 ** (-2).
	"Mixed"
	self assert: (MathExpression from: '((2 + 3) * 4) ^ 5') asNumber equals: (2 + 3) * 4 ** 5.
	self assert: (MathExpression from: '2 + 3 * 4 ^ 5') asNumber equals: 2 + (3 * (4 ** 5)).
	self assert: (MathExpression from: '4 ^ 5 * 3 + 2') asNumber equals: ((4 ** 5) * 3) + 2.
	self assert: (MathExpression from: '2 + 4 ^ 5 * 3') asNumber equals: 2 + ((4 ** 5) * 3).
]

{ #category : #tests }
MathExpressionParserTest >> test05Parenthesis [
	"Testing that the parsed expression produce the same when printing.."
	self assert: (MathExpression from: '1 + 2 + 3 + 4') equals: one + two + three + four.
	self assert: (MathExpression from: '(1 + 2) + 3 + (4)') equals: (one + two) + three + four.
	self assert: (MathExpression from: '1 + 2 * 3 / 4') equals: one + ((two * three) / four).
	self assert: (MathExpression from: '(1 + 2) * 3 / 4') equals: ((one + two) * three) / four.
	self assert: (MathExpression from: '(1 + (2 * 3)) / 4') equals: (one + (two * three)) / four.
	self assert: (MathExpression from: 'sin(1 + (2 * 3))') equals: (one + (two * three)) sin.
]

{ #category : #tests }
MathExpressionParserTest >> test06Variables [
	"The parser should always return the same variable (but they are not singleton).."
	| testRadians1 testRadians2 fx |
	testRadians1 := 37 degreesToRadians.
	testRadians2 := 68 degreesToRadians.

	"Compare parsed vs built"
	fx := x sin + x.
	self assert: (MathExpression from: 'sin(x) + x') equals: fx.

	"So knowing is only 1 'x' in the whole expression, I can evaluate it"
	x value: testRadians1.
	self assert: (fx asNumber) equals: (testRadians1 sin + testRadians1).

	"Same formula, not replacing.."
	self assert: (MathExpression from: 'sin(x) + x') equals: fx.
	self assert: (MathExpression from: 'sin(x) + x') ~~ fx.

	"Now they should return the same.."
	self assert: ((MathExpression from: 'sin(x) + x') evaluate: 'x' with: testRadians2) asNumber equals: (testRadians2 sin + testRadians2).
	self assert: ((MathExpression from: 'sin(x) + x') evaluate: #x with: testRadians1) asNumber equals: (testRadians1 sin + testRadians1).

	"More than one still one per variable"
	x value: nil.
	y value: nil.
	self assert: (MathExpression from: 'sin(x) + x^2 + y * y') equals: ((x sin) + (x ** two) + (y * y)).

	"The variable doesnt change the statement"
	x value: testRadians1.
	y value: testRadians2.
	self assert: (MathExpression from: 'sin(x) + x^2 + y * y') equals: ((x sin) + (x ** two) + (y * y)).

	"The variable doesnt change the statement"
	x value: testRadians1.
	y value: testRadians2.
	self assert: (MathExpression from: 'sin(x) + x^2 + y * y') isNotNumber.
	self assert: ((x sin) + (x ** two) + (y * y)) isNumber.
]

{ #category : #tests }
MathExpressionParserTest >> test07Consistency [	
	"Some expressions I used for debug.."
	| ninety hundredEighty |
	ninety := MathExpNumber value: 90.
	hundredEighty := MathExpNumber value: 180.
			
	self assert: (MathExpression from: '+1234567890') asNumber equals: 1234567890.
	self assert: (MathExpression from: '-1234567890') asNumber equals: -1234567890.
	self assert: (MathExpression from: '2 + 3 - 3') equals: two + three - three.
	self assert: (MathExpression from: '2 + 3 + -3') equals: two + three + (three negated).
	self assert: (MathExpression from: '2 + 3 + -3') simplify equals: two.
	self assert: (MathExpression from: 'sin(90/180)') equals: (ninety / hundredEighty) sin.
	self assert: (MathExpression from: '1 + sin(90/180)') equals: (one + ((ninety) / hundredEighty) sin).
	self assert: (MathExpression from: 'sin(90/180)+1') equals: ((ninety) / hundredEighty) sin + one.
	self assert: (MathExpression from: 'sin(90/(180+1))') equals: ((ninety) / (hundredEighty + one)) sin.
	self assert: (MathExpression from: '2 + 3 * 5') equals: two + (three * five).
	self assert: (MathExpression from: '2 + (3 * 5)') equals: two + (three * five).
	self assert: (MathExpression from: '2 * 3 + 5') equals: (two * three) + five.
	self assert: (MathExpression from: '(2 + 3) * 5') equals: (two + three) * five.
	self assert: (MathExpression from: '5 * 2 ^ 3') equals: five * (two ** three).
	self assert: (MathExpression from: '  (-2 * 3) ^  5') equals: ((minusTwo) * three) ** five.
	self assert: (MathExpression from: '3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3') equals: three + ((four * two) / (((one - five) ** two) ** three)).
	self assert: (MathExpression from: '5 / (2 + 3) * 5') equals: (five / (two + three) * five).
	self assert: (MathExpression from: 'sin(90/180*pi)') equals: (ninety / hundredEighty * pi) sin.
	self assert: (MathExpression from: 'sin(x)') equals: (MathExpSine on: x).
	self assert: (MathExpression from: 'sin(x)+4') equals: x sin + four.
	self assert: (MathExpression from: 'sin(-1)+x') equals: minusOne sin + x.
]

{ #category : #tests }
MathExpressionParserTest >> test08Negative [
	"negative something"
	self assert: (MathExpression from: '-1') equals: minusOne.
	"Is not Negative(2) because there was time for simplification and avoid parenthesis"
	self assert: (MathExpression from: '-(2)') equals: minusTwo.
	"Has no choice than create a Negative"
	self assert: (MathExpression from: '-x') equals: x negated.
	self assert: (MathExpression from: '-(y)') equals: y negated.
]

{ #category : #tests }
MathExpressionParserTest >> test09SimplifyBasic [
	"Very basic"
	self assert: (MathExpression from: 'x + 0') simplify equals: x.
	self assert: (MathExpression from: '0 + x') simplify equals: x.
	self assert: (MathExpression from: '0 + 0') simplify equals: zero.
	self assert: (MathExpression from: 'x + x') simplify equals: two * x.
	self assert: (MathExpression from: 'x + x + x') simplify equals: three * x.
	self assert: (MathExpression from: 'x - 0') simplify equals: x.
	self assert: (MathExpression from: '0 - x') simplify equals: x negated.
	self assert: (MathExpression from: 'x - x') simplify equals: zero.
	self assert: (MathExpression from: 'x - (-x)') simplify equals: two * x.
	self assert: (MathExpression from: 'x * 0') simplify equals: zero.
	self assert: (MathExpression from: '0 * x') simplify equals: zero.
	self assert: (MathExpression from: 'x * 1') simplify equals: x.
	self assert: (MathExpression from: '1 * x') simplify equals: x.
	self assert: (MathExpression from: 'x * x') simplify equals: x ** two.
	self assert: (MathExpression from: 'x * x * x') simplify equals: x ** three.
	self assert: (MathExpression from: 'x / 1') simplify equals: x.
	self assert: (MathExpression from: '1 / x') simplify equals: x reciprocal.
	self assert: (MathExpression from: 'x / x') simplify equals: one.
	self assert: (MathExpression from: '-x / x') simplify equals: minusOne.
	self assert: (MathExpression from: 'x / -x') simplify equals: minusOne.
	"A few examples used during debug.. notice I combine 'constructors' with numbers that become expressions"
	self assert: (MathExpression from: '3 + 3 + 0') simplify equals: six.
	self assert: (MathExpression from: '3 + 6 + 3 * 0') simplify equals: nine.
	self assert: (MathExpression from: '5 + 6 - 3 * 1') simplify equals: eight.
	"Done show a mess with decimals is possible"
	self assert: (MathExpression from: 'x / 1 + 0 / 5') simplify equals: x.
	"Again.. zeroes dont matter.."
	self assert: (MathExpression from: '3 + x * 0 + x') simplify equals: three + MathExpVariable x.
	" + -n "
	self assert: (MathExpression from: '0 + -5 + 3 * 1') simplify equals: minusTwo.
]

{ #category : #tests }
MathExpressionParserTest >> test10SimplifySigns [
	"A few examples used durign debug.."
	self assert: (MathExpression from: 'x * 3') simplify equals: three * x.
	self assert: (MathExpression from: '2 + x') simplify equals: x + two.
	self assert: (MathExpression from: '2 - x') simplify equals: x negated + two.

	"Double sign changes order (some are + or -, some are negative x some constants"
	self assert: (MathExpression from: 'x^2 + (0 - x)') simplify equals: x ** two - x.
	self assert: (MathExpression from: 'x + -2') simplify equals: x - two.
	self assert: (MathExpression from: 'x^2 - (0-x)') simplify equals: x ** two + x.
	self assert: (MathExpression from: 'x - -4') simplify equals: x + four.

	"Power has priority"
	self assert: (MathExpression from: '- x ^ 3') equals: (x ** 3) negated.

	"In math -n^4 => 0 - n^4 or -1 * 2^4"
	self assert: (MathExpression from: '- x ^ 4') equals: (x ** 4) negated.

	"BUT.. (-2)^4 => 2^4 .. because the sign will never remain"
	self assert: (MathExpression from: '(-x) ^ 2') simplify equals: x ** two.
	self assert: (MathExpression from: '(-x) ^ 2') simplify equals: x ** 2.
	self assert: (MathExpression from: '(-x) ^ 4') simplify equals: x ** 4.
	self assert: (MathExpression from: '(-x) ^ 6') simplify equals: x ** 6.
]

{ #category : #tests }
MathExpressionParserTest >> test11SimplifyParenthesis [
	"A few examples used during debug. I assume the pretty format by default"
	| dot |
	dot := MathExpMultiplication mathSymbolPro asString.
	self assert: (MathExpression from: 'x * 3' settings: prettySettings) asString equals: '3' , dot , 'x'.
	self assert: (MathExpression from: 'x * 3' settings: testSettings) asString equals: 'x*3'.
	self assert: (MathExpression from: '3 * x' settings: prettySettings) asString equals: '3', dot , 'x'.
	self assert: (MathExpression from: '3 * x' settings: testSettings) asString equals: '3*x'.
	self assert: (MathExpression from: 'x * 3') equals: three * x.
	self assert: (MathExpression from: '3 * x') equals: three * x.
	self assert: (MathExpression from: '5 - x') equals: five - x.
	self assert: (MathExpression from: '5 - x') simplify equals: x negated + five.
	self assert: (MathExpression from: '0 - (5 + x)') asString equals: '0 - (5 + x)'.
	self assert: (MathExpression from: '0 - (5 + x)') simplify equals: x negated - five.
	self assert: (MathExpression from: '1 + (5 + x)') asString equals: '1 + 5 + x'.
	self assert: (MathExpression from: '1 * (5 + x)') asString equals: '1' , dot , '(5 + x)'.
	self assert: (MathExpression from: '1 - (5 + x)') asString equals: '1 - (5 + x)'.
	self assert: (MathExpression from: '1 / (5 + x)') asString equals: '1/(5 + x)'.

	self assert: (MathExpression from: '0 + (0 + (0+x))' settings: prettySettings) asString equals: '0 + 0 + 0 + x'.
	self assert: (MathExpression from: '0 + (0 + (0+x))' settings: testSettings) asString equals: '0+0+0+x'.
	self assert: (MathExpression from: '0 + (0 + (0+x))') asString equals: '0 + 0 + 0 + x'.

	self assert: (MathExpression from: '-x + abs(x+0)' settings: prettySettings) asString equals: '-x + abs( x + 0 )'.
	self assert: (MathExpression from: '-x + abs(x+0)' settings: testSettings) asString equals: '-x+abs(x+0)'.
	self assert: (MathExpression from: '-x + abs(x+0)') asString equals: '-x + abs(x + 0)'.

	self assert: (MathExpression from: '0 + (0 + (0+x))') simplify equals: x.
	self assert: (MathExpression from: '0 + (0 - (0+x))') asString equals: '0 + 0 - (0 + x)'.
	self assert: (MathExpression from: '0 + (0 - (0+x))') simplify equals: x negated.
	self assert: (MathExpression from: '0 - (0 - (0+x))') asString equals: '0 - (0 - (0 + x))'.
	self assert: (MathExpression from: '0 - (0 - (0+x))') simplify equals: x.

	"randoms"
	self assert: (MathExpression from: '(x + 3) + 9') simplify equals: x + 12.
	self assert: (MathExpression from: '(x * y) * y') simplify equals: x * (y ** 2).
]

{ #category : #tests }
MathExpressionParserTest >> test12PolynomialSorting [
	"Sort by power (testing parser and simplification at once)"
	self assert: (MathExpression from: '5*x + x^3 * 2') simplify equals: two * (x ** three) + (five * x).
	self assert: (MathExpression from: '-2 + (3*x) + x^2') simplify equals: (x ** two) + (three * x) - two.
	self assert: (MathExpression from: '8 + x*4 + x^2*9 + 7*x^3') simplify 
			equals: (seven * (x ** 3)) + (nine * (x ** 2)) + (four * x) + 8.
	self assert: (MathExpression from: '(x*3) + (3*x)') simplify equals: six * x.
	self assert: (MathExpression from: '(x*3) + (3*x)') equals: (x * three) + (x * three).
]

{ #category : #tests }
MathExpressionParserTest >> test13PowerSquaredSquareRoot [
	| squareRootSymbol |
	squareRootSymbol := MathExpSquareRoot mathSymbolPro asString.

	"Same but.. just same differently"
	self assert: (MathExpression from: 'x^2') simplify equals: x ** 2.
	self assert: (MathExpression from: 'sqr(x)') equals: x sqr.
	self assert: (MathExpression from: 'sqr(x)') simplify equals: x ** 2.
	
	"But.. to match Smalltalk messages"
	self assert: (MathExpVariable x squared) equals: x ** 2.
	self assert: (MathExpVariable x cubed) equals: x ** 3.

	"Dont change to ^2"
	self assert: (MathExpression from: 'sqr(x+1)') equals: (x + 1) sqr.
	self assert: (MathExpression from: 'sqr(x+1)') simplify equals: (x + 1) ** 2. "changes"
	self assert: (MathExpression from: 'sqr(x+6)') equals: (x + 6) sqr.
	self assert: (MathExpression from: 'sqr(x+6)') simplify equals: (x + 6) ** 2. "changed"

	"Another power.. if you typed ^1/2 rather than sqrt is your business.."
	self assert: (MathExpression from: 'x^(1/2)') simplify equals: x squareRoot.

	"Dont change to ^(1/2)"
	self assert: (MathExpression from: 'sqrt(x*8)') simplify equals: (x * 8) sqrt.

	"I cant export the square symbol for some reason"
	self assert: (MathExpression from: squareRootSymbol , '(x*3)') equals: (x * 3) squareRoot.
]
