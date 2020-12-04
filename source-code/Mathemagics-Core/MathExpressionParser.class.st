"
Class part: Implements a parser for mathematical expressions. It is based on Shunting Yard algorithm.

The design is based on the following concepts:
- Keep the parser to the very minimum, and avoiding heavy dependencies, therefore PetitParser, SmaCC, YAML and others were not used. I am completely sure they do an amazing job, but the overhead to implement them and dependencies were a detriment to the concept of using a simpler design. After all { a + b } is always the same.. shouldn't change any time soon. Therefore the Shunting Yard algorithm was implemented, also to have it written in Smalltalk.
- The algorithm itself is actually very simple. A minor extension was done for supporting functions and the unary sign ( '-' representing not subtraction but a negative value).
- Normally when buildng a language there would be a duplication between the classes doing the operations (Mathematical Addition) and the class that is used internally in the compiler (Addition for Compiler). This was avoided also with this approach.
- The parser will analyze every subclass under MathExpression, and dynamically add them to the accepted symbols.
- The basic parser configuration happens on initialization. If you modify the class structure, is best not to cache the parse until you finish.
- The parser can be reused for multiple expressions in case you need to do it in a loop or use it heaviy.

For the Responsibility part:
- The parser gets created, and cached objects are created with the current structure under MathExpression.
- The parser will take a String containing the mathematical expression to process. It will use cached objects to analyse the text.
- The parser two basic stacks to process the mathematical expression, and if all goes well, it will reach the end with one final expression.
- The #parse method returns the final expression, which internally is a tree of instances of MathExpression.

For the Collaborators Part:
- The main collaborator is the MathExpression class, especially the class methods.
- The secondar collaborators are the subclasses of MathExpression that will get created by executing a #perform on the instances.
- The methods (for instance #cos) are executed on the parsed expression. Therefore any Number is stored as MathExpression themselves.
- The parser depends internally on reflection, regular expressions, Stack, String and MathExpression classes for most of the work.

Public API and Key Messages

- Simple #new constructor will need to run the initialization methods: [ self new parse: '2 * x - 6' ].
- In the 'plugins' area you can find methods called during initialization. They will discover MathExpression properties.
- The #parse method is basically using infix notation, an extra method could support postfix notation { '2 x * sin' => 'sin(2*x)' }

   One simple example is simply gorgeous.

Profiling done and most objects are now cached, including MathExpression tree, list of functions and operator and compiled regular expressions. Time reduced to 2.053 sec for 1000 iteations to 107ms.

	| newParser |
	newParser := MathExpressionParser new.
	[ 1000 timesRepeat: [ newParser parse: 'x + pi' ] ] timeToRun.
"
Class {
	#name : #MathExpressionParser,
	#superclass : #Object,
	#instVars : [
		'cachedMathClasses',
		'cachedAmbiguousSymbols',
		'cachedUnarySymbols',
		'cachedPrecedences',
		'cachedRegExs',
		'cachedRegParsers',
		'cachedEquivalents',
		'pluginProcessingMethods',
		'outputStack',
		'tokensStack',
		'variables',
		'previousTokenType'
	],
	#classVars : [
		'Singleton'
	],
	#category : #'Mathemagics-Core-Parser'
}

{ #category : #'instance creation' }
MathExpressionParser class >> new [
	"Create the parser and forces to initialize once, in case you keep the instance."
	^ self basicNew initialize.
]

{ #category : #'instance creation' }
MathExpressionParser class >> reset [
	"Destroy the defaults.. the next call will default"
	Singleton := nil.
	"Avoid the warning"
	^ self.
]

{ #category : #'instance creation' }
MathExpressionParser class >> singletonParse: aMathExpressionTextInfixFormat [
	"The parser normaly doesnt change, so can be cached as singleton and parser."
	| myParser |
	myParser := (MathExpressionSettings useSingletonParser)
						ifTrue: [ Singleton ifNil: [ Singleton := self new ] ]
						ifFalse: [ self new ].
	"now call the parser"
	^ myParser parse: aMathExpressionTextInfixFormat.
]

{ #category : #'error handling' }
MathExpressionParser >> abortAndDisplay: aText [
	"Check a condition and raise the exception in a single step".
	ArithmeticError new signal: aText asString.
]

{ #category : #'error handling' }
MathExpressionParser >> abortWhen: aCondition display: aText [
	"Check a condition and raise the exception in a single step".
	(aCondition value) ifTrue: [ self abortAndDisplay: aText ]
]

{ #category : #initialization }
MathExpressionParser >> cache1MathSymbols [
	"It will analyse the class inheritance from Mathematical Expression, and keeps the mathSymbols for each."

	"Keep in the dictionary the Class -> mathSymbols"
	cachedMathClasses := Dictionary new.

	"Link each math expression with its symbol and adds lowercase if required"
	MathExpression allSubclasses select: [ :eachClass | eachClass isAbstract not ] thenDo: [ :eachClass |

		"Missing.. skip it.."
		(eachClass class selectors includes: #mathSymbol)
		ifTrue: [

			| builder allMySymbols |
			"Method to create the instance"
			builder := eachClass instantiationMethod.
		
        "All new classes implement mathSymbol to distinguish but the smalltalk usually is the same"
			(builder isNotNil and: [ (eachClass canUnderstand: builder) or: [ eachClass class canUnderstand: builder ] ])
			ifTrue: [  
				
				"Just add it first"
				allMySymbols := Set new.
				allMySymbols add: builder asSymbol.
				
				"Go through the symbols"
				eachClass mathSymbols do: [ :item | 					
					"ensure they are Symbol"
					allMySymbols add: (item asSymbol).
  					"generate all lowercase"
  					allMySymbols add: (item asLowercase asSymbol)
				].

				"finally add to the dictionary.."
				cachedMathClasses add: (Association key: eachClass value: allMySymbols).
				
			]				
			ifFalse: [ 

				"These are to be instantiated..."
				eachClass instantiationMethod ifNotNil: [ UIManager default inform: 'Class ' , eachClass asString , ' not implementing any operator.' ].
				
			].

		]
		ifFalse: [

			"Development bug.."
			UIManager default inform: 'Class ' , eachClass asString , ' missing the mathSymbol declaration!' 
			
		].
	
	].
]

{ #category : #initialization }
MathExpressionParser >> cache2HelperCollections [
	"Various lists for quickly processing mathematical operations"

	"ATM is only the unary negative vs the subtraction symbol, but hoping is smart to detect other cases"
	cachedAmbiguousSymbols := self findAmbiguous.

	"Dictionary: Search the mathematical expressions and build a quick access precedence dictionary [ i.e: + same as - ]"
	cachedPrecedences := self findPrecedences.

	"The ones that have more than one symbol but only one symbol implemented [ #cos and #cosine but only implementing #cos ]"
	cachedEquivalents := self findEquivalents.

	"List: Search the mathematical expressions that are unary and keep their symbol [ i.e: - ]"
	cachedUnarySymbols := (self collectSymbolsWhen: [ :eachClass | eachClass isSingleTerm ]) difference: cachedAmbiguousSymbols keys.

]

{ #category : #initialization }
MathExpressionParser >> cache3RegularExpressions [
	"Create a dictionary for each token type and its regular expression to use, just that simple."
	cachedRegExs := Dictionary new: 10.
	"These are pretty much fixed"
	cachedRegExs at: #number put: MathExpNumber numberRegexp.
	cachedRegExs at: #variable put: MathExpVariable nameRegexp.
	cachedRegExs at: #parenthesisBegin put: (self codeSymbolsAsRegex: { MathExpression parenthesisBegin }).
	cachedRegExs at: #parenthesisEnd put: (self codeSymbolsAsRegex: { MathExpression parenthesisEnd }).
	"These gets added as they add subexpressions"
	cachedRegExs at: #unary put: (self codeSymbolsAsRegexWhen: [ :eachClass | eachClass isAlsoUnarySign ]).
	cachedRegExs at: #constant put: (self codeSymbolsAsRegexWhen: [ :eachClass | eachClass isMathConstant ]).
	cachedRegExs at: #function put: (self codeSymbolsAsRegexWhen: [ :eachClass | eachClass isFunction ]).
	cachedRegExs at: #operator put: (self codeSymbolsAsRegexWhen: [ 
		"Improve a bit.. now that is settled"
		:eachClass | eachClass isBinaryOperator & eachClass isFunction not ]).

	"I will keep RxParser with the already precompiled regexp since is used twice later, and in case they reuse this parser"
	cachedRegParsers := Dictionary new: cachedRegExs size.
	cachedRegExs keysAndValuesDo: [ :key :value | cachedRegParsers at: key put: (value asRegex) ].

	"Shouldnt miss any otherwise stop"
	self abortWhen: (cachedRegParsers keys sort ~= self tokenTypesInParsingOrder sort) display: 'Parser missing a regular expression.'.
]

{ #category : #initialization }
MathExpressionParser >> cache4PluginProcessingMethods [
	"Any parser will end up mapping text to objects/methods that do the processing. This is dynamic in this case."
	pluginProcessingMethods := Dictionary new: 10.
	pluginProcessingMethods at: #number put: #pluginProcessNumber:.
	pluginProcessingMethods at: #variable put: #pluginProcessVariable:.
	pluginProcessingMethods at: #unary put: #pluginProcessUnarySign:.
	pluginProcessingMethods at: #operator put: #pluginProcessOperator:.
	pluginProcessingMethods at: #constant put: #pluginProcessMathConstant:.
	pluginProcessingMethods at: #function put: #pluginProcessMathFunction:.
	pluginProcessingMethods at: #parenthesisEnd put: #pluginProcessParenthesisEnd:.
	pluginProcessingMethods at: #parenthesisBegin put: #pluginProcessParenthesisBegin:.

	"Shouldnt miss any otherwise stop"
	self abortWhen: (pluginProcessingMethods keys sort ~= self tokenTypesInParsingOrder sort) display: 'Parser missing a token definition.'.

	"Since the methods are written as symbol, this may be renamed without knowing, so I check now"
	pluginProcessingMethods keysAndValuesDo: [
		:type :method |
		self assert: (self class canUnderstand: method)
				description: 'Parser can''t process  #' , type asString , ' since no method exists #' , method asString.
	].

	"NOTE: How is this working? Finding a #function, will send the token #cos to the method that handles it. All these methods get 1 parameter: the token parsed."
]

{ #category : #reflection }
MathExpressionParser >> codeSymbolsAsRegex: parsingSymbolsList [
	"Create a String that is a regular expression for all items from the list"
	| sortedItems escapedItems |

	"Sort avoids partial recognition longest go first: #( 'sqr' 'sqrt' ) => #( 'sqrt' 'sqr' )"
	sortedItems := parsingSymbolsList asArray sort: [ :item1 :item2 | (item1 size > item2 size) ].

	"Now make a 'regexpeable' list on that sorted items"
	escapedItems := sortedItems collect: [ :eachElement |
		| temp |
		"I start with the same string and replace it"
		temp := eachElement asString. "because they came as Symbol"
		"Change each of these single characters [ '+' => '\+']"
		self regexConflicts do: [ :eachReggy | temp := temp copyReplaceAll: eachReggy with: '\' , eachReggy ].
		"Done each regexp symbol so the string is ready"
		temp.
	].

	"Answers a String with all items as one regular expressions [ #($sqr $tan $sqrt ) => '(tan|sqrt|sqr|)' ]"
	^ $( asString , (escapedItems joinUsing: '|') , $) asString.
]

{ #category : #reflection }
MathExpressionParser >> codeSymbolsAsRegexWhen: aConditionBlock [
	"Just to tidy up the syntax.. is a sequencial call "
	^ self codeSymbolsAsRegex: (self collectSymbolsWhen: aConditionBlock).
]

{ #category : #reflection }
MathExpressionParser >> collectSymbolsWhen: aConditionBlock [
	"Iterate the dictionary and evaluate each class for the block. On those positive, return the symbol. "
	| result |

	"filling as I go"
	result:= Set new: cachedMathClasses size.

	"Simulating selectKey:thenCollectValue:"
	cachedMathClasses associationsDo: [ :eachPair | 
		(aConditionBlock value: eachPair key) ifTrue: [ result add: eachPair value ]
	].

	"ready .. but because mathSymbols return a set.. make it flat (which is Array) back to set"
	^ result flattened asSet.
]

{ #category : #'shunting-yard' }
MathExpressionParser >> detectToken: aTokenType onText: aInputText [
	"Returns the parsed text if matches the expression { parsing '123.4+x' will return #number->'123.4' }"
	| regexpParser |

	"Is already compiled but you can check in: { cachedRegExps at: aTokenType }"
	regexpParser := cachedRegParsers at: aTokenType.

	"Must start with.. not just somewhere.."
	(regexpParser matchesPrefix: aInputText) ifFalse: [ ^ nil ].

	"Find the FIRST occurrence in the text and return it. Notice this method is case sensitive."
	regexpParser matchesIn: aInputText collect: [ :each | ^ Association key: (aTokenType asSymbol) value: (each asString) ].

	"Should only happen during development"
	self abortAndDisplay: 'Parser failed to represent operator "' , aInputText , '"'.

	"NOTE: The reason for the association to have the type [i.e.: #function] and value [i.e.: 'sin'] as String is because may have special characters [ such as +2 ]."
]

{ #category : #reflection }
MathExpressionParser >> findAmbiguous [
	"Register here the ones that are ambiguous and keep the ones with lowest priority. Double checks missed ones."
	| result crossCheck |

	"Register here the ones"
	result := Dictionary new.

	"** REGISTER HERE THE ONES KNOWN AS AMBIGUOUS **"
	"Assumed once you added any ambiguous you taken care of it in the parser"
	result at: (MathExpNegative mathSymbol) put: (Association key: #unary value: (MathExpNegative mathSymbolSmalltalk)).

	"Cross check.. did you miss any?"
	crossCheck := Dictionary new: cachedMathClasses size.

	"I used to check all duplications but some function do collide. For instance I use log: for binary and based-log."
	cachedMathClasses keysDo: [ :eachMathClass |
		"Back to first idea.. use mathSymbol only here"
		| itsMathSymbol |
		itsMathSymbol := eachMathClass mathSymbol.
		"Is it already in the temp full search"
		crossCheck at: itsMathSymbol
		ifPresent: [ :foundClass |
			"Fail.. is not registered.."
			result at: itsMathSymbol ifAbsent: [
				| message |
				message := 'Ambigious symbol "' , itsMathSymbol asString , '": '.
				message := message , 'Class ' , foundClass asString.
				message := message, ' vs Class ' , eachMathClass asString.
				self abortAndDisplay: message.
			]
		]
		ifAbsent: [
			"keep it in the crosscheck.."
			crossCheck at: itsMathSymbol put: eachMathClass.
		].
	].

	^ result.
]

{ #category : #reflection }
MathExpressionParser >> findEquivalents [
	"Someone may put two math symbols [ such as 'pi' its symbol ] but only implements one message"
	| result |

	"This collects the ones"
	result := Dictionary new: (cachedMathClasses size).
	
	"Use the cache again.. already loaded should be fast.."
	cachedMathClasses associationsDo: [ :eachPair |

		"smalltalk selector"
		| eachClass allSymbols builder myAllowedSymbols |

		eachClass := eachPair key.
		allSymbols := eachPair value.
		
		"By now any missing this is filtered out.."
		builder := eachClass instantiationMethod.

		"the ones to be keep"
		myAllowedSymbols := allSymbols copy.

		"do not include the one already supported.. this is only equivalent"
		myAllowedSymbols remove: builder.

		"remove the ambiguous"
		myAllowedSymbols removeAllFoundIn: cachedAmbiguousSymbols keys.

		"Basically select:then .. but that syntax is longer!"
		myAllowedSymbols do: [ :extraSymbol | result at: extraSymbol asString put: builder ].

	].

	^ result.
]

{ #category : #reflection }
MathExpressionParser >> findPrecedences [
	"Return a dictionary with each class and its precedence"
	| result |

	"This collects the ones"
	result := Dictionary new: cachedMathClasses size.

	"Parenthesis, I decided, are not expression symbols, are more printing related, so I simulate them here"
	result at: MathExpression parenthesisBegin asString put: MathExpression precedence.
	result at: MathExpression parenthesisEnd asString put: MathExpression precedence.

	"Build on the dictionary (a bit naughty.. I add from outside, but is simpler code)"
	cachedMathClasses associationsDo: [ :eachPair |

		| myClass mySymbols |

		myClass := eachPair key.
		mySymbols := eachPair value.

		"Go through all the symbols"
		mySymbols do: [ :symbol |

			| addItem |

			"the items is not in the ambiguous"
			addItem := (cachedAmbiguousSymbols includesKey: symbol) not.
			"or it in the ambiguous but the Smalltalk code is not the same.."
			addItem := addItem or: [ (mySymbols includes: (cachedAmbiguousSymbols at: symbol) value) not ].
			"add in the precedence.."
			addItem ifTrue: [ 	result at: symbol put: myClass precedence ].

		].

	].

	^ result.
]

{ #category : #'shunting-yard' }
MathExpressionParser >> incomingToken: remainingToParse [
	"Find out what the next token is, and returns it if found."
	self tokenTypesInParsingOrder do: [ :eachType |

		"This allows to filter depending on conditions, in this case, Unary Negative"
		(self tokenAllowedOnParsing: eachType) ifTrue: [

			"Apply the detection of the token, and if returned something, exits this loop too"
			(self detectToken: eachType onText: remainingToParse) ifNotNil: [ :token | ^ token ].

		].

	].

	"Not found after all the work"
	self abortAndDisplay: 'Parser did not recognise text "' , remainingToParse , '"'.
]

{ #category : #initialization }
MathExpressionParser >> initialize [
	"Initialize the Shunting Yard algorithm objects"
	super initialize.

	"All Math classes and symbols"
	self cache1MathSymbols.

	"Lists used for speed"
	self cache2HelperCollections.

	"List of regular expressions to allow recognizing symbols"
	self cache3RegularExpressions.

	"Dynamically map each type of mathematical object into a processing function with the shape #xyz -> pluginProcessXYZ: token"
	self cache4PluginProcessingMethods.
]

{ #category : #'shunting-yard' }
MathExpressionParser >> parse: aMathExpressionTextInfixFormat [
	"Based on Shunting Yard algorithm. Using regular expression for analysis, builds the expressions until reaches the end of the string."
	| remainingToParse token pluginMethod |

	"Keep the expression that will be parsed in steps.."
	remainingToParse := self parserBegin: aMathExpressionTextInfixFormat.

	"Keep going consuming part of the text.."
	[ remainingToParse isNotEmpty ] whileTrue: [

		"Find out what is next"
		token := self incomingToken: remainingToParse.

		"Chop from the current text just recognised (BEFORE any replacement)"
		remainingToParse := (remainingToParse withoutPrefix: token value) trimLeft.

		"This is for ambiguity (find #unary '-' changes for #negated)"
		cachedAmbiguousSymbols at: token value ifPresent: [ :swap | swap key = token key ifTrue: [ token value: swap value ] ].

		"This is for Math vs Smalltalk (find 'arccos' changes for #arcCos)"
		cachedEquivalents at: token value ifPresent: [ :swap | token value: swap ].

		"Find based on the type, which method processes the type"
		pluginMethod := pluginProcessingMethods at: token key.

		"Now jump to the processing method. Basically is similar to BlockClosure: value."
		self perform: pluginMethod with: token.

		"Extension for the algorithm to support '+-3' or '*-8' "
		previousTokenType := token key.
	].

	"I may ended up with tokens not applied, due to their priority, therefore complete all now"
	[ tokensStack isNotEmpty ] whileTrue: [ self processStoredToken ].

	"Final validations, clean-up and returns the built expression"
	^ self parserEnd.
]

{ #category : #'shunting-yard' }
MathExpressionParser >> parserBegin: aTextInputBeforeCleanup [
	"Prepare for processing, reset variables and tidy up the incoming text and basic quick checks"
	| cleanedUpInput countOpen countClose |

	"Just in case is reusing instance I guarantee to clean up"
	previousTokenType := #start.

	"Stacks to implement the algorithm (I destroy if called again)"
	outputStack := Stack new.
	tokensStack := Stack new.

	"Variables detected, because finding another variable should not create a new instance"
	variables := Dictionary new.

	"From now we forget the parameter"
	cleanedUpInput := aTextInputBeforeCleanup asString trim asLowercase.
	self abortWhen: cleanedUpInput isEmpty display: 'No mathematical expression provided'.

	"Faster than full process (but the algorithm will close pending right parenthesis)"
	countOpen := cleanedUpInput count: [ :each | each asSymbol = MathExpression parenthesisBegin asSymbol ].
	countClose := cleanedUpInput count: [ :each | each asSymbol = MathExpression parenthesisEnd asSymbol ].

	(countOpen < countClose) ifTrue: [
		UIManager default inform: 'Adding extra opening parenthesis in "' , cleanedUpInput , '"'.
		cleanedUpInput := (MathExpression parenthesisBegin asString repeat: (countClose - countOpen)), cleanedUpInput.
	].

	(countOpen > countClose) ifTrue: [
		UIManager default inform: 'Adding extra closing parenthesis in "' , cleanedUpInput , '"'.
		cleanedUpInput := cleanedUpInput , (MathExpression parenthesisEnd asString repeat: (countOpen - countClose)).
	].

	"Return the text ready to parse"
	^ cleanedUpInput
]

{ #category : #'shunting-yard' }
MathExpressionParser >> parserEnd [
	"By now there are no tokens left to process, no text left to process, only 1 expression in the stack which is the full expression"
	self abortWhen: tokensStack isNotEmpty
	       display: 'Parser reached the end without using all tokens'. "code issue"

	self abortWhen: outputStack isEmpty
	       display: 'Parser didnt produce a final result'. "code issue"

	"The user typed something weird like { 2 + 3   546 } "
	(outputStack size > 1) ifTrue: [ self abortAndDisplay: 'Expression incorrect around: ' , (outputStack last asString) ].

	"Should always end up with one and only one expression"
	^ outputStack pop.
]

{ #category : #plugins }
MathExpressionParser >> pluginProcessMathConstant: incomingToken [
	"Creates a mathematical constant that gets queued in the output"
	| newMathConstant |
	newMathConstant := MathExpUniversalConstant perform: (incomingToken value asSymbol).
	outputStack push: newMathConstant.
]

{ #category : #plugins }
MathExpressionParser >> pluginProcessMathFunction: incomingToken [
	"Operations and functions normally get queued straight away.."
	tokensStack push: incomingToken.
]

{ #category : #plugins }
MathExpressionParser >> pluginProcessNumber: incomingToken [
	"Creates a mathematical constant (integer/decimal) that gets queued in the output"
	| newNumericConstant |
	"You may ask.. why not create a MathExpNumber? Because this validates, converts, and may not return 1 number alone!"
	newNumericConstant := MathExpNumber numericToNumber: incomingToken value "is a String at this time..".
	"Add in the output for future"
	outputStack push: newNumericConstant.
]

{ #category : #plugins }
MathExpressionParser >> pluginProcessOperator: incomingToken [
	"As per Shunting Yard algorithm, based on precedence decides if to queue or execute"
	[ tokensStack isNotEmpty and: [ (self precedenceOf: tokensStack first) >= (self precedenceOf: incomingToken) ] ]
		whileTrue: [ self processStoredToken ].

	"Regardless if forced others execution, it will now queue the new one"
	tokensStack push: incomingToken.
]

{ #category : #plugins }
MathExpressionParser >> pluginProcessParenthesisBegin: incomingToken [
	"Opening parenthesis go straight to the queue"
	tokensStack push: incomingToken.
]

{ #category : #plugins }
MathExpressionParser >> pluginProcessParenthesisEnd: incomingToken [
	"Ending parenthesis will not go to the queue, instead they force to evaluate all the way to the matching opening parenthesis."
	[tokensStack isNotEmpty] whileTrue: [
		(#parenthesisBegin = tokensStack first key)
		ifTrue: [
			"Remove the parenthesis, it was there just as a mark"
			tokensStack pop.
			"Functions [ such as sin(x) ] have parenthesis so they evaluate once more"
			(tokensStack isNotEmpty and: [ #function = tokensStack first key ]) ifTrue: [ ^ self processStoredToken "Stop as soon as evaluate the function"].
			"Must leave then.. otherwise changes parenthesis (3 + ((4 + 2) + 6)"
			^ self.
		]
		ifFalse: [ self processStoredToken "Does not return.. keep looping" ].
	].
]

{ #category : #plugins }
MathExpressionParser >> pluginProcessUnarySign: incomingToken [
	"Basically process a single sign [ -x or +x ]."
	(MathExpNegative mathSymbolSmalltalk = incomingToken value asSymbol) ifTrue: [
		"Only the negative does actually something, the positive can be ignored"
		tokensStack push: incomingToken.
	].
]

{ #category : #plugins }
MathExpressionParser >> pluginProcessVariable: incomingToken [
	"Create a Variable and store it (but wont re-create if already provided [ x^2 + x => once instance two references]"
	| variableName variableToQueue |
	"The name in the parsed text"
	variableName := incomingToken value asString.
	"Search if previously used [ i.e.: x + x^2 ]"
	variableToQueue := variables at: variableName ifAbsentPut: [ MathExpVariable symbol: variableName ].

	"Add the previous one or a new one"
	outputStack push: variableToQueue.
]

{ #category : #'shunting-yard' }
MathExpressionParser >> precedenceOf: aToken [
	"As per Shunting Yard algorithm, comparison is by priority/precedence"
	^ cachedPrecedences at: (aToken value) ifAbsent: [ self abortAndDisplay: 'Precedence not defined for "' , aToken value asString , '"' ].

	"NOTE: Interesting case.. -3^2 = -9 .. because it's considered like 0 - 3^2 .. but Smalltalk, Excel and other languages may differ."
]

{ #category : #'shunting-yard' }
MathExpressionParser >> processStoredToken [
	"As per Shunting Yard algorithm, apply the operator on the queued items"
	| tokenSymbol latestExpression previousExpression |

	self abortWhen: (tokensStack isEmpty) display: 'Parser have not found enough tokens to process'.
	tokenSymbol := tokensStack pop value asSymbol.

	self abortWhen: (outputStack isEmpty) display: 'No arguments remaining to apply "' , tokenSymbol asString , '"'.
	latestExpression := outputStack pop.

	"Unary .. I am ready.."
	(cachedUnarySymbols includes: tokenSymbol) ifTrue: [
		"Validates, otherwise I can print a nice message"
		self abortWhen: (latestExpression class canUnderstand: tokenSymbol) not
		       display: 'Expression "' , latestExpression asString , '" does not understand "' , tokenSymbol asString , '"'.
		"Execute the operation on the expression"
		^ outputStack push: ( latestExpression perform: tokenSymbol ).
	].

	"Binary.. should have at least one left (since I took the other)."
	self abortWhen: (outputStack isEmpty) display: 'Two arguments needed to apply "' , tokenSymbol asString, '"'.
	previousExpression := outputStack pop.

	"Validates, otherwise I can print a nice message"
	(latestExpression class canUnderstand: tokenSymbol) ifTrue: [
		"Build binary expression"
		^ outputStack push: ( previousExpression perform: tokenSymbol with: latestExpression ).
	].

	"Maybe I am talking of a key one.. adding :"
	tokenSymbol := (tokenSymbol asString , ':') asSymbol.
	self abortWhen: (latestExpression class canUnderstand: tokenSymbol) not
			 display: 'Expression "' , latestExpression asString , '" does not understand "' , tokenSymbol asString , '"'.

	"Build binary expression"
	^ outputStack push: ( previousExpression perform: tokenSymbol with: latestExpression ).
]

{ #category : #reflection }
MathExpressionParser >> regexConflicts [
	"These are the symbols that regexp gives meaning therefore I must escape (in String format)."
	^ #( '\' '*' '+' '-' '.' '?' '|' '^' '$' ':' '(' ')' '{' '}' ).
]

{ #category : #'shunting-yard' }
MathExpressionParser >> tokenAllowedOnParsing: aTokenType [
	"Single place to determine if I prioritise the unary symbols or not"
	^ (aTokenType ~= #unary) or: [ { #start . #operator . #parenthesisBegin } includes: previousTokenType ].
]

{ #category : #'shunting-yard' }
MathExpressionParser >> tokenTypesInParsingOrder [
	"Instead of IFfing.. this list is used to decide in which order the parser will try to analyse the text [ i.e.:  -2 +1 will try the unary negative first ]"
	^ { #unary . #operator . #number . #constant .  #function . #variable . #parenthesisBegin . #parenthesisEnd }.
]
