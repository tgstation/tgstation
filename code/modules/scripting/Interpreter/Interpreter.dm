/*
	File: Interpreter (Internal)
*/
/*
	Class: n_Interpreter
*/
/*
	Macros: Status Macros
	RETURNING  - Indicates that the current function is returning a value.
	BREAKING   - Indicates that the current loop is being terminated.
	CONTINUING - Indicates that the rest of the current iteration of a loop is being skipped.
*/
#define RETURNING  1
#define BREAKING   2
#define CONTINUING 4

/datum/n_Interpreter
	var/datum/scope/curScope
	var/datum/scope/globalScope

	var/datum/node/BlockDefinition/program	
	var/datum/node/statement/FunctionDefinition/curFunction	
	var/datum/stack/scopes	= new()
	var/datum/stack/functions	= new()

	var/datum/container // associated container for interpeter
/*
	Var: status
	A variable indicating that the rest of the current block should be skipped. This may be set to any combination of <Status Macros>.
*/
	var/status = 0
	var/returnVal

	var/max_statements = 900 // maximum amount of statements that can be called in one execution. this is to prevent massive crashes and exploitation
	var/cur_statements = 0    // current amount of statements called
	var/alertadmins = 0		// set to 1 if the admins shouldn't be notified of anymore issues
	var/max_iterations = 100 	// max number of uninterrupted loops possible
	var/max_recursion = 10   	// max recursions without returning anything (or completing the code block)
	var/cur_recursion = 0	   	// current amount of recursion
/*
	Var: persist
	If 0, global variables will be reset after Run() finishes.
*/
	var/persist = 1
	var/paused = 0

/*
	Constructor: New
	Calls <Load()> with the given parameters.
*/
/datum/n_Interpreter/New(datum/node/BlockDefinition/GlobalBlock/program = null)
	. = ..()
	if(program)
		Load(program)

/*
	Set ourselves to Garbage Collect
*/
/datum/n_Interpreter/proc/GC()
	..()
	container = null

/*
	Proc: RaiseError
	Raises a runtime error.
*/
/datum/n_Interpreter/proc/RaiseError(datum/runtimeError/e)
	e.stack = functions.Copy()
	e.stack.Push(curFunction)
	src.HandleError(e)

/datum/n_Interpreter/proc/CreateScope(datum/node/BlockDefinition/B)
	var/datum/scope/S = new(B, curScope)
	scopes.Push(curScope)
	curScope = S
	return S

/datum/n_Interpreter/proc/CreateGlobalScope()
	scopes.Clear()
	var/datum/scope/S = new(program, null)
	globalScope = S
	return S

/*
Proc: AlertAdmins
Alerts the admins of a script that is bad.
*/
/datum/n_Interpreter/proc/AlertAdmins()
	if(container && !alertadmins)
		if(istype(container, /datum/TCS_Compiler))
			var/datum/TCS_Compiler/Compiler = container
			var/obj/machinery/telecomms/server/Holder = Compiler.Holder
			var/message = "Potential crash-inducing NTSL script detected at telecommunications server [Compiler.Holder] ([Holder.x], [Holder.y], [Holder.z])."

			alertadmins = 1
			message_admins(message, 1)
/*
Proc: RunBlock
Runs each statement in a block of code.
*/
/datum/n_Interpreter/proc/RunBlock(var/datum/node/BlockDefinition/Block, var/datum/scope/scope = null)
	var/is_global = istype(Block, /datum/node/BlockDefinition/GlobalBlock)
	if(!is_global)
		if(scope)
			curScope = scope
		else
			CreateScope(Block)
	else
		if(!persist)
			CreateGlobalScope()

		curScope = globalScope

	if(cur_statements < max_statements)
		for(var/datum/node/statement/S in Block.statements)
			while(paused) sleep(10)

			cur_statements++
			if(cur_statements >= max_statements)
				RaiseError(new/datum/runtimeError/MaxCPU())
				AlertAdmins()
				break

			if(istype(S, /datum/node/statement/VariableAssignment))
				var/datum/node/statement/VariableAssignment/stmt = S
				var/name = stmt.var_name.id_name

				if(!stmt.object)
					// Below we assign the variable first to null if it doesn't already exist.
					// This is necessary for assignments like +=, and when the variable is used in a function
					// If the variable already exists in a different block, then AssignVariable will automatically use that one.
					if(!IsVariableAccessible(name))
						AssignVariable(name, null)

					AssignVariable(name, Eval(stmt.value))
				else
					var/datum/D = Eval(GetVariable(stmt.object.id_name))
					if(!D)
						return

					D.vars[stmt.var_name.id_name] = Eval(stmt.value)

			else if(istype(S, /datum/node/statement/VariableDeclaration))
				//VariableDeclaration nodes are used to forcibly declare a local variable so that one in a higher scope isn't used by default.
				var/datum/node/statement/VariableDeclaration/dec=S
				if(!dec.object)
					AssignVariable(dec.var_name.id_name, null, curScope)
				else
					var/datum/D = Eval(GetVariable(dec.object.id_name))
					if(!D)
						return

					D.vars[dec.var_name.id_name] = null

			else if(istype(S, /datum/node/statement/FunctionCall))
				RunFunction(S)

			else if(istype(S, /datum/node/statement/FunctionDefinition))
				//do nothing

			else if(istype(S, /datum/node/statement/WhileLoop))
				RunWhile(S)

			else if(istype(S, /datum/node/statement/IfStatement))
				RunIf(S)

			else if(istype(S, /datum/node/statement/ReturnStatement))
				if(!curFunction)
					RaiseError(new/datum/runtimeError/UnexpectedReturn())
					continue

				status |= RETURNING
				returnVal = Eval(S:value)
				break

			else if(istype(S, /datum/node/statement/BreakStatement))
				status |= BREAKING
				break

			else if(istype(S, /datum/node/statement/ContinueStatement))
				status |= CONTINUING
				break

			else
				RaiseError(new/datum/runtimeError/UnknownInstruction())

			if(status)
				break

	curScope = scopes.Pop()

/*
Proc: RunFunction
Runs a function block or a proc with the arguments specified in the script.
*/
/datum/n_Interpreter/proc/RunFunction(var/datum/node/statement/FunctionCall/stmt)
	//Note that anywhere /datum/node/statement/FunctionCall/stmt is used so may /datum/node/expression/FunctionCall

	// If recursion gets too high (max 50 nested functions) throw an error
	if(cur_recursion >= max_recursion)
		AlertAdmins()
		RaiseError(new/datum/runtimeError/RecursionLimitReached())
		return 0

	var/datum/node/statement/FunctionDefinition/def
	if(!stmt.object)							//A scope's function is being called, stmt.object is null
		def = GetFunction(stmt.func_name)

	else if(istype(stmt.object))				//A method of an object exposed as a variable is being called, stmt.object is a /node/identifier
		var/O = GetVariable(stmt.object.id_name)	//Gets a reference to the object which is the target of the function call.
		if(!O) return							//Error already thrown in GetVariable()
		def = Eval(O)

	if(!def)
		return

	cur_recursion++ // add recursion
	if(istype(def))
		if(curFunction) functions.Push(curFunction)
		var/datum/scope/S = CreateScope(def.block)

		for(var/i = 1 to def.parameters.len)
			var/val
			if(stmt.parameters.len >= i)
				val = stmt.parameters[i]
			//else
			//	unspecified param
			AssignVariable(def.parameters[i], new/datum/node/expression/value/literal(Eval(val)), S)

		curFunction = stmt
		RunBlock(def.block, S)

		//Handle return value
		. = returnVal
		status &= ~RETURNING
		returnVal = null
		curFunction = functions.Pop()
		cur_recursion--

	else
		cur_recursion--
		var/list/params = new
		for(var/datum/node/expression/P in stmt.parameters)
			params += list(Eval(P))

		if(isobject(def))	//def is an object which is the target of a function call
			if(!hascall(def, stmt.func_name))
				RaiseError(new/datum/runtimeError/UndefinedFunction("[stmt.object.id_name].[stmt.func_name]"))
				return

			return call(def, stmt.func_name)(arglist(params))

		else										//def is a path to a global proc
			return call(def)(arglist(params))
	//else
	//	RaiseError(new/runtimeError/UnknownInstruction())

/*
Proc: RunIf
Checks a condition and runs either the if block or else block.
*/
/datum/n_Interpreter/proc/RunIf(var/datum/node/statement/IfStatement/stmt)
	if(!stmt.skip)
		if(Eval(stmt.cond))
			RunBlock(stmt.block)
			// Loop through the if else chain and tell them to be skipped.
			var/datum/node/statement/IfStatement/i = stmt.else_if
			var/fail_safe = 800

			while(i && fail_safe)
				fail_safe -= 1
				i.skip = 1
				i = i.else_if

		else if(stmt.else_block)
			RunBlock(stmt.else_block)

	// We don't need to skip you anymore.
	stmt.skip = 0

/*
Proc: RunWhile
Runs a while loop.
*/

/datum/n_Interpreter/proc/RunWhile(var/datum/node/statement/WhileLoop/stmt)
	var/i = 1
	while(Eval(stmt.cond) && Iterate(stmt.block, i++))
		continue

	status &= ~BREAKING

/*
Proc:Iterate
Runs a single iteration of a loop. Returns a value indicating whether or not to continue looping.
*/

/datum/n_Interpreter/proc/Iterate(var/datum/node/BlockDefinition/block, count)
	RunBlock(block)
	if(max_iterations > 0 && count >= max_iterations)
		RaiseError(new/datum/runtimeError/IterationLimitReached())
		return 0

	if(status & (BREAKING|RETURNING))
		return 0

	status &= ~CONTINUING
	return 1

/*
Proc: GetFunction
Finds a function in an accessible scope with the given name. Returns a <FunctionDefinition>.
*/

/datum/n_Interpreter/proc/GetFunction(name)
	var/datum/scope/S = curScope
	while(S)
		if(S.functions.Find(name))
			return S.functions[name]
		S = S.parent

	RaiseError(new/datum/runtimeError/UndefinedFunction(name))

/*
Proc: GetVariable
Finds a variable in an accessible scope and returns its value.
*/

/datum/n_Interpreter/proc/GetVariable(name)
	var/datum/scope/S = curScope
	while(S)
		if(S.variables.Find(name))
			return S.variables[name]
		S = S.parent

	RaiseError(new/datum/runtimeError/UndefinedVariable(name))

/datum/n_Interpreter/proc/GetVariableScope(name) //needed for when you reassign a variable in a higher scope
	var/datum/scope/S = curScope
	while(S)
		if(S.variables.Find(name))
			return S

		S = S.parent


/datum/n_Interpreter/proc/IsVariableAccessible(name)
	var/datum/scope/S = curScope
	while(S)
		if(S.variables.Find(name))
			return TRUE
		S = S.parent

	return FALSE


/*
Proc: AssignVariable
Assigns a value to a variable in a specific block.

Parameters:
name  - The name of the variable to assign.
value - The value to assign to it.
S     - The scope the variable resides in. If it is null, a scope with the variable already existing is found. If no scopes have a variable of the given name, the current scope is used.
*/

/datum/n_Interpreter/proc/AssignVariable(name, datum/node/expression/value, var/datum/scope/S = null)
	if(!S) S = GetVariableScope(name)
	if(!S) S = curScope
	if(!S) S = globalScope

	ASSERT(istype(S))
	if(istext(value) || isnum(value) || isnull(value))	value = new/datum/node/expression/value/literal(value)
	else if(!istype(value) && isobject(value))			value = new/datum/node/expression/value/reference(value)
	//TODO: check for invalid name
	S.variables["[name]"] = value


