/*
	File: Expressions
	Procedures for parsing expressions.
*/

/*
	Macros: Expression Macros
	OPERATOR   - A value indicating the parser currently expects a binary operator.
	VALUE			 - A value indicating the parser currently expects a value.
	SHIFT      - Tells the parser to push the current operator onto the stack.
	REDUCE		 - Tells the parser to reduce the stack.
*/
#define OPERATOR  1
#define VALUE     2
#define SHIFT     0
#define REDUCE    1

/*
	Class: nS_Parser
*/
/n_Parser/nS_Parser
	var
/*
	Var: expecting
	A variable which keeps track of whether an operator or value is expected. It should be either <OPERATOR> or <VALUE>. See <ParseExpression()>
	for more information.
*/
		expecting=VALUE

	proc
/*
	Proc: Precedence
	Compares two operators, decides which is higher in the order of operations, and returns <SHIFT> or <REDUCE>.
*/
		Precedence(node/expression/operator/top, node/expression/operator/input)
			if(istype(top))
				top=top.precedence
			if(istype(input))
				input=input:precedence
			if(top>=input)
				return REDUCE
			return SHIFT

/*
	Proc: GetExpression
	Takes a token expected to represent a value and returns an <expression> node.
*/
		GetExpression(token/T)
			if(!T) return
			if(istype(T, /node/expression))
				return T
			switch(T.type)
				if(/token/word)
					return new/node/expression/value/variable(T.value)
				if(/token/accessor)
					var
						token/accessor/A=T
						node/expression/value/variable/E//=new(A.member)
						stack/S=new()
					while(istype(A.object, /token/accessor))
						S.Push(A)
						A=A.object
					ASSERT(istext(A.object))

					while(A)
						var/node/expression/value/variable/V=new()
						V.id=new(A.member)
						if(E)
							V.object=E
						else
							V.object=new/node/identifier(A.object)
						E=V
						A=S.Pop()
					return E

				if(/token/number, /token/string)
					return new/node/expression/value/literal(T.value)

/*
	Proc: GetOperator
	Gets a path related to a token or string and returns an instance of the given type. This is used to get an instance of either a binary or unary
	operator from a token.

	Parameters:
	O		 - The input value. If this is a token, O is reset to the token's value.
			   When O is a string and is in L, its associated value is used as the path to instantiate.
	type - The desired type of the returned object.
	L		 - The list in which to search for O.

	See Also:
	- <GetBinaryOperator()>
	- <GetUnaryOperator()>
*/
		GetOperator(O, type=/node/expression/operator, L[])
			if(istype(O, type)) return O		//O is already the desired type
			if(istype(O, /token)) O=O:value //sets O to text
			if(istext(O))										//sets O to path
				if(L.Find(O)) O=L[O]
				else return null
			if(ispath(O))O=new O						//catches path from last check
			else return null								//Unknown type
			return O

/*
	Proc: GetBinaryOperator
	Uses <GetOperator()> to search for an instance of a binary operator type with which the given string is associated. For example, if
	O is set to "+", an <Add> node is returned.

	See Also:
	- <GetOperator()>
	- <GetUnaryOperator()>
*/
		GetBinaryOperator(O)
			return GetOperator(O, /node/expression/operator/binary, options.binary_operators)

/*
	Proc: GetUnaryOperator
	Uses <GetOperator()> to search for an instance of a unary operator type with which the given string is associated. For example, if
	O is set to "!", a <LogicalNot> node is returned.

	See Also:
	- <GetOperator()>
	- <GetBinaryOperator()>
*/
		GetUnaryOperator(O)
			return GetOperator(O, /node/expression/operator/unary,  options.unary_operators)

/*
	Proc: Reduce
	Takes the operator on top of the opr stack and assigns its operand(s). Then this proc pushes the value of that operation to the top
	of the val stack.
*/
		Reduce(stack/opr, stack/val)
			var/node/expression/operator/O=opr.Pop()
			if(!O) return
			if(!istype(O))
				errors+=new/scriptError("Error reducing expression - invalid operator.")
				return
			//Take O and assign its operands, popping one or two values from the val stack
			//depending on whether O is a binary or unary operator.
			if(istype(O, /node/expression/operator/binary))
				var/node/expression/operator/binary/B=O
				B.exp2=val.Pop()
				B.exp =val.Pop()
				val.Push(B)
			else
				O.exp=val.Pop()
				val.Push(O)

/*
	Proc: EndOfExpression
	Returns true if the current token represents the end of an expression.

	Parameters:
	end - A list of values to compare the current token to.
*/
		EndOfExpression(end[])
			if(!curToken)
				return 1
			if(istype(curToken, /token/symbol) && end.Find(curToken.value))
				return 1
			if(istype(curToken, /token/end) && end.Find(/token/end))
				return 1
			return 0

/*
	Proc: ParseExpression
	Uses the Shunting-yard algorithm to parse expressions.

	Notes:
	- When an opening parenthesis is found, then <ParseParenExpression()> is called to handle it.
	- The <expecting>  variable helps distinguish unary operators from binary operators (for cases like the - operator, which can be either).

	Articles:
	- <http://epaperpress.com/oper/>
	- <http://en.wikipedia.org/wiki/Shunting-yard_algorithm>

	See Also:
	- <ParseFunctionExpression()>
	- <ParseParenExpression()>
	- <ParseParamExpression()>
*/
		ParseExpression(list/end=list(/token/end), list/ErrChars=list("{", "}"), check_functions = 0)
			var/stack
				opr=new
				val=new
			src.expecting=VALUE
			var/loop = 0
			for()
				loop++
				if(loop > 800)
					errors+=new/scriptError("Too many nested tokens.")
					return

				if(EndOfExpression(end))
					break
				if(istype(curToken, /token/symbol) && ErrChars.Find(curToken.value))
					errors+=new/scriptError/BadToken(curToken)
					break


				if(index>tokens.len)																						//End of File
					errors+=new/scriptError/EndOfFile()
					break
				var/token/ntok
				if(index+1<=tokens.len)
					ntok=tokens[index+1]

				if(istype(curToken, /token/symbol) && curToken.value=="(")			//Parse parentheses expression
					if(expecting!=VALUE)
						errors+=new/scriptError/ExpectedToken("operator", curToken)
						NextToken()
						continue
					val.Push(ParseParenExpression())

				else if(istype(curToken, /token/symbol))												//Operator found.
					var/node/expression/operator/curOperator											//Figure out whether it is unary or binary and get a new instance.
					if(src.expecting==OPERATOR)
						curOperator=GetBinaryOperator(curToken)
						if(!curOperator)
							errors+=new/scriptError/ExpectedToken("operator", curToken)
							NextToken()
							continue
					else
						curOperator=GetUnaryOperator(curToken)
						if(!curOperator) 																						//given symbol isn't a unary operator
							errors+=new/scriptError/ExpectedToken("expression", curToken)
							NextToken()
							continue

					if(opr.Top() && Precedence(opr.Top(), curOperator)==REDUCE)		//Check order of operations and reduce if necessary
						Reduce(opr, val)
						continue
					opr.Push(curOperator)
					src.expecting=VALUE

				else if(ntok && ntok.value=="(" && istype(ntok, /token/symbol)\
											&& istype(curToken, /token/word))								//Parse function call

					if(!check_functions)

						var/token/preToken=curToken
						var/old_expect=src.expecting
						var/fex=ParseFunctionExpression()
						if(old_expect!=VALUE)
							errors+=new/scriptError/ExpectedToken("operator", preToken)
							NextToken()
							continue
						val.Push(fex)
					else
						errors+=new/scriptError/ParameterFunction(curToken)
						break

				else if(istype(curToken, /token/keyword)) 										//inline keywords
					var/n_Keyword/kw=options.keywords[curToken.value]
					kw=new kw(inline=1)
					if(kw)
						if(!kw.Parse(src))
							return
					else
						errors+=new/scriptError/BadToken(curToken)

				else if(istype(curToken, /token/end)) 													//semicolon found where it wasn't expected
					errors+=new/scriptError/BadToken(curToken)
					NextToken()
					continue
				else
					if(expecting!=VALUE)
						errors+=new/scriptError/ExpectedToken("operator", curToken)
						NextToken()
						continue
					val.Push(GetExpression(curToken))
					src.expecting=OPERATOR

				NextToken()

			while(opr.Top()) Reduce(opr, val) 																//Reduce the value stack completely
			.=val.Pop()                       																//Return what should be the last value on the stack
			if(val.Top())                     																//
				var/node/N=val.Pop()
				errors+=new/scriptError("Error parsing expression. Unexpected value left on stack: [N.ToString()].")
				return null

/*
	Proc: ParseFunctionExpression
	Parses a function call inside of an expression.

	See Also:
	- <ParseExpression()>
*/
		ParseFunctionExpression()
			var/node/expression/FunctionCall/exp=new
			exp.func_name=curToken.value
			NextToken() //skip function name
			NextToken() //skip open parenthesis, already found
			var/loops = 0

			for()
				loops++
				if(loops>=800)
					errors += new/scriptError("Too many nested expressions.")
					break
					//CRASH("Something TERRIBLE has gone wrong in ParseFunctionExpression ;__;")

				if(istype(curToken, /token/symbol) && curToken.value==")")
					return exp
				exp.parameters+=ParseParamExpression()
				if(errors.len)
					return exp
				if(curToken.value==","&&istype(curToken, /token/symbol))NextToken()	//skip comma
				if(istype(curToken, /token/end))																		//Prevents infinite loop...
					errors+=new/scriptError/ExpectedToken(")")
					return exp

/*
	Proc: ParseParenExpression
	Parses an expression that ends with a close parenthesis. This is used for parsing expressions inside of parentheses.

	See Also:
	- <ParseExpression()>
*/
		ParseParenExpression()
			if(!CheckToken("(", /token/symbol))
				return
			return new/node/expression/operator/unary/group(ParseExpression(list(")")))

/*
	Proc: ParseParamExpression
	Parses an expression that ends with either a comma or close parenthesis. This is used for parsing the parameters passed to a function call.

	See Also:
	- <ParseExpression()>
*/
		ParseParamExpression(var/check_functions = 0)
			var/cf = check_functions
			return ParseExpression(list(",", ")"), check_functions = cf)