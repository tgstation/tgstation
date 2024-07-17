///Turn the damage overlays glassy
#define GLASSY_OVERLAY_MATRIX list(\
		1, 2, 2, 0, \
		0, 1, 0, 0, \
		0, 0, 1, 0, \
		0, 0, 0, 1, \
		0, 0, 0, 0)

/obj/item/bodypart/head/voidwalker
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidwalker.dmi'
	limb_id = SPECIES_VOIDWALKER
	is_dimorphic = FALSE
	bodypart_traits = list(TRAIT_MUTE)
	head_flags = NONE
	blocks_emissive = EMISSIVE_BLOCK_NONE

	damage_overlay_color = GLASSY_OVERLAY_MATRIX

	brute_modifier = 0.9
	burn_modifier = 0.8

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/chest/voidwalker
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidwalker.dmi'
	limb_id = SPECIES_VOIDWALKER
	is_dimorphic = FALSE
	blocks_emissive = EMISSIVE_BLOCK_NONE

	brute_modifier = 0.9
	burn_modifier = 0.8

	damage_overlay_color = GLASSY_OVERLAY_MATRIX

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/arm/left/voidwalker
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidwalker.dmi'
	limb_id = SPECIES_VOIDWALKER
	is_dimorphic = FALSE
	blocks_emissive = EMISSIVE_BLOCK_NONE

	brute_modifier = 0.9
	burn_modifier = 0.8

	damage_overlay_color = GLASSY_OVERLAY_MATRIX

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/arm/right/voidwalker
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidwalker.dmi'
	limb_id = SPECIES_VOIDWALKER
	is_dimorphic = FALSE
	blocks_emissive = EMISSIVE_BLOCK_NONE

	brute_modifier = 0.9
	burn_modifier = 0.8

	damage_overlay_color = GLASSY_OVERLAY_MATRIX

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/leg/left/voidwalker
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidwalker.dmi'
	limb_id = SPECIES_VOIDWALKER
	is_dimorphic = FALSE
	blocks_emissive = EMISSIVE_BLOCK_NONE

	brute_modifier = 0.9
	burn_modifier = 0.8

	damage_overlay_color = GLASSY_OVERLAY_MATRIX

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/leg/right/voidwalker
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidwalker.dmi'
	limb_id = SPECIES_VOIDWALKER
	is_dimorphic = FALSE
	blocks_emissive = EMISSIVE_BLOCK_NONE

	brute_modifier = 0.9
	burn_modifier = 0.8

	damage_overlay_color = GLASSY_OVERLAY_MATRIX

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

#undef GLASSY_OVERLAY_MATRIX
