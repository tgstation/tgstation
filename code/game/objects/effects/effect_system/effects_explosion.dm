/obj/effect/particle_effect/expl_particles
	name = "fire"
	icon_state = "explosion_particle"
	opacity = TRUE
	anchored = TRUE


/obj/effect/particle_effect/expl_particles/proc/end_particle(datum/source)
	SIGNAL_HANDLER
	if (!QDELETED(src))
		qdel(src)

/datum/effect_system/basic/expl_particles
	effect_type = /obj/effect/particle_effect/expl_particles
	amount = 10
	step_delay = 0.1 SECONDS
	delete_on_stop = TRUE

/datum/effect_system/basic/expl_particles/get_step_count()
	return pick(25;1, 50;2, 100;3, 200;4)

/datum/effect_system/basic/expl_particles/loop_end(datum/move_loop/source)
	. = ..()
	var/obj/effect/explosion_particle = source.moving
	if(QDELETED(explosion_particle))
		return
	qdel(explosion_particle)

/obj/effect/explosion
	name = "fire"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	opacity = TRUE
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -32
	pixel_y = -32

/obj/effect/explosion/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 10)

/datum/effect_system/explosion

/datum/effect_system/explosion/start()
	new /obj/effect/explosion(location)
	var/datum/effect_system/basic/expl_particles/boom_particles = new(location)
	boom_particles.start()

/datum/effect_system/explosion/smoke

/datum/effect_system/explosion/smoke/proc/create_smoke()
	var/datum/effect_system/fluid_spread/smoke/smoke_system = new(location, range = 2)
	smoke_system.attach(holder).start()

/datum/effect_system/explosion/smoke/start()
	..()
	addtimer(CALLBACK(src, PROC_REF(create_smoke)), 0.5 SECONDS)
