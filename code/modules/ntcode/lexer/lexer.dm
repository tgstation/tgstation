/datum/ntcode/lexer
	var/list/parsers = list()

	var/list/datum/ntcode/error/errors = list()

	var/current_line_number
	var/current_line_offset

/datum/ntcode/lexer/New()
	. = ..()
	if(type != /datum/ntcode/lexer)
		return

	for(var/parser_type in subtypesof(/datum/ntcode/token))
		parsers += parser_type

/datum/ntcode/lexer/proc/tokenize(code)
	var/datum/ntcode/token/head = new()
	var/datum/ntcode/token/current_token = head

	var/index = 1;

	errors.Cut()
	current_line_number = 1
	current_line_offset = 1

	while(index <= length(code))
		if(code[index] == " " || code[index] == "\n" || code[index] == "	" || code[index] == "\t")
			if(code[index] == "\n")
				current_line_number++
				current_line_offset = 1
			index++
			continue

		var/pcode = copytext(code, index)
		if(!length(pcode))
			break

		var/parsed = FALSE
		for(var/parser in parsers)
			var/datum/ntcode/token/token = new parser().parse(src, pcode)
			if(token && token.length)
				token.line_offset = current_line_offset
				token.line_number = current_line_number
				index += token.length
				current_line_offset += token.length
				parsed = TRUE

				if(!istype(token, /datum/ntcode/token/comment))
					current_token.next = token
					token.parent = current_token
					current_token = token
				
				break
		if(!parsed)
			world.log << "[pcode]"
			error(/datum/ntcode/error/lexer/unknown_token)
			break
	return head.next

/datum/ntcode/lexer/proc/error(error_type)
	errors += new error_type(current_line_number, current_line_offset)