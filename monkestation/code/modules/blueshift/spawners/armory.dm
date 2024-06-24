/obj/effect/spawner/random/armory
	name = "generic armory spawner"
	spawn_loot_split = TRUE
	spawn_loot_count = 3
	spawn_loot_split_pixel_offsets = 4

// Misc armory stuff
/obj/effect/spawner/random/armory/barrier_grenades
	name = "barrier grenade spawner"
	icon_state = "barrier_grenade"
	loot = list(/obj/item/grenade/barrier)

/obj/effect/spawner/random/armory/barrier_grenades/six
	name = "six barrier grenade spawner"
	spawn_loot_count = 6

/obj/effect/spawner/random/armory/riot_shield
	name = "riot shield spawner"
	icon_state = "riot_shield"
	loot = list(/obj/item/shield/riot)

/obj/effect/spawner/random/armory/rubbershot
	name = "rubbershot spawner"
	icon_state = "rubbershot"
	loot = list(/obj/item/storage/box/rubbershot)

// Weapons
/obj/effect/spawner/random/armory/disablers
	name = "disabler spawner"
	icon_state = "disabler"
	loot = list(/obj/item/gun/energy/disabler)

/obj/effect/spawner/random/armory/laser_gun
	name = "laser gun spawner"
	icon_state = "laser_gun"
	loot = list(/obj/item/gun/energy/laser)

/obj/effect/spawner/random/armory/e_gun
	name = "energy gun spawner"
	icon_state = "e_gun"
	loot = list(/obj/item/gun/energy/e_gun)

/obj/effect/spawner/random/armory/shotgun
	name = "shotgun spawner"
	icon_state = "shotgun"
	loot = list(/obj/item/gun/ballistic/shotgun/riot)

// Armor
/obj/effect/spawner/random/armory/bulletproof_helmet
	name = "bulletproof helmet spawner"
	icon_state = "armor_helmet"
	loot = list(/obj/item/clothing/head/helmet/alt)

/obj/effect/spawner/random/armory/riot_helmet
	name = "riot helmet spawner"
	icon_state = "riot_helmet"
	loot = list(/obj/item/clothing/head/helmet/toggleable/riot)

/obj/effect/spawner/random/armory/bulletproof_armor
	name = "bulletproof armor spawner"
	icon_state = "bulletproof_armor"
	loot = list(/obj/item/clothing/suit/armor/bulletproof)

/obj/effect/spawner/random/armory/riot_armor
	name = "riot armor spawner"
	icon_state = "riot_armor"
	loot = list(/obj/item/clothing/suit/armor/riot)

/obj/effect/spawner/armory_spawn
	icon_state = "loot"
	icon = 'icons/effects/random_spawners.dmi'

	layer = OBJ_LAYER
	/// A list of possible guns to spawn.
	var/list/guns
	/// Do we fan out the items spawned for a natural effect?
	var/fan_out_items = FALSE
	/// How many mags per gun do we spawn, if it takes magazines.
	var/mags_to_spawn = 3
	/// Do we want to angle it so that it is horizontal?
	var/vertical_guns = TRUE


/obj/effect/spawner/armory_spawn/Initialize(mapload)
	. = ..()

	if(guns)
		var/gun_count = 0
		var/offset_percent = 20 / guns.len
		for(var/gun in guns) // 11/20/21: Gun spawners now spawn 1 of each gun in it's list no matter what, so as to reduce the RNG of the armory stock.
			var/obj/item/gun/spawned_gun = new gun(loc)

			if(vertical_guns)
				spawned_gun.place_on_rack()
				spawned_gun.pixel_x = -10 + (offset_percent * gun_count)
			else if (fan_out_items)
				spawned_gun.pixel_x = spawned_gun.pixel_y = ((!(gun_count%2)*gun_count/2)*-1)+((gun_count%2)*(gun_count+1)/2*1)

			gun_count++

/obj/effect/spawner/armory_spawn/shotguns
	guns = list(
		/obj/item/gun/ballistic/shotgun/riot/sol,
		/obj/item/gun/ballistic/shotgun/riot/sol,
		/obj/item/gun/ballistic/shotgun/riot/sol,
	)

/obj/structure/closet/ammunitionlocker/useful/PopulateContents()
	new /obj/item/storage/box/rubbershot(src)
	new /obj/item/storage/box/rubbershot(src)
	new /obj/item/storage/box/rubbershot(src)
	new /obj/item/storage/box/rubbershot(src)

/*
*	AMMO BOXES
*/

/obj/effect/spawner/armory_spawn/centcom_rifles
	guns = list(
		/obj/item/gun/ballistic/automatic/sol_rifle,
		/obj/item/gun/ballistic/automatic/sol_rifle,
		/obj/item/gun/ballistic/automatic/sol_rifle/machinegun,
	)

/obj/effect/spawner/armory_spawn/centcom_lasers
	guns = list(
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/e_gun,
	)

/obj/effect/spawner/armory_spawn/smg
	vertical_guns = FALSE
	guns = list(
		/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/sindano,
		/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/sindano,
		/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/sindano,
	)

/obj/effect/spawner/random/sakhno
	name = "sakhno rifle spawner"
	desc = "Mosin? Never heard of her!"
	icon_state = "pistol"
	loot = list(
		/obj/item/gun/ballistic/rifle/boltaction/surplus = 80,
		/obj/item/gun/ballistic/rifle/boltaction = 10,
		/obj/item/food/rationpack = 1,
	)
/obj/effect/spawner/random/sakhno/ammo
	name = ".310 Strilka stripper clip spawner"
	loot = list(
		/obj/item/ammo_box/strilka310/surplus = 80,
		/obj/item/ammo_box/strilka310 = 10,
		/obj/item/food/rationpack = 1,
	)

/obj/effect/spawner/armory_spawn/mod_lasers_big
	guns = list(
		/obj/item/gun/energy/modular_laser_rifle,
		/obj/item/gun/energy/modular_laser_rifle,
		/obj/item/gun/energy/modular_laser_rifle,
	)

/obj/effect/spawner/armory_spawn/mod_lasers_small
	guns = list(
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
	)
