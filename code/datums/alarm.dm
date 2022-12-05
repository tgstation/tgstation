//This files deals with the generic sending and receiving of "alarms"
//This is a somewhat blanket term, it covers things like fire/power/atmos alarms, along with some oddballs
//Side effect of how the system is used, these are mostly things that are of interest to ais and borgs
//Though it could easily be expanded to cover other senders/revievers
//The system as a whole differs from reading off a global list in a few ways.
//In that A, it allows us to send cameras for ais/borgs/potentially others to jump to
//And B, it's not like we're giving you all the alarms that have been sent, because of the separate listing for each reviever
//You only receive alarms sent after you start to listen
//Also of note, due to an optimization done on areas, one alarm handler will only ever send one "on" or "off" alarm
//So the whole only receiving stuff sent post creation thing actually matters
//Honestly I'm not sure how much of this is a feature, and how much is just old code
//But I'm leaving it how I found it

///Represents a single source of alarms, one alarm handler will only ever count for one alarm per listener
/datum/alarm_handler
	///A list of alarm type -> list of areas we currently have alarms in
	var/list/sent_alarms = list()
	///Our source atom
	var/atom/source_atom

/datum/alarm_handler/New(atom/source_atom)
	if(istype(source_atom))
		src.source_atom = source_atom
	else
		var/source_type = (isdatum(source_atom)) ? source_atom.type : ""
		stack_trace("a non atom was passed into alarm_handler! [source_atom] [source_type]")
	return ..()

/datum/alarm_handler/Destroy()
	for(var/alarm_type in sent_alarms)
		for(var/area/area_to_clear as anything in sent_alarms[alarm_type])
			//Yeet all connected alarms
			clear_alarm_from_area(alarm_type, area_to_clear)
	source_atom = null
	return ..()

///Sends an alarm to any interested things, does some checks to prevent unneeded work
///Important to note is that source_atom is not held as a ref, we're used as a proxy to prevent hard deletes
///optional_camera should only be used when you have one camera you want to pass along to alarm listeners, most of the time you should have no use for it
/datum/alarm_handler/proc/send_alarm(alarm_type, atom/use_as_source_atom, optional_camera)
	if(!use_as_source_atom)
		use_as_source_atom = source_atom
	if(!use_as_source_atom)
		return

	var/area/our_area = get_area(use_as_source_atom)
	var/our_z_level = use_as_source_atom.z

	var/list/existing_alarms = sent_alarms[alarm_type]
	if(existing_alarms)
		if(our_area in existing_alarms)
			return FALSE
	else
		sent_alarms[alarm_type] = list()
		existing_alarms = sent_alarms[alarm_type]

	existing_alarms += our_area

	our_area.active_alarms[alarm_type] += 1

	SEND_SIGNAL(src, COMSIG_ALARM_TRIGGERED, alarm_type, our_area)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ALARM_FIRE(alarm_type), src, alarm_type, our_area, our_z_level, optional_camera)

	return TRUE

///Clears an alarm from any interested listeners
/datum/alarm_handler/proc/clear_alarm(alarm_type, use_as_source_atom)
	SIGNAL_HANDLER
	if(!use_as_source_atom)
		use_as_source_atom = source_atom
	if(!use_as_source_atom)
		return

	return clear_alarm_from_area(alarm_type, get_area(use_as_source_atom))

///Exists so we can request that the alarms from an area are cleared, even if our source atom is no longer in that area
/datum/alarm_handler/proc/clear_alarm_from_area(alarm_type, area/our_area)

	var/list/existing_alarms = sent_alarms[alarm_type]
	if(!existing_alarms)
		return FALSE

	if(!(our_area in existing_alarms))
		return FALSE

	existing_alarms -= our_area
	if(!length(existing_alarms))
		sent_alarms -= alarm_type

	our_area.active_alarms[alarm_type] -= 1
	if(!length(our_area.active_alarms))
		our_area.active_alarms -= alarm_type

	SEND_SIGNAL(src, COMSIG_ALARM_CLEARED, alarm_type, our_area)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ALARM_CLEAR(alarm_type), src, alarm_type, our_area)
	return TRUE

/datum/alarm_listener
	///List of valid source z levels, ignored if null
	var/list/allowed_z_levels
	///List of allowed areas. if this is null it's ignored
	var/list/allowed_areas

	///List of alarm type -> list of area name -> list(area, ref to area's cameras, list(sources))
	var/list/alarms = list()
	///Should we allow alarm changes to go through or not
	var/accepting_alarm_changes = TRUE

///Accepts a list of alarm types to pay attention to, a list of valid z levels, and a list of valid areas. areas and zlevels are ignored if null
/datum/alarm_listener/New(alarms_to_listen_for, allowed_z_levels, allowed_areas)
	src.allowed_z_levels = allowed_z_levels
	src.allowed_areas = allowed_areas
	for(var/alarm_type in alarms_to_listen_for)
		RegisterSignal(SSdcs, COMSIG_GLOB_ALARM_FIRE(alarm_type), PROC_REF(add_alarm))
		RegisterSignal(SSdcs, COMSIG_GLOB_ALARM_CLEAR(alarm_type), PROC_REF(clear_alarm))

	return ..()

///Adds an alarm to our alarms list, you shouldn't be calling this manually
///It should all be handled by the signal listening we do, unless you want to only send an alarm to one listener
/datum/alarm_listener/proc/add_alarm(datum/source, datum/alarm_handler/handler, alarm_type, area/source_area, source_z, optional_camera)
	SIGNAL_HANDLER

	if (!accepting_alarm_changes)
		return

	if(allowed_z_levels && !(source_z in allowed_z_levels))
		return

	if(allowed_areas && !(source_area.type in allowed_areas))
		return

	var/list/alarms_of_our_type = alarms[alarm_type]
	if(!alarms_of_our_type)
		alarms[alarm_type] = list()
		alarms_of_our_type = alarms[alarm_type]

	if(alarms_of_our_type[source_area.name])
		var/list/alarm = alarms_of_our_type[source_area.name]
		var/list/sources = alarm[3]
		sources |= handler
		//Return if a source already exists, we don't want to send a signal or add a new entry
		return

	//We normally directly pass in a ref to the area's camera's list to prevent hanging refs
	var/list/cameras = source_area.cameras
	if(optional_camera)
		cameras = list(optional_camera) // This will cause harddels, so we need to clear manually
		RegisterSignal(optional_camera, COMSIG_PARENT_QDELETING, PROC_REF(clear_camera_ref), override = TRUE) //It's just fine to override, cause we clear all refs in the proc

	//This does mean that only the first alarm of that camera type in the area will send a ping, but jesus what else can ya do
	alarms_of_our_type[source_area.name] = list(source_area, cameras, list(handler))
	SEND_SIGNAL(src, COMSIG_ALARM_LISTENER_TRIGGERED, alarm_type, source_area)

///Removes an alarm to our alarms list, you probably shouldn't be calling this manually
///It should all be handled by the signal listening we do, unless you want to only remove an alarm to one listener
/datum/alarm_listener/proc/clear_alarm(datum/source, datum/alarm_handler/handler, alarm_type, area/source_area)
	SIGNAL_HANDLER

	if(!accepting_alarm_changes)
		return

	var/list/alarms_of_our_type = alarms[alarm_type]

	if(!alarms_of_our_type)
		return

	if(!alarms_of_our_type[source_area.name])
		return

	var/list/alarm = alarms_of_our_type[source_area.name]
	var/list/sources = alarm[3]
	sources -= handler

	if (length(sources))
		return //Return if there's still sources left, no sense clearing the list or bothering anyone about it

	alarms_of_our_type -= source_area.name

	if(!length(alarms_of_our_type))
		alarms -= alarm_type

	SEND_SIGNAL(src, COMSIG_ALARM_LISTENER_CLEARED, alarm_type, source_area)

///Does what it says on the tin, exists for signal hooking
/datum/alarm_listener/proc/prevent_alarm_changes()
	SIGNAL_HANDLER
	accepting_alarm_changes = FALSE

///Does what it says on the tin, exists for signal hooking
/datum/alarm_listener/proc/allow_alarm_changes()
	SIGNAL_HANDLER
	accepting_alarm_changes = TRUE

///Used to manually clear camera refs if one is ref'd directly
/datum/alarm_listener/proc/clear_camera_ref(obj/machinery/camera/source)
	SIGNAL_HANDLER
	var/list/alarms_cache = alarms  //Cache for sonic speec
	for(var/alarm_type in alarms_cache)
		var/list/alarms_of_type = alarms_cache[alarm_type] //Sonic cache speed forads
		for(var/area_name as anything in alarms_of_type)
			var/list/alarm_packet = alarms_of_type[area_name]
			var/list/cameras = alarm_packet[2]
			cameras -= source // REF FOUND AND CLEARED BOYSSSS
