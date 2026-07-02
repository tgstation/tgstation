/datum/ntcode/error/lexer

/datum/ntcode/error/lexer/unknown_token

/datum/ntcode/error/lexer/unknown_token/to_string()
	return "Unexpected token"	

/datum/ntcode/error/lexer/unclosed_string

/datum/ntcode/error/lexer/unclosed_string/to_string()
	return "Unclosed string literal"
	
/datum/ntcode/error/lexer/unclosed_comment

/datum/ntcode/error/lexer/unclosed_comment/to_string()
	return "Unclosed comment block"
