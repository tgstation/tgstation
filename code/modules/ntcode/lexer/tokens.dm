/datum/ntcode/token
	var/datum/ntcode/token/next
	var/datum/ntcode/token/parent
	var/value
	var/length

	var/line_number
	var/line_offset


/datum/ntcode/token/New(value, length)
	src.value = value
	src.length = length

/datum/ntcode/token/proc/to_string()
	return "[value]"

/datum/ntcode/token/proc/parse(datum/ntcode/lexer/lexer, code)

/* Comment tokens MUST be first */
/datum/ntcode/token/comment

/datum/ntcode/token/comment/line

/datum/ntcode/token/comment/line/parse(datum/ntcode/lexer/lexer, code)
	if(findtext(code, "//") != 1)
		return
	var/index = 3
	while(index <= length(code) && code[index] != "\n")
		index++
	return new type("", index - 1)

/datum/ntcode/token/comment/block

/datum/ntcode/token/comment/block/parse(datum/ntcode/lexer/lexer, code)
	if(findtext(code, "/*") != 1)
		return
	var/index = 3
	while(index < length(code))
		if(code[index] == "*" && code[index + 1] == "/")
			index++
			return new type("", index)

		if(code[index] == "\n")
			lexer.current_line_number++
		index++
	lexer.error(/datum/ntcode/error/lexer/unclosed_comment)
	return null

/datum/ntcode/token/number

/datum/ntcode/token/number/parse(datum/ntcode/lexer/lexer, code)
	var/num = ""
	for(var/i = 1; i <= length(code); i++)
		var/digit = code[i]
		if(!text2num(digit) && digit != "0")
			break
		num += digit
	if(length(num))
		return new type(text2num(num), length(num))

/datum/ntcode/token/string

/datum/ntcode/token/string/parse(datum/ntcode/lexer/lexer, code)
	var/string = ""
	var/index = 1
	if(code[index] == "\"" || code[index] == "\'")
		var/string_marker = code[index]
		index++

		var/string_ends = FALSE
		while(index <= length(code))
			if(code[index] == string_marker)
				index++
				string_ends = TRUE
				break
			string += code[index]
			index++

			if(code[index] == "\n")
				lexer.current_line_number++

		if(!string_ends)
			lexer.error(/datum/ntcode/error/lexer/unclosed_string)
		return new type(string, index - 1)

/datum/ntcode/token/identifier
	var/alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_"

/datum/ntcode/token/identifier/parse(datum/ntcode/lexer/lexer, code)
	var/identifier = ""
	var/index = 1
	while(index <= length(code))
		if(!findtext(alphabet, code[index]))
			break
		identifier += code[index]
		index++

	if(length(identifier))
		return new type(identifier, length(identifier))


/datum/ntcode/token/keyword
	var/list/keywords = list(
		"return", "if", "else", "for", "while", "var",
		"break", "continue", "do", "const", "func"
	)

/datum/ntcode/token/keyword/parse(datum/ntcode/lexer/lexer, code)
	var/datum/ntcode/token/token = new /datum/ntcode/token/identifier().parse(lexer, code)
	if(token && token.value in keywords)
		return new type(token.value, token.length)

/datum/ntcode/token/oper
	var/list/operators = list(
		"<<=", ">>=", "==", "!=", "<=", ">=", "+=",
		"-=", "*=", "/=", "%=", "&=", "|=", "^=", "&&",
		"||", "<<", ">>", "+", "-", "=", "*", "/", "%", "|", "&", "!",
		">", "<" //TODO: "\[",  "++", "--",
	)

/datum/ntcode/token/oper/parse(datum/ntcode/lexer/lexer, code)
	for(var/operator in operators)
		if(findtext(code, operator, 1, length(operator) + 1))
			return new type(operator, length(operator))

/datum/ntcode/token/punctuator
	var/list/puncts = list(
		"(", ")", "{", "}",  ";", ":", ","
	)

/datum/ntcode/token/punctuator/parse(datum/ntcode/lexer/lexer, code)
	if(code[1] in puncts)
		return new type(code[1], 1)
