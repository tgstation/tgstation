#define TIME_LEFT (SSshuttle.emergency.timeLeft())
#define ENGINES_START_TIME 100
#define ENGINES_STARTED (SSshuttle.emergency.mode == SHUTTLE_IGNITING)
#define IS_DOCKED (SSshuttle.emergency.mode == SHUTTLE_DOCKED || (ENGINES_STARTED))
#define SHUTTLE_CONSOLE_ACTION_DELAY (5 SECONDS)

#define NOT_BEGUN 0
#define STAGE_1 1
#define STAGE_2 2
#define STAGE_3 3
#define STAGE_4 4
#define HIJACKED 5

/obj/machinery/computer/emergency_shuttle
	name = "emergency shuttle console"
	desc = "For shuttle control."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	resistance_flags = INDESTRUCTIBLE
	var/auth_need = 3
	var/list/authorized = list()
	var/list/acted_recently = list()
	var/hijack_last_stage_increase = 0 SECONDS
	var/hijack_stage_time = 5 SECONDS
	var/hijack_stage_cooldown = 5 SECONDS
	var/hijack_flight_time_increase = 30 SECONDS
	var/hijack_completion_flight_time_set = 10 SECONDS //How long in deciseconds to set shuttle's timer after hijack is done.
	var/hijack_hacking = FALSE
	var/hijack_announce = TRUE

/obj/machinery/computer/emergency_shuttle/examine(mob/user)
	. = ..()
	if(hijack_announce)
		. += span_danger("Security systems present on console. Any unauthorized tampering will result in an emergency announcement.")
	if(user?.mind?.get_hijack_speed())
		. += span_danger("Alt click on this to attempt to hijack the shuttle. This will take multiple tries (current: stage [SSshuttle.emergency.hijack_status]/[HIJACKED]).")
		. += span_notice("It will take you [(hijack_stage_time * user.mind.get_hijack_speed()) / 10] seconds to reprogram a stage of the shuttle's navigational firmware, and the console will undergo automated timed lockout for [hijack_stage_cooldown/10] seconds after each stage.")
		if(hijack_announce)
			. += span_warning("It is probably best to fortify your position as to be uninterrupted during the attempt, given the automatic announcements..")

/obj/machinery/computer/emergency_shuttle/attackby(obj/item/I, mob/user,params)
	if(istype(I, /obj/item/card/id))
		say("Please equip your ID card into your ID slot to authenticate.")
	. = ..()

/obj/machinery/computer/emergency_shuttle/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/machinery/computer/emergency_shuttle/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EmergencyShuttleConsole", name)
		ui.open()

/obj/machinery/computer/emergency_shuttle/ui_data(user)
	var/list/data = list()

	data["timer_str"] = SSshuttle.emergency.getTimerStr()
	data["engines_started"] = ENGINES_STARTED
	data["authorizations_remaining"] = max((auth_need - authorized.len), 0)
	var/list/A = list()
	for(var/i in authorized)
		var/obj/item/card/id/ID = i
		var/name = ID.registered_name
		var/job = ID.assignment

		if(obj_flags & EMAGGED)
			name = Gibberish(name)
			job = Gibberish(job)
		A += list(list("name" = name, "job" = job))
	data["authorizations"] = A

	data["enabled"] = (IS_DOCKED && !ENGINES_STARTED) && !(user in acted_recently)
	data["emagged"] = obj_flags & EMAGGED ? 1 : 0
	return data

/obj/machinery/computer/emergency_shuttle/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(ENGINES_STARTED) // past the point of no return
		return
	if(!IS_DOCKED) // shuttle computer only has uses when onstation
		return
	if(SSshuttle.emergency.mode == SHUTTLE_DISABLED) // admins have disabled the shuttle.
		return
	if(!isliving(usr))
		return

	var/mob/living/user = usr
	. = FALSE

	var/obj/item/card/id/ID = user.get_idcard(TRUE)

	if(!ID)
		to_chat(user, span_warning("You don't have an ID."))
		return

	if(!(ACCESS_HEADS in ID.access))
		to_chat(user, span_warning("The access level of your card is not high enough."))
		return

	if (user in acted_recently)
		return

	var/old_len = authorized.len
	addtimer(CALLBACK(src, .proc/clear_recent_action, user), SHUTTLE_CONSOLE_ACTION_DELAY)

	switch(action)
		if("authorize")
			. = authorize(user)

		if("repeal")
			authorized -= ID

		if("abort")
			if(authorized.len)
				// Abort. The action for when heads are fighting over whether
				// to launch early.
				authorized.Cut()
				. = TRUE

	if((old_len != authorized.len) && !ENGINES_STARTED)
		var/alert = (authorized.len > old_len)
		var/repeal = (authorized.len < old_len)
		var/remaining = max(0, auth_need - authorized.len)
		if(authorized.len && remaining)
			minor_announce("[remaining] authorizations needed until shuttle is launched early", null, alert)
		if(repeal)
			minor_announce("Early launch authorization revoked, [remaining] authorizations needed")

	acted_recently += user
	ui_interact(user)

/obj/machinery/computer/emergency_shuttle/proc/authorize(mob/living/user, source)
	var/obj/item/card/id/ID = user.get_idcard(TRUE)

	if(ID in authorized)
		return FALSE
	for(var/i in authorized)
		var/obj/item/card/id/other = i
		if(other.registered_name == ID.registered_name)
			return FALSE // No using IDs with the same name

	authorized += ID

	message_admins("[ADMIN_LOOKUPFLW(user)] has authorized early shuttle launch")
	log_shuttle("[key_name(user)] has authorized early shuttle launch in [COORD(src)]")
	// Now check if we're on our way
	. = TRUE
	process(SSMACHINES_DT)

/obj/machinery/computer/emergency_shuttle/proc/clear_recent_action(mob/user)
	acted_recently -= user
	if (!QDELETED(user))
		ui_interact(user)

/obj/machinery/computer/emergency_shuttle/process()
	// Launch check is in process in case auth_need changes for some reason
	// probably external.
	. = FALSE
	if(!SSshuttle.emergency)
		return

	if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
		authorized.Cut()
		obj_flags &= ~(EMAGGED)

	if(ENGINES_STARTED || (!IS_DOCKED))
		return .

	// Check to see if we've reached criteria for early launch
	if((authorized.len >= auth_need) || (obj_flags & EMAGGED))
		// shuttle timers use 1/10th seconds internally
		SSshuttle.emergency.setTimer(ENGINES_START_TIME)
		var/system_error = obj_flags & EMAGGED ? "SYSTEM ERROR:" : null
		minor_announce("The emergency shuttle will launch in \
			[TIME_LEFT] seconds", system_error, alert=TRUE)
		. = TRUE

/obj/machinery/computer/emergency_shuttle/proc/increase_hijack_stage()
	var/obj/docking_port/mobile/emergency/shuttle = SSshuttle.emergency
	shuttle.hijack_status++
	if(hijack_announce)
		announce_hijack_stage()
	hijack_last_stage_increase = world.time
	say("Navigational protocol error! Rebooting systems.")
	if(shuttle.mode == SHUTTLE_ESCAPE)
		if(shuttle.hijack_status == HIJACKED)
			shuttle.setTimer(hijack_completion_flight_time_set)
		else
			shuttle.setTimer(shuttle.timeLeft(1) + hijack_flight_time_increase) //give the guy more time to hijack if it's already in flight.
	return shuttle.hijack_status

/obj/machinery/computer/emergency_shuttle/AltClick(user)
	if(isliving(user))
		attempt_hijack_stage(user)

/obj/machinery/computer/emergency_shuttle/proc/attempt_hijack_stage(mob/living/user)
	if(!user.CanReach(src))
		return
	if(!user?.mind?.get_hijack_speed())
		to_chat(user, "<span class='warning'>You manage to open a user-mode shell on [src], and hundreds of lines of debugging output fly through your vision. It is probably best to leave this alone.</span.")
		return
	if(!EMERGENCY_AT_LEAST_DOCKED) // prevent advancing hijack stages on BYOS shuttles until the shuttle has "docked"
		to_chat(user, "<span class='warning'>The flight plans for the shuttle haven't been loaded yet, you can't hack this right now.</span.")
		return
	if(hijack_hacking == TRUE)
		return
	if(SSshuttle.emergency.hijack_status >= HIJACKED)
		to_chat(user, span_warning("The emergency shuttle is already loaded with a corrupt navigational payload. What more do you want from it?"))
		return
	if(hijack_last_stage_increase >= world.time + hijack_stage_cooldown)
		say("Error - Catastrophic software error detected. Input is currently on timeout.")
		return
	hijack_hacking = TRUE
	to_chat(user, span_boldwarning("You [SSshuttle.emergency.hijack_status == NOT_BEGUN? "begin" : "continue"] to override [src]'s navigational protocols."))
	say("Software override initiated.")
	var/turf/console_hijack_turf = get_turf(src)
	message_admins("[src] is being overriden for hijack by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(console_hijack_turf)]")
	log_game("[src] is being overriden for hijack by [key_name(user)] at [AREACOORD(src)]")
	. = FALSE
	if(do_after(user, hijack_stage_time * (1 / user.mind.get_hijack_speed()), target = src))
		increase_hijack_stage()
		console_hijack_turf = get_turf(src)
		message_admins("[src] has had its hijack stage increased to stage [SSshuttle.emergency.hijack_status] out of [HIJACKED] by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(console_hijack_turf)]")
		log_game("[src] has had its hijack stage increased to stage [SSshuttle.emergency.hijack_status] out of [HIJACKED] by [key_name(user)] at [AREACOORD(src)]")
		. = TRUE
		to_chat(user, span_notice("You reprogram some of [src]'s programming, putting it on timeout for [hijack_stage_cooldown/10] seconds."))
	hijack_hacking = FALSE

/obj/machinery/computer/emergency_shuttle/proc/announce_hijack_stage()
	var/msg
	switch(SSshuttle.emergency.hijack_status)
		if(NOT_BEGUN)
			return
		if(STAGE_1)
			msg = "AUTHENTICATING - FAIL. AUTHENTICATING - FAIL. AUTHENTICATING - FAI###### Welcome, technician JOHN DOE."
		if(STAGE_2)
			msg = "Warning: Navigational route fails \"IS_AUTHORIZED\". Please try againNN[scramble_message_replace_chars("againagainagainagainagain", 70)]."
		if(STAGE_3)
			msg = "CRC mismatch at ~h~ in calculated route buffer. Full reset initiated of FTL_NAVIGATION_SERVICES. Memory decrypted for automatic repair."
		if(STAGE_4)
			msg = "~ACS_directive module_load(cyberdyne.exploit.nanotrasen.shuttlenav)... NT key mismatch. Confirm load? Y...###Reboot complete. $SET transponder_state = 0; System link initiated with connected engines..."
		if(HIJACKED)
			msg = "SYSTEM OVERRIDE - Resetting course to \[[scramble_message_replace_chars("###########", 100)]\] \
			([scramble_message_replace_chars("#######", 100)]/[scramble_message_replace_chars("#######", 100)]/[scramble_message_replace_chars("#######", 100)]) \
			{AUTH - ROOT (uid: 0)}.</font>[SSshuttle.emergency.mode == SHUTTLE_ESCAPE ? "Diverting from existing route - Bluespace exit in [hijack_completion_flight_time_set/10] seconds." : ""]"
	minor_announce(scramble_message_replace_chars(msg, replaceprob = 10), "Emergency Shuttle", TRUE)

/obj/machinery/computer/emergency_shuttle/emag_act(mob/user)
	// How did you even get on the shuttle before it go to the station?
	if(!IS_DOCKED)
		return

	if((obj_flags & EMAGGED) || ENGINES_STARTED) //SYSTEM ERROR: THE SHUTTLE WILL LA-SYSTEM ERROR: THE SHUTTLE WILL LA-SYSTEM ERROR: THE SHUTTLE WILL LAUNCH IN 10 SECONDS
		to_chat(user, span_warning("The shuttle is already about to launch!"))
		return

	var/time = TIME_LEFT
	message_admins("[ADMIN_LOOKUPFLW(user)] has emagged the emergency shuttle [time] seconds before launch.")
	log_shuttle("[key_name(user)] has emagged the emergency shuttle in [COORD(src)] [time] seconds before launch.")

	obj_flags |= EMAGGED
	SSshuttle.emergency.movement_force = list("KNOCKDOWN" = 60, "THROW" = 20)//YOUR PUNY SEATBELTS can SAVE YOU NOW, MORTAL
	var/datum/species/S = new
	for(var/i in 1 to 10)
		// the shuttle system doesn't know who these people are, but they
		// must be important, surely
		var/obj/item/card/id/ID = new(src)
		var/datum/job/J = pick(SSjob.joinable_occupations)
		ID.registered_name = S.random_name(pick(MALE, FEMALE))
		ID.assignment = J.title

		authorized += ID

	process(SSMACHINES_DT)

/obj/machinery/computer/emergency_shuttle/Destroy()
	// Our fake IDs that the emag generated are just there for colour
	// They're not supposed to be accessible

	for(var/obj/item/card/id/ID in src)
		qdel(ID)
	if(authorized?.len)
		authorized.Cut()
	authorized = null

	. = ..()

/obj/docking_port/mobile/emergency
	name = "emergency shuttle"
	id = "emergency"

	dwidth = 9
	width = 22
	height = 11
	dir = EAST
	port_direction = WEST
	var/sound_played = 0 //If the launch sound has been sent to all players on the shuttle itself
	var/hijack_status = NOT_BEGUN

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

/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, area/signalOrigin, reason, redAlert, set_coefficient=null)
	if(!isnum(set_coefficient))
		var/security_num = seclevel2num(get_security_level())
		switch(security_num)
			if(SEC_LEVEL_GREEN)
				set_coefficient = 2
			if(SEC_LEVEL_BLUE)
				set_coefficient = 1
			else
				set_coefficient = 0.5
	var/call_time = SSshuttle.emergencyCallTime * set_coefficient * engine_coeff
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
		SSshuttle.emergencyLastCallLoc = signalOrigin
	else
		SSshuttle.emergencyLastCallLoc = null

	priority_announce("The emergency shuttle has been called. [redAlert ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [timeLeft(600)] minutes.[reason][SSshuttle.emergencyLastCallLoc ? "\n\nCall signal traced. Results can be viewed on any communications console." : "" ][SSshuttle.adminEmergencyNoRecall ? "\n\nWarning: Shuttle recall subroutines disabled; Recall not possible." : ""]", null, ANNOUNCER_SHUTTLECALLED, "Priority")

/obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
	if(mode != SHUTTLE_CALL)
		return
	if(SSshuttle.emergencyNoRecall)
		return

	invertTimer()
	mode = SHUTTLE_RECALL

	if(prob(70))
		SSshuttle.emergencyLastCallLoc = signalOrigin
	else
		SSshuttle.emergencyLastCallLoc = null
	priority_announce("The emergency shuttle has been recalled.[SSshuttle.emergencyLastCallLoc ? " Recall signal traced. Results can be viewed on any communications console." : "" ]", null, ANNOUNCER_SHUTTLERECALLED, "Priority")

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
				if(isanimal(player) && filter_by_human) //animals don't count
					continue
				if(isbrain(player)) //also technically dead
					continue
				if(shuttle_areas[get_area(player)])
					has_people = TRUE
					var/location = get_turf(player.mind.current)
					//Non-antag present. Can't hijack.
					if(!(player.mind.has_antag_datum(/datum/antagonist)) && !istype(location, /turf/open/floor/mineral/plastitanium/red/brig))
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
	return hijack_status == HIJACKED

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
				setTimer(SSshuttle.emergencyDockTime)
				send2adminchat("Server", "The Emergency Shuttle has docked with the station.")
				priority_announce("[SSshuttle.emergency] has docked with the station. You have [timeLeft(600)] minutes to board the Emergency Shuttle.", null, ANNOUNCER_SHUTTLEDOCK, "Priority")
				ShuttleDBStuff()


		if(SHUTTLE_DOCKED)
			if(time_left <= ENGINES_START_TIME)
				mode = SHUTTLE_IGNITING
				SSshuttle.checkHostileEnvironment()
				if(mode == SHUTTLE_STRANDED)
					return
				for(var/A in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = A
					if(M.launch_status == UNLAUNCHED) //Pods will not launch from the mine/planet, and other ships won't launch unless we tell them to.
						M.check_transit_zone()

		if(SHUTTLE_IGNITING)
			var/success = TRUE
			SSshuttle.checkHostileEnvironment()
			if(mode == SHUTTLE_STRANDED)
				return

			success &= (check_transit_zone() == TRANSIT_READY)
			for(var/A in SSshuttle.mobile)
				var/obj/docking_port/mobile/M = A
				if(M.launch_status == UNLAUNCHED)
					success &= (M.check_transit_zone() == TRANSIT_READY)
			if(!success)
				setTimer(ENGINES_START_TIME)

			if(time_left <= 50 && !sound_played) //4 seconds left:REV UP THOSE ENGINES BOYS. - should sync up with the launch
				sound_played = 1 //Only rev them up once.
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.sortedAreas)
					areas += E
				hyperspace_sound(HYPERSPACE_WARMUP, areas)

			if(time_left <= 0 && !SSshuttle.emergencyNoEscape)
				//move each escape pod (or applicable spaceship) to its corresponding transit dock
				for(var/A in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = A
					M.on_emergency_launch()

				//now move the actual emergency shuttle to its transit dock
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.sortedAreas)
					areas += E
				hyperspace_sound(HYPERSPACE_LAUNCH, areas)
				enterTransit()
				mode = SHUTTLE_ESCAPE
				launch_status = ENDGAME_LAUNCHED
				setTimer(SSshuttle.emergencyEscapeTime * engine_coeff)
				priority_announce("The Emergency Shuttle has left the station. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.", null, null, "Priority")
				INVOKE_ASYNC(SSticker, /datum/controller/subsystem/ticker.proc/poll_hearts)
				SSmapping.mapvote() //If no map vote has been run yet, start one.

		if(SHUTTLE_STRANDED, SHUTTLE_DISABLED)
			SSshuttle.checkHostileEnvironment()


		if(SHUTTLE_ESCAPE)
			if(sound_played && time_left <= HYPERSPACE_END_TIME)
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.sortedAreas)
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
					for(var/A in SSshuttle.mobile)
						var/obj/docking_port/mobile/M = A
						if(M.launch_status == ENDGAME_LAUNCHED)
							if(istype(M, /obj/docking_port/mobile/pod))
								M.parallax_slowdown()

			if(time_left <= 0)
				//move each escape pod to its corresponding escape dock
				for(var/A in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = A
					M.on_emergency_dock()

				// now move the actual emergency shuttle to centcom
				// unless the shuttle is "hijacked"
				var/destination_dock = "emergency_away"
				if(is_hijacked() || elimination_hijack())
					destination_dock = "emergency_syndicate"
					minor_announce("Corruption detected in \
						shuttle navigation protocols. Please contact your \
						supervisor.", "SYSTEM ERROR:", alert=TRUE)

				dock_id(destination_dock)
				mode = SHUTTLE_ENDGAME
				timer = 0

/obj/docking_port/mobile/emergency/transit_failure()
	..()
	message_admins("Moving emergency shuttle directly to centcom dock to prevent deadlock.")

	mode = SHUTTLE_ESCAPE
	launch_status = ENDGAME_LAUNCHED
	setTimer(SSshuttle.emergencyEscapeTime)
	priority_announce("The Emergency Shuttle is preparing for direct jump. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.", null, null, "Priority")


/obj/docking_port/mobile/pod
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	launch_status = UNLAUNCHED

/obj/docking_port/mobile/pod/request(obj/docking_port/stationary/S)
	var/obj/machinery/computer/shuttle/C = getControlConsole()
	if(!istype(C, /obj/machinery/computer/shuttle/pod))
		return ..()
	if(SSsecurity_level.current_level >= SEC_LEVEL_RED || (C && (C.obj_flags & EMAGGED)))
		if(launch_status == UNLAUNCHED)
			launch_status = EARLY_LAUNCHED
			return ..()
	else
		to_chat(usr, span_warning("Escape pods will only launch during \"Code Red\" security alert."))
		return TRUE

/obj/docking_port/mobile/pod/cancel()
	return

/obj/machinery/computer/shuttle/pod
	name = "pod control computer"
	locked = TRUE
	possible_destinations = "pod_asteroid"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	light_color = LIGHT_COLOR_BLUE
	density = FALSE

/obj/machinery/computer/shuttle/pod/Initialize(mapload)
	. = ..()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, .proc/check_lock)

/obj/machinery/computer/shuttle/pod/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

/obj/machinery/computer/shuttle/pod/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	locked = FALSE
	to_chat(user, span_warning("You fry the pod's alert level checking system."))

/obj/machinery/computer/shuttle/pod/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	. = ..()
	if(port)
		possible_destinations += ";[port.id]_lavaland"

/**
 * Signal handler for checking if we should lock or unlock escape pods accordingly to a newly set security level
 *
 * Arguments:
 * * source The datum source of the signal
 * * new_level The new security level that is in effect
 */
/obj/machinery/computer/shuttle/pod/proc/check_lock(datum/source, new_level)
	SIGNAL_HANDLER

	if(obj_flags & EMAGGED)
		return
	locked = new_level < SEC_LEVEL_RED

/obj/docking_port/stationary/random
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	hidden = TRUE
	var/target_area = /area/lavaland/surface/outdoors
	var/edge_distance = 16
	// Minimal distance from the map edge, setting this too low can result in shuttle landing on the edge and getting "sliced"

/obj/docking_port/stationary/random/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	var/list/turfs = get_area_turfs(target_area)
	var/original_len = turfs.len
	while(turfs.len)
		var/turf/T = pick(turfs)
		if(T.x<edge_distance || T.y<edge_distance || (world.maxx+1-T.x)<edge_distance || (world.maxy+1-T.y)<edge_distance)
			turfs -= T
		else
			forceMove(T)
			return

	// Fallback: couldn't find anything
	WARNING("docking port '[id]' could not be randomly placed in [target_area]: of [original_len] turfs, none were suitable")
	return INITIALIZE_HINT_QDEL

/obj/docking_port/stationary/random/icemoon
	target_area = /area/icemoon/surface/outdoors

//Pod suits/pickaxes


/obj/item/clothing/head/helmet/space/orange
	name = "emergency space helmet"
	icon_state = "syndicate-helm-orange"
	inhand_icon_state = "syndicate-helm-orange"

/obj/item/clothing/suit/space/orange
	name = "emergency space suit"
	icon_state = "syndicate-orange"
	inhand_icon_state = "syndicate-orange"
	slowdown = 3

/obj/item/pickaxe/emergency
	name = "emergency disembarkation tool"
	desc = "For extracting yourself from rough landings."

/obj/item/storage/pod
	name = "emergency space suits"
	desc = "A wall mounted safe containing space suits. Will only open in emergencies."
	anchored = TRUE
	density = FALSE
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	var/unlocked = FALSE

/obj/item/storage/pod/PopulateContents()
	new /obj/item/clothing/head/helmet/space/orange(src)
	new /obj/item/clothing/head/helmet/space/orange(src)
	new /obj/item/clothing/suit/space/orange(src)
	new /obj/item/clothing/suit/space/orange(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/pickaxe/emergency(src)
	new /obj/item/pickaxe/emergency(src)
	new /obj/item/survivalcapsule(src)
	new /obj/item/storage/toolbox/emergency(src)
	new /obj/item/bodybag/environmental(src)
	new /obj/item/bodybag/environmental(src)

/obj/item/storage/pod/attackby(obj/item/W, mob/user, params)
	if (can_interact(user))
		return ..()

/obj/item/storage/pod/attackby_secondary(obj/item/weapon, mob/user, params)
	if (!can_interact(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/storage/pod/attack_hand(mob/user, list/modifiers)
	if (can_interact(user))
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SHOW, user)
	return TRUE

/obj/item/storage/pod/MouseDrop(over_object, src_location, over_location)
	if(can_interact(usr))
		return ..()

/obj/item/storage/pod/attack_hand_secondary(mob/user, list/modifiers)
	if(!can_interact(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/storage/pod/AltClick(mob/user)
	if(!can_interact(user))
		return
	..()

/obj/item/storage/pod/can_interact(mob/user)
	if(!..())
		return FALSE
	if(SSsecurity_level.current_level >= SEC_LEVEL_RED || unlocked)
		return TRUE
	to_chat(user, "The storage unit will only unlock during a Red or Delta security alert.")
	return FALSE

/obj/docking_port/mobile/emergency/backup
	name = "backup shuttle"
	id = "backup"
	dwidth = 2
	width = 8
	height = 8
	dir = EAST

/obj/docking_port/mobile/emergency/backup/Initialize(mapload)
	// We want to be a valid emergency shuttle
	// but not be the main one, keep whatever's set
	// valid.
	// backup shuttle ignores `timid` because THERE SHOULD BE NO TOUCHING IT
	var/current_emergency = SSshuttle.emergency
	. = ..()
	SSshuttle.emergency = current_emergency
	SSshuttle.backup_shuttle = src

/obj/docking_port/mobile/emergency/backup/Destroy(force)
	if(SSshuttle.backup_shuttle == src)
		SSshuttle.backup_shuttle = null
	return ..()

/obj/docking_port/mobile/emergency/shuttle_build/register()
	. = ..()
	initiate_docking(SSshuttle.getDock("emergency_home"))

#undef TIME_LEFT
#undef ENGINES_START_TIME
#undef ENGINES_STARTED
#undef IS_DOCKED
#undef SHUTTLE_CONSOLE_ACTION_DELAY

#undef NOT_BEGUN
#undef STAGE_1
#undef STAGE_2
#undef STAGE_3
#undef STAGE_4
#undef HIJACKED
