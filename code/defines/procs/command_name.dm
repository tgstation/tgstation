var/command_name = null
/proc/command_name()
	if (command_name)
		return command_name

	var/name = ""

	if (prob(10))
		name += pick("Super", "Ultra")
		name += " "

	// Prefix
	if (name)
		name += pick("", "Central", "System", "Home", "Primary", "Alpha", "Friend", "Science", "Renegade")
	else
		name += pick("Central", "System", "Home", "Primary", "Alpha", "Friend", "Science", "Renegade")
	if (name)
		name += " "

	// Suffix
	name += pick("Federation", "Command", "Alliance", "Unity", "Empire", "Confederation", "Kingdom", "Monarchy", "Complex", "Protectorate", "Commonwealth", "Imperium", "Republic")
	name += " "

	command_name = name
	return name

