var/command_name = null
/proc/command_name()
	if (command_name)
		return command_name

	var/name = "NanoTrasen"

	command_name = name
	return name

/proc/change_command_name(var/name)

	command_name = name

	return name
