/datum/ntcode/node/statement/if
	var/datum/ntcode/node/expression/condition
	var/datum/ntcode/node/block/block
	var/datum/ntcode/node/block/else_block

/datum/ntcode/node/statement/if/New(datum/ntcode/node/expression/condition, datum/ntcode/node/block/block, datum/ntcode/node/block/else_block)
	. = ..()
	src.condition = condition
	src.block = block
	src.else_block = else_block

/datum/ntcode/node/statement/if/analyze(datum/ntcode/analyzer/analyzer)
	condition.analyze(analyzer)
	block.analyze(analyzer)
	if(else_block)
		else_block.analyze(analyzer)

/datum/ntcode/node/statement/if/evaluate(datum/ntcode/interpreter/interpreter)
	if(condition.evaluate(interpreter))
		return block.evaluate(interpreter)
	else if(else_block)
		return else_block.evaluate(interpreter)
	
/datum/ntcode/node/statement/if/to_string(indent)
	var/result =  "[indent]if([condition.to_string("")]) [block.to_string(indent)]"
	if(else_block)
		result += "[indent]else [else_block.to_string(indent)]"
	return result
	
/datum/ntcode/node/statement/if/parse(datum/ntcode/parser/parser)
	if(!parser.match("if"))
		return

	parser.skip("(")
	
	var/condition = new /datum/ntcode/node/expression().parse(parser)
	if(!condition)
		parser.error(new /datum/ntcode/error/parser/unexpected/construct(parser.current_token, "condition"))
		return

	parser.skip(")")
	var/block = new /datum/ntcode/node/block().parse(parser)
	if(!block)
		parser.error(new /datum/ntcode/error/parser/unexpected/construct/block(parser.current_token))
		return

	var/datum/ntcode/node/block/else_block = null
	if(parser.match("else"))
		else_block = new /datum/ntcode/node/block().parse(parser)
		if(!else_block)
			parser.error(new /datum/ntcode/error/parser/unexpected/construct/block(parser.current_token))
			return
	
	return new type(condition, block, else_block)

/datum/ntcode/node/statement/while
	var/datum/ntcode/node/expression/condition
	var/datum/ntcode/node/block/block

/datum/ntcode/node/statement/while/New(datum/ntcode/node/expression/condition, datum/ntcode/node/block/block)
	. = ..()
	src.condition = condition
	src.block = block

/datum/ntcode/node/statement/while/analyze(datum/ntcode/analyzer/analyzer)
	condition.analyze(analyzer)
	block.analyze(analyzer)

/datum/ntcode/node/statement/while/evaluate(datum/ntcode/interpreter/interpreter)
	var/count = 0
	while(condition.evaluate(interpreter))
		if(count >= interpreter.max_iterations_count)
			return new /datum/ntcode/exception/error/maximum_loops()
		count++
		
		var/result = block.evaluate(interpreter)
		if(!result)
			continue

		if(istype(result, /datum/ntcode/exception/loop_continue))
			continue
		if(istype(result, /datum/ntcode/exception/loop_break))
			break
		return result

/datum/ntcode/node/statement/while/to_string(indent)
	return  "[indent]while([condition.to_string("")]) [block.to_string(indent)]"
	
/datum/ntcode/node/statement/while/parse(datum/ntcode/parser/parser)
	if(!parser.match("while"))
		return

	parser.skip("(")
	
	var/condition = new /datum/ntcode/node/expression().parse(parser)
	if(!condition)
		parser.error(new /datum/ntcode/error/parser/unexpected/construct(parser.current_token, "condition"))
		return

	parser.skip(")")
	var/block = new /datum/ntcode/node/block().parse(parser)
	if(!block)
		parser.error(new /datum/ntcode/error/parser/unexpected/construct/block(parser.current_token))
		return
   
	return new type(condition, block)
