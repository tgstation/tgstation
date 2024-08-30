/obj/item/clothing/shoes
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'icons/mob/clothing/feet.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/shoes/basefeet_digi.dmi')



/obj/item/clothing/shoes/sneakers
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)

/obj/item/clothing/shoes/sneakers/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes = list()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/sneakers/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers/worn/digi

/obj/item/clothing/shoes/sneakers/orange/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/sneakers_orange/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_orange/worn/digi

/obj/item/clothing/shoes/sneakers/marisa/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/sneakers_marisa/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_marisa/worn/digi



/datum/greyscale_config/sneakers/worn
	icon_file = 'icons/mob/clothing/feet.dmi'

/datum/greyscale_config/sneakers_orange/worn
	icon_file = 'icons/mob/clothing/feet.dmi'

/datum/greyscale_config/sneakers_marisa/worn
	icon_file = 'icons/mob/clothing/feet.dmi'

/datum/greyscale_config/sneakers/worn/digi
	name = "Worn Digi Sneakers"
	icon_file = 'modular_doppler/modular_cosmetics/icons/mob/shoes/basefeet_digi.dmi'

/datum/greyscale_config/sneakers_orange/worn/digi
	name = "Orange Worn Digi Sneakers"
	icon_file = 'modular_doppler/modular_cosmetics/icons/mob/shoes/basefeet_digi.dmi'

/datum/greyscale_config/sneakers_marisa/worn/digi
	name = "Worn Digi Marisa Sneakers"
	icon_file = 'modular_doppler/modular_cosmetics/icons/mob/shoes/basefeet_digi.dmi'
