/**
 * ### create_separatist_nation_list()
 *
 * Creates all departments in a list as nations while giving them the objective to killeachother if set.
 * * Arguments:
 * * revolting_departments: list of departments that will revolt. Starts as a type, then turns into the reference to the singleton.
 * * announcement: whether to tell the station a department has gone independent.
 * * dangerous: whether the nation will have objectives to attack other independent nations.
 * * message_admins: whether this will admin log how the nation creation went. Errors are still put in runtime log either way.
 */
/proc/create_separatist_nation_list(list/revolting_departments, announcement = FALSE, dangerous = FALSE, message_admins = TRUE)
	var/datum/team/nation/created_teams = list()
	for(var/department_type in revolting_departments)
		created_teams += create_separatist_nation(department_type, announcement, message_admins)

	if(!created_teams.len || !dangerous)
		return

	//get a list of all independent nations to give objectives to attack eachother.
	var/list/independent_departments = list()
	for(var/datum/team/nation/nation_datum in GLOB.antagonist_teams)
		independent_departments |= nation_datum.department

	//get all teams we just made and give them the objectives to attack eachother, this excludes nations created elsewhere.
	for(var/datum/team/nation/created_departments in created_teams)
		created_departments.generate_nation_objectives(created_teams - created_departments)

/**
 * ### create_separatist_nation()
 *
 * Actually creates the Nation and returns it.
 *
 * * Arguments:
 * * department: which department to revolt. Starts as a type, then turns into the reference to the singleton.
 * * announcement: whether to tell the station a department has gone independent.
 * * message_admins: whether this will admin log how the nation creation went. Errors are still put in runtime log either way.
 */
/proc/create_separatist_nation(datum/job_department/department, announcement = FALSE, message_admins = TRUE)
	var/list/jobs_to_revolt = list()
	var/list/citizens = list()

	if(!department)
		//departments that are already independent, these will be disallowed to be randomly picked
		var/list/independent_departments = list()
		for(var/datum/team/nation/nation_datum in GLOB.antagonist_teams)
			independent_departments |= nation_datum.department

		//picks a random department if none was given
		department = pick(subtypesof(/datum/job_department) - independent_departments)
		if(!department)
			if(message_admins)
				message_admins("Department Revolt could not create a nation, as all the departments are independent! You have created nations, you madman!")
			CRASH("Department Revolt could not create a nation, as all the departments are independent")

	department = SSjob.get_department_type(department)

	for(var/datum/job/job as anything in department.department_jobs)
		if(job.departments_list.len > 1 && job.departments_list[1] != department.type) //their loyalty is in other departments
			continue
		jobs_to_revolt += job.title

	//setup team datum
	var/datum/team/nation/nation = new(jobs_to_revolt, department)
	nation.name = department.generate_nation_name()
	//convert current members of the department
	for(var/mob/living/carbon/human/possible_separatist as anything in GLOB.joined_player_list)
		if(!possible_separatist.mind)
			continue
		var/datum/mind/separatist_mind = possible_separatist.mind
		if(!(separatist_mind.assigned_role.title in jobs_to_revolt))
			continue
		citizens += possible_separatist
		separatist_mind.add_antag_datum(/datum/antagonist/separatist, nation, department)
		nation.add_member(separatist_mind)
		possible_separatist.log_message("was made into a separatist, long live [nation.name]!", LOG_ATTACK, color="red")

	//if we didn't convert anyone we just kill the team datum, otherwise cleanup and make official
	if(!citizens.len)
		qdel(nation)
		if(message_admins)
			message_admins("The nation of [nation.name] did not have enough potential members to be created.")
		return

	var/jobs_english_list = english_list(jobs_to_revolt)
	if(message_admins)
		message_admins("The nation of [nation.name] has been formed. Affected jobs are [jobs_english_list]. Any new crewmembers with these jobs will join the secession.")
	if(announcement)
		var/announce_text = "The new independent state of [nation.name] has formed from the ashes of the [department.department_name] department!"
		if(istype(department, /datum/job_department/assistant)) //the text didn't really work otherwise
			announce_text = "The assistants of the station have risen to form the new independent state of [nation.name]!"
		priority_announce(announce_text, "Secession from [GLOB.station_name]", has_important_message = TRUE)
	return nation
