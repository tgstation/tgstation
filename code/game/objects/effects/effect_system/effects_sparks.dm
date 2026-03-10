/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/proc/do_sparks(number, cardinal_only, atom/source, atom/holder = null, spark_type = /datum/effect_system/basic/spark_spread)
	var/datum/effect_system/basic/spark_spread/sparks = new spark_type(get_turf(source), number, cardinal_only)
	if (holder)
		sparks.attach(holder)
	sparks.autocleanup = TRUE
	sparks.start()

/obj/effect/abstract/light_middleman

/// Allows us to intercept overlay lighting's well, light overlays
/// Normally these are static, but by giving them a render source and copying their base appearance
/// Animating this datum's child objects allows us to do SO much fun  stuff
/datum/light_middleman
	/// Owning parent we're interceeding for
	/// Could in theory be a turf but lies to areas means we have to pick something to type it as
	var/atom/movable/parent
	/// The holder we are currently displaying our light on
	var/atom/movable/light_holder
	/// Holds the primary light source
	var/obj/effect/abstract/light_middleman/primary_intercept
	/// Exists to hold the cone so children can modify it if they want
	var/obj/effect/abstract/light_middleman/cone_intercept
	/// Are we overriding the light already?
	var/overriding = FALSE

/datum/light_middleman/New(atom/parent, unique_string)
	. = ..()
	if(!IS_OVERLAY_LIGHT_SYSTEM(parent.light_system))
		stack_trace("Attempted to create a light middleman with a parent [parent.type] that does not use overlay lighting! This will not work.")
	if(isturf(parent))
		stack_trace("Warning, becuase overlay lights are basically never used on turfs, since they don't move,\
			vis contents replacement has not yet been implemented for them (see changeturf for why this is needed)!")
	src.parent = parent
	primary_intercept = new()
	cone_intercept = new()
	var/static/uuid = 0
	uuid = WRAP_UID(uuid + 1)
	primary_intercept.render_target = "*[unique_string]_[uuid]_target"
	cone_intercept.render_target = "[primary_intercept.render_target]_cone" // made to mirror how overlay lights work

/datum/light_middleman/Destroy(force)
	stop_overriding_light()
	QDEL_NULL(primary_intercept)
	QDEL_NULL(cone_intercept)
	parent = null
	light_holder = null
	return ..()

/datum/light_middleman/proc/being_overriding_light(unique_string)
	if(overriding)
		return
	overriding = TRUE
	// We register here because our later set render source will always trigger a refresh and thus let us capture appearances properly
	// Assuming there's an overlay light on the other side
	RegisterSignal(parent, COMSIG_ATOM_OVERLAY_LIGHT_APPLIED, PROC_REF(light_applied))
	RegisterSignal(parent, COMSIG_ATOM_OVERLAY_LIGHT_REMOVED, PROC_REF(light_removed))
	parent.set_light_render_source(primary_intercept.render_target)

/datum/light_middleman/proc/stop_overriding_light()
	if(!overriding)
		return
	overriding = FALSE
	UnregisterSignal(parent, COMSIG_ATOM_OVERLAY_LIGHT_APPLIED)
	UnregisterSignal(parent, COMSIG_ATOM_OVERLAY_LIGHT_REMOVED)
	parent.vis_contents -= primary_intercept
	parent.vis_contents -= cone_intercept
	parent.set_light_render_source("")

/datum/light_middleman/proc/light_applied(datum/source, image/visible_mask, image/cone, atom/movable/light_holder)
	SIGNAL_HANDLER
	light_holder.vis_contents += primary_intercept // how we make sure we're in the client's view
	// Avoids unneeded effects clientside
	if(IS_OVERLAY_CONE_LIGHT_SYSTEM(parent.light_system))
		light_holder.vis_contents += cone_intercept // how we make sure we're in the client's view

	var/old_target = primary_intercept.render_target
	var/old_cone_target = cone_intercept.render_target
	// This will halt any animations we have ongoing so if you care about that you've gotta react to it properly
	primary_intercept.appearance = visible_mask
	cone_intercept.appearance = cone
	// set ourselves up to render back onto the visible mask
	primary_intercept.render_source = ""
	primary_intercept.render_target = old_target
	cone_intercept.render_source = ""
	cone_intercept.render_target = old_cone_target
	// Reset our transform because otherwise it will double apply
	primary_intercept.transform = null
	cone_intercept.transform = null
	SEND_SIGNAL(src, COMSIG_LIGHT_MIDDLEMAN_UPDATED)

/datum/light_middleman/proc/light_removed(datum/source, atom/movable/light_holder)
	SIGNAL_HANDLER
	light_holder.vis_contents -= primary_intercept // how we make sure we're in the client's view
	light_holder.vis_contents -= cone_intercept // how we make sure we're in the client's view

/obj/effect/particle_effect/sparks
	name = "sparks"
	icon_state = "sparks"
	anchored = TRUE
	light_system = OVERLAY_LIGHT
	light_range = 1.5
	light_power = 2
	light_color = LIGHT_COLOR_FIRE
	/// Should this spark's effect be animated
	var/animated = TRUE
	/// Timer id for the timer that will wipe us out
	var/delete_timer_id = TIMER_ID_NULL
	/// Middleman object we're using to animate our light
	var/datum/light_middleman/middleman

/obj/effect/particle_effect/sparks/Initialize(mapload)
	..()
	if(animated)
		middleman = new(src, "sparks")
		middleman.being_overriding_light()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/particle_effect/sparks/LateInitialize()
	RegisterSignals(src, list(COMSIG_MOVABLE_CROSS, COMSIG_MOVABLE_CROSS_OVER), PROC_REF(sparks_touched))
	flick(icon_state, src)
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/turf/location = loc
	if(isturf(location))
		affect_location(location, just_initialized = TRUE)
	decay_in(2 SECONDS)

/obj/effect/particle_effect/sparks/Destroy()
	if(!isnull(middleman))
		QDEL_NULL(middleman)
	return ..()

/// Sets up our death effects given the passed in duration
/obj/effect/particle_effect/sparks/proc/decay_in(decay_time)
	if(delete_timer_id != TIMER_ID_NULL)
		deltimer(delete_timer_id)
	delete_timer_id = QDEL_IN_STOPPABLE(src, decay_time + world.tick_lag)
	if(!animated)
		return
	var/obj/effect/abstract/main_light = middleman.primary_intercept
	// We're going to fade our light out so it's less jarring when we fully disappear
	// Note, a refresh of the overlay light would break this, we're basically just sorta assuming that won't happen
	// Would need to track time and sort of "replay" where we should be otherwise
	if(decay_time >= 0.7 SECONDS) // duration of all animated spark's actual icon state animation
		animate(main_light, alpha = 220, time = 0.4 SECONDS)
		animate(alpha = 0, time = decay_time - 0.4 SECONDS, easing = CIRCULAR_EASING | EASE_IN)
	else
		animate(main_light, alpha = 0, time = decay_time)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/location = loc
	if(isturf(location))
		affect_location(location)
	return ..()

/obj/effect/particle_effect/sparks/Move()
	. = ..()
	var/turf/location = loc
	if(isturf(location))
		affect_location(location)

/obj/effect/particle_effect/sparks/quantum
	name = "quantum sparks"
	icon_state = "quantum_sparks"

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
	location.hotspot_expose(1000, 100)
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

/datum/effect_system/basic/spark_spread
	effect_type = /obj/effect/particle_effect/sparks
	step_delay = 0.35 SECONDS // chosen so we will always take at least the duration of our animation to finish

/datum/effect_system/basic/spark_spread/generate_effect()
	var/obj/effect/particle_effect/sparks/spark = ..()
	spark.decay_in(last_loop_length)

/datum/effect_system/basic/spark_spread/get_step_count()
	return rand(2, 3) // never 1 cause 1 looks dumb

/datum/effect_system/basic/spark_spread/move_failed(datum/move_loop/loop, obj/effect/failed)
	if(QDELETED(failed))
		return
	var/obj/effect/particle_effect/sparks/spark = failed
	spark.decay_in(0.1 SECONDS)

/datum/effect_system/basic/spark_spread/quantum
	effect_type = /obj/effect/particle_effect/sparks/quantum

//electricity

/obj/effect/particle_effect/sparks/electricity
	name = "lightning"
	icon_state = "electricity"
	animated = FALSE

/datum/effect_system/basic/lightning_spread
	delete_on_stop = TRUE
	effect_type = /obj/effect/particle_effect/sparks/electricity
