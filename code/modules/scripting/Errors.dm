/*
	File: Errors
*/
/*
	Class: scriptError
	An error scanning or parsing the source code.
*/
/datum/scriptError
/*
	Var: message
	A message describing the problem.
*/
	var/message

/datum/scriptError/New(msg = null)
	if(msg)message = msg

/datum/scriptError/BadToken
	message = "Unexpected token: "
	var/datum/token/token

/datum/scriptError/BadToken/New(datum/token/t)
	token = t
	if(t && t.line)
		message = "[t.line]: [message]"

	if(istype(t))
		message += "[t.value]"

	else
		message += "[t]"

/datum/scriptError/InvalidID
	parent_type = /datum/scriptError/BadToken
	message = "Invalid identifier name: "

/datum/scriptError/ReservedWord
	parent_type = /datum/scriptError/BadToken
	message = "Identifer using reserved word: "

/datum/scriptError/BadNumber
	parent_type = /datum/scriptError/BadToken
	message = "Bad number: "

/datum/scriptError/BadReturn
	var/datum/token/token
	message = "Unexpected return statement outside of a function."

/datum/scriptError/BadReturn/New(datum/token/t)
	src.token = t

/datum/scriptError/EndOfFile
	message = "Unexpected end of file."

/datum/scriptError/ExpectedToken
	message = "Expected: '"

/datum/scriptError/ExpectedToken/New(id, datum/token/T)
	if(T && T.line)
		message = "[T.line]: [message]"

	message += "[id]'. "

	if(T)
		message += "Found '[T.value]'."


/datum/scriptError/UnterminatedComment
	message = "Unterminated multi-line comment statement: expected */"

/datum/scriptError/DuplicateFunction/New(name, datum/token/t)
	message = "Function '[name]' defined twice."

/datum/scriptError/ParameterFunction
	message = "You cannot use a function inside a parameter."

/datum/scriptError/ParameterFunction/New(datum/token/t)
	var/line = "?"
	if(t)
		line = t.line
	message = "[line]: [message]"

/*
	Class: runtimeError
	An error thrown by the interpreter in running the script.
*/
/datum/runtimeError
	var/name
/*
	Var: message
	A basic description as to what went wrong.
*/
	var/message
	var/datum/stack/stack
/*
	Proc: ToString
	Returns a description of the error suitable for showing to the user.
*/
/datum/runtimeError/proc/ToString()
	. = "[name]: [message]"
	if(!stack.Top())
		return

	. += "\nStack:"
	while(stack.Top())
		var/datum/node/statement/FunctionCall/stmt = stack.Pop()
		. += "\n\t [stmt.func_name]()"

/datum/runtimeError/TypeMismatch
	name = "TypeMismatchError"

/datum/runtimeError/TypeMismatch/New(op, a, b)
	message = "Type mismatch: '[a]' [op] '[b]'"

/datum/runtimeError/TypeMismatch/unary/New(op, a)
	message = "Type mismatch: [op]'[a]'"
	
/datum/runtimeError/TypeMismatch/New(op, a, b)
	message = "Type mismatch: '[a]' [op] '[b]'"
	
/datum/runtimeError/UnexpectedReturn
	name = "UnexpectedReturnError"
	message = "Unexpected return statement."

/datum/runtimeError/UnknownInstruction
	name = "UnknownInstructionError"
	message = "Unknown instruction type. This may be due to incompatible compiler and interpreter versions or a lack of implementation."

/datum/runtimeError/UndefinedVariable
	name = "UndefinedVariableError"

/datum/runtimeError/UndefinedVariable/New(variable)
	message = "Variable '[variable]' has not been declared."

/datum/runtimeError/UndefinedFunction
	name = "UndefinedFunctionError"

/datum/runtimeError/UndefinedFunction/New(function)
	message = "Function '[function]()' has not been defined."

/datum/runtimeError/DuplicateVariableDeclaration
	name = "DuplicateVariableError"

/datum/runtimeError/DuplicateVariableDeclaration/New(variable)
	message="Variable '[variable]' was already declared."

/datum/runtimeError/IterationLimitReached
	name = "MaxIterationError"
	message = "A loop has reached its maximum number of iterations."

/datum/runtimeError/RecursionLimitReached
	name = "MaxRecursionError"
	message = "The maximum amount of recursion has been reached."

/datum/runtimeError/DivisionByZero
	name = "DivideByZeroError"
	message = "Division by zero attempted."

/datum/runtimeError/MaxCPU
	name = "MaxComputationalUse"
	message = "Maximum amount of computational cycles reached (>= 1000)."

/datum/runtimeError/VectorLimit
	name = "VectorSizeOverflow"
	message = "Maximum vector size reached"

/datum/runtimeError/StringLimit
	name = "StringSizeOverflow"
	message = "Maximum string size reached"
