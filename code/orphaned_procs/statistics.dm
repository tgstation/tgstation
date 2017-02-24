var/datum/feedback/blackbox = new()

//the feedback datum; stores all feedback
/datum/feedback
	var/list/messages = list()
	var/list/messages_admin = list()

	var/list/msg_common = list()
	var/list/msg_science = list()
	var/list/msg_command = list()
	var/list/msg_medical = list()
	var/list/msg_engineering = list()
	var/list/msg_security = list()
	var/list/msg_deathsquad = list()
	var/list/msg_syndicate = list()
	var/list/msg_service = list()
	var/list/msg_cargo = list()

	var/list/datum/feedback_variable/feedback = new()

/datum/feedback/proc/find_feedback_datum(variable)
	for (var/datum/feedback_variable/FV in feedback)
		if (FV.get_variable() == variable)
			return FV
	var/datum/feedback_variable/FV = new(variable)
	feedback += FV
	return FV

/datum/feedback/proc/get_round_feedback()
	return feedback

/datum/feedback/proc/round_end_data_gathering()
	var/pda_msg_amt = 0
	var/rc_msg_amt = 0

	for (var/obj/machinery/message_server/MS in message_servers)
		if (MS.pda_msgs.len > pda_msg_amt)
			pda_msg_amt = MS.pda_msgs.len
		if (MS.rc_msgs.len > rc_msg_amt)
			rc_msg_amt = MS.rc_msgs.len

	feedback_set_details("radio_usage","")

	feedback_add_details("radio_usage","COM-[msg_common.len]")
	feedback_add_details("radio_usage","SCI-[msg_science.len]")
	feedback_add_details("radio_usage","HEA-[msg_command.len]")
	feedback_add_details("radio_usage","MED-[msg_medical.len]")
	feedback_add_details("radio_usage","ENG-[msg_engineering.len]")
	feedback_add_details("radio_usage","SEC-[msg_security.len]")
	feedback_add_details("radio_usage","DTH-[msg_deathsquad.len]")
	feedback_add_details("radio_usage","SYN-[msg_syndicate.len]")
	feedback_add_details("radio_usage","SRV-[msg_service.len]")
	feedback_add_details("radio_usage","CAR-[msg_cargo.len]")
	feedback_add_details("radio_usage","OTH-[messages.len]")
	feedback_add_details("radio_usage","PDA-[pda_msg_amt]")
	feedback_add_details("radio_usage","RC-[rc_msg_amt]")

	feedback_set_details("round_end","[time2text(world.realtime)]") //This one MUST be the last one that gets set.

//This proc is only to be called at round end.
/datum/feedback/proc/save_all_data_to_sql()
	if (!feedback) return

	round_end_data_gathering() //round_end time logging and some other data processing
	if (!dbcon.Connect()) return
	var/round_id

	var/DBQuery/query = dbcon.NewQuery("SELECT MAX(round_id) AS round_id FROM [format_table_name("feedback")]")
	query.Execute()
	while (query.NextRow())
		round_id = query.item[1]

	if (!isnum(round_id))
		round_id = text2num(round_id)
	round_id++

	var/sqlrowlist = ""

	for (var/datum/feedback_variable/FV in feedback)
		if (sqlrowlist != "")
			sqlrowlist += ", " //a comma (,) at the start of the first row to insert will trigger a SQL error

		sqlrowlist += "(null, Now(), [round_id], \"[sanitizeSQL(FV.get_variable())]\", [FV.get_value()], \"[sanitizeSQL(FV.get_details())]\")"

	if (sqlrowlist == "")
		return

	var/DBQuery/query_insert = dbcon.NewQuery("INSERT DELAYED IGNORE INTO [format_table_name("feedback")] VALUES " + sqlrowlist)
	query_insert.Execute()


/proc/feedback_set(variable,value)
	if(!blackbox)
		return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.set_value(value)

/proc/feedback_inc(variable,value)
	if(!blackbox)
		return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.inc(value)

/proc/feedback_dec(variable,value)
	if(!blackbox)
		return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.dec(value)

/proc/feedback_set_details(variable,details)
	if(!blackbox)
		return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.set_details(details)

/proc/feedback_add_details(variable,details)
	if(!blackbox)
		return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.add_details(details)

//feedback variable datum, for storing all kinds of data
/datum/feedback_variable
	var/variable
	var/value
	var/details

/datum/feedback_variable/New(var/param_variable,var/param_value = 0)
	variable = param_variable
	value = param_value

/datum/feedback_variable/proc/inc(num = 1)
	if (isnum(value))
		value += num
	else
		value = text2num(value)
		if (isnum(value))
			value += num
		else
			value = num

/datum/feedback_variable/proc/dec(num = 1)
	if (isnum(value))
		value -= num
	else
		value = text2num(value)
		if (isnum(value))
			value -= num
		else
			value = -num

/datum/feedback_variable/proc/set_value(num)
	if (isnum(num))
		value = num

/datum/feedback_variable/proc/get_value()
	if (!isnum(value))
		return 0
	return value

/datum/feedback_variable/proc/get_variable()
	return variable

/datum/feedback_variable/proc/set_details(text)
	if (istext(text))
		details = text

/datum/feedback_variable/proc/add_details(text)
	if (istext(text))
		text = replacetext(text, " ", "_")
		if (!details)
			details = text
		else
			details += " [text]"

/datum/feedback_variable/proc/get_details()
	return details

/datum/feedback_variable/proc/get_parsed()
	return list(variable,value,details)

//sql reporting procs
/proc/sql_poll_players()
	if(!config.sql_enabled)
		return
	var/playercount = 0
	for(var/mob/M in player_list)
		if(M.client)
			playercount += 1
	if(!dbcon.Connect())
		log_game("SQL ERROR during player polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("legacy_population")] (playercount, time) VALUES ([playercount], '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during player polling. Error : \[[err]\]\n")

/proc/sql_poll_admins()
	if(!config.sql_enabled)
		return
	var/admincount = admins.len
	if(!dbcon.Connect())
		log_game("SQL ERROR during admin polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("legacy_population")] (admincount, time) VALUES ([admincount], '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during admin polling. Error : \[[err]\]\n")

/proc/sql_report_round_start()
	// TODO
	if(!config.sql_enabled)
		return

/proc/sql_report_round_end()
	// TODO
	if(!config.sql_enabled)
		return

/proc/sql_report_death(mob/living/L)
	if(!config.sql_enabled)
		return
	if(!L)
		return
	if(!L.key || !L.mind)
		return

	var/turf/T = get_turf(L)
	var/area/placeofdeath = get_area(T.loc)
	var/podname = placeofdeath.name

	var/sqlname = sanitizeSQL(L.real_name)
	var/sqlkey = sanitizeSQL(L.key)
	var/sqlpod = sanitizeSQL(podname)
	var/sqlspecial = sanitizeSQL(L.mind.special_role)
	var/sqljob = sanitizeSQL(L.mind.assigned_role)
	var/laname
	var/lakey
	if(L.lastattacker)
		laname = sanitizeSQL(L.lastattacker:real_name)
		lakey = sanitizeSQL(L.lastattacker:key)
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[L.x], [L.y], [L.z]"
	var/map = MAP_NAME
	var/server = "[world.internet_address]:[world.port]"
	if(!dbcon.Connect())
		log_game("SQL ERROR during death reporting. Failed to connect.")
	else
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("death")] (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord, mapname, server) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[L.gender]', [L.getBruteLoss()], [L.getFireLoss()], [L.brainloss], [L.getOxyLoss()], '[coord]', '[map]', '[server]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during death reporting. Error : \[[err]\]\n")

//This proc is used for feedback. It is executed at round end.
/proc/sql_commit_feedback()
	if(!blackbox)
		log_game("Round ended without a blackbox recorder. No feedback was sent to the database: This should not happen without admin intervention.")
		return

	//content is a list of lists. Each item in the list is a list with two fields, a variable name and a value. Items MUST only have these two values.
	var/list/datum/feedback_variable/content = blackbox.get_round_feedback()

	if(!content)
		log_game("Round ended without any feedback being generated. No feedback was sent to the database.")
		return

	if(!dbcon.Connect())
		log_game("SQL ERROR during feedback reporting. Failed to connect.")
	else

		var/DBQuery/max_query = dbcon.NewQuery("SELECT MAX(roundid) AS max_round_id FROM [format_table_name("feedback")]")
		max_query.Execute()

		var/newroundid

		while(max_query.NextRow())
			newroundid = max_query.item[1]

		if(!(isnum(newroundid)))
			newroundid = text2num(newroundid)

		if(isnum(newroundid))
			newroundid++
		else
			newroundid = 1

		for(var/datum/feedback_variable/item in content)
			var/variable = item.get_variable()
			var/value = item.get_value()

			var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("feedback")] (id, roundid, time, variable, value) VALUES (null, [newroundid], Now(), '[variable]', '[value]')")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during feedback reporting. Error : \[[err]\]\n")
