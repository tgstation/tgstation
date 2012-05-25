//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
	File: Binary Operators
*/
/*
	Class: binary
	Represents a binary operator in the AST. A binary operator takes two operands (ie x and y) and returns a value.
*/
/node/expression/operator/binary
	var/node/expression/exp2

////////// Comparison Operators //////////
/*
	Class: Equal
	Returns true if x = y.
*/
//
	Equal
		precedence=OOP_EQUAL

/*
	Class: NotEqual
	Returns true if x and y aren't equal.
*/
//
	NotEqual
		precedence=OOP_EQUAL

/*
	Class: Greater
	Returns true if x > y.
*/
//
	Greater
		precedence=OOP_COMPARE

/*
	Class: Less
	Returns true if x < y.
*/
//
	Less
		precedence=OOP_COMPARE

/*
	Class: GreaterOrEqual
	Returns true if x >= y.
*/
//
	GreaterOrEqual
		precedence=OOP_COMPARE

/*
	Class: LessOrEqual
	Returns true if x <= y.
*/
//
	LessOrEqual
		precedence=OOP_COMPARE


////////// Logical Operators //////////

/*
	Class: LogicalAnd
	Returns true if x and y are true.
*/
//
	LogicalAnd
		precedence=OOP_AND

/*
	Class: LogicalOr
	Returns true if x, y, or both are true.
*/
//
	LogicalOr
		precedence=OOP_OR

/*
	Class: LogicalXor
	Returns true if either x or y but not both are true.
*/
//
	LogicalXor					//Not implemented in nS
		precedence=OOP_OR


////////// Bitwise Operators //////////

/*
	Class: BitwiseAnd
	Performs a bitwise and operation.

	Example:
	011 & 110 = 010
*/
//
	BitwiseAnd
		precedence=OOP_BIT

/*
	Class: BitwiseOr
	Performs a bitwise or operation.

	Example:
	011 | 110 = 111
*/
//
	BitwiseOr
		precedence=OOP_BIT

/*
	Class: BitwiseXor
	Performs a bitwise exclusive or operation.

	Example:
	011 xor 110 = 101
*/
//
	BitwiseXor
		precedence=OOP_BIT


////////// Arithmetic Operators //////////

/*
	Class: Add
	Returns the sum of x and y.
*/
//
	Add
		precedence=OOP_ADD

/*
	Class: Subtract
	Returns the difference of x and y.
*/
//
	Subtract
		precedence=OOP_ADD

/*
	Class: Multiply
	Returns the product of x and y.
*/
//
	Multiply
		precedence=OOP_MULTIPLY

/*
	Class: Divide
	Returns the quotient of x and y.
*/
//
	Divide
		precedence=OOP_MULTIPLY

/*
	Class: Power
	Returns x raised to the power of y.
*/
//
	Power
		precedence=OOP_POW

/*
	Class: Modulo
	Returns the remainder of x / y.
*/
//
	Modulo
		precedence=OOP_MULTIPLY
