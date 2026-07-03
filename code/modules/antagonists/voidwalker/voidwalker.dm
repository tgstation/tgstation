/// Space antagonist that harasses people near space and cursed them if they get the chance
/datum/antagonist/voidwalker
	name = "\improper Войдволкер"
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
	var/datum/universal_icon/icon = uni_icon(walker_type::icon, walker_type::icon_state)
	icon.crop(5, 18, 30, 44)
	return finish_preview_icon(icon)

/datum/antagonist/voidwalker/forge_objectives()
	var/datum/objective/voidwalker_objective/objective = new
	objective.owner = owner
	objectives += objective

/datum/objective/voidwalker_objective

/datum/objective/voidwalker_objective/New()
	var/list/explanation_texts = list(
		"Покажи им красоту пустоты. Увлеки их в космическую бездну, а затем передай им истину о пустоте. Стремись просвещать, а не разрушать.",
		"Они должны увидеть то, что видели вы. Они должны пройти там, где прошли вы. Отведите их в пустоту и покажите им правду. Мёртвые не могут знать того, что знаете вы.",
		"Верните себе утраченное. Приведите своих детей чернильную тьму и верните их в свою паству.",
	)
	explanation_text = pick(explanation_texts)

	if(prob(5))
		explanation_text = "Чувак, я чертовски люблю стекло."
	..()

/datum/objective/voidwalker_objective/check_completion()
	return owner.current && owner.current.stat != DEAD
