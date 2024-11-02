/datum/preference/choiced/markings_head
	savefile_key = "markings_head"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_MARKINGS
	relevant_external_organ = null
	main_feature_name = "Bodymarkings Head"

/datum/preference/choiced/markings_head/init_possible_values()
	return assoc_to_keys_features(SSaccessories.body_markings)

/datum/preference/choiced/markings_head/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/markings_head/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["markings_head"] = value
	testing("value is [value]")

/datum/species/add_body_markings(mob/living/carbon/human/target)
	if(target.dna.features["markings_head"] && target.dna.features["markings_head"] != SPRITE_ACCESSORY_NONE)
		var/obj/item/bodypart/people_part =  target.get_bodypart(BODY_ZONE_HEAD)
		if(people_part)
			var/datum/bodypart_overlay/simple/body_marking/body_markings/markings = new /datum/bodypart_overlay/simple/body_marking/body_markings()
			var/accessory_name = target.dna.features["markings_head"]
			var/datum/sprite_accessory/accessory = markings.get_accessory(accessory_name)
			var/datum/bodypart_overlay/simple/body_marking/overlay = new /datum/bodypart_overlay/simple/body_marking()

			if(isnull(accessory))
				CRASH("Value: [accessory_name] did not have a corresponding sprite accessory!")

			overlay.icon = accessory.icon
			overlay.icon_state = accessory.icon_state
			overlay.use_gender = accessory.gender_specific
			overlay.draw_color = accessory.color_src

			people_part.add_bodypart_overlay(overlay)
	. = ..()

/datum/bodypart_overlay/simple/body_marking/body_markings/get_accessory(name)
	return SSaccessories.body_markings[name]
