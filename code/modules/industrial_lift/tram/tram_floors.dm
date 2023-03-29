/turf/open/floor/noslip/tram_plate
	name = "linear induction plate"
	desc = "The linear induction plate that powers the tram."
	icon_state = "tram_plate"
	base_icon_state = "tram_plate"
	slowdown = 0
	flags_1 = null

/turf/open/floor/noslip/tram_plate/energized
	desc = "The linear induction plate that powers the tram. It is currently energized."
	/// Weakref to the tram piece we power
	var/datum/weakref/tram_ref
	/// Inbound station
	var/inbound
	/// Outbound station
	var/outbound

/turf/open/floor/noslip/tram_platform
	name = "tram platform"
	desc = "A sturdy looking tram platform."
	icon_state = "tram_platform"
	base_icon_state = "tram_platform"
	slowdown = 0

/turf/open/floor/noslip/tram_plate/broken_states()
	return list("tram_plate-damaged1","tram_plate-damaged2")

/turf/open/floor/noslip/tram_plate/burnt_states()
	return list("tram_plate-scorched1","tram_plate-scorched2")

/turf/open/floor/noslip/tram_platform/broken_states()
	return list("tram_platform-damaged1","tram_platform-damaged2")

/turf/open/floor/noslip/tram_platform/burnt_states()
	return list("tram_platform-scorched1","tram_platform-scorched2")

/turf/open/floor/noslip/tram_plate/energized/proc/link_tram()
	for(var/datum/lift_master/tram/tram as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(tram.specific_lift_id != MAIN_STATION_TRAM)
			continue
		tram_ref = WEAKREF(tram)
		break

/turf/open/floor/noslip/tram_plate/energized/proc/toast(mob/living/future_tram_victim)
	link_tram()
	var/datum/lift_master/tram/tram = tram_ref?.resolve()

	// Check for stopped states.
	if(!tram || !tram.is_operational || !inbound || !outbound)
		return FALSE

	var/obj/structure/industrial_lift/tram/tram_part = tram.return_closest_platform_to(src)

	if(QDELETED(tram_part))
		return FALSE

	// Everything will be based on position and travel direction
	var/plate_pos
	var/tram_pos
	var/tram_velocity_sign // 1 for positive axis movement, -1 for negative
	// Try to be agnostic about N-S vs E-W movement
	if(tram.travel_direction & (NORTH|SOUTH))
		plate_pos = y
		tram_pos = tram_part.y
		tram_velocity_sign = tram.travel_direction & NORTH ? 1 : -1
	else
		plate_pos = x
		tram_pos = tram_part.x
		tram_velocity_sign = tram.travel_direction & EAST ? 1 : -1

	// How far away are we? negative if already passed.
	var/approach_distance = tram_velocity_sign * (plate_pos - (tram_pos + (XING_DEFAULT_TRAM_LENGTH * 0.5)))

	// Check if our victim is in the active path of the tram.
	if(!tram.travelling)
		return FALSE
	if(approach_distance < 0)
		return FALSE
	visible_message(
		span_hear("You hear an electric crackle when you step on the plate...")
	)
	if(tram.travel_direction & WEST && inbound < tram.idle_platform.platform_code)
		return FALSE
	if(tram.travel_direction & EAST && outbound > tram.idle_platform.platform_code)
		return FALSE
	if(approach_distance >= XING_DISTANCE_AMBER)
		return FALSE

	// Finally the interesting part where they ACTUALLY get hit!
	future_tram_victim.electrocute_act(15, src, 1)
	return TRUE
