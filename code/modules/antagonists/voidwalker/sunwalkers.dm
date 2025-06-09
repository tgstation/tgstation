/// Space antagonist that harasses people near space and cursed them if they get the chance
/datum/antagonist/sunwalker
	name = "\improper Sunwalker"
	antagpanel_category = ANTAG_GROUP_HORRORS
	job_rank = ROLE_VOIDWALKER
	show_in_antagpanel = TRUE
	antagpanel_category = "Voidwalker"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoVoidwalker"
	suicide_cry = "FOR THE VOID!!"

/datum/antagonist/sunwalker/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/sunwalker/on_gain()
	. = ..()

	forge_objectives()

/datum/antagonist/sunwalker/get_preview_icon()
	var/mob/living/basic/voidwalker/sunwalker/walker_type = /mob/living/basic/voidwalker/sunwalker
	finish_preview_icon(icon(walker_type::icon, walker_type::icon_state))

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
