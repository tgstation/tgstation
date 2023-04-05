/datum/tgs_api/v4/proc/ListCustomCommands()
	var/results = list()
	custom_commands = list()
	for(var/I in typesof(/datum/tgs_chat_command) - /datum/tgs_chat_command)
		var/datum/tgs_chat_command/stc = new I
		if(stc.ignore_type == I)
			continue

		var/command_name = stc.name
		if(!command_name || findtext(command_name, " ") || findtext(command_name, "'") || findtext(command_name, "\""))
			TGS_ERROR_LOG("Custom command [command_name] ([I]) can't be used as it is empty or contains illegal characters!")
			continue

		if(results[command_name])
			var/datum/other = custom_commands[command_name]
			TGS_ERROR_LOG("Custom commands [other.type] and [I] have the same name (\"[command_name]\"), only [other.type] will be available!")
			continue
		results += list(list("name" = command_name, "help_text" = stc.help_text, "admin_only" = stc.admin_only))
		custom_commands[command_name] = stc

	var/commands_file = chat_commands_json_path
	if(!commands_file)
		return
	text2file(json_encode(results), commands_file)

/datum/tgs_api/v4/proc/HandleCustomCommand(command_json)
	var/list/data = json_decode(command_json)
	var/command = data["command"]
	var/user = data["user"]
	var/params = data["params"]

	var/datum/tgs_chat_user/u = new
	u.id = user["id"]
	u.friendly_name = user["friendlyName"]
	u.mention = user["mention"]
	u.channel = DecodeChannel(user["channel"])

	var/datum/tgs_chat_command/sc = custom_commands[command]
	if(sc)
		var/datum/tgs_message_content/result = sc.Run(u, params)
		result = UpgradeDeprecatedCommandResponse(result, command)

		return result?.text
	return "Unknown command: [command]!"
