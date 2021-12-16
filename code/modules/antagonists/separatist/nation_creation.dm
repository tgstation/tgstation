
/**
 * ### create_separatist_nation()
 *
 * Helper called to create the separatist antagonist via making a department independent from the station.
 *
 * * Arguments:
 * * department: which department to revolt. if null, will pick a random non-independent department. starts as a type, then turns into the reference to the singleton.
 * * announcement: whether to tell the station a department has gone independent.
 * * dangerous: whether this nation will have objectives to attack other independent departments, requires more than one nation to exist obviously
 *
 * Returns null if everything went well, otherwise a string describing what went wrong.
 */
/proc/create_separatist_nation(department, announcement = FALSE, dangerous = FALSE)

	var/list/jobs_to_revolt = list()
	var/nation_name
	var/list/citizens = list()

	///departments that are already independent with a reference to their nation, these will be disallowed to be randomly picked
	var/list/independent_departments = list()
	for(var/datum/antagonist/separatist/separatist_datum in GLOB.antagonists)
		if(!separatist_datum.nation)
			continue
		independent_departments[separatist_datum.department] = separatist_datum.nation

	if(!department)
		//picks a random department if none was given
		department = pick(list(/datum/job_department/assistant, /datum/job_department/medical, /datum/job_department/engineering, /datum/job_department/science, /datum/job_department/cargo, /datum/job_department/service, /datum/job_department/security) - cannot_pick)
		if(!department)
			return "Department Revolt could not create a nation, as all the departments are independent! You have created nations, you madman!"

	department = SSjob.get_department_type(department)

	for(var/datum/job/job as anything in department.department_jobs)
		if(job.departments_list.len > 1 && job.departments_list[1] != department.type) //their loyalty is in other departments
			continue
		jobs_to_revolt += job.title

	nation_name += pick("stan", "topia", "land", "nia", "ca", "tova", "dor", "ador", "tia", "sia", "ano", "tica", "tide", "cis", "marea", "co", "taoide", "slavia", "stotzka")
	if(department == "Uprising of Assistants")
		var/prefix = pick("roving clans", "barbaric tribes", "tides", "bandit kingdom", "tribal society", "marauder clans", "horde")
		nation_name = "The [prefix] of [nation_name]"

	var/datum/team/nation/nation = new(null, jobs_to_revolt, department)
	nation.name = nation_name
	var/datum/team/department_target //dodges unfortunate runtime
	if(independent_departments.len)
		department_target = pick(independent_departments)
	nation.generate_nation_objectives(dangerous, department_target)

	for(var/mob/living/carbon/human/possible_separatist as anything in GLOB.human_list)
		if(!possible_separatist.mind)
			continue
		var/datum/mind/separatist_mind = possible_separatist.mind
		if(!(separatist_mind.assigned_role.title in jobs_to_revolt))
			continue
		citizens += possible_separatist
		separatist_mind.add_antag_datum(/datum/antagonist/separatist, nation, department)
		nation.add_member(separatist_mind)
		possible_separatist.log_message("Was made into a separatist, long live [nation_name]!", LOG_ATTACK, color="red")

	if(citizens.len)
		var/jobs_english_list = english_list(jobs_to_revolt)
		message_admins("The nation of [nation_name] has been formed. Affected jobs are [jobs_english_list]. Any new crewmembers with these jobs will join the secession.")
		if(announcement)
			var/announce_text = "The new independent state of [nation_name] has formed from the ashes of the [department] department!"
			if(department == "Uprising of Assistants") //the text didn't really work otherwise
				announce_text = "The assistants of the station have risen to form the new independent state of [nation_name]!"
			priority_announce(announce_text, "Secession from [GLOB.station_name]",  has_important_message = TRUE)
	else
		return "The nation of [nation_name] did not have enough potential members to be created."
		qdel(nation)
