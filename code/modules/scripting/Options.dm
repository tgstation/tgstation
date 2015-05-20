/*
File: Options
*/
var/const  //Ascii values of characters
	ascii_A  =65
	ascii_Z  =90
	ascii_a  =97
	ascii_z  =122
	ascii_DOLLAR = 36 // $
	ascii_ZERO=48
	ascii_NINE=57
	ascii_UNDERSCORE=95	// _

/*
	Class: n_scriptOptions
*/
n_scriptOptions
	proc
		CanStartID(char) //returns true if the character can start a variable, function, or keyword name (by default letters or an underscore)
			if(!isnum(char))char=text2ascii(char)
			return (char in ascii_A to ascii_Z) || (char in ascii_a to ascii_z) || char==ascii_UNDERSCORE || char==ascii_DOLLAR

		IsValidIDChar(char) //returns true if the character can be in the body of a variable, function, or keyword name (by default letters, numbers, and underscore)
			if(!isnum(char))char=text2ascii(char)
			return CanStartID(char) || IsDigit(char)

		IsDigit(char)
			if(!isnum(char))char=text2ascii(char)
			return char in ascii_ZERO to ascii_NINE

		IsValidID(id)    //returns true if all the characters in the string are okay to be in an identifier name
			if(!CanStartID(id)) //don't need to grab first char in id, since text2ascii does it automatically
				return 0
			if(lentext(id)==1) return 1
			for(var/i=2 to lentext(id))
				if(!IsValidIDChar(copytext(id, i, i+1)))
					return 0
			return 1

/*
	Class: nS_Options
	An implementation of <n_scriptOptions> for the n_Script language.
*/
	nS_Options
		var
			list
				symbols  		= list("(", ")", "\[", "]", ";", ",", "{", "}")     										//scanner - Characters that can be in symbols
/*
	Var: keywords
	An associative list used by the parser to parse keywords. Indices are strings which will trigger the keyword when parsed and the
	associated values are <nS_Keyword> types of which the <n_Keyword.Parse()> proc will be called.
*/
				keywords 	 	= list("if" = /n_Keyword/nS_Keyword/kwIf,  "else"  = /n_Keyword/nS_Keyword/kwElse, "elseif" = /n_Keyword/nS_Keyword/kwElseIf, \
													 "while"	  = /n_Keyword/nS_Keyword/kwWhile,		"break"	= /n_Keyword/nS_Keyword/kwBreak, \
													 "continue" = /n_Keyword/nS_Keyword/kwContinue, \
													 "return" = /n_Keyword/nS_Keyword/kwReturn, 		"def"   = /n_Keyword/nS_Keyword/kwDef)

			list
				assign_operators=list("="  = null, 																					 "&=" = "&",
												 			"|=" = "|",																					 	 "`=" = "`",
															"+=" = "+",																						 "-=" = "-",
															"*=" = "*",																						 "/=" = "/",
															"^=" = "^",
															"%=" = "%")

				unary_operators =list("!"  = /node/expression/operator/unary/LogicalNot, 		 "~"  = /node/expression/operator/unary/BitwiseNot,
															"-"  = /node/expression/operator/unary/Minus)

				binary_operators=list("==" = /node/expression/operator/binary/Equal, 			   "!="	= /node/expression/operator/binary/NotEqual,
															">"  = /node/expression/operator/binary/Greater, 			 "<" 	= /node/expression/operator/binary/Less,
															">=" = /node/expression/operator/binary/GreaterOrEqual,"<=" = /node/expression/operator/binary/LessOrEqual,
															"&&" = /node/expression/operator/binary/LogicalAnd,  	 "||"	= /node/expression/operator/binary/LogicalOr,
															"&"  = /node/expression/operator/binary/BitwiseAnd,  	 "|" 	= /node/expression/operator/binary/BitwiseOr,
															"`"  = /node/expression/operator/binary/BitwiseXor,  	 "+" 	= /node/expression/operator/binary/Add,
															"-"  = /node/expression/operator/binary/Subtract, 		 "*" 	= /node/expression/operator/binary/Multiply,
															"/"  = /node/expression/operator/binary/Divide, 			 "^" 	= /node/expression/operator/binary/Power,
															"%"  = /node/expression/operator/binary/Modulo)

		New()
			.=..()
			for(var/O in assign_operators+binary_operators+unary_operators)
				if(!symbols.Find(O)) symbols+=O