// Code taken from /bay/station.

// Examples
/*
	-- Will call the proc for all computers in the world, thats dir is 2.
	CALL ex_act(1) ON /obj/machinery/computer IN world WHERE dir == 2
	-- Will open a window with a list of all the closets in the world, with a link to VV them.
	SELECT /obj/structure/closet/secure_closet/security/cargo IN world WHERE icon_off == "secoff"
	-- Will change all the tube lights to green, and flicker them. The semicolon is important to separate the consecutive querys, but is not required for standard one-query use.
	UPDATE /obj/machinery/light SET color = "#0F0" WHERE icon_state == "tube1"; CALL flicker(1) ON /obj/machinery/light
	-- Will delete all pickaxes. "IN world" is not required.
	DELETE /obj/item/weapon/pickaxe

	--You can use operators other than ==, such as >, <=, != and etc..

	--Lists can be done through [], so say UPDATE /mob SET client.color = [1, 0.75, ...].
*/

// Used by update statements, this is to handle shit like preventing editing the /datum/admins though SDQL but WITHOUT +PERMISSIONS.
// Assumes the variable actually exists.
/datum/proc/SDQL_update(var/const/var_name, var/new_value)
	vars[var_name] = new_value
	return 1

// Because /client isn't a subtype of /datum...
/client/proc/SDQL_update(var/const/var_name, var/new_value)
	vars[var_name] = new_value
	return 1

/client/proc/SDQL2_query(var/query_text as message)
	set category = "Debug"

	if(!check_rights(R_DEBUG))  // Shouldn't happen... but just to be safe.
		message_admins("<span class='warning'>ERROR: Non-admin [usr.key] attempted to execute the following SDQL query: [query_text]</span>")
		log_admin("Non-admin [usr.key] attempted to execute the following SDQL query: [query_text]!")
		return

	if(!query_text || length(query_text) < 1)
		return

	var/query_log = "[key_name(src)] executed SDQL query: \"[query_text]\"."
	world.log << query_log
	message_admins(query_log)
	log_game(query_log)
	sleep(-1) // Incase the server crashes due to a huge query, we allow the server to log the above things (it might just delay it).

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

				else if(char == "'" || char == "\"")
					objs += locate(copytext(type, 2, length(type)))

			if("where" in query_tree)
				var/objs_temp = objs
				objs = list()
				for(var/datum/d in objs_temp)
					if(SDQL_expression(d, query_tree["where"]))
						objs += d

			switch(query_tree[1])
				if("call")
					for(var/datum/d in objs)
						SDQL_var(d, query_tree["call"][1], source = d)

				if("delete")
					for(var/datum/d in objs)
						qdel(d)

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
										if(istype(temp, /turf) && (v == "x" || v == "y" || v == "z"))
											break

										temp.SDQL_update(v, SDQL_expression(d, set_list[sets]))
										break

									if(temp.vars.Find(v) && (istype(temp.vars[v], /datum) || istype(temp.vars[v], /client)))
										temp = temp.vars[v]

									else
										break

	catch(var/exception/e)
		to_chat(usr, "<span class='danger'>An exception has occured during the execution of your query and your query has been aborted.</span>")
		to_chat(usr, "exception name: [e.name]")
		to_chat(usr, "file/line: [e.file]/[e.line]")
		return

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
				to_chat(usr, "<span class='danger'>Parsing error on [querys_pos]\th query. Nothing was executed.</span>")
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
		spaces += "&nbsp;&nbsp;&nbsp;&nbsp;"

	for(var/item in query_tree)
		if(istype(item, /list))
			to_chat(usr, "[spaces](")
			SDQL_testout(item, indent + 1)
			to_chat(usr, "[spaces])")

		else
			to_chat(usr, "[spaces][item]")

		if(!isnum(item) && query_tree[item])

			if(istype(query_tree[item], /list))
				to_chat(usr, "[spaces]&nbsp;&nbsp;&nbsp;&nbsp;(")
				SDQL_testout(query_tree[item], indent + 2)
				to_chat(usr, "[spaces]&nbsp;&nbsp;&nbsp;&nbsp;)")

			else
				to_chat(usr, "[spaces]&nbsp;&nbsp;&nbsp;&nbsp;[query_tree[item]]")

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

	if(ispath(type, /mob))
		for(var/mob/d in location)
			if(istype(d, type))
				out += d

	else if(ispath(type, /turf))
		for(var/turf/d in location)
			if(istype(d, type))
				out += d

	else if(ispath(type, /obj))
		for(var/obj/d in location)
			if(istype(d, type))
				out += d

	else if(ispath(type, /area))
		for(var/area/d in location)
			if(istype(d, type))
				out += d

	else if(ispath(type, /atom))
		for(var/atom/d in location)
			if(istype(d, type))
				out += d

	else
		for(var/datum/d in location)
			if(istype(d, type))
				out += d

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
					result += val
				if("-")
					result -= val
				if("*")
					result *= val
				if("/")
					result /= val
				if("&")
					result &= val
				if("|")
					result |= val
				if("^")
					result ^= val
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
					to_chat(usr, "<span class='warning'>SDQL2: Unknown op [op]</span>")
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
		val = list()
		for(var/list/expression_list in expressions_list)
			val += SDQL_expression(object, expression_list)

	else
		val = SDQL_var(object, expression, i, object)
		i = expression.len

	return list("val" = val, "i" = i)

/proc/SDQL_var(datum/object, list/expression, start = 1, source)
	var/v

	var/long = start < expression.len

	if (object == world && long && expression[start + 1] == ".")
		to_chat(usr, "Sorry, but global variables are not supported at the moment.")
		return null

	if (expression [start] == "{" && long)
		if (lowertext(copytext(expression[start + 1], 1, 3)) != "0x")
			to_chat(usr, "<span class='danger'>Invalid pointer syntax: [expression[start + 1]]</span>")
			return null
		v = locate("\[[expression[start + 1]]]")
		if (!v)
			to_chat(usr, "<span class='danger'>Invalid pointer: [expression[start + 1]]</span>")
			return null
		start++

	else if ((!long || expression[start + 1] == ".") && (expression[start] in object.vars))
		v = object.vars[expression[start]]

	else if (long && expression[start + 1] == ":" && hascall(object, expression[start]))
		v = expression[start]

	else if (!long || expression[start + 1] == ".")
		switch(expression[start])
			if("usr")
				v = usr
			if("src")
				v = source
			if("marked")
				if(usr.client && usr.client.holder && usr.client.holder.marked_datum)
					v = usr.client.holder.marked_datum
				else
					return null
			if("global")
				v = world // World is mostly a token, really.
			else
				return null

	else if (object == world) // Shitty ass hack kill me.
		v = expression[start]

	if(long)
		if (expression[start + 1] == ".")
			return SDQL_var(v, expression[start + 2], source = source)

		else if (expression[start + 1] == ":")
			return SDQL_function(object, v, expression[start + 2], source)

		else if (expression[start + 1] == "\[" && islist(v))
			var/list/L = v
			var/index = SDQL_expression(source, expression[start + 2])
			if (isnum(index) && (!IsInteger(index) || L.len < index))
				to_chat(world, "<span class='danger'>Invalid list index: [index]</span>")
				return null

			return L[index]

	return v


/proc/SDQL_function(var/datum/object, var/procname, var/list/arguments, source)
	set waitfor = FALSE

	var/list/new_args = list()
	for(var/arg in arguments)
		new_args[++new_args.len] = SDQL_expression(source, arg)

	if (object == world) // Global proc.
		procname = "/proc/[procname]"
		return call(procname)(arglist(new_args))

	return call(object, procname)(arglist(new_args)) // Spawn in case the function sleeps.


/proc/SDQL2_tokenize(query_text)


	var/list/whitespace = list(" ", "\n", "\t")
	var/list/single = list("(", ")", ",", "+", "-", ".", "\[", "]", "{", "}", ";")
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
				to_chat(usr, "<span class='warning'>SDQL2: You have an error in your SDQL syntax, unexpected ' in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.</span>")
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
				to_chat(usr, "<span class='warning'>SDQL2: You have an error in your SDQL syntax, unmatched ' in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.</span>")
				return null

			query_list += "[word]'"
			word = ""

		else if(char == "\"")
			if(word != "")
				to_chat(usr, "<span class='warning'>SDQL2: You have an error in your SDQL syntax, unexpected \" in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.</span>")
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
				to_chat(usr, "<span class='warning'>SDQL2: You have an error in your SDQL syntax, unmatched \" in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.</span>")
				return null

			query_list += "[word]\""
			word = ""

		else
			word += char

	if(word != "")
		query_list += word
	return query_list
