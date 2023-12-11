GLOBAL_LIST_INIT(sdql2_queries, GLOB.sdql2_queries || list())
GLOBAL_DATUM_INIT(sdql2_vv_statobj, /obj/effect/statclick/sdql2_vv_all, new(null, "VIEW VARIABLES (all)", null))

/datum/sdql2_query
	var/list/query_tree
	var/state = SDQL2_STATE_IDLE
	var/options = SDQL2_OPTIONS_DEFAULT
	var/superuser = FALSE //Run things like proccalls without using admin protections
	var/allow_admin_interact = TRUE //Allow admins to do things to this excluding varedit these two vars
	var/static/id_assign = 1
	var/id = 0

	var/qdel_on_finish = FALSE

	//Last run
		//General
	var/finished = FALSE
	var/start_time
	var/end_time
	var/where_switched = FALSE
	var/show_next_to_key
		//Select query only
	var/list/select_refs
	var/list/select_text
		//Runtime tracked
			//These three are weird. For best performance, they are only a number when they're not being changed by the SDQL searching/execution code. They only become numbers when they finish changing.
	var/list/obj_count_all
	var/list/obj_count_eligible
	var/obj_count_finished

	//Statclick
	var/obj/effect/statclick/SDQL2_delete/delete_click
	var/obj/effect/statclick/SDQL2_action/action_click

/datum/sdql2_query/New(list/tree, SU = FALSE, admin_interact = TRUE, _options = SDQL2_OPTIONS_DEFAULT, finished_qdel = FALSE)
	if(IsAdminAdvancedProcCall() || !LAZYLEN(tree))
		qdel(src)
		return
	LAZYADD(GLOB.sdql2_queries, src)
	superuser = SU
	allow_admin_interact = admin_interact
	query_tree = tree
	options = _options
	id = id_assign++
	qdel_on_finish = finished_qdel

/datum/sdql2_query/Destroy()
	state = SDQL2_STATE_HALTING
	query_tree = null
	obj_count_all = null
	obj_count_eligible = null
	obj_count_finished = null
	select_text = null
	select_refs = null
	GLOB.sdql2_queries -= src
	return ..()

/datum/sdql2_query/proc/get_query_text()
	var/list/out = list()
	recursive_list_print(out, query_tree)
	return out.Join()

/datum/sdql2_query/proc/generate_stat()
	if(!allow_admin_interact)
		return
	if(!delete_click)
		delete_click = new(null, "INITIALIZING", src)
	if(!action_click)
		action_click = new(null, "INITIALIZNG", src)
	var/list/L = list()
	L[++L.len] = list("[id] ", "[delete_click.update("DELETE QUERY | STATE : [state] | ALL/ELIG/FIN \
	[islist(obj_count_all)? length(obj_count_all) : (isnull(obj_count_all)? "0" : obj_count_all)]/\
	[islist(obj_count_eligible)? length(obj_count_eligible) : (isnull(obj_count_eligible)? "0" : obj_count_eligible)]/\
	[islist(obj_count_finished)? length(obj_count_finished) : (isnull(obj_count_finished)? "0" : obj_count_finished)] - [get_query_text()]")]", REF(delete_click))
	L[++L.len] = list(" ", "[action_click.update("[SDQL2_IS_RUNNING? "HALT" : "RUN"]")]", REF(action_click))
	return L

/datum/sdql2_query/proc/delete_click()
	admin_del(usr)

/datum/sdql2_query/proc/action_click()
	if(SDQL2_IS_RUNNING)
		admin_halt(usr)
	else
		admin_run(usr)

/datum/sdql2_query/proc/admin_halt(user = usr)
	if(!SDQL2_IS_RUNNING)
		return
	var/msg = "[key_name(user)] has halted query #[id]"
	message_admins(msg)
	log_admin(msg)
	state = SDQL2_STATE_HALTING

/datum/sdql2_query/proc/admin_run(mob/user = usr)
	if(SDQL2_IS_RUNNING)
		return
	var/msg = "[key_name(user)] has (re)started query #[id]"
	message_admins(msg)
	log_admin(msg)
	show_next_to_key = user.ckey
	ARun()

/datum/sdql2_query/proc/admin_del(user = usr)
	var/msg = "[key_name(user)] has stopped + deleted query #[id]"
	message_admins(msg)
	log_admin(msg)
	qdel(src)

/datum/sdql2_query/proc/set_option(name, value)
	switch(name)
		if("select")
			switch(value)
				if("force_nulls")
					options &= ~(SDQL2_OPTION_SELECT_OUTPUT_SKIP_NULLS)
		if("proccall")
			switch(value)
				if("blocking")
					options |= SDQL2_OPTION_BLOCKING_CALLS
		if("priority")
			switch(value)
				if("high")
					options |= SDQL2_OPTION_HIGH_PRIORITY
		if("autogc")
			switch(value)
				if("keep_alive")
					options |= SDQL2_OPTION_DO_NOT_AUTOGC
		if("sequential")
			switch(value)
				if("true")
					options |= SDQL2_OPTION_SEQUENTIAL

/datum/sdql2_query/proc/ARun()
	INVOKE_ASYNC(src, PROC_REF(Run))

/datum/sdql2_query/proc/Run()
	if(SDQL2_IS_RUNNING)
		return FALSE
	if(query_tree["options"])
		for(var/name in query_tree["options"])
			var/value = query_tree["options"][name]
			set_option(name, value)
	select_refs = list()
	select_text = null
	obj_count_all = 0
	obj_count_eligible = 0
	obj_count_finished = 0
	start_time = REALTIMEOFDAY

	state = SDQL2_STATE_PRESEARCH
	var/list/search_tree = PreSearch()
	SDQL2_STAGE_SWITCH_CHECK

	state = SDQL2_STATE_SEARCHING
	var/list/found = Search(search_tree)
	SDQL2_STAGE_SWITCH_CHECK

	state = SDQL2_STATE_EXECUTING
	Execute(found)
	SDQL2_STAGE_SWITCH_CHECK

	end_time = REALTIMEOFDAY
	state = SDQL2_STATE_IDLE
	finished = TRUE
	. = TRUE
	if(show_next_to_key)
		var/client/C = GLOB.directory[show_next_to_key]
		if(C)
			var/mob/showmob = C.mob
			to_chat(showmob, "<span class='admin'>SDQL query results: [get_query_text()]<br>\
			SDQL query completed: [islist(obj_count_all)? length(obj_count_all) : obj_count_all] objects selected by path, and \
			[where_switched? "[islist(obj_count_eligible)? length(obj_count_eligible) : obj_count_eligible] objects executed on after WHERE keyword selection." : ""]<br>\
			SDQL query took [DisplayTimeText(end_time - start_time)] to complete.</span>", confidential = TRUE)
			if(length(select_text))
				var/text = islist(select_text)? select_text.Join() : select_text
				var/static/result_offset = 0
				showmob << browse(text, "window=SDQL-result-[result_offset++]")
	show_next_to_key = null
	if(qdel_on_finish)
		qdel(src)

/datum/sdql2_query/proc/PreSearch()
	SDQL2_HALT_CHECK
	switch(query_tree[1])
		if("explain")
			SDQL_testout(query_tree["explain"])
			state = SDQL2_STATE_HALTING
			return
		if("call")
			. = query_tree["on"]
		if("select", "delete", "update")
			. = query_tree[query_tree[1]]
	state = SDQL2_STATE_SWITCHING

/datum/sdql2_query/proc/Search(list/tree)
	SDQL2_HALT_CHECK
	var/type = tree[1]
	var/list/from = tree[2]
	var/list/objs = SDQL_from_objs(from)
	SDQL2_TICK_CHECK
	SDQL2_HALT_CHECK
	objs = SDQL_get_all(type, objs)
	SDQL2_TICK_CHECK
	SDQL2_HALT_CHECK

	// 1 and 2 are type and FROM.
	var/i = 3
	while (i <= tree.len)
		var/key = tree[i++]
		var/list/expression = tree[i++]
		switch (key)
			if ("map")
				for(var/j = 1 to objs.len)
					var/x = objs[j]
					objs[j] = SDQL_expression(x, expression)
					SDQL2_TICK_CHECK
					SDQL2_HALT_CHECK

			if ("where")
				where_switched = TRUE
				var/list/out = list()
				obj_count_eligible = out
				for(var/x in objs)
					if(SDQL_expression(x, expression))
						out += x
					SDQL2_TICK_CHECK
					SDQL2_HALT_CHECK
				objs = out
	if(islist(obj_count_eligible))
		obj_count_eligible = objs.len
	else
		obj_count_eligible = obj_count_all
	. = objs
	state = SDQL2_STATE_SWITCHING

/datum/sdql2_query/proc/SDQL_from_objs(list/tree)
	if(IsAdminAdvancedProcCall())
		if("world" in tree)
			var/text = "[key_name(usr)] attempted to grab world with a procedure call to a SDQL datum."
			message_admins(text)
			log_admin(text)
			return
	if("world" in tree)
		return world
	return SDQL_expression(world, tree)

/datum/sdql2_query/proc/SDQL_get_all(type, location)
	var/list/out = list()
	obj_count_all = out

// If only a single object got returned, wrap it into a list so the for loops run on it.
	if(!islist(location) && location != world)
		location = list(location)

	if(type == "*")
		for(var/i in location)
			var/datum/d = i
			if(d.can_vv_get() || superuser)
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK
		return out
	if(istext(type))
		type = text2path(type)
	var/typecache = typecacheof(type)

	if(ispath(type, /mob))
		for(var/mob/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /turf))
		for(var/turf/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /obj))
		for(var/obj/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /area))
		for(var/area/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /atom))
		for(var/atom/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /datum))
		if(location == world) //snowflake for byond shortcut
			for(var/datum/d) //stupid byond trick to have it not return atoms to make this less laggy
				if(typecache[d.type] && (d.can_vv_get() || superuser))
					out += d
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK
		else
			for(var/datum/d in location)
				if(typecache[d.type] && (d.can_vv_get() || superuser))
					out += d
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK
	obj_count_all = out.len
	return out

/datum/sdql2_query/proc/Execute(list/found)
	SDQL2_HALT_CHECK
	select_refs = list()
	select_text = list()
	switch(query_tree[1])
		if("call")
			for(var/i in found)
				if(!isdatum(i))
					continue
				world.SDQL_var(i, query_tree["call"][1], null, i, superuser, src)
				obj_count_finished++
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK

		if("delete")
			for(var/datum/d in found)
				qdel(d)
				obj_count_finished++
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK

		if("select")
			var/list/text_list = list()
			var/print_nulls = !(options & SDQL2_OPTION_SELECT_OUTPUT_SKIP_NULLS)
			obj_count_finished = select_refs
			for(var/i in found)
				SDQL_print(i, text_list, print_nulls)
				select_refs[REF(i)] = TRUE
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK
			select_text = text_list

		if("update")
			if("set" in query_tree)
				var/list/set_list = query_tree["set"]
				for(var/d in found)
					if(!isdatum(d))
						continue
					SDQL_internal_vv(d, set_list)
					obj_count_finished++
					SDQL2_TICK_CHECK
					SDQL2_HALT_CHECK
	if(islist(obj_count_finished))
		obj_count_finished = length(obj_count_finished)
	state = SDQL2_STATE_SWITCHING

/datum/sdql2_query/proc/SDQL_print(object, list/text_list, print_nulls = TRUE)
	if(isdatum(object))
		text_list += "<A HREF='?_src_=vars;[HrefToken(forceGlobal = TRUE)];Vars=[REF(object)]'>[REF(object)]</A> : [object]"
		if(istype(object, /atom))
			var/atom/A = object
			var/turf/T = A.loc
			var/area/a
			if(isturf(A))
				a = A.loc
				T = A //this should prevent the "inside" part
				text_list += " <font color='gray'>at</font> [ADMIN_COORDJMP(A)]"
			else if(istype(T))
				text_list += " <font color='gray'>at</font> [T] [ADMIN_COORDJMP(T)]"
				a = T.loc
			else
				var/turf/final = get_turf(T) //Recursive, hopefully?
				if(istype(final))
					text_list += " <font color='gray'>at</font> [final] [ADMIN_COORDJMP(final)]"
					a = final.loc
				else
					text_list += " <font color='gray'>at</font> nonexistent location"
			if(a)
				text_list += " <font color='gray'>in</font> area [a]"
				if(T.loc != a)
					text_list += " <font color='gray'>inside</font> [T]"
		text_list += "<br>"
	else if(islist(object))
		var/list/L = object
		var/first = TRUE
		text_list += "\["
		for (var/x in L)
			if (!first)
				text_list += ", "
			first = FALSE
			SDQL_print(x, text_list)
			if (!isnull(x) && !isnum(x) && L[x] != null)
				text_list += " -> "
				SDQL_print(L[L[x]])
		text_list += "]<br>"
	else
		if(isnull(object))
			if(print_nulls)
				text_list += "NULL<br>"
		else
			text_list += "[object]<br>"

/datum/sdql2_query/CanProcCall()
	if(!allow_admin_interact)
		return FALSE
	return ..()

/datum/sdql2_query/vv_edit_var(var_name, var_value)
	if(!allow_admin_interact)
		return FALSE
	if(var_name == NAMEOF(src, superuser) || var_name == NAMEOF(src, allow_admin_interact) || var_name == NAMEOF(src, query_tree))
		return FALSE
	return ..()

/datum/sdql2_query/proc/SDQL_internal_vv(d, list/set_list)
	for(var/list/sets in set_list)
		var/datum/temp = d
		var/i = 0
		for(var/v in sets)
			if(v == "#null")
				SDQL_expression(d, set_list[sets])
				break
			i++
			if(i == sets.len)
				if(superuser)
					if(temp.vars.Find(v))
						temp.vars[v] = SDQL_expression(d, set_list[sets])
				else
					temp.vv_edit_var(v, SDQL_expression(d, set_list[sets]))
				break
			if(temp.vars.Find(v) && (istype(temp.vars[v], /datum) || istype(temp.vars[v], /client)))
				temp = temp.vars[v]
			else
				break

/datum/sdql2_query/proc/SDQL_function_blocking(datum/object, procname, list/arguments, source)
	var/list/new_args = list()
	for(var/arg in arguments)
		new_args[++new_args.len] = SDQL_expression(source, arg)
	if(object == GLOB) // Global proc.
		return superuser ? (call("/proc/[procname]")(arglist(new_args))) : (WrapAdminProcCall(GLOBAL_PROC, procname, new_args))
	return superuser ? (call(object, procname)(arglist(new_args))) : (WrapAdminProcCall(object, procname, new_args))

/datum/sdql2_query/proc/SDQL_function_async(datum/object, procname, list/arguments, source)
	set waitfor = FALSE
	return SDQL_function_blocking(object, procname, arguments, source)

/datum/sdql2_query/proc/SDQL_expression(datum/object, list/expression, start = 1)
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
				if("%")
					result = (result % val)
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
					to_chat(usr, span_danger("SDQL2: Unknown op [op]"), confidential = TRUE)
					result = null
		else
			result = val

	return result

/datum/sdql2_query/proc/SDQL_value(datum/object, list/expression, start = 1)
	var/i = start
	var/val = null

	if(i > expression.len)
		return list("val" = null, "i" = i)

	if(istype(expression[i], /list))
		val = SDQL_expression(object, expression[i])

	else if(expression[i] == "TRUE")
		val = TRUE

	else if(expression[i] == "FALSE")
		val = FALSE

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

	else if(ispath(expression[i]))
		val = expression[i]

	else if(expression[i][1] in list("'", "\""))
		val = copytext_char(expression[i], 2, -1)

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

	else if(expression[i] == "@\[")
		var/list/search_tree = expression[++i]
		var/already_searching = (state == SDQL2_STATE_SEARCHING) //In case we nest, don't want to break out of the searching state until we're all done.

		if(!already_searching)
			state = SDQL2_STATE_SEARCHING

		val = Search(search_tree)
		SDQL2_STAGE_SWITCH_CHECK

		if(!already_searching)
			state = SDQL2_STATE_EXECUTING
		else
			state = SDQL2_STATE_SEARCHING

	else
		val = world.SDQL_var(object, expression, i, object, superuser, src)
		i = expression.len

	return list("val" = val, "i" = i)
