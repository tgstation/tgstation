/datum/antagonist/voidwalker
	name = "\improper Voidwalker"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	job_rank = ROLE_VOIDWALKER
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoVoidwalker"
	suicide_cry = "FOR THE VOID!!"
	preview_outfit = /datum/outfit/voidwalker

/datum/antagonist/voidwalker/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/voidwalker/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/nightmare/forge_objectives()
	var/datum/objective/voidwalker_fluff/objective = new
	objective.owner = owner
	objectives += objective

/datum/outfit/voidwalker
	name = "Voidwalker (Preview only)"

/datum/outfit/voidwalker/post_equip(mob/living/carbon/human/human, visualsOnly)
	human.set_species(/datum/species/voidling)

/datum/objective/voidwalker_fluff

/datum/objective/voidwalker_fluff/New()
	var/list/explanation_texts = list(
		"Show them the beauty of the void.",
		"Hunt the gravlings.",
		"Be somewhat unsettling.",
		"Man I fucking love glass.",
		"Wooohhhhhh be spooky!"
	)
	explanation_text = pick(explanation_texts)
	..()

/datum/objective/voidwalker_fluff/check_completion()
	return owner.current.stat != DEAD


