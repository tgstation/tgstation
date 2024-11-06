///
// Abstract types
///

/datum/preference/choiced/markings
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_MARKINGS
	abstract_type = /datum/preference/choiced/markings
	relevant_external_organ = null
	var/body_zone
	var/markingval

/datum/preference/choiced/markings/init_possible_values()
	var/datum/bodypart_overlay/simple/body_marking/body_markings/markings = new /datum/bodypart_overlay/simple/body_marking/body_markings()
	var/list/returnval = list()
	var/list/allmarkings = assoc_to_keys_features(SSaccessories.body_markings)
	for(var/i in allmarkings)
		var/datum/sprite_accessory/body_marking/accessory = markings.get_accessory(i)
		if(accessory.body_zones & body_zone)
			returnval += i
	return returnval

/datum/preference/choiced/markings/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/markings/apply_to_human(mob/living/carbon/human/target, value)

	if(value == SPRITE_ACCESSORY_NONE)
		return

	if(!target.dna.features["markings_list"])
		var/list/markings_listt = list()
		LAZYSETLEN(markings_listt, MARKING_LIST_LEN)
		target.dna.features["markings_list"] = markings_listt

	if(!target.dna.features["markings_list_zones"])
		var/list/markings_listt = list()
		LAZYSETLEN(markings_listt, MARKING_LIST_LEN)
		target.dna.features["markings_list_zones"] = markings_listt

	target.dna.features["markings_list"][markingval] = value
	target.dna.features["markings_list_zones"][markingval] = body_zone

/datum/preference/color/markings
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_MARKINGS
	relevant_head_flag = null
	abstract_type = /datum/preference/color/markings
	var/markingval

/datum/preference/color/markings/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.features["markings_list_colors"])
		var/list/markings_listt = list()
		LAZYSETLEN(markings_listt, MARKING_LIST_LEN)
		target.dna.features["markings_list_colors"] = markings_listt

	target.dna.features["markings_list_colors"][markingval] = value

///
// Proc overloads
///

/datum/species/proc/add_doppler_markings(mob/living/carbon/human/target, value, colorvalue, bodypart)
	bodypart = cover_flags2body_zones(bodypart)
	bodypart = bodypart[1]
	var/obj/item/bodypart/people_part =  target.get_bodypart(bodypart)
	if(people_part)
		var/datum/bodypart_overlay/simple/body_marking/body_markings/markings = new /datum/bodypart_overlay/simple/body_marking/body_markings()
		var/accessory_name = value
		var/datum/sprite_accessory/accessory = markings.get_accessory(accessory_name)
		var/datum/bodypart_overlay/simple/body_marking/overlay = new /datum/bodypart_overlay/simple/body_marking()

		if(isnull(accessory))
			CRASH("Value: [accessory_name] did not have a corresponding sprite accessory!")

		overlay.icon = accessory.icon
		overlay.icon_state = accessory.icon_state
		overlay.use_gender = accessory.gender_specific
		overlay.draw_color = colorvalue || accessory.color_src
		people_part.add_bodypart_overlay(overlay)

/datum/species/add_body_markings(mob/living/carbon/human/target)
	. = ..()

	if(target.dna.features["markings_list"])
		var/list/markingslist = target.dna.features["markings_list"]
		for(var/i in 1 to markingslist.len)
			if(markingslist[i] && markingslist[i] != SPRITE_ACCESSORY_NONE)
				add_doppler_markings(target, target.dna.features["markings_list"][i], target.dna.features["markings_list_colors"][i], target.dna.features["markings_list_zones"][i])

/datum/bodypart_overlay/simple/body_marking/body_markings/get_accessory(name)
	return SSaccessories.body_markings[name]

/datum/preference/color/markings/markings_r_leg3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_leg2) != SPRITE_ACCESSORY_NONE

#undef MARKING_LIST_LEN
