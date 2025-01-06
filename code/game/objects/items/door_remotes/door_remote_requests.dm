
/obj/item/door_remote/proc/toggle_listen(mob/user, setting_toggle = FALSE)
	if(!setting_toggle)
		if(!listening)
			listening = !listening
			RegisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, PROC_REF(receive_access_request))
			log_admin("[src] has started listening for door access requests due to being picked up.")
			SSdoor_remotes.add_listening_remote(region_access, src)
		else
			listening = !listening
			UnregisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST)
			log_admin("[src] has stopped listening for access requests due to being abandoned.")
			SSdoor_remotes.remove_listening_remote(region_access, src)
			RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	else
		if(!listening)
			RegisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, PROC_REF(receive_access_request))
			listening = !listening
			log_admin("[user] has activated [src] to listen to door access requests.")
			SSdoor_remotes.add_listening_remote(region_access, src)
		else
			UnregisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST)
			log_admin("[user] has deactivated [src] listening to door access requests.")
			listening = !listening
			SSdoor_remotes.remove_listening_remote(region_access, src)

/obj/item/door_remote/proc/clear_requests(mob/user)
	to_chat(user, span_yellowteamradio("The remote buzzes: %CLEARED!%"))

/obj/item/door_remote/proc/set_auto_response()
	return

/obj/item/door_remote/proc/receive_access_request(datum/source, obj/item/card/id/ID_requesting, obj/machinery/door/airlock/requested_door)
	SIGNAL_HANDLER

	if(open_requests[ID_requesting])
		ID_requesting.visible_message(span_notice("Irritably vibrating text rolls across [ID_requesting]: REQUEST PENDING FOR _[response_name]_, PLEASE WAIT."), vision_distance = 1)
		return COMPONENT_REQUEST_LIMIT_REACHED
	//if(recent_rejections[ID_requesting])
	//	ID_requesting.visible_message(span_danger("A grating buzz sounds and [ID_requesting] warns: REQUEST TO _[response_name]_ REFUSED."))
	//	return COMPONENT_NOT_ON_THE_LIST_PAL
	open_requests[ID_requesting] = requested_door
	ID_requesting.visible_message(span_notice("Sedate text pulses slowly on [ID_requesting]: REQUEST RECEIVED BY _[response_name]_, PLEASE WAIT."), vision_distance = 1)
	return COMPONENT_REQUEST_RECEIVED

/obj/item/door_remote/proc/expire_access_request(obj/item/card/id/ID_requesting)
	/// Open request gets removed if the remote holder decides to approve it or EA the door
	/// so check that it's there first
	if(open_requests[ID_requesting])
		open_requests -= ID_requesting
		ID_requesting.visible_message(span_notice("A bland banner blinks on [ID_requesting]: RESPONSE TIMEOUT FOR _[response_name]_."), vision_distance = 1)


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
	for(var/obj/item/card/id/request_item in open_requests)
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
		parsed_requests += "[request_item.registered_name] -> [open_requests[request_item]] ([get_area(requested_door)])[nearest_camera ? "" : "!!NO_CAM!!"]"
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
	var/radius = 32
	if(is_emagged)
		available_actions = SSid_access.remote_request_action_list_nefarious
		radius = 36 // space it out a bit more with the extra option
	else
		available_actions = SSid_access.remote_request_action_list
	var/action = show_radial_menu(user, user, available_actions, radius = 32)
	if(!action)
		return
	for(var/choice in choices)
		// second index of a given choice is its index in open_requests
		// first index was just text for the remote user
		var/open_req_index_from_tgui_selection = choice[2]
		var/given_request = open_requests[open_req_index_from_tgui_selection]
		var/obj/item/card/id/given_id = given_request
		var/obj/machinery/door/airlock/given_door = open_requests[given_request]
		if(!istype(given_id) || !istype(given_door) || !given_door.requiresID() || !given_door.canAIControl())
			to_chat(user, span_yellowteamradio("The remote buzzes:"))
			to_chat(user, span_red("%REQUEST_RESPONSE_FAILURE%[open_requests[given_id]]"))
			LAZYREMOVE(open_requests, given_id)
			continue
		// primary door behavior for response is handled by SSid_access
/*		var/SIDE_EFFECTS = SSid_access.handle_request_response(action, given_door, is_emagged)
		// stagger the sound response randomly because these remotes are janky tchotchkes given
		// to heads instead of raises but we want to give the player some audio feedback
		var/sound_delay = (rand(4,20) DECISECONDS * open_requests.Find(given_id))
		var/datum/callback/side_effect_callback = CALLBACK(src, SIDE_EFFECTS)
		side_effect_callback.Invoke(user, given_id, given_door, is_emagged)
		addtimer(CALLBACK(src, PROC_REF(do_handled_request_noise), action), sound_delay)
		LAZYREMOVE(open_requests, given_id)

/obj/item/door_remote/proc/do_handled_request_noise(action)
*/
/*
*	Side effects for door remote actions
*	Except for shock, these only occur when performing remote request handling
*	For some of them, it's as simple as playing a sound
*/
/*
/obj/item/door_remote/proc/block_side_effects(mob/user, obj/item/card/id/given_id, obj/machinery/door/airlock/given_door, sound_delay)

/obj/item/door_remote/proc/deny_side_effects(mob/user, obj/item/card/id/given_id, obj/machinery/door/airlock/given_door, sound_delay)

/obj/item/door_remote/proc/bolt_side_effects(mob/user, obj/item/card/id/given_id, obj/machinery/door/airlock/given_door, sound_delay)

/obj/item/door_remote/proc/shock_side_effects(mob/user, obj/item/card/id/given_id, obj/machinery/door/airlock/given_door, sound_delay)

/obj/item/door_remote/proc/escalate_side_effects(mob/user, obj/item/card/id/given_id, obj/machinery/door/airlock/given_door, sound_delay)
*/
