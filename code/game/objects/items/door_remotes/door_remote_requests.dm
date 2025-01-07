// for making ID feedback messages less verbose in the code here
#define ID_FEEDBACK(message) SSdoor_remote_routing.id_feedback_message(message)
// for parity with the above
#define REMOTE_FEEDBACK(message) remote_feedback_message(message)

// Similar to the message SSdoor_remote_routing generates on IDs, an audible message from the remote
/obj/item/door_remote/proc/remote_feedback_message(message)
	audible_message("[message]", audible_message_flags = EMOTE_MESSAGE)

/obj/item/door_remote/proc/toggle_listen(mob/user, setting_toggle = FALSE)
	if(!setting_toggle)
		if(!listening)
			listening = !listening
			RegisterSignal(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, PROC_REF(receive_access_request))
			log_admin("[src] has started listening for door access requests due to being picked up.")
			SSdoor_remote_routing.add_listening_remote(region_access, src)
		else
			listening = !listening
			UnregisterSignal(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST)
			log_admin("[src] has stopped listening for access requests due to being abandoned.")
			SSdoor_remote_routing.remove_listening_remote(region_access, src)
			auto_response = null
			RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	else
		if(!listening)
			RegisterSignal(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, PROC_REF(receive_access_request))
			listening = !listening
			log_admin("[user] has activated [src] to listen to door access requests.")
			SSdoor_remote_routing.add_listening_remote(region_access, src)
		else
			UnregisterSignal(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST)
			log_admin("[user] has deactivated [src] listening to door access requests.")
			listening = !listening
			auto_response = null
			SSdoor_remote_routing.remove_listening_remote(region_access, src)

/obj/item/door_remote/proc/clear_requests(mob/user)
	REMOTE_FEEDBACK("buzzes: \"CLEARED REQUESTS.\"")

/obj/item/door_remote/proc/set_auto_response()
	return

/obj/item/door_remote/proc/receive_access_request(datum/source, obj/item/card/id/advanced/ID_requesting, obj/machinery/door/airlock/requested_door)
	SIGNAL_HANDLER

	if(open_requests[ID_requesting])
		ID_FEEDBACK("buzzes uncharitably, \"REQUEST TO [response_name] PENDING, ROUTING DENIED\"")
		return COMPONENT_REQUEST_LIMIT_REACHED
	if(recent_denials[ID_requesting])
		ID_FEEDBACK("buzzes, \"REQUEST TO [response_name] DENIED, ROUTING DENIED\"")
		return COMPONENT_REQUEST_DENIED
	open_requests[ID_requesting] = requested_door
	ID_FEEDBACK("intones, \"REQUEST ROUTED TO [response_name]; REQUEST RECEIVED.\"")
	return COMPONENT_REQUEST_RECEIVED

/obj/item/door_remote/proc/expire_access_request(obj/item/card/id/advanced/ID_requesting)
	/// Open request gets removed if the remote holder decides to approve it or EA the door
	/// so check that it's there first
	if(open_requests[ID_requesting])
		LAZYREMOVE(open_requests, ID_requesting)
		ID_FEEDBACK("intones \"_[response_name]_ REQUEST TIMEOUT\"")

/obj/item/door_remote/proc/handle_config(mob/user)
	to_chat(user, span_yellowteamradio("The remote buzzes: %CONFIG%"))												// :3 *meow
	var/config_choice = tgui_alert(user, "Blocky, flickering text gives you a few options: \n(C)LEAR_REQUESTS\n(A)UTO_RESPONSE\n(T)OGGLE_LISTEN", "%CONFIG:NT_DOOR_WAND%", list("C", "A", "T"))
	var/datum/callback/chosen_callback = setting_callbacks[config_choice]
	if(config_choice == "T")
		return chosen_callback.Invoke(user, /*setting_toggle = */TRUE)
	else
		return chosen_callback.Invoke(user)

/obj/item/door_remote/proc/handle_requests(mob/user)
	var/is_emagged = obj_flags & EMAGGED
	if(!length(open_requests))
		to_chat(user, span_yellowteamradio("The remote buzzes: %NO_REQUESTS%"))
		return
	// Javascript doesn't like when you feed associative arrays from BYOND into its functions that want
	// primitives so we have to do some value conversion here
	// open_requests is an asslist ( id : door ) of which ID is requesting which door
	var/list/parsed_requests = list()
	for(var/obj/item/card/id/advanced/request_item in open_requests)
		var/obj/machinery/camera/nearest_camera = null
		// checkboxes further down returns a list of lists
		// (text, index_value) with the text being some useless cruff from the tgui input // (javascript doesn't support BYOND friendly asslists)
		// but the index_value is the index of the request in the open_requests list
		// that we can use to get the actual request and door to operate on
		var/obj/machinery/door/airlock/requested_door = open_requests[request_item]
		// cards and airlocks are not indestructible so we wanna make sure they're still a type
		if(!istype(request_item, /obj/item/card/id) || !istype(requested_door, /obj/machinery/door/airlock))
			request_item = "ERR! Request signal lost! Contact the engineering department."
			parsed_requests += request_item
			continue
		for(var/obj/machinery/camera/smile_youre_on_camera in view(7, requested_door))
			if(smile_youre_on_camera.is_operational && (get_dist(smile_youre_on_camera, requested_door) <= smile_youre_on_camera.view_range))
				nearest_camera = smile_youre_on_camera
				break
		parsed_requests += "[request_item.registered_name] -> [open_requests[request_item]] [nearest_camera ? "On-camera" : "OFF-CAMERA!"]"
	var/list/choices = list()
	choices = tgui_input_checkboxes(
		user = user,
		message = "A scrollable list sluggishly populates on the screen, helpfully labeled: %LIST%",
		title = "%ACCESS_REQUESTS%",
		items = parsed_requests
	)
	if(!length(choices))
		to_chat(user, span_yellowteamradio("The remote buzzes: %NO_SELECTION%"))
		return
	balloon_alert(user, "choose batch action")
	var/list/available_actions // PSEUDO_M use resolve radials here
	var/action = show_radial_menu(user, user, available_actions, radius = 32)
	if(!action)
		return
	for(var/choice in choices)
		// second index of a given choice is its index in open_requests
		// first index was just text for the remote user
		var/open_req_index_from_tgui_selection = choice[2]
		var/given_request = open_requests[open_req_index_from_tgui_selection]
		var/obj/item/card/id/advanced/given_id = given_request
		var/obj/machinery/door/airlock/given_door = open_requests[given_request]
		if(!istype(given_id) || !istype(given_door) || !given_door.requiresID() || !given_door.canAIControl())
			to_chat(user, span_yellowteamradio("The remote buzzes:"))
			to_chat(user, span_red("%REQUEST_RESPONSE_FAILURE%[open_requests[given_id]]"))
			LAZYREMOVE(open_requests, given_id)
			continue
		LAZYREMOVE(open_requests, given_id)

/obj/item/door_remote/proc/do_handled_request_noise(action)


/obj/item/door_remote/proc/block_side_effects(mob/user, obj/item/card/id/advanced/given_id, obj/machinery/door/airlock/given_door, sound_delay)

/obj/item/door_remote/proc/deny_side_effects(mob/user, obj/item/card/id/advanced/given_id, obj/machinery/door/airlock/given_door, sound_delay)

/obj/item/door_remote/proc/bolt_side_effects(mob/user, obj/item/card/id/advanced/given_id, obj/machinery/door/airlock/given_door, sound_delay)

/obj/item/door_remote/proc/shock_side_effects(mob/user, obj/item/card/id/advanced/given_id, obj/machinery/door/airlock/given_door, sound_delay)

/obj/item/door_remote/proc/escalate_side_effects(mob/user, obj/item/card/id/advanced/given_id, obj/machinery/door/airlock/given_door, sound_delay)

#undef ID_FEEDBACK
#undef REMOTE_FEEDBACK
