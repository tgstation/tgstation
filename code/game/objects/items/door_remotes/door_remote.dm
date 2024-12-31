#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"
#define WAND_HANDLE_REQUESTS "requests"
#define WAND_SHOCK "shock"

/obj/item/door_remote
	icon_state = "remote"
	base_icon_state = "remote"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon = 'icons/obj/devices/remote.dmi'
	name = "control wand"
	desc = "A remote for controlling a set of airlocks."
	w_class = WEIGHT_CLASS_TINY
	var/department = "civilian"
	var/mode = WAND_OPEN
	var/region_access = REGION_GENERAL
	var/list/access_list
	/// The name that gets sent back to IDs that send access requests to this remote. Defaults to the department head's job
	var/response_name = null
	var/listening = FALSE
	/// an asslist (ID : door)
	var/list/open_requests = null
	/// When the remote gets dropped, start a ten minute timer before we stop listening for requests
	var/stop_listening_timer = null
	var/list/setting_callbacks = list()
	var/static/list/response_radials


/obj/item/door_remote/Initialize(mapload)
	. = ..()
	access_list = SSid_access.get_region_access_list(list(region_access))
	update_icon_state()
	if(!response_name)
		response_name = department
	setting_callbacks = list( // asslist of callbacks for the config menu, see handle_config
	"C" = CALLBACK(src, PROC_REF(clear_requests)),
	"A" = CALLBACK(src, PROC_REF(set_auto_response)),
	"T" = CALLBACK(src, PROC_REF(toggle_listen)),
	)
	// For cases where it spawns on somebody
	setup_radial_images()
	if(get(loc, /mob/living))
		toggle_listen(loc)
	else
		RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))

/obj/item/door_remote/proc/setup_radial_images()
	if(response_radials) // already setup
		return
	response_radials = REMOTE_RESPONSE_RADIALS

/obj/item/door_remote/proc/resolve_radial_options()
	var/static/list/available_options = list(
		WAND_OPEN = DOOR_REMOTE_RADIAL_OPERATION_OPENING_INDEX,
		WAND_BOLT = DOOR_REMOTE_RADIAL_OPERATION_BOLTING_INDEX,
		WAND_EMERGENCY = DOOR_REMOTE_RADIAL_OPERATION_EA_INDEX,
		WAND_SHOCK = DOOR_REMOTE_RADIAL_OPERATION_SHOCK_INDEX,
		WAND_HANDLE_REQUESTS = 5, // fuck off
	)
	var/list/image_set = GLOB.door_remote_radial_images?[region_access]
	var/is_emagged = obj_flags & EMAGGED
	if(!image_set)
		image_set = GLOB.door_remote_radial_images[REGION_ALL_STATION]
	image_set = list(image_set.Copy()) // so we don't end up messing around with the GLOB
	image_set += response_radials[DOOR_REMOTE_RADIAL_OPERATION_HANDLE_REQUESTS_INDEX]
	var/list/resolved_options = list()
	for(var/option in available_options)
		resolved_options.Add(available_options[option] = image_set[available_options[option]])
	if(!is_emagged)
		resolved_options.Remove(WAND_SHOCK) // no shock without emag
	return resolved_options

/obj/item/door_remote/proc/on_pickup(datum/source, atom/new_hand_touches_the_beacon)
	SIGNAL_HANDLER
	if(listening)
		deltimer(stop_listening_timer)
	else
		toggle_listen(new_hand_touches_the_beacon)
	UnregisterSignal(src, COMSIG_ITEM_PICKUP)

/obj/item/door_remote/proc/toggle_listen(mob/user, setting_toggle = FALSE)
	if(!setting_toggle)
		if(!listening)
			listening = !listening
			RegisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, PROC_REF(receive_access_request))
			log_admin("[src] has started listening for door access requests due to being picked up.")
			SSid_access.add_listening_remote(region_access, src)
		else
			listening = !listening
			UnregisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST)
			log_admin("[src] has stopped listening for access requests due to being abandoned.")
			SSid_access.remove_listening_remote(region_access, src)
			RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))

	else
		if(!listening)
			RegisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, PROC_REF(receive_access_request))
			listening = !listening
			log_admin("[user] has activated [src] to listen to door access requests.")
			SSid_access.add_listening_remote(region_access, src)
		else
			UnregisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST)
			log_admin("[user] has deactivated [src] listening to door access requests.")
			listening = !listening
			SSid_access.remove_listening_remote(region_access, src)

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

/obj/item/door_remote/attack_self(mob/user)
	var/list/radial_options = resolve_radial_options()
	var/choice = show_radial_menu(user, user, radial_options, radius = 32)
	switch(choice)
		if(WAND_OPEN)
			mode = WAND_OPEN
		if(WAND_BOLT)
			mode = WAND_BOLT
		if(WAND_EMERGENCY)
			mode = WAND_EMERGENCY
		if(WAND_HANDLE_REQUESTS)
			handle_requests(user)
		if(WAND_SHOCK) // doorshock not wizard shock
			mode = WAND_SHOCK
	update_icon_state()
	balloon_alert(user, "mode: [desc[mode]]")

/obj/item/door_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/door) && !isturf(interacting_with))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

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
	balloon_alert(user, "Choose batch action:")
	var/list/available_actions
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
/obj/item/door_remote/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/obj/machinery/door/door

	if (istype(interacting_with, /obj/machinery/door))
		door = interacting_with
		if (!door.opens_with_door_remote)
			return ITEM_INTERACT_BLOCKING

	else
		for (var/obj/machinery/door/door_on_turf in get_turf(interacting_with))
			if (door_on_turf.opens_with_door_remote)
				door = door_on_turf
				break

		if (isnull(door))
			return ITEM_INTERACT_BLOCKING

	if (!door.check_access_list(access_list) || !door.requiresID())
		interacting_with.balloon_alert(user, "can't access!")
		return ITEM_INTERACT_BLOCKING

	var/obj/machinery/door/airlock/airlock = door

	if (!door.hasPower() || (istype(airlock) && !airlock.canAIControl()))
		interacting_with.balloon_alert(user, mode == WAND_OPEN ? "it won't budge!" : "nothing happens!")
		return ITEM_INTERACT_BLOCKING

	switch (mode)
		if (WAND_OPEN)
			if (door.density)
				door.open()
			else
				door.close()
		if (WAND_BOLT)
			if (!istype(airlock))
				interacting_with.balloon_alert(user, "only airlocks!")
				return ITEM_INTERACT_BLOCKING

			if (airlock.locked)
				airlock.unbolt()
				log_combat(user, airlock, "unbolted", src)
			else
				airlock.bolt()
				log_combat(user, airlock, "bolted", src)
		if (WAND_EMERGENCY)
			if (!istype(airlock))
				interacting_with.balloon_alert(user, "only airlocks!")
				return ITEM_INTERACT_BLOCKING

			airlock.emergency = !airlock.emergency
			airlock.update_appearance(UPDATE_ICON)

	return ITEM_INTERACT_SUCCESS

/obj/item/door_remote/update_icon_state()
	var/icon_state_mode
	switch(mode)
		if(WAND_OPEN)
			icon_state_mode = "open"
		if(WAND_BOLT)
			icon_state_mode = "bolt"
		if(WAND_EMERGENCY)
			icon_state_mode = "emergency"

	icon_state = "[base_icon_state]_[department]_[icon_state_mode]"
	return ..()

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	department = "omni"
	region_access = REGION_ALL_STATION

/obj/item/door_remote/command
	name = "command door remote"
	department = "command"
	response_name = span_comradio("CAPTAIN")
	region_access = REGION_COMMAND

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	department = "engi"
	response_name = span_engradio("CHIEF ENGINEER")
	region_access = REGION_ENGINEERING

/obj/item/door_remote/research_director
	name = "research door remote"
	department = "sci"
	response_name = span_sciradio("RESEARCH DIRECTOR")
	region_access = REGION_RESEARCH

/obj/item/door_remote/head_of_security
	name = "security door remote"
	department = "security"
	region_access = REGION_SECURITY

/obj/item/door_remote/head_of_security/Initialize(mapload)
	/// Warden wishes they were a head
	response_name = span_secradio("HEAD OF SEC[generate_heretic_text(3)]WARDEN")
	. = ..()

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	desc = "Remotely controls airlocks. This remote has additional Vault access."
	department = "cargo"
	response_name = span_suppradio("QUARTERMASTER")
	region_access = REGION_SUPPLY

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	department = "med"
	response_name = span_medradio("CHIEF MEDICAL OFFICER")
	region_access = REGION_MEDBAY

/obj/item/door_remote/civilian
	name = "civilian door remote"
	department = "civilian"
	response_name = span_servradio("HEAD OF PERSONNEL")
	region_access = REGION_GENERAL

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
#undef WAND_HANDLE_REQUESTS
#undef WAND_SHOCK
