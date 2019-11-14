/datum/skill/pie_throwing
	name = "Pie Throwing"
	desc = "Clowning tecniques."

/datum/skill/pie_throwing/get_skill_speed_modifier(level)
	switch(level)
		if(SKILL_LEVEL_NONE)
			return 0
		if(SKILL_LEVEL_NOVICE)
			return 0
		if(SKILL_LEVEL_APPRENTICE)
			return 1
		if(SKILL_LEVEL_JOURNEYMAN)
			return 2
		if(SKILL_LEVEL_EXPERT)
			return 3
		if(SKILL_LEVEL_MASTER)
			return 4
		if(SKILL_LEVEL_LEGENDARY)
			return 5