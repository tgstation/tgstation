/datum/skill/gaming
	name = "Gaming"
	desc = "Your proficeny as a gamer. Beat bosses with ease, powergame in Orion Trail, and slam some gamer fuel."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 2, 3, 4, 5, 6, 7))//used to modify damage rolls and prob()s

/datum/skill/gaming/level_changed(var/datum/mind/mind, new_level, old_level)
	..()
	if(new_level <= old_level)
		return
	switch(new_level)
		if(SKILL_LEVEL_JOURNEYMAN)
			to_chat(mind.current, "<span class='nicegreen'>I can see patterns in the arcade games. The optimal healing strats are so obvious now!</span>")
		if(SKILL_LEVEL_LEGENDARY)
			to_chat(mind.current, "<span class='nicegreen'>Maybe gamerfuel actually would help me play better...</span>")
