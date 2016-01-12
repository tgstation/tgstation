/*
File: Options
*/
// Ascii values of characters
/var/const/ascii_A			= 65
/var/const/ascii_Z			= 90
/var/const/ascii_a			= 97
/var/const/ascii_z 			= 122
/var/const/ascii_DOLLAR		= 36	// $
/var/const/ascii_ZERO		= 48
/var/const/ascii_NINE		= 57
/var/const/ascii_UNDERSCORE	= 95	// _

/*
	Class: n_scriptOptions
*/
/datum/n_scriptOptions/proc/CanStartID(char) //returns true if the character can start a variable, function, or keyword name (by default letters or an underscore)
	if(!isnum(char))
		char = text2ascii(char)

	return (char in ascii_A to ascii_Z) || (char in ascii_a to ascii_z) || char == ascii_UNDERSCORE || char == ascii_DOLLAR

/datum/n_scriptOptions/proc/IsValidIDChar(char) //returns true if the character can be in the body of a variable, function, or keyword name (by default letters, numbers, and underscore)
	if(!isnum(char))
		char = text2ascii(char)

	return CanStartID(char) || IsDigit(char)

/datum/n_scriptOptions/proc/IsDigit(char)
	if(!isnum(char))
		char = text2ascii(char)

	return char in ascii_ZERO to ascii_NINE

/datum/n_scriptOptions/proc/IsValidID(id)    //returns true if all the characters in the string are okay to be in an identifier name
	if(!CanStartID(id)) //don't need to grab first char in id, since text2ascii does it automatically
		return 0

	if(length(id) == 1)
		return 1

	for(var/i=2 to length(id))
		if(!IsValidIDChar(copytext(id, i, i + 1)))
			return 0
	return 1

/*
	Class: nS_Options
	An implementation of <n_scriptOptions> for the n_Script language.
*/
/datum/n_scriptOptions/nS_Options
	var/list/symbols			= list(
		"(",
		")",
		"\[",
		"]",
		";",
		",",
		"{",
		"}"
	)     										//scanner - Characters that can be in symbols
/*
Var: keywords
An associative list used by the parser to parse keywords. Indices are strings which will trigger the keyword when parsed and the
associated values are <nS_Keyword> types of which the <n_Keyword.Parse()> proc will be called.
*/
	var/list/keywords 	 		= list(
		"if"		= /datum/n_Keyword/nS_Keyword/kwIf,
		"else"		= /datum/n_Keyword/nS_Keyword/kwElse,
		"elseif"	= /datum/n_Keyword/nS_Keyword/kwElseIf,
		"while"	 	= /datum/n_Keyword/nS_Keyword/kwWhile,
		"break"		= /datum/n_Keyword/nS_Keyword/kwBreak,
		"continue"	= /datum/n_Keyword/nS_Keyword/kwContinue,
		"return"	= /datum/n_Keyword/nS_Keyword/kwReturn,
		"def"		= /datum/n_Keyword/nS_Keyword/kwDef
	)

	var/list/assign_operators	= list(
		"="			= null,
		"&="		= "&",
		"|="		= "|",
		"`="		= "`",
		"+="		= "+",
		"-="		= "-",
		"*="		= "*",
		"/="		= "/",
		"^="		= "^",
		"%="		= "%"
	)

	var/list/unary_operators	= list(
		"!"			= /datum/node/expression/operator/unary/LogicalNot,
		"~"			= /datum/node/expression/operator/unary/BitwiseNot,
		"-"			= /datum/node/expression/operator/unary/Minus
	)

	var/list/binary_operators	= list(
		"=="		= /datum/node/expression/operator/binary/Equal,
		"!="		= /datum/node/expression/operator/binary/NotEqual,
		">"			= /datum/node/expression/operator/binary/Greater,
		"<" 		= /datum/node/expression/operator/binary/Less,
		">="		= /datum/node/expression/operator/binary/GreaterOrEqual,
		"<="		= /datum/node/expression/operator/binary/LessOrEqual,
		"&&"		= /datum/node/expression/operator/binary/LogicalAnd,
		"||"		= /datum/node/expression/operator/binary/LogicalOr,
		"&"			= /datum/node/expression/operator/binary/BitwiseAnd,
		"|"			= /datum/node/expression/operator/binary/BitwiseOr,
		"`"			= /datum/node/expression/operator/binary/BitwiseXor,
		"+"			= /datum/node/expression/operator/binary/Add,
		"-"			= /datum/node/expression/operator/binary/Subtract, 
		"*"			= /datum/node/expression/operator/binary/Multiply,
		"/"			= /datum/node/expression/operator/binary/Divide,
		"^"			= /datum/node/expression/operator/binary/Power,
		"%"			= /datum/node/expression/operator/binary/Modulo
	)

/datum/n_scriptOptions/nS_Options/New()
	. = ..()
	for(var/O in assign_operators + binary_operators + unary_operators)
		if(!symbols.Find(O))
			symbols += O