/obj/item/organ/ears/fox
	name = "fox ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	damage_multiplier = 2

	dna_block = /datum/dna_block/feature/ears
	bodypart_overlay = /datum/bodypart_overlay/mutant/cat_ears
	sprite_accessory_override = /datum/sprite_accessory/ears/fox

/obj/item/organ/tail/fox
	name = "fox tail"
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fox
	wag_flags = WAG_ABLE

/datum/bodypart_overlay/mutant/tail/fox
	feature_key = "fox_tail"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/tail/fox/get_global_feature_list()
	return SSaccessories.tails_list_fox

