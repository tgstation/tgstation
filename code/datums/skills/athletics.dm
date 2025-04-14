/datum/skill/athletics
	name = "Athletics"
	title = "Athlete"
	desc = "Twinkle twinkle little star, hit the gym and lift the bar."
	// The skill value modifier effects the max duration that is possible for /datum/status_effect/exercised; The rands modifier determines block probability and crit probability while boxing against boxers
	modifiers = list(
		SKILL_VALUE_MODIFIER = list(
			1 MINUTES,
			1.5 MINUTES,
			2 MINUTES,
			2.5 MINUTES,
			3 MINUTES,
			3.5 MINUTES,
			5 MINUTES
		),
		SKILL_RANDS_MODIFIER = list(
			0,
			5,
			10,
			15,
			20,
			30,
			50
		)
	)

	skill_item_path = /obj/item/clothing/gloves/boxing/golden

/datum/skill/athletics/New()
	. = ..()
	levelUpMessages[SKILL_LEVEL_NOVICE] = span_nicegreen("I am just getting started on my [name] journey! I think I should be able to identify other people who are working to improve their body by sight.")
	levelUpMessages[SKILL_LEVEL_APPRENTICE] = span_nicegreen("I've created a routine for myself, I can more efficiently exercise multiple muscle groups at once.")
	levelUpMessages[SKILL_LEVEL_JOURNEYMAN] = span_nicegreen("When I exercise, its like I enter a trance. There is nothing in the universe but me and my routine.")
	levelUpMessages[SKILL_LEVEL_EXPERT] = span_nicegreen("I have reached a level of physicality that any person would be proud of.")
	levelUpMessages[SKILL_LEVEL_MASTER] = span_nicegreen("I feel like I could fistfight a gorilla and win.")
	levelUpMessages[SKILL_LEVEL_LEGENDARY] = span_nicegreen("I feel like I have reached a plateau in my athletic abilities. I must get stronger, I must go further beyond!")
	levelUpMessages[SKILL_LEVEL_MYTHICAL] = span_nicegreen("I have reached godlike physical ability. I feel as if I could finally beat the RD in an Arm Wrestling match!")

/datum/skill/athletics/level_gained(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	if(new_level >= SKILL_LEVEL_NOVICE && old_level < SKILL_LEVEL_NOVICE)
		ADD_TRAIT(mind, TRAIT_EXAMINE_FITNESS, SKILL_TRAIT)

/datum/skill/athletics/level_lost(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	if(old_level >= SKILL_LEVEL_NOVICE && new_level < SKILL_LEVEL_NOVICE)
		REMOVE_TRAIT(mind, TRAIT_EXAMINE_FITNESS, SKILL_TRAIT)

/datum/skill/athletics/level_gained(datum/mind/mind, new_level, old_level, silent) //Adds rod suplexing ability to mythical individuals
	. = ..()
	if(new_level == SKILL_LEVEL_MYTHICAL && old_level < SKILL_LEVEL_MYTHICAL)
		ADD_TRAIT(mind, TRAIT_ROD_SUPLEX, SKILL_TRAIT)

/datum/skill/athletics/level_lost(datum/mind/mind, new_level, old_level, silent) //Removes rod suplexing ability from wimps
	. = ..()
	if(old_level == SKILL_LEVEL_MYTHICAL && new_level < SKILL_LEVEL_MYTHICAL)
		REMOVE_TRAIT(mind, TRAIT_ROD_SUPLEX, SKILL_TRAIT)
