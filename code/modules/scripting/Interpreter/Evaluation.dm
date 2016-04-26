/proc/isobject(x)
	return (istype(x, /datum) || istype(x, /list) || istype(x, /savefile) || istype(x, /client) || (x == world))

/datum/n_Interpreter/proc/Eval(datum/node/expression/exp)
	if(istype(exp, /datum/node/expression/FunctionCall))
		return RunFunction(exp)

	else if(istype(exp, /datum/node/expression/operator))
		return EvalOperator(exp)

	else if(istype(exp, /datum/node/expression/value/literal))
		var/datum/node/expression/value/literal/lit = exp
		return lit.value

	else if(istype(exp, /datum/node/expression/value/reference))
		var/datum/node/expression/value/reference/ref = exp
		return ref.value

	else if(istype(exp, /datum/node/expression/value/variable))
		var/datum/node/expression/value/variable/v = exp
		if(!v.object)
			return Eval(GetVariable(v.id.id_name))
		else
			var/datum/D
			if(istype(v.object, /datum/node/identifier))
				D = GetVariable(v.object:id_name)
			else
				D = v.object

			D = Eval(D)
			if(!isobject(D))
				return null

			if(!D.vars.Find(v.id.id_name))
				RaiseError(new/datum/runtimeError/UndefinedVariable("[v.object.ToString()].[v.id.id_name]"))
				return null

			return Eval(D.vars[v.id.id_name])

	else if(istype(exp, /datum/node/expression))
		RaiseError(new/datum/runtimeError/UnknownInstruction())

	else
		return exp

/datum/n_Interpreter/proc/EvalOperator(datum/node/expression/operator/exp)
	if(istype(exp, /datum/node/expression/operator/binary))
		var/datum/node/expression/operator/binary/bin = exp
		try // This way we can forgo sanity in the actual evaluation (other than divide by 0).
			switch(bin.type)
				if(/datum/node/expression/operator/binary/Equal)
					return Equal(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/NotEqual)
					return NotEqual(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/Greater)
					return Greater(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/Less)
					return Less(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/GreaterOrEqual)
					return GreaterOrEqual(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/LessOrEqual)
					return LessOrEqual(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/LogicalAnd)
					return LogicalAnd(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/LogicalOr)
					return LogicalOr(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/LogicalXor)
					return LogicalXor(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/BitwiseAnd)
					return BitwiseAnd(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/BitwiseOr)
					return BitwiseOr(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/BitwiseXor)
					return BitwiseXor(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/Add)
					return Add(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/Subtract)
					return Subtract(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/Multiply)
					return Multiply(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/Divide)
					return Divide(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/Power)
					return Power(Eval(bin.exp), Eval(bin.exp2))

				if(/datum/node/expression/operator/binary/Modulo)
					return Modulo(Eval(bin.exp), Eval(bin.exp2))

				else
					RaiseError(new/datum/runtimeError/UnknownInstruction())

		catch
			RaiseError(new/datum/runtimeError/TypeMismatch(bin.token, Eval(bin.exp), Eval(bin.exp2)))

	else
		try
			switch(exp.type)
				if(/datum/node/expression/operator/unary/Minus)
					return Minus(Eval(exp.exp))

				if(/datum/node/expression/operator/unary/LogicalNot)
					return LogicalNot(Eval(exp.exp))

				if(/datum/node/expression/operator/unary/BitwiseNot)
					return BitwiseNot(Eval(exp.exp))

				if(/datum/node/expression/operator/unary/group)
					return Eval(exp.exp)

				else
					RaiseError(new/datum/runtimeError/UnknownInstruction())
		catch
			RaiseError(new/datum/runtimeError/TypeMismatch/unary(exp.token, Eval(exp.exp)))

//Binary//
//Comparison operators
/datum/n_Interpreter/proc/Equal(a, b)
	return a == b

/datum/n_Interpreter/proc/NotEqual(a, b)
	return a != b //LogicalNot(Equal(a, b))

/datum/n_Interpreter/proc/Greater(a, b)
	return a > b

/datum/n_Interpreter/proc/Less(a, b)
	return a < b

/datum/n_Interpreter/proc/GreaterOrEqual(a, b)
	return a >= b

/datum/n_Interpreter/proc/LessOrEqual(a, b)
	return a <= b

//Logical Operators
/datum/n_Interpreter/proc/LogicalAnd(a, b)
	return a && b

/datum/n_Interpreter/proc/LogicalOr(a, b)
	return a || b

/datum/n_Interpreter/proc/LogicalXor(a, b)
	return (a || b) && !(a && b)

//Bitwise Operators
/datum/n_Interpreter/proc/BitwiseAnd(a, b)
	return a & b

/datum/n_Interpreter/proc/BitwiseOr(a, b)
	return a | b

/datum/n_Interpreter/proc/BitwiseXor(a, b)
	return a ^ b

//Arithmetic Operators
/datum/n_Interpreter/proc/Add(a, b)
	return a + b

/datum/n_Interpreter/proc/Subtract(a, b)
	return a - b

/datum/n_Interpreter/proc/Divide(a, b)
	if(b == 0)
		RaiseError(new/datum/runtimeError/DivisionByZero())
		return null

	return a / b

/datum/n_Interpreter/proc/Multiply(a, b)
	return a * b

/datum/n_Interpreter/proc/Modulo(a, b)

	return a % b

/datum/n_Interpreter/proc/Power(a, b)
	return a ** b

//Unary//
/datum/n_Interpreter/proc/Minus(a)
	return -a

/datum/n_Interpreter/proc/LogicalNot(a)
	return !a

/datum/n_Interpreter/proc/BitwiseNot(a)
	return ~a
