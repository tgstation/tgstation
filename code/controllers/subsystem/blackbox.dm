SUBSYSTEM_DEF(blackbox)
	name = "Blackbox"
	wait = 6000
	flags = SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_BLACKBOX

	var/list/feedback = list()	//list of datum/feedback_variable
	var/triggertime = 0
	var/sealed = FALSE	//time to stop tracking stats?
	var/list/research_levels = list() //list of highest tech levels attained that isn't lost lost by destruction of RD computers


/datum/controller/subsystem/blackbox/Initialize()
	triggertime = world.time
	. = ..()

//poll population
/datum/controller/subsystem/blackbox/fire()
	if(!SSdbcore.Connect())
		return
	var/playercount = 0
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			playercount += 1
	var/admincount = GLOB.admins.len
	var/datum/DBQuery/query_record_playercount = SSdbcore.NewQuery("INSERT INTO [format_table_name("legacy_population")] (playercount, admincount, time, server_ip, server_port, round_id) VALUES ([playercount], [admincount], '[SQLtime()]', INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]', '[GLOB.round_id]')")
	query_record_playercount.Execute()

	if(CONFIG_GET(flag/use_exp_tracking))
		if((triggertime < 0) || (world.time > (triggertime +3000)))	//subsystem fires once at roundstart then once every 10 minutes. a 5 min check skips the first fire. The <0 is midnight rollover check
			update_exp(10,FALSE)


/datum/controller/subsystem/blackbox/Recover()
	feedback = SSblackbox.feedback
	sealed = SSblackbox.sealed

//no touchie
/datum/controller/subsystem/blackbox/can_vv_get(var_name)
	if(var_name == "feedback")
		return FALSE
	return ..()

/datum/controller/subsystem/blackbox/vv_edit_var(var_name, var_value)
	return FALSE

/datum/controller/subsystem/blackbox/Shutdown()
	sealed = FALSE
	record_feedback("tally", "ahelp_stats", GLOB.ahelp_tickets.active_tickets.len, "unresolved")
	for (var/obj/machinery/message_server/MS in GLOB.message_servers)
		if (MS.pda_msgs.len)
			record_feedback("tally", "radio_usage", MS.pda_msgs.len, "PDA")
		if (MS.rc_msgs.len)
			record_feedback("tally", "radio_usage", MS.rc_msgs.len, "request console")
	if(research_levels.len)
		SSblackbox.record_feedback("associative", "high_research_level", 1, research_levels)

	if (!SSdbcore.Connect())
		return

	var/list/sqlrowlist = list()

	for (var/datum/feedback_variable/FV in feedback)
		sqlrowlist += list(list("datetime" = "Now()", "round_id" = GLOB.round_id, "key" =  "'[sanitizeSQL(FV.key)]'", "details" = "'[sanitizeSQL(json_encode(FV.json))]'"))

	if (!length(sqlrowlist))
		return

	SSdbcore.MassInsert(format_table_name("feedback"), sqlrowlist, ignore_errors = TRUE, delayed = TRUE)

/datum/controller/subsystem/blackbox/proc/Seal()
	if(sealed)
		return
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name_admin(usr)] sealed the blackbox!")
	log_game("Blackbox sealed[IsAdminAdvancedProcCall() ? " by [key_name(usr)]" : ""].")
	sealed = TRUE

/datum/controller/subsystem/blackbox/proc/log_research(tech, level)
	if(!(tech in research_levels) || research_levels[tech] < level)
		research_levels[tech] = level

/datum/controller/subsystem/blackbox/proc/LogBroadcast(freq)
	if(sealed)
		return
	switch(freq)
		if(1459)
			record_feedback("tally", "radio_usage", 1, "common")
		if(SCI_FREQ)
			record_feedback("tally", "radio_usage", 1, "science")
		if(COMM_FREQ)
			record_feedback("tally", "radio_usage", 1, "command")
		if(MED_FREQ)
			record_feedback("tally", "radio_usage", 1, "medical")
		if(ENG_FREQ)
			record_feedback("tally", "radio_usage", 1, "engineering")
		if(SEC_FREQ)
			record_feedback("tally", "radio_usage", 1, "security")
		if(SYND_FREQ)
			record_feedback("tally", "radio_usage", 1, "syndicate")
		if(SERV_FREQ)
			record_feedback("tally", "radio_usage", 1, "service")
		if(SUPP_FREQ)
			record_feedback("tally", "radio_usage", 1, "supply")
		if(CENTCOM_FREQ)
			record_feedback("tally", "radio_usage", 1, "centcom")
		if(AIPRIV_FREQ)
			record_feedback("tally", "radio_usage", 1, "ai private")
		if(REDTEAM_FREQ)
			record_feedback("tally", "radio_usage", 1, "CTF red team")
		if(BLUETEAM_FREQ)
			record_feedback("tally", "radio_usage", 1, "CTF blue team")
		else
			record_feedback("tally", "radio_usage", 1, "other")

/datum/controller/subsystem/blackbox/proc/find_feedback_datum(key)
	for(var/datum/feedback_variable/FV in feedback)
		if(FV.key == key)
			return FV

	var/datum/feedback_variable/FV = new(key)
	feedback += FV
	return FV
/*
feedback data can be recorded in 5 formats:
"text"
	used for simple single-string records i.e. the current map
	further calls to the same key will append saved data unless the overwrite argument is true or it already exists
	calls: 	SSblackbox.record_feedback("text", "example", 1, "sample text")
			SSblackbox.record_feedback("text", "example", 1, "other text")
	json: {"data":["sample text","other text"]}
"amount"
	used to record simple counts of data i.e. the number of ahelps recieved
	further calls to the same key will add or subtract (if increment argument is a negative) from the saved amount
	calls:	SSblackbox.record_feedback("amount", "example", 8)
			SSblackbox.record_feedback("amount", "example", 2)
	json: {"data":10}
"tally"
	used to track the number of occurances of multiple related values i.e. how many times each type of gun is fired
	further calls to the same key will:
	 	add or subtract from the saved value of the data key if it already exists
		append the key and it's value if it doesn't exist
	calls:	SSblackbox.record_feedback("tally", "example", 1, "sample data")
			SSblackbox.record_feedback("tally", "example", 4, "sample data")
			SSblackbox.record_feedback("tally", "example", 2, "other data")
	json: {"data":{"sample data":5,"other data":2}}
"nested tally"
	used to track the number of occurances of structured semi-relational values i.e. the results of arcade machines
	similar to running total, but related values are nested in a multi-dimensional array built
	the final element in the data list is used as the tracking key, all prior elements are used for nesting
	further calls to the same key will:
	 	add or subtract from the saved value of the data key if it already exists in the same multi-dimensional position
		append the key and it's value if it doesn't exist
	calls: 	SSblackbox.record_feedback("nested tally", "example", 1, list("fruit", "orange", "apricot"))
			SSblackbox.record_feedback("nested tally", "example", 2, list("fruit", "orange", "orange"))
			SSblackbox.record_feedback("nested tally", "example", 3, list("fruit", "orange", "apricot"))
			SSblackbox.record_feedback("nested tally", "example", 10, list("fruit", "red", "apple"))
			SSblackbox.record_feedback("nested tally", "example", 1, list("vegetable", "orange", "carrot"))
	json: {"data":{"fruit":{"orange":{"apricot":4,"orange":2},"red":{"apple":10}},"vegetable":{"orange":{"carrot":1}}}}
	tracking values associated with a number can't merge with a nesting value, trying to do so will append the list
	call:	SSblackbox.record_feedback("nested tally", "example", 3, list("fruit", "orange"))
	json: {"data":{"fruit":{"orange":{"apricot":4,"orange":2},"red":{"apple":10},"orange":3},"vegetable":{"orange":{"carrot":1}}}}
"associative"
	used to record text that's associated with a value i.e. coordinates
	further calls to the same key will append a new list to existing data
	calls:	SSblackbox.record_feedback("associative", "example", 1, list("text" = "example", "path" = /obj/item, "number" = 4))
			SSblackbox.record_feedback("associative", "example", 1, list("number" = 7, "text" = "example", "other text" = "sample"))
	json: {"data":{"1":{"text":"example","path":"/obj/item","number":"4"},"2":{"number":"7","text":"example","other text":"sample"}}}
*/
/datum/controller/subsystem/blackbox/proc/record_feedback(type, key, increment, data, overwrite)
	if(sealed || !type || !istext(key) || !isnum(increment))
		return
	var/datum/feedback_variable/FV = find_feedback_datum(key)
	switch(type)
		if("text")
			if(!istext(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			if(overwrite)
				FV.json["data"] = data
			else
				FV.json["data"] |= data
		if("amount")
			FV.json["data"] += increment
		if("tally")
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"][data] += increment
		if("nested tally")
			if(!islist(data))
				return
			FV.json = record_feedback_recurse_list(FV.json, data, increment)
		if("associative")
			if(!islist(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"]["[FV.json["data"].len+1]"] = list()
			for(var/i in data)
				FV.json["data"]["[FV.json["data"].len]"]["[i]"] = "[data[i]]"

/datum/controller/subsystem/blackbox/proc/record_feedback_recurse_list(list/L, list/key_list, increment, depth = 1)
	if(depth == key_list.len)
		if(L.Find(key_list[depth]))
			L["[key_list[depth]]"] += increment
		else
			var/list/asd = list(key_list[depth] = increment)
			L += asd
	else
		if(!L.Find(key_list[depth]))
			var/list/mmx = list(key_list[depth] = list())
			L += mmx
		L["[key_list[depth-1]]"] = .(L["[key_list[depth]]"], key_list, increment, ++depth)
	return L

/datum/feedback_variable
	var/key
	var/list/json = list()

/datum/feedback_variable/New(new_key)
	key = new_key

/datum/controller/subsystem/blackbox/proc/ReportDeath(mob/living/L)
	if(sealed)
		return
	if(!SSdbcore.Connect())
		return
	if(!L || !L.key || !L.mind)
		return
	var/area/placeofdeath = get_area(L)
	var/sqlname = sanitizeSQL(L.real_name)
	var/sqlkey = sanitizeSQL(L.ckey)
	var/sqljob = sanitizeSQL(L.mind.assigned_role)
	var/sqlspecial = sanitizeSQL(L.mind.special_role)
	var/sqlpod = sanitizeSQL(placeofdeath.name)
	var/laname
	var/lakey
	if(L.lastattacker && ismob(L.lastattacker))
		var/mob/LA = L.lastattacker
		laname = sanitizeSQL(LA.real_name)
		lakey = sanitizeSQL(LA.key)
	var/sqlbrute = sanitizeSQL(L.getBruteLoss())
	var/sqlfire = sanitizeSQL(L.getFireLoss())
	var/sqlbrain = sanitizeSQL(L.getBrainLoss())
	var/sqloxy = sanitizeSQL(L.getOxyLoss())
	var/sqltox = sanitizeSQL(L.getToxLoss())
	var/sqlclone = sanitizeSQL(L.getCloneLoss())
	var/sqlstamina = sanitizeSQL(L.getStaminaLoss())
	var/x_coord = sanitizeSQL(L.x)
	var/y_coord = sanitizeSQL(L.y)
	var/z_coord = sanitizeSQL(L.z)
	var/last_words = sanitizeSQL(L.last_words)
	var/suicide = sanitizeSQL(L.suiciding)
	var/map = sanitizeSQL(SSmapping.config.map_name)
	var/datum/DBQuery/query_report_death = SSdbcore.NewQuery("INSERT INTO [format_table_name("death")] (pod, x_coord, y_coord, z_coord, mapname, server_ip, server_port, round_id, tod, job, special, name, byondkey, laname, lakey, bruteloss, fireloss, brainloss, oxyloss, toxloss, cloneloss, staminaloss, last_words, suicide) VALUES ('[sqlpod]', '[x_coord]', '[y_coord]', '[z_coord]', '[map]', INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]', [GLOB.round_id], '[SQLtime()]', '[sqljob]', '[sqlspecial]', '[sqlname]', '[sqlkey]', '[laname]', '[lakey]', [sqlbrute], [sqlfire], [sqlbrain], [sqloxy], [sqltox], [sqlclone], [sqlstamina], '[last_words]', [suicide])")
	query_report_death.Execute()
