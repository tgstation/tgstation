/datum/ntcode/variable
	var/name
	var/value

/datum/ntcode/variable/New(name, value)
	. = ..()
	src.name = name
	src.value = value

/datum/ntcode/variable/const

/datum/ntcode/function
	var/name
	var/list/arguments

/datum/ntcode/function/New(name, list/arguments)
	. = ..()
	src.name = name
	src.arguments = arguments

/datum/ntcode/function/proc/analyze(datum/ntcode/analyzer/analyzer)

/datum/ntcode/function/proc/evaluate(datum/ntcode/interpreter/interpreter, list/arguments)

/datum/ntcode/function/node
	var/datum/ntcode/node/block/block

/datum/ntcode/function/node/New(name, list/arguments, datum/ntcode/node/block/block)
	. = ..()
	src.block = block

/datum/ntcode/function/node/analyze(datum/ntcode/analyzer/analyzer)
	var/datum/ntcode/scope/current_scope = analyzer.current_scope
	while(analyzer.current_scope.parent)
		analyzer.current_scope = analyzer.current_scope.parent
		
	for(var/i = 1; i <= arguments.len; i++)
		block.set_variable(new /datum/ntcode/variable(arguments[i], null))
	
	block.analyze(analyzer)
	analyzer.current_scope = current_scope

/datum/ntcode/function/node/evaluate(datum/ntcode/interpreter/interpreter, list/arg)
	var/datum/ntcode/scope/current_scope = interpreter.current_scope
	while(interpreter.current_scope.parent)
		interpreter.current_scope = interpreter.current_scope.parent
	
	for(var/i = 1; i <= arguments.len; i++)
		block.set_variable(new /datum/ntcode/variable(arguments[i], arg[i]))
	
	var/datum/ntcode/exception/exception = block.evaluate(interpreter)
	interpreter.current_scope = current_scope

	if(!exception)
		return

	if(istype(exception, /datum/ntcode/exception/ret))
		var/datum/ntcode/exception/ret/result = exception
		return result.result
	
	if(istype(exception, /datum/ntcode/exception/error))
		var/datum/ntcode/exception/error/error = exception
		error.stack += src
		return error

	return exception

/datum/ntcode/function/byond
	var/object
	var/proc_reference

/datum/ntcode/function/byond/New(name, arguments, object, proc_reference)
	. = ..()
	src.object = object
	src.proc_reference = proc_reference

/datum/ntcode/function/byond/evaluate(datum/ntcode/interpreter/interpreter, list/arguments)
	return call(object, proc_reference)(arglist(arguments))

/datum/ntcode/scope
	var/datum/ntcode/scope/parent

	var/list/datum/ntcode/variable/variables = alist()

	var/list/datum/ntcode/function/functions = alist()

/datum/ntcode/scope/proc/set_function(datum/ntcode/function/function)
	functions[function.name] = function

/datum/ntcode/scope/proc/get_function(name)
	var/datum/ntcode/scope/scope = src
	while(scope)
		for(var/function in scope.functions)
			if(function == name)
				return scope.functions[function]
		scope = scope.parent
	return null

/datum/ntcode/scope/proc/set_variable(datum/ntcode/variable/variable)
	variables[variable.name] = variable
 
/datum/ntcode/scope/proc/get_variable(name)
	var/datum/ntcode/scope/scope = src
	while(scope)
		for(var/variable in scope.variables)
			if(variable == name)
				return scope.variables[variable]
		scope = scope.parent
	return null

