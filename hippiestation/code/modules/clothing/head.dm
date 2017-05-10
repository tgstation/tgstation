/obj/item/clothing/head/wizard/hippie
	alternate_worn_icon = 'hippiestation/icons/mob/head.dmi'
	icon = 'hippiestation/icons/obj/clothing/hats.dmi'
	dog_fashion = null

/obj/item/clothing/head/wizard/hippie/necrolord
	name = "Necrolord hood"
	desc = "One of the lord robes, powerful sets of robes belonging to some of the Wizard federation's most talented wizards."
	icon_state = "necrolord"
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 30, bomb = 30, bio = 30, rad = 30)
	flags_inv = HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/blastco
	alternate_worn_icon = 'hippiestation/icons/mob/head.dmi'
	icon = 'hippiestation/icons/obj/clothing/hats.dmi'
	name = "BlastCo(tm) Helmet"
	desc = "A specialized helmet built for sustaining concussive blasts and shrapnel. It is in travel mode. Property of BlastCo."
	alt_desc = "A specialized helmet built for sustaining concussive blasts and shrapnel. It is in combat mode. Property of BlastCo."
	icon_state = "hardsuit1-blastco"
	item_color = "blastco"
	armor = list(melee = 70, bullet = 30, laser = 50, energy = 25, bomb = 100, bio = 100, rad = 70)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
