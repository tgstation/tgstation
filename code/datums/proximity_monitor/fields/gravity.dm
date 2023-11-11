// Proximity monitor applies forced gravity to all turfs in range.
/datum/proximity_monitor/advanced/gravity
	edge_is_a_field = TRUE
	var/gravity_value = 0
	var/list/modified_turfs = list()

/datum/proximity_monitor/advanced/gravity/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, gravity)
	. = ..()
	gravity_value = gravity
	recalculate_field()

/datum/proximity_monitor/advanced/gravity/setup_field_turf(turf/target)
	. = ..()
	if(!isnull(modified_turfs[target]))
		return
	if(HAS_TRAIT(target, TRAIT_FORCED_GRAVITY))
		return
	target.AddElement(/datum/element/forced_gravity, gravity_value, can_override = TRUE)
	modified_turfs[target] = gravity_value

/datum/proximity_monitor/advanced/gravity/cleanup_field_turf(turf/target)
	. = ..()
	if(isnull(modified_turfs[target]))
		return
	var/grav_value = modified_turfs[target] || 0
	target.RemoveElement(/datum/element/forced_gravity, grav_value, can_override = TRUE)
	modified_turfs -= target

// Subtype which pops up a balloon alert when a mob enters the field
/datum/proximity_monitor/advanced/gravity/warns_on_entrance
	/// This is a list of mob refs that have recently entered the field.
	/// We track it so that we don't spam a player who is stutter stepping in and out with balloon alerts.
	var/list/recently_warned

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/setup_field_turf(turf/target)
	. = ..()
	for(var/mob/living/guy in target)
		warn_mob(guy, target)

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/cleanup_field_turf(turf/target)
	. = ..()
	for(var/mob/living/guy in target)
		warn_mob(guy, target)

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/field_edge_crossed(atom/movable/movable, turf/location)
	. = ..()
	if(isliving(movable))
		warn_mob(movable, location)

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/field_edge_uncrossed(atom/movable/movable, turf/location)
	. = ..()
	if(isliving(movable))
		warn_mob(movable, location)

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/proc/warn_mob(mob/living/to_warn, turf/location)
	var/mob_ref_key = REF(to_warn)
	if(mob_ref_key in recently_warned)
		return

	location.balloon_alert(to_warn, "gravity [(location in modified_turfs) ? "shifts!" : "reverts..."]")
	LAZYADD(recently_warned, mob_ref_key)
	addtimer(CALLBACK(src, PROC_REF(clear_recent_warning), mob_ref_key), 3 SECONDS)

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/proc/clear_recent_warning(mob_ref_key)
	LAZYREMOVE(recently_warned, mob_ref_key)
