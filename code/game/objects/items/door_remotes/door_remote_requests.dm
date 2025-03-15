// for making ID feedback messages less verbose in the code here
#define ID_FEEDBACK(id, message) SSdoor_remote_routing.id_feedback_message(id, message)
// for parity with the above
#define REMOTE_FEEDBACK(message) remote_feedback_message(message)
#define IS_BLOCKED(id) (SSdoor_remote_routing.check_possible_restrictions(id, src, "BLOCKED"))
#define WAS_DENIED(id) (SSdoor_remote_routing.check_possible_restrictions(id, src, "DENIED"))
#define OPEN_REQUESTS (SSdoor_remote_routing.open_requests)

/obj/item/door_remote/proc/in_our_area(area/station/checked_area) //when you come out your shit is GONE
	// Heads of Staff can swipe to make every door remote all-access
	// Probably almost always not a great idea but emergencies rarely allow only good ideas
	if(SSdoor_remote_routing.door_remotes_unrestricted)
		return TRUE
	// Sometimes door accesses don't align exactly with ID acceses even
	// though it's your department...
	for(var/area/station/our_domain in our_departmental_areas)
		if(istype(checked_area, our_domain))
			return TRUE
	return FALSE

// Similar to the message SSdoor_remote_routing generates on IDs, an audible message from the remote
/obj/item/door_remote/proc/remote_feedback_message(message)
	if(silenced)
		return NONE
	audible_message("[message]", audible_message_flags = EMOTE_MESSAGE)

// Heads of staff can lock down a door remote, assuming that they have access that would match or override
// that remote's access
/obj/item/door_remote/proc/lockdown(list/access_list_used)
	if(!check_access_list(access_list_used))
		return FALSE
	locked_down = !locked_down
	silenced = FALSE
	if(!locked_down)
		REMOTE_FEEDBACK("buzzes: \"LOCKDOWN LIFTED.\"")
		req_access = accesses
		return TRUE
	if(listening == TRUE)
		UnregisterSignal(SSdoor_remote_routing, list(COMSIG_DOOR_REMOTE_ACCESS_REQUEST, COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED))
		listening = FALSE
	auto_response = null
	req_access = access_list_used
	notify_lockdown()

/obj/item/door_remote/proc/notify_lockdown()
	playsound(source = src, soundin = 'sound/machines/scanner/scanbuzz.ogg', vol = 30, vary = FALSE)
	REMOTE_FEEDBACK("buzzes: \"LOCKDOWN ENGAGED.\"")
	var/mob/living/my_holder = get(loc, /mob/living)
	if(obj_flags & EMAGGED && my_holder)
		my_holder.electrocute_act(5, src, 10)

/obj/item/door_remote/proc/toggle_listen()
	if(locked_down)
		notify_lockdown()
		return NONE
	listening = !listening
	if(listening)
		RegisterSignal(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, PROC_REF(receive_access_request))
		RegisterSignal(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED, PROC_REF(acknowledge_resolution))
		return REMOTE_FEEDBACK("buzzes, \"LISTENING.\"")
	UnregisterSignal(SSdoor_remote_routing, list(COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED, COMSIG_DOOR_REMOTE_ACCESS_REQUEST))
	REMOTE_FEEDBACK("buzzes, \"NOT LISTENING.\"")

/obj/item/door_remote/proc/acknowledge_resolution(
	datum/source,
	obj/item/card/id/advanced/ID_resolved,
	obj/machinery/door/airlock/resolved_door = null,
	action,
	obj/item/door_remote/handler,
	handling_flags = null
	)
	SIGNAL_HANDLER

	var/area/given_area = get_area(resolved_door)
	if(!(resolved_door.check_access_list(accesses) || in_our_area(given_area)))
		return
	var/ID_name = "\[[uppertext(ID_resolved.registered_name)]\]"
	var/airlock_name = "\[[uppertext(resolved_door.name)]\]"
	var/area_name = "\[[uppertext(given_area.name)]\]"
	if(action == EXPIRED_REQUEST)
		REMOTE_FEEDBACK("buzzes: [ID_name] REQUEST FOR [airlock_name] IN [area_name] EXPIRED.")
		return
	if(handler == src)
		return
	var/conspicuous = FALSE
	if(handling_flags & COMPONENT_REQUEST_AUTO_HANDLED)
		//if someone does something like steal a remote, emag it, and set it to auto-shock requested doors
		//that's a big enough ruckus that it should be obvious something is up
		conspicuous = TRUE
	var/action_message = "buzzes: \"[ID_name] REQUEST FOR [airlock_name] IN [area_name] "
	switch(action)
		if(REMOTE_RESPONSE_APPROVE)
			action_message += "APPROVED BY "
		if(REMOTE_RESPONSE_DENY,REMOTE_RESPONSE_BLOCK)
			action_message += "DENIED BY "
		if(REMOTE_RESPONSE_BOLT)
			action_message += "AIRLOCK SECURED BY "
		if(REMOTE_RESPONSE_EA)
			action_message += "EMERGENCY ACCESS SET BY "
		if(REMOTE_RESPONSE_SHOCK)
			if(conspicuous)
				action_message += "##ERROR## SERVICE REM##ERROR##"
			else
				action_message += "APPROVED BY "
	action_message += "\[[handler.response_name]\]"
	if(conspicuous)
		action_message += "\[--AUTOMATIC RESPONSE--\].\""
	REMOTE_FEEDBACK(action_message)

/obj/item/door_remote/proc/set_auto_response(mob/living/user)
	if(auto_response)
		auto_response = null
		REMOTE_FEEDBACK("buzzes: \"AUTO-RESPONSE CLEARED.\"")
		return
	var/auto_response_option = show_radial_menu(user, user, resolve_radial_options("responses"), radius = 40)
	user.balloon_alert("set auto-response")
	if(!auto_response_option)
		return
	REMOTE_FEEDBACK("buzzes: \"AUTO-RESPONSE SET.\"")
	auto_response = auto_response_option

/obj/item/door_remote/proc/receive_access_request(datum/source, obj/item/card/id/advanced/ID_requesting, obj/machinery/door/airlock/requested_door)
	SIGNAL_HANDLER
	if(!requested_door.check_access_list(accesses) && !in_our_area(get_area(requested_door)))
		return NONE
	if(WAS_DENIED(WEAKREF(ID_requesting)))
		ID_FEEDBACK(ID_requesting, "buzzes, \"REQUEST NOT ROUTED TO [response_name]: RECENT DENIAL NOTICE.\"")
		return COMPONENT_REQUEST_DENIED | COMPONENT_REQUEST_BLOCKED
	if(IS_BLOCKED(WEAKREF(ID_requesting)))
		ID_FEEDBACK(ID_requesting, "buzzes, \"REQUEST NOT ROUTED TO [response_name]: BLOCKED ID NOTICE.\"")
		return COMPONENT_REQUEST_DENIED | COMPONENT_REQUEST_BLOCKED
	. = COMPONENT_REQUEST_RECEIVED
	var/ID_name = "\[[uppertext(ID_requesting.registered_name)]\]"
	var/airlock_name = "\[[uppertext(requested_door.name)]\]"
	var/area_name
	var/area/given_area = get_area(requested_door)
	area_name = "\[[uppertext(given_area.name)]\]"
	var/to_buzz = "buzzes: \"[ID_name] REQUESTS ACCESS TO [airlock_name] IN [area_name]"
	if(auto_response)
		var/auto_handling = SEND_SIGNAL(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED, ID_requesting, requested_door, auto_response, src, COMPONENT_REQUEST_AUTO_HANDLED)
		if(auto_handling & COMPONENT_REQUEST_HANDLED)
			. |= COMPONENT_REQUEST_AUTO_HANDLED
			to_buzz += ". HANDLED WITH AUTO-RESPONSE. HAVE A SECURE DAY.\""
		else
			to_buzz += ". AUTO-RESPONSE FAILED. PLEASE REVIEW.\""
	else
		to_buzz += ".\""
	REMOTE_FEEDBACK(to_buzz)
	return .

/obj/item/door_remote/proc/handle_config(mob/user)
	if(locked_down)
		notify_lockdown()
		return NONE
	REMOTE_FEEDBACK("buzzes: \"CONFIG\"")
	var/list/available_configs = list()
	available_configs = list(
		"\[B\]LOCKED REQUESTS MANAGEMENT.",
		"\[C\]HECK LOGS: ACTIONS | DENIALS | BLOCKED",
		"\[A\]UTO-RESPONSE TOGGLE. CURRENT: [auto_response ? "ON" : "OFF"]",
		"\[T\]OGGLE LISTENING. CURRENT: [listening ? "ON" : "OFF"]",
		"\[S\]ILENCE FEEDBACK. CURRENT: [silenced ? "ON" : "OFF"]",
	)
	var/config_choice = tgui_input_list(user,
	"Blocky, flickering text presents your options:",
	"%CONFIG:NT_DOOR_WAND%",
	available_configs
	)
	if(!config_choice)
		return NONE
	var/config_index = available_configs.Find(config_choice)
	switch(config_index)
		if(1)
			manage_blocked(user)
		if(2)
			check_logs(user)
		if(3)
			set_auto_response(user)
		if(4)
			toggle_listen()
		if(5)
			toggle_audible_feedback(user)

/obj/item/door_remote/proc/toggle_audible_feedback(mob/user)
	silenced = !silenced
	if(silenced)
		to_chat(user, "[src] conspicuously does not buzz.")
	else
		REMOTE_FEEDBACK("buzzes: \"UNMUTED.\"")

/obj/item/door_remote/proc/manage_blocked(mob/user)
	#warn "implement this"

// See the door_remote_routing controller for the format of open requests
/obj/item/door_remote/proc/handle_requests(mob/user)
	if(locked_down)
		notify_lockdown()
		return NONE
	if(!listening)
		REMOTE_FEEDBACK("buzzes: \"NOT LISTENING FOR ACCESS REQUESTS. PLEASE ENABLE LISTENING FOR ACCESS REQUESTS.\"")
		return
	var/list/qualified_requests = list()
	for(var/obj/item/card/id/advanced/request_item as anything in OPEN_REQUESTS)
		var/obj/machinery/door/airlock/requested_door = OPEN_REQUESTS[request_item][2]
		if(requested_door.check_access_list(src) || in_our_area(get_area(requested_door)))
			// Make sure we just take the list itself rather than worrying about making our own
			qualified_requests[request_item] = OPEN_REQUESTS[request_item]
	if(!length(qualified_requests))
		REMOTE_FEEDBACK("buzzes: \"NO REQUESTS.\"")
		return
	// Javascript doesn't like when you feed associative arrays from BYOND into its functions that want
	// primitives so we have to do some value conversion here
	var/list/parsed_requests = list()
	for(var/obj/item/card/id/advanced/request_item in qualified_requests)

		var/obj/machinery/camera/nearest_camera = null
		var/obj/machinery/door/airlock/requested_door = qualified_requests[request_item][2]
		// cards and airlocks are not indestructible so we wanna make sure they're still a type
		if(!istype(request_item, /obj/item/card/id) || !isairlock(requested_door))
			request_item = "ERR! Request [qualified_requests.Find(request_item)] signal lost!"
			parsed_requests += request_item
			continue
		// If there's a nearby camera, notify the remote holder
		// for cases of department heads who are ACTUALLY in their office(?!) or of a mind
		// to have the AI double-check the requestor is the actual ID owner
		for(var/obj/machinery/camera/smile_youre_on_camera in viewers(7, requested_door))
			if(smile_youre_on_camera.is_operational)
				nearest_camera = smile_youre_on_camera
				break
		// only provide the name so that negligent heads of staff might end up letting someone in
		// who isn't even on the manifest
		parsed_requests += "[request_item.registered_name] -> [requested_door] [nearest_camera ? "On-camera" : "OFF-CAMERA!"]"
	var/list/choices = list()
	choices = tgui_input_checkboxes(
		user = user,
		message = "A scrollable list sluggishly populates on the screen, helpfully labeled: %LIST%",
		title = "%ACCESS_REQUESTS%",
		items = parsed_requests
	)
	if(!length(choices))
		REMOTE_FEEDBACK("buzzes: \"NO SELECTION\"")
		return
	balloon_alert(user, "choose batch action")
	var/list/available_actions = resolve_radial_options("responses")
	var/action = show_radial_menu(user, user, available_actions, radius = 32)
	if(!action)
		return NONE
	// check that the requests we chose are still valid to handle
	// handled in this way so we retain our place in the index
	for(var/obj/item/card/id/advanced/valid_request in qualified_requests)
		// if the request is not there at all
		if(!(OPEN_REQUESTS).Find(valid_request))
			qualified_requests[valid_request] = "INVALID!"
		// or if the request was handled/expired and they made a new request in the meantime
		else if (OPEN_REQUESTS[valid_request] != qualified_requests[valid_request])
			qualified_requests[valid_request] = "INVALID!"
			continue
	var/list/resolved_requests_to_handle = list()
	for(var/choice_tuple in choices)
		// The way checkbox inputs work for tgui: index 1 = player text, index 2 = list index
		var/actual_index = choice_tuple[2]
		if(qualified_requests[actual_index] == "INVALID!")
			continue
		var/list/resolved_request_information = qualified_requests[qualified_requests[actual_index]]
		resolved_requests_to_handle[resolved_request_information[1]] = resolved_request_information
	for(var/request_being_handled in resolved_requests_to_handle)
		var/requested_door = resolved_requests_to_handle[request_being_handled][2]
		SEND_SIGNAL(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED, request_being_handled, requested_door, action, src)

#undef ID_FEEDBACK
#undef REMOTE_FEEDBACK
#undef IS_BLOCKED
#undef WAS_DENIED
#undef OPEN_REQUESTS
