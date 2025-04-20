///Holster
/datum/storage/holster
	max_slots = 1
	max_total_storage = 16
	open_sound = 'sound/items/handling/holster_open.ogg'
	open_sound_vary = TRUE

/datum/storage/holster/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	. = ..()
	if(length(holdables))
		set_holdable(holdables)
		return
		
	set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/ballistic/rifle/boltaction, //fits if you make it an obrez
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
	))

///Energy holster
/datum/storage/holster/energy
	max_slots = 2

/datum/storage/holster/energy/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	holdables = list(
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/recharge/ebow,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
	)

	return ..()

///Detective holster
/datum/storage/holster/detective
	max_slots = 3

/datum/storage/holster/detective/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	holdables = list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm, // Pistol magazines.
		/obj/item/ammo_box/magazine/m9mm_aps,
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box/c38, // Revolver speedloaders.
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/strilka310,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/ballistic/rifle/boltaction, //fits if you make it an obrez
	)

	return ..()

///Chameleon Holster
/datum/storage/holster/chameleon
	max_slots = 2
	silent = TRUE

/datum/storage/holster/chameleon/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	holdables = list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm_aps,
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box/c38,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/strilka310,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/gun/energy/recharge/ebow,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
	)

	return ..()

///Nukie holster
/datum/storage/holster/nukie
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_BULKY

/datum/storage/holster/nukie/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	holdables = list(
		/obj/item/gun, // ALL guns.
		/obj/item/ammo_box/magazine, // ALL magazines.
		/obj/item/ammo_box/c38, //There isn't a speedloader parent type, so I just put these three here by hand.
		/obj/item/ammo_box/a357, //I didn't want to just use /obj/item/ammo_box, because then this could hold huge boxes of ammo.
		/obj/item/ammo_box/strilka310,
		/obj/item/ammo_casing, // For shotgun shells, rockets, launcher grenades, and a few other things.
		/obj/item/grenade, // All regular grenades, the big grenade launcher fires these.
	)

	return ..()

///Nukie cowboy holster
/datum/storage/holster/nukie/cowboy
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_NORMAL
