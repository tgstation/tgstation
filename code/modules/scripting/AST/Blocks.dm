/*
	File: Block Types
*/
/*
	Class: BlockDefinition
	An object representing a set of actions to perform independently from the rest of the script. Blocks are basically just
	lists of statements to execute which also contain some local variables and methods. Note that since functions are local to a block,
	it is possible to have a function definition inside of any type of block (such as in an if statement or another function),
	and not just in the global scope as in many languages.
*/
/node/BlockDefinition
	var/list
		statements = new
		functions  = new
		initial_variables = new

	proc
/*
	Proc: SetVar
	Defines a permanent variable. The variable will not be deleted when it goes out of scope.

	Notes:
	Since all pre-existing temporary variables are deleted, it is not generally desirable to use this proc after the interpreter has been instantiated.
	Instead, use <n_Interpreter.SetVar()>.

	See Also:
	- <n_Interpreter.SetVar()>
*/
		SetVar(name, value)
			initial_variables[name]=value


/*
	Class: GlobalBlock
	A block object representing the global scope.
*/
//
	GlobalBlock
		New()
			initial_variables["null"]=null
			return ..()

/*
	Class: FunctionBlock
	A block representing a function body.
*/
//
	FunctionBlock