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
	to_chat(usr, "<span class='danger'>SQDL2 Parsing Error: [error_message]</span>")
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


//query:	select_query | delete_query | update_query
/datum/SDQL_parser/proc/query(i, list/node)
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
/datum/SDQL_parser/proc/select_query(i, list/node)
	var/list/select = list()
	i = select_list(i + 1, select)
	node += "select"
	node["select"] = select
	selectors(i, node)
	return i

//delete_query:	'DELETE' select_list [('FROM' | 'IN') from_list] ['WHERE' bool_expression]
/datum/SDQL_parser/proc/delete_query(i, list/node)
	var/list/select = list()
	i = select_list(i + 1, select)
	node += "delete"
	node["delete"] = select
	selectors(i, node)
	return i

//update_query:	'UPDATE' select_list [('FROM' | 'IN') from_list] 'SET' assignments ['WHERE' bool_expression]
/datum/SDQL_parser/proc/update_query(i, list/node)
	var/list/select = list()
	i = select_list(i + 1, select)
	node += "update"
	node["update"] = select
	if(tokenl(i) != "set")
		i = parse_error("UPDATE has misplaced SET")
	var/list/set_assignments = list()
	i = assignments(i + 1, set_assignments)
	node += "set"
	node["set"] = set_assignments
	selectors(i, node)
	return i

//call_query:	'CALL' call_function ['ON' select_list [('FROM' | 'IN') from_list] ['WHERE' bool_expression]]
/datum/SDQL_parser/proc/call_query(i, list/node)
	var/list/func = list()
	i = variable(i + 1, func) // Yes technically does anything variable() matches but I don't care, if admins fuck up this badly then they shouldn't be allowed near SDQL.
	node += "call"
	node["call"] = func
	if(tokenl(i) != "on")
		return i
	var/list/select = list()
	i = select_list(i + 1, select)
	node += "on"
	node["on"] = select
	selectors(i, node)
	return i

//select_list:	select_item [',' select_list]
/datum/SDQL_parser/proc/select_list(i, list/node)
	i = select_item(i, node)
	if(token(i) == ",")
		i = select_list(i + 1, node)
	return i

//assignments:	assignment, [',' assignments]
/datum/SDQL_parser/proc/assignments(i, list/node)
	i = assignment(i, node)
	if(token(i) == ",")
		i = assignments(i + 1, node)
	return i

//select_item:	'*' | select_function | object_type
/datum/SDQL_parser/proc/select_item(i, list/node)
	if(token(i) == "*")
		node += "*"
		i++
	else if(tokenl(i) in select_functions)
		i = select_function(i, node)
	else
		i = object_type(i, node)
	return i

// Standardized method for handling the IN/FROM and WHERE options.
/datum/SDQL_parser/proc/selectors(i, list/node)
	while (token(i))
		var/tok = tokenl(i)
		if(tok in list("from", "in"))
			var/list/from = list()
			i = from_item(i + 1, from)
			node["from"] = from
			continue
		if(tok == "where")
			var/list/where = list()
			i = bool_expression(i + 1, where)
			node["where"] = where
			continue
		parse_error("Expected either FROM, IN or WHERE token, found [token(i)] instead.")
		return i + 1
	if(!node.Find("from"))
		node["from"] = list("world")
	return i

//from_item:	'world' | object_type
/datum/SDQL_parser/proc/from_item(i, list/node)
	if(token(i) == "world")
		node += "world"
		i++
	else
		i = expression(i, node)
	return i

//bool_expression:	expression [bool_operator bool_expression]
/datum/SDQL_parser/proc/bool_expression(i, list/node)
	var/list/bool = list()
	i = expression(i, bool)
	node[++node.len] = bool
	if(tokenl(i) in boolean_operators)
		i = bool_operator(i, node)
		i = bool_expression(i, node)
	return i

//assignment:	<variable name> '=' expression
/datum/SDQL_parser/proc/assignment(var/i, var/list/node, var/list/assignment_list = list())
	assignment_list += token(i)
	if(token(i + 1) == ".")
		i = assignment(i + 2, node, assignment_list)
	else if(token(i + 1) == "=")
		var/exp_list = list()
		node[assignment_list] = exp_list
		i = expression(i + 2, exp_list)
	else
		parse_error("Assignment expected, but no = found")
	return i

//variable:	<variable name> | <variable name> '.' variable
/datum/SDQL_parser/proc/variable(i, list/node)
	var/list/L = list(token(i))
	node[++node.len] = L
	if(token(i) == "{")
		L += token(i+1)
		i += 2
		if(token(i) != "}")
			parse_error("Missing } at end of pointer.")
	if(token(i + 1) == ".")
		L += "."
		i = variable(i + 2, L)
	else if(token(i + 1) == "(") // OH BOY PROC
		var/list/arguments = list()
		i = call_function(i, null, arguments)
		L += ":"
		L[++L.len] = arguments
	else if(token(i + 1) == "\[")
		var/list/expression = list()
		i = expression(i + 2, expression)
		if (token(i) != "]")
			parse_error("Missing ] at the end of list access.")
		L += "\["
		L[++L.len] = expression
		i++
	else
		i++
	return i

//array:	'[' expression, expression, ... ']'
/datum/SDQL_parser/proc/array(i, list/node)
	if(copytext(token(i), 1, 2) != "\[")
		parse_error("Expected an array but found '[token(i)]'")
		return i + 1
	node += token(i)
	var/list/expression_list = list()
	i++
	if(token(i) != "]")
		var/list/temp_expression_list = list()
		var/tok
		do
			tok = token(i)
			if(tok == "," || tok == ":")
				if(temp_expression_list == null)
					parse_error("Found ',' or ':' without expression in an array.")
					return i + 1
				expression_list[++expression_list.len] = temp_expression_list
				temp_expression_list = null
				if(tok == ":")
					temp_expression_list = list()
					i = expression(i + 1, temp_expression_list)
					expression_list[expression_list[expression_list.len]] = temp_expression_list
					temp_expression_list = null
					tok = token(i)
					if(tok != ",")
						if(tok == "]")
							break
						parse_error("Expected ',' or ']' after array assoc value, but found '[token(i)]'")
						return i
 				i++
 				continue
			temp_expression_list = list()
			i = expression(i, temp_expression_list)
		while(token(i) && token(i) != "]")
		if(temp_expression_list)
			expression_list[++expression_list.len] = temp_expression_list
	node[++node.len] = expression_list
	return i + 1

//object_type:	<type path> | string
/datum/SDQL_parser/proc/object_type(i, list/node)
	if(copytext(token(i), 1, 2) == "/")
		node += token(i)
	else
		i = string(i, node)
	return i + 1

//comparitor:	'=' | '==' | '!=' | '<>' | '<' | '<=' | '>' | '>='
/datum/SDQL_parser/proc/comparitor(i, list/node)
	if(token(i) in list("=", "==", "!=", "<>", "<", "<=", ">", ">="))
		node += token(i)
	else
		parse_error("Unknown comparitor [token(i)]")
	return i + 1

//bool_operator:	'AND' | '&&' | 'OR' | '||'
/datum/SDQL_parser/proc/bool_operator(i, list/node)
	if(tokenl(i) in list("and", "or", "&&", "||"))
		node += token(i)
	else
		parse_error("Unknown comparitor [token(i)]")
	return i + 1

//string:	''' <some text> ''' | '"' <some text > '"'
/datum/SDQL_parser/proc/string(i, list/node)
	if(copytext(token(i), 1, 2) in list("'", "\""))
		node += token(i)
	else
		parse_error("Expected string but found '[token(i)]'")
	return i + 1

//call_function:	<function name> ['(' [arguments] ')']
/datum/SDQL_parser/proc/call_function(i, list/node, list/arguments)
	if(length(tokenl(i)))
		var/procname = ""
		if(token(i) == "global" && token(i+1) == ".")
			i += 2
			procname = "global."
		node += procname + token(i++)
		if(token(i) != "(")
			parse_error("Expected ( but found '[token(i)]'")
		else if(token(i + 1) != ")")
			var/list/expression_list_temp = list()
			do
				i = expression(i + 1, expression_list_temp)
				if(token(i) == ",")
					arguments[++arguments.len] = expression_list_temp
					expression_list_temp = list()
					continue
			while(token(i) && token(i) != ")")
			arguments[++arguments.len] = expression_list_temp
		else
			i++
	else
		parse_error("Expected a function but found nothing")
	return i + 1

//select_function:	count_function
/datum/SDQL_parser/proc/select_function(i, list/node)
	parse_error("Sorry, function calls aren't available yet")
	return i

//expression:	( unary_expression | '(' expression ')' | value ) [binary_operator expression]
/datum/SDQL_parser/proc/expression(i, list/node)
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
/datum/SDQL_parser/proc/unary_expression(i, list/node)
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
/datum/SDQL_parser/proc/binary_operator(i, list/node)
	if(token(i) in (binary_operators + comparitors))
		node += token(i)
	else
		parse_error("Unknown binary operator [token(i)]")
	return i + 1

//value:	variable | string | number | 'null'
/datum/SDQL_parser/proc/value(i, list/node)
	if(token(i) == "null")
		node += "null"
		i++
	else if(lowertext(copytext(token(i),1,3)) == "0x" && isnum(hex2num(copytext(token(i),3))))
		node += hex2num(copytext(token(i),3))
		i++
	else if(isnum(text2num(token(i))))
		node += text2num(token(i))
		i++
	else if(copytext(token(i), 1, 2) in list("'", "\""))
		i = string(i, node)
	else if(copytext(token(i), 1, 2) == "\[") // Start a list.
		i = array(i, node)
	else
		i = variable(i, node)
	return i

/*EXPLAIN SELECT * WHERE 42 = 6 * 9 OR val = - 5 == 7*/
