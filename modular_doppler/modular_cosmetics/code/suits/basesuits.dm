/obj/item/clothing/suit/bio_suit
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'icons/mob/clothing/head/bio.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/bio_digi.dmi')

/obj/item/clothing/suit/wizrobe
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'icons/mob/clothing/suits/wizard.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/wizard_digi.dmi')



/obj/item/clothing/suit/toggle/labcoat
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/labcoat.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/labcoat_digi.dmi')

//God damnit TG you *fuckwits*, why didn't you subtype these properly
/obj/item/clothing/suit/toggle/labcoat/genetics
	greyscale_config_worn_bodyshapes = list(BODYSHAPE_HUMANOID_T = /datum/greyscale_config/labcoat/worn,
		BODYSHAPE_DIGITIGRADE_T = /datum/greyscale_config/labcoat/worn/digi)
/obj/item/clothing/suit/toggle/labcoat/chemist
	greyscale_config_worn_bodyshapes = list(BODYSHAPE_HUMANOID_T = /datum/greyscale_config/labcoat/worn,
		BODYSHAPE_DIGITIGRADE_T = /datum/greyscale_config/labcoat/worn/digi)
/obj/item/clothing/suit/toggle/labcoat/virologist
	greyscale_config_worn_bodyshapes = list(BODYSHAPE_HUMANOID_T = /datum/greyscale_config/labcoat/worn,
		BODYSHAPE_DIGITIGRADE_T = /datum/greyscale_config/labcoat/worn/digi)
/obj/item/clothing/suit/toggle/labcoat/coroner
	greyscale_config_worn_bodyshapes = list(BODYSHAPE_HUMANOID_T = /datum/greyscale_config/labcoat/worn,
		BODYSHAPE_DIGITIGRADE_T = /datum/greyscale_config/labcoat/worn/digi)
/obj/item/clothing/suit/toggle/labcoat/science
	greyscale_config_worn_bodyshapes = list(BODYSHAPE_HUMANOID_T = /datum/greyscale_config/labcoat/worn,
		BODYSHAPE_DIGITIGRADE_T = /datum/greyscale_config/labcoat/worn/digi)
/obj/item/clothing/suit/toggle/labcoat/roboticist
	greyscale_config_worn_bodyshapes = list(BODYSHAPE_HUMANOID_T = /datum/greyscale_config/labcoat/worn,
		BODYSHAPE_DIGITIGRADE_T = /datum/greyscale_config/labcoat/worn/digi)
/obj/item/clothing/suit/toggle/labcoat/interdyne
	greyscale_config_worn_bodyshapes = list(BODYSHAPE_HUMANOID_T = /datum/greyscale_config/labcoat/worn,
		BODYSHAPE_DIGITIGRADE_T = /datum/greyscale_config/labcoat/worn/digi)



/obj/item/clothing/suit/space
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'icons/mob/clothing/suits/spacesuit.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/spacesuit_digi.dmi')

/obj/item/clothing/suit/chaplainsuit
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'icons/mob/clothing/suits/chaplain.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/chaplain_digi.dmi')

/obj/item/clothing/suit/hooded/chaplainsuit
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'icons/mob/clothing/suits/chaplain.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/chaplain_digi.dmi')

/obj/item/clothing/suit/hooded/explorer
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'icons/mob/clothing/suits/utility.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/suit_digi.dmi')



/// TODO: migrate these into our normal file
/datum/greyscale_config/labcoat/worn/digi
	name = "Labcoat (Worn, Digitigrade)"
	icon_file = 'modular_doppler/modular_cosmetics/icons/mob/suit/labcoat_digi.dmi'
