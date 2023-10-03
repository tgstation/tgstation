/obj/effect/spawner/armory_spawn
	icon_state = "loot"
	icon = 'icons/effects/random_spawners.dmi'

	layer = OBJ_LAYER
	/// A list of possible guns to spawn.
	var/list/guns
	/// Do we fan out the items spawned for a natural effect?
	var/fan_out_items = TRUE
	/// How many mags per gun do we spawn, if it takes magazines.
	var/mags_to_spawn = 3
	/// Do we want to angle it so that it is horizontal?
	var/vertical_guns = TRUE


/obj/effect/spawner/armory_spawn/Initialize(mapload)
	. = ..()

	if(guns)
		var/current_offset = -10
		var/offset_percent = 20 / guns.len
		for(var/gun in guns) // 11/20/21: Gun spawners now spawn 1 of each gun in it's list no matter what, so as to reduce the RNG of the armory stock.
			var/obj/item/gun/spawned_gun = new gun(loc)

			if(vertical_guns)
				spawned_gun.place_on_rack()
				spawned_gun.pixel_x = current_offset
				current_offset += offset_percent

			if(istype(spawned_gun, /obj/item/gun/ballistic))
				var/obj/item/gun/ballistic/spawned_ballistic_gun = spawned_gun
				if(spawned_ballistic_gun.magazine && !istype(spawned_ballistic_gun.magazine, /obj/item/ammo_box/magazine/internal))
					var/obj/item/storage/box/ammo_box/spawned_box = new(loc)
					spawned_box.name = "ammo box - [spawned_ballistic_gun.name]"
					for(var/i in 1 to mags_to_spawn)
						new spawned_ballistic_gun.spawn_magazine_type (spawned_box)

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

/obj/item/storage/box/ammo_box
	name = "ammo box"
	desc = "A box filled with ammunition."
	icon = 'modular_skyrat/modules/microfusion/icons/microfusion_cells.dmi'
	icon_state = "microfusion_box"
	illustration = null
	layer = 2.9

/obj/item/storage/box/ammo_box/microfusion
	name = "microfusion cell container"
	desc = "A box filled with microfusion cells."

/obj/item/storage/box/ammo_box/microfusion/PopulateContents()
	new /obj/item/stock_parts/cell/microfusion(src)
	new /obj/item/stock_parts/cell/microfusion(src)
	new /obj/item/stock_parts/cell/microfusion(src)

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
