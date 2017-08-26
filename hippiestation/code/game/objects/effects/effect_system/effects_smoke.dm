/obj/effect/particle_effect/smoke
	alpha = 0

/obj/effect/particle_effect/smoke/New(loc)
	..()
	addtimer(CALLBACK(src, /obj/effect/particle_effect/.proc/smokefoam_fade_in), 0)

/obj/effect/particle_effect/smoke/kill_smoke()
	..()
	animate(src, alpha = 0, time = 10)
