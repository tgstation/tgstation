/*
	File: Errors
*/
/*
	Class: scriptError
	An error scanning or parsing the source code.
*/
/scriptError
	var
/*
	Var: message
	A message describing the problem.
*/
		message
	New(msg=null)
		if(msg)message=msg

	BadToken
		message="Unexpected token: "
		var/token/token
		New(token/t)
			token=t
			if(t&&t.line) message="[t.line]: [message]"
			if(istype(t))message+="[t.value]"
			else message+="[t]"

	InvalidID
		parent_type=/scriptError/BadToken
		message="Invalid identifier name: "

	ReservedWord
		parent_type=/scriptError/BadToken
		message="Identifer using reserved word: "

	BadNumber
		parent_type=/scriptError/BadToken
		message = "Bad number: "

	BadReturn
		var/token/token
		message = "Unexpected return statement outside of a function."
		New(token/t)
			src.token=t

	EndOfFile
		message = "Unexpected end of file."

	ExpectedToken
		message="Expected: '"
		New(id, token/T)
			if(T && T.line) message="[T.line]: [message]"
			message+="[id]'. "
			if(T)message+="Found '[T.value]'."


	UnterminatedComment
		message="Unterminated multi-line comment statement: expected */"

	DuplicateFunction
		New(name, token/t)
			message="Function '[name]' defined twice."

	ParameterFunction
		message = "You cannot use a function inside a parameter."

		New(token/t)
			var/line = "?"
			if(t)
				line = t.line
			message = "[line]: [message]"

/*
	Class: runtimeError
	An error thrown by the interpreter in running the script.
*/
/runtimeError
	var
		name
/*
	Var: message
	A basic description as to what went wrong.
*/
		message
		stack/stack

	proc
/*
	Proc: ToString
	Returns a description of the error suitable for showing to the user.
*/
		ToString()
			. = "[name]: [message]"
			if(!stack.Top()) return
			.+="\nStack:"
			while(stack.Top())
				var/node/statement/FunctionCall/stmt=stack.Pop()
				. += "\n\t [stmt.func_name]()"

	TypeMismatch
		name="TypeMismatchError"
		New(op, a, b)
			message="Type mismatch: '[a]' [op] '[b]'"

	UnexpectedReturn
		name="UnexpectedReturnError"
		message="Unexpected return statement."

	UnknownInstruction
		name="UnknownInstructionError"
		message="Unknown instruction type. This may be due to incompatible compiler and interpreter versions or a lack of implementation."

	UndefinedVariable
		name="UndefinedVariableError"
		New(variable)
			message="Variable '[variable]' has not been declared."

	UndefinedFunction
		name="UndefinedFunctionError"
		New(function)
			message="Function '[function]()' has not been defined."

	DuplicateVariableDeclaration
		name="DuplicateVariableError"
		New(variable)
			message="Variable '[variable]' was already declared."

	IterationLimitReached
		name="MaxIterationError"
		message="A loop has reached its maximum number of iterations."

	RecursionLimitReached
		name="MaxRecursionError"
		message="The maximum amount of recursion has been reached."

	DivisionByZero
		name="DivideByZeroError"
		message="Division by zero attempted."

	MaxCPU
		name="MaxComputationalUse"
		message="Maximum amount of computational cycles reached (>= 1000)."