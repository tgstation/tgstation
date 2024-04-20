/datum/team/brother_team
	var/color
	var/summoned_gear = FALSE
	var/choosing_gear = FALSE
	var/datum/bb_gear/chosen_gear
	var/static/next_color = 1

/datum/team/brother_team/add_brother(mob/living/new_brother, source)
	. = ..()
	roll_for_color()
	update_action_icons()

/datum/team/brother_team/remove_member(datum/mind/member)
	. = ..()
	update_action_icons()

/datum/team/brother_team/proc/roll_for_color()
	if(!isnull(color) || !length(members))
		return
	color = GLOB.color_list_blood_brothers[next_color]
	next_color = WRAP_UP(next_color, length(GLOB.color_list_blood_brothers))

/datum/team/brother_team/proc/update_action_icons()
	for(var/datum/mind/brother as anything in members)
		var/datum/antagonist/brother/blood_bond = brother.has_antag_datum(/datum/antagonist/brother)
		blood_bond?.comms_action?.build_all_button_icons()
		blood_bond?.gear_action?.build_all_button_icons()

/datum/team/brother_team/proc/has_recruited()
	return length(members) > 1

/datum/team/brother_team/proc/fully_recruited()
	return brothers_left < 1

/datum/team/brother_team/proc/summon_gear(mob/living/summoner)
	if(summoned_gear || choosing_gear || !chosen_gear || !fully_recruited() || QDELETED(summoner) || !(summoner.mind in members))
		return FALSE
	summoned_gear = TRUE
	for(var/datum/mind/member as anything in members)
		var/datum/antagonist/brother/blood_bond = member.has_antag_datum(/datum/antagonist/brother)
		to_chat(member.current, span_notice("[summoner.mind.name || summoner.real_name] has summoned their gear, [chosen_gear.name], at [get_area(get_turf(summoner))]!"), type = MESSAGE_TYPE_INFO, avoid_highlighting = (member.current == summoner))
		if(!QDELETED(blood_bond?.gear_action))
			QDEL_NULL(blood_bond.gear_action)
	chosen_gear.summon(summoner, src)
	update_action_icons()
	return TRUE
