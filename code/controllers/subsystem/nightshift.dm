SUBSYSTEM_DEF(nightshift)
	name = "Night Shift"
	wait = 600
	flags = SS_NO_TICK_CHECK

	var/nightshift_active = FALSE
	var/nightshift_start_time = 702000		//7:30 PM, station time
	var/nightshift_end_time = 270000		//7:30 AM, station time
	var/nightshift_first_check = 30 SECONDS

	var/obey_security_level = TRUE
	var/high_security_mode = FALSE

/datum/controller/subsystem/nightshift/Initialize()
	if(!CONFIG_GET(flag/enable_night_shifts))
		can_fire = FALSE
	return ..()

/datum/controller/subsystem/nightshift/fire(resumed = FALSE)
	if(world.time - SSticker.round_start_time < nightshift_first_check)
		return
	check_nightshift()

/datum/controller/subsystem/nightshift/proc/check_nightshift(force_set = FALSE)
	var/time = station_time()
	var/nightshift = time < nightshift_end_time || time > nightshift_start_time
	var/red_or_delta = GLOB.security_level == SEC_LEVEL_RED || GLOB.security_level == SEC_LEVEL_DELTA
	var/announcing = TRUE
	if(nightshift && red_or_delta)
		nightshift = FALSE
	if(high_security_mode && !red_or_delta)
		high_security_mode = FALSE
		priority_announce("Restoring night lighting configuration to normal operation.", sound='sound/misc/notice2.ogg', sender_override="Automated Lighting System Announcement")
		announcing = FALSE
	else if(!high_security_mode && red_or_delta)
		high_security_mode = TRUE
		priority_announce("Night lighting disabled: Station is in a state of emergency.", sound='sound/misc/notice2.ogg', sender_override="Automated Lighting System Announcement")
		announcing = FALSE

	if((nightshift_active != nightshift) || force_set)
		nightshift? activate_nightshift(announcing) : deactivate_nightshift(announcing)

/datum/controller/subsystem/nightshift/proc/activate_nightshift(announce = TRUE)
	if(!nightshift_active)
		if(announce)
			priority_announce("Good evening, crew. To reduce power consumption and stimulate the circadian rhythms of some species, all of the lights aboard the station have been dimmed for the night.", sound='sound/misc/notice2.ogg', sender_override="Automated Lighting System Announcement")
		nightshift_active = TRUE
	var/list/area/affected = return_nightshift_area_types()
	for(var/i in affected)
		var/area/A = locate(i) in GLOB.sortedAreas
		for(var/obj/machinery/power/apc/APC in A)
			APC.set_nightshift(TRUE)
			CHECK_TICK

/datum/controller/subsystem/nightshift/proc/deactivate_nightshift(announce = TRUE)
	if(nightshift_active)
		if(announce)
			priority_announce("Good morning, crew. As it is now day time, all of the lights aboard the station have been restored to their former brightness.", sound='sound/misc/notice2.ogg', sender_override="Automated Lighting System Announcement")
		nightshift_active = FALSE
	var/list/area/affected = return_nightshift_area_types()
	for(var/i in affected)
		var/area/A = locate(i) in GLOB.sortedAreas
		for(var/obj/machinery/power/apc/APC in A)
			APC.set_nightshift(FALSE)
			CHECK_TICK

/datum/controller/subsystem/nightshift/proc/return_nightshift_area_types()
	return GLOB.the_station_areas.Copy()
