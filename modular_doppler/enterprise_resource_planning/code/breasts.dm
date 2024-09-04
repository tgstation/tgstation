/datum/species/get_features()
	var/list/features = ..()

	features += /datum/preference/choiced/breasts

	GLOB.features_by_species[type] = features

	return features



/// SSAccessories setup
/datum/controller/subsystem/accessories
	var/list/breasts_list

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()
	breasts_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/breasts)["default_sprites"] // FLAKY DEFINE: this should be using DEFAULT_SPRITE_LIST
	//damnit SSAccessories



/// The boobage in question
/obj/item/organ/external/breasts
	name = "breasts"
	desc = "Super-effective at deterring ice dragons."
	icon_state = "snout"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_BREASTS

	preference = "feature_breasts"
	//external_bodyshapes = BODYSHAPE_SNOUTED

	dna_block = DNA_BREASTS_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/breasts

/datum/bodypart_overlay/mutant/breasts
	layers = EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3 | EXTERNAL_BEHIND | EXTERNAL_BEHIND_2 | EXTERNAL_BEHIND_3
	feature_key = "breasts"

/datum/bodypart_overlay/mutant/breasts/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(human.undershirt != "Nude")
		return FALSE
	if((human.w_uniform && human.w_uniform.body_parts_covered & CHEST) || (human.wear_suit && human.wear_suit.body_parts_covered & CHEST))
		return FALSE
	return TRUE

/datum/bodypart_overlay/mutant/breasts/get_global_feature_list()
	return SSaccessories.breasts_list

/datum/bodypart_overlay/mutant/breasts/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["breasts_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND))
		overlay.color = limb.owner.dna.features["breasts_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["breasts_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_2))
		overlay.color = limb.owner.dna.features["breasts_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["breasts_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_3))
		overlay.color = limb.owner.dna.features["breasts_color_3"]
		return overlay
	return ..()

/datum/bodypart_overlay/mutant/breasts/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(-(UNIFORM_LAYER + 0.09))
			return "ADJ"
		if(-(UNIFORM_LAYER + 0.08))
			return "ADJ_2"
		if(-(UNIFORM_LAYER + 0.07))
			return "ADJ_3"
	return ..()

/datum/bodypart_overlay/mutant/breasts/bitflag_to_layer(layer)
	switch(layer)
		if(EXTERNAL_ADJACENT)
			return -(UNIFORM_LAYER + 0.09)
		if(EXTERNAL_ADJACENT_2)
			return -(UNIFORM_LAYER + 0.08)
		if(EXTERNAL_ADJACENT_3)
			return -(UNIFORM_LAYER + 0.07)
	return ..()


/// Main breast prefs
//core toggle
/datum/preference/toggle/breasts
	savefile_key = "has_breasts"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/breasts/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		//to_chat(world, "Begone, boobs.")
		target.dna.features["breasts"] = "Bare"

/datum/preference/toggle/breasts/create_default_value()
	return FALSE

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	/*to_chat(world, "Regenerating organs for [target], a [src], trying to add boobs")
	for(var/feature in target.dna.features)
		to_chat(world, "[target] has feature [feature]")*/
	if(target.dna.features["breasts"])
		//to_chat(world, "Boobs are in the features list, adding [target.dna.features["breasts"]]")
		if(target.dna.features["breasts"] != "Bare")
			//to_chat(world, "Boob type valid, trying to insert [target.dna.features["breasts"]]")
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/external/breasts)
			//to_chat(world, "Inserted boobage exists: [replacement]")
			//replacement.build_from_dna(target.dna, "breasts") //TODO: do we need to add this
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			//to_chat(world, "Boobs inserted, new state is [target.dna.features["breasts"]]")
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_BREASTS)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()



//sprite selection
/datum/preference/choiced/breasts
	savefile_key = "feature_breasts"
	savefile_identifier = PREFERENCE_CHARACTER
	//category = PREFERENCE_CATEGORY_FEATURES
	category = PREFERENCE_CATEGORY_CLOTHING
	main_feature_name = "Breasts"
	should_generate_icons = TRUE
	priority = PREFERENCE_PRIORITY_DEFAULT
	can_randomize = FALSE

/datum/preference/choiced/breasts/init_possible_values()
	return assoc_to_keys_features(SSaccessories.breasts_list)

/datum/preference/choiced/breasts/icon_for(value)
	return generate_genitals_shot(SSaccessories.breasts_list[value], "breasts")

/datum/preference/choiced/breasts/apply_to_human(mob/living/carbon/human/target, value)
	//to_chat(world, "Applying [value] to [target]'s boobs...")
	target.dna.features["breasts"] = value
	//to_chat(world, "Applied!")

/datum/preference/choiced/breasts/create_default_value()
	return pick(SSaccessories.breasts_list["None"])

/datum/preference/choiced/breasts/is_accessible(datum/preferences/preferences)
	. = ..()
	var/has_breasts = preferences.read_preference(/datum/preference/toggle/breasts)
	if(has_breasts == TRUE)
		return TRUE
	return FALSE



/// Breast colors!
/datum/preference/tri_color/breasts_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "breasts_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	can_randomize = FALSE

/datum/preference/tri_color/breasts_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/breasts_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["breasts_color_1"] = value[1]
	target.dna.features["breasts_color_2"] = value[2]
	target.dna.features["breasts_color_3"] = value[3]

/datum/preference/tri_color/breasts_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
/datum/preference/choiced/breasts/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/breasts_color::savefile_key

	return data



/// Breast sprite accessories
/datum/sprite_accessory/breasts
	icon = 'modular_doppler/enterprise_resource_planning/icons/mob/breasts.dmi'
	em_block = TRUE

/datum/sprite_accessory/breasts/bare
	name = "Bare"
	icon_state = "bare"

/datum/sprite_accessory/breasts/pair
	name = "Pair 0"
	icon_state = "pair_0"

/datum/sprite_accessory/breasts/pair/size1
	name = "Pair 1"
	icon_state = "pair_1"

/datum/sprite_accessory/breasts/pair/size2
	name = "Pair 2"
	icon_state = "pair_2"

/datum/sprite_accessory/breasts/pair/size3
	name = "Pair 3"
	icon_state = "pair_3"

/datum/sprite_accessory/breasts/pair/size4
	name = "Pair 4"
	icon_state = "pair_4"

/datum/sprite_accessory/breasts/pair/size5
	name = "Pair 5"
	icon_state = "pair_5"

/datum/sprite_accessory/breasts/pair/size6
	name = "Pair 6"
	icon_state = "pair_6"

/datum/sprite_accessory/breasts/pair/size7
	name = "Pair 7"
	icon_state = "pair_7"

/datum/sprite_accessory/breasts/pair/size8
	name = "Pair 8"
	icon_state = "pair_8"

/datum/sprite_accessory/breasts/pair/size9
	name = "Pair 9"
	icon_state = "pair_9"

/datum/sprite_accessory/breasts/pair/size10
	name = "Pair 10"
	icon_state = "pair_10"

/datum/sprite_accessory/breasts/pair/size11
	name = "Pair 11"
	icon_state = "pair_11"

/datum/sprite_accessory/breasts/pair/size12
	name = "Pair 12"
	icon_state = "pair_12"
