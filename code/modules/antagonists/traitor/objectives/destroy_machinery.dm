/datum/traitor_objective_category/destroy_machinery
	name = "Destroy Infrastructure"
	objectives = list(
		/datum/traitor_objective/destroy_machinery = 1,
	)

/datum/traitor_objective/destroy_machinery
	name = "Destroy the %MACHINE%"
	description = "Destroy the %MACHINE% to cause disarray and disrupt the operations of the %JOB%'s department."

	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = list(3, 4)

	progression_minimum = 15 MINUTES
	progression_maximum = 30 MINUTES

	/// The possible target machinery and the jobs tied to each one.
	applicable_jobs = list(
		JOB_STATION_ENGINEER = /obj/machinery/telecomms/hub,
		JOB_SCIENTIST = /obj/machinery/rnd/server,
	)
	/// The chosen job. Used to check for duplicates
	var/chosen_job

/datum/traitor_objective/destroy_machinery/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	for(var/datum/traitor_objective/destroy_machinery/objective as anything in possible_duplicates)
		applicable_jobs -= objective.chosen_job
	if(!length(applicable_jobs))
		return FALSE
	var/list/obj/machinery/possible_machines = list()
	while(length(possible_machines) <= 0 && length(applicable_jobs) > 0)
		var/target_head = pick(applicable_jobs)
		var/obj/machinery/machine_to_find = applicable_jobs[target_head]
		applicable_jobs -= target_head

		chosen_job = target_head
		for(var/obj/machinery/machine as anything in GLOB.machines)
			if(istype(machine, machine_to_find) && is_station_level(machine.z))
				possible_machines += machine

	if(!length(possible_machines))
		return FALSE

	for(var/obj/machinery/machine as anything in possible_machines)
		AddComponent(/datum/component/traitor_objective_register, machine, succeed_signals = list(COMSIG_PARENT_QDELETING))

	replace_in_name("%JOB%", lowertext(chosen_job))
	replace_in_name("%MACHINE%", possible_machines[1].name)
	return TRUE

