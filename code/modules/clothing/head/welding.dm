/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	inhand_icon_state = "welding"
	custom_materials = list(/datum/material/iron=1750, /datum/material/glass=400)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 60)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT | PLASMAMAN_HELMET_EXEMPT

/obj/item/clothing/head/welding/attack_self(mob/user)
	weldingvisortoggle(user)
