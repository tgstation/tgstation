/datum/component/energized
	can_transfer = FALSE
	///what we give to connect_loc by default, makes slippable mobs moving over us slip
	var/static/list/default_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(toast),
	)
	/// Inbound station
	var/inbound
	/// Outbound station
	var/outbound
	/// Transport ID of the tram
	var/specific_transport_id = TRAMSTATION_LINE_1
	/// Weakref to the tram
	var/datum/weakref/transport_ref

/datum/component/energized/Initialize(plate_inbound, plate_outbound, plate_transport_id)
	. = ..()

	if(isnull(plate_inbound))
		return

	inbound = plate_inbound
	if(isnull(plate_outbound))
		return

	outbound = plate_outbound
	if(isnull(plate_transport_id))
		return

	specific_transport_id = plate_transport_id
	find_tram()

/datum/component/energized/proc/find_tram()
	for(var/datum/transport_controller/linear/transport as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		if(transport.specific_transport_id == specific_transport_id)
			transport_ref = WEAKREF(transport)
			break

/datum/component/energized/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(toast))

/datum/component/energized/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ENTERED)
	return ..()


/datum/component/energized/proc/toast(turf/open/floor/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!source.broken && !source.burnt)
		return

	if(!isliving(arrived))
		return

	if(prob(85))
		if(prob(25))
			do_sparks(1, FALSE, source)
			playsound(src, SFX_SPARKS, 40, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			source.audible_message(span_danger("[parent] makes an electric crackle..."))
		return

	var/mob/living/future_tram_victim = arrived
	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()

	// Check for stopped states.
	if(isnull(tram) || !tram.controller_operational || !inbound || !outbound)
		return FALSE

	var/obj/structure/transport/linear/tram/tram_part = tram.return_closest_platform_to(parent)

	if(QDELETED(tram_part))
		return FALSE

	if(isnull(source))
		return FALSE

	// Everything will be based on position and travel direction
	var/plate_pos
	var/tram_pos
	var/tram_velocity_sign // 1 for positive axis movement, -1 for negative
	// Try to be agnostic about N-S vs E-W movement
	if(tram.travel_direction & (NORTH|SOUTH))
		plate_pos = source.y
		tram_pos = source.y
		tram_velocity_sign = tram.travel_direction & NORTH ? 1 : -1
	else
		plate_pos = source.x
		tram_pos = source.x
		tram_velocity_sign = tram.travel_direction & EAST ? 1 : -1

	// How far away are we? negative if already passed.
	var/approach_distance = tram_velocity_sign * (plate_pos - (tram_pos + (DEFAULT_TRAM_LENGTH * 0.5)))

	// Check if our victim is in the active path of the tram.
	if(!tram.controller_active)
		return FALSE
	if(approach_distance < 0)
		return FALSE
	if((tram.travel_direction & WEST) && inbound < tram.destination_platform.platform_code)
		return FALSE
	if((tram.travel_direction & EAST) && outbound > tram.destination_platform.platform_code)
		return FALSE
	if(approach_distance >= AMBER_THRESHOLD_NORMAL)
		return FALSE

	// Finally the interesting part where they ACTUALLY get hit!
	notify_ghosts("[future_tram_victim] has fallen in the path of an oncoming tram!", source = future_tram_victim, action = NOTIFY_ORBIT, header = "Electrifying!")
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	source.audible_message(span_danger("[parent] makes a loud electric crackle!"))
	to_chat(future_tram_victim, span_userdanger("You hear a loud electric crackle!"))
	future_tram_victim.electrocute_act(15, src, 1)
	return TRUE
