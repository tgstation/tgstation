/obj/item/clothing/shoes
	worn_icon = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi'
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE, BODYTYPE_TESHVALI, BODYTYPE_AVALARI)
	bodytype_icon_files = list("4" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet.dmi',
		"16" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/feet_digi.dmi',
		"1024" = 'modular_skyraptor/modules/species_teshvali/icons/clothing/teshvali_feet.dmi',
		"2048" = 'modular_skyraptor/modules/species_teshvali/icons/clothing/avalari_feet.dmi')



/obj/item/clothing/shoes/sneakers
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE, BODYTYPE_TESHVALI, BODYTYPE_AVALARI)

/obj/item/clothing/shoes/sneakers/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes = list()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/sneakers/worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers/worn/digi
	greyscale_config_worn_bodytypes["[BODYTYPE_TESHVALI]"] = /datum/greyscale_config/sneakers/worn/teshvali
	greyscale_config_worn_bodytypes["[BODYTYPE_AVALARI]"] = /datum/greyscale_config/sneakers/worn/avalari

/obj/item/clothing/shoes/sneakers/orange/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/sneakers_orange/worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_orange/worn/digi
	greyscale_config_worn_bodytypes["[BODYTYPE_TESHVALI]"] = /datum/greyscale_config/sneakers_orange/worn/teshvali
	greyscale_config_worn_bodytypes["[BODYTYPE_AVALARI]"] = /datum/greyscale_config/sneakers_orange/worn/avalari

/obj/item/clothing/shoes/sneakers/marisa/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/sneakers_marisa/worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/sneakers_marisa/worn/digi
	greyscale_config_worn_bodytypes["[BODYTYPE_TESHVALI]"] = /datum/greyscale_config/sneakers_marisa/worn/teshvali
	greyscale_config_worn_bodytypes["[BODYTYPE_AVALARI]"] = /datum/greyscale_config/sneakers_marisa/worn/avalari



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

/datum/greyscale_config/sneakers/worn/teshvali
	name = "Worn Tesh'Vali Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/teshvali_feet.dmi'

/datum/greyscale_config/sneakers_orange/worn/teshvali
	name = "Worn Tesh'Vali Orange Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/teshvali_feet.dmi'

/datum/greyscale_config/sneakers_marisa/worn/teshvali
	name = "Worn Tesh'Vali Marisa Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/teshvali_feet.dmi'

/datum/greyscale_config/sneakers/worn/avalari
	name = "Worn Tesh'Vali Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/avalari_feet.dmi'

/datum/greyscale_config/sneakers_orange/worn/avalari
	name = "Worn Tesh'Vali Orange Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/avalari_feet.dmi'

/datum/greyscale_config/sneakers_marisa/worn/avalari
	name = "Worn Tesh'Vali Marisa Sneakers"
	icon_file = 'modular_skyraptor/modules/species_teshvali/icons/clothing/avalari_feet.dmi'
