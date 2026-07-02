/datum/ntcode/node/declaration/function
	var/name
	var/list/arguments
	var/datum/ntcode/node/block/block

/datum/ntcode/node/declaration/function/New(name, list/arguments, datum/ntcode/node/block/block)
	. = ..()
	src.name = name
	src.arguments = arguments
	src.block = block

/datum/ntcode/node/declaration/function/analyze(datum/ntcode/analyzer/analyzer)
	var/datum/ntcode/scope/current_scope = analyzer.current_scope
	while(analyzer.current_scope.parent)
		analyzer.current_scope = analyzer.current_scope.parent

	for(var/i = 1; i <= arguments.len; i++)
		block.set_variable(new /datum/ntcode/variable(arguments[i], null))
	
	analyzer.call_stack += name
	block.analyze(analyzer)
	analyzer.call_stack.Cut()

	analyzer.current_scope = current_scope

/datum/ntcode/node/declaration/function/evaluate(datum/ntcode/interpreter/interpreter)
	interpreter.current_scope.set_function(new /datum/ntcode/function/node(name, arguments, block))

/datum/ntcode/node/declaration/function/parse(datum/ntcode/parser/parser)
	if(!parser.match("func"))
		return

	var/name = parser.consume(/datum/ntcode/token/identifier)
	parser.skip("(")

	var/arguments = list()
	while(!parser.equals(")"))
		var/arg_name = parser.consume(/datum/ntcode/token/identifier)
		if(!arg_name)
			return null
		arguments += arg_name
		if(parser.equals(")"))
			break
		parser.skip(",")
	parser.skip(")")

	var/block = new /datum/ntcode/node/block().parse(parser)
	if(!block)
		parser.error(new /datum/ntcode/error/parser/unexpected/construct/block(parser.current_token))
		return null
	return new type(name, arguments, block)

/datum/ntcode/node/declaration/function/to_string(indent)
	var/result = "[indent]func [name]("
	for(var/arg in arguments)
		result += "[arg], "
	if(arguments.len > 0)
		result = copytext(result, 1, length(result) - 1)
	return "[result])[block.to_string(indent)]"
