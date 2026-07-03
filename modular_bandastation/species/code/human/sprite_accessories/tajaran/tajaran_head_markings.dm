/datum/sprite_accessory/tajaran_head_markings
	icon = 'icons/bandastation/mob/species/tajaran/sprite_accessories/head_markings.dmi'
	color_src = TRUE

/datum/sprite_accessory/tajaran_head_markings/tigerhead
	name = "Tiger head"
	icon_state = "tiger_head"

/datum/sprite_accessory/tajaran_head_markings/tigerface
	name = "Tiger face"
	icon_state = "tiger_face"

/datum/sprite_accessory/tajaran_head_markings/outears
	name = "Outer ears"
	icon_state = "outears"

/datum/sprite_accessory/tajaran_head_markings/inears
	name = "Inner ears"
	icon_state = "inears"

/datum/sprite_accessory/tajaran_head_markings/muzzle
	name = "Muzzle"
	icon_state = "muzzle"

/datum/sprite_accessory/tajaran_head_markings/muzinears
	name = "Muzzle and Inner ears"
	icon_state = "muzinears"

/datum/sprite_accessory/tajaran_head_markings/nose
	name = "Nose"
	icon_state = "nose"

/datum/sprite_accessory/tajaran_head_markings/muzzle2
	name = "Muzzle Alt."
	icon_state = "muzzle2"

/datum/sprite_accessory/tajaran_head_markings/points
	name = "Points"
	icon_state = "points"

/datum/sprite_accessory/tajaran_head_markings/patch
	name = "Patch"
	icon_state = "patch"

/datum/sprite_accessory/tajaran_head_markings/cheetah
	name = "Cheetah"
	icon_state = "cheetah"

/// MARK: Bodypart overlay
/datum/bodypart_overlay/simple/body_marking/tajaran_head
	dna_feature_key = FEATURE_TAJARAN_HEAD_MARKINGS
	dna_color_feature_key = FEATURE_TAJARAN_HEAD_MARKINGS_COLOR
	applies_to = list(
		/obj/item/bodypart/head,
	)
