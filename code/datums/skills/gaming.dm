/datum/skill/gaming
	name = "Gaming"
	desc = "My proficiency as a gamer. This helps me beat bosses with ease, powergame in Orion Trail, and makes me wanna slam some gamer fuel."
	modifiers = list(SKILL_PROBS_MODIFIER = list(0, 5, 10, 15, 15, 20, 25),
				SKILL_RANDS_MODIFIER = list(0, 1, 2, 3, 4, 5, 7))

/datum/skill/gaming/level_gained(var/datum/mind/mind, new_level, old_level)
	switch(new_level)
		if(SKILL_LEVEL_JOURNEYMAN)//gives slight extra perks outside roll modifiers
			to_chat(mind.current, "<span class='nicegreen'>I'm starting to pick up the meta of these arcade games. \
			If I were to minmax the optimal strat and accentuate my playstyle around well-refined tech...</span>")
		if(SKILL_LEVEL_LEGENDARY)//leads to a mysterious power...
			to_chat(mind.current, "<span class='nicegreen'>Maybe gamerfuel actually would help me play better...</span>")
		else
			to_chat(mind.current, "<span class='nicegreen'>I'm getting better at these arcade games!</span>")
