//An alarm event in an area
//there is one alarm of a given type to any given area (by name)
//it may have a list of cameras assigned, representing cameras in the vicinity
//of that alarm (usually)
//one alarm may have multiple source objects that triggered the alarm
//alarms will trigger function calls on alarm listener datums in response to certain events

//See also (code/__DEFINES/alerts.dm, code/_globalvars/lists/alerts.dm)
/datum/alarm
	var/alarm_type
	var/area/trigger_area
	var/list/cameras
	var/list/sources

/datum/alarm/New(alarm_type, area/src_area, list/new_cameras, obj/source)
	. = ..()
	trigger_area = src_area
	alarm_type = alarm_type

	if(!LAZYACCESS(sources, source))
		LAZYADD(sources, source)

	for (var/C in new_cameras)
		if(!LAZYACCESS(cameras, C))
			LAZYADD(cameras, C)

	//Add to active alarms list
	var/list/alarms_of_type = GLOB.alarms[alarm_type]
	alarms_of_type.Add(src)

	//Now notify listeners of new alarm creation
	var/list/AL = GLOB.alarm_listeners[alarm_type]
	for(var/datum/alarm_listener/L in AL)
		if( L.event_types & ALARM_CREATED )
			L.alarm_created(src)

/datum/alarm/Destroy()
	//Remove from active alarms list, important to do this first
	//since listeners use these lists to get active alarms for
	//display in ui's etc
	var/list/alarms_of_type = GLOB.alarms[alarm_type]
	alarms_of_type.Remove(src)

	//notify listeners cancelled before destroying
	var/list/AL = GLOB.alarm_listeners[alarm_type]
	for(var/datum/alarm_listener/L in AL)
		if( L.event_types & ALARM_CANCELLED )
			L.alarm_cancelled(src)

	//Cleanup
	trigger_area = null
	alarm_type = null
	LAZYCLEARLIST(cameras)
	LAZYCLEARLIST(sources)
	. = ..()

/datum/alarm/proc/addSource(obj/source, list/new_cameras)
	. = TRUE

	if(!LAZYACCESS(sources, source))
		LAZYADD(sources, source)

	//A list of cameras for a given source is only ever added once, this is weird but okay?
	if(LAZYLEN(cameras) <= 0)
		for(var/C in new_cameras)
			if(!LAZYACCESS(cameras, C))
				LAZYADD(cameras, C)

	var/list/AL = GLOB.alarm_listeners[alarm_type]
	for(var/datum/alarm_listener/L in AL)
		if( L.event_types & ALARM_SOURCE_ADDED )
			L.alarm_source_added(src, source)

/datum/alarm/proc/cancelSource(source)
	LAZYREMOVE(sources, source)
	var/list/AL = GLOB.alarm_listeners[alarm_type]
	for(var/datum/alarm_listener/L in AL)
		if( L.event_types & ALARM_SOURCE_REMOVED )
			L.alarm_source_removed(src, source)
	//NO sources left, tell the alarm code to cancel this alert
	return LAZYLEN(sources) <= 0

/proc/triggerAlarm(alarm_type, area/src_area, list/cameras, obj/source)
	var/datum/alarm/A = getAlarm(alarm_type, src_area)
	if(A)
		return A.addSource(source, cameras)
	else
		//New alarm woop woop, back that ass up
		A = new /datum/alarm(alarm_type, src_area, cameras, source)
		return TRUE

/proc/cancelAlarm(type, area/src_area, obj/source)
	var/datum/alarm/A = getAlarm(type, src_area)
	if(A)
		. = A.cancelSource(source)
		if(.)
			qdel(A)

/proc/getAlarm(type, area/src_area)
	var/list/potential_alarms = GLOB.alarms[type]
	var/datum/alarm/A = potential_alarms[src_area.name]
	return A

//Registers itself on a global list of listeners for alarm alerts
//the following events can be listend for
//alarm_source_removed
//alarm_source_added
//alarm_cancelled
//alarm_created
//you can also specify if you listen across z levels
/datum/alarm_listener
	var/atom/caller //Our owner
	var/event_types //The types of events we get a trigger for (bitflag)
	var/alert_types //The types of alerts we listen too
	var/cross_z = FALSE //Does this trigger on events on a different Z level?

/datum/alarm_listener/New(atom/C, list/types, event_types, cross_z = FALSE)
	. = ..()
	for(var/type in types)
		var/list/listeners = GLOB.alarm_listeners[type]
		listeners.Add(src)
	alert_types = types
	caller = C

/datum/alarm_listener/Destroy()
	caller = null
	for(var/type in alert_types)
		var/list/listeners = GLOB.alarm_listeners[type]
		listeners.Remove(src)
	. = ..()

//Some basic ass alert functionality
/datum/alarm_listener/proc/alarm_source_removed(datum/alarm/A, obj/source)
	to_chat(caller, "--- [A.type] alarm source [source.name] removed in [A.trigger_area.name] ---")

/datum/alarm_listener/proc/alarm_source_added(datum/alarm/A, obj/source)
	to_chat(caller, "--- [A.type] alarm source [source.name] added in [A.trigger_area.name] ---")

/datum/alarm_listener/proc/alarm_created(datum/alarm/A)
	to_chat(caller, "--- [A.type] alarm detected in [A.trigger_area.name] ---")

/datum/alarm_listener/proc/alarm_cancelled(datum/alarm/A)
	to_chat(caller, "--- [A.type] alarm in [A.trigger_area.name] has been cleared ---")

/datum/alarm_listener/computer/alarm_created(datum/alarm/A)
	caller.update_alarm_display()

/datum/alarm_listener/computer/alarm_cancelled(datum/alarm/A)
	caller.update_alarm_display()

/datum/alarm_listener/computer/get_data_for_ui()
	var/alarms = list()
	for(var/type in alert_types)
		alarms[type] = list()
		var/list/alarms_of_type = GLOB.alarms[type]
		for(var/datum/alarm/A in alarms_of_type)
			alarms[type] += A.trigger_area
	return data
