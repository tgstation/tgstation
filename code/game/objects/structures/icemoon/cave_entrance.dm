/obj/structure/spawner/ice_moon
	name = "cave entrance"
	desc = "A hole in the ground, filled with monsters ready to defend it."

	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"

	faction = list("mining")
	max_mobs = 3
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/wolf)

	move_resist = INFINITY
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE // no you can't destroy a hole unfortunately

/obj/structure/spawner/ice_moon/Initialize()
	. = ..()
	clear_rock()

/obj/structure/spawner/ice_moon/proc/clear_rock()
	for(var/turf/F in RANGE_TURFS(2, src))
		if(get_dist(src, F) >= 2)
			if(abs(src.x - F.x) + abs(src.y - F.y) > 3)
				continue
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/polarbear
	max_mobs = 1
	spawn_time = 600 //60 seconds
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/polarbear)

/obj/structure/spawner/ice_moon/polarbear/clear_rock()
	for(var/turf/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/snowlegion
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow)
