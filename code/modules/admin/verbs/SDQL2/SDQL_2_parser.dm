//I'm pretty sure that this is a recursive [s]descent[/s] ascent parser.



//Spec

//////////
//
//	query				:	select_query | delete_query | update_query | call_query | explain
//	explain				:	'EXPLAIN' query
//
//	select_query		:	'SELECT' select_list [('FROM' | 'IN') from_list] ['WHERE' bool_expression]
//	delete_query		:	'DELETE' select_list [('FROM' | 'IN') from_list] ['WHERE' bool_expression]
//	update_query		:	'UPDATE' select_list [('FROM' | 'IN') from_list] 'SET' assignments ['WHERE' bool_expression]
//	call_query			:	'CALL' call_function ['ON' select_list [('FROM' | 'IN') from_list] ['WHERE' bool_expression]]
//
//	select_list			:	select_item [',' select_list]
//	select_item			:	'*' | select_function | object_type
//	select_function		:	count_function
//	count_function		:	'COUNT' '(' '*' ')' | 'COUNT' '(' object_types ')'
//
//	from_list			:	from_item [',' from_list]
//	from_item			:	'world' | object_type
//
//	call_function		:	<function name> ['(' [arguments] ')']
//	arguments			:	expression [',' arguments]
//
//	object_type			:	<type path> | string
//
//	assignments			:	assignment, [',' assignments]
//	assignment			:	<variable name> '=' expression
//	variable			:	<variable name> | <variable name> '.' variable
//
//	bool_expression		:	expression comparitor expression  [bool_operator bool_expression]
//	expression			:	( unary_expression | '(' expression ')' | value ) [binary_operator expression]
//	unary_expression	:	unary_operator ( unary_expression | value | '(' expression ')' )
//	comparitor			:	'=' | '==' | '!=' | '<>' | '<' | '<=' | '>' | '>='
//	value				:	variable | string | number | 'null'
//	unary_operator		:	'!' | '-' | '~'
//	binary_operator		:	comparitor | '+' | '-' | '/' | '*' | '&' | '|' | '^'
//	bool_operator		:	'AND' | '&&' | 'OR' | '||'
//
//	string				:	''' <some text> ''' | '"' <some text > '"'
//	number				:	<some digits>
//
//////////

/datum/SDQL_parser
	var/query_type
	var/error = 0

	var/list/query
	var/list/tree

	var/list/select_functions = list("count")
	var/list/boolean_operators = list("and", "or", "&&", "||")
	var/list/unary_operators = list("!", "-", "~")
	var/list/binary_operators = list("+", "-", "/", "*", "&", "|", "^")
	var/list/comparitors = list("=", "==", "!=", "<>", "<", "<=", ">", ">=")



/datum/SDQL_parser/New(query_list)
	query = query_list



/datum/SDQL_parser/proc/parse_error(error_message)
	error = 1
	usr << "\red SQDL2 Parsing Error: [error_message]"
	return query.len + 1

/datum/SDQL_parser/proc/parse()
	tree = list()
	query(1, tree)

	if(error)
		return list()
	else
		return tree

/datum/SDQL_parser/proc/token(i)
	if(i <= query.len)
		return query[i]

	else
		return null

/datum/SDQL_parser/proc/tokens(i, num)
	if(i + num <= query.len)
		return query.Copy(i, i + num)

	else
		return null

/datum/SDQL_parser/proc/tokenl(i)
	return lowertext(token(i))



/datum/SDQL_parser/proc

//query:	select_query | delete_query | update_query
	query(i, list/node)
		query_type = tokenl(i)

		switch(query_type)
			if("select")
				select_query(i, node)

			if("delete")
				delete_query(i, node)

			if("update")
				update_query(i, node)

			if("call")
				call_query(i, node)

			if("explain")
				node += "explain"
				node["explain"] = list()
				query(i + 1, node["explain"])


//	select_query:	'SELECT' select_list [('FROM' | 'IN') from_list] ['WHERE' bool_expression]
	select_query(i, list/node)
		var/list/select = list()
		i = select_list(i + 1, select)

		node += "select"
		node["select"] = select

		var/list/from = list()
		if(tokenl(i) in list("from", "in"))
			i = from_list(i + 1, from)
		else
			from += "world"

		node += "from"
		node["from"] = from

		if(tokenl(i) == "where")
			var/list/where = list()
			i = bool_expression(i + 1, where)

			node += "where"
			node["where"] = where

		return i


//delete_query:	'DELETE' select_list [('FROM' | 'IN') from_list] ['WHERE' bool_expression]
	delete_query(i, list/node)
		var/list/select = list()
		i = select_list(i + 1, select)

		node += "delete"
		node["delete"] = select

		var/list/from = list()
		if(tokenl(i) in list("from", "in"))
			i = from_list(i + 1, from)
		else
			from += "world"

		node += "from"
		node["from"] = from

		if(tokenl(i) == "where")
			var/list/where = list()
			i = bool_expression(i + 1, where)

			node += "where"
			node["where"] = where

		return i


//update_query:	'UPDATE' select_list [('FROM' | 'IN') from_list] 'SET' assignments ['WHERE' bool_expression]
	update_query(i, list/node)
		var/list/select = list()
		i = select_list(i + 1, select)

		node += "update"
		node["update"] = select

		var/list/from = list()
		if(tokenl(i) in list("from", "in"))
			i = from_list(i + 1, from)
		else
			from += "world"

		node += "from"
		node["from"] = from

		if(tokenl(i) != "set")
			i = parse_error("UPDATE has misplaced SET")

		var/list/set_assignments = list()
		i = assignments(i + 1, set_assignments)

		node += "set"
		node["set"] = set_assignments

		if(tokenl(i) == "where")
			var/list/where = list()
			i = bool_expression(i + 1, where)

			node += "where"
			node["where"] = where

		return i


//call_query:	'CALL' call_function ['ON' select_list [('FROM' | 'IN') from_list] ['WHERE' bool_expression]]
	call_query(i, list/node)
		var/list/func = list()
		i = call_function(i + 1, func)

		node += "call"
		node["call"] = func

		if(tokenl(i) != "on")
			return i

		var/list/select = list()
		i = select_list(i + 1, select)

		node += "on"
		node["on"] = select

		var/list/from = list()
		if(tokenl(i) in list("from", "in"))
			i = from_list(i + 1, from)
		else
			from += "world"

		node += "from"
		node["from"] = from

		if(tokenl(i) == "where")
			var/list/where = list()
			i = bool_expression(i + 1, where)

			node += "where"
			node["where"] = where

		return i


//select_list:	select_item [',' select_list]
	select_list(i, list/node)
		i = select_item(i, node)

		if(token(i) == ",")
			i = select_list(i + 1, node)

		return i


//from_list:	from_item [',' from_list]
	from_list(i, list/node)
		i = from_item(i, node)

		if(token(i) == ",")
			i = from_list(i + 1, node)

		return i


//assignments:	assignment, [',' assignments]
	assignments(i, list/node)
		i = assignment(i, node)

		if(token(i) == ",")
			i = assignments(i + 1, node)

		return i


//select_item:	'*' | select_function | object_type
	select_item(i, list/node)

		if(token(i) == "*")
			node += "*"
			i++

		else if(tokenl(i) in select_functions)
			i = select_function(i, node)

		else
			i = object_type(i, node)

		return i


//from_item:	'world' | object_type
	from_item(i, list/node)

		if(token(i) == "world")
			node += "world"
			i++

		else
			i = object_type(i, node)

		return i


//bool_expression:	expression [bool_operator bool_expression]
	bool_expression(i, list/node)

		var/list/bool = list()
		i = expression(i, bool)

		node[++node.len] = bool

		if(tokenl(i) in boolean_operators)
			i = bool_operator(i, node)
			i = bool_expression(i, node)

		return i


//assignment:	<variable name> '=' expression
	assignment(i, list/node)

		node += token(i)

		if(token(i + 1) == "=")
			var/varname = token(i)
			node[varname] = list()

			i = expression(i + 2, node[varname])

		else
			parse_error("Assignment expected, but no = found")

		return i


//variable:	<variable name> | <variable name> '.' variable
	variable(i, list/node)
		var/list/L = list(token(i))
		node[++node.len] = L

		if(token(i + 1) == ".")
			L += "."
			i = variable(i + 2, L)

		else
			i++

		return i


//object_type:	<type path> | string
	object_type(i, list/node)

		if(copytext(token(i), 1, 2) == "/")
			node += token(i)

		else
			i = string(i, node)

		return i + 1


//comparitor:	'=' | '==' | '!=' | '<>' | '<' | '<=' | '>' | '>='
	comparitor(i, list/node)

		if(token(i) in list("=", "==", "!=", "<>", "<", "<=", ">", ">="))
			node += token(i)

		else
			parse_error("Unknown comparitor [token(i)]")

		return i + 1


//bool_operator:	'AND' | '&&' | 'OR' | '||'
	bool_operator(i, list/node)

		if(tokenl(i) in list("and", "or", "&&", "||"))
			node += token(i)

		else
			parse_error("Unknown comparitor [token(i)]")

		return i + 1


//string:	''' <some text> ''' | '"' <some text > '"'
	string(i, list/node)

		if(copytext(token(i), 1, 2) in list("'", "\""))
			node += token(i)

		else
			parse_error("Expected string but found '[token(i)]'")

		return i + 1


//call_function:	<function name> ['(' [arguments] ')']
	call_function(i, list/node)

		parse_error("Sorry, function calls aren't available yet")

		return i


//select_function:	count_function
	select_function(i, list/node)

		parse_error("Sorry, function calls aren't available yet")

		return i


//expression:	( unary_expression | '(' expression ')' | value ) [binary_operator expression]
	expression(i, list/node)

		if(token(i) in unary_operators)
			i = unary_expression(i, node)

		else if(token(i) == "(")
			var/list/expr = list()

			i = expression(i + 1, expr)

			if(token(i) != ")")
				parse_error("Missing ) at end of expression.")

			else
				i++

			node[++node.len] = expr

		else
			i = value(i, node)

		if(token(i) in binary_operators)
			i = binary_operator(i, node)
			i = expression(i, node)

		else if(token(i) in comparitors)
			i = binary_operator(i, node)

			var/list/rhs = list()
			i = expression(i, rhs)

			node[++node.len] = rhs


		return i


//unary_expression:	unary_operator ( unary_expression | value | '(' expression ')' )
	unary_expression(i, list/node)

		if(token(i) in unary_operators)
			var/list/unary_exp = list()

			unary_exp += token(i)
			i++

			if(token(i) in unary_operators)
				i = unary_expression(i, unary_exp)

			else if(token(i) == "(")
				var/list/expr = list()

				i = expression(i + 1, expr)

				if(token(i) != ")")
					parse_error("Missing ) at end of expression.")

				else
					i++

				unary_exp[++unary_exp.len] = expr

			else
				i = value(i, unary_exp)

			node[++node.len] = unary_exp


		else
			parse_error("Expected unary operator but found '[token(i)]'")

		return i


//binary_operator:	comparitor | '+' | '-' | '/' | '*' | '&' | '|' | '^'
	binary_operator(i, list/node)

		if(token(i) in (binary_operators + comparitors))
			node += token(i)

		else
			parse_error("Unknown binary operator [token(i)]")

		return i + 1


//value:	variable | string | number | 'null'
	value(i, list/node)

		if(token(i) == "null")
			node += "null"
			i++

		else if(isnum(text2num(token(i))))
			node += text2num(token(i))
			i++

		else if(copytext(token(i), 1, 2) in list("'", "\""))
			i = string(i, node)

		else
			i = variable(i, node)

		return i




/*EXPLAIN SELECT * WHERE 42 = 6 * 9 OR val = - 5 == 7*/