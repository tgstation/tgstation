//SDQL2 datumized, /tg/station special!

/// Parses the `query_text` input and handles running it and returning the desired results.
/// This should not be called directly, use either the `admin_SDQL2_query` or `HandleUserlessSDQL` wrappers instead.
/world/proc/SDQL2_query(mob/user, query_text, log_entry1, log_entry2, silent = FALSE)
	if(IsAdminAdvancedProcCall())
		tgui_alert(usr, "Please do not invoke SDQL2_query directly, this messes with logging. Use admin_SDQL2_query() instead.", "SDQL2", list("Ok"))
		return

	// will give information back to the user about the status of the query, different than silent because this is stuff that we would always send to a real cliented mob.
	var/user_feedback = FALSE
	var/query_log = "executed SDQL query(s): \"[query_text]\"."

	if(!silent)
		message_admins("[log_entry1] [query_log]")
	query_log = "[log_entry2] [query_log]"
	user.log_message(query_log, LOG_ADMIN)
	NOTICE(query_log)

	if(user != GLOB.AdminProcCallHandler)
		user_feedback = TRUE

	var/start_time_total = REALTIMEOFDAY
	var/sequential = FALSE

	if(!length(query_text))
		return
	var/list/query_list = SDQL2_tokenize(query_text)
	if(!length(query_list))
		return
	var/list/querys = SDQL_parse(query_list)
	if(!length(querys))
		return
	var/list/datum/sdql2_query/running = list()
	var/list/datum/sdql2_query/waiting_queue = list() //Sequential queries queue.

	for(var/list/query_tree in querys)
		var/datum/sdql2_query/query = new /datum/sdql2_query(query_tree)
		if(QDELETED(query))
			continue
		if(user_feedback) // otherwise, there would be no user/ckey to look up in GLOB.directory
			query.show_next_to_key = user.ckey
		waiting_queue += query
		if(query.options & SDQL2_OPTION_SEQUENTIAL)
			sequential = TRUE

	if(sequential) //Start first one
		var/datum/sdql2_query/query = popleft(waiting_queue)
		running += query
		var/msg = "Starting query #[query.id] - [query.get_query_text()]."
		if(user_feedback)
			to_chat(user, span_admin(msg), confidential = TRUE)
		log_admin(msg)
		query.ARun()

	else //Start all
		for(var/datum/sdql2_query/query in waiting_queue)
			running += query
			var/msg = "Starting query #[query.id] - [query.get_query_text()]."
			if(user_feedback)
				to_chat(user, span_admin(msg), confidential = TRUE)
			log_admin(msg)
			query.ARun()

	var/finished = FALSE
	var/objs_all = 0
	var/objs_eligible = 0
	var/selectors_used = FALSE
	var/list/combined_refs = list()
	do
		CHECK_TICK
		finished = TRUE
		for(var/i in running)
			var/datum/sdql2_query/query = i
			if(QDELETED(query))
				running -= query
				continue
			else if(query.state != SDQL2_STATE_IDLE)
				finished = FALSE
				if(query.state == SDQL2_STATE_ERROR)
					if(user_feedback)
						to_chat(user, span_admin("SDQL query [query.get_query_text()] errored. It will NOT be automatically garbage collected. Please remove manually."), confidential = TRUE)
					running -= query
			else
				if(query.finished)
					objs_all += islist(query.obj_count_all)? length(query.obj_count_all) : query.obj_count_all
					objs_eligible += islist(query.obj_count_eligible)? length(query.obj_count_eligible) : query.obj_count_eligible
					selectors_used |= query.where_switched
					combined_refs |= query.select_refs
					running -= query
					if(!(query.options & SDQL2_OPTION_DO_NOT_AUTOGC))
						QDEL_IN(query, 50)
					if(sequential && waiting_queue.len)
						finished = FALSE
						var/datum/sdql2_query/next_query = popleft(waiting_queue)
						running += next_query
						var/msg = "Starting query #[next_query.id] - [next_query.get_query_text()]."
						if(user_feedback)
							to_chat(user, span_admin(msg), confidential = TRUE)
						log_admin(msg)
						next_query.ARun()
				else
					if(user_feedback)
						to_chat(user, span_admin("SDQL query [query.get_query_text()] was halted. It will NOT be automatically garbage collected. Please remove manually."), confidential = TRUE)
					running -= query
	while(!finished)

	var/end_time_total = REALTIMEOFDAY - start_time_total
	return list(span_admin("SDQL query combined results: [query_text]"),\
		span_admin("SDQL query completed: [objs_all] objects selected by path, and [selectors_used ? objs_eligible : objs_all] objects executed on after WHERE filtering/MAPping if applicable."),\
		span_admin("SDQL combined querys took [DisplayTimeText(end_time_total)] to complete.")) + combined_refs

//Staying as a world proc as this is called too often for changes to offset the potential IsAdminAdvancedProcCall checking overhead.
/world/proc/SDQL_var(object, list/expression, start = 1, source, superuser, datum/sdql2_query/query)
	var/v
	var/static/list/exclude = list("usr", "src", "marked", "global", "MC", "FS", "CFG")
	var/long = start < expression.len
	var/datum/D
	if(isdatum(object))
		D = object

	if (object == world && (!long || expression[start + 1] == ".") && !(expression[start] in exclude) && copytext(expression[start], 1, 3) != "SS") //3 == length("SS") + 1
		to_chat(usr, span_danger("World variables are not allowed to be accessed. Use global."), confidential = TRUE)
		return null

	else if(expression [start] == "{" && long)
		if(lowertext(copytext(expression[start + 1], 1, 3)) != "0x") //3 == length("0x") + 1
			to_chat(usr, span_danger("Invalid pointer syntax: [expression[start + 1]]"), confidential = TRUE)
			return null
		var/datum/located = locate("\[[expression[start + 1]]]")
		if(!istype(located))
			to_chat(usr, span_danger("Invalid pointer: [expression[start + 1]] - null or not datum"), confidential = TRUE)
			return null
		if(!located.can_vv_mark())
			to_chat(usr, span_danger("Pointer [expression[start+1]] cannot be marked"), confidential = TRUE)
			return null
		v = located
		start++
		long = start < expression.len
	else if(expression[start] == "(" && long)
		v = query.SDQL_expression(source, expression[start + 1])
		start++
		long = start < expression.len
	else if(D != null && (!long || expression[start + 1] == ".") && (expression[start] in D.vars))
		if(D.can_vv_get(expression[start]) || superuser)
			v = D.vars[expression[start]]
		else
			v = "SECRET"
	else if(D != null && long && expression[start + 1] == ":" && hascall(D, expression[start]))
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
			if("MC")
				v = Master
			if("FS")
				v = Failsafe
			if("CFG")
				v = config
			else
				if(copytext(expression[start], 1, 3) == "SS") //Subsystem //3 == length("SS") + 1
					var/SSname = copytext_char(expression[start], 3)
					var/SSlength = length(SSname)
					var/datum/controller/subsystem/SS
					var/SSmatch
					for(var/_SS in Master.subsystems)
						SS = _SS
						if(copytext("[SS.type]", -SSlength) == SSname)
							SSmatch = SS
							break
					if(!SSmatch)
						return null
					v = SSmatch
				else
					return null
	else if(object == GLOB) // Shitty ass hack kill me.
		v = expression[start]
	if(long)
		if(expression[start + 1] == ".")
			return SDQL_var(v, expression[start + 2], null, source, superuser, query)
		else if(expression[start + 1] == ":")
			return (query.options & SDQL2_OPTION_BLOCKING_CALLS)? query.SDQL_function_async(object, v, expression[start + 2], source) : query.SDQL_function_blocking(object, v, expression[start + 2], source)
		else if(expression[start + 1] == "\[" && islist(v))
			var/list/L = v
			var/index = query.SDQL_expression(source, expression[start + 2])
			if(isnum(index) && (!ISINTEGER(index) || L.len < index))
				to_chat(usr, span_danger("Invalid list index: [index]"), confidential = TRUE)
				return null
			return L[index]
	return v

