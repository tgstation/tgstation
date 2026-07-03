/datum/ntcode/error/semantic
	var/datum/ntcode/node/node

/datum/ntcode/error/semantic/New(datum/ntcode/node/node)
	. = ..()
	src.node = node
	if(node && node.node_token)
		line_number = node.node_token.line_number
		line_offset = node.node_token.line_offset

/datum/ntcode/error/semantic/unknown
	var/name

	var/value

/datum/ntcode/error/semantic/unknown/New(datum/ntcode/node/node, value)
	. = ..()
	src.value = value

/datum/ntcode/error/semantic/unknown/to_string()
	return "'[value]' is an unknown [name] in that scope"

/datum/ntcode/error/semantic/unknown/function
	name = "function"

/datum/ntcode/error/semantic/unknown/variable
	name = "variable"

/datum/ntcode/error/semantic/unknown/module
	name = "module"

/datum/ntcode/error/semantic/unknown/entry_point
	var/entry_point_name

/datum/ntcode/error/semantic/unknown/entry_point/New(datum/ntcode/node/node, entry_point_name)
	src.entry_point_name = entry_point_name

/datum/ntcode/error/semantic/unknown/entry_point/to_string()
	return "Can't find entry point [entry_point_name]"

/datum/ntcode/error/semantic/known
	var/name

	var/value

/datum/ntcode/error/semantic/known/New(datum/ntcode/node/node, value)
	. = ..()
	src.value = value

/datum/ntcode/error/semantic/known/to_string()
	return "[name] [value] is already exists in that scope"

/datum/ntcode/error/semantic/known/function
	name = "function"

/datum/ntcode/error/semantic/known/variable
	name = "variable"

/datum/ntcode/error/semantic/const_assign
	var/name

/datum/ntcode/error/semantic/const_assign/New(datum/ntcode/node/node, name)
	. = ..()
	src.name = name

/datum/ntcode/error/semantic/const_assign/to_string()
	return "You can't assign value to constant '[name]'"

/datum/ntcode/error/semantic/recursion
	var/function_name

/datum/ntcode/error/semantic/recursion/New(datum/ntcode/node/node, function_name)
	. = ..()
	src.function_name = function_name

/datum/ntcode/error/semantic/recursion/to_string()
	return "Recursion was detected in the '[function_name]' function. Recursion is an illegal Syndicate technology created to destroy Nanotrasen systems."

/datum/ntcode/error/semantic/invalid_arguments_count
	var/datum/ntcode/function/function
	var/arguments_count

/datum/ntcode/error/semantic/invalid_arguments_count/New(datum/ntcode/node/node, datum/ntcode/function/function, arguments_count)
	. = ..()
	src.function = function
	src.arguments_count = arguments_count

/datum/ntcode/error/semantic/invalid_arguments_count/to_string()
	var/result = ""
	if(arguments_count < function.arguments.len)
		result = "There are too few arguments."
	else
		result =  "There are too much arguments."
	result += " The '[function.name]' function accepts the following arguments: "
	if(function.arguments.len > 0)
		for(var/argument in function.arguments)
			result += "[argument], "
		result = copytext(result, 1, length(result) -1)
	else
		result += "none"
	return result
