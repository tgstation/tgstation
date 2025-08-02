/datum/unit_test/traitor/Run()
	var/datum/dynamic_ruleset/roundstart/traitor/traitor_ruleset = allocate(/datum/dynamic_ruleset/roundstart/traitor)
	var/list/possible_jobs = list()
	var/list/restricted_roles = traitor_ruleset.get_blacklisted_roles()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(!(job.job_flags & JOB_CREW_MEMBER))
			continue
		var/rank = job.title
		if(rank in restricted_roles)
			continue
		possible_jobs += rank

	for(var/job_name in possible_jobs)
		var/datum/job/job = SSjob.get_job(job_name)
		var/mob/living/player = allocate(job.spawn_type)
		player.mind_initialize()
		var/datum/mind/mind = player.mind
		if(ishuman(player))
			var/mob/living/carbon/human/human = player
			human.equipOutfit(job.outfit)
		mind.set_assigned_role(job)
		var/datum/antagonist/traitor/traitor = mind.add_antag_datum(/datum/antagonist/traitor)
		if(!traitor.uplink_handler)
			TEST_FAIL("[job_name] when made traitor does not have a proper uplink created when spawned in!")
