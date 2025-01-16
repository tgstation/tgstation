GLOBAL_LIST_INIT(welding_paintjobs, list(
		"Classic" = "welding",
		"Flames" = "welding-f",
		"Blue Flames" ="welding-b",
		"Purple Flames" = "welding-p",
		"Gold" = "welding-gold",
		"Knight" = "welding-k",
		"Engineering" = "welding-e",
		"Demon" = "welding-d",
		"Fancy" = "welding-fancy"
))


/obj/item/clothing/head/utility/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	inhand_icon_state = "welding"
	lefthand_file = 'icons/mob/inhands/clothing/masks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/masks_righthand.dmi'
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*1.75, /datum/material/glass=SMALL_MATERIAL_AMOUNT * 4)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/utility_welding
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT | STACKABLE_HELMET_EXEMPT
	var/design = "welding"
	var/list/paintjobs = list()
/obj/item/clothing/head/utility/welding/Initialize(mapload)
	. = ..()
	if(!up)
		AddComponent(/datum/component/adjust_fishing_difficulty, 8)
	paintjobs = list(
		"Classic" = image(icon = src.icon, icon_state = "welding"),
		"Flames" = image(icon = src.icon, icon_state = "welding-f"),
		"Blue Flames" = image(icon = src.icon, icon_state = "welding-b"),
		"Purple Flames" = image(icon = src.icon, icon_state = "welding-p"),
		"Gold" = image(icon = src.icon, icon_state = "welding-gold"),
		"Knight" = image(icon = src.icon, icon_state = "welding-k"),
		"Engineering" = image(icon = src.icon, icon_state = "welding-e"),
		"Demon" = image(icon = src.icon, icon_state = "welding-d"),
		"Fancy" = image(icon = src.icon, icon_state = "welding-fancy"),
		)

/datum/armor/utility_welding
	melee = 10
	fire = 100
	acid = 60

/obj/item/clothing/head/utility/welding/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/head/utility/welding/adjust_visor(mob/user)
	. = ..()
	if(up)
		qdel(GetComponent(/datum/component/adjust_fishing_difficulty))
	else
		AddComponent(/datum/component/adjust_fishing_difficulty, 8)

/obj/item/clothing/head/utility/welding/update_icon_state()
	. = ..()
	icon_state = "[design][up ? "up" : ""]"
	inhand_icon_state = "[design][up ? "off" : ""]"
