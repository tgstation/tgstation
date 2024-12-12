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
