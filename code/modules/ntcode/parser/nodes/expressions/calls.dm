/datum/ntcode/node/expression/function_call
	var/list/puncts = list(
		NTCODE_OPEN_PAREN,
		NTCODE_CLOSE_PAREN,
		NTCODE_FUNCTION_DELIMETER
	)

	var/function_name

	var/list/datum/ntcode/node/expression/arguments

/datum/ntcode/node/expression/function_call/New(name, list/datum/ntcode/node/expression/arguments)
	function_name = name
	src.arguments = arguments

/datum/ntcode/node/expression/function_call/analyze(datum/ntcode/analyzer/analyzer)
	var/datum/ntcode/function/function = analyzer.current_scope.get_function(function_name)
	if(!function)
		analyzer.error(new /datum/ntcode/error/semantic/unknown/function(src, function_name))
		return

	if(arguments.len != function.arguments.len)
		analyzer.error(new /datum/ntcode/error/semantic/invalid_arguments_count(src, function, arguments.len))

	for(var/datum/ntcode/node/argument in arguments)
		argument.analyze(analyzer)

	if(function_name in analyzer.call_stack)
		analyzer.error(new /datum/ntcode/error/semantic/recursion(src, function_name))
		return
	analyzer.call_stack += function_name
	function.analyze(analyzer)

/datum/ntcode/node/expression/function_call/evaluate(datum/ntcode/interpreter/interpreter)
	var/datum/ntcode/function/function = interpreter.current_scope.get_function(function_name)
	var/list/arg = list()
	for(var/datum/ntcode/node/argument in arguments)
		var/value = argument.evaluate(interpreter)
		if(istype(value, /datum/ntcode/exception))
			return value
		arg += value
	return function.evaluate(interpreter, arg)

/datum/ntcode/node/expression/function_call/expect(datum/ntcode/token/token, expect)
	return (is_function_delimiter(token) && expect == NTCODE_EXPRESSION_OPERATOR) ||\
	(is_function(token) && expect == NTCODE_EXPRESSION_OPERAND)||\
	(is_open_paren(token) && (expect == NTCODE_EXPRESSION_OPAREN || expect == NTCODE_EXPRESSION_OPERAND))||\
	(is_close_paren(token) && (expect == NTCODE_EXPRESSION_OPERATOR || is_open_paren(token.parent)))

/datum/ntcode/node/expression/function_call/matches(datum/ntcode/token/token)
	return is_function_delimiter(token) || is_function(token) || is_open_paren(token) || is_close_paren(token)

/datum/ntcode/node/expression/function_call/build(datum/ntcode/token/token, datum/stack/tree, alist/metadata)
	var/args_count = metadata["args_count"][token]
	var/list/datum/ntcode/node/arguments = list()
	for(var/i = 0; i < args_count; i++)
		var/datum/arg = tree.pop()
		arguments += arg
	return new /datum/ntcode/node/expression/function_call(token.value, reverse_range(arguments))

/datum/ntcode/node/expression/function_call/shunt(datum/ntcode/token/token, datum/stack/stack, datum/queue/output, alist/metadata)
	if(is_ntcode_punctuator(token))
		switch(token.value)
			if(NTCODE_FUNCTION_DELIMETER)
				var/datum/ntcode/token/current_function = metadata["functions"].peek()
				if(current_function && metadata["args_count"][current_function])
					metadata["args_count"][current_function]++
				while(stack.any() && stack.peek().value != NTCODE_OPEN_PAREN)
					output.enqueue(stack.pop())
				metadata["expect"] = NTCODE_EXPRESSION_OPERAND
			if(NTCODE_OPEN_PAREN)
				stack.push(token)
				metadata["expect"] = NTCODE_EXPRESSION_OPERAND
			if(NTCODE_CLOSE_PAREN)
				while (stack.peek().value != NTCODE_OPEN_PAREN)
					output.enqueue(stack.pop())
				stack.pop()
				if (stack.any() && is_function(stack.peek()))
					output.enqueue(stack.pop())
				metadata["functions"].pop()
				metadata["expect"] = NTCODE_EXPRESSION_OPERATOR
	else
		stack.push(token)
		metadata["args_count"][token] = 1
		if(token.next && token.next.next && is_close_paren(token.next.next))
			metadata["args_count"][token] = 0
		metadata["functions"].push(token)
		metadata["expect"] = NTCODE_EXPRESSION_OPAREN

/datum/ntcode/node/expression/function_call/to_string(indent)
	var/result = "[indent][function_name]("
	for(var/datum/ntcode/node/expression/argument in arguments)
		result +=  "[argument.to_string("")], "
	if(arguments.len > 0)
		result = copytext(result, 1, length(result) -1)
	return "[result])"

/datum/ntcode/node/expression/function_call/proc/is_open_paren(datum/ntcode/token/token, expect)
	return is_ntcode_punctuator(token) && token.value == NTCODE_OPEN_PAREN

/datum/ntcode/node/expression/function_call/proc/is_close_paren(datum/ntcode/token/token, expect)
	return is_ntcode_punctuator(token) && token.value == NTCODE_CLOSE_PAREN

/datum/ntcode/node/expression/function_call/proc/is_function_delimiter(datum/ntcode/token/token, expect)
	return is_ntcode_punctuator(token) && token.value == NTCODE_FUNCTION_DELIMETER

/datum/ntcode/node/expression/function_call/proc/is_function(datum/ntcode/token/token, expect)
	return is_ntcode_identifier(token) && token.next && token.next.value == NTCODE_OPEN_PAREN

#undef NTCODE_OPEN_PAREN
#undef NTCODE_CLOSE_PAREN
#undef NTCODE_FUNCTION_DELIMETER
