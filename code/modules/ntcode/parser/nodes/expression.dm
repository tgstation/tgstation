
/datum/ntcode/node/expression
	var/list/datum/ntcode/node/expression/expressions = list()

	var/expect = list()

/datum/ntcode/node/expression/New()
	. = ..()
	if(type != /datum/ntcode/node/expression)
		return
	for(var/expression in subtypesof(/datum/ntcode/node/expression/))
		expressions += new expression
	sortTim(expressions, GLOBAL_PROC_REF(cmp_expression_precedence))

/proc/cmp_expression_precedence(datum/ntcode/node/expression/first, datum/ntcode/node/expression/second)
	return first.precedence - second.precedence

/datum/ntcode/node/expression/parse(datum/ntcode/parser/parser)
	var/datum/stack/stack = new()
	var/datum/queue/output = new()

	// It should be only function call expression's variable
	var/depth = 1

	var/alist/metadata = alist()
	metadata["precs"] = alist()
	metadata["args_count"] = alist()
	metadata["functions"] = new /datum/stack()
	metadata["expect"] = NTCODE_EXPRESSION_OPERAND

	while(parser.current_token)
		if(parser.current_token.value == "(")
			depth++
		if(parser.current_token.value == ")")
			depth--
		if(depth == 0)
			break

		if(depth >= parser.max_expressions_count)
			parser.error(new /datum/ntcode/error/parser/max_depth/expression(parser.current_token))
			break

		var/is_valid_token = FALSE
		for(var/datum/ntcode/node/expression/expression in expressions)
			if(expression.matches(parser.current_token))
				is_valid_token = TRUE
				if(expression.expect(parser.current_token, metadata["expect"]))
					expression.shunt(parser.current_token, stack, output, metadata)
					break


		if(!is_valid_token)
			break

		parser.advance()

	if(metadata["expect"] != NTCODE_EXPRESSION_OPERATOR)
		parser.error(new /datum/ntcode/error/parser/unexpected/construct(parser.current_token, metadata["expect"]))
		return

	while(stack.any())
		var/datum/ntcode/token/token = stack.pop()
		if(token.value == "(")
			parser.error(new /datum/ntcode/error/parser/unexpected/construct(token, ")"))
		output.enqueue(token)

	var/datum/stack/tree = new()

	while(output.any())
		var/datum/ntcode/token/token = output.dequeue()
		for(var/datum/ntcode/node/expression/expression in expressions)
			if(!expression.matches(token))
				continue
			var/datum/node = expression.build(token, tree, metadata)
			if(node)
				tree.push(node)
				break

	var/datum/result = tree.pop()
	return result

/datum/ntcode/node/expression/proc/expect(datum/ntcode/token/token, expect)
	return FALSE

/datum/ntcode/node/expression/proc/matches(datum/ntcode/token/token)
	return FALSE

/datum/ntcode/node/expression/proc/build(datum/ntcode/token/token, datum/stack/tree, alist/metadata)
	return null

/datum/ntcode/node/expression/proc/shunt(datum/ntcode/token/token, datum/stack/stack, datum/queue/output, alist/metadata)
	return FALSE
