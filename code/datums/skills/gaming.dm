/datum/skill/gaming
	name = "Gaming"
	desc = "Your proficeny as a gamer. Beat bosses with ease, powergame in Orion Trail, and slam some gamer fuel."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 2, 3, 4, 5, 6, 7))//used to modify damage rolls and prob()s

/datum/skill/gaming/level_changed(var/datum/mind/mind, new_level, old_level)
	switch(new_level)
		if(SKILL_LEVEL_JOURNEYMAN)
			to_chat(mind.current, "<span class='nicegreen'>I'm starting to pick up the meta of these arcade games. \
			If I were to minmax the optimal strat and accentuate my playstyle around well-refined tech...</span>")
		if(SKILL_LEVEL_LEGENDARY)
			to_chat(mind.current, "<span class='nicegreen'>Maybe gamerfuel actually would help me play better...</span>")
		else
			to_chat(mind.current, "<span class='nicegreen'>I'm getting better at these arcade games.</span>")
