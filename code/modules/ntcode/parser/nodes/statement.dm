/datum/ntcode/node/statement
	var/list/datum/ntcode/node/statement/statements = list()

/datum/ntcode/node/statement/New()
	. = ..()
	if(type != /datum/ntcode/node/statement)
		return
	for(var/statement in subtypesof(/datum/ntcode/node/statement/))
		statements += new statement
		
/datum/ntcode/node/statement/parse(datum/ntcode/parser/parser)
	if(parser.current_statements_count >= parser.max_statements_count)
		parser.error(new /datum/ntcode/error/parser/max_depth/statement(parser.current_token))
		return

	for(var/datum/ntcode/node/statement/statement_type in statements)
		var/result = statement_type.parse(parser)
		if(result)
			parser.current_statements_count++
			return result
