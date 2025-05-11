
/datum/crusher_skin/ahabs_harpoon
	name = "Ahab's harpoon"
	retool_icon = 'modular_doppler/modular_crusher_ahabs_spear/icons/ahabs_spear.dmi'
	retool_icon_state = "crusher_ahab"
	retool_inhand_icon = "crusher_ahab"
	retool_projectile_icon = 'modular_doppler/modular_crusher_ahabs_spear/icons/projectiles.dmi'
	retool_projectile_icon_state = "ahabprojectile"
	retool_lefthand_file = 'modular_doppler/modular_crusher_ahabs_spear/icons/l_hand_ahab.dmi'
	retool_righthand_file = 'modular_doppler/modular_crusher_ahabs_spear/icons/r_hand_ahab.dmi'
	retool_worn_file = 'modular_doppler/modular_crusher_ahabs_spear/icons/back.dmi'
	normal_skin = FALSE

/obj/item/crusher_trophy/retool_kit/ahab
	name = "Ahab's harpoon retool kit"
	desc = "A toolkit for changing the crusher's appearance without affecting the device's function. This one will make it look like Ahab's harpoon, the weapon of legends."
	icon = 'modular_doppler/modular_crusher_ahabs_spear/icons/ahabs_spear.dmi'
	icon_state = "ahab_retool"
	forced_skin = /datum/crusher_skin/ahabs_harpoon

/obj/item/crusher_trophy/retool_kit/ahab/effect_desc()
	return "the crusher to have the appearance of the weapon of legends, Ahab's Harpoon"
