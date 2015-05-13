/*
	Class: scope
	A runtime instance of a block. Used internally by the interpreter.
*/
scope
	var
		scope/parent = null
		node/BlockDefinition/block
		list
			functions
			variables

	New(node/BlockDefinition/B, scope/parent)
		src.block = B
		src.parent = parent
		src.variables = B.initial_variables.Copy()
		src.functions = B.functions.Copy()
		.=..()