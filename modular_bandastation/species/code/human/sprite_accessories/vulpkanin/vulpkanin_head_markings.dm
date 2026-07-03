/datum/sprite_accessory/vulpkanin_head_markings
	icon = 'icons/bandastation/mob/species/vulpkanin/sprite_accessories/head_markings.dmi'
	color_src = TRUE

/datum/sprite_accessory/vulpkanin_head_markings/nose_default
	name = "Vulpkanin Nose"
	icon_state = "nose"

/datum/sprite_accessory/vulpkanin_head_markings/nose_alt_default
	name = "Vulpkanin Nose Alt."
	icon_state = "nose_alt"

/datum/sprite_accessory/vulpkanin_head_markings/tiger_head
	name = "Vulpkanin Tiger Head"
	icon_state = "tiger_head"

/datum/sprite_accessory/vulpkanin_head_markings/tiger_face
	name = "Vulpkanin Tiger Head and Face"
	icon_state = "tiger_face"

/datum/sprite_accessory/vulpkanin_head_markings/muzzle
	name = "Vulpkanin Muzzle"
	icon_state = "muzzle"

/datum/sprite_accessory/vulpkanin_head_markings/muzzle_ears
	name = "Vulpkanin Muzzle and Ears"
	icon_state = "muzzle_ear"

/datum/sprite_accessory/vulpkanin_head_markings/points_fade
	name = "Vulpkanin Points Head"
	icon_state = "points_fade"

/datum/sprite_accessory/vulpkanin_head_markings/points_sharp
	name = "Vulpkanin Points Head 2"
	icon_state = "points_sharp"

/// MARK: Bodypart overlay
/datum/bodypart_overlay/simple/body_marking/vulpkanin_head
	dna_feature_key = FEATURE_VULPKANIN_HEAD_MARKINGS
	dna_color_feature_key = FEATURE_VULPKANIN_HEAD_MARKINGS_COLOR
	applies_to = list(
		/obj/item/bodypart/head,
	)
