/datum/ntcode/node/expression/oper/unary
	associativity = NTCODE_RIGHT_ASSOCIATIVITY
	precedence = NTCODE_PREC_UNARY

	var/datum/ntcode/node/expression/expression

/datum/ntcode/node/expression/oper/unary/New(datum/ntcode/node/expression/expression)
	. = ..()
	src.expression = expression

/datum/ntcode/node/expression/oper/unary/expect(datum/ntcode/token/token, expect)
	. = ..()
	return . || expect == NTCODE_EXPRESSION_OPERAND

/datum/ntcode/node/expression/oper/unary/analyze(datum/ntcode/analyzer/analyzer)
	expression.analyze(analyzer)

/datum/ntcode/node/expression/oper/unary/evaluate(datum/ntcode/interpreter/interpreter)
	var/value = expression.evaluate(interpreter)
	if(istype(value, /datum/ntcode/exception/error))
		return value

/datum/ntcode/node/expression/oper/unary/proc/evaluate_operator(value)		

/datum/ntcode/node/expression/oper/unary/build(datum/ntcode/token/token, datum/stack/tree, alist/metadata)
	return new type(tree.pop())

/datum/ntcode/node/expression/oper/unary/to_string(indent)
	return "[indent]([symbol][expression.to_string("")])"

/datum/ntcode/node/expression/oper/unary/not
	symbol = "!"

/datum/ntcode/node/expression/oper/unary/not/evaluate_operator(value)
	if(value == 0)
		return 1
	return !value

/datum/ntcode/node/expression/oper/unary/minus
	symbol = "-"
	
/datum/ntcode/node/expression/oper/unary/minus/matches(datum/ntcode/token/token)
	return token.value == symbol  && (token.parent == null || token.parent == "," || token.parent == "(" || is_ntcode_operator(token.parent))

/datum/ntcode/node/expression/oper/unary/minus/evaluate_operator(value)
	return -value
