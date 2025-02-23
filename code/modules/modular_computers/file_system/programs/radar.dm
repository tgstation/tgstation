///The selected target is not trackable
#define RADAR_NOT_TRACKABLE 0
///The selected target is trackable
#define RADAR_TRACKABLE 1
///The selected target is trackable, even if subtypes would normally consider it untrackable.
#define RADAR_TRACKABLE_ANYWAY 2

///If the target is something it shouldn't be normally tracking, this is the maximum distance within with it an be tracked.
#define MAX_RADAR_CIRCUIT_DISTANCE 18

/datum/computer_file/program/radar //generic parent that handles most of the process
	filename = "genericfinder"
	filedesc = "debug_finder"
	downloader_category = PROGRAM_CATEGORY_EQUIPMENT
	ui_header = "borg_mon.gif" //DEBUG -- new icon before PR
	program_open_overlay = "radarntos"
	program_flags = PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_LAPTOP | PROGRAM_PDA
	size = 5
	tgui_id = "NtosRadar"
	///List of trackable entities. Updated by the scan() proc.
	var/list/list/objects
	///Ref of the last trackable object selected by the user in the tgui window. Updated in the ui_act() proc.
	var/selected
	///Used to store when the next scan is available.
	COOLDOWN_DECLARE(next_scan)
	///Used to keep track of the last value program_open_overlay was set to, to prevent constant unnecessary update_appearance() calls
	var/last_icon_state = ""
	///Used by the tgui interface, themed NT or Syndicate.
	var/arrowstyle = "ntosradarpointer.png"
	///Used by the tgui interface, themed for NT or Syndicate colors.
	var/pointercolor = "green"

/datum/computer_file/program/radar/on_start(mob/living/user)
	. = ..()
	if(!.)
		return
	if(COOLDOWN_FINISHED(src, next_scan))
		// start with a scan without a cooldown, but don't scan if we *are* on cooldown already.
		scan()
	START_PROCESSING(SSfastprocess, src)

/datum/computer_file/program/radar/kill_program(mob/user)
	objects = list()
	selected = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/computer_file/program/radar/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/computer_file/program/radar/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/radar_assets),
	)

/datum/computer_file/program/radar/ui_data(mob/user)
	var/list/data = list()
	data["selected"] = selected
	data["scanning"] = !COOLDOWN_FINISHED(src, next_scan)
	data["object"] = objects

	data["target"] = list()
	var/list/trackinfo = track()
	if(trackinfo)
		data["target"] = trackinfo
	return data

/datum/computer_file/program/radar/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("selecttarget")
			var/selected_new_ref = params["ref"]
			if(selected_new_ref in trackable_object_refs())
				selected = selected_new_ref
				SEND_SIGNAL(computer, COMSIG_MODULAR_COMPUTER_RADAR_SELECTED, selected)
			return TRUE

		if("scan")
			if(!COOLDOWN_FINISHED(src, next_scan))
				return TRUE // update anyways

			COOLDOWN_START(src, next_scan, 2 SECONDS)
			scan()
			return TRUE

/// Returns all ref()s that are being tracked currently
/datum/computer_file/program/radar/proc/trackable_object_refs()
	var/list/all_refs = list()
	for(var/list/object_list as anything in objects)
		all_refs += object_list["ref"]
	return all_refs

/**
 *Updates tracking information of the selected target.
 *
 *The track() proc updates the entire set of information about the location
 *of the target, including whether the Ntos window should use a pinpointer
 *crosshair over the up/down arrows, or none in favor of a rotating arrow
 *for far away targets. This information is returned in the form of a list.
 *
*/
/datum/computer_file/program/radar/proc/track()
	var/atom/movable/signal = find_atom()
	if(!trackable(signal))
		return

	var/turf/here_turf = (get_turf(computer))
	var/turf/target_turf = (get_turf(signal))
	var/userot = FALSE
	var/rot = 0
	var/pointer="crosshairs"
	var/locx = (target_turf.x - here_turf.x) + 24
	var/locy = (here_turf.y - target_turf.y) + 24

	if(get_dist_euclidean(here_turf, target_turf) > 24)
		userot = TRUE
		rot = round(get_angle(here_turf, target_turf))
	else
		if(target_turf.z > here_turf.z)
			pointer="caret-up"
		else if(target_turf.z < here_turf.z)
			pointer="caret-down"

	var/list/trackinfo = list(
		"locx" = locx,
		"locy" = locy,
		"userot" = userot,
		"rot" = rot,
		"arrowstyle" = arrowstyle,
		"color" = pointercolor,
		"pointer" = pointer,
		)
	return trackinfo

/**
 *
 *Checks the trackability of the selected target.
 *
 *If the target is on the computer's Z level, or both are on station Z
 *levels, and the target isn't untrackable, return TRUE.
 *Arguments:
 **arg1 is the atom being evaluated.
*/
/datum/computer_file/program/radar/proc/trackable(atom/movable/signal)
	SHOULD_CALL_PARENT(TRUE)
	if(isnull(signal) || isnull(computer))
		return RADAR_NOT_TRACKABLE
	var/turf/here = get_turf(computer)
	var/turf/there = get_turf(signal)
	if(isnull(here) || isnull(there) || !is_valid_z_level(here, there))
		return RADAR_NOT_TRACKABLE
	var/trackable_signal = SEND_SIGNAL(computer, COMSIG_MODULAR_COMPUTER_RADAR_TRACKABLE, signal, here, there)
	if(trackable_signal & COMPONENT_RADAR_TRACK_ANYWAY)
		return RADAR_TRACKABLE_ANYWAY
	if(trackable_signal & COMPONENT_RADAR_DONT_TRACK)
		return RADAR_NOT_TRACKABLE
	return RADAR_TRACKABLE

/**
 *
 *Runs a scan of all the trackable atoms.
 *
 *Checks each entry in the GLOB of the specific trackable atoms against
 *the track() proc, and fill the objects list with lists containing the
 *atoms' names and REFs. The objects list is handed to the tgui screen
 *for displaying to, and being selected by, the user. A two second
 *sleep is used to delay the scan, both for thematical reasons as well
 *as to limit the load players may place on the server using these
 *somewhat costly loops.
*/
/datum/computer_file/program/radar/proc/scan()
	return

/**
 *
 *Finds the atom in the appropriate list that the `selected` var indicates
 *
 *The `selected` var holds a REF, which is a string. A mob REF may be
 *something like "mob_209". In order to find the actual atom, we need
 *to search the appropriate list for the REF string. This is dependant
 *on the program (Lifeline uses GLOB.human_list, while Fission360 uses
 *GLOB.poi_list), but the result will be the same; evaluate the string and
 *return an atom reference.
*/
/datum/computer_file/program/radar/proc/find_atom()
	SHOULD_CALL_PARENT(TRUE)
	var/list/atom_container = list(null)
	SEND_SIGNAL(computer, COMSIG_MODULAR_COMPUTER_RADAR_FIND_ATOM, atom_container)
	return atom_container[1]

//We use SSfastprocess for the program icon state because it runs faster than process_tick() does.
/datum/computer_file/program/radar/process()
	if(computer.active_program != src)
		//We're not the active program, it's time to stop.
		return PROCESS_KILL
	if(!selected)
		return

	var/atom/movable/signal = find_atom()
	if(!trackable(signal))
		program_open_overlay = "[initial(program_open_overlay)]lost"
		if(last_icon_state != program_open_overlay)
			computer.update_appearance()
			last_icon_state = program_open_overlay
		return

	var/here_turf = get_turf(computer)
	var/target_turf = get_turf(signal)
	var/trackdistance = get_dist_euclidean(here_turf, target_turf)
	switch(trackdistance)
		if(0)
			program_open_overlay = "[initial(program_open_overlay)]direct"
		if(1 to 12)
			program_open_overlay = "[initial(program_open_overlay)]close"
		if(13 to 24)
			program_open_overlay = "[initial(program_open_overlay)]medium"
		if(25 to INFINITY)
			program_open_overlay = "[initial(program_open_overlay)]far"

	if(last_icon_state != program_open_overlay)
		computer.update_appearance()
		last_icon_state = program_open_overlay
	computer.setDir(get_dir(here_turf, target_turf))

//We can use process_tick to restart fast processing, since the computer will be running this constantly either way.
/datum/computer_file/program/radar/process_tick(seconds_per_tick)
	if(computer.active_program == src)
		START_PROCESSING(SSfastprocess, src)

///////////////////
//Suit Sensor App//
///////////////////

///A program that tracks crew members via suit sensors
/datum/computer_file/program/radar/lifeline
	filename = "lifeline"
	filedesc = "Lifeline"
	extended_desc = "This program allows for tracking of crew members via their suit sensors."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	download_access = list(ACCESS_MEDICAL)
	program_icon = "heartbeat"
	circuit_comp_type = /obj/item/circuit_component/mod_program/radar/medical

/datum/computer_file/program/radar/lifeline/find_atom()
	return ..() || (locate(selected) in GLOB.human_list)

/datum/computer_file/program/radar/lifeline/scan()
	objects = list()
	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/humanoid = i
		if(!trackable(humanoid))
			continue
		var/crewmember_name = "Unknown"
		if(humanoid.wear_id)
			var/obj/item/card/id/ID = humanoid.wear_id.GetID()
			if(ID?.registered_name)
				crewmember_name = ID.registered_name
		var/list/crewinfo = list(
			ref = REF(humanoid),
			name = crewmember_name,
			)
		objects += list(crewinfo)

/datum/computer_file/program/radar/lifeline/trackable(mob/living/carbon/human/humanoid)
	. = ..()
	if(. != RADAR_TRACKABLE)
		return .
	if(!istype(humanoid))
		return RADAR_NOT_TRACKABLE
	if(!istype(humanoid.w_uniform, /obj/item/clothing/under))
		return RADAR_NOT_TRACKABLE
	var/obj/item/clothing/under/uniform = humanoid.w_uniform
	if(!uniform.has_sensor || uniform.sensor_mode < SENSOR_COORDS) // Suit sensors must be on maximum
		return RADAR_NOT_TRACKABLE
	return .

///Tracks all janitor equipment
/datum/computer_file/program/radar/custodial_locator
	filename = "custodiallocator"
	filedesc = "Custodial Locator"
	extended_desc = "This program allows for tracking of custodial equipment."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	download_access = list(ACCESS_JANITOR)
	program_icon = "broom"
	size = 2
	detomatix_resistance = DETOMATIX_RESIST_MINOR
	circuit_comp_type = /obj/item/circuit_component/mod_program/radar/janitor

/datum/computer_file/program/radar/custodial_locator/find_atom()
	return ..() || (locate(selected) in GLOB.janitor_devices)

/datum/computer_file/program/radar/custodial_locator/scan()
	objects = list()
	for(var/obj/custodial_tools as anything in GLOB.janitor_devices)
		if(!trackable(custodial_tools))
			continue
		var/tool_name = custodial_tools.name

		if(istype(custodial_tools, /obj/item/mop))
			var/obj/item/mop/wet_mop = custodial_tools
			tool_name = "[wet_mop.reagents.total_volume ? "Wet" : "Dry"] [wet_mop.name]"

		if(istype(custodial_tools, /obj/structure/mop_bucket/janitorialcart))
			var/obj/structure/mop_bucket/janitorialcart/janicart = custodial_tools
			tool_name = "[janicart.name] - Water level: [janicart.reagents.total_volume] / [janicart.reagents.maximum_volume]"

		if(istype(custodial_tools, /mob/living/basic/bot/cleanbot))
			var/mob/living/basic/bot/cleanbot/cleanbots = custodial_tools
			tool_name = "[cleanbots.name] - [cleanbots.bot_mode_flags & BOT_MODE_ON ? "Online" : "Offline"]"

		var/list/tool_information = list(
			ref = REF(custodial_tools),
			name = tool_name,
		)
		objects += list(tool_information)

////////////////////////
//Nuke Disk Finder App//
////////////////////////

///A program that tracks nukes and nuclear accessories
/datum/computer_file/program/radar/fission360
	filename = "fission360"
	filedesc = "Fission360"
	program_open_overlay = "radarsyndicate"
	extended_desc = "This program allows for tracking of nuclear authorization disks and warheads."
	program_flags = PROGRAM_ON_SYNDINET_STORE
	tgui_id = "NtosRadarSyndicate"
	program_icon = "bomb"
	arrowstyle = "ntosradarpointerS.png"
	pointercolor = "red"
	circuit_comp_type = /obj/item/circuit_component/mod_program/radar/nukie

/datum/computer_file/program/radar/fission360/on_start(mob/living/user)
	. = ..()
	if(!.)
		return

	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DEVICE_ARMED, PROC_REF(on_nuke_armed))

/datum/computer_file/program/radar/fission360/kill_program(mob/user)
	UnregisterSignal(SSdcs, COMSIG_GLOB_NUKE_DEVICE_ARMED)
	return ..()

/datum/computer_file/program/radar/fission360/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_NUKE_DEVICE_ARMED)
	return ..()

/datum/computer_file/program/radar/fission360/find_atom()
	return ..() || SSpoints_of_interest.get_poi_atom_by_ref(selected)

/datum/computer_file/program/radar/fission360/scan()
	objects = list()

	// All the nukes
	for(var/obj/machinery/nuclearbomb/nuke as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		var/list/nuke_info = list(
			ref = REF(nuke),
			name = nuke.name,
			)
		objects += list(nuke_info)

	// Dat fukken disk
	var/obj/item/disk/nuclear/disk = locate() in SSpoints_of_interest.real_nuclear_disks
	var/list/disk_info = list(
		ref = REF(disk),
		name = "Nuke Auth. Disk",
		)
	objects += list(disk_info)

	// The infiltrator
	var/obj/docking_port/mobile/infiltrator = SSshuttle.getShuttle("syndicate")
	var/list/ship_info = list(
		ref = REF(infiltrator),
		name = "Infiltrator",
		)
	objects += list(ship_info)

///Shows how long until the nuke detonates, if one is active.
/datum/computer_file/program/radar/fission360/on_examine(obj/item/modular_computer/source, mob/user)
	var/list/examine_list = list()

	for(var/obj/machinery/nuclearbomb/bomb as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		if(bomb.timing)
			examine_list += span_danger("Extreme danger. Arming signal detected. Time remaining: [bomb.get_time_left()].")
	return examine_list

/*
 * Signal proc for [COMSIG_GLOB_NUKE_DEVICE_ARMED].
 * Warns anyone nearby or holding the computer that a nuke was armed.
 */
/datum/computer_file/program/radar/fission360/proc/on_nuke_armed(datum/source, obj/machinery/nuclearbomb/bomb)
	SIGNAL_HANDLER

	if(!computer)
		return

	playsound(computer, 'sound/items/nuke_toy_lowpower.ogg', 50, FALSE)
	if(isliving(computer.loc))
		to_chat(computer.loc, span_userdanger("Your [computer.name] vibrates and lets out an ominous alarm. Uh oh."))
	else
		computer.audible_message(
			span_danger("[computer] vibrates and lets out an ominous alarm. Uh oh."),
			span_notice("[computer] begins to vibrate rapidly. Wonder what that means..."),
		)


/**
 * Base circuit for the radar program.
 * The abstract radar doesn't have this, nor this one is associated to it, so
 * make sure to specify the associate_program and circuit_comp_type of subtypes,
 */
/obj/item/circuit_component/mod_program/radar

	///The target to track
	var/datum/port/input/target
	///The selected target, from the app
	var/datum/port/output/selected_by_app
	/// The result from the output
	var/datum/port/output/x_pos
	var/datum/port/output/y_pos

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/mod_program/radar/populate_ports()
	. = ..()
	target = add_input_port("Target", PORT_TYPE_ATOM)
	selected_by_app = add_output_port("Selected From Program", PORT_TYPE_ATOM)
	x_pos = add_output_port("X", PORT_TYPE_NUMBER)
	y_pos = add_output_port("Y", PORT_TYPE_NUMBER)

/obj/item/circuit_component/mod_program/radar/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(associated_program.computer, COMSIG_MODULAR_COMPUTER_RADAR_TRACKABLE, PROC_REF(can_track))
	RegisterSignal(associated_program.computer, COMSIG_MODULAR_COMPUTER_RADAR_FIND_ATOM, PROC_REF(get_atom))
	RegisterSignal(associated_program.computer, COMSIG_MODULAR_COMPUTER_RADAR_SELECTED, PROC_REF(on_selected))

/obj/item/circuit_component/mod_program/radar/unregister_shell()
	UnregisterSignal(associated_program.computer, list(
		COMSIG_MODULAR_COMPUTER_RADAR_TRACKABLE,
		COMSIG_MODULAR_COMPUTER_RADAR_FIND_ATOM,
		COMSIG_MODULAR_COMPUTER_RADAR_SELECTED,
	))
	return ..()

/obj/item/circuit_component/mod_program/radar/get_ui_notices()
	. = ..()
	. += create_ui_notice("Max range for unsupported entities: [MAX_RADAR_CIRCUIT_DISTANCE] tiles", "orange", FA_ICON_BULLSEYE)

///Set the selected ref of the program to the target (if it exists) and update the x/y pos ports (if trackable) when triggered.
/obj/item/circuit_component/mod_program/radar/input_received(datum/port/port)
	var/datum/computer_file/program/radar/radar = associated_program
	var/atom/radar_atom = radar.find_atom()
	if(target.value != radar_atom)
		radar.selected = REF(target.value)
		SStgui.update_uis(radar.computer)
	if(radar.trackable(radar_atom))
		var/turf/turf = get_turf(radar_atom)
		x_pos.set_output(turf.x)
		y_pos.set_output(turf.y)
	else
		x_pos.set_output(null)
		y_pos.set_output(null)

/**
 * Check if we can track the object. When making different definitions of this proc for subtypes, include typical
 * targets as an exception to this (e.g humans for lifeline) so that even if they're coming from a circuit input
 * they won't get filtered by the maximum distance, because they're "supported entities".
 */
/obj/item/circuit_component/mod_program/radar/proc/can_track(datum/source, atom/signal, signal_turf, computer_turf)
	SIGNAL_HANDLER
	if(target.value && get_dist_euclidean(computer_turf, signal_turf) > MAX_RADAR_CIRCUIT_DISTANCE)
		return COMPONENT_RADAR_DONT_TRACK
	return COMPONENT_RADAR_TRACK_ANYWAY

///Return the value of the target port.
/obj/item/circuit_component/mod_program/radar/proc/get_atom(datum/source, list/atom_container)
	SIGNAL_HANDLER
	atom_container[1] = target.value

/**
 * When a target is selected by the app, reset the target port, update the x/pos ports (if trackable)
 * and set selected_by_app port to the target atom.
 */
/obj/item/circuit_component/mod_program/radar/proc/on_selected(datum/source, selected_ref)
	SIGNAL_HANDLER
	target.set_value(null)
	var/datum/computer_file/program/radar/radar = associated_program
	var/atom/selected_atom = radar.find_atom()
	selected_by_app.set_output(selected_atom)
	if(radar.trackable(selected_atom))
		var/turf/turf = get_turf(radar.selected)
		x_pos.set_output(turf.x)
		y_pos.set_output(turf.y)
	else
		x_pos.set_output(null)
		y_pos.set_output(null)

	trigger_output.set_output(COMPONENT_SIGNAL)


/obj/item/circuit_component/mod_program/radar/medical
	associated_program = /datum/computer_file/program/radar/lifeline

/obj/item/circuit_component/mod_program/radar/medical/can_track(datum/source, atom/signal, signal_turf, computer_turf)
	if(target.value in GLOB.human_list)
		return NONE
	return ..()

/obj/item/circuit_component/mod_program/radar/janitor
	associated_program = /datum/computer_file/program/radar/custodial_locator

/obj/item/circuit_component/mod_program/radar/janitor/can_track(datum/source, atom/signal, signal_turf, computer_turf)
	if(target.value in GLOB.janitor_devices)
		return NONE
	return ..()
/obj/item/circuit_component/mod_program/radar/nukie
	associated_program = /datum/computer_file/program/radar/fission360

/obj/item/circuit_component/mod_program/radar/nukie/can_track(datum/source, atom/signal, signal_turf, computer_turf)
	if(target.value in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		return NONE
	if(target.value in SSpoints_of_interest.real_nuclear_disks)
		return NONE
	if(target.value == SSshuttle.getShuttle("syndicate"))
		return NONE
	return ..()

#undef MAX_RADAR_CIRCUIT_DISTANCE

#undef RADAR_NOT_TRACKABLE
#undef RADAR_TRACKABLE
#undef RADAR_TRACKABLE_ANYWAY
