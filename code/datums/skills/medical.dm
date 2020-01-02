/datum/skill/medical
	name = "Medical"
	desc = "From Bandaids to biopsies, this improves your ability to get people back up both in the field and on the operating table."

/datum/skill/medical/get_skill_speed_modifier(level)
	switch(level)
		if(SKILL_LEVEL_NONE)
			return 1
		if(SKILL_LEVEL_NOVICE)
			return 0.95
		if(SKILL_LEVEL_APPRENTICE)
			return 0.9
		if(SKILL_LEVEL_JOURNEYMAN)
			return 0.85
		if(SKILL_LEVEL_EXPERT)
			return 0.75
		if(SKILL_LEVEL_MASTER)
			return 0.6
		if(SKILL_LEVEL_LEGENDARY)
			return 0.5
