/obj/effect/particle_effect/foam
	alpha = 0

/obj/effect/particle_effect/foam/New(loc)
	..()
	addtimer(CALLBACK(src, /obj/effect/particle_effect/.proc/smokefoam_fade_in), 0)

/obj/effect/particle_effect/foam/kill_foam()
	..()
	animate(src, alpha = 0, time = 5)

/obj/effect/particle_effect/proc/smokefoam_fade_in()
	animate(src, alpha = 255, time = 5)