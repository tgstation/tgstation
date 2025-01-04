/obj/docking_port/mobile/emergency
	name = "emergency shuttle"
	shuttle_id = "emergency"
	dir = EAST
	port_direction = WEST
	var/sound_played = 0 //If the launch sound has been sent to all players on the shuttle itself
	var/hijack_status = HIJACK_NOT_BEGUN

/obj/docking_port/mobile/emergency/Initialize(mapload)
	. = ..()

	setup_shuttle_events()

/obj/docking_port/mobile/emergency/canDock(obj/docking_port/stationary/S)
	return SHUTTLE_CAN_DOCK //If the emergency shuttle can't move, the whole game breaks, so it will force itself to land even if it has to crush a few departments in the process

/obj/docking_port/mobile/emergency/register()
	. = ..()
	SSshuttle.emergency = src

/obj/docking_port/mobile/emergency/Destroy(force)
	if(force)
		// This'll make the shuttle subsystem use the backup shuttle.
		if(src == SSshuttle.emergency)
			// If we're the selected emergency shuttle
			SSshuttle.emergencyDeregister()

	. = ..()

/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, area/signal_origin, reason, red_alert, set_coefficient=null)
	if(!isnum(set_coefficient))
		set_coefficient = SSsecurity_level.current_security_level.shuttle_call_time_mod
	alert_coeff = set_coefficient
	var/call_time = SSshuttle.emergency_call_time * alert_coeff * engine_coeff
	switch(mode)
		// The shuttle can not normally be called while "recalling", so
		// if this proc is called, it's via admin fiat
		if(SHUTTLE_RECALL, SHUTTLE_IDLE, SHUTTLE_CALL)
			mode = SHUTTLE_CALL
			setTimer(call_time)
		else
			return

	SSshuttle.emergencyCallAmount++

	if(prob(70))
		SSshuttle.emergency_last_call_loc = signal_origin
	else
		SSshuttle.emergency_last_call_loc = null

	priority_announce(
		text = "The emergency shuttle has been called. [red_alert ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [(timeLeft(60 SECONDS))] minutes.[reason][SSshuttle.emergency_last_call_loc ? "\n\nCall signal traced. Results can be viewed on any communications console." : "" ][SSshuttle.admin_emergency_no_recall ? "\n\nWarning: Shuttle recall subroutines disabled; Recall not possible." : ""]",
		title = "Emergency Shuttle Dispatched",
		sound = ANNOUNCER_SHUTTLECALLED,
		sender_override = "Emergency Shuttle Uplink Alert",
		color_override = "orange",
		)

/obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
	if(mode != SHUTTLE_CALL)
		return
	if(SSshuttle.emergency_no_recall)
		return

	invertTimer()
	mode = SHUTTLE_RECALL

	if(prob(70))
		SSshuttle.emergency_last_call_loc = signalOrigin
	else
		SSshuttle.emergency_last_call_loc = null
	priority_announce(
		text = "The emergency shuttle has been recalled.[SSshuttle.emergency_last_call_loc ? " Recall signal traced. Results can be viewed on any communications console." : "" ]",
		title = "Emergency Shuttle Recalled",
		sound = ANNOUNCER_SHUTTLERECALLED,
		sender_override = "Emergency Shuttle Uplink Alert",
		color_override = "orange",
		)

	SSticker.emergency_reason = null

/**
 * Proc that handles checking if the emergency shuttle was successfully hijacked via being the only people present on the shuttle for the elimination hijack or highlander objective
 *
 * Checks for all mobs on the shuttle, checks their status, and checks if they're
 * borgs or simple animals. Depending on the args, certain mobs may be ignored,
 * and the presence of other antags may or may not invalidate a hijack.
 * Args:
 * filter_by_human, default TRUE, tells the proc that only humans should block a hijack. Borgs and animals are ignored and will not block if this is TRUE.
 * solo_hijack, default FALSE, tells the proc to fail with multiple hijackers, such as for Highlander mode.
 */
/obj/docking_port/mobile/emergency/proc/elimination_hijack(filter_by_human = TRUE, solo_hijack = FALSE)
	var/has_people = FALSE
	var/hijacker_count = 0
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			if(player.stat != DEAD)
				if(issilicon(player) && filter_by_human) //Borgs are technically dead anyways
					continue
				if(isanimal_or_basicmob(player) && filter_by_human) //animals don't count
					continue
				if(isbrain(player)) //also technically dead
					continue
				if(shuttle_areas[get_area(player)])
					has_people = TRUE
					var/location = get_area(player.mind.current)
					//Non-antag present. Can't hijack.
					if(!(player.mind.has_antag_datum(/datum/antagonist)) && !istype(location, /area/shuttle/escape/brig))
						return FALSE
					//Antag present, doesn't stop but let's see if we actually want to hijack
					var/prevent = FALSE
					for(var/datum/antagonist/A in player.mind.antag_datums)
						if(A.can_elimination_hijack == ELIMINATION_ENABLED)
							hijacker_count += 1
							prevent = FALSE
							break //If we have both prevent and hijacker antags assume we want to hijack.
						else if(A.can_elimination_hijack == ELIMINATION_PREVENT)
							prevent = TRUE
					if(prevent)
						return FALSE

	//has people AND either there's only one hijacker or there's any but solo_hijack is disabled
	return has_people && ((hijacker_count == 1) || (hijacker_count && !solo_hijack))

/obj/docking_port/mobile/emergency/proc/is_hijacked()
	return hijack_status == HIJACK_COMPLETED

/obj/docking_port/mobile/emergency/proc/ShuttleDBStuff()
	set waitfor = FALSE
	if(!SSdbcore.Connect())
		return
	var/datum/db_query/query_round_shuttle_name = SSdbcore.NewQuery({"
		UPDATE [format_table_name("round")] SET shuttle_name = :name WHERE id = :round_id
	"}, list("name" = name, "round_id" = GLOB.round_id))
	query_round_shuttle_name.Execute()
	qdel(query_round_shuttle_name)

/obj/docking_port/mobile/emergency/check()
	if(!timer)
		return
	var/time_left = timeLeft(1)

	// The emergency shuttle doesn't work like others so this
	// ripple check is slightly different
	if(!ripples.len && (time_left <= SHUTTLE_RIPPLE_TIME) && ((mode == SHUTTLE_CALL) || (mode == SHUTTLE_ESCAPE)))
		var/destination
		if(mode == SHUTTLE_CALL)
			destination = SSshuttle.getDock("emergency_home")
		else if(mode == SHUTTLE_ESCAPE)
			destination = SSshuttle.getDock("emergency_away")
		create_ripples(destination)

	switch(mode)
		if(SHUTTLE_RECALL)
			if(time_left <= 0)
				mode = SHUTTLE_IDLE
				timer = 0
		if(SHUTTLE_CALL)
			if(time_left <= 0)
				//move emergency shuttle to station
				if(initiate_docking(SSshuttle.getDock("emergency_home")) != DOCKING_SUCCESS)
					setTimer(20)
					return
				mode = SHUTTLE_DOCKED
				setTimer(SSshuttle.emergency_dock_time)
				send2adminchat("Server", "The Emergency Shuttle has docked with the station.")
				priority_announce(
					text = "[SSshuttle.emergency] has docked with the station. You have [DisplayTimeText(SSshuttle.emergency_dock_time)] to board the emergency shuttle.",
					title = "Emergency Shuttle Arrival",
					sound = ANNOUNCER_SHUTTLEDOCK,
					sender_override = "Emergency Shuttle Uplink Alert",
					color_override = "orange",
				)
				ShuttleDBStuff()
				addtimer(CALLBACK(src, PROC_REF(announce_shuttle_events)), 20 SECONDS)


		if(SHUTTLE_DOCKED)
			if(time_left <= ENGINE_START_TIME)
				mode = SHUTTLE_IGNITING
				SSshuttle.checkHostileEnvironment()
				if(mode == SHUTTLE_STRANDED)
					return
				for(var/A in SSshuttle.mobile_docking_ports)
					var/obj/docking_port/mobile/M = A
					if(M.launch_status == UNLAUNCHED) //Pods will not launch from the mine/planet, and other ships won't launch unless we tell them to.
						M.check_transit_zone()

		if(SHUTTLE_IGNITING)
			var/success = TRUE
			SSshuttle.checkHostileEnvironment()
			if(mode == SHUTTLE_STRANDED)
				return

			success &= (check_transit_zone() == TRANSIT_READY)
			for(var/A in SSshuttle.mobile_docking_ports)
				var/obj/docking_port/mobile/M = A
				if(M.launch_status == UNLAUNCHED)
					success &= (M.check_transit_zone() == TRANSIT_READY)
			if(!success)
				setTimer(ENGINE_START_TIME)

			if(time_left <= 50 && !sound_played) //4 seconds left:REV UP THOSE ENGINES BOYS. - should sync up with the launch
				sound_played = 1 //Only rev them up once.
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.areas)
					areas += E
				hyperspace_sound(HYPERSPACE_WARMUP, areas)

			if(time_left <= 0 && !SSshuttle.emergency_no_escape)
				//move each escape pod (or applicable spaceship) to its corresponding transit dock
				for(var/A in SSshuttle.mobile_docking_ports)
					var/obj/docking_port/mobile/M = A
					M.on_emergency_launch()

				//now move the actual emergency shuttle to its transit dock
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.areas)
					areas += E
				hyperspace_sound(HYPERSPACE_LAUNCH, areas)
				enterTransit()

				//Tell the events we're starting, so they can time their spawns or do some other stuff
				for(var/datum/shuttle_event/event as anything in event_list)
					event.start_up_event(SSshuttle.emergency_escape_time * engine_coeff)

				mode = SHUTTLE_ESCAPE
				launch_status = ENDGAME_LAUNCHED
				setTimer(SSshuttle.emergency_escape_time * engine_coeff)
				priority_announce(
					text = "The emergency shuttle has left the station. Estimate [timeLeft(60 SECONDS)] minutes until the shuttle docks at [command_name()].",
					title = "Emergency Shuttle Departure",
					sender_override = "Emergency Shuttle Uplink Alert",
					color_override = "orange",
				)
				INVOKE_ASYNC(SSticker, TYPE_PROC_REF(/datum/controller/subsystem/ticker, poll_hearts))
				INVOKE_ASYNC(SSvote, TYPE_PROC_REF(/datum/controller/subsystem/vote, initiate_vote), /datum/vote/map_vote, vote_initiator_name = "Map Rotation", forced = TRUE)

				if(!is_reserved_level(z))
					CRASH("Emergency shuttle did not move to transit z-level!")

		if(SHUTTLE_STRANDED, SHUTTLE_DISABLED)
			SSshuttle.checkHostileEnvironment()


		if(SHUTTLE_ESCAPE)
			if(sound_played && time_left <= HYPERSPACE_END_TIME)
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.areas)
					areas += E
				hyperspace_sound(HYPERSPACE_END, areas)
			if(time_left <= PARALLAX_LOOP_TIME)
				var/area_parallax = FALSE
				for(var/place in shuttle_areas)
					var/area/shuttle/shuttle_area = place
					if(shuttle_area.parallax_movedir)
						area_parallax = TRUE
						break
				if(area_parallax)
					parallax_slowdown()
					for(var/A in SSshuttle.mobile_docking_ports)
						var/obj/docking_port/mobile/M = A
						if(M.launch_status == ENDGAME_LAUNCHED)
							if(istype(M, /obj/docking_port/mobile/pod))
								M.parallax_slowdown()

			process_events()

			if(time_left <= 0)
				//move each escape pod to its corresponding escape dock
				for(var/obj/docking_port/mobile/port as anything in SSshuttle.mobile_docking_ports)
					port.on_emergency_dock()

				// now move the actual emergency shuttle to centcom
				// unless the shuttle is "hijacked"
				var/destination_dock = "emergency_away"
				if(is_hijacked() || elimination_hijack())
					// just double check
					SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_NUKIEBASE)
					destination_dock = "emergency_syndicate"
					minor_announce("Corruption detected in \
						shuttle navigation protocols. Please contact your \
						supervisor.", "SYSTEM ERROR:", sound_override = 'sound/announcer/announcement/announce_syndi.ogg')

				dock_id(destination_dock)
				mode = SHUTTLE_ENDGAME
				timer = 0

/obj/docking_port/mobile/emergency/transit_failure()
	..()
	message_admins("Moving emergency shuttle directly to centcom dock to prevent deadlock.")

	mode = SHUTTLE_ESCAPE
	launch_status = ENDGAME_LAUNCHED
	setTimer(SSshuttle.emergency_escape_time)
	priority_announce(
		text = "The emergency shuttle is preparing for direct jump. Estimate [timeLeft(60 SECONDS)] minutes until the shuttle docks at [command_name()].",
		title = "Emergency Shuttle Transit Failure",
		sender_override = "Emergency Shuttle Uplink Alert",
		color_override = "orange",
	)

///Generate a list of events to run during the departure
/obj/docking_port/mobile/emergency/proc/setup_shuttle_events()
	var/list/names = list()
	for(var/datum/shuttle_event/event as anything in subtypesof(/datum/shuttle_event))
		if(prob(initial(event.event_probability)))
			add_shuttle_event(event)
			names += initial(event.name)
	if(LAZYLEN(names))
		log_game("[capitalize(name)] has selected the following shuttle events: [english_list(names)].")
