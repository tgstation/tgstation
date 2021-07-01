/datum/skill/gaming
	name = "Gaming"
	title = "Gamer"
	desc = "My proficiency as a gamer. This helps me beat bosses with ease, powergame in Orion Trail, and makes me wanna slam some gamer fuel."
	modifiers = list(SKILL_PROBS_MODIFIER = list(0, 5, 10, 15, 15, 20, 25),
				SKILL_RANDS_MODIFIER = list(0, 1, 2, 3, 4, 5, 7))
	skill_cape_path = /obj/item/clothing/neck/cloak/skill_reward/gaming

/datum/skill/gaming/New()
	. = ..()
	levelUpMessages[1] = "<span class='nicegreen'>I'm starting to get a hang of the controls of these games...</span>"
	levelUpMessages[4] = "<span class='nicegreen'>I'm starting to pick up the meta of these arcade games. If I were to minmax the optimal strat and accentuate my playstyle around well-refined tech...</span>"
	levelUpMessages[6] = "<span class='nicegreen'>Through incredible determination and effort, I've reached the peak of my [name] abilities. I wonder how I can become any more powerful... Maybe gamer fuel would actually help me play better..?</span>"
