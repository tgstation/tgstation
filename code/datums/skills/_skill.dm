/datum/skill
	var/name = "Skill"
	var/desc = "the art of doing things"
	var/modifiers = list(SKILL_SPEED_MODIFIER = list(1, 1, 1, 1, 1, 1, 1)) //Dictionary of modifier type - list of modifiers (indexed by level). 7 entries in each list for all 7 skill levels.

/datum/skill/proc/get_skill_modifier(modifier, level)
	return modifiers[modifier][level+1] //+1 because lists start at 1

/datum/skill/proc/level_changed(var/datum/mind/mind, new_level, old_level) //just for announcements (doesn't go off if the xp gain is silent)
	if(new_level >= old_level)
		to_chat(mind.current, "<span class='nicegreen'>I feel like I've become more proficient at [name]!</span>")
	else
		to_chat(mind.current, "<span class='warning'>I feel like I've become worse at [name]!</span>")
