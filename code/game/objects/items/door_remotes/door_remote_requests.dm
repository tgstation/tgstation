// for making ID feedback messages less verbose in the code here
#define ID_FEEDBACK(id, message) SSdoor_remote_routing.id_feedback_message(id, message)
// for parity with the above
#define REMOTE_FEEDBACK(message) remote_feedback_message(message)


/obj/item/door_remote/proc/in_our_area(area/station/checked_area) //when you come out your shit is GONE
	// Heads of Staff can swipe to make every door remote all-access
	// Probably almost always not a great idea but emergencies rarely allow only good ideas
	if(SSstation.door_remotes_unrestricted)
		return TRUE
	// Sometimes door accesses don't align exactly with ID acceses even
	// though it's your department...
	for(var/area/station/our_domain in our_departmental_areas)
		if(istype(checked_area, our_domain))
			return TRUE
	return FALSE

// Similar to the message SSdoor_remote_routing generates on IDs, an audible message from the remote
/obj/item/door_remote/proc/remote_feedback_message(message)
	audible_message("[message]", audible_message_flags = EMOTE_MESSAGE)

/obj/item/door_remote/proc/toggle_listen()
	listening = !listening
	if(listening)
		RegisterSignal(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, PROC_REF(receive_access_request))
		RegisterSignal(SSdoor_remote_routing, COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED, PROC_REF(acknowledge_resolution))
		return REMOTE_FEEDBACK("buzzes, \"LISTENING.\"")
	UnregisterSignal(SSdoor_remote_routing, list(COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED, COMSIG_DOOR_REMOTE_ACCESS_REQUEST))
	REMOTE_FEEDBACK("buzzes, \"NOT LISTENING.\"")

/obj/item/door_remote/proc/acknowledge_resolution(datum/source, obj/item/card/id/advanced/ID_resolved, obj/machinery/door/airlock/resolved_door)
	SIGNAL_HANDLER
	if(!recently_resolved_requests[ID_resolved])
		return
	recently_resolved_requests -= ID_resolved
	REMOTE_FEEDBACK("buzzes, \"REQUEST TO [response_name] RESOLVED.\"")


/obj/item/door_remote/proc/clear_requests(mob/user)
	REMOTE_FEEDBACK("buzzes: \"CLEARED REQUESTS.\"")
	if(!length(open_requests))
		return
	open_requests = list()

/obj/item/door_remote/proc/set_auto_response(response_set_to)
	REMOTE_FEEDBACK("buzzes: \"AUTO-RESPONSE SET.\"")
	auto_response = response_set_to

/obj/item/door_remote/proc/receive_access_request(datum/source, obj/item/card/id/advanced/ID_requesting, obj/machinery/door/airlock/requested_door)
	SIGNAL_HANDLER

	if(!check_access(requested_door) && !in_our_area(get_area(requested_door)))
		return NONE

	if(open_requests[ID_requesting])
		ID_FEEDBACK(ID_requesting, "buzzes uncharitably, \"REQUEST TO [response_name] PENDING, ROUTING DENIED\"")
		return COMPONENT_REQUEST_LIMIT_REACHED
	if(recent_denials[ID_requesting])
		ID_FEEDBACK(ID_requesting, "buzzes, \"REQUEST TO [response_name] DENIED, ROUTING DENIED\"")
		return COMPONENT_REQUEST_DENIED
	open_requests[ID_requesting] = requested_door
	addtimer(CALLBACK, PROC_REF(expire_access_request), ID_requesting, 5 MINUTES)
	ID_FEEDBACK(ID_requesting, "intones, \"REQUEST ROUTED TO [response_name]; REQUEST RECEIVED.\"")
	return COMPONENT_REQUEST_RECEIVED

/obj/item/door_remote/proc/expire_access_request(obj/item/card/id/advanced/ID_requesting)
	/// Open request gets removed if the remote holder decides to approve it or EA the door
	/// so check that it's there first
	if(open_requests.Find(ID_requesting))
		if(recently_resolved_requests.Find(ID_requesting))
			recently_resolved_requests -= ID_requesting
			return
		LAZYREMOVE(open_requests, ID_requesting)
		ID_FEEDBACK(ID_requesting, "intones \"_[response_name]_ REQUEST TIMEOUT\"")

/obj/item/door_remote/proc/handle_config(mob/user)
	REMOTE_FEEDBACK("buzzes: CONFIG")
	var/config_choice = tgui_alert(user, "Blocky, flickering text gives you a few options: \n(C)LEAR_REQUESTS\n(A)UTO_RESPONSE\n(T)OGGLE_LISTEN", "%CONFIG:NT_DOOR_WAND%", list("C", "A", "T"))
	var/datum/callback/chosen_callback = setting_callbacks[config_choice]
	if(!config_choice)
		return NONE
	return chosen_callback.Invoke(user)

/obj/item/door_remote/proc/handle_requests(mob/user)
	if(!length(open_requests))
		REMOTE_FEEDBACK("buzzes: NO_REQUESTS")
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
	// In case requests are resolved or expired while we're fiddling with the remote
	var/list/cached_requests = list()
	for(var/obj/item/card/id/advanced/given_id in open_requests)
		cached_requests["[open_requests.Find(given_id)]"] = given_id
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
	var/list/available_actions = resolve_response_radial_options()
	var/action = show_radial_menu(user, user, available_actions, radius = 32)
	if(!action)
		return NONE
	var/list/resolved_selections = list()
	for(var/choice_tuple in choices)
		// Break out of this whole loop if the requests got handled by someone else
		if(!length(open_requests))
			REMOTE_FEEDBACK("buzzes: \"RACE CONDITION, ALTERNATIVE NODE HANDLED REQUESTS\"")
			return NONE
		// The way checkbox inputs work for tgui: index 1 = player text, index 2 = list index
		var/actual_index = choice_tuple[2]
		// check that each request in the cache we chose to handle is still in the same place
		if(cached_requests[actual_index] && (open_requests.Find(cached_requests[actual_index]) == actual_index))
			// resolve the list of IDs we're going to handle requests for so we can remove them from our requests
			// all at once
			resolved_selections += open_requests[actual_index]






#undef ID_FEEDBACK
#undef REMOTE_FEEDBACK
