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
/n_Interpreter
	var
		scope
			curScope
			globalScope
		node
			BlockDefinition/program
			statement/FunctionDefinition/curFunction
		stack
			scopes		= new()
			functions	= new()

		datum/container // associated container for interpeter
/*
	Var: status
	A variable indicating that the rest of the current block should be skipped. This may be set to any combination of <Status Macros>.
*/
		status=0
		returnVal

		max_statements=900 // maximum amount of statements that can be called in one execution. this is to prevent massive crashes and exploitation
		cur_statements=0    // current amount of statements called
		alertadmins=0		// set to 1 if the admins shouldn't be notified of anymore issues
		max_iterations=100 	// max number of uninterrupted loops possible
		max_recursion=10   	// max recursions without returning anything (or completing the code block)
		cur_recursion=0	   	// current amount of recursion
/*
	Var: persist
	If 0, global variables will be reset after Run() finishes.
*/
		persist=1
		paused=0

/*
	Constructor: New
	Calls <Load()> with the given parameters.
*/
	New(node/BlockDefinition/GlobalBlock/program=null)
		.=..()
		if(program)Load(program)

	proc

/*
	Set ourselves to Garbage Collect
*/
		GC()
			..()
			container = null

/*
	Proc: RaiseError
	Raises a runtime error.
*/
		RaiseError(runtimeError/e)
			e.stack=functions.Copy()
			e.stack.Push(curFunction)
			src.HandleError(e)

		CreateScope(node/BlockDefinition/B)
			var/scope/S = new(B, curScope)
			scopes.Push(curScope)
			curScope = S
			return S

		CreateGlobalScope()
			scopes.Clear()
			var/scope/S = new(program, null)
			globalScope = S
			return S

/*
	Proc: AlertAdmins
	Alerts the admins of a script that is bad.
*/
		AlertAdmins()
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
		RunBlock(node/BlockDefinition/Block, scope/scope = null)
			var/is_global = istype(Block, /node/BlockDefinition/GlobalBlock)
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

				for(var/node/statement/S in Block.statements)
					while(paused) sleep(10)

					cur_statements++
					if(cur_statements >= max_statements)
						RaiseError(new/runtimeError/MaxCPU())
						AlertAdmins()
						break

					if(istype(S, /node/statement/VariableAssignment))
						var/node/statement/VariableAssignment/stmt = S
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
							if(!D) return
							D.vars[stmt.var_name.id_name] = Eval(stmt.value)
					else if(istype(S, /node/statement/VariableDeclaration))
						//VariableDeclaration nodes are used to forcibly declare a local variable so that one in a higher scope isn't used by default.
						var/node/statement/VariableDeclaration/dec=S
						if(!dec.object)
							AssignVariable(dec.var_name.id_name, null, curScope)
						else
							var/datum/D = Eval(GetVariable(dec.object.id_name))
							if(!D) return
							D.vars[dec.var_name.id_name] = null
					else if(istype(S, /node/statement/FunctionCall))
						RunFunction(S)
					else if(istype(S, /node/statement/FunctionDefinition))
						//do nothing
					else if(istype(S, /node/statement/WhileLoop))
						RunWhile(S)
					else if(istype(S, /node/statement/IfStatement))
						RunIf(S)
					else if(istype(S, /node/statement/ReturnStatement))
						if(!curFunction)
							RaiseError(new/runtimeError/UnexpectedReturn())
							continue
						status |= RETURNING
						returnVal=Eval(S:value)
						break
					else if(istype(S, /node/statement/BreakStatement))
						status |= BREAKING
						break
					else if(istype(S, /node/statement/ContinueStatement))
						status |= CONTINUING
						break
					else
						RaiseError(new/runtimeError/UnknownInstruction())
					if(status)
						break

			curScope = scopes.Pop()

/*
	Proc: RunFunction
	Runs a function block or a proc with the arguments specified in the script.
*/
		RunFunction(node/statement/FunctionCall/stmt)
			//Note that anywhere /node/statement/FunctionCall/stmt is used so may /node/expression/FunctionCall

			// If recursion gets too high (max 50 nested functions) throw an error
			if(cur_recursion >= max_recursion)
				AlertAdmins()
				RaiseError(new/runtimeError/RecursionLimitReached())
				return 0

			var/node/statement/FunctionDefinition/def
			if(!stmt.object)							//A scope's function is being called, stmt.object is null
				def = GetFunction(stmt.func_name)
			else if(istype(stmt.object))				//A method of an object exposed as a variable is being called, stmt.object is a /node/identifier
				var/O = GetVariable(stmt.object.id_name)	//Gets a reference to the object which is the target of the function call.
				if(!O) return							//Error already thrown in GetVariable()
				def = Eval(O)

			if(!def) return

			cur_recursion++ // add recursion
			if(istype(def))
				if(curFunction) functions.Push(curFunction)
				var/scope/S = CreateScope(def.block)
				for(var/i=1 to def.parameters.len)
					var/val
					if(stmt.parameters.len>=i)
						val = stmt.parameters[i]
					//else
					//	unspecified param
					AssignVariable(def.parameters[i], new/node/expression/value/literal(Eval(val)), S)
				curFunction=stmt
				RunBlock(def.block, S)
				//Handle return value
				. = returnVal
				status &= ~RETURNING
				returnVal=null
				curFunction=functions.Pop()
				cur_recursion--
			else
				cur_recursion--
				var/list/params=new
				for(var/node/expression/P in stmt.parameters)
					params+=list(Eval(P))
				if(isobject(def))	//def is an object which is the target of a function call
					if( !hascall(def, stmt.func_name) )
						RaiseError(new/runtimeError/UndefinedFunction("[stmt.object.id_name].[stmt.func_name]"))
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
		RunIf(node/statement/IfStatement/stmt)
			if(!stmt.skip)
				if(Eval(stmt.cond))
					RunBlock(stmt.block)
					// Loop through the if else chain and tell them to be skipped.
					var/node/statement/IfStatement/i = stmt.else_if
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
		RunWhile(node/statement/WhileLoop/stmt)
			var/i=1
			while(Eval(stmt.cond) && Iterate(stmt.block, i++))
				continue
			status &= ~BREAKING

/*
	Proc:Iterate
	Runs a single iteration of a loop. Returns a value indicating whether or not to continue looping.
*/
		Iterate(node/BlockDefinition/block, count)
			RunBlock(block)
			if(max_iterations > 0 && count >= max_iterations)
				RaiseError(new/runtimeError/IterationLimitReached())
				return 0
			if(status & (BREAKING|RETURNING))
				return 0
			status &= ~CONTINUING
			return 1

/*
	Proc: GetFunction
	Finds a function in an accessible scope with the given name. Returns a <FunctionDefinition>.
*/
		GetFunction(name)
			var/scope/S = curScope
			while(S)
				if(S.functions.Find(name))
					return S.functions[name]
				S = S.parent
			RaiseError(new/runtimeError/UndefinedFunction(name))

/*
	Proc: GetVariable
	Finds a variable in an accessible scope and returns its value.
*/
		GetVariable(name)
			var/scope/S = curScope
			while(S)
				if(S.variables.Find(name))
					return S.variables[name]
				S = S.parent
			RaiseError(new/runtimeError/UndefinedVariable(name))

		GetVariableScope(name) //needed for when you reassign a variable in a higher scope
			var/scope/S = curScope
			while(S)
				if(S.variables.Find(name))
					return S
				S = S.parent


		IsVariableAccessible(name)
			var/scope/S = curScope
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
		AssignVariable(name, node/expression/value, scope/S=null)
			if(!S) S = GetVariableScope(name)
			if(!S) S = curScope
			if(!S) S = globalScope
			ASSERT(istype(S))
			if(istext(value) || isnum(value) || isnull(value))	value = new/node/expression/value/literal(value)
			else if(!istype(value) && isobject(value))			value = new/node/expression/value/reference(value)
			//TODO: check for invalid name
			S.variables["[name]"] = value


