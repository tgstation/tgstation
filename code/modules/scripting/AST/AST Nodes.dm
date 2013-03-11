/*
	File: AST Nodes
	An abstract syntax tree (AST) is a representation of source code in a computer-friendly format. It is composed of nodes,
	each of which represents a certain part of the source code. For example, an <IfStatement> node represents an if statement in the
	script's source code. Because it is a representation of the source code in memory, it is independent of any specific scripting language.
	This allows a script in any language for which a parser exists to be run by the interpreter.

	The AST is produced by an <n_Parser> object. It consists of a <GlobalBlock> with an arbitrary amount of statements. These statements are
	run in order by an <n_Interpreter> object. A statement may in turn run another block (such as an if statement might if its condition is
	met).

	Articles:
	- <http://en.wikipedia.org/wiki/Abstract_syntax_tree>
*/
var
	const
/*
	Constants: Operator Precedence
	OOP_OR				- Logical or
	OOP_AND				- Logical and
	OOP_BIT				- Bitwise operations
	OOP_EQUAL			- Equality checks
	OOP_COMPARE		- Greater than, less then, etc
	OOP_ADD				- Addition and subtraction
	OOP_MULTIPLY	- Multiplication and division
	OOP_POW				- Exponents
	OOP_UNARY			- Unary Operators
	OOP_GROUP			- Parentheses
*/
		OOP_OR      = 							1   //||
		OOP_AND     = OOP_OR			+ 1   	//&&
		OOP_BIT     = OOP_AND			+ 1   //&, |
		OOP_EQUAL   = OOP_BIT			+ 1   //==, !=
		OOP_COMPARE = OOP_EQUAL		+ 1   //>, <, >=, <=
		OOP_ADD     = OOP_COMPARE	+ 1 	//+, -
		OOP_MULTIPLY= OOP_ADD			+ 1   //*, /, %
		OOP_POW     = OOP_MULTIPLY+ 1		//^
		OOP_UNARY   = OOP_POW			+ 1   //!
		OOP_GROUP   = OOP_UNARY		+ 1   //()

/*
	Class: node
*/
/node
	proc
		ToString()
			return "[src.type]"
/*
	Class: identifier
*/
/node/identifier
	var
		id_name

	New(id)
		.=..()
		src.id_name=id

	ToString()
		return id_name

/*
	Class: expression
*/
/node/expression
/*
	Class: operator
	See <Binary Operators> and <Unary Operators> for subtypes.
*/
/node/expression/operator
	var
		node/expression/exp
		tmp
			name
			precedence

	New()
		.=..()
		if(!src.name) src.name="[src.type]"

	ToString()
		return "operator: [name]"

/*
	Class: FunctionCall
*/
/node/expression/FunctionCall
	//Function calls can also be expressions or statements.
	var
		func_name
		node/identifier/object
		list/parameters=new

/*
	Class: literal
*/
/node/expression/value/literal
	var
		value

	New(value)
		.=..()
		src.value=value

	ToString()
		return src.value

/*
	Class: variable
*/
/node/expression/value/variable
	var
		node
			object		//Either a node/identifier or another node/expression/value/variable which points to the object
		node/identifier
			id


	New(ident)
		.=..()
		id=ident
		if(istext(id))id=new(id)

	ToString()
		return src.id.ToString()

/*
	Class: reference
*/
/node/expression/value/reference
	var
		datum/value

	New(value)
		.=..()
		src.value=value

	ToString()
		return "ref: [src.value] ([src.value.type])"