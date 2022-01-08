/datum/unit_test/traitor/Run()
	var/datum/dynamic_ruleset/roundstart/traitor/traitor = allocate(/datum/dynamic_ruleset/roundstart/traitor/)
	var/list/protected_roles = traitor.protected_roles
	var/list/restricted_roles = traitor.restricted_roles

	var/list/possible_jobs = SSjob.station_jobs.Copy()
	possible_jobs -= protected_roles
	possible_jobs -= restricted_roles

	for(var/job in possible_jobs)
		var/datum/job/job = SSjob.GetJob(job)
		var/mob/living/player = allocate(job.spawn_type)
		player.mind_initialize()
		var/datum/mind/mind = player.mind
		if(ishuman(player))
			var/mob/living/carbon/human/human = player
			human.equipOutfit(job.outfit)
		mind.set_assigned_role(job)
		for(var/datum/traitor_objective/objective_typepath as anything in subtypesof(/datum/traitor_objective))
			if(initial(objective_typepath.abstract_type) == objective_typepath)
				continue
			var/datum/traitor_objective/objective = allocate(objective_typepath)
			try
				var/failed = objective.generate_objective(mind, list())
			catch(var/exception/exception)
				Fail("[objective_typepath] failed to generate their objective. Reason: [exception.name] [exception.file]:[exception.line]\n[exception.desc]")
