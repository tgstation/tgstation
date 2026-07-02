/datum/ntcode/interpreter
	var/datum/ntcode/scope/current_scope

	var/list/datum/ntcode/module/modules

	var/max_iterations_count = 100

/datum/ntcode/interpreter/New()
	. = ..()
	current_scope = new()
	modules = list(
		new /datum/ntcode/module/math(),
		new /datum/ntcode/module/string(),
		new /datum/ntcode/module/debug()
	)

/datum/ntcode/interpreter/proc/error(error)
	world.log << error

/datum/ntcode/interpreter/proc/evaluate(code)
	var/datum/ntcode/lexer/lexer = new()
	var/datum/ntcode/token/head_token = lexer.tokenize(code)

	for(var/datum/ntcode/error/error in lexer.errors)
		world.log << "Lexer error - [error.line_number]:[error.line_offset] - [error.to_string()]."
		return

	var/datum/ntcode/parser/parser = new()
	var/datum/ntcode/node/head_node = parser.parse(head_token)

	world.log << head_node.to_string()
	for(var/datum/ntcode/error/error in parser.errors)
		world.log << "Syntax error - [error.line_number]:[error.line_offset] - [error.to_string()]."
		return

	var/datum/ntcode/analyzer/analyzer = new(modules)
	var/list/semantic_errors = analyzer.analyze(head_node)

	for(var/datum/ntcode/error/error in semantic_errors)
		world.log << "Semantic error - [error.line_number]:[error.line_offset] - [error.to_string()]."
		return

	if(!head_node)
		error("There is no program")
		return
	
	world.log << "STARTED EVALUATION"
	
	head_node.evaluate(src)
	
	var/datum/ntcode/function/main = current_scope.get_function("main")

	if(!main)
		error("Can't find entry point")
		return

	var/datum/ntcode/exception/error/result = main.evaluate(src)
	if(result)
		world.log << "FUNCTION MAIN ENDED WITH ERROR [result.message]"
		world.log << "STACK"
		for(var/datum/ntcode/function/function in result.stack)
			world.log << "[function.name]"

	return result


