// Disabler rifle with a scope
/obj/item/gun/energy/disabler/rifle
	name = "disabler rifle"
	desc = "A bulky disabler rifle designed for long range non-lethal takedowns, packing quite a punch but taking a long-time to recharge."
	icon = 'signia_modules/modules/disabler_sniper/icons/wide_guns.dmi'
	worn_icon = 'signia_modules/modules/disabler_sniper/icons/back.dmi'
	righthand_file = 'signia_modules/modules/disabler_sniper/icons/guns_righthand.dmi'
	lefthand_file = 'signia_modules/modules/disabler_sniper/icons/guns_lefthand.dmi'
	icon_state = "disabler_rifle"
	worn_icon_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/rifle)
	w_class = WEIGHT_CLASS_HUGE
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	shaded_charge = 1
	recoil = 1
	fire_sound_volume = 80
	pb_knockback = 1 // Its beam is powerful enough to knockdown for a second, so it makes sense to knock you back a tile Point Blank

	SET_BASE_PIXEL(-8, 0)

/obj/item/gun/energy/disabler/rifle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2) // https://www.youtube.com/watch?v=innJxQM_-CE
