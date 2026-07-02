/datum/ntcode/node/statement/simple

/datum/ntcode/node/statement/simple/assign
	var/assign_symbol = "="
	var/variable_name

	var/datum/ntcode/node/expression/expression

/datum/ntcode/node/statement/simple/assign/New(variable_name, datum/ntcode/node/expression/expression)
	. = ..()
	src.variable_name = variable_name
	src.expression = expression

/datum/ntcode/node/statement/simple/assign/analyze(datum/ntcode/analyzer/analyzer)
	var/datum/ntcode/variable/variable = analyzer.current_scope.get_variable(variable_name)
	if(!variable)
		analyzer.error(new /datum/ntcode/error/semantic/unknown/variable(src, variable_name))

	if(istype(variable, /datum/ntcode/variable/const))
		analyzer.error(new /datum/ntcode/error/semantic/const_assign(src, variable_name))
		
	expression.analyze(analyzer)
	
/datum/ntcode/node/statement/simple/assign/evaluate(datum/ntcode/interpreter/interpreter)
	var/datum/ntcode/variable/variable = interpreter.current_scope.get_variable(variable_name)
	var/result = expression.evaluate(interpreter)
	if(istype(result, /datum/ntcode/exception))
		return result
	assign(variable, result)

/datum/ntcode/node/statement/simple/assign/parse(datum/ntcode/parser/parser)
	if(!istype(parser.current_token, /datum/ntcode/token/identifier))
		return
	if(!parser.current_token.next || parser.current_token.next.value != assign_symbol)
		return
	var/var_name = parser.consume(/datum/ntcode/token/identifier)
	parser.skip(assign_symbol)
	var/result = new type(var_name, new /datum/ntcode/node/expression().parse(parser))
	parser.skip(";")
	return result

/datum/ntcode/node/statement/simple/assign/proc/assign(datum/ntcode/variable/variable, value)
	variable.value = value

/datum/ntcode/node/statement/simple/assign/to_string(indent)
	return "[indent][variable_name] [assign_symbol] [expression.to_string("")];"

/datum/ntcode/node/statement/simple/assign/add
	assign_symbol = "+="

/datum/ntcode/node/statement/simple/assign/add/assign(datum/ntcode/variable/variable, value)
	variable.value += value

/datum/ntcode/node/statement/simple/assign/subtract
	assign_symbol = "-="

/datum/ntcode/node/statement/simple/assign/subtract/assign(datum/ntcode/variable/variable, value)
	variable.value -= value

/datum/ntcode/node/statement/simple/assign/multiply
	assign_symbol = "*="

/datum/ntcode/node/statement/simple/assign/multiply/assign(datum/ntcode/variable/variable, value)
	variable.value *= value

/datum/ntcode/node/statement/simple/assign/divide
	assign_symbol = "/="

/datum/ntcode/node/statement/simple/assign/divide/assign(datum/ntcode/variable/variable, value)
	variable.value /= value

/datum/ntcode/node/statement/simple/assign/mod
	assign_symbol = "%="

/datum/ntcode/node/statement/simple/assign/mod/assign(datum/ntcode/variable/variable, value)
	variable.value %= value

/datum/ntcode/node/statement/simple/assign/and
	assign_symbol = "&="

/datum/ntcode/node/statement/simple/assign/and/assign(datum/ntcode/variable/variable, value)
	variable.value &= value

/datum/ntcode/node/statement/simple/assign/or
	assign_symbol = "|="

/datum/ntcode/node/statement/simple/assign/or/assign(datum/ntcode/variable/variable, value)
	variable.value |= value

/datum/ntcode/node/statement/simple/assign/xor
	assign_symbol = "^="

/datum/ntcode/node/statement/simple/assign/xor/assign(datum/ntcode/variable/variable, value)
	variable.value ^= value

/datum/ntcode/node/statement/simple/assign/right_shift
	assign_symbol = ">>="

/datum/ntcode/node/statement/simple/assign/right_shift/assign(datum/ntcode/variable/variable, value)
	variable.value >>= value

/datum/ntcode/node/statement/simple/assign/left_shift
	assign_symbol = "<<="

/datum/ntcode/node/statement/simple/assign/left_shift/assign(datum/ntcode/variable/variable, value)
	variable.value <<= value

/datum/ntcode/node/statement/simple/function_call
	var/datum/ntcode/node/expression/function

/datum/ntcode/node/statement/simple/function_call/New(datum/ntcode/node/expression/function)
	. = ..()
	src.function = function

/datum/ntcode/node/statement/simple/function_call/analyze(datum/ntcode/analyzer/analyzer)
	function.analyze(analyzer)

/datum/ntcode/node/statement/simple/function_call/evaluate(datum/ntcode/interpreter/interpreter)
	return function.evaluate(interpreter)

/datum/ntcode/node/statement/simple/function_call/parse(datum/ntcode/parser/parser)
	if(!parser.equals(/datum/ntcode/token/identifier))
		return
	
	if(!parser.current_token.next || parser.current_token.next.value != "(")
		return

	var/function = new /datum/ntcode/node/expression().parse(parser)
	if(!function)
		parser.error(new /datum/ntcode/error/parser/unexpected/construct/expression(parser.current_token))
		return
	parser.skip(";")

	return new type(function)

/datum/ntcode/node/statement/simple/function_call/to_string(indent)
	return "[indent][function.to_string("")];"

/datum/ntcode/node/statement/simple/ret
	var/datum/ntcode/node/expression/expression

/datum/ntcode/node/statement/simple/ret/New(datum/ntcode/node/expression/expression)
	. = ..()
	src.expression = expression

/datum/ntcode/node/statement/simple/ret/analyze(datum/ntcode/analyzer/analyzer)
	expression.analyze(analyzer)

/datum/ntcode/node/statement/simple/ret/evaluate(datum/ntcode/interpreter/interpreter)
	var/value = expression.evaluate(interpreter)
	if(istype(value, /datum/ntcode/exception))
		return value

	return new /datum/ntcode/exception/ret(value)
	
/datum/ntcode/node/statement/simple/ret/parse(datum/ntcode/parser/parser)
	if(!parser.match("return"))
		return

	var/expression = new /datum/ntcode/node/expression().parse(parser)
	if(!expression)
		parser.error(new /datum/ntcode/error/parser/unexpected/construct/expression(parser.current_token))
		return
	parser.skip(";")
	return new type(expression)

/datum/ntcode/node/statement/simple/ret/to_string(indent)
	return "[indent]return [expression.to_string("")];"	

/datum/ntcode/node/statement/simple/loop_continue

/datum/ntcode/node/statement/simple/loop_continue/evaluate(datum/ntcode/interpreter/interpreter)
	return new /datum/ntcode/exception/loop_continue()
	
/datum/ntcode/node/statement/simple/loop_continue/parse(datum/ntcode/parser/parser)
	if(!parser.match("continue"))
		return
	parser.skip(";")
	return new type()

/datum/ntcode/node/statement/simple/loop_continue/to_string(indent)
	return "[indent]continue;"  

/datum/ntcode/node/statement/simple/loop_break

/datum/ntcode/node/statement/simple/loop_break/evaluate(datum/ntcode/interpreter/interpreter)
	return new /datum/ntcode/exception/loop_break()
	
/datum/ntcode/node/statement/simple/loop_break/parse(datum/ntcode/parser/parser)
	if(!parser.match("break"))
		return
	parser.skip(";")
	return new type()

/datum/ntcode/node/statement/simple/loop_break/to_string(indent)
	return "[indent]break;"  

/datum/ntcode/node/statement/simple/variable_declaration
	var/keyword = "var"

	var/var_name

	var/datum/ntcode/node/expression/initialization

/datum/ntcode/node/statement/simple/variable_declaration/New(var_name, datum/ntcode/node/expression/initialization)
	. = ..()
	src.var_name = var_name
	src.initialization = initialization

/datum/ntcode/node/statement/simple/variable_declaration/analyze(datum/ntcode/analyzer/analyzer)
	if(initialization)
		initialization.analyze(analyzer)
	analyzer.current_scope.set_variable(new /datum/ntcode/variable(var_name, null))

/datum/ntcode/node/statement/simple/variable_declaration/evaluate(datum/ntcode/interpreter/interpreter)
	var/value = null
	if(initialization)
		value = initialization.evaluate(interpreter)
	if(istype(value, /datum/ntcode/exception/error))
		return value
	interpreter.current_scope.set_variable(new /datum/ntcode/variable(var_name, value))

/datum/ntcode/node/statement/simple/variable_declaration/parse(datum/ntcode/parser/parser)
	if(!parser.match(keyword))
		return
	var/var_name = parser.consume(/datum/ntcode/token/identifier)
	var/datum/ntcode/node/expression/init = null
	if(parser.match("="))
		init = new /datum/ntcode/node/expression().parse(parser)
		if(!init)
			parser.error(new /datum/ntcode/error/parser/unexpected/construct/expression(parser.current_token))
			return
	parser.skip(";")
	return new type(var_name, init)

/datum/ntcode/node/statement/simple/variable_declaration/to_string(indent)
	. = ..()
	var/result = "[indent][keyword] [var_name]"
	if(initialization)
		result += " = [initialization.to_string("")]"
	return "[result];"

/datum/ntcode/node/statement/simple/variable_declaration/const
	keyword = "const"

/datum/ntcode/node/statement/simple/variable_declaration/const/analyze(datum/ntcode/analyzer/analyzer)
	if(initialization)
		initialization.analyze(analyzer)
	analyzer.current_scope.set_variable(new /datum/ntcode/variable/const(var_name, null))

/datum/ntcode/node/statement/simple/variable_declaration/const/evaluate(datum/ntcode/interpreter/interpreter)
	var/value = null
	if(initialization)
		value = initialization.evaluate(interpreter)
	if(istype(value, /datum/ntcode/exception))
		return value
	interpreter.current_scope.set_variable(new /datum/ntcode/variable/const(var_name, value))

/datum/ntcode/node/statement/simple/import
	var/module_name

/datum/ntcode/node/statement/simple/import/New(module_name)
	. = ..()
	src.module_name = module_name

/datum/ntcode/node/statement/simple/import/analyze(datum/ntcode/analyzer/analyzer)
	for(var/datum/ntcode/module/module in analyzer.modules)
		if(module.module_name != module_name)
			continue

		for(var/datum/ntcode/variable/variable in module.variables)
			if(analyzer.current_scope.get_variable(variable.name))
				analyzer.error(new /datum/ntcode/error/semantic/known/variable(src, variable.name))
				continue
			analyzer.current_scope.set_variable(variable)

		for(var/datum/ntcode/function/function in module.functions)
			if(analyzer.current_scope.get_function(function.name))
				analyzer.error(new /datum/ntcode/error/semantic/known/function(src, function.name))
				continue
			analyzer.current_scope.set_function(function)
		return

	analyzer.error(new /datum/ntcode/error/semantic/unknown/module(src, module_name))

/datum/ntcode/node/statement/simple/import/evaluate(datum/ntcode/interpreter/interpreter)
	for(var/datum/ntcode/module/module in interpreter.modules)
		if(module.module_name != module_name)
			continue

		for(var/datum/ntcode/variable/variable in module.variables)
			interpreter.current_scope.set_variable(variable)

		for(var/datum/ntcode/function/function in module.functions)
			interpreter.current_scope.set_function(function)
		return

/datum/ntcode/node/statement/simple/import/parse(datum/ntcode/parser/parser)
	if(!parser.match("import"))
		return
	var/module_name = parser.consume(/datum/ntcode/token/identifier)
	if(!module_name)
		return
	parser.skip(";")
	return new type(module_name)

/datum/ntcode/node/statement/simple/import/to_string(indent)
	return "import [module_name];"
	
