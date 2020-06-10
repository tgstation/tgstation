/datum/computer_file/program/radar //generic parent that handles most of the process
	filename = "genericfinder"
	filedesc = "debug_finder"
	ui_header = "borg_mon.gif" //DEBUG -- new icon before PR
	program_icon_state = "generic"
	extended_desc = "generic"
	requires_ntnet = TRUE
	transfer_access = null
	available_on_ntnet = FALSE
	network_destination = "tracking program"
	size = 5
	tgui_id = "NtosRadar"
	ui_x = 800
	ui_y = 600
	special_assets = list(
		/datum/asset/simple/radar_assets,
	)
	///List of trackable entities. Updated by the scan() proc.
	var/list/objects
	///Ref of the last trackable object selected by the user in the tgui window. Updated in the ui_act() proc.
	var/atom/selected
	///Used to store when the next scan is available. Updated by the scan() proc.
	var/next_scan = 0

/datum/computer_file/program/radar/kill_program(forced = FALSE)
	objects = list()
	selected = null
	return ..()

/datum/computer_file/program/radar/ui_data(mob/user)
	var/list/data = get_header_data()
	data["selected"] = selected
	data["objects"] = list()
	data["scanning"] = (world.time < next_scan)
	for(var/list/i in objects)
		var/list/objectdata = list(
			ref = i["ref"],
			name = i["name"],
		)
		data["object"] += list(objectdata)

	data["target"] = list()
	var/list/trackinfo = track()
	if(trackinfo)
		data["target"] = trackinfo
	return data

/datum/computer_file/program/radar/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("selecttarget")
			selected = params["ref"]
		if("scan")
			scan()

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
	return

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
	if(!signal)
		return FALSE
	var/turf/here = get_turf(computer)
	var/turf/there = get_turf(signal)
	return (there.z == here.z) || (is_station_level(here.z) && is_station_level(there.z))

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

///////////////////
//Suit Sensor App//
///////////////////

///A program that tracks crew members via suit sensors
/datum/computer_file/program/radar/lifeline
	filename = "Lifeline"
	filedesc = "Lifeline"
	program_icon_state = "generic"
	extended_desc = "This program allows for tracking of crew members via their suit sensors."
	requires_ntnet = TRUE
	transfer_access = ACCESS_MEDICAL
	available_on_ntnet = TRUE

/datum/computer_file/program/radar/lifeline/track()
	var/mob/living/carbon/human/humanoid = locate(selected) in GLOB.human_list
	if(!istype(humanoid) || !trackable(humanoid))
		return

	var/turf/here_turf = (get_turf(computer))
	var/turf/target_turf = (get_turf(humanoid))
	var/userot = FALSE
	var/rot = 0
	var/pointer="crosshairs"
	var/locx = (target_turf.x - here_turf.x)
	var/locy = (here_turf.y - target_turf.y)
	if(get_dist_euclidian(here_turf, target_turf) > 24) //If they're too far away, we need the angle for the arrow along the edge of the radar display
		userot = TRUE
		rot = round(Get_Angle(here_turf, target_turf))
	else
		locx = locx + 24
		locy = locy + 24
		if(target_turf.z > here_turf.z)
			pointer="caret-up"
		else if(target_turf.z < here_turf.z)
			pointer="caret-down"
	var/list/trackinfo = list(
		locx = locx,
		locy = locy,
		userot = userot,
		rot = rot,
		arrowstyle = "ntosradarpointer.png", //For the rotation arrow, it's stupid I know
		color = "green",
		pointer = pointer,
		)
	return trackinfo

/datum/computer_file/program/radar/lifeline/scan()
	if(world.time < next_scan)
		return
	next_scan = world.time + (2 SECONDS)
	objects = list()
	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/humanoid = i
		if(!trackable(humanoid))
			continue
		var/crewmember_name = "Unknown"
		if(humanoid.wear_id)
			var/obj/item/card/id/ID = humanoid.wear_id.GetID()
			if(ID && ID.registered_name)
				crewmember_name = ID.registered_name
		var/list/crewinfo = list(
			ref = REF(humanoid),
			name = crewmember_name,
			)
		objects += list(crewinfo)

/datum/computer_file/program/radar/lifeline/trackable(mob/living/carbon/human/humanoid)
	if(!humanoid || !istype(humanoid))
		return FALSE
	if(..() && istype(humanoid.w_uniform, /obj/item/clothing/under))

		var/obj/item/clothing/under/uniform = humanoid.w_uniform
		if(!uniform.has_sensor || (uniform.sensor_mode < SENSOR_COORDS)) // Suit sensors must be on maximum.
			return FALSE

		return TRUE

////////////////////////
//Nuke Disk Finder App//
////////////////////////

///A program that tracks crew members via suit sensors
/datum/computer_file/program/radar/fission360
	filename = "Fission360"
	filedesc = "Fission360"
	program_icon_state = "generic"
	extended_desc = "This program allows for tracking of nuclear authorization disks and warheads."
	requires_ntnet = FALSE
	transfer_access = null
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	tgui_id = "NtosRadarSyndicate"

/datum/computer_file/program/radar/fission360/track()
	var/obj/nuke = locate(selected) in GLOB.poi_list
	if(!trackable(nuke))
		return

	var/turf/here_turf = (get_turf(computer))
	var/turf/target_turf = (get_turf(nuke))
	var/userot = FALSE
	var/rot = 0
	var/pointer="crosshairs"
	var/locx = (target_turf.x - here_turf.x)
	var/locy = (here_turf.y - target_turf.y)
	if(get_dist_euclidian(here_turf, target_turf) > 24) //If they're too far away, we need the angle for the arrow along the edge of the radar display
		userot = TRUE
		rot = round(Get_Angle(here_turf, target_turf))
	else
		locx = locx + 24
		locy = locy + 24
		if(target_turf.z > here_turf.z)
			pointer="caret-up"
		else if(target_turf.z < here_turf.z)
			pointer="caret-down"
	var/list/trackinfo = list(
		locx = locx,
		locy = locy,
		userot = userot,
		rot = rot,
		arrowstyle = "ntosradarpointerS.png",
		color = "red",
		pointer = pointer,
		)
	return trackinfo

/datum/computer_file/program/radar/fission360/scan()
	if(world.time < next_scan)
		return
	next_scan = world.time + (2 SECONDS)
	objects = list()
	for(var/i in GLOB.nuke_list)
		var/obj/machinery/nuclearbomb/nuke = i
		if(!trackable(nuke))
			continue

		var/list/nukeinfo = list(
			ref = REF(nuke),
			name = nuke.name,
			)
		objects += list(nukeinfo)
	var/obj/item/disk/nuclear/disk = locate() in GLOB.poi_list
	if(trackable(disk))
		var/list/nukeinfo = list(
			ref = REF(disk),
			name = disk.name,
			)
		objects += list(nukeinfo)
