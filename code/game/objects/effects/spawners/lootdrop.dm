/obj/effect/spawner/lootdrop
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	layer = OBJ_LAYER
	anchored = TRUE // Stops persistent lootdrop spawns from being shoved into lockers
	var/list/loot //a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/lootcount = 1 //how many items will be spawned
	var/lootdoubles = TRUE //if the same item can be spawned twice
	var/fan_out_items = FALSE //Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself
	var/spawn_on_init = TRUE	// Whether the spawner should immediately spawn loot and cleanup on Initialize()
	var/spawn_all_loot = FALSE // Whether the spawner should spawn all the loot in the list
	var/spawn_loot_chance = 100 // The chance for the spawner to create loot (ignores lootcount)
	var/spawn_scatter_radius = 0	//determines how big of a range (in tiles) we should scatter things in.

/obj/effect/spawner/lootdrop/Initialize(mapload)
	. = ..()

	if(spawn_on_init)
		spawn_loot()
		return INITIALIZE_HINT_QDEL

///If the spawner has any loot defined, randomly picks some and spawns it. Does not cleanup the spawner.
/obj/effect/spawner/lootdrop/proc/spawn_loot(lootcount_override)
	if(!prob(spawn_loot_chance))
		return INITIALIZE_HINT_QDEL

	var/list/spawn_locations = get_spawn_locations(spawn_scatter_radius)
	var/lootcount = isnull(lootcount_override) ? src.lootcount : lootcount_override

	if(spawn_all_loot)
		lootcount = INFINITY
		lootdoubles = FALSE

	if(loot?.len)
		var/loot_spawned = 0
		while((lootcount-loot_spawned) && loot.len)
			var/lootspawn = pickweight(loot)
			while(islist(lootspawn))
				lootspawn = pickweight(lootspawn)
			if(!lootdoubles)
				loot.Remove(lootspawn)
			if(lootspawn && (spawn_scatter_radius == 0 || spawn_locations.len))
				var/turf/spawn_loc = loc
				if(spawn_scatter_radius > 0)
					spawn_loc = pick_n_take(spawn_locations)

				var/atom/movable/spawned_loot = new lootspawn(spawn_loc)

				if (!fan_out_items)
					if (pixel_x != 0)
						spawned_loot.pixel_x = pixel_x
					if (pixel_y != 0)
						spawned_loot.pixel_y = pixel_y
				else
					if (loot_spawned)
						spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
			loot_spawned++

///If the spawner has a spawn_scatter_radius set, this creates a list of nearby turfs available
/obj/effect/spawner/lootdrop/proc/get_spawn_locations(radius)
	var/list/scatter_locations = list()

	if(radius >= 0)
		for(var/turf/turf_in_view in view(radius, get_turf(src)))
			if(!turf_in_view.density)
				scatter_locations += turf_in_view

	return scatter_locations

/obj/effect/spawner/lootdrop/arcade_boards
	name = "arcade board spawner"
	lootdoubles = FALSE
	loot = list()

/obj/effect/spawner/lootdrop/arcade_boards/Initialize(mapload)
	loot += subtypesof(/obj/item/circuitboard/computer/arcade)
	return ..()

/obj/effect/spawner/lootdrop/maintenance
	name = "maintenance loot spawner"
	desc = "Come on Lady Luck, spawn me a pair of sunglasses."
	spawn_on_init = FALSE
	// see code/_globalvars/lists/maintenance_loot.dm for loot table

/obj/effect/spawner/lootdrop/maintenance/examine(mob/user)
	. = ..()
	. += span_info("This spawner has an effective loot count of [get_effective_lootcount()].")

/obj/effect/spawner/lootdrop/maintenance/Initialize(mapload)
	. = ..()
	// There is a single callback in SSmapping to spawn all delayed maintenance loot
	// so we don't just make one callback per loot spawner
	GLOB.maintenance_loot_spawners += src
	loot = GLOB.maintenance_loot

	// Late loaded templates like shuttles can have maintenance loot
	if(SSticker.current_state >= GAME_STATE_SETTING_UP)
		spawn_loot()
		hide()

/obj/effect/spawner/lootdrop/maintenance/Destroy()
	GLOB.maintenance_loot_spawners -= src
	return ..()

/obj/effect/spawner/lootdrop/maintenance/proc/hide()
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/spawner/lootdrop/maintenance/proc/get_effective_lootcount()
	var/effective_lootcount = lootcount

	if(HAS_TRAIT(SSstation, STATION_TRAIT_FILLED_MAINT))
		effective_lootcount = FLOOR(lootcount * 1.5, 1)

	else if(HAS_TRAIT(SSstation, STATION_TRAIT_EMPTY_MAINT))
		effective_lootcount = FLOOR(lootcount * 0.5, 1)

	return effective_lootcount

/obj/effect/spawner/lootdrop/maintenance/spawn_loot(lootcount_override)
	if(isnull(lootcount_override))
		lootcount_override = get_effective_lootcount()
	. = ..()

	// In addition, closets that are closed will have the maintenance loot inserted inside.
	for(var/obj/structure/closet/closet in get_turf(src))
		if(!closet.opened)
			closet.take_contents()

/obj/effect/spawner/lootdrop/maintenance/two
	name = "2 x maintenance loot spawner"
	lootcount = 2

/obj/effect/spawner/lootdrop/maintenance/three
	name = "3 x maintenance loot spawner"
	lootcount = 3

/obj/effect/spawner/lootdrop/maintenance/four
	name = "4 x maintenance loot spawner"
	lootcount = 4

/obj/effect/spawner/lootdrop/maintenance/five
	name = "5 x maintenance loot spawner"
	lootcount = 5

/obj/effect/spawner/lootdrop/maintenance/six
	name = "6 x maintenance loot spawner"
	lootcount = 6

/obj/effect/spawner/lootdrop/maintenance/seven
	name = "7 x maintenance loot spawner"
	lootcount = 7

/obj/effect/spawner/lootdrop/maintenance/eight
	name = "8 x maintenance loot spawner"
	lootcount = 8

/obj/effect/spawner/lootdrop/crate_spawner
	name = "lootcrate spawner" //USE PROMO CODE "SELLOUT" FOR 20% OFF!
	lootdoubles = FALSE

	loot = list(
				/obj/structure/closet/crate/secure/loot = 20,
				"" = 80
				)

//finds the probabilities of items spawning from a loot spawner's loot pool
/obj/item/loot_table_maker
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	var/spawner_to_test = /obj/effect/spawner/lootdrop/maintenance //what lootdrop spawner to use the loot pool of
	var/loot_count = 180 //180 is about how much maint loot spawns per map as of 11/14/2019
	//result outputs
	var/list/spawned_table //list of all items "spawned" and how many
	var/list/stat_table //list of all items "spawned" and their occurrance probability

/obj/item/loot_table_maker/Initialize()
	. = ..()
	make_table()

/obj/item/loot_table_maker/attack_self(mob/user)
	to_chat(user, "Loot pool re-rolled.")
	make_table()

/obj/item/loot_table_maker/proc/make_table()
	spawned_table = list()
	stat_table = list()
	var/obj/effect/spawner/lootdrop/spawner_to_table = new spawner_to_test
	var/lootpool = spawner_to_table.loot
	qdel(spawner_to_table)
	for(var/i in 1 to loot_count)
		var/loot_spawn = pick_loot(lootpool)
		if(!(loot_spawn in spawned_table))
			spawned_table[loot_spawn] = 1
		else
			spawned_table[loot_spawn] += 1
	stat_table += spawned_table
	for(var/item in stat_table)
		stat_table[item] /= loot_count

/obj/item/loot_table_maker/proc/pick_loot(lootpool) //selects path from loot table and returns it
	var/lootspawn = pickweight(lootpool)
	while(islist(lootspawn))
		lootspawn = pickweight(lootspawn)
	return lootspawn

/obj/effect/spawner/lootdrop/space
	name = "generic space ruin loot spawner"
	lootcount = 1

/// Space loot spawner. Couple of random bits of technology-adjacent stuff including anomaly cores and BEPIS techs.
/obj/effect/spawner/lootdrop/space/fancytech
	lootcount = 2
	loot = list(
		/obj/item/raw_anomaly_core/random = 1,
		/obj/item/disk/tech_disk/spaceloot = 1,
		/obj/item/camera_bug = 1
	)

/// Space loot spawner. Some sort of random and rare tool. Only a single drop.
/obj/effect/spawner/lootdrop/space/fancytool
	lootcount = 1
	loot = list(
		/obj/item/wrench/abductor = 1,
		/obj/item/wirecutters/abductor = 1,
		/obj/item/screwdriver/abductor = 1,
		/obj/item/crowbar/abductor = 1,
		/obj/item/weldingtool/abductor = 1,
		/obj/item/multitool/abductor = 1,
		/obj/item/scalpel/alien = 1,
		/obj/item/hemostat/alien = 1,
		/obj/item/retractor/alien = 1,
		/obj/item/circular_saw/alien = 1,
		/obj/item/surgicaldrill/alien = 1,
		/obj/item/cautery/alien = 1,
		/obj/item/wrench/caravan = 1,
		/obj/item/wirecutters/caravan = 1,
		/obj/item/screwdriver/caravan = 1,
		/obj/item/crowbar/red/caravan = 1
	)


/// Space loot spawner. A single roundstart species language book.
/obj/effect/spawner/lootdrop/space/languagebook
	lootcount = 1
	loot = list(
		/obj/item/language_manual/roundstart_species = 100,
		/obj/item/language_manual/roundstart_species/five = 3,
		/obj/item/language_manual/roundstart_species/unlimited = 1
	)

/// A selection of cosmetic syndicate items. Just a couple. No hardsuits or weapons.
/obj/effect/spawner/lootdrop/space/syndiecosmetic
	lootcount = 2
	loot = list(
		/obj/item/clothing/under/syndicate = 10,
		/obj/item/clothing/under/syndicate/skirt = 10,
		/obj/item/clothing/under/syndicate/bloodred = 10,
		/obj/item/clothing/under/syndicate/bloodred/sleepytime = 5,
		/obj/item/clothing/under/syndicate/tacticool = 10,
		/obj/item/clothing/under/syndicate/tacticool/skirt = 10,
		/obj/item/clothing/under/syndicate/sniper = 10,
		/obj/item/clothing/under/syndicate/camo = 10,
		/obj/item/clothing/under/syndicate/soviet = 10,
		/obj/item/clothing/under/syndicate/combat = 10,
		/obj/item/clothing/under/syndicate/rus_army = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 7,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 1
	)
