/datum/round_event_control/grey_tide
	name = "Grey Tide"
	typepath = /datum/round_event/grey_tide
	max_occurrences = 2
	min_players = 5
	category = EVENT_CATEGORY_ENGINEERING
	description = "Bolts open all doors in one or more departments."

/datum/round_event/grey_tide
	announce_when = 50
	end_when = 20
	var/list/area/areas_to_open = list()
	var/severity = 1

/datum/round_event/grey_tide/setup()
	announce_when = rand(50, 60)
	end_when = rand(20, 30)
	severity = rand(1,3)

	var/list/potential_areas = list(/area/station/command,
								/area/station/engineering,
								/area/station/medical,
								/area/station/security,
								/area/station/cargo,
								/area/station/science)

	var/list/areas_affected = list() //The list of areas the admins will recieve

	for(var/i in 1 to severity)
		var/picked_area = pick_n_take(potential_areas)
		areas_affected += picked_area
		for(var/area/area_to_check as anything in GLOB.areas)
			if(istype(area_to_check, picked_area))
				areas_to_open += area_to_check

	message_admins("Grey Tide event has selected the following areas to open: [english_list(areas_affected)]") //This returns paths, not names. Trying to pull the area's name with .name doesn't work

/datum/round_event/grey_tide/announce(fake)
	priority_announce("Gr3y.T1d3 virus detected in [station_name()] secure locking encryption subroutines. Severity level of [severity]. Recommend station AI involvement.", "Security Alert") //It affects more than just doors!

/datum/round_event/grey_tide/start()
	if(!length(areas_to_open))
		log_world("ERROR: Could not initiate grey-tide. No areas in the list!")
		kill()

/datum/round_event/grey_tide/tick()
	if(ISMULTIPLE(activeFor, 12))
		for(var/area/area_to_open in areas_to_open)
			for(var/obj/machinery/light/chosen_light in area_to_open)
				chosen_light.flicker(10)

/datum/round_event/grey_tide/end()
	for(var/area/area_to_open in areas_to_open)
		for(var/obj/object_to_open in area_to_open)
			if(istype(object_to_open, /obj/structure/closet/secure_closet))
				var/obj/structure/closet/secure_closet/chosen_closet = object_to_open
				chosen_closet.locked = FALSE
				chosen_closet.update_appearance()
			else if(istype(object_to_open, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/chosen_airlock = object_to_open
				if(chosen_airlock.critical_machine) //Skip doors in critical positions, such as the SM chamber.
					continue
				chosen_airlock.prison_open()
			else if(istype(object_to_open, /obj/machinery/status_display/door_timer))
				var/obj/machinery/status_display/door_timer/prison_timer = object_to_open
				prison_timer.timer_end(forced = TRUE)
			else if(istype(object_to_open, /obj/machinery/power/apc)) //Escape (or sneak in) under the cover of darkness
				var/obj/machinery/power/apc/apc_to_trigger = object_to_open
				apc_to_trigger.lighting = APC_CHANNEL_OFF
				apc_to_trigger.update_appearance()
				apc_to_trigger.update()

