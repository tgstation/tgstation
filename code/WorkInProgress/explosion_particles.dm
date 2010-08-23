/obj/effects/expl_particles
	name = "fire"
	icon = 'effects.dmi'
	icon_state = "explosion_particle"
	opacity = 1
	anchored = 1
	mouse_opacity = 0

/obj/effects/expl_particles/New()
	..()
	spawn (15)
		del(src)
	return

/obj/effects/expl_particles/Move()
	..()
	return

/datum/effects/system/expl_particles
	var/number = 10
	var/turf/location
	var/total_particles = 0

/datum/effects/system/expl_particles/proc/set_up(n = 10, loca)
	number = n
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effects/system/expl_particles/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		spawn(0)
			var/obj/effects/expl_particles/expl = new /obj/effects/expl_particles(src.location)
			var/direct = pick(alldirs)
			for(i=0, i<pick(1;25,2;50,3,4;200), i++)
				sleep(1)
				step(expl,direct)

/obj/effects/explosion
	name = "fire"
	icon = '96x96.dmi'
	icon_state = "explosion"
	opacity = 1
	anchored = 1
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32

/obj/effects/explosion/New()
	..()
	spawn (10)
		del(src)
	return

/datum/effects/system/explosion
	var/turf/location

/datum/effects/system/explosion/proc/set_up(loca)
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effects/system/explosion/proc/start()
	new/obj/effects/explosion( location )
	var/datum/effects/system/expl_particles/P = new/datum/effects/system/expl_particles()
	P.set_up(10,location)
	P.start()
	spawn(5)
		var/datum/effects/system/harmless_smoke_spread/S = new/datum/effects/system/harmless_smoke_spread()
		S.set_up(5,0,location,null)
		S.start()