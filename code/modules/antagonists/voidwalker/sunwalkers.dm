/// Space antagonist that murders everyone in space and nearby it using the power of loads of fire
/datum/antagonist/sunwalker
	name = "\improper Sunwalker"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	pref_flag = ROLE_SUNWALKER

	show_in_antagpanel = TRUE
	antagpanel_category = "Voidwalker"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSunwalker"
	suicide_cry = "FOR THE SUN!!"

/datum/antagonist/sunwalker/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/sunwalker/on_gain()
	. = ..()

	forge_objectives()

/datum/antagonist/sunwalker/forge_objectives()
	var/datum/objective/sunwalker/objective = new
	objective.owner = owner
	objectives += objective

/datum/objective/sunwalker

/datum/objective/sunwalker/New()
	var/list/explanation_texts = list(
		"Teach them to fear the void. Overhwelm them with your brilliance, then impart the truth of immolation. Seek to destroy, not enlighten.",
	)
	explanation_text = pick(explanation_texts)

	if(prob(5))
		explanation_text = "Man I fucking love glass."
	..()

/datum/objective/sunwalker/check_completion()
	return owner.current.stat != DEAD
