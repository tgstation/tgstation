/proc/moth_name(gender)
	if(gender == MALE)
		return "[pick(GLOB.moth_names_male)]"
	else
		return "[pick(GLOB.moth_names_female)]"