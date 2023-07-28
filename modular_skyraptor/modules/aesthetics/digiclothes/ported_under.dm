/obj/item/clothing/under/rank/captain
	worn_icon = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/command.dmi'
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	bodytype_icon_files = list("4" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/command.dmi', "8" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/command_digi.dmi')

/obj/item/clothing/under/rank/security
	worn_icon = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/security.dmi'
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	bodytype_icon_files = list("4" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/security.dmi', "8" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/security_digi.dmi')

/obj/item/clothing/under/rank/medical
	worn_icon = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/medical.dmi'
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	bodytype_icon_files = list("4" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/medical.dmi', "8" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/medical_digi.dmi')

/obj/item/clothing/under/rank/cargo
	worn_icon = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/cargo.dmi'
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	bodytype_icon_files = list("4" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/cargo.dmi', "8" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/cargo_digi.dmi')

/obj/item/clothing/under/rank/engineering
	worn_icon = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/engineering.dmi'
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	bodytype_icon_files = list("4" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/engineering.dmi', "8" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/engineering_digi.dmi')

/obj/item/clothing/under/rank/rnd
	worn_icon = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/rnd.dmi'
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	bodytype_icon_files = list("4" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/rnd.dmi', "8" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/rnd_digi.dmi')



/// Colored/generic
/obj/item/clothing/under/color
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	bodytype_icon_files = list("4" = 'icons/mob/clothing/under/color.dmi', "8" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/color_digi.dmi')

/obj/item/clothing/under/color/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodytypes = list()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/jumpsuit_worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/jumpsuit_worn/digi

/datum/greyscale_config/jumpsuit_worn/digi
	name = "Worn Digitigrade Jumpsuit"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/color_digi.dmi'
	json_config = 'code/datums/greyscale/json_configs/jumpsuit_worn.json'


/obj/item/clothing/under/rank/prisoner
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	bodytype_icon_files = list("4" = 'icons/mob/clothing/under/color.dmi', "8" = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/color_digi.dmi')

/datum/greyscale_config/jumpsuit_prison_worn/digi
	name = "Worn Prison Digitigrade Jumpsuit"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/skyrat_inherited/under/color_digi.dmi'
	json_config = 'code/datums/greyscale/json_configs/jumpsuit_prison_worn.json'
