/// Space antagonist that harasses people near space and cursed them if they get the chance
/datum/antagonist/voidwalker
	name = "\improper Voidwalker"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	pref_flag = ROLE_VOIDWALKER

	show_in_antagpanel = TRUE
	antagpanel_category = "Voidwalker"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoVoidwalker"
	suicide_cry = "FOR THE VOID!!"

/datum/antagonist/voidwalker/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/voidwalker/on_gain()
	. = ..()

	forge_objectives()

/datum/antagonist/voidwalker/get_preview_icon()
	var/mob/living/basic/voidwalker/walker_type = /mob/living/basic/voidwalker
	var/icon/icon = icon(walker_type::icon, walker_type::icon_state)
	icon.Crop(5, 18, 30, 44)
	return finish_preview_icon(icon)

/datum/antagonist/voidwalker/forge_objectives()
	var/datum/objective/voidwalker_objective/objective = new
	objective.owner = owner
	objectives += objective

/datum/objective/voidwalker_objective

/datum/objective/voidwalker_objective/New()
	var/list/explanation_texts = list(
		"Show them the beauty of the void. Drag them into the cosmic abyss, then impart the truth of the void unto them. Seek to enlighten, not destroy.",
		"They must see what you have seen. They must walk where you have walked. Bring them to the void and show them the truth. The dead cannot know what you know.",
		"Recover what you have lost. Bring your children into the inky black and return them to your flock.",
	)
	explanation_text = pick(explanation_texts)

	if(prob(5))
		explanation_text = "Man I fucking love glass."
	..()

/datum/objective/voidwalker_objective/check_completion()
	return owner.current && owner.current.stat != DEAD
