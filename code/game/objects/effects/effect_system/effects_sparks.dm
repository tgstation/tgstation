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
	var/turf/location = loc
	if(isturf(location))
		affect_location(location, just_initialized = TRUE)
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/location = loc
	if(isturf(location))
		affect_location(location)
	return ..()

/obj/effect/particle_effect/sparks/Move()
	..()
	var/turf/location = loc
	if(isturf(location))
		affect_location(location)

/*
* Apply the effects of this spark to its location.
*
* When the spark is first created, Cross() and Crossed() don't get called,
* so for the first initialization, we make sure to specifically invoke the
* behavior of the spark on all the mobs and objects in the location.
* turf/location - The place the spark is affectiong
* just_initialized - If the spark is just being created, and we need to manually affect everything in the location
*/
/obj/effect/particle_effect/sparks/proc/affect_location(turf/location, just_initialized = FALSE)
	location.hotspot_expose(1000,100)
	if(just_initialized)
		for(var/atom/movable/singed in location)
			sparks_touched(src, singed)

/*
* This is called when anything passes through the same tiles as a spark, or when a spark passes through something's tile.
*
* This is invoked by the signals sent by every atom when they're crossed or crossing something. It
* signifies that something has been touched by sparks, and should be affected by possible pyrotechnic affects..
* datum/source - Can either be the spark itself or an object that just walked into it
* mob/living/singed_mob - The mob that was touched by the spark
*/
/obj/effect/particle_effect/sparks/proc/sparks_touched(datum/source, atom/movable/singed)
	SIGNAL_HANDLER

	if(isobj(singed))
		var/obj/singed_obj = singed
		if(singed_obj.resistance_flags & FLAMMABLE && !(singed_obj.resistance_flags & ON_FIRE)) //only fire_act flammable objects instead of burning EVERYTHING
			singed_obj.fire_act(1,100)
		if(singed_obj.reagents)
			var/datum/reagents/reagents = singed_obj.reagents
			reagents?.expose_temperature(1000)
		return
	if(isliving(singed))
		var/mob/living/singed_living = singed
		if(singed_living.fire_stacks)
			singed_living.ignite_mob(FALSE) //ignite the mob, silent = FALSE (You're set on fire!)
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
