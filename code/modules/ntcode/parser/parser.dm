

/datum/ntcode/parser
	var/datum/ntcode/token/current_token
	var/list/errors = list()

	var/max_statements_count = 500
	var/max_expressions_count = 100
	var/max_blocks_count = 100

	var/current_statements_count

/datum/ntcode/parser/proc/parse(datum/ntcode/token/head)
	current_token = head
	current_statements_count = 0
	return new /datum/ntcode/node/root().parse(src)

/datum/ntcode/parser/proc/match_value(expected)
	if(!equals_value(expected))
		return FALSE
	advance()
	return TRUE

/datum/ntcode/parser/proc/skip_value(expected)
	if(!equals_value(expected))
		error(new /datum/ntcode/error/parser/unexpected/token/value(current_token, expected))
	advance()

/datum/ntcode/parser/proc/consume_value(expected)
	if(!current_token || current_token.value != expected)
		error(new /datum/ntcode/error/parser/unexpected/token/value(current_token, expected))
		return null
	var/value = current_token.value
	advance()
	return value

/datum/ntcode/parser/proc/equals_value(expected)
	if(!current_token)
		return expected == null
	return current_token.value == expected

/datum/ntcode/parser/proc/match(expected)
	if(istext(expected))
		return match_value(expected)
	if(!equals(expected))
		return FALSE
	advance()
	return TRUE

/datum/ntcode/parser/proc/skip(expected)
	if(istext(expected))
		return skip_value(expected)
	if(!equals(current_token, expected))
		error(new /datum/ntcode/error/parser/unexpected/token/type(current_token, expected))
	advance()

/datum/ntcode/parser/proc/consume(expected)
	if(istext(expected))
		return consume_value(expected)
	if(!current_token || current_token.type != expected)
		error(new /datum/ntcode/error/parser/unexpected/token/type(current_token, expected))
		return null
	var/value = current_token.value
	advance()
	return value

/datum/ntcode/parser/proc/equals(expected)
	if(istext(expected))
		return equals_value(expected)
	if(!current_token)
		return expected == null
	return current_token.type == expected

/datum/ntcode/parser/proc/advance()
	current_token = current_token.next

/datum/ntcode/parser/proc/error(datum/ntcode/error/parser/error)
	errors += error
	recover(list(";", "{", "}"))

/datum/ntcode/parser/proc/recover(list/sync_tokens)
	while(current_token && !(current_token.value in sync_tokens))
		advance()
