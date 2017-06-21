SUBSYSTEM_DEF(blackbox)
	name = "Blackbox"
	wait = 6000
	flags = SS_NO_TICK_CHECK | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_BLACKBOX

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
	var/list/msg_other = list()

	var/list/feedback = list()	//list of datum/feedback_variable

	var/sealed = FALSE	//time to stop tracking stats?

//poll population
/datum/controller/subsystem/blackbox/fire()
	if(!SSdbcore.Connect())
		return
	var/playercount = 0
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			playercount += 1
	var/admincount = GLOB.admins.len
	var/datum/DBQuery/query_record_playercount = SSdbcore.NewQuery("INSERT INTO [format_table_name("legacy_population")] (playercount, admincount, time, server_ip, server_port) VALUES ([playercount], [admincount], '[SQLtime()]', INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]')")
	query_record_playercount.Execute()

/datum/controller/subsystem/blackbox/Recover()
	msg_common = SSblackbox.msg_common
	msg_science = SSblackbox.msg_science
	msg_command = SSblackbox.msg_command
	msg_medical = SSblackbox.msg_medical
	msg_engineering = SSblackbox.msg_engineering
	msg_security = SSblackbox.msg_security
	msg_deathsquad = SSblackbox.msg_deathsquad
	msg_syndicate = SSblackbox.msg_syndicate
	msg_service = SSblackbox.msg_service
	msg_cargo = SSblackbox.msg_cargo
	msg_other = SSblackbox.msg_other

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
	set_val("ahelp_unresolved", GLOB.ahelp_tickets.active_tickets.len)

	var/pda_msg_amt = 0
	var/rc_msg_amt = 0

	for (var/obj/machinery/message_server/MS in GLOB.message_servers)
		if (MS.pda_msgs.len > pda_msg_amt)
			pda_msg_amt = MS.pda_msgs.len
		if (MS.rc_msgs.len > rc_msg_amt)
			rc_msg_amt = MS.rc_msgs.len

	set_details("radio_usage","")

	add_details("radio_usage","COM-[msg_common.len]")
	add_details("radio_usage","SCI-[msg_science.len]")
	add_details("radio_usage","HEA-[msg_command.len]")
	add_details("radio_usage","MED-[msg_medical.len]")
	add_details("radio_usage","ENG-[msg_engineering.len]")
	add_details("radio_usage","SEC-[msg_security.len]")
	add_details("radio_usage","DTH-[msg_deathsquad.len]")
	add_details("radio_usage","SYN-[msg_syndicate.len]")
	add_details("radio_usage","SRV-[msg_service.len]")
	add_details("radio_usage","CAR-[msg_cargo.len]")
	add_details("radio_usage","OTH-[msg_other.len]")
	add_details("radio_usage","PDA-[pda_msg_amt]")
	add_details("radio_usage","RC-[rc_msg_amt]")

	if (!SSdbcore.Connect())
		return

	var/list/sqlrowlist = list()

	for (var/datum/feedback_variable/FV in feedback)
		sqlrowlist += list(list("time" = "Now()", "round_id" = GLOB.round_id, "var_name" =  "'[sanitizeSQL(FV.get_variable())]'", "var_value" = FV.get_value(), "details" = "'[sanitizeSQL(FV.get_details())]'"))

	if (!length(sqlrowlist))
		return

	SSdbcore.MassInsert(format_table_name("feedback"), sqlrowlist, ignore_errors = TRUE, delayed = TRUE)


/datum/controller/subsystem/blackbox/proc/LogBroadcast(blackbox_msg, freq)
	if(sealed)
		return
	switch(freq)
		if(1459)
			msg_common += blackbox_msg
		if(1351)
			msg_science += blackbox_msg
		if(1353)
			msg_command += blackbox_msg
		if(1355)
			msg_medical += blackbox_msg
		if(1357)
			msg_engineering += blackbox_msg
		if(1359)
			msg_security += blackbox_msg
		if(1441)
			msg_deathsquad += blackbox_msg
		if(1213)
			msg_syndicate += blackbox_msg
		if(1349)
			msg_service += blackbox_msg
		if(1347)
			msg_cargo += blackbox_msg
		else
			msg_other += blackbox_msg

/datum/controller/subsystem/blackbox/proc/find_feedback_datum(variable)
	for(var/datum/feedback_variable/FV in feedback)
		if(FV.get_variable() == variable)
			return FV

	var/datum/feedback_variable/FV = new(variable)
	feedback += FV
	return FV

/datum/controller/subsystem/blackbox/proc/set_val(variable, value)
	if(sealed)
		return
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.set_value(value)

/datum/controller/subsystem/blackbox/proc/inc(variable, value)
	if(sealed)
		return
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.inc(value)

/datum/controller/subsystem/blackbox/proc/dec(variable,value)
	if(sealed)
		return
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.dec(value)

/datum/controller/subsystem/blackbox/proc/set_details(variable,details)
	if(sealed)
		return
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.set_details(details)

/datum/controller/subsystem/blackbox/proc/add_details(variable,details)
	if(sealed)
		return
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.add_details(details)

/datum/controller/subsystem/blackbox/proc/ReportDeath(mob/living/L)
	if(sealed)
		return
	if(!SSdbcore.Connect())
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
	var/map = sanitizeSQL(SSmapping.config.map_name)
	var/datum/DBQuery/query_report_death = SSdbcore.NewQuery("INSERT INTO [format_table_name("death")] (pod, x_coord, y_coord, z_coord, mapname, server_ip, server_port, round_id, tod, job, special, name, byondkey, laname, lakey, bruteloss, fireloss, brainloss, oxyloss, toxloss, cloneloss, staminaloss) VALUES ('[sqlpod]', '[x_coord]', '[y_coord]', '[z_coord]', '[map]', INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]', [GLOB.round_id], '[SQLtime()]', '[sqljob]', '[sqlspecial]', '[sqlname]', '[sqlkey]', '[laname]', '[lakey]', [sqlbrute], [sqlfire], [sqlbrain], [sqloxy], [sqltox], [sqlclone], [sqlstamina])")
	query_report_death.Execute()

/datum/controller/subsystem/blackbox/proc/Seal()
	if(sealed)
		return
	if(IsAdminAdvancedProcCall())
		var/msg = "[key_name_admin(usr)] sealed the blackbox!"
		message_admins(msg)
	log_game("Blackbox sealed[IsAdminAdvancedProcCall() ? " by [key_name(usr)]" : ""].")
	sealed = TRUE

//feedback variable datum, for storing all kinds of data
/datum/feedback_variable
	var/variable
	var/value
	var/details

/datum/feedback_variable/New(param_variable, param_value = 0)
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
