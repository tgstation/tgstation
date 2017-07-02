/obj/item/clothing/suit/wizrobe/hippie
	alternate_worn_icon = 'hippiestation/icons/mob/suit.dmi'
	icon = 'hippiestation/icons/obj/clothing/suits.dmi'

/obj/item/clothing/suit/wizrobe/hippie/necrolord
	name = "Necrolord robes"
	desc = "One of the lord robes, powerful sets of robes belonging to some of the Wizard Federation's most talented wizards. This robe in particular belongs to Nehalim the Damned, who was infamous for spamming NPC mobs that were annoying as fuck to deal with. He died later on when one of his opponents flamed at him, literally."
	icon_state = "necrolord"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 30, bomb = 30, bio = 30, rad = 30)
	allowed = list(/obj/item/weapon/teleportation_scroll, /obj/item/weapon/gun/magic/staff/staffofrevenant)

/obj/item/clothing/suit/space/hardsuit/syndi/elite/blastco
	alternate_worn_icon = 'hippiestation/icons/mob/suit.dmi'
	icon = 'hippiestation/icons/obj/clothing/suits.dmi'
	name = "BlastCo(tm) Hardsuit"
	desc = "A specialized hardsuit built for sustaining concussive blasts and shrapnel. It is in travel mode."
	alt_desc = "A specialized hardsuit built for sustaining concussive blasts and shrapnel. It is in combat mode."
	icon_state = "hardsuit1-blastco"
	item_state = "syndie_hardsuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/blastco
	armor = list(melee = 70, bullet = 30, laser = 50, energy = 25, bomb = 100, bio = 100, rad = 70)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
