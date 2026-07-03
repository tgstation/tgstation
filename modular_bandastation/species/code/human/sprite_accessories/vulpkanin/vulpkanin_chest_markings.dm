/datum/sprite_accessory/vulpkanin_chest_markings
	icon = 'icons/bandastation/mob/species/vulpkanin/sprite_accessories/chest_markings.dmi'
	color_src = TRUE
	em_block = TRUE

/datum/sprite_accessory/vulpkanin_chest_markings/points_crest
	name = "Points and crest"
	icon_state = "crestpoints"
	gender_specific = TRUE

/datum/sprite_accessory/vulpkanin_chest_markings/points_fade_belly_alt
	name = "Points and belly alt."
	icon_state = "altpointsfadebelly"
	gender_specific = TRUE

/datum/sprite_accessory/vulpkanin_chest_markings/belly_full
	name = "Belly 2"
	icon_state = "fullbelly"
	gender_specific = TRUE

/datum/sprite_accessory/vulpkanin_chest_markings/points_fade_belly
	name = "Points and belly"
	icon_state = "pointsfadebelly"

/datum/sprite_accessory/vulpkanin_chest_markings/belly_fox
	name = "Foxbelly"
	icon_state = "foxbelly"

/datum/sprite_accessory/vulpkanin_chest_markings/belly_crest
	name = "Belly crest"
	icon_state = "bellycrest"

/datum/bodypart_overlay/simple/body_marking/vulpkanin_chest
	dna_feature_key = FEATURE_VULPKANIN_CHEST_MARKINGS
	dna_color_feature_key = FEATURE_VULPKANIN_BODY_MARKINGS_COLOR
	applies_to = list(
		/obj/item/bodypart/chest,
	)
