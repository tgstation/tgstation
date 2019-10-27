/datum/skill/mining
	name = "Mining"
	desc = "A dwarf's biggest skill, after drinking."

/datum/skill/mining/get_skill_speed_modifier(level)
	switch(level)
		if(SKILL_LEVEL_NONE)
			return 1.3
		if(SKILL_LEVEL_NOVICE)
			return 1.2
		if(SKILL_LEVEL_APPRENTICE)
			return 1.1
		if(SKILL_LEVEL_JOURNEYMAN)
			return 1
		if(SKILL_LEVEL_EXPERT)
			return 0.9
		if(SKILL_LEVEL_MASTER)
			return 0.75
		if(SKILL_LEVEL_LEGENDARY)
			return 0.5
