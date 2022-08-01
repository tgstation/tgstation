/obj/item/clothing/under/pants
	gender = PLURAL
	body_parts_covered = GROIN|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	custom_price = PAYCHECK_CREW
	icon = 'icons/obj/clothing/under/shorts_pants.dmi'
	worn_icon = 'icons/mob/clothing/under/shorts_pants.dmi'
	species_exception = list(/datum/species/golem)

/obj/item/clothing/under/pants/slacks
	name = "slacks"
	desc = "A pair of comfy slacks."
	icon_state = "slacks"
	greyscale_config = /datum/greyscale_config/slacks
	greyscale_config_worn = /datum/greyscale_config/slacks_worn
	greyscale_colors = "#575757#3E3E3E#75634F"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/pants/jeans
	name = "jeans"
	desc = "A nondescript pair of tough jeans."
	icon_state = "jeans"
	greyscale_config = /datum/greyscale_config/jeans
	greyscale_config_worn = /datum/greyscale_config/jeans_worn
	greyscale_colors = "#787878#723E0E#4D7EAC"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/pants/track
	name = "track pants"
	desc = "A pair of track pants, for the athletic."
	icon_state = "trackpants"

/obj/item/clothing/under/pants/camo
	name = "camo pants"
	desc = "A pair of woodland camouflage pants. Probably not the best choice for a space station."
	icon_state = "camopants"
