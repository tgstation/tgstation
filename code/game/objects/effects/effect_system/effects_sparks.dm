/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/proc/do_sparks(number, cardinal_only, datum/source)
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(number, cardinal_only, source)
	sparks.autocleanup = TRUE
	sparks.start()


/obj/effect/particle_effect/sparks
	name = "sparks"
	icon_state = "sparks"
	anchored = TRUE
	light_system = OVERLAY_LIGHT
	light_range = 1.5
	light_power = 0.8
	light_color = LIGHT_COLOR_FIRE

/obj/effect/particle_effect/sparks/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/particle_effect/sparks/LateInitialize()
	RegisterSignals(src, list(COMSIG_MOVABLE_CROSS, COMSIG_MOVABLE_CROSS_OVER), PROC_REF(sparks_touched))
	flick(icon_state, src)
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/turf/T = loc
	if(isturf(T))
		affect_location(T, TRUE) // just_initialized set to TRUE
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/T = loc
	if(isturf(T))
		affect_location(T)
	UnregisterSignal(src, list(COMSIG_MOVABLE_CROSS, COMSIG_MOVABLE_CROSS_OVER))
	return ..()

/obj/effect/particle_effect/sparks/Move()
	..()
	var/turf/T = loc
	if(isturf(T))
		affect_location(T)

/obj/effect/particle_effect/sparks/proc/affect_location(turf/T, just_initialized = 0)
	T.hotspot_expose(1000,100)
	if(just_initialized)
		for(var/atom/movable/singed in T)
			sparks_touched(src, singed)


/obj/effect/particle_effect/sparks/proc/sparks_touched(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(isobj(AM))
		var/obj/singed = AM
		if(singed.resistance_flags & FLAMMABLE) //only fire_act flammable objects instead of burning EVERYTHING
			singed.fire_act(1000,100)
		if(singed.reagents)
			var/datum/reagents/reagents = singed.reagents
			reagents.expose_temperature(1000)
		return
	if(isliving(AM))
		var/mob/living/singed = AM
		if(singed.fire_stacks)
			singed.ignite_mob(FALSE) //ignite the mob, silent = FALSE (You're set on fire!)
		return

/datum/effect_system/spark_spread
	effect_type = /obj/effect/particle_effect/sparks

/datum/effect_system/spark_spread/quantum
	effect_type = /obj/effect/particle_effect/sparks/quantum


//electricity

/obj/effect/particle_effect/sparks/electricity
	name = "lightning"
	icon_state = "electricity"

/obj/effect/particle_effect/sparks/quantum
	name = "quantum sparks"
	icon_state = "quantum_sparks"

/datum/effect_system/lightning_spread
	effect_type = /obj/effect/particle_effect/sparks/electricity
