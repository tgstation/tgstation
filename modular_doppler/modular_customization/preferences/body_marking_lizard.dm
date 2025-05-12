
/// Standard bodymark fixing
/datum/bodypart_overlay/simple/body_marking/lizard
	layers = EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3

/datum/bodypart_overlay/simple/body_marking/lizard/get_image(layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	var/gender_string = (use_gender && limb.is_dimorphic) ? (limb.gender == MALE ? MALE : FEMALE + "_") : "" //we only got male and female sprites
	if(layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		return image(icon, gender_string + icon_state + "_" + limb.body_zone + "_2", layer = layer)
	if(layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		return image(icon, gender_string + icon_state + "_" + limb.body_zone + "_3", layer = layer)
	return image(icon, gender_string + icon_state + "_" + limb.body_zone, layer = layer)

/datum/bodypart_overlay/simple/body_marking/lizard/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["body_markings_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["body_markings_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["body_markings_color_3"]
		return overlay
	return ..()

/datum/preference/choiced/lizard_body_markings/create_default_value()
	return /datum/sprite_accessory/lizard_markings/none::name

/datum/preference/choiced/lizard_body_markings/icon_for(value)
	var/datum/sprite_accessory/sprite_accessory = SSaccessories.lizard_markings_list[value]

	var/static/datum/universal_icon/body
	if (isnull(body))
		body = uni_icon('icons/mob/human/human.dmi', "human_basic", NORTH)
		body.blend_color(COLOR_WEBSAFE_DARK_GRAY, ICON_MULTIPLY)
	var/datum/universal_icon/final_icon = body.copy()

	if(sprite_accessory.icon_state != "none")
		if(icon_exists(sprite_accessory.icon, "male_[sprite_accessory.icon_state]_head"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "[sprite_accessory.icon_state]_head")
			accessory_icon.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "male_[sprite_accessory.icon_state]_chest"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "male_[sprite_accessory.icon_state]_chest")
			accessory_icon.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "male_[sprite_accessory.icon_state]_chest_2"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "male_[sprite_accessory.icon_state]_chest_2")
			accessory_icon.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "male_[sprite_accessory.icon_state]_chest_3"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "male_[sprite_accessory.icon_state]_chest_3")
			accessory_icon.blend_color(COLOR_BLUE, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		// androgenous breaker
		if(icon_exists(sprite_accessory.icon, "[sprite_accessory.icon_state]_head"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "[sprite_accessory.icon_state]_head")
			accessory_icon.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "[sprite_accessory.icon_state]_chest"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "[sprite_accessory.icon_state]_chest")
			accessory_icon.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "[sprite_accessory.icon_state]_chest_2"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "[sprite_accessory.icon_state]_chest_2")
			accessory_icon.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "[sprite_accessory.icon_state]_chest_3"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "[sprite_accessory.icon_state]_chest_3")
			accessory_icon.blend_color(COLOR_BLUE, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		// limbs breaker
		if(icon_exists(sprite_accessory.icon, "[sprite_accessory.icon_state]_l_arm"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "[sprite_accessory.icon_state]_l_arm")
			accessory_icon.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "[sprite_accessory.icon_state]_r_arm"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "[sprite_accessory.icon_state]_r_arm")
			accessory_icon.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "[sprite_accessory.icon_state]_l_leg"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "[sprite_accessory.icon_state]_l_leg")
			accessory_icon.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "[sprite_accessory.icon_state]_r_leg"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "[sprite_accessory.icon_state]_r_leg")
			accessory_icon.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(0, 0, 32, 32)
	final_icon.scale(32, 32)

	return final_icon

//toggle prefs
/datum/preference/toggle/markings
	savefile_key = "has_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/markings/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		target.dna.features["lizard_markings"] = /datum/sprite_accessory/lizard_markings/none::name

/datum/preference/toggle/markings/create_default_value()
	return FALSE

//toggle pref integration
/datum/preference/choiced/lizard_body_markings
	category = PREFERENCE_CATEGORY_CLOTHING

/datum/preference/choiced/lizard_body_markings/is_accessible(datum/preferences/preferences)
	. = ..()
	var/has_markings = preferences.read_preference(/datum/preference/toggle/markings)
	if(has_markings == TRUE)
		return TRUE
	return FALSE

//manually adding them now
/datum/species/add_body_markings(mob/living/carbon/human/hooman)
	. = ..()
	if((hooman.dna.features["lizard_markings"] && hooman.dna.features["lizard_markings"] != /datum/sprite_accessory/lizard_markings/none::name) && (hooman.client?.prefs.read_preference(/datum/preference/toggle/markings)))
		var/datum/bodypart_overlay/simple/body_marking/markings = new /datum/bodypart_overlay/simple/body_marking/lizard() // made to die... mostly because we cant use initial on lists but its convenient and organized
		var/accessory_name = hooman.dna.features[markings.dna_feature_key] //get the accessory name from dna
		var/datum/sprite_accessory/moth_markings/accessory = markings.get_accessory(accessory_name) //get the actual datum

		if(isnull(accessory))
			CRASH("Value: [accessory_name] did not have a corresponding sprite accessory!")

		for(var/obj/item/bodypart/part as anything in markings.applies_to) //check through our limbs
			var/obj/item/bodypart/people_part = hooman.get_bodypart(initial(part.body_zone)) // and see if we have a compatible marking for that limb

			if(!people_part)
				continue

			var/datum/bodypart_overlay/simple/body_marking/overlay = new /datum/bodypart_overlay/simple/body_marking/lizard()

			// Tell the overlay what it should look like
			overlay.icon = accessory.icon
			overlay.icon_state = accessory.icon_state
			overlay.use_gender = accessory.gender_specific
			overlay.draw_color = accessory.color_src ? hooman.dna.features["mcolor"] : null

			people_part.add_bodypart_overlay(overlay)
