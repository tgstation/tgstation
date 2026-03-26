#define DISSOLVE_DURATION 45 SECONDS

/obj/effect/decal/cleanable/greenglow/waste
	name = "caustic sludge"
	desc = "A puddle of toxic, industrial waste. Eats through the floor if not cleaned up."
	icon_state = "waste_spill"
	light_power = 1
	beauty = -300
	clean_type = CLEAN_TYPE_ACID
	decal_reagent = /datum/reagent/toxin/acid/industrial_waste
	reagent_amount = 5
	alpha = 0

	/// audio of the waste bubbling and melting things.
	var/datum/looping_sound/soup/bubbling_audio // It's really just bubbling liquid audio, which is what I need here.
	/// TimerID for the floor melting effect, so we can stop it if it gets cleaned up.
	var/dissolve_timer

/obj/effect/decal/cleanable/greenglow/waste/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	animate(src, alpha=255, time= 0.5 SECONDS)

	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash_hydroponics")
	splash_animation.color = "#15ff00"
	flick_overlay_view(splash_animation, 1.1 SECONDS)

	bubbling_audio = new /datum/looping_sound/soup(src)
	bubbling_audio.start()
	pre_dissolve()

/obj/effect/decal/cleanable/greenglow/waste/Destroy()
	. = ..()
	bubbling_audio.stop()
	QDEL_NULL(bubbling_audio)
	qdel(particles)
	particles = null

	deltimer(dissolve_timer)
	dissolve_timer = null

/**
 * Sets up our waste to perform dissolve_floor after the timer goes off.
 */
/obj/effect/decal/cleanable/greenglow/waste/proc/pre_dissolve(display_message = TRUE, dissolve_clock = DISSOLVE_DURATION)
	if(display_message)
		visible_message(span_warning("\The [src] begins corroding \the [get_turf(src)]!"))
	if(color)
		color = "#ffffffff"
	playsound(src, 'sound/items/tools/welder.ogg', 50, TRUE)
	dissolve_timer = addtimer(CALLBACK(src, PROC_REF(dissolve_floor)), dissolve_clock, TIMER_STOPPABLE)
	particles =  new /particles/acid/toxic()

/obj/effect/decal/cleanable/greenglow/waste/proc/dissolve_floor()
	if(QDELETED(src))
		return
	var/atom/splashed_turf = get_turf(src)
	if(!isfloorturf(splashed_turf))
		return
	var/turf/open/splash_floor = splashed_turf
	splash_floor.ScrapeAway(flags = CHANGETURF_IGNORE_AIR) //Eat away the floor
	visible_message(span_warning("The waste eats away at the floor, leaving \the [get_turf(src)] behind."))
	animate(src, time = 0.5 SECONDS, color = "#bebebe8e")
	if(bubbling_audio)
		bubbling_audio.stop()
	qdel(particles)
	particles = null

#undef DISSOLVE_DURATION
