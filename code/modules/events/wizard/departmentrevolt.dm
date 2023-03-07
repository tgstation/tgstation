
#define RANDOM_DEPARTMENT "Random Department"

/datum/round_event_control/wizard/deprevolt //stationwide!
	name = "Departmental Uprising"
	weight = 0 //An order that requires order in a round of chaos was maybe not the best idea. Requiescat in pace departmental uprising August 2014 - March 2015 //hello motherfucker i fixed your shit in 2021
	typepath = /datum/round_event/wizard/deprevolt
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "A department is turned into an independent state."
	admin_setup = list(
		/datum/event_admin_setup/listed_options/departmental_revolt,
		/datum/event_admin_setup/question/departmental_revolt_annouce,
		/datum/event_admin_setup/question/departmental_revolt_dangerous
	)

/datum/round_event/wizard/deprevolt
	///which department is revolting?
	var/datum/job_department/picked_department
	/// Announce the separatist nation to the round?
	var/announce = FALSE
	/// Is it going to try fighting other nations?
	var/dangerous_nation = TRUE

/datum/round_event/wizard/deprevolt/start()
	// no setup needed, this proc handles empty values. God i'm good (i wrote all of this)
	create_separatist_nation(picked_department, announce, dangerous_nation)

///which department is revolting?
/datum/event_admin_setup/listed_options/departmental_revolt
	input_text = "Which department should revolt?"
	normal_run_option = "Random"

/datum/event_admin_setup/listed_options/departmental_revolt/get_list()
	return subtypesof(/datum/job_department)
	
/datum/event_admin_setup/listed_options/departmental_revolt/apply_to_event(datum/round_event/wizard/deprevolt/event)
	event.picked_department = chosen

/// Announce the separatist nation to the round?
/datum/event_admin_setup/question/departmental_revolt_annouce
	input_text = "Announce This New Independent State?"

/datum/event_admin_setup/question/departmental_revolt_annouce/apply_to_event(datum/round_event/wizard/deprevolt/event)
	event.announce = chosen

/// Is it going to try fighting other nations?
/datum/event_admin_setup/question/departmental_revolt_dangerous
	input_text = "Dangerous Nation? This means they will fight other nations."

/datum/event_admin_setup/question/departmental_revolt_dangerous/apply_to_event(datum/round_event/wizard/deprevolt/event)
	event.dangerous_nation = chosen

#undef RANDOM_DEPARTMENT
