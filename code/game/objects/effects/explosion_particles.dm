/obj/effect/expl_particles
	name = "fire"
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosion_particle"
	opacity = 1
	anchored = 1
	mouse_opacity = 0

/obj/effect/expl_particles/New()
	..()
	spawn (15)
		qdel(src)
	return

/obj/effect/expl_particles/Move()
	..()
	return

/datum/effect/system/expl_particles
	var/number = 10
	var/turf/location
	var/total_particles = 0

/datum/effect/system/expl_particles/proc/set_up(n = 10, loca)
	number = n
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effect/system/expl_particles/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		spawn(0)
			var/obj/effect/expl_particles/expl = new /obj/effect/expl_particles(src.location)
			var/direct = pick(alldirs)
			for(i=0, i<pick(1;25,2;50,3,4;200), i++)
				sleep(1)
				step(expl,direct)

/obj/effect/explosion
	name = "fire"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	opacity = 1
	anchored = 1
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32

/obj/effect/explosion/New()
	..()
	spawn (10)
		qdel(src)
	return

/datum/effect/system/explosion
	var/turf/location

/datum/effect/system/explosion/proc/set_up(loca)
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effect/system/explosion/proc/start()
	new/obj/effect/explosion( location )
	var/datum/effect/system/expl_particles/P = new/datum/effect/system/expl_particles()
	P.set_up(10,location)
	P.start()
	spawn(5)
		var/datum/effect/effect/system/harmless_smoke_spread/S = new/datum/effect/effect/system/harmless_smoke_spread()
		S.set_up(5,0,location,null)
		S.start()