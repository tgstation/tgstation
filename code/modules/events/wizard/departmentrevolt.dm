
#define RANDOM_DEPARTMENT "Random Department"

/datum/round_event_control/wizard/deprevolt //stationwide!
	name = "Departmental Uprising"
	weight = 0 //An order that requires order in a round of chaos was maybe not the best idea. Requiescat in pace departmental uprising August 2014 - March 2015 //hello motherfucker i fixed your shit in 2021
	typepath = /datum/round_event/wizard/deprevolt
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "A department is turned into an independent state."
	admin_setup = /datum/event_admin_setup/department_revolt

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

/datum/event_admin_setup/department_revolt
	///which department is revolting?
	var/datum/job_department/picked_department
	/// Announce the separatist nation to the round?
	var/announce = FALSE
	/// Is it going to try fighting other nations?
	var/dangerous_nation = TRUE

/datum/event_admin_setup/department_revolt/prompt_admins()
	var/list/options = list("Random" = RANDOM_DEPARTMENT)
	var/list/pickable_departments = subtypesof(/datum/job_department)
	for(var/datum/job_department/dep as anything in pickable_departments)
		options[initial(dep.department_name)] = dep
	picked_department = options[(tgui_input_list(usr,"Which department should revolt? Select none for a random department.","Select a department", options))]
	if(!picked_department)
		return ADMIN_CANCEL_EVENT
	if(picked_department == RANDOM_DEPARTMENT)
		picked_department = null
		return

	var/announce_question = tgui_alert(usr, "Announce This New Independent State?", "Secession", list("Announce", "No Announcement"))
	if(announce_question == "Announce")
		announce = TRUE

	var/dangerous_question = tgui_alert(usr, "Dangerous Nation? This means they will fight other nations.", "Conquest", list("Yes", "No"))
	if(dangerous_question == "No")
		dangerous_nation = FALSE

/datum/event_admin_setup/department_revolt/apply_to_event(datum/round_event/wizard/deprevolt/event)
	event.picked_department = picked_department
	event.announce = announce
	event.dangerous_nation = dangerous_nation

#undef RANDOM_DEPARTMENT
