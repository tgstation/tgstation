/datum/species/get_features()
	var/list/features = ..()

	features += /datum/preference/choiced/taur_type

	GLOB.features_by_species[type] = features

	return features

// dna is a string
/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["taur"] && !(type in GLOB.species_blacklist_no_mutant))
		if(target.dna.features["taur"] != /datum/sprite_accessory/taur/none::name && target.dna.features["taur"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/taur_body/body_to_use = /obj/item/organ/taur_body
			var/datum/sprite_accessory/taur/accessory = SSaccessories.taur_list[target.dna.features["taur"]]
			if (accessory)
				body_to_use = accessory.organ_type
			var/obj/item/organ/replacement  = SSwardrobe.provide_type(body_to_use)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAUR)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()

//core toggle
/datum/preference/toggle/taur
	savefile_key = "has_taur"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/taur/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		target.dna.features["taur"] = /datum/sprite_accessory/taur/none::name

/datum/preference/toggle/taur/create_default_value()
	return FALSE

/datum/preference/toggle/taur/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_mutant)
		return FALSE
	return TRUE

/datum/preference/choiced/taur_type
	savefile_key = "feature_taur"
	main_feature_name = "Taur"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	priority = PREFERENCE_PRIORITY_DEFAULT
	should_generate_icons = TRUE
	can_randomize = FALSE

/datum/preference/choiced/taur_type/icon_for(value)
	var/datum/sprite_accessory/taur/taur_acc = SSaccessories.taur_list[value]
	// TO THOSE RESEARCHING THIS CODE LATER! This initial blank sprite is ESSENTIAL. It allows to sprite to generate even if the initial ADJ sprite is broken or nonexistant.
	var/datum/universal_icon/final_icon = uni_icon('modular_doppler/taurs/icons/taur.dmi', "m_taur_none_ADJ", EAST)
	var/datum/universal_icon/accessory_icon = uni_icon(taur_acc.icon, "m_taur_[taur_acc.icon_state]_[taur_acc.primary_layer]", EAST)
	accessory_icon.blend_color(COLOR_RED, ICON_MULTIPLY)
	var/datum/universal_icon/accessory_icon_2 = null
	if (icon_exists(taur_acc.icon, "m_taur_[taur_acc.icon_state]_[taur_acc.primary_layer]_2"))
		accessory_icon_2 = uni_icon(taur_acc.icon, "m_taur_[taur_acc.icon_state]_[taur_acc.primary_layer]_2", EAST)
		accessory_icon_2.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
	var/datum/universal_icon/accessory_icon_3 = null
	if (icon_exists(taur_acc.icon, "m_taur_[taur_acc.icon_state]_[taur_acc.primary_layer]_3"))
		accessory_icon_3 = uni_icon(taur_acc.icon, "m_taur_[taur_acc.icon_state]_[taur_acc.primary_layer]_3", EAST)
		accessory_icon_3.blend_color(COLOR_BLUE, ICON_MULTIPLY)
	final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
	if (istype(accessory_icon_2))
		final_icon.blend_icon(accessory_icon_2, ICON_OVERLAY)
	if (istype(accessory_icon_3))
		final_icon.blend_icon(accessory_icon_3, ICON_OVERLAY)

	final_icon.scale(64, 32)
	final_icon.shift(EAST, 0, ICON_SIZE_X, ICON_SIZE_Y)


	return final_icon

/datum/preference/choiced/taur_type/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["taur"] = value

/datum/preference/choiced/taur_type/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/has_taur = preferences.read_preference(/datum/preference/toggle/taur)
	if(has_taur == TRUE)
		return TRUE
	return FALSE

/datum/preference/choiced/taur_type/init_possible_values()
	return assoc_to_keys_features(SSaccessories.taur_list)

/datum/preference/choiced/taur_type/create_default_value()
	return /datum/sprite_accessory/taur/none::name

/// SSAccessories setup
/datum/controller/subsystem/accessories
	var/list/taur_list

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()
	taur_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/taur)["default_sprites"]

/datum/bodypart_overlay/mutant/taur_body
	layers = EXTERNAL_FRONT | EXTERNAL_FRONT_2 | EXTERNAL_FRONT_3 | EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3 | EXTERNAL_BEHIND | EXTERNAL_BEHIND_2 | EXTERNAL_BEHIND_3 | EXTERNAL_BODY_FRONT_UNDER_CLOTHES | EXTERNAL_BODY_FRONT_UNDER_CLOTHES_2 | EXTERNAL_BODY_FRONT_UNDER_CLOTHES_3

	feature_key = "taur"
	feature_key_sprite = "taur"

/datum/bodypart_overlay/mutant/taur_body/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	. = ..()

	if (!.)
		return .

	var/obj/item/organ/taur_body/body = bodypart_owner
	if (istype(body))
		if (body.hide_self)
			return FALSE

		var/mob/living/carbon/human/owner = bodypart_owner.owner
		if(!istype(owner))
			return TRUE

		var/obj/item/clothing/suit/worn_suit = owner.wear_suit
		if (istype(worn_suit))
			if((worn_suit.flags_inv & HIDETAIL) && !worn_suit.gets_cropped_on_taurs)
				return TRUE

			if (worn_suit.flags_inv & HIDETAURIFCOMPATIBLE)
				for(var/shape in worn_suit.supported_bodyshapes)
					if(body.external_bodyshapes & shape)
						return FALSE

/datum/bodypart_overlay/mutant/taur_body/get_global_feature_list()
	return SSaccessories.taur_list

/datum/bodypart_overlay/mutant/taur_body/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()

	if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT))
		overlay.color = limb.owner.dna.features["taur_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["taur_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND))
		overlay.color = limb.owner.dna.features["taur_color_1"]
		return overlay
	else if (draw_layer == bitflag_to_layer(EXTERNAL_BODY_FRONT_UNDER_CLOTHES))
		overlay.color = limb.owner.dna.features["taur_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_2))
		overlay.color = limb.owner.dna.features["taur_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["taur_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_2))
		overlay.color = limb.owner.dna.features["taur_color_2"]
		return overlay
	else if (draw_layer == bitflag_to_layer(EXTERNAL_BODY_FRONT_UNDER_CLOTHES_2))
		overlay.color = limb.owner.dna.features["taur_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_3))
		overlay.color = limb.owner.dna.features["taur_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["taur_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_3))
		overlay.color = limb.owner.dna.features["taur_color_3"]
		return overlay
	else if (draw_layer == bitflag_to_layer(EXTERNAL_BODY_FRONT_UNDER_CLOTHES_3))
		overlay.color = limb.owner.dna.features["taur_color_3"]
		return overlay
	return ..()
