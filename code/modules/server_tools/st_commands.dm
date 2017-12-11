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
	var/static/list/cached_custom_server_tools_commands
	if(!cached_custom_server_tools_commands)
		cached_custom_server_tools_commands = list()
		for(var/I in typesof(/datum/server_tools_command) - /datum/server_tools_command)
			var/datum/server_tools_command/stc = I
			cached_custom_server_tools_commands[lowertext(initial(stc.name))] = stc

	var/command_type = cached_custom_server_tools_commands[command]
	if(!command_type)
		return FALSE
	var/datum/server_tools_command/stc = new command_type
	return stc.Run(sender, params) || TRUE

/*
The MIT License

Copyright (c) 2017 Jordan Brown

Permission is hereby granted, free of charge, 
to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to 
deal in the Software without restriction, including 
without limitation the rights to use, copy, modify, 
merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom 
the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice 
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
