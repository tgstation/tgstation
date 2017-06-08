//An alarm event in an area
//there is one alarm of a given type to any given area (by name)
//it may have a list of cameras assigned, representing cameras in the vicinity
//of that alarm (usually)
//one alarm may have multiple source objects that triggered the alarm
//alarms will trigger function calls on alarm listener datums in response to certain events
/datum/alarm
	var/type
	var/Area/area
	var/list/cameras
	var/list/sources

/datum/alarm/Initialize(mapload, type, src_area, new_cameras, source)
	. = ..()
	area = src_area
	type = type
	if(!LAZYACCESS(sources, source))
		LAZYADD(sources, source)
	for var/C in new_cameras
		if(!LAZYACCESS(cameras, C))
			LAZYADD(cameras, C)

	for datum/alarm_listener/L in GLOB.alarm_listeners[type]
		if( L.event_types & ALARM_CREATED )
			L.alarm_created(src)
	
/datum/alarm/Destroy()
	area = null
	type = null
	LAZYCLEARLIST(cameras)
	LAZYCLEARLIST(sources)
	for datum/alarm_listener/L in GLOB.alarm_listeners[type]
		if( L.event_types & ALARM_CREATED )
			L.alarm_cancelled(src)
	. = ..()

/datum/alarm/proc/addSource(obj/source, list/new_cameras)
	if(!LAZYACCESS(sources, source))
		LAZYADD(sources, source)

	//A list of cameras for a given source is only ever added once, this is weird but okay?
	if(LAZYLEN(cameras) <= 0)
		for var/C in new_cameras
			if(!LAZYACCESS(cameras, C))
				LAZYADD(cameras, C)

	for datum/alarm_listener/L in GLOB.alarm_listeners[type]
		if( L.event_types & ALARM_SOURCE_ADDED )
			L.alarm_source_added(src, source)

/datum/alarm/proc/cancelSource(source)
	LAZYREMOVE(sources, source)
	for datum/alarm_listener/L in GLOB.alarm_listeners[type]
		if( L.event_types & ALARM_SOURCE_REMOVED )
			L.alarm_source_removed(src, source)
	//NO sources left, tell the alarm code to cancel this alert
	return LAZYLEN(sources) <= 0


/proc/triggerAlarm(type, area/src_area, list/cameras, obj/source)
	var/datum/alarm/A = getAlarm(type, src_area)
	if(A)
		return A.addSource(source, cameras)
	else
		return createAlarm(type, src_area, cameras, obj/source)

/proc/cancelAlarm(type, area/src_area, obj/source)
	var/datum/alarm/A = getAlarm(type, src_area)
	if(A)
		//may cancel Alarm completely
		A.cancelSource(source)

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

/datum/alarm_listener/Initialize(mapload, atom/C, list/types, event_types, cross_z = FALSE)
	. = ..()
	for var/type in types
		var/listeners = GLOB.alarm_listeners[type]
		listeners.Add(src)
	alert_types = types
	caller = C

/datum/alarm_listener/Destroy()
	c = null
	for var/type in alert_types
		var/listeners = GLOB.alarm_listeners[type]
		listeners.Remove(src)
	. = ..()

//Some basic ass alert functionality
/datum/alarm_listener/proc/alarm_source_removed(datum/alarm/A, obj/source)
	to_chat(caller, "--- [A.type] alarm source [source.name] removed in [A.area.name] ---")

/datum/alarm_listener/proc/alarm_source_added(datum/alarm/A, obj/source)
	to_chat(caller, "--- [A.type] alarm source [source.name] added in [A.area.name] ---")

/datum/alarm_listener/proc/alarm_created(datum/alarm/A)
	to_chat(caller, "--- [A.type] alarm detected in [A.area.name] ---")

s
sw
/datum/alarm_listener/proc/alarm_cancelled(datum/alarm/A)
	to_chat(caller, "--- [A.type] alarm in [A.area.name] ha-s been cleared -")

/datum/alarm_listener/ai
	var/mob/living/silicon/caller //todo test this works?
