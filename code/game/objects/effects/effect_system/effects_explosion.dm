/obj/effect/particle_effect/expl_particles
	name = "fire"
	icon_state = "explosion_particle"
	opacity = TRUE
	anchored = TRUE

/obj/effect/particle_effect/expl_particles/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/particle_effect/expl_particles/LateInitialize()
	var/step_amt = pick(25;1,50;2,100;3,200;4)

	var/datum/move_loop/loop = SSmove_manager.move(src, pick(GLOB.alldirs), 1, timeout = step_amt)
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, .proc/end_particle)

/obj/effect/particle_effect/expl_particles/proc/end_particle(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)

/datum/effect_system/expl_particles
	number = 10

/datum/effect_system/expl_particles/start()
	for(var/i in 1 to number)
		new /obj/effect/particle_effect/expl_particles(location)

/obj/effect/explosion
	name = "fire"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	opacity = TRUE
	anchored = TRUE
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -32
	pixel_y = -32

/obj/effect/explosion/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 10)

/datum/effect_system/explosion

/datum/effect_system/explosion/set_up(location)
	src.location = get_turf(location)

/datum/effect_system/explosion/start()
	new/obj/effect/explosion( location )
	var/datum/effect_system/expl_particles/P = new/datum/effect_system/expl_particles()
	P.set_up(10, 0, location)
	P.start()

/datum/effect_system/explosion/smoke

/datum/effect_system/explosion/smoke/proc/create_smoke()
	var/datum/effect_system/smoke_spread/S = new
	S.set_up(2, location)
	S.start()

/datum/effect_system/explosion/smoke/start()
	..()
	addtimer(CALLBACK(src, .proc/create_smoke), 5)
