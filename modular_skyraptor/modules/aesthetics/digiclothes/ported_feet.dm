/obj/item/clothing/shoes
	worn_icon = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi'
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	bodytype_icon_files = list("4" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi', "16" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet_digi.dmi')



/obj/item/clothing/shoes/sneakers
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)

/obj/item/clothing/shoes/sneakers/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes = list()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/sneakers_worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_worn/digi

/obj/item/clothing/shoes/sneakers/orange/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/sneakers_orange_worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_orange_worn/digi

/obj/item/clothing/shoes/sneakers/marisa/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/sneakers_marisa/worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_marisa/worn/digi



/datum/greyscale_config/sneakers/worn
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi'

/datum/greyscale_config/sneakers_orange/worn
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi'

/datum/greyscale_config/sneakers_marisa/worn
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi'

/datum/greyscale_config/sneakers/worn/digi
	name = "Worn Digi Sneakers"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet_digi.dmi'

/datum/greyscale_config/sneakers_orange/worn/digi
	name = "Orange Worn Digi Sneakers"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet_digi.dmi'

/datum/greyscale_config/sneakers_marisa/worn/digi
	name = "Worn Digi Marisa Sneakers"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet_digi.dmi'
