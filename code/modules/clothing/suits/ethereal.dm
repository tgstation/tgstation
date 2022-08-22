/obj/item/clothing/suit/hooded/ethereal_raincoat
	name = "ethereal raincoat"
	desc = ""
	icon = 'icons/obj/clothing/suits/ethereal.dmi'
	icon_state = "eth_raincoat"
	worn_icon = 'icons/mob/clothing/suits/ethereal.dmi'
	greyscale_config = /datum/greyscale_config/eth_raincoat
	greyscale_config_worn = /datum/greyscale_config/eth_raincoat_worn
	greyscale_colors = "#4e7cc7"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN|ARMS
	hoodtype = /obj/item/clothing/head/hooded/ethereal_rainhood

/obj/item/clothing/suit/hooded/ethereal_raincoat/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance('icons/mob/clothing/suits/ethereal.dmi', "eth_raincoat_glow_worn", alpha = src.alpha)

/obj/item/clothing/suit/hooded/ethereal_raincoat/trailwarden
	name = "trailwarden oilcoat"
	desc = "A masterfully handcrafted oilslick coat, supposedly makes for excellent camouflage among Sprout's vegetation. Traditionally the bioluminescent patterns were painted with the blood of the wearer as it was said to bring good luck, it was later replaced by a mixture based on tree sap."
	greyscale_colors = "#32a87d"

/obj/item/clothing/head/hooded/ethereal_rainhood
	name = "winter hood"
	desc = "A cozy winter hood attached to a heavy winter jacket."
	icon = 'icons/obj/clothing/head/ethereal.dmi'
	icon_state = "eth_rainhood"
	worn_icon = 'icons/mob/clothing/head/ethereal.dmi'
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS