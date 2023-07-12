// CMG gunset - IN USE
/obj/item/storage/box/gunset/blueshield
	name = "Blueshield's CMG-2 gunset"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gunset/blueshield/PopulateContents()
	. = ..()
	new /obj/item/gun/ballistic/automatic/cmg/nomag(src)
	new /obj/item/ammo_box/magazine/multi_sprite/cmg(src)
	new /obj/item/ammo_box/magazine/multi_sprite/cmg(src)
	new /obj/item/ammo_box/magazine/multi_sprite/cmg/lethal(src)
	new /obj/item/ammo_box/magazine/multi_sprite/cmg/lethal(src)
	new /obj/item/suppressor/nanotrasen(src)

//suppressor for the CMG
/obj/item/suppressor/nanotrasen
	name = "NT-S suppressor"
	desc = "A Nanotrasen brand small-arms suppressor, including a large NT logo stamped on the side."


// -----------
// Unused guns:
// -----------

//Energy Revolver
/obj/item/gun/energy/e_gun/revolver //The virgin gun.
	name = "energy revolver"
	desc = "An advanced energy revolver with the capacity to shoot both electrodes and lasers."
	force = 7
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	ammo_x_offset = 1
	charge_sections = 4
	fire_delay = 4
	icon = 'modular_skyrat/modules/blueshield/icons/energy.dmi'
	icon_state = "bsgun"
	inhand_icon_state = "minidisable"
	lefthand_file = 'modular_skyrat/modules/blueshield/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/blueshield/icons/guns_righthand.dmi'
	obj_flags = UNIQUE_RENAME
	cell_type = /obj/item/stock_parts/cell/blueshield
	pin = /obj/item/firing_pin/implant/mindshield
	selfcharge = TRUE

/obj/item/stock_parts/cell/blueshield
	name = "internal revolver power cell"
	maxcharge = 1500
	chargerate = 300

//PDW-9 taser pistol
/obj/item/gun/energy/e_gun/revolver/pdw9 //The chad gun.
	name = "PDW-9 taser pistol"
	desc = "A military grade energy sidearm, used by many militia forces throughout the local sector. It comes with an internally recharging battery which is slow to recharge."
	ammo_x_offset = 2
	icon_state = "pdw9pistol"
	inhand_icon_state = null
	cell_type = /obj/item/stock_parts/cell/pdw9

/obj/item/stock_parts/cell/pdw9
	name = "internal pistol power cell"
	maxcharge = 1000
	chargerate = 300
	var/obj/item/gun/energy/e_gun/revolver/pdw9/parent

/obj/item/stock_parts/cell/pdw9/Initialize(mapload)
	. = ..()
	parent = loc

/obj/item/stock_parts/cell/pdw9/process()
	. = ..()
	parent.update_icon()

//Allstar SC-3 PDW 'Hellfire'
/obj/item/gun/energy/laser/hellgun/blueshield
	name = "\improper Allstar SC-3 PDW 'Hellfire'"
	desc = "A prototype energy carbine, despite NT's ban on hellfire weaponry due to negative press. \
		Allstar continued to work on it, compacting it into a small form-factor for personal defense. \
		As part of the Asset Retention Program created by Nanotrasen, Allstar's prototype began to be put into use."
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'
	worn_icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns_back.dmi'
	lefthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_righthand.dmi'
	icon_state = "hellfirepdw"
	worn_icon_state = "hellfirepdw"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hellfire/bs)

/obj/item/gun/energy/laser/hellgun/blueshield/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/ammo_casing/energy/laser/hellfire/bs
	projectile_type = /obj/projectile/beam/laser/hellfire
	e_cost = 83 //Lets it squeeze out a few more shots
	select_name = "maim"
