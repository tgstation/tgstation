GLOBAL_LIST_EMPTY(meteor_shield_sats)

/obj/machinery/satellite/meteor_shield
	/// Whether the meteor sat checks for line of sight to determine if it can intercept a meteor.
	var/check_sight = TRUE
	/// The proximity monitor used to detect meteors entering the shield's range.
	var/datum/proximity_monitor/meteor_monitor
	/// A counter for how many meteors this specific satellite has zapped.
	var/meteors_zapped = 0

/obj/machinery/satellite/meteor_shield/Initialize(mapload)
	. = ..()
	GLOB.meteor_shield_sats += src
	RegisterSignal(src, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(on_space_move)) // so these fuckers don't drift off into space when you're trying to position them
	setup_proximity()
	register_context()

/obj/machinery/satellite/meteor_shield/examine(mob/user)
	. = ..()
	. += span_info("It has stopped <b>[meteors_zapped]</b> meteors so far.")

/obj/machinery/satellite/meteor_shield/proc/on_space_move(datum/source)
	SIGNAL_HANDLER
	return COMSIG_MOVABLE_STOP_SPACEMOVE

/obj/machinery/satellite/meteor_shield/Destroy()
	GLOB.meteor_shield_sats -= src
	if(meteor_monitor)
		QDEL_NULL(meteor_monitor)
	return ..()

/obj/machinery/satellite/meteor_shield/vv_edit_var(vname, vval)
	. = ..()
	if(.)
		switch(vname)
			if(NAMEOF(src, kill_range))
				meteor_monitor?.set_range(kill_range)
			if(NAMEOF(src, active))
				setup_proximity()

/obj/machinery/satellite/meteor_shield/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_LMB] = active ? "Deactivate" : "Activate"
	if(!active)
		context[SCREENTIP_CONTEXT_RMB] = "Pick up"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/satellite/meteor_shield/HasProximity(obj/effect/meteor/meteor)
	if(!active || !istype(meteor) || QDELING(meteor) || (obj_flags & EMAGGED))
		return
	var/turf/our_turf = get_turf(src)
	var/turf/meteor_turf = get_turf(meteor)
	if(!check_los(our_turf, meteor_turf))
		return
	our_turf.Beam(meteor_turf, icon_state = "sat_beam", time = 5)
	if(meteor.shield_defense(src))
		new /obj/effect/temp_visual/explosion(meteor_turf)
		INVOKE_ASYNC(src, PROC_REF(play_zap_sound), meteor_turf)
		SSblackbox.record_feedback("tally", "meteors_zapped", 1, "[meteor.type]")
		meteors_zapped++
		qdel(meteor)

/obj/machinery/satellite/meteor_shield/proc/check_los(turf/source, turf/target) as num
	// if something goes fucky wucky, let's just assume line-of-sight by default
	if(!check_sight)
		return TRUE
	for(var/turf/segment as anything in get_line(source, target))
		if(QDELETED(segment))
			continue
		if(isclosedturf(segment) && !istransparentturf(segment))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/proc/play_zap_sound(turf/epicenter)
	if(QDELETED(epicenter))
		return
	var/static/near_distance
	if(isnull(near_distance))
		var/list/world_view = getviewsize(world.view)
		near_distance = max(world_view[1], world_view[2])
	SSexplosions.shake_the_room(
		epicenter,
		near_distance,
		far_distance = near_distance * 3,
		quake_factor = 0,
		echo_factor = 0,
		creaking = FALSE,
		near_sound = sound('sound/weapons/lasercannonfire.ogg'),
		far_sound = sound('sound/weapons/marauder.ogg')
	)

/obj/machinery/satellite/meteor_shield/toggle(user)
	. = ..()
	setup_proximity()

/obj/machinery/satellite/meteor_shield/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	setup_proximity()

/obj/machinery/satellite/meteor_shield/proc/setup_proximity()
	if((obj_flags & EMAGGED) || !active)
		if(!QDELETED(meteor_monitor))
			QDEL_NULL(meteor_monitor)
	else
		if(QDELETED(meteor_monitor))
			meteor_monitor = new(src, kill_range)

/obj/machinery/satellite/meteor_shield/piercing
	check_sight = FALSE

/proc/get_meteor_sat_coverage() as num
	var/list/covered_tiles = list()
	for(var/obj/machinery/satellite/meteor_shield/sat as anything in GLOB.meteor_shield_sats)
		if(QDELETED(sat) || !sat.active || !is_station_level(sat.z) || (sat.obj_flags & EMAGGED))
			continue
		if(sat.check_sight)
			covered_tiles |= view(sat.kill_range, sat)
		else
			covered_tiles |= range(sat.kill_range, sat)
	return length(covered_tiles)


/obj/machinery/satellite/meteor_shield/proc/change_meteor_chance(mod = 1)
	var/static/list/meteor_event_typecache
	if(!meteor_event_typecache)
		meteor_event_typecache = typecacheof(list(
			/datum/round_event_control/meteor_wave,
			/datum/round_event_control/sandstorm,
			/datum/round_event_control/space_dust,
			/datum/round_event_control/stray_meteor
		))
	var/list/all_events = SSevents.control | SSgamemode.control
	for(var/datum/round_event_control/event as anything in all_events)
		if(is_type_in_typecache(event, meteor_event_typecache))
			event.weight *= mod

/obj/machinery/satellite/meteor_shield/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !can_interact(user))
		return
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(active)
		balloon_alert(user, "can't pick up while active!")
		return
	balloon_alert(user, "picking up satellite...")
	if(do_after(user, 5 SECONDS, src))
		var/obj/item/meteor_shield_capsule/capsule = new(drop_location())
		user.put_in_hands(capsule)
		qdel(src)

/obj/item/meteor_shield_capsule
	name = "meteor shield satellite capsule"
	desc = "A bluespace capsule which a single unit of meteor shield satellite is compressed within. If you activate this capsule, a meteor shield satellite will pop out. You still need to install these."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY

/obj/item/meteor_shield_capsule/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 5 SECONDS, /obj/machinery/satellite/meteor_shield, delete_on_use = TRUE)
