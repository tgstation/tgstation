/datum/status_effect/grouped/heretic_dreams
	id = "heretic_dreams"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	/// Cooldown between allowed dreams
	COOLDOWN_DECLARE(dreaming_cooldown)

/datum/status_effect/grouped/heretic_dreams/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_PRE_DREAMING, PROC_REF(add_heretic_dream))
	RegisterSignal(owner, COMSIG_START_DREAMING, PROC_REF(start_heretic_dream))

/datum/status_effect/grouped/heretic_dreams/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_PRE_DREAMING)
	UnregisterSignal(owner, COMSIG_START_DREAMING)

/datum/status_effect/grouped/heretic_dreams/proc/add_heretic_dream(mob/living/dreamer, list/dream_pool)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, dreaming_cooldown))
		return

	var/atom/dream_center = get_dream_center(dreamer)
	if(isnull(dream_center))
		return

	dream_pool[new /datum/dream/heretic(dream_center)] = 200

/datum/status_effect/grouped/heretic_dreams/proc/start_heretic_dream(mob/living/dreamer, datum/dream/current_dream)
	SIGNAL_HANDLER

	if(!istype(current_dream, /datum/dream/heretic))
		return
	COOLDOWN_START(src, dreaming_cooldown, /datum/mood_event/mansus_dream_fatigue::timeout)
	dreamer.add_mood_event("mansus_dream_fatigue", /datum/mood_event/mansus_dream_fatigue)

/datum/status_effect/grouped/heretic_dreams/proc/get_dream_center(mob/living/dreamer)
	// Select a random influence as the center of the dream
	if(length(GLOB.reality_smash_track.smashes))
		return pick(GLOB.reality_smash_track.smashes)

	// If there are no influences, either don't trigger the dream (if we are a heretic) or pick a completely random locale (if we aren't)
	if(IS_HERETIC(dreamer))
		return null

	return get_safe_random_station_turf_equal_weight()

/// Heretics can see dreams about random machinery from the perspective of a random unused influence
/datum/dream/heretic
	sleep_until_finished = TRUE
	/// The location of the influence (or lack thereof in the case of a fake dream) we will be dreaming about
	var/atom/dream_center
	/// The distance to the objects visible from the influence during the dream
	var/dream_view_range = 5
	var/list/what_you_can_see = list(
		/obj/item,
		/obj/structure,
		/obj/machinery,
	)
	var/static/list/what_you_cant_see = typecacheof(list(
		// Underfloor stuff and default wallmounts
		/obj/item/radio/intercom,
		/obj/structure/cable,
		/obj/structure/disposalpipe/segment,
		/obj/machinery/atmospherics/pipe/smart/manifold4w,
		/obj/machinery/atmospherics/components/unary/vent_scrubber,
		/obj/machinery/atmospherics/components/unary/vent_pump,
		/obj/machinery/duct,
		/obj/machinery/navbeacon,
		/obj/machinery/power/terminal,
		/obj/machinery/power/apc,
		/obj/machinery/light_switch,
		/obj/machinery/light,
		/obj/machinery/camera,
		/obj/machinery/door/firedoor,
		/obj/machinery/firealarm,
		/obj/machinery/airalarm,
		/obj/structure/window/fulltile,
		/obj/structure/window/reinforced/fulltile,
	))
	/// Cached list of allowed typecaches for each type in what_you_can_see
	var/static/list/allowed_typecaches_by_root_type = null

/datum/dream/heretic/New(atom/dream_center)
	src.dream_center = dream_center

/datum/dream/heretic/GenerateDream(mob/living/carbon/dreamer)
	. = list()
	. += "you wander through the forest of Mansus"
	. += "there is a " + pick("pond", "well", "lake", "puddle", "stream", "spring", "brook", "marsh")

	if(isnull(allowed_typecaches_by_root_type))
		allowed_typecaches_by_root_type = list()
		for(var/type in what_you_can_see)
			allowed_typecaches_by_root_type[type] = typecacheof(type) - what_you_cant_see

	var/list/all_objects = oview(dream_view_range, dream_center)
	var/something_found = FALSE
	for(var/object_type in allowed_typecaches_by_root_type)
		var/list/filtered_objects = typecache_filter_list(all_objects, allowed_typecaches_by_root_type[object_type])
		if(filtered_objects.len)
			if (!something_found)
				. += "its waters reflect"
				something_found = TRUE
			var/obj/found_object = pick(filtered_objects)
			. += initial(found_object.name)
	if(!something_found)
		. += pick("it's pitch black", "ihe reflections are vague", "you stroll aimlessly")
	else
		. += "the images fade in the ripples"
	. += "you feel exhausted"

/datum/mood_event/mansus_dream_fatigue
	description = "I must recover before I can dream of Mansus again."
	mood_change = -2
	timeout = 5 MINUTES
