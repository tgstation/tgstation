/datum/ntcode/node/expression/oper
	var/symbol

/datum/ntcode/node/expression/oper/proc/compare_operators(datum/ntcode/token/op1, datum/ntcode/token/op2, alist/metadata)
	var/precedence2 = metadata["precs"][op2]["precedence"]
	if(associativity == NTCODE_RIGHT_ASSOCIATIVITY)
		return precedence < precedence2
	else
		return precedence <= precedence2

/datum/ntcode/node/expression/oper/expect(datum/ntcode/token/token/token, expect)
	return expect == NTCODE_EXPRESSION_OPERATOR

/datum/ntcode/node/expression/oper/matches(datum/ntcode/token/token, expect)
	return is_ntcode_operator(token) && token.value == symbol

/datum/ntcode/node/expression/oper/shunt(datum/ntcode/token/token, datum/stack/stack, datum/queue/output, alist/metadata)
	while (stack.any() && is_ntcode_operator(stack.peek().type) && compare_operators(token, stack.peek(), metadata))
		output.enqueue(stack.pop())
	stack.push(token)
	metadata["precs"][token] = alist("precedence" = precedence, "associativity" = associativity)
	metadata["expect"] = NTCODE_EXPRESSION_OPERAND
