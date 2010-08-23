var/church_name = null
/proc/church_name()
	if (church_name)
		return church_name

	var/name = ""
	
	name += pick("Holy", "United", "First", "Second", "Last")
	
	if (prob(20))
		name += " Space"
	
	name += " " + pick("Church", "Cathedral", "Body", "Worshippers", "Movement", "Witnesses")
	name += " of [religion_name()]"
	
	return name
