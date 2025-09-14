/obj/item/clothing/under/pants
	gender = PLURAL
	body_parts_covered = GROIN|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	custom_price = PAYCHECK_CREW
	icon = 'icons/obj/clothing/under/shorts_pants_shirts.dmi'
	worn_icon = 'icons/mob/clothing/under/shorts_pants_shirts.dmi'
	abstract_type = /obj/item/clothing/under/pants
	species_exception = list(/datum/species/golem)

/obj/item/clothing/under/pants/slacks
	name = "slacks"
	desc = "A pair of comfy slacks."
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	icon_state = "/obj/item/clothing/under/pants/slacks"
	post_init_icon_state = "slacks"
	greyscale_config = /datum/greyscale_config/slacks
	greyscale_config_worn = /datum/greyscale_config/slacks/worn
	greyscale_colors = "#575757#3E3E3E#75634F"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/pants/jeans
	name = "jeans"
	desc = "A nondescript pair of tough jeans."
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	icon_state = "/obj/item/clothing/under/pants/jeans"
	post_init_icon_state = "jeans"
	greyscale_config = /datum/greyscale_config/jeans
	greyscale_config_worn = /datum/greyscale_config/jeans/worn
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
