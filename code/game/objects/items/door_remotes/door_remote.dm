#define RESOLVE_OPERATION_RADIALS (1<<0)
#define RESOLVE_RESPONSE_RADIALS (1<<1)

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
	var/department_name = "civilian"
	var/mode = WAND_OPEN
	var/datum/id_trim/job/owner_trim = null
	var/list/access_list
	var/listening = FALSE
	/// The name that gets sent back to IDs that send access requests to this remote. Defaults to the department_name head's id_trim/job
	var/response_name = null
	/// A bitfield to represent regions this remote is listening to requests for
	/// Will typically be one region; Captain can listen to any station region; down the line
	/// we may allow remotes to have their access modified by HoP, hacking, science, etc.
	var/listening_regions = null
	/// When the remote gets dropped, start a 5 minute timer before we stop listening for requests
	var/list/setting_callbacks = list()
	// Areas this remote has unfettered access to
	var/list/our_departmental_areas = null
	// Assoclist of ID -> door they want opened
	var/list/open_requests
	// A simple lists of IDs that have had their requests resolved recently
	// so we can make sure our timers are expiring (or not) the correct requests
	var/list/recently_resolved_requests
	// A given response to automatically respond to any given request with (horrible idea, good for morale)
	var/auto_response = null

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
	/// Warden wishes they were a head
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
	owner_trim = SSid_access.trim_singletons_by_path[owner_trim]
	access_list = owner_trim.access
	update_icon_state()
	if(!response_name)
		response_name = department_name
	setting_callbacks = list( // asslist of callbacks for the config menu, see handle_config
	"C" = CALLBACK(src, PROC_REF(clear_requests)),
	"A" = CALLBACK(src, PROC_REF(set_auto_response)),
	"T" = CALLBACK(src, PROC_REF(toggle_listen)),
	)
	// For cases where it spawns on somebody
	return INITIALIZE_HINT_LATELOAD

/obj/item/door_remote/LateInitialize()
	. = ..()
	if(get(loc, /mob/living))
		toggle_listen()
	else
		RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))

/obj/item/door_remote/proc/resolve_mode_radial_options()
	var/static/list/always_available_options = list(
		WAND_OPEN,
		WAND_BOLT,
		WAND_EMERGENCY,
	)
	var/static/handle_requests_option = WAND_HANDLE_REQUESTS
	var/static/emagged_available_option = WAND_SHOCK
	var/list/image_set = GLOB.door_remote_radial_images?[department_name]
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

/obj/item/door_remote/proc/resolve_response_radial_options()
	var/list/resolved_options = list()
	var/is_emagged = obj_flags & EMAGGED
	var/static/list/request_handling_options = GLOB.door_remote_radial_images[REQUEST_RESPONSES]
	for(var/option in request_handling_options)
		resolved_options[option] = request_handling_options[option]
	if(!is_emagged)
		resolved_options -= REMOTE_RESPONSE_SHOCK
	return resolved_options

/obj/item/door_remote/proc/on_pickup(datum/source, atom/new_hand_touches_the_beacon)
	SIGNAL_HANDLER
	if(!listening)
		toggle_listen()
	UnregisterSignal(src, COMSIG_ITEM_PICKUP)

/obj/item/door_remote/attack_self(mob/user)
	var/list/radial_options = resolve_mode_radial_options()
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

	if ((!door.check_access_list(access_list) && !in_our_area(get_area(door))) || !door.requiresID())
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
				airlock.set_electrified(MACHINE_ELECTRIFIED_PERMANENT, user)

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


