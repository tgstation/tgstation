/obj/item/clothing/suit/hooded/wintercoat/science/robotics/alt
	name = "roboticist's winter coat"
	desc = "Пальто, исключительно для разбирающихся в моде. Для крутых и подкрученных перцев. На бирке указано: 'Flameholdeir Industries'. Поможет даже во время самых длинных, холодных и тёмных времен."
	icon_state = "coatrobotics"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/wintercoat.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/wintercoat.dmi'
	hoodtype = NONE
	inhand_icon_state = null

/obj/item/clothing/suit/hooded/wintercoat/science/robotics/alt/click_alt(mob/user)
	return NONE // Restrict user to zip and unzip coat

// Blueshield
/obj/item/clothing/suit/hooded/wintercoat/blueshield
	name = "blueshield's winter coat"
	desc = "A comfy kevlar-lined coat with blue highlights, fit to keep the blueshield armored and warm."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/wintercoat.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/wintercoat.dmi'
	icon_state = "coat_blueshield"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/blueshield
	armor_type = /datum/armor/suit_armor

/obj/item/clothing/suit/hooded/wintercoat/blueshield/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/blueshield
	desc = "A comfy kevlar-lined hood to go with the comfy kevlar-lined coat."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/winterhood.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/winterhood.dmi'
	icon_state = "hood_blueshield"
	armor_type = /datum/armor/suit_armor
