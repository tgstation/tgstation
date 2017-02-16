// Code taken from /bay/station.
// Modified to allow consequtive querys in one invocation, terminated with ";"

// Examples
/*
	-- Will call the proc for all computers in the world, thats dir is 2.
	CALL ex_act(1) ON /obj/machinery/computer IN world WHERE dir == 2
	-- Will open a window with a list of all the closets in the world, with a link to VV them.
	SELECT /obj/structure/closet/secure_closet/security/cargo IN world WHERE icon_off == "secoff"
	-- Will change all the tube lights to green
	UPDATE /obj/machinery/light IN world SET color = "#0F0" WHERE icon_state == "tube1"
	-- Will delete all pickaxes. "IN world" is not required.
	DELETE /obj/item/weapon/pickaxe
	-- Will flicker the lights once, then turn all mobs green. The semicolon is important to separate the consecutive querys, but is not required for standard one-query use
	CALL flicker(1) ON /obj/machinery/light; UPDATE /mob SET color = "#00cc00"

	--You can use operators other than ==, such as >, <=, != and etc..

*/

/datum/proc/SDQL_update(const/var_name, new_value)
	vars[var_name] = new_value
	return TRUE

/client/proc/SDQL2_query(query_text as message)
	set category = "Debug"
	if(!check_rights(R_DEBUG))  //Shouldn't happen... but just to be safe.
		message_admins("<span class='danger'>ERROR: Non-admin [key_name(usr, usr.client)] attempted to execute a SDQL query!</span>")
		log_admin("Non-admin [usr.ckey]([usr]) attempted to execute a SDQL query!")
		return FALSE

	var/query_log = "executed SDQL query: \"[query_text]\"."
	message_admins("[key_name_admin(usr)] [query_log]")
	query_log = "[usr.ckey]([usr]) [query_log]"
	log_game(query_log)
	NOTICE(query_log)

	if(!query_text || length(query_text) < 1)
		return

	//world << query_text

	var/list/query_list = SDQL2_tokenize(query_text)

	if(!query_list || query_list.len < 1)
		return

	var/list/querys = SDQL_parse(query_list)

	if(!querys || querys.len < 1)
		return

	try

		for(var/list/query_tree in querys)
			var/list/from_objs = list()
			var/list/select_types = list()

			switch(query_tree[1])
				if("explain")
					SDQL_testout(query_tree["explain"])
					return

				if("call")
					if("on" in query_tree)
						select_types = query_tree["on"]
					else
						return

				if("select", "delete", "update")
					select_types = query_tree[query_tree[1]]

			from_objs = SDQL_from_objs(query_tree["from"])

			var/list/objs = list()

			for(var/type in select_types)
				var/char = copytext(type, 1, 2)

				if(char == "/" || char == "*")
					for(var/from in from_objs)
						objs += SDQL_get_all(type, from)
						CHECK_TICK

				else if(char == "'" || char == "\"")
					objs += locate(copytext(type, 2, length(type)))

			if("where" in query_tree)
				var/objs_temp = objs
				objs = list()
				for(var/datum/d in objs_temp)
					if(SDQL_expression(d, query_tree["where"]))
						objs += d
					CHECK_TICK

			switch(query_tree[1])
				if("call")
					var/list/call_list = query_tree["call"]
					var/list/args_list = query_tree["args"]

					for(var/datum/d in objs)
						var/list/new_args = list()
						for(var/a in args_list)
							new_args += SDQL_expression(d,a)
						for(var/v in call_list)
							if(copytext(v,1,8) == "global.")
								v = "/proc/[copytext(v,8)]"
								SDQL_callproc_global(v,new_args)
							else
								SDQL_callproc(d, v, new_args)
						CHECK_TICK

				if("delete")
					for(var/datum/d in objs)
						qdel(d)
						CHECK_TICK

				if("select")
					var/text = ""
					for(var/datum/t in objs)
						text += "<A HREF='?_src_=vars;Vars=\ref[t]'>\ref[t]</A>"
						if(istype(t, /atom))
							var/atom/a = t

							if(a.x)
								text += ": [t] at ([a.x], [a.y], [a.z])<br>"

							else if(a.loc && a.loc.x)
								text += ": [t] in [a.loc] at ([a.loc.x], [a.loc.y], [a.loc.z])<br>"

							else
								text += ": [t]<br>"

						else
							text += ": [t]<br>"
						CHECK_TICK

					usr << browse(text, "window=SDQL-result")

				if("update")
					if("set" in query_tree)
						var/list/set_list = query_tree["set"]
						for(var/datum/d in objs)
							for(var/list/sets in set_list)
								var/datum/temp = d
								var/i = 0
								for(var/v in sets)
									if(++i == sets.len)
										temp.SDQL_update(v, SDQL_expression(d, set_list[sets]))
										break
									if(temp.vars.Find(v) && (istype(temp.vars[v], /datum)))
										temp = temp.vars[v]
									else
										break
							CHECK_TICK

	catch(var/exception/e)
		usr << "<span class='boldwarning'>A runtime error has occured in your SDQL2-query.</span>"
		usr << "\[NAME\][e.name]"
		usr << "\[FILE\][e.file]"
		usr << "\[LINE\][e.line]"

/proc/SDQL_callproc_global(procname,args_list)
	set waitfor = FALSE
	call(procname)(arglist(args_list))

/proc/SDQL_callproc(thing, procname, args_list)
	set waitfor = FALSE
	if(hascall(thing, procname))
		call(thing, procname)(arglist(args_list))

/proc/SDQL_parse(list/query_list)
	var/datum/SDQL_parser/parser = new()
	var/list/querys = list()
	var/list/query_tree = list()
	var/pos = 1
	var/querys_pos = 1
	var/do_parse = 0

	for(var/val in query_list)
		if(val == ";")
			do_parse = 1
		else if(pos >= query_list.len)
			query_tree += val
			do_parse = 1

		if(do_parse)
			parser.query = query_tree
			var/list/parsed_tree
			parsed_tree = parser.parse()
			if(parsed_tree.len > 0)
				querys.len = querys_pos
				querys[querys_pos] = parsed_tree
				querys_pos++
			else //There was an error so don't run anything, and tell the user which query has errored.
				usr << "<span class='danger'>Parsing error on [querys_pos]\th query. Nothing was executed.</span>"
				return list()
			query_tree = list()
			do_parse = 0
		else
			query_tree += val
		pos++

	qdel(parser)

	return querys



/proc/SDQL_testout(list/query_tree, indent = 0)
	var/spaces = ""
	for(var/s = 0, s < indent, s++)
		spaces += "    "

	for(var/item in query_tree)
		if(istype(item, /list))
			usr << "[spaces]("
			SDQL_testout(item, indent + 1)
			usr << "[spaces])"

		else
			usr << "[spaces][item]"

		if(!isnum(item) && query_tree[item])

			if(istype(query_tree[item], /list))
				usr << "[spaces]    ("
				SDQL_testout(query_tree[item], indent + 2)
				usr << "[spaces]    )"

			else
				usr << "[spaces]    [query_tree[item]]"



/proc/SDQL_from_objs(list/tree)
	if("world" in tree)
		return list(world)

	var/list/out = list()

	for(var/type in tree)
		var/char = copytext(type, 1, 2)

		if(char == "/")
			out += SDQL_get_all(type, world)

		else if(char == "'" || char == "\"")
			out += locate(copytext(type, 2, length(type)))

	return out


/proc/SDQL_get_all(type, location)
	var/list/out = list()

	if(type == "*")
		for(var/datum/d in location)
			out += d

		return out

	type = text2path(type)
	var/typecache = typecacheof(type)

	if(ispath(type, /mob))
		for(var/mob/d in location)
			if(typecache[d.type])
				out += d
			CHECK_TICK

	else if(ispath(type, /turf))
		for(var/turf/d in location)
			if(typecache[d.type])
				out += d
			CHECK_TICK

	else if(ispath(type, /obj))
		for(var/obj/d in location)
			if(typecache[d.type])
				out += d
			CHECK_TICK

	else if(ispath(type, /area))
		for(var/area/d in location)
			if(typecache[d.type])
				out += d
			CHECK_TICK

	else if(ispath(type, /atom))
		for(var/atom/d in location)
			if(typecache[d.type])
				out += d
			CHECK_TICK
	else if(ispath(type, /datum))
		if(location == world) //snowflake for byond shortcut
			for(var/datum/d) //stupid byond trick to have it not return atoms to make this less laggy
				if(typecache[d.type])
					out += d
				CHECK_TICK
		else
			for(var/datum/d in location)
				if(typecache[d.type])
					out += d
				CHECK_TICK

	return out


/proc/SDQL_expression(datum/object, list/expression, start = 1)
	var/result = 0
	var/val

	for(var/i = start, i <= expression.len, i++)
		var/op = ""

		if(i > start)
			op = expression[i]
			i++

		var/list/ret = SDQL_value(object, expression, i)
		val = ret["val"]
		i = ret["i"]

		if(op != "")
			switch(op)
				if("+")
					result = (result + val)
				if("-")
					result = (result - val)
				if("*")
					result = (result * val)
				if("/")
					result = (result / val)
				if("&")
					result = (result & val)
				if("|")
					result = (result | val)
				if("^")
					result = (result ^ val)
				if("=", "==")
					result = (result == val)
				if("!=", "<>")
					result = (result != val)
				if("<")
					result = (result < val)
				if("<=")
					result = (result <= val)
				if(">")
					result = (result > val)
				if(">=")
					result = (result >= val)
				if("and", "&&")
					result = (result && val)
				if("or", "||")
					result = (result || val)
				else
					usr << "<span class='danger'>SDQL2: Unknown op [op]</span>"
					result = null
		else
			result = val

	return result

/proc/SDQL_value(datum/object, list/expression, start = 1)
	var/i = start
	var/val = null

	if(i > expression.len)
		return list("val" = null, "i" = i)

	if(istype(expression[i], /list))
		val = SDQL_expression(object, expression[i])

	else if(expression[i] == "!")
		var/list/ret = SDQL_value(object, expression, i + 1)
		val = !ret["val"]
		i = ret["i"]

	else if(expression[i] == "~")
		var/list/ret = SDQL_value(object, expression, i + 1)
		val = ~ret["val"]
		i = ret["i"]

	else if(expression[i] == "-")
		var/list/ret = SDQL_value(object, expression, i + 1)
		val = -ret["val"]
		i = ret["i"]

	else if(expression[i] == "null")
		val = null

	else if(isnum(expression[i]))
		val = expression[i]

	else if(copytext(expression[i], 1, 2) in list("'", "\""))
		val = copytext(expression[i], 2, length(expression[i]))

	else if(expression[i] == "\[")
		var/list/expressions_list = expression[++i]
		var/list/val2 = list()
		for(var/list/expression_list in expressions_list)
			val2[++val2.len] = SDQL_expression(object, expression_list)
		val = val2
	else
		val = SDQL_var(object, expression, i)
		i = expression.len

	return list("val" = val, "i" = i)

/proc/SDQL_var(datum/object, list/expression, start = 1)
	var/v
	if(expression[start] in object.vars)
		v = object.vars[expression[start]]
	else if(expression[start] == "{" && start < expression.len)
		if(lowertext(copytext(expression[start + 1], 1, 3)) != "0x")
			usr << "<span class='danger'>Invalid pointer syntax: [expression[start + 1]]</span>"
			return null
		v = locate("\[[expression[start + 1]]]")
		if(!v)
			usr << "<span class='danger'>Invalid pointer: [expression[start + 1]]</span>"
			return null
		start++
	else
		switch(expression[start])
			if("usr")
				v = usr
			if("src")
				v = object
			if("marked")
				if(usr.client && usr.client.holder && usr.client.holder.marked_datum)
					v = usr.client.holder.marked_datum
				else
					return null
			else
				return null
	if(start < expression.len && expression[start + 1] == ".")
		return SDQL_var(v, expression[start + 2])
	else
		return v

/proc/SDQL2_tokenize(query_text)

	var/list/whitespace = list(" ", "\n", "\t")
	var/list/single = list("(", ")", ",", "+", "-", ".", ";", "{", "}", "\[", "]")
	var/list/multi = list(
					"=" = list("", "="),
					"<" = list("", "=", ">"),
					">" = list("", "="),
					"!" = list("", "="))

	var/word = ""
	var/list/query_list = list()
	var/len = length(query_text)

	for(var/i = 1, i <= len, i++)
		var/char = copytext(query_text, i, i + 1)

		if(char in whitespace)
			if(word != "")
				query_list += word
				word = ""

		else if(char in single)
			if(word != "")
				query_list += word
				word = ""

			query_list += char

		else if(char in multi)
			if(word != "")
				query_list += word
				word = ""

			var/char2 = copytext(query_text, i + 1, i + 2)

			if(char2 in multi[char])
				query_list += "[char][char2]"
				i++

			else
				query_list += char

		else if(char == "'")
			if(word != "")
				usr << "\red SDQL2: You have an error in your SDQL syntax, unexpected ' in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again."
				return null

			word = "'"

			for(i++, i <= len, i++)
				char = copytext(query_text, i, i + 1)

				if(char == "'")
					if(copytext(query_text, i + 1, i + 2) == "'")
						word += "'"
						i++

					else
						break

				else
					word += char

			if(i > len)
				usr << "\red SDQL2: You have an error in your SDQL syntax, unmatched ' in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again."
				return null

			query_list += "[word]'"
			word = ""

		else if(char == "\"")
			if(word != "")
				usr << "\red SDQL2: You have an error in your SDQL syntax, unexpected \" in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again."
				return null

			word = "\""

			for(i++, i <= len, i++)
				char = copytext(query_text, i, i + 1)

				if(char == "\"")
					if(copytext(query_text, i + 1, i + 2) == "'")
						word += "\""
						i++

					else
						break

				else
					word += char

			if(i > len)
				usr << "\red SDQL2: You have an error in your SDQL syntax, unmatched \" in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again."
				return null

			query_list += "[word]\""
			word = ""

		else
			word += char

	if(word != "")
		query_list += word
	return query_list
