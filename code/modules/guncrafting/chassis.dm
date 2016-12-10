/obj/item/weapon/gun/energy/prototype
	name = "prototype energy gun"
	desc = "A barebones energy gun chassis. Contains an integrated control chip that allows for users to control module activation."
	icon = 'icons/obj/guncrafting/energy/chassis.dmi'
	icon_state = 'default'
	item_state =
	ammo_type = list()
	var/datum/gun/GCdatum
	var/obj/item/ammo_casing/energy/prototype/Pcasing = new /obj/item/ammo_casing/energy/prototype(src)
	cell_type = /obj/item/weapon/stock_parts/cell	//We're not using this.
	w_class = 5
	var/max_projector_mods = 1
	var/max_power_modules = 1
	var/max_effect_modules = 1
	var/max_trigger_modules = 1
	var/max_chassis_modules = 1
	var/max_barrel_modules = 1
	var/max_cosmetic_modules = 1
	var/max_other_modules = 1
	var/gun_class = 1

/obj/item/weapon/energy/prototype/New()
	ammo_type += Pcasing
	..()
	GCdatum = new /datum/gun
	Pcasing.GCdatum = GCdatum
	GCdatum.holder = src

/obj/item/weapon/gun/energy/prototype/small
	name = "prototype energy pistol"
	desc = "A barebones energy gun chassis. Contains an integrated control chip that allows for users to control module activation."
	icon_state = 'small'
	item_state =
	w_class = 1
	slot = SLOT_POCKETS|SLOT_BELT
	max_projector_mods = 1
	max_power_modules = 1
	max_trigger_modules = 2
	max_effect_modules = 2
	max_chassis_modules = 1
	max_barrel_modules = 1
	max_cosmetic_modules = 2
	max_other_modules = 2
	gun_class = 1

/obj/item/weapon/gun/energy/prototype/medium
	name = "prototype energy gun"
	desc = "A barebones energy gun chassis. Contains an integrated control chip that allows for users to control module activation."
	icon_state = 'medium'
	item_state =
	w_class = 3
	slot = SLOT_BELT
	max_projector_mods = 2
	max_power_modules = 2
	max_trigger_modules = 2
	max_effect_modules = 3
	max_chassis_modules = 2
	max_barrel_modules = 2
	max_cosmetic_modules = 3
	max_other_modules = 2
	gun_class = 2

/obj/item/weapon/gun/energy/prototype/large
	name = "prototype energy rifle"
	desc = "A barebones energy gun chassis. Contains an integrated control chip that allows for users to control module activation."
	icon_state = 'large'
	item_state =
	w_class = 4
	slot = SLOT_BACK|SLOT_BELT
	max_projector_mods = 3
	max_power_modules = 3
	max_trigger_modules = 2
	max_effect_modules = 4
	max_chassis_modules = 3
	max_barrel_modules = 2
	max_cosmetic_modules = 4
	max_other_modules = 3
	gun_class = 3

/obj/item/weapon/gun/energy/prototype/huge
	name = "prototype energy cannon"
	desc = "A barebones energy gun chassis. Contains an integrated control chip that allows for users to control module activation."
	icon_state = 'small'
	item_state =
	w_class = 5
	slot = SLOT_BACK
	max_projector_mods = 3
	max_power_modules = 4
	max_trigger_modules = 2
	max_effect_modules = 5
	max_chassis_modules = 4
	max_barrel_modules = 3
	max_cosmetic_modules = 5
	max_other_modules = 4
	gun_class = 4

