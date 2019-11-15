/datum/skill/pie_throwing
	name = "Pie Throwing"
	desc = "Clowning tecniques."

/datum/skill/pie_throwing/get_skill_speed_modifier(level)
	switch(level)
		if(SKILL_LEVEL_NONE)
			return 0
		if(SKILL_LEVEL_NOVICE)
			return 10
		if(SKILL_LEVEL_APPRENTICE)
			return 20
		if(SKILL_LEVEL_JOURNEYMAN)
			return 30
		if(SKILL_LEVEL_EXPERT)
			return 40
		if(SKILL_LEVEL_MASTER)
			return 50
		if(SKILL_LEVEL_LEGENDARY)
			return 60
