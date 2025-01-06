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
	var/static/list/always_available_options = list(
		WAND_OPEN,
		WAND_BOLT,
		WAND_EMERGENCY,
	)
	var/static/handle_requests_option = WAND_HANDLE_REQUESTS
	var/static/emagged_available_option = WAND_SHOCK
	var/list/image_set = GLOB.door_remote_radial_images?[region_access]
	var/is_emagged = obj_flags & EMAGGED
	if(!image_set)
		image_set = GLOB.door_remote_radial_images[REGION_ALL_STATION]
	var/list/resolved_options = list()
	for(var/option in always_available_options)
		resolved_options[option] = image_set[option]
	resolved_options[handle_requests_option] = GLOB.door_remote_radial_images[WAND_HANDLE_REQUESTS]
	if(is_emagged)
		resolved_options[emagged_available_option] = image_set[emagged_available_option]
	return resolved_options

/obj/item/door_remote/proc/on_pickup(datum/source, atom/new_hand_touches_the_beacon)
	SIGNAL_HANDLER
	if(listening)
		deltimer(stop_listening_timer)
	else
		toggle_listen(new_hand_touches_the_beacon)
	UnregisterSignal(src, COMSIG_ITEM_PICKUP)

/obj/item/door_remote/attack_self(mob/user)
	var/list/radial_options = resolve_radial_options()
	var/choice = show_radial_menu(user, user, radial_options, radius = 40)
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
