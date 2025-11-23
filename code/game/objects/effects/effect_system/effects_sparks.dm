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
	SEND_SIGNAL(location, COMSIG_ATOM_TOUCHED_SPARKS, src) // for plasma floors; other floor types only have to worry about the mysterious HAZARDOUS sparks
	if(just_initialized)
		for(var/atom/movable/singed in location)
			sparks_touched(src, singed)

/*
* This is called when anything passes through the same tiles as a spark, or when a spark passes through something's tile.
*
* This is invoked by the signals sent by every atom when they're crossed or crossing something. It
* signifies that something has been touched by sparks, and should be affected by possible pyrotechnic affects..
* datum/source - Can either be the spark itself or an object that just walked into it
* mob/living/singed - What was touched by the spark
*/
/obj/effect/particle_effect/sparks/proc/sparks_touched(datum/source, atom/singed)
	SIGNAL_HANDLER

	SEND_SIGNAL(singed, COMSIG_ATOM_TOUCHED_SPARKS, src)
	if(isobj(singed))
		var/datum/reagents/reagents = singed.reagents // heat up things that contain reagents before we check to see if they burn
		if(reagents && !(reagents.flags & SEALED_CONTAINER))
			reagents.expose_temperature(1000) // we set this at 1000 because that's the max reagent temp for a chem heater, higher temps require more than sparks
		return
	if(ishuman(singed))
		var/mob/living/carbon/human/singed_human = singed
		for(var/obj/item/anything in singed_human.get_visible_items())
			sparks_touched(src, anything)

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
