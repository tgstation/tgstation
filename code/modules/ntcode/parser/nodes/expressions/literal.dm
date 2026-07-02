/datum/ntcode/node/expression/literal
	var/list/literal_types = list(
		/datum/ntcode/token/number,
		/datum/ntcode/token/string
	)
	var/value

/datum/ntcode/node/expression/literal/New(value)
	. = ..()
	src.value = value

/datum/ntcode/node/expression/literal/evaluate(datum/ntcode/interpreter/interpreter)
	return value
	
/datum/ntcode/node/expression/literal/to_string(indent)
	if(istext(value))
		return "'[value]'"
	return "[value]"

/datum/ntcode/node/expression/literal/expect(datum/ntcode/token/token/token, expect)
	return expect == NTCODE_EXPRESSION_OPERAND

/datum/ntcode/node/expression/literal/matches(datum/ntcode/token/token, expect)
	return token.type in literal_types

/datum/ntcode/node/expression/literal/build(datum/ntcode/token/token, datum/stack/tree, alist/metadata)
	return new /datum/ntcode/node/expression/literal(token.value)

/datum/ntcode/node/expression/literal/shunt(datum/ntcode/token/token, datum/stack/stack, datum/queue/output, alist/metadata)
	output.enqueue(token)
	metadata["expect"] = NTCODE_EXPRESSION_OPERATOR
