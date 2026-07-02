/datum/ntcode/node/expression/variable
	var/name

/datum/ntcode/node/expression/variable/New(name)
	. = ..()
	src.name = name
	
/datum/ntcode/node/expression/variable/analyze(datum/ntcode/analyzer/analyzer)
	var/datum/ntcode/variable/variable = analyzer.current_scope.get_variable(name)
	if(!variable)
		analyzer.error(new /datum/ntcode/error/semantic/unknown/variable(src, name))
		return null

/datum/ntcode/node/expression/variable/evaluate(datum/ntcode/interpreter/interpreter)
	var/datum/ntcode/variable/variable = interpreter.current_scope.get_variable(name)
	return variable.value

/datum/ntcode/node/expression/variable/to_string(indent)
	return "[name]"

/datum/ntcode/node/expression/variable/expect(datum/ntcode/token/token/token, expect)
	return expect == NTCODE_EXPRESSION_OPERAND

/datum/ntcode/node/expression/variable/matches(datum/ntcode/token/token)
	return is_ntcode_identifier(token) && token.next && token.next.value != "("

/datum/ntcode/node/expression/variable/build(datum/ntcode/token/token, datum/stack/tree, alist/metadata)
	return new /datum/ntcode/node/expression/variable(token.value)

/datum/ntcode/node/expression/variable/shunt(datum/ntcode/token/token, datum/stack/stack, datum/queue/output, alist/metadata)
	output.enqueue(token)
	metadata["expect"] = NTCODE_EXPRESSION_OPERATOR