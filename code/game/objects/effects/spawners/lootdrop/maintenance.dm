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
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100

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
