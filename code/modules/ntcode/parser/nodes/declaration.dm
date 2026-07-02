/datum/ntcode/node/declaration
	var/list/datum/ntcode/node/declaration/declarations = list()

/datum/ntcode/node/declaration/New()
	. = ..()
	if(type != /datum/ntcode/node/declaration)
		return
	for(var/declaration in subtypesof(/datum/ntcode/node/declaration/))
		declarations += new declaration
		
/datum/ntcode/node/declaration/parse(datum/ntcode/parser/parser)
	for(var/datum/ntcode/node/declaration/declaration in declarations)
		var/result = declaration.parse(parser)
		if(result)
			return result
