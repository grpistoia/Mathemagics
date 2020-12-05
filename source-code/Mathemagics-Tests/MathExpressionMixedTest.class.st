"
This class contains mixed tests used during development.

Due to change in precedence, sorting, simplification or derivation, the tests fail sometimes. Random tests were added and kept for future validations.
"
Class {
	#name : #MathExpressionMixedTest,
	#superclass : #MathExpressionBaseTest,
	#category : #'Mathemagics-Tests-Debug'
}

{ #category : #tests }
MathExpressionMixedTest >> testAntiFreeze [
	"At one point this used to freeze the VM .. shouldnt anymore.."

	(MathExpression from: '2 + x') simplify .
	(MathExpression from: '-2 + x') simplify .
	(MathExpression from: 'x * -2') simplify .
	(MathExpression from: 'x ^ 2') simplify .
	(MathExpression from: 'x * x ^ 2') simplify .
	(MathExpression from: '-x ^ 2') simplify .
	(MathExpression from: '(-x) ^ 2') simplify .
	(MathExpression from: 'x ^ (2^100)') simplify .

	(MathExpression from: 'x + (x + 5)') simplify . "x*2+5"

	(MathExpression from: '8 + (x + 5)') simplify . "x+13"

	(MathExpression from: '(x + 5) + (x + 3)') simplify .  "x*2+8"

	(MathExpression from: 'x + 5 + x + 3') simplify .  "x*2+8"

	(MathExpression from: 'x + y + x ^ 6') simplify. "x^6+x+y"
	(MathExpression from: '4 + x^2 + x^y') simplify.

	(MathExpression from: '6 + pi + 4') simplify.

	(MathExpression from: '6 + sin(x) + y + x ^ 3') simplify. "x^3+(sin(x))+y+6"

	(MathExpression from: 'x + y + 9 + y') simplify.

	(MathExpression from: '(x+y)+(5+x)') simplify .
	(MathExpression from: '(x+y)+(5+y)') simplify .

	(MathExpression from: 'sin(x)') simplify.
	(MathExpression from: 'sin(x)+x') simplify.

	(MathExpression from: 'sin(x) +x + cos(x)') simplify.

	(MathExpression from: 'x-0') simplify.
	(MathExpression from: '0-x') simplify.
	(MathExpression from: 'x+0') simplify.
	(MathExpression from: '0+x') simplify.
	(MathExpression from: 'x*1') simplify.
	(MathExpression from: '1*x') simplify.
	(MathExpression from: '0*x') simplify.
	(MathExpression from: 'x*0') simplify.
	(MathExpression from: '-1*x') simplify.
	(MathExpression from: '2*(-x)') simplify.
	(MathExpression from: '-2*(-x)') simplify.

	(MathExpression from: 'x^(-2) * x') simplify.
	(MathExpression from: 'x^(-2) * 1/x') simplify.
	(MathExpression from: 'x^(-2) * x^(-1)') simplify.
	(MathExpression from: 'x^5 / x^3') simplify.

	(MathExpression from: '-3*y + 4*x*y - 4*x*y') simplify.
	(MathExpression from: '-3*y + 4*x*y - 2*x^2 + 2*x + y^2 - 4*x*y') simplify.

	(MathExpression from: '-3*y + 4*x*y - 2*x^2 + 2*x + y^2 - 4*x*y + 2*y + 3*x^2') simplify.

	(MathExpression from: 'x^2 * x^3') simplify.
	(MathExpression from: 'x^2 / x^3') simplify.
	(MathExpression from: 'x^2 ^3') simplify.
	(MathExpression from: 'x^2 ^z') simplify.
	(MathExpression from: 'e^ln(x)') simplify.
	(MathExpression from: '10^log(x)') simplify.
	(MathExpression from: 'e^ln(x^2)') simplify.
	(MathExpression from: 'ln(e^x)') simplify.
	(MathExpression from: 'log(10^x)') simplify.

   (MathExpression from: 'tan(x^2+1)') derivativeFor: #x.

	(MathExpression from: '2 * x / 4') simplify.

	(MathExpression from: 'x * (1 / 3)') simplify.

	(MathExpression from: 'x * (1 / 0)') simplify.
	(MathExpression from: 'x * (0 / 0)') simplify.

	(MathExpression from: 'x+(-2)') simplify.
	(MathExpression from: 'x+pi') simplify.

	(MathExpression from: 'x * (777 / 888)*10') simplify.

	MathExpNumber value: 3/2.

	(MathExpression from: 'sin(x*8)') simplify.
	(MathExpression from: 'sin(pi*8)') simplify. "sin(Œ†*8/4) ????"

	(MathExpression from: '18/(2*x)') simplify. "18/x*2"
	(MathExpression from: '(2*x)/18') simplify. "x*(1/9)"

	(MathExpression from: '-9 -(9*x -6)') simplify.

	(MathExpression from: 'y+x') simplify asString .
	(MathExpression from: 'y-x') simplify asString .
	(MathExpression from: 'y*x') simplify asString .
	(MathExpression from: 'y+x^2') simplify asString .
	(MathExpression from: 'x^3+x^z') simplify asString .
	(MathExpression from: 'x^3+x^4') simplify asString .
	(MathExpression from: 'x^3+x^3') simplify asString .
	(MathExpression from: '4^5+x^z') simplify asString .
	(MathExpression from: '4^z+x^z') simplify asString .

	(MathExpression from: '(x+y)+(5+x)') simplify asString .

	(MathExpression from: '(x+5)+x') simplify asString .
	(MathExpression from: 'x+x+5') simplify asString .
	(MathExpression from: 'x^3+x^y+x+5') simplify asString .

	(MathExpression from: 'sin(x)+(5+x)') simplify. "x+5+ln(x)"
	(MathExpression from: 'ln(x)+(5+x)') simplify. "??"
	(MathExpression from: '(5+x)+ln(x)*x') simplify.
	(MathExpression from: '(5+x)+ln(x)+x') simplify.

	(MathExpression from: '(5*y+x)+x^3+x') simplify.
	(MathExpression from: '(x+2)+x') simplify asString . "'x*2+2'"
	(MathExpression from: 'x+(x+2)') simplify asString . "'x*2+2'"
	(MathExpression from: 'x+(x+2)') simplify asString .  "y+x+x"

	(MathExpression from: 'x+y+x') simplify asString .  "y+x+x"

	(MathExpression from: 'y^2+x+x') simplify asString .  "y+x+x"
	(MathExpression from: 'x+y^2+x') simplify asString .  "y+x+x"
	(MathExpression from: 'x+y^2+z') simplify asString .  "y+x+x"
	(MathExpression from: 'x+y*2') simplify asString .  "y+x+x"

	(MathExpression from: 'y+x+2+a+x') simplify.

	(MathExpression from: '1+2*3/4').
	(MathExpression from: 'x+2+4*x') simplify.
	(MathExpression from: 'x+2+4*x') simplify.
	(MathExpression from: '(x+a)^2*(x+a)^5') simplify.

	"cos(pi*2)"
	(MathExpConstantPi new * 2 ) cos simplify .
	"cos(0)"
	(MathExpNumber zero) cos asNumber.
	"cos(pi/2)"
	(pi / 2) cos asNumber.
	"cos(5/2*pi)"
	(pi * 5 / 2) asNumber.
	(pi * 5 / 2) cos asNumber.
	"cos(pi)"
	(MathExpNumber zero) cos asNumber.
	"cos(2/3*pi)"
	pi cos asNumber.
	"cos(2*pi)"
	(pi * 2) cos asNumber.
	"cos(2*pi)"
	(pi * 3 / 2) cos asNumber.
]

{ #category : #tests }
MathExpressionMixedTest >> testAutoConversion [
	"Some more complicated parsing tests"
	| fx |

	fx := MathExpression from: 'sqr(10) + 2'.
	self assert: fx asString equals: 'sqr(10) + 2'.
	self assert: fx asNumber equals: 102.

	fx := MathExpression from: '20^2 + 3'.
	self assert: fx asNumber equals: 403.

	fx := (MathExpression from: 'sqr(x) * x').
	self assert: fx simplify equals: x ** three.

	fx := MathExpression from: 'sqrt(25)'.
	fx settings: testSettings.
	self assert: fx asString equals: 'sqrt(25)'.
	self assert: fx asNumber equals: 5.

	fx := (MathExpression from: 'x+5') squareRoot.
	fx settings: testSettings.
	self assert: fx asString equals: 'sqrt(x+5)'.
	fx settings: prettySettings.
	self assert: fx asString equals: MathExpSquareRoot mathSymbolPro asString , '( x + 5 )'.
]

{ #category : #tests }
MathExpressionMixedTest >> testComplexTests [
	"Some more complicated parsing tests"
	| fx |

	fx := MathExpUndefined new.
	self assert: fx asString equals: 'Undefined'.

	fx := MathExpInfinity new.
	fx settings: testSettings.
	self assert: fx asString equals: 'Infinity'.
	fx settings: prettySettings.
	self assert: fx asString equals: MathExpInfinity mathSymbolPro asString.

	fx := MathExpression from: 'x+pi'.
	fx settings: testSettings.
	self assert: fx asString equals: 'x+pi'.
	fx settings: prettySettings.
	self assert: fx asString equals: 'x + ' , MathExpConstantPi mathSymbolPro asString.

	"I accept the pi unicode character"
	fx := MathExpression from: 'x + ' , MathExpConstantPi mathSymbolPro asString asLowercase.
	self assert: fx equals: x + pi.

	"Pi character uppercase do exist!"
	fx := MathExpression from: 'x - ' , MathExpConstantPi mathSymbolPro asString asUppercase.
	self assert: fx equals: x - pi.

	fx := MathExpression from: '(-x + x) + 9'.
	self assert: fx simplify equals: nine.

	fx := MathExpression from: '-x + 9 + x'.
	self assert: fx simplify equals: nine.

	fx := MathExpression from: 'x + (9 * 1)'.
	self assert: fx simplify equals: x + 9.
]

{ #category : #tests }
MathExpressionMixedTest >> testDocoExamples [
	"Examples used in the documentation"
	| fx |

	fx := MathExpression from: '-2 ^ 4'.
	self assert: fx asNumber equals: -16.

	fx := MathExpression from: 'sin(pi) - 0 * x^2 + x * 1 - ln(e)'.
	self assert: fx simplify equals: (x - 1).

	fx := MathExpression from: 'x^3 + 5*x'.
	self assert: (fx derivativeFor: $x) equals: (MathExpression from: '3*x^2 + 5').

	fx := MathExpression from: 'cos(x^5)'.
	self assert: (fx derivativeFor: $x) equals: (MathExpression from: '5*(x^4*-sin(x^5))').


]

{ #category : #tests }
MathExpressionMixedTest >> testFunnyConstructors [
	"Some more complicated parsing tests"
	| fx |

	fx := (MathExpPower leftSide: x rightSide: 2).
	self assert: fx equals: x ** two.

	fx := (MathExpPower leftSide: x rightSide: 2) simplify.
	self assert: fx equals: x ** two.

	fx := (MathExpPower leftSide: x rightSide: 1/2) simplify.
	self assert: fx equals: x squareRoot.

	"Not square.. mutate"
	fx := (MathExpSqr leftSide: x rightSide: 8).
	self assert: fx equals: x ** 8.
	self assert: fx class equals: MathExpPower.

	"Not squareroot.. mutate"
	fx := (MathExpSquareRoot leftSide: x rightSide: 9).
	self assert: fx equals: x ** 9.
	self assert: fx class equals: MathExpPower.

	"remains"
	fx := (MathExpSquareRoot leftSide: MathExpVariable x rightSide: 1/2).
	self assert: fx equals: x squareRoot.
	self assert: fx class equals: MathExpSquareRoot.

	"n log m"
	fx := (MathExpLogarithm leftSide: 3 rightSide: 5).
	self assert: fx class equals: MathExpLogarithm.

	"log"
	fx := (MathExpLogarithm leftSide: 10 rightSide: x).
	self assert: fx class equals: MathExpLogarithmBaseTen.
	self assert: fx equals: x log.

	"ln"
	fx := (MathExpLogarithm leftSide: e rightSide: x).
	self assert: fx class equals: MathExpLogarithmBaseE.
	self assert: fx equals: x ln.

	"log2"
	fx := (MathExpLogarithm leftSide: 2 rightSide: x).
	self assert: fx class equals: MathExpLogarithmBaseTwo.
	self assert: fx equals: x log2.
]

{ #category : #tests }
MathExpressionMixedTest >> testHardFix [
	"Multiple errors I found in debug that should work now"
	| fx dx |

	fx := MathExpVariable x.
	self assert: fx asString equals: 'x'.

	fx := MathExpVariable x negated.
	self assert: fx asString equals: '-x'.

	fx := MathExpNegative on: (MathExpVariable x negated).
	self assert: fx asString equals: '-(-x)'.

	fx := MathExpression from: 'x - (-y)'.
	self assert: fx asString equals: 'x - (-y)'.

	fx := MathExpression from: '2 * 3 / 4'.	"Shoudnt print (2*3)/4"
	fx settings: testSettings.
	self assert: fx asString equals: '(2*3)/4'.

	fx := (MathExpression from: '2 + 3 / 4').	"Shouldn't print 2+(3/4)"
	fx settings: testSettings.
	self assert: fx asString equals: '2+3/4'.

	fx := (MathExpression from: '(2 + 3) / 4').	"Shouldn't print 2+3/4"
	fx settings: testSettings.
	self assert: fx asString equals: '(2+3)/4'.

	fx := MathExpression from: '2 * -x'.
	self assert: fx equals: (MathExpNumber two * (x negated)).
	fx := MathExpression from: '2 * -x'.
	self assert: fx simplify equals: (MathExpNumber minusTwo * x).

	fx := MathExpression from: '-2 + 6'.
	self assert: fx asNumber equals: 4.

	fx := MathExpression from: '-2 - 6'.
	self assert: fx asNumber equals: -8.

	fx := MathExpression from: '-2 * 6'.
	self assert: fx asNumber equals: -12.

	fx := MathExpression from: '2 * -6'.
	self assert: fx asNumber equals: -12.

	fx := MathExpression from: '2 / 6'.
	self assert: fx asNumber equals: 1/3.

	fx := MathExpression from: '2 / -6'.
	self assert: fx asNumber equals: -1/3.

	fx := MathExpression from: '-2 / -6'.
	self assert: fx asNumber equals: 1/3.

	fx := MathExpression from: '+x'.
	self assert: fx simplify equals: x.

	fx := MathExpression from: '-x'.
	self assert: fx simplify equals: x negated.

	fx := MathExpression from: '-(-x)'.
	self assert: fx simplify equals: x.

	fx := MathExpression from: '-1 * x'.
	self assert: fx simplify equals: x negated.

	fx := MathExpression from: '-x + 6'.
	self assert: fx simplify equals: x negated + 6.

	fx := MathExpression from: '-x - 6'.
	self assert: fx simplify equals: x negated - 6.

	fx := MathExpression from: '-x * 6'.
	self assert: fx simplify equals: MathExpNumber six negated * x.

	fx := MathExpression from: '-x / 6'.
	self assert: fx simplify equals: x / 6 negated.

	fx := MathExpression from: '-x ^ 6'.
	self assert: fx simplify equals: (x ** 6) negated.

	fx := MathExpression from: '(-x) ^ 6'.
	self assert: fx simplify equals: x ** 6.

	fx := MathExpression from: '(-x) ^ 5 ^ 6'.
	self assert: fx simplify equals: x ** 30.

	fx := MathExpression from: '-(2 * x)'.
	self assert: fx simplify equals: two negated * x.

	fx := MathExpression from: '-(x * 2)'.
	self assert: fx simplify equals: two negated * x.

	fx := MathExpression from: '-(x + 2)'.
	self assert: fx simplify asString equals: '-x - 2'.

	fx := MathExpression from: '-(x - 2)'.
	self assert: fx simplify asString equals: '-x + 2'.

	fx := MathExpression from: '2 * (4 + x)'.
	self assert: fx simplify equals: two * x + 8.

	fx := MathExpression from: '2 * (4 - x)'.
	self assert: fx simplify equals: two negated * x + 8.

	fx := MathExpression from: '2 * (4 * x)'.
	self assert: fx simplify equals: x * 8.

	fx := MathExpression from: '(2 + x) + (4 * x)'.
	self assert: fx simplify equals: x * 5 + 2.

	fx := MathExpression from: '(2 * x) * (4 * x)'.
	self assert: fx simplify equals: (x ** 2) * 8.

	fx := MathExpression from: '(2 + x) + (4 + x)'.
	self assert: fx simplify equals: two*x + six.

	fx := MathExpression from: 'sin(' , 45 degreesToRadians asString , ')'.
	self assert: fx simplify equals: (MathExpNumber value: (45 degreesToRadians)) sin.

	fx := MathExpression from: '8 / x*4 - x^2*9 + 7*x^3'.
	self assert: fx simplify equals: (seven * (x**3)) + (nine negated * (x**2)) + ((MathExpNumber value: 32)/x).

	fx := MathExpression from: 'cos(x^4*3)'.
	dx := fx derivativeFor: x.
	self assert: dx equals: (MathExpression from: '12*(x^3*-sin(3*x^4))').

	fx := MathExpression from: 'x*2'.	"1*2+x*0"
	dx := fx derivativeFor: x.
	self assert: dx equals: two.

	fx := MathExpression from: 'x/2'.	"(1*2-(x*0))/2^2"
	dx := fx derivativeFor: x.
	self assert: dx equals: MathExpNumber oneHalf.

	fx := MathExpression from: 'x^2'.	"1*2*x^(2-1)+0*ln(x)*x^2"
	dx := fx derivativeFor: x.
	self assert: dx equals: x*2.

	fx := MathExpression from: 'x + 2'.	"1-0"
	dx := fx derivativeFor: x.
	self assert: dx equals: one.

	fx := MathExpression from: 'x-2'.	"1-0"
	dx := fx derivativeFor: x.
	self assert: dx equals: one.

	fx := MathExpression from: '-(x^3)'.	"-3*x^2"
	dx := fx derivativeFor: x.
	self assert: dx equals: (MathExpression from: '-3*x^2').

	fx := MathExpression from: '2*sin(x^2)'.	"2*2*x*(cos(x^2))"
	dx := fx derivativeFor: x.
	self assert: dx equals: (MathExpression from: '4*(x*cos(x^2))').

	fx := MathExpression from: '3*ln(x^2)'.	"3*2*x/x^2"
	dx := fx derivativeFor: x.
	self assert: dx equals: six / x.

	fx := MathExpression from: 'tan( x )'.	"1/(cos(x)^2)"
	dx := fx derivativeFor: x.
	self assert: dx equals: (MathExpression from: '1/(cos(x)^2)').

	fx := MathExpression from: 'cos(x + 2)'.
	dx := fx derivativeFor: x.
	self assert: dx equals: (x + 2) sin negated.

	fx := MathExpression from: 'sin(x * 1)'.
	dx := fx derivativeFor: x.
	self assert: dx equals: (x cos).

	fx := MathExpression from: '3*ln(x^2)'.
	dx := fx derivativeFor: x.
	self assert: dx equals: six / x.
]

{ #category : #tests }
MathExpressionMixedTest >> testManualConversion [
	"Some more complicated parsing tests"
	| fx |

	fx := MathExpression from: 'pi + 4'.
	self assert: fx asNumber equals: 7.141592653589793.

	fx := MathExpression from: 'pi + 3'.
	self assert: fx asBlock asString equals: '[ Float pi + 3 ]'.

	fx := MathExpression from: 'x + x + pi + y'.
	self assert: fx asBlock asString equals: '[ :x :y | x + x + Float pi + y ]'.

	fx := MathExpression from: 'm + m + pi + n'.
	self assert: fx simplify asBlock asString equals: [ :m :n | m * 2 + (n + Float pi) ] asString.
]

{ #category : #tests }
MathExpressionMixedTest >> testMissingParenthesisCompletion [
	"Some more complicated parsing tests"
	| fx |

	"Is OK I raise a notification for now"

	fx := MathExpression from: '(x + log(x'.
	self assert: fx equals: x + x log.

	fx := MathExpression from: 'ln(x)) + x)'.
	self assert: fx equals: x ln + x.
]

{ #category : #tests }
MathExpressionMixedTest >> testNumericParserExtension [
	"I support a bit more than Smalltalk when parsing"

	"Using parser"
	self assert: (MathExpression from: '1') asNumber equals: 1.
	self assert: (MathExpression from: '5') asNumber equals: 5.
	self assert: (MathExpression from: '0.6') asNumber equals: 0.6.
	self assert: (MathExpression from: '.9') asNumber equals: 0.9.
	self assert: (MathExpression from: '-8') asNumber equals: -8.
	self assert: (MathExpression from: '-.3') asNumber equals: -0.3.

	"Number accept number.. which.. may come as a surprise.."
	self assert: (MathExpNumber value: 123456e2) asNumber equals: 12345600.

	"Expression support stuff.. it may return a number, a variable.. or something else"
	self assert: (MathExpression safeguard: '3') asNumber equals: 3.
	self assert: (MathExpression safeguard: '44') asNumber equals: 44.
	self assert: (MathExpression safeguard: '-5') asNumber equals: -5.
	self assert: (MathExpression safeguard: '+7') asNumber equals: 7. "support +"
	self assert: (MathExpression safeguard: '+5.6') asNumber equals: 5.6.
	self assert: (MathExpression safeguard: '-5.6') asNumber equals: -5.6.
	self assert: (MathExpression safeguard: '-05.60') asNumber equals: -5.6.
	self assert: (MathExpression safeguard: '-.6') asNumber equals: -0.6. "missing zero"
	self assert: (MathExpression safeguard: '+.3') asNumber equals: 0.3.
	self assert: (MathExpression safeguard: '.3') asNumber equals: 0.3.
	self assert: (MathExpression safeguard: '3e-4') asNumber asFloat equals: 0.0003.
	self assert: (MathExpression safeguard: '123.456e-1') asNumber equals: 12.3456. "tricky case"
		
]

{ #category : #tests }
MathExpressionMixedTest >> testPrettyOnes [
	"These are good to detect simplification problems"
	| fx sx |

	fx := MathExpression from: 'abs(-volume)'.
	sx := MathExpression from: 'abs(volume)'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: 'sqr(-sqr(-mass))'.
	sx := MathExpression from: 'mass^4'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: 'x^-2'.
	sx := MathExpression from: '1/x^2'.
	self assert: (fx simplify) equals: sx.
]

{ #category : #tests }
MathExpressionMixedTest >> testRecurrentIssues1 [
	"These are good to detect simplification problems"
	| fx sx dx |

	fx := MathExpression from: 'sin(x) * cos(abs(x**2)) / sin(x)'.
	sx := MathExpression from: 'cos(x^2)'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '(6/x) / (2/3)'.
	sx := MathExpression from: '9/x'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: ' (6 * x^y ) / (3 * x) '.
	sx := MathExpression from: '2 * x^(y-1)'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '6 + pi + 4'.
	sx := MathExpression from: '10 + pi'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '6 - pi + 4'.
	sx := MathExpression from: '10 - pi'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '6 + pi - 4'.
	sx := MathExpression from: '2 + pi'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '6 + pi - 4'.
	sx := MathExpression from: '2 + pi'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '(x/2) / 8'.
	sx := MathExpression from: 'x/16'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '(x * y) * y'.
	sx := MathExpression from: 'y^2*x'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: 'abs(x*x)'.
	dx := MathExpression from: '2*x'.
	self assert: (fx derivativeFor: x) equals: dx.

	fx := MathExpression from: '3 * ln(x**2)'.
	dx := MathExpression from: '6/x'.
	self assert: (fx derivativeFor: x) equals: dx.

	fx := MathExpression from: '3*2^1 * 1^-1 * x^1 * x^-2'.
	sx := MathExpression from: '6/x'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: 'cos(x + 2)'.
	dx := MathExpression from: '-sin(x + 2)'.
	self assert: (fx derivativeFor: x) equals: dx.

	fx := MathExpression from: 'cos(x + 2*x)'.
	dx := MathExpression from: '-3*sin(3*x)'.
	self assert: (fx derivativeFor: x) equals: dx.
]

{ #category : #tests }
MathExpressionMixedTest >> testRecurrentIssues2 [
	"These are good to detect simplification problems"
	| fx sx |

	fx := MathExpression from: '-(-x/y)'.
	sx := MathExpression from: 'x/y'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '(-x/y)'.
	sx := MathExpression from: '-(x/y)'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '(x/-y)'.
	sx := MathExpression from: '-(x/y)'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '(x/-2)'.
	sx := MathExpression from: 'x/-2'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '(-3/x)'.
	sx := MathExpression from: '-3/x'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '(-3/-x)'.
	sx := MathExpression from: '3/x'.
	self assert: (fx simplify) equals: sx.
]

{ #category : #tests }
MathExpressionMixedTest >> testRecurrentIssues3 [
	"These are good to detect simplification problems"
	| fx sx |

	fx := MathExpression from: 'cos(pi*4)'.
	sx := MathExpNumber one.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: 'cos(pi)'.
	sx := MathExpNumber minusOne.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: 'sin(pi)'.
	sx := MathExpNumber zero.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: 'sin(pi*4)'.
	sx := MathExpNumber zero.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: 'sin(pi/2)'.
	sx := MathExpNumber one.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: 'sin(-pi/2)'.
	sx := MathExpNumber minusOne.
	self assert: (fx simplify) equals: sx.
]

{ #category : #tests }
MathExpressionMixedTest >> testRecurrentIssues4 [
	"These are good to detect simplification problems"
	| fx sx |

	"in case the term ordering gets broken"
	fx := MathExpression from: 'x + sin(x^2) + x'.
	sx := MathExpression from: '2*x + sin(x^2)'.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '0 + (0 - (0 + (0 + (0 + x))))'.
	sx := x negated.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '0 + (0 - (0 + (0 - (0 + x))))'.
	sx := x.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '0 * (0 - (0 + (0 * (0 + x))))'.
	sx := zero.
	self assert: (fx simplify) equals: sx.

	fx := MathExpression from: '-0 * (0 * (-0 * (0 * (-0 * x))))'.
	sx := zero.
	self assert: (fx simplify) equals: sx.
]

{ #category : #tests }
MathExpressionMixedTest >> testRecurrentIssues5 [
	"These are good to detect simplification problems"
	| f g |

	f := MathExpression from: '3+x'.
	g := MathExpression from: 'x+3'.
	self assert: f equals: g.

	f := MathExpression from: '3-x'.
	g := MathExpression from: 'x-3'.
	self assert: f ~= g.

	f := MathExpression from: '3*x'.
	g := MathExpression from: 'x*3'.
	self assert: f equals: g.

	f := MathExpression from: '3/x'.
	g := MathExpression from: 'x/3'.
	self assert: f ~= g.

	f := MathExpression from: '3/0'.
	g := MathExpUndefined new.
	self assert: f simplify equals: g.

	f := MathExpression from: '0/0'.
	g := MathExpUndefined new.
	self assert: f simplify equals: g.

	f := MathExpression from: 'log 0'.
	g := MathExpUndefined new.
	self assert: f simplify equals: g.
]

{ #category : #tests }
MathExpressionMixedTest >> testRecurrentIssues6 [
	"Endless combinations"
	| f g r |

	"-----------------------------------------------"
	f := MathExpression from: '(5 + x) + 3'.
	g := MathExpression from: '3 + (5 + x)'.
	r := MathExpression from: 'x+8'.
	self assert: f simplify equals: r.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 - x) + 3'.
	g := MathExpression from: '3 + (5 - x)'.
	r := MathExpression from: '-x+8'.
	self assert: f simplify equals: r.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 * x) + 3'.
	g := MathExpression from: '3 + (5 * x)'.
	r := MathExpression from: '5*x + 3'.
	self assert: f simplify equals: r.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 / x) + 3'.
	g := MathExpression from: '3 + (5 / x)'.
	r := MathExpression from: '5/x + 3'.
	self assert: f simplify equals: r.
	self assert: g simplify equals: r.

	"-----------------------------------------------"
	f := MathExpression from: '(5 + x) - 3'.
	r := MathExpression from: 'x+2'.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 - (5 + x)'.
	r := MathExpression from: '-x-2'.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 - x) - 3'.
	r := MathExpression from: '-x+2'.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 - (5 - x)'.
	r := MathExpression from: '+x-2'.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 * x) - 3'.
	r := MathExpression from: '5*x - 3'.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 - (5 * x)'.
	r := MathExpression from: '-5*x + 3'.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 / x) - 3'.
	r := MathExpression from: '5/x - 3'.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 - (5 / x)'.
	r := MathExpression from: '-5/x + 3'.
	self assert: g simplify equals: r.

	"-----------------------------------------------"
	f := MathExpression from: '(5 + x) * 3'.
	r := MathExpression from: '3*x + 15'.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 * (5 + x)'.
	r := MathExpression from: '3*x + 15'.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 - x) * 3'.
	r := MathExpression from: '-3*x + 15'.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 * (5 - x)'.
	r := MathExpression from: '-3*x + 15'.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 * x) * 3'.
	r := MathExpression from: '15*x'.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 * (5 * x)'.
	r := MathExpression from: '15*x'.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 / x) * 3'.
	r := MathExpression from: '15/x'.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 * (5 / x)'.
	r := MathExpression from: '15/x'.
	self assert: g simplify equals: r.

	"-----------------------------------------------"
	f := MathExpression from: '(5 + x) / 3'.
	r := f.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 / (5 + x)'.
	r := g.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 - x) / 3'.
	r := MathExpression from: '(-x + 5) / 3'.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 / (5 - x)'.
	r := MathExpression from: '3 / (-x + 5)'.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 * x) / 3'.
	r := x * (MathExpNumber value: 5/3).
	self assert: f simplify equals: r.
	g := MathExpression from: '3 / (5 * x)'.
	r := (MathExpNumber value: 3/5) / x.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 / x) / 3'.
	r := (MathExpNumber value: 5/3) / x.
	self assert: f simplify equals: r.
	g := MathExpression from: '3 / (5 / x)'.
	r := (MathExpNumber value: 3/5) * x.
	self assert: g simplify equals: r.

	f := MathExpression from: '(5 / x) / (1 / 3)'.
	r := MathExpression from: '15/x'.
	self assert: f simplify equals: r.
	g := MathExpression from: '(1 / 3) / (5 / x)'.
	r := (MathExpNumber value: 1/15) * x.
	self assert: g simplify equals: r.
]

{ #category : #tests }
MathExpressionMixedTest >> testSmalltalkUnsupported [
	"These are good to detect simplification problems"
	| fx |

	self should: [ MathExpNumber from: '.' ] raise: Exception.

	self should: [ MathExpNumber from: '2.' ] raise: Exception.

	self should: [ MathExpNumber from: '2e' ] raise: Exception.

	self should: [ MathExpNumber from: '.e' ] raise: Exception.

	fx := MathExpNumber from: '8'.
	self assert: fx asNumber equals: 8.

	fx := MathExpNumber from: '2.3'.
	self assert: fx asNumber equals: 2.3.

	fx := MathExpNumber from: '+2'.
	self assert: fx asNumber equals: 2.

	fx := MathExpNumber from: '-2'.
	self assert: fx asNumber equals: -2.

	fx := MathExpNumber from: '-2.46'.
	self assert: fx asNumber equals: -2.46.

	fx := MathExpNumber from: '2e1'.
	self assert: fx asNumber equals: 20.

	fx := MathExpNumber from: '2e2'.
	self assert: fx asNumber equals: 200.

	fx := MathExpNumber from: '2e2.5'.
	self assert: fx asNumber equals: 2*(10**2.5).

	fx := MathExpNumber from: '.6'.
	self assert: fx asNumber equals: 0.6.

	fx := MathExpNumber from: '.1'.
	self assert: fx asNumber equals: 0.1.

	fx := MathExpNumber from: '-.1'.
	self assert: fx asNumber equals: -0.1.

	fx := MathExpNumber from: 'e'.
	self assert: fx equals: e.

	fx := MathExpNumber from: 'e'.
	self assert: fx asNumber equals: Float e.
	
]

{ #category : #tests }
MathExpressionMixedTest >> testVariableNames [
	"Some things are guaranteed"
	self assert: (MathExpVariable symbol: #x) symbol equals: #x.
	self assert: (MathExpVariable symbol: 'x') symbol equals: #x.
	self assert: (MathExpVariable symbol: $x) symbol equals: #x.
	self assert: (MathExpVariable symbol: #y) symbol equals: #y.

	"Existing.. even if they are different instances"
	self assert: (MathExpVariable symbol: #x) equals: x.

	"Recently I extended this.. { E = mass * c ** 2"
	self assert: (MathExpVariable symbol: 'mass') symbol equals: #mass.
	self assert: (MathExpVariable symbol: 'c') symbol equals: #c.

	"another example.. so we are not so narrow-minded to only accept X and Y"
	self assert: (MathExpVariable symbol: 'volume') symbol equals: #volume.

	"Some names are automatically reserved"
	self should: [ MathExpVariable symbol: 'e' ] raise: AssertionFailure.
	self should: [ MathExpVariable symbol: 'pi' ] raise: AssertionFailure.
	self should: [ MathExpVariable symbol: 'phi' ] raise: AssertionFailure.
	self should: [ MathExpVariable symbol: '3' ] raise: AssertionFailure.
]
