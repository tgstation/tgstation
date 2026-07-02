/datum/ntcode/node/block
	var/datum/ntcode/node/head

	var/list/datum/ntcode/variable/variables

/datum/ntcode/node/block/New(datum/ntcode/node/head)
	. = ..()
	src.head = head
	variables = alist()

/datum/ntcode/node/block/proc/set_variable(datum/ntcode/variable/variable)
	variables[variable.name] = variable

/datum/ntcode/node/block/analyze(datum/ntcode/analyzer/analyzer)
	var/datum/ntcode/scope/new_scope = new()
	for(var/variable_name in variables)
		if(analyzer.current_scope.get_variable(variable_name))
			analyzer.error(new /datum/ntcode/error/semantic/known/variable(src, variable_name))
			continue
		new_scope.set_variable(variables[variable_name])

	new_scope.parent = analyzer.current_scope
	analyzer.current_scope = new_scope
	
	var/datum/ntcode/node/current = head

	var/result = null

	while(current)
		current.analyze(analyzer)
		current = current.next

	analyzer.current_scope = analyzer.current_scope.parent
	variables.Cut()
	return result

/datum/ntcode/node/block/evaluate(datum/ntcode/interpreter/interpreter)
	var/datum/ntcode/scope/new_scope = new()
	for(var/variable in variables)
		new_scope.set_variable(variables[variable])

	new_scope.parent = interpreter.current_scope
	interpreter.current_scope = new_scope
	
	var/datum/ntcode/node/current = head

	var/result = null

	while(current)
		var/datum/ntcode/exception/exception = current.evaluate(interpreter)
		if(exception)
			result = exception
			break
		current = current.next

	// TODO: Delete free scope from memory
	interpreter.current_scope = interpreter.current_scope.parent
	variables.Cut()
	
	return result

/datum/ntcode/node/block/parse(datum/ntcode/parser/parser)
	if(parser.current_token.value != "{")
		return new type(new /datum/ntcode/node/statement().parse(parser))


	var/block_count = 0
	var/datum/stack/block_stack = new()

	parser.consume("{")
	block_stack.push(null)

	while(parser.current_token)
		if(parser.match("}"))
			var/datum/ntcode/node/head = block_stack.pop()

			if(block_stack.any())
				var/datum/ntcode/node/parent_head = block_stack.peek()
				
				var/datum/ntcode/node/block/completed = new type(head)

				var/datum/ntcode/node/tail = parent_head
				while(tail.next)
					tail = tail.next
				tail.next = completed
				continue
			else
				return new type(head)

		if(parser.match("{"))
			block_count++
			if(block_count >= parser.max_blocks_count)
				parser.error(new /datum/ntcode/error/parser/max_depth/blocks(parser.current_token))
				parser.recover(list("}"))
				return
			block_stack.push(null)
			continue
			
		var/result = new /datum/ntcode/node/statement().parse(parser)
		if(result)
			var/datum/ntcode/node/current = block_stack.pop()
			if(!current)
				block_stack.push(result)
			else
				var/datum/ntcode/node/tail = current
				while(tail.next)
					tail = tail.next
				tail.next = result
				block_stack.push(current)
		else
			parser.error(new /datum/ntcode/error/parser/unexpected/construct/statement(parser.current_token))
			break

	parser.error(new /datum/ntcode/error/parser/unexpected/construct/block(parser.current_token))

/datum/ntcode/node/block/to_string(indent)
	. = ..()
	var/result = "\n[indent]{\n"
	
	var/datum/ntcode/node/current = head
	while(current)
		result += "[current.to_string("[indent]	")]\n"
		current = current.next
	
	result += "[indent]}\n"
	return result