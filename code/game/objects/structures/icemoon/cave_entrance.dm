/obj/structure/spawner/ice_moon
	name = "cave entrance"
	desc = "A hole in the ground, filled with monsters ready to defend it."

	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"

	faction = list("mining")
	max_mobs = 3
	max_integrity = 250
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/wolf)

	move_resist = INFINITY
	anchored = TRUE

/obj/structure/spawner/ice_moon/Initialize()
	. = ..()
	clear_rock()

/obj/structure/spawner/ice_moon/deconstruct(disassembled)
	destroy_message()
	return ..()

/**
  * Visible message created when the spawner is destroyed, used for formatting
  *
  */
/obj/structure/spawner/ice_moon/proc/destroy_message()
	visible_message("<span class='userdanger'>[src] collapses, sealing everything inside!</span>")

/**
  * Clears rocks around the spawner when it is created
  *
  */
/obj/structure/spawner/ice_moon/proc/clear_rock()
	for(var/turf/F in RANGE_TURFS(2, src))
		if(abs(src.x - F.x) + abs(src.y - F.y) > 3)
			continue
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/polarbear
	max_mobs = 1
	spawn_time = 60 SECONDS
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/polarbear)

/obj/structure/spawner/ice_moon/polarbear/clear_rock()
	for(var/turf/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/demonic_portal
	name = "demonic portal"
	desc = "A portal that goes to another world, normal creatures couldn't survive there."

	icon_state = "nether"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/ice_demon)

/obj/structure/spawner/ice_moon/demonic_portal/destroy_message()
	visible_message("<span class='userdanger'>[src] collapses, cutting it off from this world!</span>")

/obj/structure/spawner/ice_moon/demonic_portal/clear_rock()
	for(var/turf/F in RANGE_TURFS(3, src))
		if(abs(src.x - F.x) + abs(src.y - F.y) > 5)
			continue
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/ice_whelp)

/obj/structure/spawner/ice_moon/demonic_portal/snowlegion
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow)
