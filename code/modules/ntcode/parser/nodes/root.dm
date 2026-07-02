/datum/ntcode/node/root
	var/datum/ntcode/node/head

	var/static/list/datum/ntcode/node/root_nodes = list(
		/datum/ntcode/node/declaration/function,
		/datum/ntcode/node/statement/simple/import
	)

/datum/ntcode/node/root/New(datum/ntcode/node/head)
	. = ..()
	src.head = head

/datum/ntcode/node/root/analyze(datum/ntcode/analyzer/analyzer)
	var/datum/ntcode/node/current_node = head
	while(current_node)
		if(istype(current_node, /datum/ntcode/node/declaration/function))
			var/datum/ntcode/node/declaration/function/function_node = current_node
			if(analyzer.current_scope.get_function(function_node.name))
				analyzer.error(new /datum/ntcode/error/semantic/known/function(src, function_node.name))
				return
			analyzer.current_scope.set_function(new /datum/ntcode/function/node(function_node.name, function_node.arguments, function_node.block))
		current_node = current_node.next

	current_node = head
	while(current_node)
		current_node.analyze(analyzer)
		current_node = current_node.next

/datum/ntcode/node/root/evaluate(datum/ntcode/interpreter/interpreter)
	var/datum/ntcode/node/current_node = head
	while(current_node)
		if(istype(current_node, /datum/ntcode/node/declaration/function))
			var/datum/ntcode/exception/exception = current_node.evaluate(interpreter)
			if(exception)
				return exception
		current_node = current_node.next

	current_node = head
	while(current_node)
		if(!istype(current_node, /datum/ntcode/node/declaration/function))
			var/datum/ntcode/exception/exception = current_node.evaluate(interpreter)
			if(exception)
				return exception
		current_node = current_node.next

/datum/ntcode/node/root/parse(datum/ntcode/parser/parser)
	var/datum/ntcode/node/head = new()
	var/datum/ntcode/node/current_node = head
	
	while(parser.current_token)
		var/node_parsed = FALSE
		for(var/root_node in root_nodes)
			var/result = new root_node().parse(parser)
			if(!result)
				continue

			node_parsed = TRUE
			current_node.next = result
			current_node = current_node.next
		if(!node_parsed)
			parser.error(new /datum/ntcode/error/parser/unexpected/construct(parser.current_token, "first-level instruction: import, function declaration"))
			break
	return new type(head.next)

/datum/ntcode/node/root/to_string(indent)
	var/result = ""
	var/datum/ntcode/node/current_node = head
	while(current_node)
		result += "[current_node.to_string(indent)]\n"
		current_node = current_node.next
	return result
	