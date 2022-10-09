/datum/round_event_control/wizard/deprevolt //stationwide!
	name = "Departmental Uprising"
	weight = 0 //An order that requires order in a round of chaos was maybe not the best idea. Requiescat in pace departmental uprising August 2014 - March 2015 //hello motherfucker i fixed your shit in 2021
	typepath = /datum/round_event/wizard/deprevolt
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "A department is turned into an independent state."

	///manual choice of what department to revolt for admins to pick
	var/datum/job_department/picked_department
	///admin choice on whether to announce the department
	var/announce = FALSE
	///admin choice on whether this nation will have objectives to attack other nations, default true for !fun!
	var/dangerous_nation = TRUE

/datum/round_event_control/wizard/deprevolt/admin_setup(mob/admin)
	if(!check_rights(R_FUN))
		return

	var/list/options = list()
	var/list/pickable_departments = subtypesof(/datum/job_department)
	for(var/datum/job_department/dep as anything in pickable_departments)
		options[initial(dep.department_name)] = dep
	picked_department = options[(input(usr,"Which department should revolt? Select none for a random department.","Select a department") as null|anything in options)]
	if(!picked_department)
		return //eh just random they dont care

	var/announce_question = tgui_alert(usr, "Announce This New Independent State?", "Secession", list("Announce", "No Announcement"))
	if(announce_question == "Announce")
		announce = TRUE

	var/dangerous_question = tgui_alert(usr, "Dangerous Nation? This means they will fight other nations.", "Conquest", list("Yes", "No"))
	if(dangerous_question == "No")
		dangerous_nation = FALSE

/datum/round_event/wizard/deprevolt/start()
	var/datum/round_event_control/wizard/deprevolt/event_control = control
	create_separatist_nation(event_control.picked_department, event_control.announce, event_control.dangerous_nation)
