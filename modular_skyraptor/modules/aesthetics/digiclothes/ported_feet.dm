/obj/item/clothing/shoes
	worn_icon = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi'
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE, BODYTYPE_TESHVALI, BODYTYPE_AVALARI)
	bodytype_icon_files = list("4" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi',
		"8" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet_digi.dmi',
		"1024" = 'modular_skyraptor/modules/species_teshvali/icons/clothing/teshvali_feet.dmi',
		"1024" = 'modular_skyraptor/modules/species_teshvali/icons/clothing/avalari_feet.dmi')



/obj/item/clothing/shoes/sneakers
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE, BODYTYPE_TESHVALI)

/obj/item/clothing/shoes/sneakers/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes = list()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/sneakers_worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_worn/digi
	greyscale_config_worn_bodytypes["[BODYTYPE_TESHVALI]"] = /datum/greyscale_config/sneakers_worn/teshvali
	greyscale_config_worn_bodytypes["[BODYTYPE_AVALARI]"] = /datum/greyscale_config/sneakers_worn/avalari

/obj/item/clothing/shoes/sneakers/orange/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/sneakers_orange_worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_orange_worn/digi
	greyscale_config_worn_bodytypes["[BODYTYPE_TESHVALI]"] = /datum/greyscale_config/sneakers_orange_worn/teshvali
	greyscale_config_worn_bodytypes["[BODYTYPE_AVALARI]"] = /datum/greyscale_config/sneakers_orange_worn/avalari

/obj/item/clothing/shoes/sneakers/marisa/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/sneakers_marisa/worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_marisa/worn/digi
	greyscale_config_worn_bodytypes["[BODYTYPE_TESHVALI]"] = /datum/greyscale_config/sneakers_marisa/worn/teshvali
	greyscale_config_worn_bodytypes["[BODYTYPE_AVALARI]"] = /datum/greyscale_config/sneakers_marisa/worn/avalari



/datum/greyscale_config/sneakers_worn
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi'

/datum/greyscale_config/sneakers_orange_worn
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi'

/datum/greyscale_config/sneakers_marisa/worn
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi'

/datum/greyscale_config/sneakers_worn/digi
	name = "Worn Digi Sneakers"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet_digi.dmi'

/datum/greyscale_config/sneakers_orange_worn/digi
	name = "Orange Digi Worn Sneakers"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet_digi.dmi'

/datum/greyscale_config/sneakers_marisa/worn/digi
	name = "Worn Digi Marisa Sneakers"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet_digi.dmi'

/datum/greyscale_config/sneakers_worn/teshvali
	name = "Worn Tesh'Vali Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/teshvali_feet.dmi'

/datum/greyscale_config/sneakers_orange_worn/teshvali
	name = "Worn Tesh'Vali Orange Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/teshvali_feet.dmi'

/datum/greyscale_config/sneakers_marisa/worn/teshvali
	name = "Worn Tesh'Vali Marisa Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/teshvali_feet.dmi'

/datum/greyscale_config/sneakers_worn/avalari
	name = "Worn Tesh'Vali Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/avalari_feet.dmi'

/datum/greyscale_config/sneakers_orange_worn/avalari
	name = "Worn Tesh'Vali Orange Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/avalari_feet.dmi'

/datum/greyscale_config/sneakers_marisa/worn/avalari
	name = "Worn Tesh'Vali Marisa Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/avalari_feet.dmi'
