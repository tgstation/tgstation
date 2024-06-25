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
		GLOB.total_meteors_zapped++
		meteor.make_debris()
		qdel(meteor)

/obj/machinery/satellite/meteor_shield/proc/check_los(turf/source, turf/target) as num
	// if something goes fucky wucky, let's just assume line-of-sight by default
	. = TRUE
	if(!check_sight)
		return TRUE
	for(var/turf/segment as anything in get_line(source, target))
		if(QDELETED(segment))
			continue
		if(isclosedturf(segment) && !istransparentturf(segment))
			return FALSE

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
		far_distance = near_distance * 8,
		quake_factor = 0,
		echo_factor = 0,
		creaking = FALSE,
		near_sound = sound('sound/weapons/lasercannonfire.ogg'),
		far_sound = sound('sound/weapons/marauder.ogg'),
		pressure_affected = FALSE
	)
