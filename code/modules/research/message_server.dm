var/global/list/obj/machinery/message_server/message_servers = list()

/datum/data_pda_msg
	var/recipient = "Unspecified" //name of the person
	var/sender = "Unspecified" //name of the sender
	var/message = "Blank" //transferred message
	var/image/photo = null //Attached photo

/datum/data_pda_msg/New(var/param_rec = "",var/param_sender = "",var/param_message = "",var/param_photo=null)

	if(param_rec)
		recipient = param_rec
	if(param_sender)
		sender = param_sender
	if(param_message)
		message = param_message
	if(param_photo)
		photo = param_photo

/datum/data_pda_msg/proc/get_photo_ref()
	if(photo)
		return "<a href='byond://?src=\ref[src];photo=1'>(Photo)</a>"
	return ""

/datum/data_pda_msg/Topic(href,href_list)
	..()
	if(href_list["photo"])
		var/mob/M = usr
		M << browse_rsc(photo, "pda_photo.png")
		M << browse("<html><head><title>PDA Photo</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='pda_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "</body></html>", "window=book;size=192x192")
		onclose(M, "PDA Photo")

/datum/data_rc_msg
	var/rec_dpt = "Unspecified" //name of the person
	var/send_dpt = "Unspecified" //name of the sender
	var/message = "Blank" //transferred message
	var/stamp = "Unstamped"
	var/id_auth = "Unauthenticated"
	var/priority = "Normal"

/datum/data_rc_msg/New(var/param_rec = "",var/param_sender = "",var/param_message = "",var/param_stamp = "",var/param_id_auth = "",var/param_priority)
	if(param_rec)
		rec_dpt = param_rec
	if(param_sender)
		send_dpt = param_sender
	if(param_message)
		message = param_message
	if(param_stamp)
		stamp = param_stamp
	if(param_id_auth)
		id_auth = param_id_auth
	if(param_priority)
		switch(param_priority)
			if(1)
				priority = "Normal"
			if(2)
				priority = "High"
			if(3)
				priority = "Extreme"
			else
				priority = "Undetermined"

/obj/machinery/message_server
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	name = "Messaging Server"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100

	var/list/datum/data_pda_msg/pda_msgs = list()
	var/list/datum/data_rc_msg/rc_msgs = list()
	var/active = 1
	var/decryptkey = "password"

/obj/machinery/message_server/New()
	message_servers += src
	decryptkey = GenerateKey()
	send_pda_message("System Administrator", "system", "This is an automated message. The messaging system is functioning correctly.")
	..()
	return

/obj/machinery/message_server/Destroy()
	message_servers -= src
	return ..()

/obj/machinery/message_server/proc/GenerateKey()
	//Feel free to move to Helpers.
	var/newKey
	newKey += pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	newKey += pick("diamond", "beer", "mushroom", "assistant", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	newKey += pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	return newKey

/obj/machinery/message_server/process()
	//if(decryptkey == "password")
	//	decryptkey = generateKey()
	if(active && (stat & (BROKEN|NOPOWER)))
		active = 0
		return
	update_icon()
	return

/obj/machinery/message_server/proc/send_pda_message(recipient = "",sender = "",message = "",photo=null)
	. = new/datum/data_pda_msg(recipient,sender,message,photo)
	pda_msgs += .

/obj/machinery/message_server/proc/send_rc_message(recipient = "",sender = "",message = "",stamp = "", id_auth = "", priority = 1)
	rc_msgs += new/datum/data_rc_msg(recipient,sender,message,stamp,id_auth)

/obj/machinery/message_server/attack_hand(mob/user)
	user << "You toggle PDA message passing from [active ? "On" : "Off"] to [active ? "Off" : "On"]"
	active = !active
	update_icon()

	return

/obj/machinery/message_server/update_icon()
	if((stat & (BROKEN|NOPOWER)))
		icon_state = "server-nopower"
	else if (!active)
		icon_state = "server-off"
	else
		icon_state = "server-on"

	return


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

var/obj/machinery/blackbox_recorder/blackbox

/obj/machinery/blackbox_recorder
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	name = "Blackbox Recorder"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	armor = list(melee = 25, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70)
	var/list/messages = list()		//Stores messages of non-standard frequencies
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

	//Only one can exsist in the world!
/obj/machinery/blackbox_recorder/New()
	if (blackbox)
		if (istype(blackbox,/obj/machinery/blackbox_recorder))
			qdel(src)
	blackbox = src


/obj/machinery/blackbox_recorder/Destroy()
	var/turf/T = locate(1,1,2)
	if (T)
		blackbox = null
		var/obj/machinery/blackbox_recorder/BR = new/obj/machinery/blackbox_recorder(T)
		BR.msg_common = msg_common
		BR.msg_science = msg_science
		BR.msg_command = msg_command
		BR.msg_medical = msg_medical
		BR.msg_engineering = msg_engineering
		BR.msg_security = msg_security
		BR.msg_deathsquad = msg_deathsquad
		BR.msg_syndicate = msg_syndicate
		BR.msg_service = msg_service
		BR.msg_cargo = msg_cargo
		BR.feedback = feedback
		BR.messages = messages
		BR.messages_admin = messages_admin
		if(blackbox != BR)
			blackbox = BR
	return ..()

/obj/machinery/blackbox_recorder/proc/find_feedback_datum(variable)
	for (var/datum/feedback_variable/FV in feedback)
		if (FV.get_variable() == variable)
			return FV
	var/datum/feedback_variable/FV = new(variable)
	feedback += FV
	return FV

/obj/machinery/blackbox_recorder/proc/get_round_feedback()
	return feedback

/obj/machinery/blackbox_recorder/proc/round_end_data_gathering()

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
/obj/machinery/blackbox_recorder/proc/save_all_data_to_sql()
	if (!feedback) return

	round_end_data_gathering() //round_end time logging and some other data processing
	establish_db_connection()
	if (!dbcon.IsConnected()) return
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
	if (!blackbox) return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if (!FV) return

	FV.set_value(value)

/proc/feedback_inc(variable,value)
	if (!blackbox) return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if (!FV) return

	FV.inc(value)

/proc/feedback_dec(variable,value)
	if (!blackbox) return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if (!FV) return

	FV.dec(value)

/proc/feedback_set_details(variable,details)
	if (!blackbox) return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV) return

	FV.set_details(details)

/proc/feedback_add_details(variable,details)
	if (!blackbox) return

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if (!FV) return

	FV.add_details(details)
