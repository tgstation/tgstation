/// Proximity monitor that checks to see to see if anything worth shooting is within the bound of a turret.
/// Used so turrets don't waste time processing if nothing is near.
/datum/proximity_monitor/advanced/turret_tracking
	edge_is_a_field = TRUE
	/// Current list of things in the field.
	var/list/atom/movable/tracking
	/// Typecache of "interesting" objects.
	var/static/list/interesting_typecache

/datum/proximity_monitor/advanced/turret_tracking/New(atom/_host, range, _ignore_if_not_on_turf)
	if(!istype(_host, /obj/machinery/porta_turret))
		CRASH("Turret trackers should only be used with /obj/machinery/porta_turret as a host!")
	. = ..()
	if(isnull(interesting_typecache))
		interesting_typecache = typecacheof(list(
			/mob/living/basic,
			/mob/living/carbon,
			/mob/living/silicon/robot,
			/mob/living/simple_animal,
			/obj/structure/blob,
			/obj/vehicle/sealed/mecha,
		))

/datum/proximity_monitor/advanced/turret_tracking/Destroy()
	. = ..()
	LAZYNULL(tracking) // just to be sure

/datum/proximity_monitor/advanced/turret_tracking/setup_field_turf(turf/target)
	for(var/atom/movable/thing in target)
		start_tracking(thing)

/datum/proximity_monitor/advanced/turret_tracking/cleanup_field_turf(turf/target)
	for(var/atom/movable/thing in target)
		stop_tracking(thing)

/datum/proximity_monitor/advanced/turret_tracking/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	start_tracking(movable)

/datum/proximity_monitor/advanced/turret_tracking/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(get_dist(new_location, host) > current_range)
		stop_tracking(movable)

/datum/proximity_monitor/advanced/turret_tracking/proc/start_tracking(atom/movable/thing)
	if(QDELETED(src) || QDELETED(thing))
		return
	if(thing.invisibility > SEE_INVISIBLE_LIVING || !is_type_in_typecache(thing, interesting_typecache))
		return
	if(thing in tracking) // check this last
		return
	var/obj/machinery/porta_turret/turret = host
	if(isliving(thing) && turret.in_faction(thing))
		return
	LAZYADD(tracking, thing)
	RegisterSignal(thing, COMSIG_QDELETING, PROC_REF(stop_tracking))
	turret.check_should_process()
	testing("interesting thing [thing] ([AREACOORD(thing)]) now being tracked by [turret] ([AREACOORD(turret)])")

/datum/proximity_monitor/advanced/turret_tracking/proc/stop_tracking(atom/movable/thing)
	SIGNAL_HANDLER
	if(isnull(thing) || !(thing in tracking))
		return
	UnregisterSignal(thing, COMSIG_QDELETING)
	// not using LAZYREMOVE so we can just do LAZYLEN once
	tracking -= thing
	if(!LAZYLEN(tracking))
		LAZYNULL(tracking)
		var/obj/machinery/porta_turret/turret = host
		turret.check_should_process()
		testing("interesting thing [thing] ([AREACOORD(thing)]) no longer being tracked by [turret] ([AREACOORD(turret)])")
