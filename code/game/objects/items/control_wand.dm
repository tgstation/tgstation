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
	var/setting_callbacks = list(
		CALLBACK(src, PROC_REF(clear_requests)),
		CALLBACK(src, PROC_REF(set_listen_for_requests),
		CALLBACK(src, PROC_REF(set_auto_response)),
		CALLBACK(src, PROC_REF(stop_listening))
		)

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	access_list = SSid_access.get_region_access_list(list(region_access))
	update_icon_state()
	if(!response_name)
		response_name = department
	/// For cases where it spawns on somebody
	if(get(loc, /mob/living))
		set_listen_for_requests(src, loc)
	else
		RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(set_listen_for_requests))


/obj/item/door_remote/proc/set_listen_for_requests(datum/source, atom/new_location, setting_toggle = FALSE)
	SIGNAL_HANDLER
	/// If we were moved to a mob, start listening...
	RegisterSignal(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, PROC_REF(receive_access_request))
	if(!setting_toggle && (!listening || stop_listening_timer))
		UnregisterSignal(COMSIG_ITEM_PICKUP)
		if(stop_listening_timer)
			deltimer(stop_listening_timer)
			stop_listening_timer = null
	SSid_access.add_listening_remote(region_access, src)

/obj/item/door_remote/proc/receive_access_request(datum/source, obj/item/card/id/ID_requesting, obj/machinery/door/airlock/requested_door)
	SIGNAL_HANDLER

	if(open_requests[ID_requesting])
		ID_requesting.visible_message(span_notice("Irritably vibrating text rolls across [ID_requesting]: REQUEST PENDING FOR _[response_name]_, PLEASE WAIT."), vision_distance = 1)
		return COMPONENT_REQUEST_LIMIT_REACHED
	if(recent_rejections[ID_requesting])
		ID_requesting.visible_message(span_danger("A grating buzz sounds and [ID_requesting] warns: REQUEST TO _[response_name]_ REFUSED."))
		return COMPONENT_NOT_ON_THE_LIST_PAL
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

///obj/item/door_remote/attack_self_secondary(mob/user)
//	var/choice = tgui_alert(user, message = "", src.name, list/buttons = list("Configure remote", "Handle access requests"), timeout = 10 SECONDS)
//	if(choice == "Configure remote")
//		configure_remote(user)
//	else if (choice == "Handle access requests")
//		handle_requests(user)
//	else
//		return

/obj/item/door_remote/proc/handle_requests(mob/user)
	// TGUI doesn't like when you feed associative arrays from BYOND into its functions that want
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
		if(!istype(request_item, obj/item/card/id) || !istype(requested_door, obj/machinery/door/airlock))
			request_item = "ERR! Request signal lost! Contact the engineering department."
			continue
		for(var/obj/machinery/camera/smile_youre_on_camera in view(7, requested_door))
			if(smile_youre_on_camera.is_operational && (get_dist(smile_youre_on_camera, requested_door) <= smile_youre_on_camera.view_range))
				nearest_camera = smile_youre_on_camera
				break
		parsed_requests += "[request_item.registered_name] -> [open_requests[request_item]] ([nearest_camera ? nearest_camera.c_tag : get_area(requested_door)])"
	parsed_requests +=
	list(
		"\[OPERATION\] Clear all requests" = PROC_REF(clear_requests),
		(listening ? "\[OPERATION\] Stop listening for requests" = PROC_REF(stop_listening) : \
		"\[OPERATION\] Start listening for requests" = PROC_REF(set_listen_for_requests),
		"\[OPERATION\] !CAUTION! Set automatic request response. !CAUTION!)" = PROC_REF(set_auto_response))
	var/choices = list(tgui_input_checkboxes(user = user, message = "Handle requests", title = "Select", items = parsed_requests))
	if(!choices)
		return
	else
		var/choices_indexes = list()
		// checkbox input returns a list of tuples, first index is a string of whatever given index
		// and second is the index from the original list that the given item should represent
		for(var/tuple as anything in choices)
			choices_indexes += tuple[2]
		// at minimum, this will be three, because we add three options arbitrarily a few lines up
		// for parsed requests
		var/operation_check = len(parsed_requests)
		if()

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
	response_name = "CAPTAIN"
	region_access = REGION_COMMAND

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	department = "engi"
	response_name = "CHIEF ENGINEER"
	region_access = REGION_ENGINEERING

/obj/item/door_remote/research_director
	name = "research door remote"
	department = "sci"
	response_name = "RESEARCH DIRECTOR"
	region_access = REGION_RESEARCH

/obj/item/door_remote/head_of_security
	name = "security door remote"
	department = "security"
	/// Warden wishes they were a head
	response_name = "HEAD OF SEC~~!*$-- WARDEN"
	region_access = REGION_SECURITY

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	desc = "Remotely controls airlocks. This remote has additional Vault access."
	department = "cargo"
	response_name = "QUARTERMASTER"
	region_access = REGION_SUPPLY

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	department = "med"
	response_name = "CHIEF MEDICAL OFFICER"
	region_access = REGION_MEDBAY

/obj/item/door_remote/civilian
	name = "civilian door remote"
	department = "civilian"
	response_name = "HEAD OF PERSONNEL"
	region_access = REGION_GENERAL

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
