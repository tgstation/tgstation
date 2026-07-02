/datum/ntcode/error/parser
	var/datum/ntcode/token/token

/datum/ntcode/error/parser/New(datum/ntcode/token/token)
	. = ..()
	if(token)
		src.line_number = token.line_number
		src.line_offset = token.line_offset
	src.token = token
	
/datum/ntcode/error/parser/unexpected/token
	var/expected

/datum/ntcode/error/parser/unexpected/token/New(datum/ntcode/token/token, expected)
	. = ..()
	src.token = token
	src.expected = expected

/datum/ntcode/error/parser/unexpected/token/value

/datum/ntcode/error/parser/unexpected/token/value/to_string()
	return "Expected '[expected]' got [token.value]"

/datum/ntcode/error/parser/unexpected/token/type

/datum/ntcode/error/parser/unexpected/token/type/to_string()
	var/list/split = splittext("[token.type]", "/")
	var/list/split_exp =  splittext("[expected]", "/")
	return "Expected '[split_exp[split_exp.len]]' got '[split[split.len]]'"

/datum/ntcode/error/parser/unexpected/construct
	var/construct_name

/datum/ntcode/error/parser/unexpected/construct/New(datum/ntcode/token/token, construct_name)
	. = ..()
	if(construct_name)
		src.construct_name = construct_name

/datum/ntcode/error/parser/unexpected/construct/to_string()
	return "Expected [construct_name] got '[token.value]'"
	
/datum/ntcode/error/parser/unexpected/construct/expression
	construct_name = "expression"

/datum/ntcode/error/parser/unexpected/construct/block
	construct_name = "block"

/datum/ntcode/error/parser/unexpected/construct/statement
	construct_name = "statement"

/datum/ntcode/error/parser/max_depth
	var/name

/datum/ntcode/error/parser/max_depth/to_string()
	return "Reached maximum [name]"

/datum/ntcode/error/parser/max_depth/expression
	name = "expression depth"

/datum/ntcode/error/parser/max_depth/statement
	name = "statements count"

/datum/ntcode/error/parser/max_depth/blocks
	name = "blocks count"