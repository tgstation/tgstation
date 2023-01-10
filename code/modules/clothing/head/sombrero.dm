/obj/item/clothing/head/costume/sombrero
	name = "sombrero"
	icon = 'icons/obj/clothing/head/sombrero.dmi'
	icon_state = "sombrero"
	inhand_icon_state = "sombrero"
	desc = "You can practically taste the fiesta."
	flags_inv = HIDEHAIR

	dog_fashion = /datum/dog_fashion/head/sombrero

	greyscale_config = /datum/greyscale_config/sombrero
	greyscale_config_worn = /datum/greyscale_config/sombrero/worn
	greyscale_config_inhand_left = /datum/greyscale_config/sombrero/lefthand
	greyscale_config_inhand_right = /datum/greyscale_config/sombrero/righthand

/obj/item/clothing/head/costume/sombrero/green
	name = "green sombrero"
	desc = "As elegant as a dancing cactus."
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	dog_fashion = null
	greyscale_colors = "#13d968#ffffff"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/costume/sombrero/shamebrero
	name = "shamebrero"
	icon_state = "shamebrero"
	desc = "Once it's on, it never comes off."
	dog_fashion = null
	greyscale_colors = "#d565d3#f8db18"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/costume/sombrero/shamebrero/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)
