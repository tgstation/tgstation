var/religion_name = null
/proc/religion_name()
	if (religion_name)
		return religion_name

	var/name = ""
	
	name += pick("bee", "science", "edu", "captain", "assistant", "monkey", "alien", "space", "unit", "sprocket", "gadget", "bomb", "revolution", "beyond", "station", "goon", "robot", "ivor", "hobnob")
	name += pick("ism", "ia", "ology", "istism", "ites", "ick", "ian", "ity")
	
	return capitalize(name)
