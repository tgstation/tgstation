// Proximity monitor applies forced gravity to all turfs in range.
/datum/proximity_monitor/advanced/gravity
	edge_is_a_field = TRUE
	var/gravity_value = 0
	var/list/modified_turfs = list()

/datum/proximity_monitor/advanced/gravity/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, gravity)
	. = ..()
	gravity_value = gravity
	recalculate_field(full_recalc = TRUE)

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

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/field_edge_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(isliving(movable))
		warn_mob(movable, new_location)

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/field_edge_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(isliving(movable))
		warn_mob(movable, old_location)

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/proc/warn_mob(mob/living/to_warn, turf/location)
	var/mob_ref_key = REF(to_warn)
	if(mob_ref_key in recently_warned)
		return

	location.balloon_alert(to_warn, "gravity [(location in modified_turfs) ? "shifts!" : "reverts..."]")
	LAZYADD(recently_warned, mob_ref_key)
	addtimer(CALLBACK(src, PROC_REF(clear_recent_warning), mob_ref_key), 3 SECONDS)

/datum/proximity_monitor/advanced/gravity/warns_on_entrance/proc/clear_recent_warning(mob_ref_key)
	LAZYREMOVE(recently_warned, mob_ref_key)

/obj/gravity_fluff_field
	icon = 'icons/obj/smooth_structures/grav_field.dmi'
	icon_state = "grav_field-0"
	base_icon_state = "grav_field"
	obj_flags = NONE
	anchored = TRUE
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags_self = LETPASSCLICKS
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_GRAV_FIELD
	canSmoothWith = SMOOTH_GROUP_GRAV_FIELD
	alpha = 200
	/// our emissive appearance
	var/mutable_appearance/emissive
	var/particles/particle_type

/obj/gravity_fluff_field/Initialize(mapload, strength)
	. = ..()
	if(isnull(strength))
		return INITIALIZE_HINT_QDEL
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)
	switch(strength)
		if(2 to INFINITY)
			particle_type = /particles/grav_field_down/strong
		if(1 to 2)
			particle_type = /particles/grav_field_down
		if(0 to 1)
			particle_type = /particles/grav_field_float
		if(-INFINITY to -1)
			particle_type = /particles/grav_field_up
	if (particle_type)
		add_shared_particles(/particles/grav_field_down/strong)
		color = particle_type::color
	RegisterSignal(src, COMSIG_ATOM_SMOOTHED_ICON, PROC_REF(smoothed))

/obj/gravity_fluff_field/Destroy(force)
	remove_shared_particles(particle_type)
	emissive = null
	return ..()

/obj/gravity_fluff_field/proc/smoothed(datum/source)
	SIGNAL_HANDLER
	cut_overlay(emissive)
	// because it uses a different name
	emissive = emissive_appearance('icons/obj/smooth_structures/grav_field_emissive.dmi', "grav_field_emissive-[splittext(icon_state, "-")[2]]", src)
	add_overlay(emissive)

// Subtype which adds a subtle overlay to all turfs
/datum/proximity_monitor/advanced/gravity/subtle_effect

/datum/proximity_monitor/advanced/gravity/subtle_effect/setup_field_turf(turf/target)
	. = ..()
	if(!isopenturf(target))
		return
	new /obj/gravity_fluff_field(target, gravity_value)

/datum/proximity_monitor/advanced/gravity/subtle_effect/cleanup_field_turf(turf/target)
	. = ..()
	qdel(locate(/obj/gravity_fluff_field) in target)
