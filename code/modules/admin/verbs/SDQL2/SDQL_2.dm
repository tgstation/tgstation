//SDQL2 datumized, /tg/station special!

/*
	Welcome admins, badmins and coders alike, to Structured Datum Query Language.
	SDQL allows you to powerfully run code on batches of objects (or single objects, it's still unmatched
	even there.)
	When I say "powerfully" I mean it you're in for a ride.

	Ok so say you want to get a list of every mob. How does one do this?
	"SELECT /mob"
	This will open a list of every object in world that is a /mob.
	And you can VV them if you need.

	What if you want to get every mob on a *specific z-level*?
	"SELECT /mob WHERE z == 4"

	What if you want to select every mob on even numbered z-levels?
	"SELECT /mob WHERE z % 2 == 0"

	Can you see where this is going? You can select objects with an arbitrary expression.
	These expressions can also do variable access and proc calls (yes, both on-object and globals!)
	Keep reading!

	Ok. What if you want to get every machine in the SSmachine process list? Looping through world is kinda
	slow.

	"SELECT * IN SSmachines.machinery"

	Here "*" as type functions as a wildcard.
	We know everything in the global SSmachines.machinery list is a machine.

	You can specify "IN <expression>" to return a list to operate on.
	This can be any list that you can wizard together from global variables and global proc calls.
	Every variable/proc name in the "IN" block is global.
	It can also be a single object, in which case the object is wrapped in a list for you.
	So yeah SDQL is unironically better than VV for complex single-object operations.

	You can of course combine these.
	"SELECT * IN SSmachines.machinery WHERE z == 4"
	"SELECT * IN SSmachines.machinery WHERE stat & 2" // (2 is NOPOWER, can't use defines from SDQL. Sorry!)
	"SELECT * IN SSmachines.machinery WHERE stat & 2 && z == 4"

	The possibilities are endless (just don't crash the server, ok?).

	Oh it gets better.

	You can use "MAP <expression>" to run some code per object and use the result. For example:

	"SELECT /obj/machinery/power/smes MAP [charge / capacity * 100, RCon_tag, src]"

	This will give you a list of all the APCs, their charge AND RCon tag. Useful eh?

	[] being a list here. Yeah you can write out lists directly without > lol lists in VV. Color matrix
	shenanigans inbound.

	After the "MAP" segment is executed, the rest of the query executes as if it's THAT object you just made
	(here the list).
	Yeah, by the way, you can chain these MAP / WHERE things FOREVER!

	"SELECT /mob WHERE client MAP client WHERE holder MAP holder"

	You can also generate a new list on the fly using a selector array. @[] will generate a list of objects based off the selector provided.

	"SELECT /mob/living IN (@[/area/service/bar MAP contents])[1]"

	What if some dumbass admin spawned a bajillion spiders and you need to kill them all?
	Oh yeah you'd rather not delete all the spiders in maintenace. Only that one room the spiders were
	spawned in.

	"DELETE /mob/living/carbon/superior_animal/giant_spider WHERE loc.loc == marked"

	Here I used VV to mark the area they were in, and since loc.loc = area, voila.
	Only the spiders in a specific area are gone.

	Or you know if you want to catch spiders that crawled into lockers too (how even?)

	"DELETE /mob/living/carbon/superior_animal/giant_spider WHERE global.get_area(src) == marked"

	What else can you do?

	Well suppose you'd rather gib those spiders instead of simply flat deleting them...

	"CALL gib() ON /mob/living/carbon/superior_animal/giant_spider WHERE global.get_area(src) == marked"

	Or you can have some fun..

	"CALL forceMove(marked) ON /mob/living/carbon/superior_animal"

	You can also run multiple queries sequentially:

	"CALL forceMove(marked) ON /mob/living/carbon/superior_animal; CALL gib() ON
	/mob/living/carbon/superior_animal"

	And finally, you can directly modify variables on objects.

	"UPDATE /mob WHERE client SET client.color = [0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]"

	Don't crash the server, OK?

	"UPDATE /mob/living/carbon/human/species/monkey SET #null = forceMove(usr.loc)"

	Writing "#null" in front of the "=" will call the proc and discard the return value.

	A quick recommendation: before you run something like a DELETE or another query.. Run it through SELECT
	first.
	You'd rather not gib every player on accident.
	Or crash the server.

	By the way, queries are slow and take a while. Be patient.
	They don't hang the entire server though.

	With great power comes great responsability.

	Here's a slightly more formal quick reference.

	The 4 queries you can do are:

	"SELECT <selectors>"
	"CALL <proc call> ON <selectors>"
	"UPDATE <selectors> SET var=<value>,var2=<value>"
	"DELETE <selectors>"

	"<selectors>" in this context is "<type> [IN <source>] [chain of MAP/WHERE modifiers]"

	"IN" (or "FROM", that works too but it's kinda weird to read),
	is the list of objects to work on. This defaults to world if not provided.
	But doing something like "IN living_mob_list" is quite handy and can optimize your query.
	All names inside the IN block are global scope, so you can do living_mob_list (a global var) easily.
	You can also run it on a single object. Because SDQL is that convenient even for single operations.

	<type> filters out objects of, well, that type easily. "*" is a wildcard and just takes everything in
	the source list.

	And then there's the MAP/WHERE chain.
	These operate on each individual object being ran through the query.
	They're both expressions like IN, but unlike it the expression is scoped *on the object*.
	So if you do "WHERE z == 4", this does "src.z", effectively.
	If you want to access global variables, you can do `global.living_mob_list`.
	Same goes for procs.

	MAP "changes" the object into the result of the expression.
	WHERE "drops" the object if the expression is falsey (0, null or "")

	What can you do inside expressions?

	* Proc calls
	* Variable reads
	* Literals (numbers, strings, type paths, etc...)
	* \ref referencing: {0x30000cc} grabs the object with \ref [0x30000cc]
	* Lists: [a, b, c] or [a: b, c: d]
	* Math and stuff.
	* A few special variables: src (the object currently scoped on), usr (your mob),
		marked (your marked datum), global(global scope)

	TG ADDITIONS START:
	Add USING keyword to the front of the query to use options system
	The defaults aren't necessarily implemented, as there is no need to.
	Available options: (D) means default
	PROCCALL = (D)ASYNC, BLOCKING
	SELECT = FORCE_NULLS, (D)SKIP_NULLS
	PRIORITY = HIGH, (D) NORMAL
	AUTOGC = (D) AUTOGC, KEEP_ALIVE
	SEQUENTIAL = TRUE - The queries in this batch will be executed sequentially one by one not in parallel

	Example: USING PROCCALL = BLOCKING, SELECT = FORCE_NULLS, PRIORITY = HIGH SELECT /mob FROM world WHERE z == 1

*/

/client/proc/admin_SDQL2_query(query_text as message)
	set category = "Debug"
	set name = "SDQL2 Query"

	if(!check_rights(R_DEBUG))  //Shouldn't happen... but just to be safe.
		message_admins(span_danger("ERROR: Non-admin [key_name(usr)] attempted to execute a SDQL query!"))
		usr.log_message("non-admin attempted to execute a SDQL query!", LOG_ADMIN)
		return FALSE
	var/prompt = tgui_alert(usr, "Run SDQL2 Query?", "SDQL2", list("Yes", "Cancel"))
	if (prompt != "Yes")
		return
	SSblackbox.record_feedback("nested tally", "SDQL query", 1, list(ckey, query_text))
	var/list/results = world.SDQL2_query(usr, query_text, key_name_admin(usr), "[key_name(usr)]")
	if(length(results) == 0)
		return

	for(var/message in 1 to 3)
		to_chat(usr, results[message], confidential = TRUE)

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

