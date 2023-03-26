/datum/antagonist/separatist
	name = "\improper Separatists"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	suicide_cry = "FOR THE MOTHERLAND!!"
	ui_name = "AntagInfoSeparatist"

	///team datum
	var/datum/team/nation/nation
	///background color of the ui
	var/ui_color

/datum/antagonist/separatist/on_gain()
	setup_ui_color()
	return ..()

/datum/antagonist/separatist/on_removal()
	remove_objectives()
	return ..()

//give ais their role as UN
/datum/antagonist/separatist/apply_innate_effects(mob/living/mob_override)
	. = ..()
	if(isAI(mob_override))
		var/mob/living/silicon/ai/united_nations_ai = mob_override
		united_nations_ai.laws = new /datum/ai_laws/united_nations
		united_nations_ai.laws.associate(united_nations_ai)

/datum/antagonist/separatist/create_team(datum/team/nation/new_team)
	if(!new_team)
		return
	nation = new_team

/datum/antagonist/separatist/get_team()
	return nation

/datum/antagonist/separatist/ui_static_data(mob/user)
	var/list/data = list()
	data["objectives"] = get_objectives()
	data["nation"] = nation.name
	data["nationColor"] = ui_color
	return data

/datum/antagonist/separatist/proc/remove_objectives()
	objectives -= nation.objectives

/datum/antagonist/separatist/proc/setup_ui_color()
	var/list/hsl = rgb2num(nation.department.ui_color, COLORSPACE_HSL)
	hsl[3] = 25 //setting lightness very low
	ui_color = rgb(hsl[1], hsl[2], hsl[3], space = COLORSPACE_HSL)
