/*
	File: Statement Types
*/
/*
	Class: statement
	An object representing a single instruction run by an interpreter.
*/
/datum/node/statement
/*
	Class: FunctionCall
	Represents a call to a function.
*/
//
/datum/node/statement/FunctionCall
	var/func_name
	var/datum/node/identifier/object
	var/list/parameters = new

/*
Class: FunctionDefinition
Defines a function.
*/
//
/datum/node/statement/FunctionDefinition
	var/func_name
	var/list/parameters = new
	var/datum/node/BlockDefinition/FunctionBlock/block

/*
Class: VariableAssignment
Sets a variable in an accessible scope to the given value if one exists, otherwise initializes a new local variable to the given value.

Notes:
If a variable with the same name exists in a higher block, the value will be assigned to it. If not,
a new variable is created in the current block. To force creation of a new variable, use <VariableDeclaration>.

See Also:
- <VariableDeclaration>
*/
//
/datum/node/statement/VariableAssignment
	var/datum/node/identifier/object
	var/datum/node/identifier/var_name
	var/datum/node/expression/value

/*
Class: VariableDeclaration
Intializes a local variable to a null value.

See Also:
- <VariableAssignment>
*/
//
/datum/node/statement/VariableDeclaration
	var/datum/node/identifier/object
	var/datum/node/identifier/var_name

/*
Class: IfStatement
*/
//
/datum/node/statement/IfStatement
	var/skip = 0
	var/datum/node/BlockDefinition/block
	var/datum/node/BlockDefinition/else_block //may be null
	var/datum/node/expression/cond
	var/datum/node/statement/else_if

/datum/node/statement/IfStatement/ElseIf

/*
Class: WhileLoop
Loops while a given condition is true.
*/
//
/datum/node/statement/WhileLoop
	var/datum/node/BlockDefinition/block
	var/datum/node/expression/cond

/*
Class: ForLoop
Loops while test is true, initializing a variable, increasing the variable
*/
/datum/node/statement/ForLoop
	var/datum/node/BlockDefinition/block
	var/datum/node/expression/test
	var/datum/node/expression/init
	var/datum/node/expression/increment

/*
Class: BreakStatement
Ends a loop.
*/
//
/datum/node/statement/BreakStatement

/*
Class: ContinueStatement
Skips to the next iteration of a loop.
*/
//
/datum/node/statement/ContinueStatement

/*
Class: ReturnStatement
Ends the function and returns a value.
*/
//
/datum/node/statement/ReturnStatement
	var/datum/node/expression/value