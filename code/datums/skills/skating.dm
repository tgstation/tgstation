/datum/skill/skating
	name = "Skating"
	desc = "How good you are at skating. Decides how quickly you tire out from tricks, and has some special bonuses along the way."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.8, 0.6, 0.5, 0.4, 0.4, 0.2)) //instability of a skateboard / this number

/datum/skill/skating/level_changed(var/datum/mind/mind, new_level, old_level)
	..()
	if(new_level <= old_level)
		return //no info dumps if you're losing xp because you got it on levelup
	switch(new_level)
		if(SKILL_LEVEL_JOURNEYMAN)
			to_chat(mind.current, "<span class='nicegreen'>I'm getting the hang of [name]! I should be able to drop into riding the board immediately from my hand.</span>")
		if(SKILL_LEVEL_MASTER)
			to_chat(mind.current, "<span class='nicegreen'>I'm the lord of the gnar! I can now ollie over living creatures of all kinds!</span>")
