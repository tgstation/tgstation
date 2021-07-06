///Represents a single source of alerts, one alert handler will only ever count for one alert per listener
/datum/alert_handler
	///A list of alert type -> list of area names we currently have alerts in
	var/list/sent_alerts = list()
	///Our source atom
	var/atom/source_atom

/datum/alert_handler/New(atom/_source_atom)
	if(istype(_source_atom))
		source_atom = _source_atom
	else
		var/source_type = ""
		if(istype(_source_atom, /datum))
			source_type = _source_atom.type
		stack_trace("a non atom was passed into alert_handler! [_source_atom] [source_type]")
	return ..()

/datum/alert_handler/Destroy()
	for(var/alert_type in sent_alerts)
		for(var/area/area_to_clear in sent_alerts[alert_type])
			//Yeet all connected alerts
			clear_alert_from_area(alert_type, area_to_clear)
	source_atom = null
	return ..()

///Sends an alert to any interested things, does some checks to prevent unneeded work
///Important to note is that source_atom is not held as a ref, we're used as a proxy to prevent hard deletes
///optional_camera should only be used when you have one camera you want to pass along to alert listeners, most of the time you should have no use for it
/datum/alert_handler/proc/send_alert(alert_type, atom/use_as_source_atom = source_atom, optional_camera)
	if(!use_as_source_atom)
		return

	var/area/our_area = get_area(use_as_source_atom)
	var/our_z_level = use_as_source_atom.z

	if (our_area.area_flags & NO_ALERTS)
		return FALSE

	var/list/existing_alerts = sent_alerts[alert_type]
	if(existing_alerts)
		if(our_area in existing_alerts)
			return FALSE
	else
		sent_alerts[alert_type] = list()
		existing_alerts = sent_alerts[alert_type]

	existing_alerts += our_area

	our_area.active_alarms[alert_type] += 1

	SEND_GLOBAL_SIGNAL(COMSIG_ALERT_FIRE(alert_type), src, alert_type, our_area, our_z_level, optional_camera)

	return TRUE

///Clears an alert from any interested listeners
/datum/alert_handler/proc/clear_alert(alert_type, use_as_source_atom = source_atom)
	if(!use_as_source_atom)
		return

	var/area/our_area = get_area(use_as_source_atom)
	return clear_alert_from_area(alert_type, our_area)

///Exists so we can request that the alerts from an area are cleared, even if our source atom is no longer in that area
/datum/alert_handler/proc/clear_alert_from_area(alert_type, area/our_area)
	if (our_area.area_flags & NO_ALERTS)
		return FALSE

	var/list/existing_alerts = sent_alerts[alert_type]
	if(!existing_alerts)
		return FALSE

	if(!(our_area in existing_alerts))
		return FALSE

	existing_alerts -= our_area
	if(!length(existing_alerts))
		sent_alerts -= alert_type

	our_area.active_alarms[alert_type] -= 1
	if(!length(our_area.active_alarms))
		our_area.active_alarms -= alert_type

	SEND_GLOBAL_SIGNAL(COMSIG_ALERT_CLEAR(alert_type), src, alert_type, our_area)
	return TRUE

/datum/alert_listener
	///List of valid source z levels, ignored if null
	var/list/allowed_z_levels
	///List of allowed areas. if this is null it's ignored
	var/list/allowed_areas

	///List of alert type -> list of area name -> list(area, ref to area's cameras, list(sources))
	var/list/alarms = list()
	///Should we allow alert changes to go through or not
	var/accepting_alert_changes = TRUE

///Accepts a list of alert types to pay attention to, a list of valid z levels, and a list of valid areas. areas and zlevels are ignored if null
/datum/alert_listener/New(_alerts_to_listen_for, _allowed_z_levels, _allowed_areas)
	allowed_z_levels = _allowed_z_levels
	allowed_areas = _allowed_areas
	for(var/alert_type in _alerts_to_listen_for)
		RegisterSignal(SSdcs, COMSIG_ALERT_FIRE(alert_type), .proc/add_alert)
		RegisterSignal(SSdcs, COMSIG_ALERT_CLEAR(alert_type), .proc/clear_alert)

	return ..()

///Adds an alert to our alarms list, you probobly shouldn't be calling this manually
/datum/alert_listener/proc/add_alert(datum/source, datum/alert_handler/handler, alert_type, area/source_area, source_z, optional_camera)
	if (!accepting_alert_changes)
		return

	if(allowed_z_levels && !(source_z in allowed_z_levels))
		return

	if(allowed_areas && !(source_area.type in allowed_areas))
		return

	var/list/alerts_of_our_type = alarms[alert_type]
	if(!alerts_of_our_type)
		alarms[alert_type] = list()
		alerts_of_our_type = alarms[alert_type]

	if(alerts_of_our_type[source_area.name])
		var/list/alarm = alerts_of_our_type[source_area.name]
		var/list/sources = alarm[3]
		sources |= handler
		//Return if a source already exists, we don't want to send a signal or add a new entry
		return

	//We normally directly pass in a ref to the area's camera's list to prevent hanging refs
	var/list/cameras = source_area.cameras
	if(optional_camera)
		cameras = list(optional_camera) // This will cause harddels, so we need to clear manually
		RegisterSignal(optional_camera, COMSIG_PARENT_QDELETING, .proc/clear_camera_ref, override = TRUE) //It's just fine to override, cause we clear all refs in the proc

	//This does mean that only the first alert of that camera type in the area will send a ping, but jesus what else can ya do
	alerts_of_our_type[source_area.name] = list(source_area, cameras, list(handler))
	SEND_SIGNAL(src, COMSIG_ALERT_TRIGGERED, alert_type, source_area)

///Removes an alert to our alarms list, you probobly shouldn't be calling this manually
/datum/alert_listener/proc/clear_alert(datum/source, datum/alert_handler/handler, alert_type, area/source_area)
	if(!accepting_alert_changes)
		return

	var/list/alerts_of_our_type = alarms[alert_type]

	if(!alerts_of_our_type)
		return

	if(!alerts_of_our_type[source_area.name])
		return

	var/list/alarm = alerts_of_our_type[source_area.name]
	var/list/sources  = alarm[3]
	sources -= handler

	if (length(sources))
		return //Return if there's still sources left, no sense clearing the list or bothering anyone about it

	alerts_of_our_type -= source_area.name
	SEND_SIGNAL(src, COMSIG_ALERT_CLEARED, alert_type, source_area)

///Does what it says on the tin, exists for signal hooking
/datum/alert_listener/proc/prevent_alert_changes()
	SIGNAL_HANDLER
	accepting_alert_changes = FALSE

///Does what it says on the tin, exists for signal hooking
/datum/alert_listener/proc/allow_alert_changes()
	SIGNAL_HANDLER
	accepting_alert_changes = TRUE

///Used to manually clear camera refs if one is ref'd directly
/datum/alert_listener/proc/clear_camera_ref(obj/machinery/camera/source)
	var/list/alerts = alarms  //Cache for sonic speec
	for(var/alert_type in alerts)
		var/list/alarms_of_type = alerts[alert_type] //Sonic cache speed forads
		for(var/area_name as anything in alarms_of_type)
			var/list/alert_packet = alarms_of_type[area_name]
			var/list/cameras = alert_packet[2]
			cameras -= source // REF FOUND AND CLEARED BOYSSSS
