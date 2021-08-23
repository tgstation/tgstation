SUBSYSTEM_DEF(nightshift)
	name = "Night Shift"
	wait = 10 MINUTES

	var/nightshift_active = FALSE
	var/nightshift_start_time = 702000 //7:30 PM, station time
	var/nightshift_end_time = 270000 //7:30 AM, station time
	var/nightshift_first_check = 30 SECONDS

	var/high_security_mode = FALSE
	var/list/currentrun

/datum/controller/subsystem/nightshift/Initialize()
	if(!CONFIG_GET(flag/enable_night_shifts))
		can_fire = FALSE
	return ..()

/datum/controller/subsystem/nightshift/fire(resumed = FALSE)
	if(resumed)
		update_nightshift(resumed = TRUE)
		return
	if(world.time - SSticker.round_start_time < nightshift_first_check)
		return
	check_nightshift()

/datum/controller/subsystem/nightshift/proc/announce(message)
	priority_announce(message, sound='sound/misc/notice2.ogg', sender_override="Weather Update")

/datum/controller/subsystem/nightshift/proc/check_nightshift()
	var/emergency = SSsecurity_level.current_level >= SEC_LEVEL_RED
	var/announcing = TRUE
	var/time = station_time()
	var/night_time = (time < nightshift_end_time) || (time > nightshift_start_time)
	if(high_security_mode != emergency)
		high_security_mode = emergency
		if(night_time)
			announcing = FALSE
			if(!emergency)
				announce("Restoring night lighting configuration to normal operation.")
			else
				announce("Disabling night lighting: Station is in a state of emergency.")
	if(emergency)
		night_time = FALSE
	if(nightshift_active != night_time)
		update_nightshift(night_time, announcing)

GLOBAL_VAR(thingling_storm)

/datum/controller/subsystem/nightshift/proc/update_nightshift(active, announce = TRUE, resumed = FALSE)
	if(!resumed)
		currentrun = GLOB.apcs_list.Copy()
		nightshift_active = active
		if(active)
			if(announce)
				announce("Night falls. Deadly temperatures will kill anyone left outside until the sun rises and the storms calm.")
			update_lumcount(DYNAMIC_LIGHTING_ENABLED) //zero, total dorkness
			GLOB.thingling_storm = SSweather.run_weather(/datum/weather/snow_storm, SSmapping.levels_by_trait(ZTRAIT_STATION))
		else
			if(announce)
				announce("The sun has risen. The outside is now safe to travel in, if you have proper equipment.")
			update_lumcount(DYNAMIC_LIGHTING_DISABLED) //fullbright
			var/datum/weather/ending_this_storm = GLOB.thingling_storm
			ending_this_storm?.wind_down()
	for(var/obj/machinery/power/apc/APC as anything in currentrun)
		currentrun -= APC
		if (APC.area && (APC.area.type in GLOB.the_station_areas))
			APC.set_nightshift(active)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/nightshift/proc/update_lumcount(new_lighting)
	var/area/outside = get_area_instance_from_text(/area/icemoon/surface/outdoors)
	outside.set_dynamic_lighting(new_lighting)
	var/area/tcomms = get_area_instance_from_text(/area/tcommsat/server)
	tcomms.set_dynamic_lighting(new_lighting)
