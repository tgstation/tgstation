/datum/server_tools_command
	var/name = ""	//the string to trigger this command on a chat bot. e.g. TGS3_BOT: do_this_command
	var/help_text = ""	//help text for this command
	var/admin_only = FALSE	//set to TRUE if this command should only be usable by registered chat admins

//override to implement command, params is the trimmed string following the command name
/datum/server_tools_command/proc/Run(params)
	ASSERT(type != /datum/server_tools_command)
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
			.[command_name] = list("help_text" = initial(stc.help_text), "admin_only" = initial(stc.admin_only))

/world/proc/HandleServiceCustomCommand(command, params)
	for(var/I in typesof(/datum/server_tools_command) - /datum/server_tools_command)
		var/datum/server_tools_command/stc = I
		if(lowertext(initial(I.name)) == command)
			stc = new stc
			return stc.Run(params) || TRUE
	return FALSE