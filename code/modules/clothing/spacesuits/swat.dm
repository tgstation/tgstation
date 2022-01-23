/obj/item/clothing/suit/space/swat
	name = "MK.I SWAT Suit"
	desc = "A tactical suit first developed in a joint effort by the defunct IS-ERI and Nanotrasen in 2321 for military operations. It has a minor slowdown, but offers decent protection."
	icon_state = "heavy"
	inhand_icon_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/knife/combat)
	armor = list(MELEE = 40, BULLET = 30, LASER = 30,ENERGY = 40, BOMB = 50, BIO = 90, FIRE = 100, ACID = 100, WOUND = 15)
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = THICKMATERIAL
	show_hud = FALSE
	cell = null
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	actions_types = null
	slowdown = 0.6
