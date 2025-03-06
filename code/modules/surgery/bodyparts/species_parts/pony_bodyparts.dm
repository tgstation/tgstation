#define PONY_HEAD_SIZE_MODIFIER 1.5
/obj/item/bodypart/head/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	is_dimorphic = FALSE
	bodyshape = BODYSHAPE_PONY
	head_flags = HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_DEBRAIN|HEAD_HAIR
	teeth_count = 24
	/// Offset to apply to equipment held in the mouth.
	var/datum/worn_feature_offset/worn_mouth_item_offset

/obj/item/bodypart/head/pony/Initialize(mapload)
	. = ..()
/*
	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_x = list("north" = -2, "south" = 2, "east" = 4, "west" = -4),
		offset_y = list("north" = -1, "south" = -1, "east" = -1, "west" = -1),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_x = list("north" = 0, "south" = 0, "east" = 8, "west" = -8),
		offset_y = list("north" = -6, "south" = -6, "east" = -6, "west" = -6),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	worn_face_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACE,
		offset_x = list("north" = 0, "south" = 0, "east" = 5, "west" = -5),
		offset_y = list("north" = -6, "south" = -6, "east" = -6, "west" = -6),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
*/

	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_x = list("north" = -4, "south" = 4, "east" = 7, "west" = -7),
		offset_y = list("north" = 3, "south" = 3, "east" = 3, "west" = 3),
	)
	worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -7, "south" = -7, "east" = -7, "west" = -7),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -7, "south" = -7, "east" = -7, "west" = -7),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_x = list("north" = 0, "south" = 0, "east" = 8, "west" = -8),
		offset_y = list("north" = -6, "south" = -6, "east" = -6, "west" = -6),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	/*worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -3, "south" = -3, "east" = -3, "west" = -3),
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -1, "south" = -2, "east" = -2, "west" = -2),
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_x = list("north" = 0, "south" = 0, "east" = 8, "west" = -8),
		offset_y = list("north" = -4, "south" = -4, "east" = -3, "west" = -3),
	)*/
	worn_face_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACE,
		offset_x = list("north" = 0, "south" = 0, "east" = 5, "west" = -5),
		offset_y = list("north" = -5, "south" = -6, "east" = -6, "west" = -6),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)

/obj/item/bodypart/chest/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	is_dimorphic = FALSE
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/chest/pony/Initialize(mapload)
	. = ..()
	worn_back_offset = new(
		attached_part = src,
		feature_key = OFFSET_BACK,
		offset_x = list("north" = 0, "south" = 0, "east" = 2, "west" = -2),
		offset_y = list("north" = -4, "south" = -4, "east" = -5, "west" = -5),
	)
	worn_belt_offset = new(
		attached_part = src,
		feature_key = OFFSET_BELT,
		offset_x = list("north" = 0, "south" = 0, "east" = 2, "west" = -2),
		offset_y = list("north" = -4, "south" = -4, "east" = -5, "west" = -5),
		rotation_modifier = list("north" = 0, "south" = 0, "east" = 90, "west" = -90)
	)
	worn_suit_storage_offset = new(
		attached_part = src,
		feature_key = OFFSET_S_STORE,
		offset_x = list("north" = 0, "south" = 0, "east" = 2, "west" = -2),
		offset_y = list("north" = -4, "south" = -4, "east" = -5, "west" = -5),
		rotation_modifier = list("north" = 0, "south" = 0, "east" = 90, "west" = -90)
	)
	worn_id_offset = new(
		attached_part = src,
		feature_key = OFFSET_ID,
		offset_x = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 5),
	)
	worn_suit_offset = new(
		attached_part = src,
		feature_key = OFFSET_SUIT,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -5, "south" = -6, "east" = -5, "west" = -5),
	)

/obj/item/bodypart/arm/left/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	unarmed_attack_verbs = list("kicks", "hoofs", "stomps")
	grappled_attack_verb = "stomps"
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/arm/left/pony/Initialize(mapload)
	. = ..()
	worn_glove_offset = new( // even though they can't wear gloves. we're cheating and using this for the front leg offsets
		attached_part = src,
		feature_key = OFFSET_GLOVES,
		offset_x = list("north" = 0, "south" = 0, "east" = 5, "west" = -5),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	)


/obj/item/bodypart/arm/right/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	unarmed_attack_verbs = list("kicks", "hoofs", "stomps")
	grappled_attack_verb = "stomps"
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/arm/right/pony/Initialize(mapload)
	. = ..()
	worn_glove_offset = new( // even though they can't wear gloves. we're cheating and using this for the front leg offsets
		attached_part = src,
		feature_key = OFFSET_GLOVES,
		offset_x = list("north" = -1, "south" = -1, "east" = 5, "west" = -5),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	)

/obj/item/bodypart/leg/left/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/leg/left/pony/Initialize(mapload)
	. = ..()
	worn_foot_offset = new(
		attached_part = src,
		feature_key = OFFSET_SHOES,
		offset_x = list("north" = 0, "south" = 0, "east" = -4, "west" = 4),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	)

/obj/item/bodypart/leg/right/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/leg/right/pony/Initialize(mapload)
	. = ..()
	worn_foot_offset = new(
		attached_part = src,
		feature_key = OFFSET_SHOES,
		offset_x = list("north" = 0, "south" = 0, "east" = -4, "west" = 4),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	)

/obj/item/organ/eyes/pony
	name = "pony eyes"
	eye_icon_state = "pony_eye"

/obj/item/organ/eyes/pony/generate_body_overlay_before_eyelids(mob/living/carbon/human/parent)
	var/mutable_appearance/eyelashes = mutable_appearance('icons/mob/human/human_face.dmi', "pony_eyelids", -BODY_LAYER, parent)
	return list(eyelashes)

/obj/item/organ/ears/pony
	icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	icon_state = "m_pony_ears_pony_FRONT"
	worn_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	worn_icon_state = "m_pony_ears_pony_FRONT"
	visual = TRUE
	damage_multiplier = 2 // pony ears are big and sensitive to loud noises

	restyle_flags = EXTERNAL_RESTYLE_FLESH

	dna_block = DNA_EARS_BLOCK

	bodypart_overlay = /datum/bodypart_overlay/mutant/pony_ears

/datum/bodypart_overlay/mutant/pony_ears
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	color_source = ORGAN_COLOR_INHERIT
	feature_key = "pony_ears"
	dyable = TRUE

/datum/bodypart_overlay/mutant/pony_ears/get_global_feature_list()
	return SSaccessories.pony_ears_list

/datum/bodypart_overlay/mutant/pony_ears/can_draw_on_bodypart(mob/living/carbon/human/human)
	//if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
	//	return FALSE
	return TRUE

/obj/item/organ/tail/pony
	name = "pony tail"
	preference = "feature_pony_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/pony_tail

	wag_flags = NONE
	dna_block = DNA_PONY_TAIL_BLOCK

/datum/bodypart_overlay/mutant/pony_tail
	dyable = TRUE
	color_source = ORGAN_COLOR_HAIR
	feature_key = "pony_tail"
	layers = EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/pony_tail/get_global_feature_list()
	return SSaccessories.pony_tail_list

/datum/preference/choiced/pony_tail
	savefile_key = "feature_pony_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/pony

/datum/preference/choiced/pony_tail/init_possible_values()
	return assoc_to_keys_features(SSaccessories.pony_tail_list)

/datum/preference/choiced/pony_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["pony_tail"] = value

/datum/preference/choiced/pony_tail/create_default_value()
	return /datum/sprite_accessory/pony_tail/pony::name

/datum/preference/choiced/pony_choice
	savefile_key = "feature_pony_choice"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_inherent_trait = TRAIT_PONY_PREFS

/datum/preference/choiced/pony_tail/init_possible_values()
	return list("Unicorn", "Pegasus", "Earth")

/datum/preference/choiced/pony_choice/apply_to_human(mob/living/carbon/human/target, value)
	switch(value)
		if("Unicorn")
		if("Pegasus")
		if("Earth")

/datum/preference/choiced/pony_tail/create_default_value()
	return /datum/sprite_accessory/pony_tail/pony::name

/obj/item/organ/pony_horn
	name = "unicorn horn"
	icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	icon_state = "m_pony_horn_pony_FRONT"
	worn_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	worn_icon_state = "m_pony_horn_pony_FRONT"
	visual = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/pony_horn
	slot = ORGAN_SLOT_PONY_HORN

/datum/bodypart_overlay/mutant/pony_horn
	dyable = TRUE
	color_source = ORGAN_COLOR_INHERIT
	feature_key = "pony_horn"
	layers = EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/pony_horn/get_global_feature_list()
	return SSaccessories.pony_tail_list
