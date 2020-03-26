/datum/skill/mining
	name = "Mining"
	desc = "A dwarf's biggest skill, after drinking."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.75, 0.6, 0.5),SKILL_PROBS_MODIFIER=list(10, 15, 20, 25, 30, 35, 40))


/datum/skill/athletics
	name = "Athletics"
	desc = "haha gotta go fast zzzzzzzzzzzew"

/datum/skill/athletics/level_gained(var/datum/mind/mind, new_level, old_level)
	. = ..()
	select_movespeed(mind, new_level, old_level)

/datum/skill/athletics/level_lost(datum/mind/mind, new_level, old_level)
	. = ..()
	select_movespeed(mind, new_level, old_level)


/datum/skill/athletics/proc/select_movespeed(var/datum/mind/mind, new_level, old_level)
	switch(new_level)
		if(SKILL_LEVEL_NONE)
			mind.current.remove_movespeed_modifier("athlete")
		if(SKILL_LEVEL_NOVICE)
			mind.current.add_movespeed_modifier(/datum/movespeed_modifier/beginner_athlete)
		if(SKILL_LEVEL_APPRENTICE)
			mind.current.add_movespeed_modifier(/datum/movespeed_modifier/beginner_athlete)
		if(SKILL_LEVEL_JOURNEYMAN)
			mind.current.add_movespeed_modifier(/datum/movespeed_modifier/okay_athlete)
		if(SKILL_LEVEL_EXPERT)
			mind.current.add_movespeed_modifier(/datum/movespeed_modifier/decent_athlete)
		if(SKILL_LEVEL_MASTER)
			mind.current.add_movespeed_modifier(/datum/movespeed_modifier/professional_athlete)
		if(SKILL_LEVEL_LEGENDARY)
			mind.current.add_movespeed_modifier(/datum/movespeed_modifier/the_flash)
