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
	var/static/list/always_available_options = list(
		WAND_OPEN,
		WAND_BOLT,
		WAND_EMERGENCY,
		WAND_HANDLE_REQUESTS
		)
	var/static/emagged_available_option = WAND_SHOCK
	var/department_name = "civilian"
	var/mode = WAND_OPEN
	var/datum/id_trim/job/owner_trim = null
	var/list/accesses = list()
	var/listening = FALSE
	/// The name that gets sent back to IDs that send access requests to this remote. Defaults to the department_name head's id_trim/job
	var/response_name = null
	/// When the remote gets dropped, start a 5 minute timer before we stop listening for requests
	var/listen_timeout_timer_id = null
	var/static/list/special_modes = list(
		WAND_HANDLE_REQUESTS,
		WAND_HANDLE_CONFIG,
	)
	// Areas this remote has unfettered access to
	var/list/our_departmental_areas = null
	// A given response to automatically respond to any given request with (horrible idea, good for morale)
	var/auto_response = null
	// Whether a remote holder has disabled its audio feedback messages
	var/silenced = FALSE
	// A head of staff with access equaling this remote's access can lock it down
	// To unlock the remote, the person wanting to unlock it must have access equal to
	// or greater than whoever locked it
	var/locked_down = FALSE
	// Dummy record created on the remote (instead of the subsystem) when the remote gets emagged
	// Record auditing returns a dummy record when there is one
	var/list/dummy_record = null

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	department_name = "omni"
	owner_trim = /datum/id_trim/job/captain
	our_departmental_areas = list(
		/area/station,	// like a boss
		)

/obj/item/door_remote/omni/captain
	name = "captain's door remote"
	desc = "This gaudily decorated remote can access any door on the station. This can only end well."
	department_name = DEPARTMENT_COMMAND
	response_name = span_comradio("CAPTAIN")

/obj/item/door_remote/chief_engineer
	name = "chief engineer's door remote"
	department_name = DEPARTMENT_ENGINEERING
	response_name = span_engradio("CHIEF ENGINEER")
	owner_trim = /datum/id_trim/job/chief_engineer
	our_departmental_areas = list(
		/area/station/engineering,
		/area/station/construction,
		/area/station/server,
		/area/station/tcommsat,
		/area/station/server,
		)

/obj/item/door_remote/research_director
	name = "research director's door remote"
	department_name = DEPARTMENT_SCIENCE
	response_name = span_sciradio("RESEARCH DIRECTOR")
	owner_trim = /datum/id_trim/job/research_director
	our_departmental_areas = list(
		/area/station/science,
		/area/station/ai_monitored/aisat,
		/area/station/ai_monitored/turret_protected,
	)

/obj/item/door_remote/head_of_security
	name = "warden's(?) door remote"
	desc = "This door remote controls Security airlocks. An indescripable odor emanates from it: fear, sweat, coffee... is that a hint of resentment? It looks like someone has tampered with the identifier."
	department_name = DEPARTMENT_SECURITY
	owner_trim = /datum/id_trim/job/head_of_security
	our_departmental_areas = list(
		/area/station/security,
		/area/station/ai_monitored/security,
	)

/obj/item/door_remote/head_of_security/Initialize(mapload)
	// Warden wishes they were a head
	response_name = span_secradio("HEAD OF SEC[generate_heretic_text(3)]WARDEN")
	return ..()

/obj/item/door_remote/quartermaster
	name = "quartermaster's door remote"
	desc = "Remotely controls airlocks. This remote has additional Vault access. Holding it makes you feel insecure, for some reason."
	department_name = DEPARTMENT_CARGO
	response_name = span_suppradio("QUARTERMASTER")
	owner_trim = /datum/id_trim/job/quartermaster
	our_departmental_areas = list(
		/area/station/cargo,
	)

/obj/item/door_remote/chief_medical_officer
	name = "chief medical officer's door remote"
	department_name = DEPARTMENT_MEDICAL
	response_name = span_medradio("CHIEF MEDICAL OFFICER")
	owner_trim = /datum/id_trim/job/chief_medical_officer
	our_departmental_areas = list(
		/area/station/medical,
	)

/obj/item/door_remote/head_of_personnel
	name = "head of personnel's remote"
	department_name = DEPARTMENT_SERVICE
	response_name = span_servradio("HEAD OF PERSONNEL")
	owner_trim = /datum/id_trim/job/head_of_personnel
	our_departmental_areas = list(
		/area/station/service,
	)

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	// Trim accesses get updated by configs so we don't set it until all that's done
	if(owner_trim)
		owner_trim = SSid_access.trim_singletons_by_path[owner_trim]
		accesses = owner_trim.access
		req_access = accesses
	update_icon_state()
	if(!response_name)
		response_name = department_name
	// For cases where it spawns on somebody
	return INITIALIZE_HINT_LATELOAD

/obj/item/door_remote/LateInitialize()
	if(get(loc, /mob/living))
		toggle_listen()
	else
		RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	SSdoor_remote_routing.begin_tracking(src)

/obj/item/door_remote/proc/on_pickup(datum/source, atom/new_hand_touches_the_beacon)
	SIGNAL_HANDLER
	if(!listening)
		toggle_listen()
	UnregisterSignal(src, COMSIG_ITEM_PICKUP)

/obj/item/door_remote/attack_self(mob/user)
	if(locked_down)
		notify_lockdown()
		return NONE
	var/list/radial_options = resolve_radial_options("modes")
	var/choice = show_radial_menu(user, user, radial_options, radius = 40)
	if(choice)
		if(choice in special_modes)
			return handle_special_mode(user, choice)
		mode = choice
		balloon_alert(user, "mode: [desc[mode]]")
		if(mode == WAND_SHOCK)
			return // this is only a special case to spare players further coder sprites
	update_icon_state()

/obj/item/door_remote/proc/handle_special_mode(mob/user, special_mode)
	if(special_mode == WAND_HANDLE_REQUESTS)
		handle_requests(user)
		return
	if(special_mode == WAND_HANDLE_CONFIG)
		handle_config(user)

/obj/item/door_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(locked_down)
		notify_lockdown()
		return NONE
	if(!istype(interacting_with, /obj/machinery/door) && !isturf(interacting_with))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/door_remote/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(locked_down)
		notify_lockdown()
		return NONE
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

	if ((!door.check_access_list(accesses) && !in_our_area(get_area(door))) || !door.requiresID())
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

		if (WAND_SHOCK)
			if (!istype(airlock))
				interacting_with.balloon_alert(user, "only airlocks!")
				return ITEM_INTERACT_BLOCKING

			if(airlock.isElectrified())
				airlock.set_electrified(MACHINE_NOT_ELECTRIFIED, user)
			else
				var/duration = MACHINE_ELECTRIFIED_PERMANENT
				if(get_dist(user, airlock) < 7)
					//if they're more than 7 tiles away, only set it temporarily
					//so emagged remote holders can't perma-shock every door with a security camera console
					duration = MACHINE_DEFAULT_ELECTRIFY_TIME
				airlock.set_electrified(duration, user)

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
	icon_state = "[base_icon_state]_[department_name]_[icon_state_mode]"
	return ..()


