SUBSYSTEM_DEF(door_remote_routing)
	name = "Door Remote Routing"
	init_order = INIT_ORDER_DOOR_REMOTES
	flags = SS_NO_FIRE
	// For tracking what a given remote user has done, as well
	// as who they've blocked/denied, for admins and perhaps
	// for players to audit, eventually
	var/list/obj/item/door_remote/door_remote_records = list()
	// An associative list of IDs that have made requests, to a list containing
	// the door the ID in question, the door requested, and the timer ID for the request
	var/list/open_requests = list()
	var/door_remotes_unrestricted = FALSE
	var/list/request_handling_options
	var/static/list/record_actions = list(
		REMOTE_RESPONSE_APPROVE = "approve",
		REMOTE_RESPONSE_DENY = "deny",
		REMOTE_RESPONSE_BOLT = "bolt+block",
		REMOTE_RESPONSE_BLOCK = "block",
		REMOTE_RESPONSE_EA = "emrgncy",
		REMOTE_RESPONSE_SHOCK = "shocked",
		)
	var/list/standard_modes = list(
		WAND_OPEN,
		WAND_BOLT,
		WAND_EMERGENCY,
		WAND_HANDLE_REQUESTS,
		WAND_HANDLE_CONFIG,
		)
	var/list/standard_responses = list(
		REMOTE_RESPONSE_APPROVE,
		REMOTE_RESPONSE_DENY,
		REMOTE_RESPONSE_BOLT,
		REMOTE_RESPONSE_BLOCK,
		REMOTE_RESPONSE_EA,
		)
	var/list/possible_resolutions = list(
		REMOTE_RESPONSE_APPROVE,
		REMOTE_RESPONSE_DENY,
		REMOTE_RESPONSE_BOLT,
		REMOTE_RESPONSE_BLOCK,
		REMOTE_RESPONSE_EA,
		REMOTE_RESPONSE_SHOCK,
		EXPIRED_REQUEST,
		)
	var/emag_mode = WAND_SHOCK
	var/emag_response = REMOTE_RESPONSE_SHOCK


/datum/controller/subsystem/door_remote_routing/Initialize()
	setup_door_remote_radials()
	request_handling_options = GLOB.door_remote_radial_images[REQUEST_RESPONSES]
	RegisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED, PROC_REF(handle_resolution))
	return SS_INIT_SUCCESS

// If (when?) we make this info player-available, shocks won't be visible because we'll create a dummy
// record when the remote is emagged, which will display the records at the moment it was emagged
/datum/controller/subsystem/door_remote_routing/proc/begin_tracking(obj/item/door_remote/now_tracked)
	door_remote_records[now_tracked] = list(
		// list of lists, of the form [ID, door, action, time]
		"ACTIONS" = list(),
		// simple list of ID cards; a timer will remove them after a certain amount of time
		"DENIED" = list(),
		// simple list of ID cards; only a remote holder can remove them from this
		"BLOCKED" = list()
		)
	RegisterSignal(now_tracked, COMSIG_QDELETING, PROC_REF(stop_tracking))

/datum/controller/subsystem/door_remote_routing/proc/stop_tracking(obj/item/door_remote/now_untracked)
	var/list/record_copy
	var/list/record = door_remote_records[now_untracked]
	record_copy = deep_copy_list_alt(record)
	door_remote_records -= now_untracked
	door_remote_records[now_untracked.name] = record_copy

/datum/controller/subsystem/door_remote_routing/proc/check_possible_restrictions(
	datum/weakref/ID_ref,/*THE ID!*/
	obj/item/door_remote/remote,/*The remote that is checking the ID*/
	restriction_type) /*BLOCKED or DENIED*/

	var/list/record_lists = door_remote_records[remote]
	var/list/restriction_list = record_lists[restriction_type]
	if(restriction_list.Find(ID_ref))
		return TRUE
	return FALSE

/* When someone bops a door with the alternate action of their ID, they will request the door be opened by the door remote.
 * First, we deduce the appropriate region(s) for the access request.
 * If we find an appropriate region, then we add it to the list of regions we're gonna send a signal for.
 *
 * * ID_requesting - The ID card that is requesting the door be opened.
 * * door_requested - The door that the ID card is requesting be opened.
 */
/datum/controller/subsystem/door_remote_routing/proc/route_request_to_door_remote(obj/item/card/id/ID_requesting, obj/machinery/door/airlock/door_requested)
	var/timer_id = addtimer(CALLBACK(src, PROC_REF(expire_access_request), ID_requesting, door_requested), 10 SECONDS, TIMER_STOPPABLE)
	#warn "fix this timer"
	open_requests[ID_requesting] = list(ID_requesting, door_requested, timer_id)
	var/received = SEND_SIGNAL(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, ID_requesting, door_requested)
	if(!(received & COMPONENT_REQUEST_RECEIVED))
		id_feedback_message(ID_requesting, "buzzes: \"ROUTING REQUEST FAILED, NO REMOTES LISTENING\"")
		deltimer(timer_id)
		open_requests -= ID_requesting
		return NONE
	id_feedback_message(ID_requesting, "buzzes: \"REQUEST ROUTED AND RECEIVED SUCCESSFULLY.\"")

/*Does a bunch of a hullabaloo to set up a door remote's radial menu images
 * Done this way so we can just have a set of images hanging around on GLOB
 * Instead of regenerating the images every time the menu gets opened
*/
/datum/controller/subsystem/door_remote_routing/proc/setup_door_remote_radials()
	for(var/region_name in GLOB.door_remote_radial_images)
		var/image_set = GLOB.door_remote_radial_images[region_name]
		if(!islist(image_set)) // then it's our odd-one-out image for handling requests
			if(!isimage(image_set)) // then we have a problem
				CRASH("Wrong type when trying to configure door remote radials! [image_set] is not a list or image.")
			for(var/added_to in GLOB.door_remote_radial_images) // this will only run once
				var/list/list_to_append = GLOB.door_remote_radial_images[added_to]
				if(islist(list_to_append))
					list_to_append[WAND_HANDLE_REQUESTS] = GLOB.door_remote_radial_images[WAND_HANDLE_REQUESTS]
					list_to_append[WAND_HANDLE_CONFIG] = GLOB.door_remote_radial_images[WAND_HANDLE_CONFIG]
			continue // we do it like this to minimize the creation of GLOB variables for holding our radial images
		var/image/bolt_radial = image_set[WAND_BOLT]
		var/image/EA_radial = image_set[WAND_EMERGENCY]
		var/image/shock_radial = image_set[WAND_SHOCK]
		bolt_radial.add_overlay(image(icon = 'icons/obj/doors/airlocks/station/overlays.dmi', icon_state = "lights_bolts"))
		EA_radial.add_overlay(image(icon = 'icons/obj/doors/airlocks/station/overlays.dmi', icon_state = "lights_emergency"))
		shock_radial.add_overlay(image(icon = 'icons/mob/huds/hud.dmi', icon_state = "electrified"))
	// and a cherry on top
	GLOB.door_remote_radial_images[REQUEST_RESPONSES] = REMOTE_RESPONSE_RADIALS

/datum/controller/subsystem/door_remote_routing/proc/expire_access_request(obj/item/card/id/advanced/ID_requesting, obj/machinery/door/airlock/requested_door)
	SEND_SIGNAL(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED, ID_requesting, requested_door, EXPIRED_REQUEST)

/datum/controller/subsystem/door_remote_routing/proc/lift_lockout(
	obj/item/door_remote/denying_remote,
	datum/weakref/ID_reference,
	record_type)
	if(!istype(denying_remote, /obj/item/door_remote))
		CRASH("lift_denial_lockout called with non-remote item.")
	var/list/remote_records = door_remote_records[denying_remote]
	var/list/record = remote_records[record_type]

	if(record.Find(ID_reference))
		record -= ID_reference
		var/obj/item/card/id/advanced/ID_denied = ID_reference.resolve()
		if(!istype(ID_denied, /obj/item/card/id/advanced))
			return
		id_feedback_message(ID_denied, "buzzes: \"[record_type == "DENIED" ? "DENIAL LOCKOUT DELAY" : "BLOCK"] FROM [denying_remote.response_name] LIFTED.\"")


// A proc to give feedback to the holder of an ID making a request, as well as any nosey busybodies nearby
/datum/controller/subsystem/door_remote_routing/proc/id_feedback_message(obj/item/card/id/advanced/ID_requesting, message)
	if(!istype(ID_requesting, /obj/item/card/id/advanced))
		CRASH("generate_ID_response called with non-ID card. How did we get here?")
	ID_requesting.audible_message(message, audible_message_flags = EMOTE_MESSAGE)

// Handles the resolution of a request made by an ID card, either
// by it simply expiring, or by a remote holder with access to that door
// approving or denying it. Request resolution are first-come, first-served
// so the Captain (if they have their remote listening) can handle a request
// if they see fit before a given department head would.
/datum/controller/subsystem/door_remote_routing/proc/handle_resolution(
	datum/source,
	obj/item/card/id/advanced/ID_resolved,
	obj/machinery/door/airlock/resolved_door,
	action,
	obj/item/door_remote/handler,
	handling_flags = NONE)
	SIGNAL_HANDLER

	. = NONE
	if(!possible_resolutions.Find(action))
		CRASH("handle_resolution called with invalid action.")
	// Handled this way so remotes hear it to clear the expired request
	if(action == EXPIRED_REQUEST)
		id_feedback_message(ID_resolved, "buzzes: \"REQUEST TIMEOUT\"")
		open_requests -= ID_resolved
		return NONE
	if(!open_requests.Find(ID_resolved))
		return NONE
	var/powered_and_controllable = (resolved_door.hasPower() && resolved_door.canAIControl())
	if(!powered_and_controllable)
		id_feedback_message(ID_resolved, "buzzes \"SIGNAL TO AIRLOCK LOST\".")
		return NONE
	if(handling_flags & COMPONENT_REQUEST_AUTO_HANDLED)
		. |= COMPONENT_REQUEST_AUTO_HANDLED
	var/request_info = open_requests[ID_resolved]
	var/timer_id = request_info[3]
	if(!deltimer(timer_id))
		debug_admins("Timer deletion failed for [timer_id] on [src].")
	open_requests -= ID_resolved
	var/handling_head = handler.response_name
	switch(action)
		if(REMOTE_RESPONSE_APPROVE)
			if(resolved_door.locked)
				resolved_door.unlock()
			INVOKE_ASYNC(resolved_door, TYPE_PROC_REF(/obj/machinery/door/airlock, open))
			id_feedback_message(ID_resolved, "buzzes \"APPROVED BY [handling_head]\".")
			. |= COMPONENT_REQUEST_HANDLED
		if(REMOTE_RESPONSE_DENY)
			id_feedback_message(ID_resolved, "buzzes \"DENIED BY [handling_head]\".")
			. |= COMPONENT_REQUEST_HANDLED | COMPONENT_REQUEST_DENIED
		if(REMOTE_RESPONSE_BOLT)
			id_feedback_message(ID_resolved, "buzzes \"DENIED BY [handling_head]. FURTHER REQUESTS TO [handling_head] BLOCKED. AIRLOCK SECURED.\"")
			INVOKE_ASYNC(resolved_door, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_close))
			. |= COMPONENT_REQUEST_HANDLED | COMPONENT_REQUEST_DENIED | COMPONENT_REQUEST_BLOCKED
		if(REMOTE_RESPONSE_BLOCK)
			id_feedback_message(ID_resolved, "buzzes \"DENIED BY [handling_head]. FURTHER REQUESTS TO [handling_head] BLOCKED.\"")
			. |= COMPONENT_REQUEST_HANDLED | COMPONENT_REQUEST_DENIED | COMPONENT_REQUEST_BLOCKED
		if(REMOTE_RESPONSE_EA)
			id_feedback_message(ID_resolved, "buzzes \"EMERGENCY ACCESS GRANTED BY [handling_head].\"")
			if(resolved_door.locked)
				resolved_door.unlock()
			resolved_door.emergency = TRUE
			resolved_door.update_appearance(UPDATE_ICON)
			. |= COMPONENT_REQUEST_HANDLED
		if(REMOTE_RESPONSE_SHOCK)
			//relevantly, we don't return the name of the handler here
			//as a subtle tell
			id_feedback_message(ID_resolved, "buzzes \"EMERGENCY ACCESS GRANTED.\"")
			if(resolved_door.locked)
				resolved_door.unlock()
			resolved_door.emergency = TRUE
			resolved_door.update_appearance(UPDATE_ICON)
			//the remote (as in not local, but also door remote) response for electrifying is temporary; doing it in LOS is the permanent one
			resolved_door.set_electrified(MACHINE_DEFAULT_ELECTRIFY_TIME, handler.auto_response ? handler.auto_response[2] : get(handler.loc, /mob/living))
			. |= COMPONENT_REQUEST_HANDLED
	if(. & COMPONENT_REQUEST_DENIED)
		if(. & COMPONENT_REQUEST_BLOCKED)
			door_remote_records[handler]["BLOCKED"][WEAKREF(ID_resolved)] = "[ID_resolved]"
		else
			door_remote_records[handler]["DENIED"][WEAKREF(ID_resolved)] = "[ID_resolved]"
			addtimer(CALLBACK(src, PROC_REF(lift_lockout), handler, WEAKREF(ID_resolved), "DENIED"), 10 SECONDS)
	#warn "fix this timer"
	log_action(ID_resolved, resolved_door, handler, action)

/datum/controller/subsystem/door_remote_routing/proc/log_action(
	obj/item/card/id/advanced/ID_resolved,
	obj/machinery/door/airlock/resolved_door,
	obj/item/door_remote/handler,
	action)
	var/list/record_lists = door_remote_records[handler]
	var/list/action_record = record_lists["ACTIONS"]
	var/name_and_assignment = "[ID_resolved]\[[ID_resolved.assignment]\]"
	var/doordinates/*door coordinates*/ = "X\[[resolved_door.x]\]Y\[[resolved_door.y]\]"
	var/action_statement = " [record_actions[action]]"
	var/log_time = "[gameTimestamp()]"
	// in-character log time
	var/IC_log_time = "[gameTimestamp(format = "MMM DD [CURRENT_STATION_YEAR] HH:MM:SS")]"
	var/log_text = uppertext("[name_and_assignment] [doordinates] [action_statement]")
	var/list/log_list = list(log_text, log_time, IC_log_time)
	action_record["[action_record.len + 1]"] = log_list
