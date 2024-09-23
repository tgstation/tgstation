#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"
#define WAND_HANDLE_REQUESTS "requests"

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
	/// The name that gets sent back to IDs that send access requests to this remote. Defaults to department.
	var/response_name = null
	var/listening = FALSE
	/// A list of paired items, the first being the ID card requesting access, the second being the door that access is requested for.
	/// They'll only be able to request one door per ID, both so we're not cramming this full of lists that need to be GC'd and to make
	/// remote requests kind of a pain in the ass and a situation where they should request adding the access to their ID from the relevant
	/// head of staff.
	var/open_requests = list()
	/// When the remote gets dropped, start a ten minute timer before we stop listening for requests
	var/stop_listening_timer = null
	var/setting_callbacks = list()

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	access_list = SSid_access.get_region_access_list(list(region_access))
	update_icon_state()
	if(!response_name)
		response_name = department
	setting_callbacks = list(
	CALLBACK(src, PROC_REF(clear_requests)),
	CALLBACK(src, PROC_REF(toggle_listen)),
	CALLBACK(src, PROC_REF(set_auto_response)),
	)
	// For cases where it spawns on somebody
	if(get(loc, /mob/living))
		toggle_listen(loc)
	else
		RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))

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

/obj/item/door_remote/proc/clear_requests()
	return

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
	var/static/list/desc = list(WAND_OPEN = "Open Door", WAND_BOLT = "Toggle Bolts", WAND_EMERGENCY = "Toggle Emergency Access", WAND_HANDLE_REQUESTS = "Handle access requests")
	var/choice = show_radial_menu(user, user, desc, radius = 32)
	switch(choice)
		if(WAND_OPEN)
			mode = WAND_OPEN
		if(WAND_BOLT)
			mode = WAND_BOLT
		if(WAND_EMERGENCY)
			mode = WAND_EMERGENCY
		if(WAND_HANDLE_REQUESTS)
			handle_requests(user)
	update_icon_state()
	balloon_alert(user, "mode: [desc[mode]]")

/obj/item/door_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/door) && !isturf(interacting_with))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/door_remote/proc/handle_requests(mob/user)
	// Javascript doesn't like when you feed associative arrays from BYOND into its functions that want
	// primitives so we get a little saucy here.
	var/list/parsed_requests = list()
	for(var/obj/item/card/id/request_item in open_requests)
		var/obj/machinery/camera/nearest_camera = null
		// Open requests is an associated list of (id_card : door_requested), but when we
		// handle requests we'll dynamically check if the door is in-sight of a functional
		// camera; presumably the remote holder will also have access to those cameras from
		// their telescreen so they can make sure whoever has that ID is the person in question
		// It's not like someone would steal the remote, right?
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
		parsed_requests += "[request_item.registered_name] -> [open_requests[request_item]] ([nearest_camera ? nearest_camera.c_tag : get_area(requested_door)])"
	parsed_requests += list(
		"\[OPERATION\] Clear all requests",
		"\[OPERATION\] [listening ? "Stop" : "Start"] listening for requests",
		"\[OPERATION\] !CAUTION!_Set automatic request response_!CAUTION!)")
	var/list/choices = list()
	choices = tgui_input_checkboxes(user = user,
	message = "Please choose either a single operation, or a set of door access requests to perform\
	 a batch operation on. Nanotrasen Incorporated not liable for any criminal activity or loss of\
	 profit and/or life resulting from door requests.",
	   title = "DOOR REQUEST HANDLER AND CONFIGURATION", items = parsed_requests)
	var/number_of_choices = length(choices)
	if(!number_of_choices)
		return
	else
		// at minimum, this will be three, because we add three options arbitrarily for config
		var/parsed_length = length(parsed_requests)
		// Decouple the index from the returned lists, and also check if they wanted to do an operation
		/* Check early to see if they only chose one operation option; if so, do that and stop
		 * NOTE: Due to how BYOND handles lists of list, if they only choose one option, then it won't
		 * return a list of lists, it will just return the contents of the single returned list and put
		 * that in var/choices instead.
		 */
		// It's either this or a couple dozen more lines to make sure
		// it's always a list of lists
		if(number_of_choices == 1 && /*isnum(*/choices[1][2]/*) && choices[2]*/ >= parsed_length - 3)
			var/index_for_readability = choices[1][2]
			var/datum/callback/chosen_callback = setting_callbacks[index_for_readability]
			if(index_for_readability == 2)
				return chosen_callback.Invoke(user, /*setting_toggle = */TRUE)
			else
				return chosen_callback.Invoke(user)
		for(var/list/operation in choices)
			// The length of the parsed_requests is 3 at a minimum, and we can see
			// if they chose to do an operation, but we don't want to muck with priority
			// if they try to do multiple operations along with door request handling
			// so it'll have to be mutually exclusive
			if(operation[2] >= parsed_length - 3)
				if(number_of_choices > 1)
					to_chat(user, span_notice("%ERR...% Operations are mutually exclusive with each other and batch handling. %ERR...%"))
					return




/obj/item/door_remote/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)


/obj/item/door_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
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
