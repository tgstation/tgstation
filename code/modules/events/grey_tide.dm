/datum/round_event_control/grey_tide
	name = "Grey Tide"
	typepath = /datum/round_event/grey_tide
	max_occurrences = 2
	min_players = 5
	category = EVENT_CATEGORY_ENGINEERING
	description = "Bolts open all doors in one or more departments."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 7

/datum/round_event/grey_tide
	announce_when = 50
	end_when = 20
	///The number of areas to be hit by the event.
	var/severity = 1
	///The area subtypes to be targeted by the event.
	var/list/grey_tide_areas = list()

/datum/round_event/grey_tide/setup()
	announce_when = rand(50, 60)
	end_when = rand(20, 30)
	severity = rand(1,3)

	var/list/potential_areas = list(/area/station/command,
		/area/station/engineering,
		/area/station/medical,
		/area/station/security,
		/area/station/cargo,
		/area/station/science,
	)

	for(var/i in 1 to severity)
		grey_tide_areas += pick_n_take(potential_areas)

/datum/round_event/grey_tide/announce(fake)
	if(fake)
		severity = rand(1,3)
	priority_announce("Gr3y.T1d3 virus detected in [station_name()] secure locking encryption subroutines. Severity level of [severity]. Recommend station AI involvement.", "Security Alert")

/datum/round_event/grey_tide/start()
	if(!length(grey_tide_areas))
		stack_trace("Could not initiate grey-tide. No areas in the list!")
		kill()

/datum/round_event/grey_tide/tick()
	if(!ISMULTIPLE(activeFor, 12))
		return

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_GREY_TIDE_LIGHT, grey_tide_areas)

// Objects currently impacted by the greytide event:
// /obj/machinery/door/airlock -- Signal bolts open the door
// /obj/machinery/status_display/door_timer -- Signal instantly ends the timer, releasing the occupant
// /obj/structure/closet/secure_closet -- Signal unlocks locked lockers
// /obj/machinery/power/apc -- Signal turns the lighting channel off

/datum/round_event/grey_tide/end()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_GREY_TIDE, grey_tide_areas)
