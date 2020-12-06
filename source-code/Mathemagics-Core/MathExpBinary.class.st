"
Class part:

	Designed to support binary operations, typically addition, division, exponentiation, etc.
	
Responsibility part:

	Most of the behaviour is related with the printing (leftSide symbol rightSide) and support for special properties in some of the subclasses, such as associative property used mainly in the simplification process.

Public API and Key Messages:

	Most of the methods in the super class already define the behaviour of subclasses. Some of them directly check on the class (rather than implementing an abstract method here) because those are unlikely to change, and I saw that best documented than hundred of methods returning 'false' or 'true' in subclasses. Also avoided overloading Object class with even more methods, feels is going to explode!

Internal Representation and Key Implementation Points:

	People normally call ""left term"" and ""right term"", or ""base"" and ""exponent"" for different operations, but the functionality is the same. Left and right side is based on the order that they get written.
"
Class {
	#name : #MathExpBinary,
	#superclass : #MathExpression,
	#instVars : [
		'leftSide',
		'rightSide'
	],
	#category : #'Mathemagics-Core-Base'
}

{ #category : #testing }
MathExpBinary class >> isAbstract [
	^ self == MathExpBinary.
]

{ #category : #private }
MathExpBinary class >> leftSide: aLeftExpression rightSide: aRightExpression [
	"This constructor will create and set the left and right subexpressions to guarantee consistency."
	^ self new leftSide: aLeftExpression rightSide: aRightExpression.
]

{ #category : #comparing }
MathExpBinary >> = anExpression [
	"For performance.. these are basically always the same"
	| l1 l2 r1 r2 |
	(self == anExpression) ifTrue: [ ^ true ].

	"Must be the same otherwise fails already"
	(self class == anExpression class) ifFalse: [ ^ false ].

	"Prepare"
	l1 := self leftSide.
	l2 := self rightSide.
	r1 := anExpression leftSide.
	r2 := anExpression rightSide.

	"Both are the same, compare sides { l1 + l2 = r1 + r2 }. This is also supported inside the simplification."
	^ ((l1 = r1) and: [ l2 = r2 ]) or: [ self isCommutative and: [ (l1 = r2) and: [ l2 = r1 ] ] ].
]

{ #category : #converting }
MathExpBinary >> asCommutative [
	"Just to ease the code, sum and multiplication return self"
	self isCommutative ifTrue: [ ^ self ].
	"Most times this will fail"
	self error: 'The expression ' , self className , ' cannot be writen in Commutative form'.
]

{ #category : #printing }
MathExpBinary >> codeOn: aStream [
	"This just calls methods that repeat quite a bit of logic"

	"left side"
	self utilCodeTerm: leftSide onto: aStream.

	"Put the mathematical symbol in between"
	self utilCodeSymbolOnto: aStream.

	"Print right side"
	self utilCodeTerm: rightSide onto: aStream.
]

{ #category : #converting }
MathExpBinary >> commuteTerms [
	"Execute { a * (b * x) => (a * b) * x => c * x }"
	| flatTerms sortingHat sortedTerms |

	"to be 100% I can proceed"
	self assert: (self isCommutative or: [ self isAssociative ]).

	"remove the sublevels here.."
	flatTerms := self flatPackTerms.

	"Here is the magic trick... the sorting by term order speeds the process"
	sortingHat := [ :sortA : sortB | sortA termOrder <= sortB termOrder ].

	"Gryffindor!!!"
	sortedTerms := flatTerms sort: sortingHat.

	"Now extract from the sorted list"
	^ self flatUnpack: sortedTerms.
]

{ #category : #mathematics }
MathExpBinary >> degree [
	"Needs to delegate only, not subclass except power { (x^3 + x) returns 3 }"
	^ (leftSide degree) max: (rightSide degree).
]

{ #category : #converting }
MathExpBinary >> expand [
	"Usually special cases that as not associative or commutative { 3 + (5 - x) => 3 + 5 - x }"

	"to be 100% I can proceed"
	self assert: self isExpandable.

	"Ensure is commutative before moving terms"
	(self isCommutative not and: [ self canRewriteCommutative and: [ self wantsSortedTerms ] ] ) ifTrue: [ ^ self asCommutative commuteTerms ].

	"Just itself.. cannot expand"
	^ self.
]

{ #category : #converting }
MathExpBinary >> factorFromSum [
	"This is a special case of 'antifactoring', some people call it multiplication which is confusing."
	"Factoring is: { 2y + 6 => 2 * (y + 3) }"
	"In here we go: { x + (2 * x) => (1 * x) + (2 * x) => (1 + 2) * (x + x) }"

	"(x1 *|/ a) +|- (x2 *|/ b)"
	| term1 term2 x1 a x2 b coef |

	self assert: (self isClassAddition | self isClassSubtraction).
	self assert: (leftSide class isBinaryOperator not) | (leftSide isClassMultiplication) | (leftSide isClassDivision).
	self assert: (rightSide class isBinaryOperator not) | (rightSide isClassMultiplication) | (rightSide isClassDivision).

	"This puts the constant at the end"
	term1 := leftSide asProduct sortTermsIfNeeded.
	term2 := rightSide asProduct sortTermsIfNeeded.

	"b and d must be "
	x1 := term1 leftSide.
	a := term1 rightSide.
	x2:= term2 leftSide.
	b := term2 rightSide.

	"Basically..  not the same.. skip.. or.. x+(3/x) due to non commutativeness"
	(x1 = x2) ifFalse: [  ^ self ].

	"This only applies to + and -"
	coef := (self isClassSubtraction) ifTrue: [ a - b ] ifFalse: [ a + b ].

	"Generalising.. (x * a) + x => (x * a) + (x * 1) => x * (a + 1)"
	"Generalising.. (x * a) - x => (x * a) - (x * 1) => x * (a - 1)"
	^ x1 * coef.
]

{ #category : #converting }
MathExpBinary >> flatPackTerm: aTerm into: aCollection [
	"Either the leftSide or rightSide, to avoid code duplication. Notice is NOT recursive, is only 1 level."

	"It will convert to commutative if needed"
	| commutativeForm |

	"If not commutative and cannot be expressed as commutative just add the whole term"
	(aTerm isCommutative) | (aTerm canRewriteCommutative) ifFalse: [ ^ aCollection add: aTerm; yourself ].

	"ready to separate it"
	commutativeForm := aTerm asCommutative.

	"Not the same expression, just add the whole term"
	(commutativeForm class = self class) ifFalse: [ ^ aCollection add: aTerm; yourself ].

	"I can separate it"
	aCollection add: commutativeForm leftSide.
	aCollection add: commutativeForm rightSide.

	"Already added both so can return"
	^ aCollection.
]

{ #category : #converting }
MathExpBinary >> flatPackTerms [
	"Used for sorting term { x + ( x + 2 ) } => ( x , x , 2 ) }. Notice is NOT recursive, is only 1 level."
	"For other classes wont act { x + ( x / 2 ) } => ( x , (x / 2) ) }"
	| temp zero one |

	"to be 100% I can proceed"
	self assert: (self isCommutative or: [ self isAssociative ]).

	"I know I am associative by now... do each side"
	temp := OrderedCollection new.

	"this breaks the parts and add to the list"
	self flatPackTerm: leftSide into: temp.
	self flatPackTerm: rightSide into: temp.

	"creates only once"
	zero := MathExpNumber zero.
	one := MathExpNumber one.	

	"This is speed.. the library adds extra *1 for division we can remove now"
	(self isClassMultiplication) ifTrue: [ temp := temp reject: [ :each | each = one ] ].
	(self isClassAddition) ifTrue: [ temp := temp reject: [ :each | each = zero ] ].

	"ready"
	^ temp.
]

{ #category : #converting }
MathExpBinary >> flatUnpack: aSortedArray [
	"Rebuild from #( a b c ) => { (a + b) + c }."
	| item1 item2 item3 item4 newLeft newRight |

	"May have only 1?"
	item1 := aSortedArray first.
	(aSortedArray size = 1) ifTrue: [ ^ item1 ].

	"May have only 2"
	item2 := aSortedArray second.
	(aSortedArray size = 2) ifTrue: [ ^ self rewriteOnLeft: item1 andRight: item2 ].

	"Extract item 3.."
	item3 := aSortedArray third.
	(aSortedArray size = 3) ifTrue: [
		"Is a binary and unary"
		"Example: if (x + 2) + 1 => x + (1 + 2)"
		"Example: if x + (x + 5) => (x + x) + 5"
		"Example: if (2 - x) + 1 => -x + (2 +1)"
		(item1 relatedTo: item2)
			ifTrue: [
				newLeft := self rewriteOnLeft: item1 andRight: item2.
				newRight := item3.
			]
			ifFalse: [
				newLeft := item1.
				newRight := self rewriteOnLeft: item2 andRight: item3.
			].
		^ self rewriteOnLeft: newLeft andRight: newRight.
	].

	"Has 4.. put two and two"
	"( x + 2 ) + ( 4 + x ) => ( x + x ) + ( 2 + 4 )"
   item4 := aSortedArray fourth.
	newLeft := self rewriteOnLeft: item1 andRight: item2.
	newRight := self rewriteOnLeft: item3 andRight: item4.
	^ self rewriteOnLeft: newLeft andRight: newRight.

	"NOTE: Since equals does consider commutative the same.. this mehod cannot flag the change as a change in format"
]

{ #category : #comparing }
MathExpBinary >> hash [
	"Used by the queue inside the parser"
	^ (self class hash hashMultiply + leftSide hash) hashMultiply + rightSide hash.
]

{ #category : #testing }
MathExpBinary >> isExpandable [
	"This is the opposite of Factoring. Allows non associative and non commutative to get tidy up."
	| binarySide unarySide |

	"At least one is binary"
	(leftSide class isSingleTerm) & (rightSide class isSingleTerm) ifTrue: [ ^ false ].

	"For now.. only addition and subtraction support 2 binary"
	(leftSide class isSingleTerm not) & (rightSide class isSingleTerm not) ifTrue: [
		"Addition and Subtraction, yes, otherwise abort mission.."
		^ (self isClassAddition) | (self isClassSubtraction).
	].

	"No much I can do for you.."
	((self isCommutative not) and: [ self canRewriteCommutative not ]) ifTrue: [ ^ false ].

	"If they have nothing to do.. dont bother"
	binarySide := leftSide class isBinaryOperator ifTrue: [ leftSide ] ifFalse: [ rightSide ].
	unarySide := leftSide class isBinaryOperator ifTrue: [ rightSide ] ifFalse: [ leftSide ].
	(unarySide relatedTo: binarySide leftSide) | (unarySide relatedTo: binarySide rightSide) ifFalse: [ ^ false ].

	"The parent and one of the child expression must be commutative-like"
   ^ (leftSide canRewriteCommutative) | (rightSide canRewriteCommutative).
]

{ #category : #testing }
MathExpBinary >> isNumber [
	"Quick search without having to calculate the expression"
	^ leftSide isNumber and: [ rightSide isNumber ].
]

{ #category : #private }
MathExpBinary >> leftSide [
	"Designed to be handled by each related class, shouldnt need accessing from outside"
	^ leftSide.
]

{ #category : #private }
MathExpBinary >> leftSide: aLeftExpression rightSide: aRightExpression [
	"In case a number or a string with a number is send, it will wrap as constant first. Should be called on construction only."
	leftSide := (MathExpression safeguard: aLeftExpression).
	rightSide := (MathExpression safeguard: aRightExpression).
]

{ #category : #printing }
MathExpBinary >> printLeft: firstTerm printRight: secondTerm On: aStream [
	"This support the printing in the following form: (left) symbol (right). For instance { x + y }."
	| addExtraSpace |

	"This is just visual.. but normally people separate + and -"
	addExtraSpace := (self settings spacedTerms).
	addExtraSpace := addExtraSpace and: [ { MathExpAddition . MathExpSubtraction } includes: self class ].

	self utilPrint: firstTerm useParenthesis: (firstTerm wantsParenthesisUnder: self) onto: aStream.

	addExtraSpace ifTrue: [ self utilPrintSpaceOn: aStream ].

	self utilMathSymbolPrintedOn: aStream.

	addExtraSpace ifTrue: [ self utilPrintSpaceOn: aStream ].

	self utilPrint: secondTerm useParenthesis: (secondTerm wantsParenthesisUnder: self) onto: aStream.
]

{ #category : #printing }
MathExpBinary >> printOn: aStream [
	"By default just print left and right"
	self printLeft: leftSide printRight: rightSide On: aStream.
]

{ #category : #converting }
MathExpBinary >> replace: searchExpression with: replaceExpression [
	"Used to replace a subexpression for another."
	| newLeft newRight temp flatSearch |

	"First I compare myself"
	(self = searchExpression) ifTrue: [ ^ replaceExpression ].

	"It will rebuild if the subexpressions have changed"
	newLeft := leftSide replace: searchExpression with: replaceExpression.
	newRight := rightSide replace: searchExpression with: replaceExpression.
	(leftSide = newLeft) & (rightSide = newRight) ifFalse: [ ^ self rewriteOnLeft: newLeft  andRight: newRight ].

	"Getting to the end of posibilities.."
	(self canRewriteCommutative & searchExpression canRewriteCommutative) ifTrue: [

		"Separate the terms of myself"
		temp := self asCommutative flatPackTerms.

		"Separate the terms of the input"
		flatSearch := searchExpression asCommutative flatPackTerms.

		"Happens to have them.. then .. rebuild without"
		(temp includesAll: flatSearch) ifTrue: [
			"Delete the items"
			temp removeAll: flatSearch.
			"Add the new one as is"
			temp add: replaceExpression.
			"Now extract from the sorted list"
			^ self flatUnpack: temp asArray.
		].
	].

	"Return itself if no replacement"
	^ self.
]

{ #category : #private }
MathExpBinary >> rewriteOnLeft: aLeftExpression andRight: aRightExpression [
	"This create a new instance from the same class, from scratch, is not clone, is new"
	^ (self class) leftSide: aLeftExpression rightSide: aRightExpression.
]

{ #category : #private }
MathExpBinary >> rightSide [
	"Designed to be handled by each related class, shouldnt need accessing from outside"
	^ rightSide.
]

{ #category : #private }
MathExpBinary >> runDivisionOfFractions [
	"Should be queried first, but chances are is not supported for this operation"
	^ self.
]

{ #category : #private }
MathExpBinary >> runDivisionOfProducts [
	"Should be queried first, but chances are is not supported for this operation"
	^ self.
]

{ #category : #private }
MathExpBinary >> runLogarithmSimplification [
	"Should be queried first, but chances are is not supported for this operation"
	^ self.
]

{ #category : #private }
MathExpBinary >> runPowerSimplification [
	"Should be queried first, but chances are is not supported for this operation"
	^ self.
]

{ #category : #private }
MathExpBinary >> runSimplifyOnEachTerm: aBlockOnChange [
	"This is to reduce a bit of code.. and tidy up.. but should be used in a single place"
	| newLeft newRight |

	"simplify each term"
	newLeft := leftSide simplify.
	newRight := rightSide simplify.

	"Notice here may be affected by commutative in which case I build a new expression"
	(newLeft == leftSide) & (newRight == rightSide) ifFalse: [ aBlockOnChange value: (self rewriteOnLeft: newLeft andRight: newRight) ].
]

{ #category : #private }
MathExpBinary >> runSimplifyRulesTrailOn: aTrail [
	"Notice that must work top down because simplifying the lower subexpression may change it such as { x+x -> 2*x }"

	"Check if I can calculate and if the number is not .. a monster"
	self convertToNumber: [ :result | ^ MathExpNumber value: result ].

	"Now try to simplify each term.. if will only run the block if they did change.."
	self runSimplifyOnEachTerm: [ : newForm | ^ self simplifyInto: newForm trail: aTrail ].

	"Commutative/Associative expressions do this. It's designed for speed before Expanding."
	(self wantsCommutativeBracketed or: [ self wantsCommutativeRightwards or: [ self wantsCommutativeLeftwards ] ])
		ifTrue: [ ^ self simplifyInto: self commuteTerms trail: aTrail ].

	"No choice to try to expand terms that may help simplifying"
	self isExpandable ifTrue: [ | temp | temp := self expand. (self == temp) ifFalse: [ ^ self simplifyInto: temp trail: aTrail ] ].

	"THESE ARE NOT IN ALL OF THEM.. BUT SOME.. AND ARE BEST AFTER SIMPLER STEPS"

	"Division of fractions can be simplified { (a / b) / (c / d) => (a * d) / (b * c) }"
	self supportDivisionOfFractions ifTrue: [ ^ self simplifyInto: self runDivisionOfFractions trail: aTrail ].

	"A division of multiplications can be simplified { (x * b} / c => x * (b / c)"
	self supportDivisionOfProducts ifTrue: [ ^ self simplifyInto: self runDivisionOfProducts trail: aTrail ].

	"Convert to simpler power .. { x ^ n / x ^ m = x ^ (n-m) } and other cases"
	self supportPowerSimplification ifTrue: [ ^ self simplifyInto: self runPowerSimplification trail: aTrail ].

	"Business decision: { ln( e ^ x) = e ^ ln( x ) => x }. That is true except for x <= 0, sufficient for now."
	self supportLogarithmSimplification ifTrue: [ ^ self simplifyInto: self runLogarithmSimplification trail: aTrail ].

	"Ran out of options"
	^ self.
]

{ #category : #accessing }
MathExpBinary >> settings: selectedSettings [
	"Normally global is enough but you can choose differently."
	super settings: selectedSettings.
	leftSide settings: selectedSettings.
	rightSide settings: selectedSettings.
]

{ #category : #converting }
MathExpBinary >> sortTermsIfNeeded [
	"For cases that I simplify I can quickly resolve things like { 3 + x } => { x + 3 } in one go"
	self wantsSortedTerms ifTrue: [ self error: 'Class ' , self className , ' should override method.' "You added a new subclass?"].
	"Did nothing as the method implies.."
	^ self
]

{ #category : #testing }
MathExpBinary >> supportDivisionOfFractions [
	"(a / b) / (c / d) => (a * d) / (b * c). Simpler to have it in Binary."
	^ false.
]

{ #category : #testing }
MathExpBinary >> supportDivisionOfProducts [
	"(a * b) / (c * d) => (a/c) * (b/d). Simpler to have it in Binary."
	^ false.
]

{ #category : #testing }
MathExpBinary >> supportLogarithmSimplification [
	"e ^ ln( x ) => x"
	"b ^ log{b}( x ) => x"
	"log{b}( b ^ x ) => x"
	^ false.
]

{ #category : #testing }
MathExpBinary >> supportPowerSimplification [
	"Only multiplication and division and power"
	"x^n * x^m => x^(n+m)"
	"x^n / x^m => x^(n-m)"
	"(x^n) ^ m => x^(n*m)"
	^ false.
]

{ #category : #mathematics }
MathExpBinary >> termOrder [
	"Check superclass for more information"
	| temp lto rto |
	"Functions highlight so they dont move too far"
	temp := self class isFunction ifTrue: [ 'F' ] ifFalse: [ '' ].
	
	"each order now.."
	lto := leftSide termOrder.
	rto := rightSide termOrder.
	
	"can expect commutation to do better?"
	((lto > rto) and: [ self isCommutative | self canRewriteCommutative ]) ifTrue: [ ^ temp , rto , lto ].
	
	"as is.."
	^ temp , lto , rto.
]

{ #category : #accessing }
MathExpBinary >> variables [
	"Build the Set and add the right side and left side in that order because addAll changes it."
	^ Set new yourself; addAll: leftSide variables; addAll: rightSide variables; yourself.
]

{ #category : #testing }
MathExpBinary >> wantsCommutativeBracketed [
	"Answer if (x + a) + (x + b) -> (x + x) + (a + b) .. or .. (a * x) * (b * x) -> (a * b) * (x * x)"
	^ (self class = leftSide class) & (self class = rightSide class) and: [
			"Only make sense to go ahead if there is a variable on both sides "
			(leftSide variables & rightSide variables) isNotEmpty.
		].
]

{ #category : #testing }
MathExpBinary >> wantsCommutativeLeftwards [
	"Answer if x + (x + 5) => (x + x) + 5"
	"Answer if 8 + (x + 5) => x + (8 + 5)"
	"Answer if x * (x * 5) => (x * x) * 5"
	^ "(leftSide class isSingleTerm) &" (self isCommutative) & (self class = rightSide class) and: [
			(leftSide termOrder >= rightSide leftSide termOrder) | (leftSide termOrder >= rightSide rightSide termOrder) |
				((leftSide relatedTo: rightSide leftSide) & (rightSide leftSide relatedTo: rightSide rightSide) not)
		].
]

{ #category : #testing }
MathExpBinary >> wantsCommutativeRightwards [
	"Answer if (x + 5) + x => (x + x) + 5"
	"Answer if (x + 5) + 8 => x + (8 + 5)"
	"Answer if (x * 5) * x => (x * x) * 5"

	"Final checks"
	^ "(rightSide class isSingleTerm) &" (self isCommutative) & (self class = leftSide class) and: [
			(rightSide termOrder <= leftSide leftSide termOrder) | (rightSide termOrder <= leftSide rightSide termOrder) |
				((rightSide relatedTo: leftSide leftSide) & (leftSide leftSide relatedTo: leftSide rightSide) not)
		].
]

{ #category : #printing }
MathExpBinary >> wantsParenthesisUnder: parentExpression [
	"If I have a function has parenthesis... 1/abs(x)"
	(self class isFunction) ifTrue: [ ^ false ].
	
	"Compare this one, such as + vs * .. for instance.. { (a+b)*c } with { a-(b+c) }"
	^ (super wantsParenthesisUnder: parentExpression) or: [ (self class isBinaryOperator) & (parentExpression isCommutative not) ].
]

{ #category : #testing }
MathExpBinary >> wantsSortedTerms [
	"Shouldnt need overriding since ask the right questions"
	^ self isCommutative and: [ (leftSide termOrder) > (rightSide termOrder) ].
]
