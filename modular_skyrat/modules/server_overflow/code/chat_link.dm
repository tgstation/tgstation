

/proc/send_ooc_to_other_server(ckey, message)
	if(!CONFIG_GET(flag/secondary_server_enabled))
		return
	var/list/ooc_information = list()
	ooc_information["server_name"] = CONFIG_GET(string/our_server_name)
	ooc_information["expected_ckey"] = ckey(ckey)
	ooc_information["message"] = message
	var/second_server = CONFIG_GET(string/server_two_ip)
	if(!second_server)
		message_admins("SERVER CONTROL CRITICAL ERROR: No second server IP set in config!")
		return
	send2otherserver(station_name(), null, "incoming_ooc_message", second_server, ooc_information)

/datum/world_topic/incoming_ooc_message
	keyword = "incoming_ooc_message"
	require_comms_key = TRUE

/datum/world_topic/incoming_ooc_message/Run(list/input)
	var/server_name = input["server_name"]
	var/exp_ckey = ckey(input["expected_ckey"])
	var/message = input["message"]

	send_ooc_message("[server_name] - [exp_ckey]", message)

/proc/send_ooc_message(sender_name, message)
	if(!GLOB.ooc_allowed)
		return
	for(var/client/C in GLOB.clients)
		if(C.prefs.chat_toggles & CHAT_OOC)
			if(GLOB.OOC_COLOR)
				to_chat(C, "<span class='oocplain'><font color='[GLOB.OOC_COLOR]'><b><span class='prefix'>OOC:</span> <EM>[sender_name]:</EM> <span class='message linkify'>[message]</span></b></font></span>")
			else
				to_chat(C, "<span class='ooc'><span class='prefix'>OOC:</span> <EM>[sender_name]:</EM> <span class='message linkify'>[message]</span></span>")
