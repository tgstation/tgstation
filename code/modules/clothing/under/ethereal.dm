/obj/item/clothing/under/ethereal_tunic
	name = "ethereal tunic"
	desc = "A simple tunic worn over an undersuit, it glows in the dark!"
	icon = 'icons/obj/clothing/under/ethereal.dmi'
	icon_state = "eth_tunic"
	worn_icon = 'icons/mob/clothing/under/ethereal.dmi'
	greyscale_colors = "#4e7cc7"
	greyscale_config = /datum/greyscale_config/eth_tunic
	greyscale_config_worn = /datum/greyscale_config/eth_tunic_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/ethereal_tunic/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance('icons/mob/clothing/under/ethereal.dmi', "eth_tunic_emissive_worn", alpha = src.alpha)

/obj/item/clothing/under/ethereal_tunic/update_overlays()
	. = ..()
		. += emissive_appearance('icons/obj/clothing/under/ethereal.dmi', "eth_tunic_emissive", alpha = src.alpha)

/obj/item/clothing/under/ethereal_tunic
	name = "trailwarden tunic"
	desc = "It was common for farmers and travelers to eventually find their clothes permanently stained from wading through the mud and bioluminescent flora of Sprout, eventually it became customary to dye clothes to replicate this effect purposefully."