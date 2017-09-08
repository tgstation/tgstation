/datum/server_tools_command
	var/name = ""	//the string to trigger this command on a chat bot. e.g. TGS3_BOT: do_this_command
	var/help_text = ""	//help text for this command
	var/required_parameters = 0	//number of parameters required for this command
	var/admin_only = FALSE	//set to TRUE if this command should only be usable by registered chat admins

//override to implement command
//sender is the display name of who sent the command
//params is the trimmed string following the command name
/datum/server_tools_command/proc/Run(sender, params)
	CRASH("[type] has no implementation for Run()")

/world/proc/ListServiceCustomCommands(warnings_only)
	if(!warnings_only)
		. = list()
	var/list/command_name_types = list()
	var/list/warned_command_names = warnings_only ? list() : null
	for(var/I in typesof(/datum/server_tools_command) - /datum/server_tools_command)
		var/datum/server_tools_command/stc = I
		var/command_name = initial(stc.name)
		var/static/list/warned_server_tools_names = list()
		if(!command_name || findtext(command_name, " ") || findtext(command_name, "'") || findtext(command_name, "\""))
			if(warnings_only && !warned_command_names[command_name])
				SERVER_TOOLS_LOG("WARNING: Custom command [command_name] can't be used as it is empty or contains illegal characters!")
				warned_command_names[command_name] = TRUE
			continue
		
		if(command_name_types[command_name])
			if(warnings_only)
				SERVER_TOOLS_LOG("WARNING: Custom commands [command_name_types[command_name]] and [stc] have the same name, only [command_name_types[command_name]] will be available!")
			continue
		command_name_types[stc] = command_name

		if(!warnings_only)
			.[command_name] = list(SERVICE_JSON_PARAM_HELPTEXT = initial(stc.help_text), SERVICE_JSON_PARAM_ADMINONLY = initial(stc.admin_only), SERVICE_JSON_PARAM_REQUIREDPARAMETERS = initial(stc.required_parameters))

/world/proc/HandleServiceCustomCommand(command, sender, params)
	for(var/I in typesof(/datum/server_tools_command) - /datum/server_tools_command)
		var/datum/server_tools_command/stc = I
		if(lowertext(initial(stc.name)) == command)
			stc = new stc
			return stc.Run(sender, params) || TRUE
	return FALSE