/datum/sprite_accessory/tajaran_chest_markings
	icon = 'icons/bandastation/mob/species/tajaran/sprite_accessories/chest_markings.dmi'
	color_src = TRUE

/datum/sprite_accessory/tajaran_chest_markings/belly
	name = "Belly"
	icon_state = "belly"

/datum/sprite_accessory/tajaran_chest_markings/belly_full
	name = "Full Belly"
	icon_state = "fullbelly"

/datum/sprite_accessory/tajaran_chest_markings/belly_crest
	name = "Belly Crest"
	icon_state = "crest"

/datum/sprite_accessory/tajaran_chest_markings/patch
	name = "Patch"
	icon_state = "patch"

/datum/sprite_accessory/tajaran_chest_markings/tiger
	name = "Tiger"
	icon_state = "tiger"

/datum/sprite_accessory/tajaran_chest_markings/cheetah
	name = "Cheetah"
	icon_state = "cheetah"

// MARK: bodypart_overlay
/datum/bodypart_overlay/simple/body_marking/tajaran_chest
	dna_feature_key = FEATURE_TAJARAN_CHEST_MARKINGS
	dna_color_feature_key = FEATURE_TAJARAN_BODY_MARKINGS_COLOR
	applies_to = list(
		/obj/item/bodypart/chest,
	)
