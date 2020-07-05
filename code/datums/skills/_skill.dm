/datum/skill
	var/name = "Skill"
	var/desc = "the art of doing things"
	var/modifiers = list(SKILL_SPEED_MODIFIER = list(1, 1, 1, 1, 1, 1, 1)) //Dictionary of modifier type - list of modifiers (indexed by level). 7 entries in each list for all 7 skill levels.

/datum/skill/proc/get_skill_modifier(modifier, level)
	return modifiers[modifier][level+1] //+1 because lists start at 1

/**
  * level_gained: Gives skill levelup messages to the user
  *
  * Only fires if the xp gain isn't silent, so only really useful for messages.
  * Arguments:
  * * mind - The mind that you'll want to send messages
  * * new_level - The newly gained level. Can check the actual level to give different messages at different levels, see defines in skills.dm
  * * old_level - Similar to the above, but the level you had before levelling up.
  */
/datum/skill/proc/level_gained(var/datum/mind/mind, new_level, old_level)//just for announcements (doesn't go off if the xp gain is silent)
	to_chat(mind.current, "<span class='nicegreen'>I feel like I've become more proficient at [name]!</span>")

/**
  * level_lost: See level_gained, same idea but fires on skill level-down
  */
/datum/skill/proc/level_lost(var/datum/mind/mind, new_level, old_level)
	to_chat(mind.current, "<span class='warning'>I feel like I've become worse at [name]!</span>")
