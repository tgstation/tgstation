// Code taken from /bay/station.
// Modified to allow consequtive querys in one invocation, terminated with ";"

// Examples
/*
	-- Will call the proc for all computers in the world, thats dir is 2.
	CALL ex_act(EXPLODE_DEVASTATE) ON /obj/machinery/computer IN world WHERE dir == 2
	-- Will open a window with a list of all the closets in the world, with a link to VV them.
	SELECT /obj/structure/closet/secure_closet/security/cargo IN world WHERE icon_off == "secoff"
	-- Will change all the tube lights to green
	UPDATE /obj/machinery/light IN world SET color = "#0F0" WHERE icon_state == "tube1"
	-- Will delete all pickaxes. "IN world" is not required.
	DELETE /obj/item/pickaxe
	-- Will flicker the lights once, then turn all mobs green. The semicolon is important to separate the consecutive querys, but is not required for standard one-query use
	CALL flicker(1) ON /obj/machinery/light; UPDATE /mob SET color = "#00cc00"

	--You can use operators other than ==, such as >, <=, != and etc..

*/

/client/proc/SDQL2_query(query_text as message)
	set category = "Debug"
	if(!check_rights(R_DEBUG))  //Shouldn't happen... but just to be safe.
		message_admins("<span class='danger'>ERROR: Non-admin [key_name(usr)] attempted to execute a SDQL query!</span>")
		log_admin("Non-admin [key_name(usr)] attempted to execute a SDQL query!")
		return FALSE
	var/list/results = world.SDQL2_query(query_text, key_name_admin(usr), "[key_name(usr)]")
	for(var/I in 1 to 3)
		to_chat(usr, results[I])
	SSblackbox.record_feedback("nested tally", "SDQL query", 1, list(ckey, query_text))

/world/proc/SDQL2_query(query_text, log_entry1, log_entry2)
	var/query_log = "executed SDQL query: \"[query_text]\"."
	message_admins("[log_entry1] [query_log]")
	query_log = "[log_entry2] [query_log]"
	log_game(query_log)
	NOTICE(query_log)
	var/objs_all = 0
	var/objs_eligible = 0
	var/start_time = REALTIMEOFDAY

	if(!query_text || length(query_text) < 1)
		return


	var/list/query_list = SDQL2_tokenize(query_text)

	if(!query_list || query_list.len < 1)
		return

	var/list/querys = SDQL_parse(query_list)


	if(!querys || querys.len < 1)
		return

	var/list/refs = list()
	var/where_used = FALSE
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

		from_objs = world.SDQL_from_objs(query_tree["from"])

		var/list/objs = list()

		for(var/type in select_types)
			objs += SDQL_get_all(type, from_objs)
			CHECK_TICK
		objs_all = objs.len

		if("where" in query_tree)
			where_used = TRUE
			var/objs_temp = objs
			objs = list()
			for(var/datum/d in objs_temp)
				if(SDQL_expression(d, query_tree["where"]))
					objs += d
					objs_eligible++
				CHECK_TICK

		switch(query_tree[1])
			if("call")
				for(var/datum/d in objs)
					world.SDQL_var(d, query_tree["call"][1], source = d)
					CHECK_TICK

			if("delete")
				for(var/datum/d in objs)
					SDQL_qdel_datum(d)
					CHECK_TICK

			if("select")
				var/text = ""
				for(var/datum/t in objs)
					text += SDQL_gen_vv_href(t)
					refs[REF(t)] = TRUE
					CHECK_TICK
				usr << browse(text, "window=SDQL-result")

			if("update")
				if("set" in query_tree)
					var/list/set_list = query_tree["set"]
					for(var/datum/d in objs)
						SDQL_internal_vv(d, set_list)
						CHECK_TICK

	var/end_time = REALTIMEOFDAY
	end_time -= start_time
	return list("<span class='admin'>SDQL query results: [query_text]</span>",\
		"<span class='admin'>SDQL query completed: [objs_all] objects selected by path, and [where_used ? objs_eligible : objs_all] objects executed on after WHERE filtering if applicable.</span>",\
		"<span class='admin'>SDQL query took [DisplayTimeText(end_time)] to complete.</span>") + refs

/proc/SDQL_qdel_datum(datum/d)
	qdel(d)

/proc/SDQL_gen_vv_href(t)
	var/text = ""
	text += "<A HREF='?_src_=vars;[HrefToken()];Vars=[REF(t)]'>[REF(t)]</A>"
	if(istype(t, /atom))
		var/atom/a = t
		var/turf/T = a.loc
		var/turf/actual = get_turf(a)
		if(istype(T))
			text += ": [t] <font color='gray'>at turf</font> [T] [ADMIN_COORDJMP(T)]<br>"
		else if(a.loc && istype(actual))
			text += ": [t] <font color='gray'>in</font> [a.loc] <font color='gray'>at turf</font> [actual] [ADMIN_COORDJMP(actual)]<br>"
		else
			text += ": [t]<br>"
	else
		text += ": [t]<br>"
	return text

/proc/SDQL_internal_vv(d, list/set_list)
	for(var/list/sets in set_list)
		var/datum/temp = d
		var/i = 0
		for(var/v in sets)
			if(++i == sets.len)
				temp.vv_edit_var(v, SDQL_expression(d, set_list[sets]))
				break
			if(temp.vars.Find(v) && (istype(temp.vars[v], /datum)))
				temp = temp.vars[v]
			else
				break

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
	var/static/whitespace = "&nbsp;&nbsp;&nbsp; "
	var/spaces = ""
	for(var/s = 0, s < indent, s++)
		spaces += whitespace

	for(var/item in query_tree)
		if(istype(item, /list))
			to_chat(usr, "[spaces](")
			SDQL_testout(item, indent + 1)
			to_chat(usr, "[spaces])")

		else
			to_chat(usr, "[spaces][item]")

		if(!isnum(item) && query_tree[item])

			if(istype(query_tree[item], /list))
				to_chat(usr, "[spaces][whitespace](")
				SDQL_testout(query_tree[item], indent + 2)
				to_chat(usr, "[spaces][whitespace])")

			else
				to_chat(usr, "[spaces][whitespace][query_tree[item]]")



/world/proc/SDQL_from_objs(list/tree)
	if("world" in tree)
		return src
	return SDQL_expression(src, tree)

/proc/SDQL_get_all(type, location)
	var/list/out = list()

// If only a single object got returned, wrap it into a list so the for loops run on it.
	if(!islist(location) && location != world)
		location = list(location)

	type = text2path(type)
	var/typecache = typecacheof(type)

	if(ispath(type, /mob))
		for(var/mob/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK

	else if(ispath(type, /turf))
		for(var/turf/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK

	else if(ispath(type, /obj))
		for(var/obj/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK

	else if(ispath(type, /area))
		for(var/area/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK

	else if(ispath(type, /atom))
		for(var/atom/d in location)
			if(typecache[d.type] && d.can_vv_get())
				out += d
			CHECK_TICK
	else if(ispath(type, /datum))
		if(location == world) //snowflake for byond shortcut
			for(var/datum/d) //stupid byond trick to have it not return atoms to make this less laggy
				if(typecache[d.type] && d.can_vv_get())
					out += d
				CHECK_TICK
		else
			for(var/datum/d in location)
				if(typecache[d.type] && d.can_vv_get())
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
					to_chat(usr, "<span class='danger'>SDQL2: Unknown op [op]</span>")
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
			var/result = SDQL_expression(object, expression_list)
			var/assoc
			if(expressions_list[expression_list] != null)
				assoc = SDQL_expression(object, expressions_list[expression_list])
			if(assoc != null)
				// Need to insert the key like this to prevent duplicate keys fucking up.
				var/list/dummy = list()
				dummy[result] = assoc
				result = dummy
			val += result
	else
		val = world.SDQL_var(object, expression, i, object)
		i = expression.len

	return list("val" = val, "i" = i)

/world/proc/SDQL_var(datum/object, list/expression, start = 1, source)
	var/v
	var/long = start < expression.len
	if(object == world && long && expression[start + 1] == ".")
		to_chat(usr, "Sorry, but world variables are not supported at the moment.")
		return null
	else if(expression [start] == "{" && long)
		if(lowertext(copytext(expression[start + 1], 1, 3)) != "0x")
			to_chat(usr, "<span class='danger'>Invalid pointer syntax: [expression[start + 1]]</span>")
			return null
		v = locate("\[[expression[start + 1]]]")
		if(!v)
			to_chat(usr, "<span class='danger'>Invalid pointer: [expression[start + 1]]</span>")
			return null
		start++
	else if((!long || expression[start + 1] == ".") && (expression[start] in object.vars))
		if(object.can_vv_get(expression[start]))
			v = object.vars[expression[start]]
		else
			v = "SECRET"
	else if(long && expression[start + 1] == ":" && hascall(object, expression[start]))
		v = expression[start]
	else if(!long || expression[start + 1] == ".")
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
			if("world")
				v = world
			if("global")
				v = GLOB
			else
				return null
	else if(object == GLOB) // Shitty ass hack kill me.
		v = expression[start]
	if(long)
		if(expression[start + 1] == ".")
			return SDQL_var(v, expression[start + 2], source = source)
		else if(expression[start + 1] == ":")
			return SDQL_function(object, v, expression[start + 2], source)
		else if(expression[start + 1] == "\[" && islist(v))
			var/list/L = v
			var/index = SDQL_expression(source, expression[start + 2])
			if(isnum(index) && (!ISINTEGER(index) || L.len < index))
				to_chat(usr, "<span class='danger'>Invalid list index: [index]</span>")
				return null
			return L[index]
	return v

/proc/SDQL_function(var/datum/object, var/procname, var/list/arguments, source)
	set waitfor = FALSE
	var/list/new_args = list()
	for(var/arg in arguments)
		new_args += SDQL_expression(source, arg)
	if(object == GLOB) // Global proc.
		procname = "/proc/[procname]"
		return WrapAdminProcCall(GLOBAL_PROC, procname, new_args)
	return WrapAdminProcCall(object, procname, new_args)

/proc/SDQL2_tokenize(query_text)

	var/list/whitespace = list(" ", "\n", "\t")
	var/list/single = list("(", ")", ",", "+", "-", ".", ";", "{", "}", "\[", "]", ":")
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
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unexpected ' in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.")
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
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unmatched ' in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.")
				return null

			query_list += "[word]'"
			word = ""

		else if(char == "\"")
			if(word != "")
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unexpected \" in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.")
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
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unmatched \" in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.")
				return null

			query_list += "[word]\""
			word = ""

		else
			word += char

	if(word != "")
		query_list += word
	return query_list
