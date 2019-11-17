/datum/skill/pie_throwing
	name = "pie throwing"
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
			return 25
		if(SKILL_LEVEL_EXPERT)
			return 30
		if(SKILL_LEVEL_MASTER)
			return 35
		if(SKILL_LEVEL_LEGENDARY)
			return 50
