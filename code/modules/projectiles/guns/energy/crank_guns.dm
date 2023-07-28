/obj/item/gun/energy/laser/musket
	name = "laser musket"
	desc = "A hand-crafted laser weapon, it has a hand crank on the side to charge it up."
	icon_state = "musket"
	inhand_icon_state = "musket"
	worn_icon_state = "las_musket"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/musket)
	slot_flags = ITEM_SLOT_BACK
	obj_flags = UNIQUE_RENAME
	can_bayonet = TRUE
	knife_x_offset = 22
	knife_y_offset = 11

/obj/item/gun/energy/laser/musket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_wielded = 10)
	AddComponent( \
		/datum/component/crank_recharge, \
		charging_cell = get_cell(), \
		charge_amount = 500, \
		cooldown_time = 2 SECONDS, \
		charge_sound = 'sound/weapons/laser_crank.ogg', \
		charge_sound_cooldown_time = 1.8 SECONDS, \
	)

/obj/item/gun/energy/laser/musket/update_icon_state()
	inhand_icon_state = "[initial(inhand_icon_state)][(get_charge_ratio() == 4 ? "charged" : "")]"
	return ..()

/obj/item/gun/energy/laser/musket/prime
	name = "heroic laser musket"
	desc = "A well-engineered, hand-charged laser weapon. Its capacitors hum with potential."
	icon_state = "musket_prime"
	inhand_icon_state = "musket_prime"
	worn_icon_state = "las_musket_prime"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/musket/prime)


/obj/item/gun/energy/disabler/smoothbore
	name = "smoothbore disabler"
	desc = "A hand-crafted disabler, using a hard knock on an energy cell to fire the stunner laser. A lack of proper focusing means it has no accuracy whatsoever."
	icon_state = "smoothbore"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/smoothbore)
	shaded_charge = 1
	charge_sections = 1
	spread = 22.5

/obj/item/gun/energy/disabler/smoothbore/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/crank_recharge, \
		charging_cell = get_cell(), \
		charge_amount = 1000, \
		cooldown_time = 2 SECONDS, \
		charge_sound = 'sound/weapons/laser_crank.ogg', \
		charge_sound_cooldown_time = 1.8 SECONDS, \
	)

/obj/item/gun/energy/disabler/smoothbore/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 18, \
		overlay_y = 12, \
	) //i swear 1812 being the overlay numbers was accidental

/obj/item/gun/energy/disabler/smoothbore/prime //much stronger than the other prime variants, so dont just put this in as maint loot
	name = "elite smoothbore disabler"
	desc = "An enhancement version of the smoothbore disabler pistol. Improved optics and cell type result in good accuracy and the ability to fire twice. \
	The disabler bolts also don't dissipate upon impact with armor, unlike the previous model."
	icon_state = "smoothbore_prime"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/smoothbore/prime)
	charge_sections = 2
	spread = 0 //could be like 5, but having just very tiny spread kinda feels like bullshit
