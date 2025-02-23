/obj/effect/spawner/random/maintenance
	name = "maintenance loot spawner"
	desc = "Come on Lady Luck, spawn me a pair of sunglasses."
	icon_state = "loot"
	remove_if_cant_spawn = FALSE //don't remove stuff from the global maint list, which other can use.
	// see code/_globalvars/lists/maintenance_loot.dm for loot table

/// A subtype of maintenance loot spawner that does not spawn any decals, for when you want to place them on chasm turfs and such
/// decals such as ashes will cause NeverShouldHaveComeHere() to fail on such turfs, which creates annoying rng based CI failures
/obj/effect/spawner/random/maintenance/no_decals

/obj/effect/spawner/random/maintenance/no_decals/can_spawn(loot)
	if(ispath(loot, /obj/effect/decal))
		return FALSE
	return ..()

/obj/effect/spawner/random/maintenance/examine(mob/user)
	. = ..()
	. += span_info("This spawner has an effective loot count of [get_effective_lootcount()].")

/obj/effect/spawner/random/maintenance/Initialize(mapload)
	loot = GLOB.maintenance_loot
	return ..()

/obj/effect/spawner/random/maintenance/skew_loot_weights(list/loot_list, exponent)
	///We only need to skew the weights once, since it's a global list used by all maint spawners.
	var/static/already_done = FALSE
	if(loot_list == GLOB.maintenance_loot && already_done)
		return
	already_done = TRUE
	return ..()

/obj/effect/spawner/random/maintenance/proc/hide()
	SetInvisibility(INVISIBILITY_OBSERVER)
	alpha = 100

/obj/effect/spawner/random/maintenance/proc/get_effective_lootcount()
	var/effective_lootcount = spawn_loot_count

	if(HAS_TRAIT(SSstation, STATION_TRAIT_FILLED_MAINT))
		effective_lootcount = FLOOR(spawn_loot_count * 1.5, 1)

	else if(HAS_TRAIT(SSstation, STATION_TRAIT_EMPTY_MAINT))
		effective_lootcount = FLOOR(spawn_loot_count * 0.5, 1)

	return effective_lootcount

/obj/effect/spawner/random/maintenance/spawn_loot(lootcount_override)
	if(isnull(lootcount_override))
		lootcount_override = get_effective_lootcount()
	. = ..()

	// In addition, closets that are closed will have the maintenance loot inserted inside.
	for(var/obj/structure/closet/closet in get_turf(src))
		if(!closet.opened)
			closet.take_contents()

/obj/effect/spawner/random/maintenance/two
	name = "2 x maintenance loot spawner"
	spawn_loot_count = 2

/obj/effect/spawner/random/maintenance/three
	name = "3 x maintenance loot spawner"
	spawn_loot_count = 3

/obj/effect/spawner/random/maintenance/four
	name = "4 x maintenance loot spawner"
	spawn_loot_count = 4

/obj/effect/spawner/random/maintenance/five
	name = "5 x maintenance loot spawner"
	spawn_loot_count = 5

/obj/effect/spawner/random/maintenance/six
	name = "6 x maintenance loot spawner"
	spawn_loot_count = 6

/obj/effect/spawner/random/maintenance/seven
	name = "7 x maintenance loot spawner"
	spawn_loot_count = 7

/obj/effect/spawner/random/maintenance/eight
	name = "8 x maintenance loot spawner"
	spawn_loot_count = 8

/obj/effect/spawner/random/maintenance/no_decals/two
	name = "2 x maintenance loot spawner"
	spawn_loot_count = 2

/obj/effect/spawner/random/maintenance/no_decals/three
	name = "3 x maintenance loot spawner"
	spawn_loot_count = 3

/obj/effect/spawner/random/maintenance/no_decals/four
	name = "4 x maintenance loot spawner"
	spawn_loot_count = 4

/obj/effect/spawner/random/maintenance/no_decals/five
	name = "5 x maintenance loot spawner"
	spawn_loot_count = 5

/obj/effect/spawner/random/maintenance/no_decals/six
	name = "6 x maintenance loot spawner"
	spawn_loot_count = 6

/obj/effect/spawner/random/maintenance/no_decals/seven
	name = "7 x maintenance loot spawner"
	spawn_loot_count = 7

/obj/effect/spawner/random/maintenance/no_decals/eight
	name = "8 x maintenance loot spawner"
	spawn_loot_count = 8
