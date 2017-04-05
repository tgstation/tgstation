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

	var/DBQuery/query_feedback_max_id = dbcon.NewQuery("SELECT MAX(round_id) AS round_id FROM [format_table_name("feedback")]")
	if(!query_feedback_max_id.Execute())
		return
	while (query_feedback_max_id.NextRow())
		round_id = query_feedback_max_id.item[1]

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

	var/DBQuery/query_feedback_save = dbcon.NewQuery("INSERT DELAYED IGNORE INTO [format_table_name("feedback")] VALUES " + sqlrowlist)
	query_feedback_save.Execute()


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
/proc/sql_poll_population()
	if(!config.sql_enabled)
		return
	if(!dbcon.Connect())
		return
	var/playercount = 0
	for(var/mob/M in player_list)
		if(M.client)
			playercount += 1
	var/admincount = admins.len
	var/DBQuery/query_record_playercount = dbcon.NewQuery("INSERT INTO [format_table_name("legacy_population")] (playercount, admincount, time, server_ip, server_port) VALUES ([playercount], [admincount], '[SQLtime()]', INET_ATON('[world.internet_address]'), '[world.port]')")
	query_record_playercount.Execute()

/proc/sql_report_death(mob/living/L)
	if(!config.sql_enabled)
		return
	if(!dbcon.Connect())
		return
	if(!L || !L.key || !L.mind)
		return
	var/turf/T = get_turf(L)
	var/area/placeofdeath = get_area(T.loc)
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
	var/sqlgender = sanitizeSQL(L.gender)
	var/sqlbrute = sanitizeSQL(L.getBruteLoss())
	var/sqlfire = sanitizeSQL(L.getFireLoss())
	var/sqlbrain = sanitizeSQL(L.getBrainLoss())
	var/sqloxy = sanitizeSQL(L.getOxyLoss())
	var/sqltox = sanitizeSQL(L.getStaminaLoss())
	var/sqlclone = sanitizeSQL(L.getStaminaLoss())
	var/sqlstamina = sanitizeSQL(L.getStaminaLoss())
	var/coord = sanitizeSQL("[L.x], [L.y], [L.z]")
	var/map = sanitizeSQL(SSmapping.config.map_name)
	var/DBQuery/query_report_death = dbcon.NewQuery("INSERT INTO [format_table_name("death")] (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, toxloss, cloneloss, staminaloss, coord, mapname, server_ip, server_port) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[SQLtime()]', '[laname]', '[lakey]', '[sqlgender]', [sqlbrute], [sqlfire], [sqlbrain], [sqloxy], [sqltox], [sqlclone], [sqlstamina], '[coord]', '[map]', INET_ATON('[world.internet_address]'), '[world.port]')")
	query_report_death.Execute()
