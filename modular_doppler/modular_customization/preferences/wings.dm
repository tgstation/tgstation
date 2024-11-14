/// SSAccessories setup
/datum/controller/subsystem/accessories
	var/list/wings_list_more

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()
	wings_list_more = init_sprite_accessory_subtypes(/datum/sprite_accessory/wings_more)["default_sprites"] // FLAKY DEFINE: this should be using DEFAULT_SPRITE_LIST

/datum/dna
	///	This variable is read by the regenerate_organs() proc to know what organ subtype to give
	var/wing_type = NO_VARIATION

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target == null)
		return
	if(!ishuman(target))
		return

	if(target.dna.features["moth_wings"] && !(type in GLOB.species_blacklist_no_mutant))
		if(target.dna.wing_type == NO_VARIATION)
			return .
		if((target.dna.features["moth_wings"] != /datum/sprite_accessory/moth_wings/none::name && target.dna.features["moth_wings"] != /datum/sprite_accessory/blank::name))
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/wings/moth)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	if(target.dna.features["wings"] && !(type in GLOB.species_blacklist_no_mutant))
		if(target.dna.features["wings"] != /datum/sprite_accessory/wings_more/none::name && target.dna.features["wings"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/wings/more)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .

	var/obj/item/organ/wings/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(istype(old_part))
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()


/// Dropdown to select which ears you'll be rocking
/datum/preference/choiced/wing_variation
	savefile_key = "wing_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/choiced/wing_variation/create_default_value()
	return NO_VARIATION

/datum/preference/choiced/wing_variation/init_possible_values()
	return list(NO_VARIATION, "Wings", "Moth Wings")

/datum/preference/choiced/wing_variation/apply_to_human(mob/living/carbon/human/target, chosen_variation)
	target.dna.wing_type = chosen_variation
	switch(chosen_variation)
		if(NO_VARIATION)
			target.dna.features["wings"] = /datum/sprite_accessory/wings_more/none::name
			target.dna.features["moth_wings"] = /datum/sprite_accessory/moth_wings/none::name
		if("Wings")
			target.dna.features["moth_wings"] = /datum/sprite_accessory/moth_wings/none::name
		if("Moth Wings")
			target.dna.features["wings"] = /datum/sprite_accessory/wings_more/none::name

/datum/preference/choiced/wing_variation/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_mutant)
		return FALSE
	return TRUE

//	Wings
/datum/preference/choiced/wings
	savefile_key = "feature_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Wings"

/datum/preference/choiced/wings/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/wing_variation)
	if(chosen_variation == "Wings")
		return TRUE
	return FALSE

/datum/preference/choiced/wings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.wings_list_more)

/datum/preference/choiced/wings/create_default_value()
	return /datum/sprite_accessory/wings_more/none::name

/datum/preference/choiced/wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["wings"] = value

/datum/preference/choiced/wings/icon_for(value)
	var/datum/sprite_accessory/wings = SSaccessories.wings_list_more[value]
	return generate_back_icon(wings, "wings")

//	Moth Wings
/datum/preference/choiced/moth_wings
	category = PREFERENCE_CATEGORY_CLOTHING

/datum/preference/choiced/moth_wings/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/wing_variation)
	if(chosen_variation == "Moth Wings")
		return TRUE
	return FALSE

/datum/preference/choiced/moth_wings/create_default_value()
	return /datum/sprite_accessory/moth_wings/none::name

/// Overwrite lives here
//	This is for the triple color channel
/datum/bodypart_overlay/mutant/wings/more
	layers = EXTERNAL_FRONT | EXTERNAL_FRONT_2 | EXTERNAL_FRONT_3 | EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3 | EXTERNAL_BEHIND | EXTERNAL_BEHIND_2 | EXTERNAL_BEHIND_3
	feature_key_sprite = "wings"

/datum/bodypart_overlay/mutant/wings/more/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT))
		overlay.color = limb.owner.dna.features["wings_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["wings_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND))
		overlay.color = limb.owner.dna.features["wings_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_2))
		overlay.color = limb.owner.dna.features["wings_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["wings_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_2))
		overlay.color = limb.owner.dna.features["wings_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_3))
		overlay.color = limb.owner.dna.features["wings_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["wings_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_3))
		overlay.color = limb.owner.dna.features["wings_color_3"]
		return overlay
	return ..()



/// Overwrite lives here
//	Moth wings have their own bespoke RGB code.
/datum/bodypart_overlay/mutant/wings/moth/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	var/color_intended = COLOR_WHITE

	var/tcol_1 = limb.owner.dna.features["wings_color_1"]
	var/tcol_2 = limb.owner.dna.features["wings_color_2"]
	var/tcol_3 = limb.owner.dna.features["wings_color_3"]
	if(tcol_1 && tcol_2 && tcol_3)
		//this is beyond ugly but it works
		var/r1 = hex2num(copytext(tcol_1, 2, 4)) / 255.0
		var/g1 = hex2num(copytext(tcol_1, 4, 6)) / 255.0
		var/b1 = hex2num(copytext(tcol_1, 6, 8)) / 255.0
		var/r2 = hex2num(copytext(tcol_2, 2, 4)) / 255.0
		var/g2 = hex2num(copytext(tcol_2, 4, 6)) / 255.0
		var/b2 = hex2num(copytext(tcol_2, 6, 8)) / 255.0
		var/r3 = hex2num(copytext(tcol_3, 2, 4)) / 255.0
		var/g3 = hex2num(copytext(tcol_3, 4, 6)) / 255.0
		var/b3 = hex2num(copytext(tcol_3, 6, 8)) / 255.0
		color_intended = list(r1,g1,b1, r2,g2,b2, r3,g3,b3)
	overlay.color = color_intended
	return overlay
