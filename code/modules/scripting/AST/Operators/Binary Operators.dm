//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
	File: Binary Operators
*/
/*
	Class: binary
	Represents a binary operator in the AST. A binary operator takes two operands (ie x and y) and returns a value.
*/
/datum/node/expression/operator/binary
	var/datum/node/expression/exp2

////////// Comparison Operators //////////
/*
	Class: Equal
	Returns true if x = y.
*/
//
/datum/node/expression/operator/binary/Equal
	token		= "=="
	precedence	= OOP_EQUAL

/*
Class: NotEqual
Returns true if x and y aren't equal.
*/
//
/datum/node/expression/operator/binary/NotEqual
	token		= "!="
	precedence	= OOP_EQUAL

/*
Class: Greater
Returns true if x > y.
*/
//
/datum/node/expression/operator/binary/Greater
	token		= ">"
	precedence	= OOP_COMPARE

/*
Class: Less
Returns true if x < y.
*/
//
/datum/node/expression/operator/binary/Less
	token		= "<"
	precedence	= OOP_COMPARE

/*
Class: GreaterOrEqual
Returns true if x >= y.
*/
//
/datum/node/expression/operator/binary/GreaterOrEqual
	token		= ">="
	precedence	= OOP_COMPARE

/*
Class: LessOrEqual
Returns true if x <= y.
*/
//
/datum/node/expression/operator/binary/LessOrEqual
	token		= "<="
	precedence	= OOP_COMPARE


////////// Logical Operators //////////

/*
Class: LogicalAnd
Returns true if x and y are true.
*/
//
/datum/node/expression/operator/binary/LogicalAnd
	token		= "&&"
	precedence	= OOP_AND

/*
Class: LogicalOr
Returns true if x, y, or both are true.
*/
//
/datum/node/expression/operator/binary/LogicalOr
	token		= "||"
	precedence	= OOP_OR

/*
Class: LogicalXor
Returns true if either x or y but not both are true.
*/
//
/datum/node/expression/operator/binary/LogicalXor					//Not implemented in nS
	precedence	= OOP_OR


////////// Bitwise Operators //////////

/*
Class: BitwiseAnd
Performs a bitwise and operation.

Example:
011 & 110 = 010
*/
//
/datum/node/expression/operator/binary/BitwiseAnd
	token		= "&"
	precedence	= OOP_BIT

/*
Class: BitwiseOr
Performs a bitwise or operation.

Example:
011 | 110 = 111
*/
//
/datum/node/expression/operator/binary/BitwiseOr
	token		= "|"
	precedence	= OOP_BIT

/*
Class: BitwiseXor
Performs a bitwise exclusive or operation.

Example:
011 xor 110 = 101
*/
//
/datum/node/expression/operator/binary/BitwiseXor
	token		= "`"
	precedence	= OOP_BIT


////////// Arithmetic Operators //////////

/*
Class: Add
Returns the sum of x and y.
*/
//
/datum/node/expression/operator/binary/Add
	token		= "+"
	precedence	= OOP_ADD

/*
Class: Subtract
Returns the difference of x and y.
*/
//
/datum/node/expression/operator/binary/Subtract
	token		= "-"
	precedence	= OOP_ADD

/*
Class: Multiply
Returns the product of x and y.
*/
//
/datum/node/expression/operator/binary/Multiply
	token		= "*"
	precedence	= OOP_MULTIPLY

/*
Class: Divide
Returns the quotient of x and y.
*/
//
/datum/node/expression/operator/binary/Divide
	token		= "/"
	precedence	= OOP_MULTIPLY

/*
Class: Power
Returns x raised to the power of y.
*/
//
/datum/node/expression/operator/binary/Power
	token		= "^"
	precedence	= OOP_POW

/*
Class: Modulo
Returns the remainder of x / y.
*/
//
/datum/node/expression/operator/binary/Modulo
	token		= "%"
	precedence	= OOP_MULTIPLY
