/datum/tgs_api/v5/proc/ListCustomCommands()
	var/results = list()
	custom_commands = list()
	for(var/I in typesof(/datum/tgs_chat_command) - /datum/tgs_chat_command)
		var/datum/tgs_chat_command/stc = new I
		var/command_name = stc.name
		if(!command_name || findtext(command_name, " ") || findtext(command_name, "'") || findtext(command_name, "\""))
			TGS_WARNING_LOG("Custom command [command_name] ([I]) can't be used as it is empty or contains illegal characters!")
			continue

		if(results[command_name])
			var/datum/other = custom_commands[command_name]
			TGS_WARNING_LOG("Custom commands [other.type] and [I] have the same name (\"[command_name]\"), only [other.type] will be available!")
			continue
		results += list(list(DMAPI5_CUSTOM_CHAT_COMMAND_NAME = command_name, DMAPI5_CUSTOM_CHAT_COMMAND_HELP_TEXT = stc.help_text, DMAPI5_CUSTOM_CHAT_COMMAND_ADMIN_ONLY = stc.admin_only))
		custom_commands[command_name] = stc

	return results

/datum/tgs_api/v5/proc/HandleCustomCommand(list/command_json)
	var/command = command_json[DMAPI5_CHAT_COMMAND_NAME]
	var/user = command_json[DMAPI5_CHAT_COMMAND_USER]
	var/params = command_json[DMAPI5_CHAT_COMMAND_PARAMS]

	var/datum/tgs_chat_user/u = new
	u.id = user[DMAPI5_CHAT_USER_ID]
	u.friendly_name = user[DMAPI5_CHAT_USER_FRIENDLY_NAME]
	u.mention = user[DMAPI5_CHAT_USER_MENTION]
	u.channel = DecodeChannel(user[DMAPI5_CHAT_USER_CHANNEL])

	var/datum/tgs_chat_command/sc = custom_commands[command]
	if(sc)
		var/text_response = sc.Run(u, params)
		var/list/topic_response = list()
		if(!istext(text_response))
			TGS_ERROR_LOG("Custom command [command] should return a string! Got: \"[text_response]\"")
			text_response = null
		topic_response[DMAPI5_TOPIC_RESPONSE_COMMAND_RESPONSE_MESSAGE] = text_response
		return json_encode(topic_response)
	return TopicResponse("Unknown custom chat command: [command]!")
