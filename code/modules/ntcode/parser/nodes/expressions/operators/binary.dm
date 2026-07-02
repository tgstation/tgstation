/datum/ntcode/node/expression/oper/binary
	var/datum/ntcode/node/left
	var/datum/ntcode/node/right

/datum/ntcode/node/expression/oper/binary/New(datum/ntcode/node/left, datum/ntcode/node/right)
	. = ..()
	src.left = left
	src.right = right

/datum/ntcode/node/expression/oper/binary/analyze(datum/ntcode/analyzer/analyzer)
	left.analyze(analyzer)
	right.analyze(analyzer)
	
/datum/ntcode/node/expression/oper/binary/build(datum/ntcode/token/token, datum/stack/tree, alist/metadata)
	var/right = tree.pop()
	var/left = tree.pop()
	return new type(left, right)

/datum/ntcode/node/expression/oper/binary/evaluate(datum/ntcode/interpreter/interpreter)
	var/left_v = left.evaluate(interpreter)
	var/right_v = right.evaluate(interpreter)
	if(istype(left_v, /datum/ntcode/exception))
		return left_v
	if(istype(right_v, /datum/ntcode/exception))
		return right_v
	return evaluate_operator(left_v, right_v)

/datum/ntcode/node/expression/oper/binary/proc/evaluate_operator(left, right)

/datum/ntcode/node/expression/oper/binary/to_string(indent)
	return "[indent]([left.to_string("")] [symbol] [right.to_string("")])"

/datum/ntcode/node/expression/oper/binary/add
	symbol = "+"
	precedence = NTCODE_PREC_ADD

/datum/ntcode/node/expression/oper/binary/add/evaluate_operator(left, right)
	if(isnum(left) && isnum(right))
		return left + right
	return "[left][right]"

/datum/ntcode/node/expression/oper/binary/subtract
	symbol = "-"
	precedence = NTCODE_PREC_ADD

/datum/ntcode/node/expression/oper/binary/subtract/evaluate_operator(left, right)
	if(isnum(left) && isnum(right))
		return left - right
	
/datum/ntcode/node/expression/oper/binary/multiply
	symbol = "*"
	precedence = NTCODE_PREC_MULTIPLY

/datum/ntcode/node/expression/oper/binary/multiply/evaluate_operator(left, right)
	if(isnum(left) && isnum(right))
		return left * right

/datum/ntcode/node/expression/oper/binary/divide
	symbol = "/"
	precedence = NTCODE_PREC_MULTIPLY

/datum/ntcode/node/expression/oper/binary/divide/evaluate_operator(left, right)
	if(isnum(left) && isnum(right))
		if(right == 0)
			return new /datum/ntcode/exception/error/divide_by_zero()
		return left / right

/datum/ntcode/node/expression/oper/binary/mod
	symbol = "%"
	precedence = NTCODE_PREC_MULTIPLY

/datum/ntcode/node/expression/oper/binary/mod/evaluate_operator(left, right)
	if(isnum(left) && isnum(right))
		return left % right

/datum/ntcode/node/expression/oper/binary/less
	symbol = "<"
	precedence = NTCODE_PREC_RELATIONAL

/datum/ntcode/node/expression/oper/binary/less/evaluate_operator(left, right)
	return left < right

/datum/ntcode/node/expression/oper/binary/more
	symbol = ">"
	precedence = NTCODE_PREC_RELATIONAL

/datum/ntcode/node/expression/oper/binary/more/evaluate_operator(left, right)
	return left > right

/datum/ntcode/node/expression/oper/binary/less_or_equal
	symbol = "<="
	precedence = NTCODE_PREC_RELATIONAL

/datum/ntcode/node/expression/oper/binary/less_or_equal/evaluate_operator(left, right)
	return left <= right

/datum/ntcode/node/expression/oper/binary/more_or_equal
	symbol = ">="
	precedence = NTCODE_PREC_RELATIONAL

/datum/ntcode/node/expression/oper/binary/more_or_equal/evaluate_operator(left, right)
	return left >= right

/datum/ntcode/node/expression/oper/binary/equal
	symbol = "=="
	precedence = NTCODE_PREC_EQUAL

/datum/ntcode/node/expression/oper/binary/equal/evaluate_operator(left, right)
	return left == right

/datum/ntcode/node/expression/oper/binary/not_equal
	symbol = "!="
	precedence = NTCODE_PREC_EQUAL

/datum/ntcode/node/expression/oper/binary/not_equal/evaluate_operator(left, right)
	return left != right

//TODO: the correct processing without calculating unnecessary parts
/datum/ntcode/node/expression/oper/binary/or
	symbol = "||"
	precedence = NTCODE_PREC_LOGICAL_OR

/datum/ntcode/node/expression/oper/binary/or/evaluate_operator(left, right)
	return left || right

/datum/ntcode/node/expression/oper/binary/and
	symbol = "&&"
	precedence = NTCODE_PREC_LOGICAL_AND

/datum/ntcode/node/expression/oper/binary/and/evaluate_operator(left, right)
	return left && right

/datum/ntcode/node/expression/oper/binary/xor
	symbol = "^"
	precedence = NTCODE_PREC_EXCLUSIVE_OR

/datum/ntcode/node/expression/oper/binary/xor/evaluate_operator(left, right)
	return left ^ right
	
/datum/ntcode/node/expression/oper/binary/left_shift
	symbol = "<<"
	precedence = NTCODE_PREC_SHIFT

/datum/ntcode/node/expression/oper/binary/left_shift/evaluate_operator(left, right)
	return left << right

/datum/ntcode/node/expression/oper/binary/right_shift
	symbol = ">>"
	precedence = NTCODE_PREC_SHIFT

/datum/ntcode/node/expression/oper/binary/right_shift/evaluate_operator(left, right)
	return left >> right
/*
/datum/ntcode/node/expression/oper/binary/array
	symbol = "\["
	precedence = NTCODE_PREC_ARRAY

/datum/ntcode/node/expression/oper/binary/array/to_string(indent)
	return "[indent][left.to_string("")]\[[right.to_string("")]]"	

/datum/ntcode/node/expression/oper/binary/array/evaluate_operator(left, right)
	return*/