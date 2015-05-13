/*
	File: Interpreter (Public)
	Contains methods for interacting with the interpreter.
*/
/*
	Class: n_Interpreter
	Procedures allowing for interaction with the script that is being run by the interpreter object.
*/

/n_Interpreter
	proc

/*
	Proc: Load
	Loads a 'compiled' script into memory.

	Parameters:
	program - A <GlobalBlock> object which represents the script's global scope.
*/
		Load(node/BlockDefinition/GlobalBlock/program)
			ASSERT(program)
			src.program 	= program
			CreateGlobalScope()
			alertadmins = 0 // reset admin alerts

/*
	Proc: Run
	Runs the script.
*/
		Run()
			cur_recursion = 0 // reset recursion
			cur_statements = 0 // reset CPU tracking

			ASSERT(src.program)
			RunBlock(src.program)

/*
	Proc: SetVar
	Defines a global variable for the duration of the next execution of a script.

	Notes:
	This differs from <Block.SetVar()> in that variables set using this procedure only last for the session,
	while those defined from the block object persist if it is ran multiple times.

	See Also:
	- <Block.SetVar()>
*/
		SetVar(name, value)
			if(!istext(name))
				//CRASH("Invalid variable name")
				return
			AssignVariable(name, value)

/*
	Proc: SetProc
	Defines a procedure to be available to the script.

	Parameters:
	name 		- The name of the procedure as exposed to the script.
	path 		- The typepath of a proc to be called when the function call is read by the interpreter, or, if object is specified, a string representing the procedure's name.
	object	- (Optional) An object which will the be target of a function call.
	params 	- Only required if object is not null, a list of the names of parameters the proc takes.
*/
		SetProc(name, path, object=null, list/params=null)
			if(!istext(name))
				//CRASH("Invalid function name")
				return
			if(!object)
				globalScope.functions[name] = path
			else
				var/node/statement/FunctionDefinition/S = new()
				S.func_name		= name
				S.parameters	= params
				S.block			= new()
				S.block.SetVar("src", object)
				var/node/expression/FunctionCall/C = new()
				C.func_name	= path
				C.object		= new("src")
				for(var/p in params)
					C.parameters += new/node/expression/value/variable(p)
				var/node/statement/ReturnStatement/R=new()
				R.value=C
				S.block.statements += R
				globalScope.functions[name] = S
/*
	Proc: VarExists
	Checks whether a global variable with the specified name exists.
*/
		VarExists(name)
			return globalScope.variables.Find(name) //convert to 1/0 first?

/*
	Proc: ProcExists
	Checks whether a global function with the specified name exists.
*/
		ProcExists(name)
			return globalScope.functions.Find(name)

/*
	Proc: GetVar
	Returns the value of a global variable in the script. Remember to ensure that the variable exists before calling this procedure.

	See Also:
	- <VarExists()>
*/
		GetVar(name)
			if(!VarExists(name))
				//CRASH("No variable named '[name]'.")
				return
			var/x = globalScope.variables[name]
			return Eval(x)

/*
	Proc: GetCleanVar
	Returns the value of a global variable in the script and cleans it (sanitizes).
*/

		GetCleanVar(name, compare)
			var/x = GetVar(name)
			if(istext(x) && compare && x != compare) // Was changed
				x = sanitize(x)
			return x

/*
	Proc: CallProc
	Calls a global function defined in the script and, amazingly enough, returns its return value. Remember to ensure that the function
	exists before calling this procedure.

	See Also:
	- <ProcExists()>
*/
		CallProc(name, params[]=null)
			if(!ProcExists(name))
				//CRASH("No function named '[name]'.")
				return
			var/node/statement/FunctionDefinition/func = globalScope.functions[name]
			if(istype(func))
				var/node/statement/FunctionCall/stmt = new
				stmt.func_name  = func.func_name
				stmt.parameters = params
				return RunFunction(stmt)
			else
				return call(func)(arglist(params))
			//CRASH("Unknown function type '[name]'.")

/*
	Event: HandleError
	Called when the interpreter throws a runtime error.

	See Also:
	- <runtimeError>
*/
		HandleError(runtimeError/e)