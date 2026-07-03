/datum/ntcode/interpreter
	var/datum/ntcode/scope/current_scope

	var/list/datum/ntcode/module/modules

	var/max_iterations_count = 100

/datum/ntcode/interpreter/New()
	. = ..()
	current_scope = new()
	modules = list(
		new /datum/ntcode/module/math(),
		new /datum/ntcode/module/string()
	)

/datum/ntcode/interpreter/proc/compile(code)
	var/list/errors = list()
	var/datum/ntcode/lexer/lexer = new()
	var/datum/ntcode/token/head_token = lexer.tokenize(code)

	errors += lexer.errors
	if(errors.len || !head_token)
		return errors

	var/datum/ntcode/parser/parser = new()
	var/datum/ntcode/node/head_node = parser.parse(head_token)

	errors += parser.errors
	if(errors.len || !head_node)
		return errors

	var/datum/ntcode/analyzer/analyzer = new(modules)
	var/list/semantic_errors = analyzer.analyze(head_node)

	errors += semantic_errors
	if(errors.len)
		return errors

	head_node.evaluate(src)

/datum/ntcode/interpreter/proc/evaluate(args)


