/datum/preferences
	///job xp
	var/list/job_xp_list = list()
	//job level
	var/list/job_level_list = list()
	///claimed rewards
	var/list/job_rewards_claimed = list()
	///per round claims
	var/list/job_rewards_per_round = list()


/datum/preferences/proc/write_jobxp_preferences()
	savefile.set_entry("job_xp_list", job_xp_list)
	savefile.set_entry("job_rewards_claimed", job_rewards_claimed)
	savefile.set_entry("job_rewards_per_round", job_rewards_per_round)
	savefile.set_entry("job_level_list", job_level_list)

/datum/preferences/proc/load_jobxp_preferences()
	job_xp_list = savefile.get_entry("job_xp_list", job_xp_list)
	job_rewards_claimed = savefile.get_entry("job_rewards_claimed", job_rewards_claimed)
	job_rewards_per_round = savefile.get_entry("job_rewards_per_round", job_rewards_per_round)
	job_level_list = savefile.get_entry("job_level_list", job_level_list)

	job_xp_list = SANITIZE_LIST(job_xp_list)
	job_rewards_claimed = SANITIZE_LIST(job_rewards_claimed)
	job_rewards_per_round = SANITIZE_LIST(job_rewards_per_round)
	job_level_list = SANITIZE_LIST(job_level_list)

	if(!length(job_xp_list))
		build_jobxp_list(job_xp_list)
	if(!length(job_rewards_claimed))
		build_jobxp_list(job_rewards_claimed)
	if(!length(job_rewards_per_round))
		build_jobxp_list(job_rewards_per_round)
	if(!length(job_level_list))
		build_jobxp_list(job_level_list)
	//check_unclaimed_rewards()

/datum/preferences/proc/rebuild_all_jobxp_lists()
	job_xp_list = list()
	job_rewards_claimed = list()
	job_rewards_per_round = list()
	job_level_list = list()

	if(!length(job_xp_list))
		build_jobxp_list(job_xp_list)
	if(!length(job_rewards_claimed))
		build_jobxp_list(job_rewards_claimed)
	if(!length(job_rewards_per_round))
		build_jobxp_list(job_rewards_per_round)
	if(!length(job_level_list))
		build_jobxp_list(job_level_list)

	save_preferences()


/datum/preferences/proc/build_jobxp_list(list/empty_list)
	var/list/jobs = list()
	var/list/all_jobs = subtypesof(/datum/job)
	for(var/job_type in all_jobs)
		var/datum/job/job = job_type
		jobs += initial(job.title)

	for(var/job as anything in jobs)
		if(!length(SSjob.all_occupations))
			SSjob.SetupOccupations()
		empty_list += job

/datum/preferences/proc/update_jobxp_list(list/update_list)
	var/list/jobs = list()
	var/list/all_jobs = subtypesof(/datum/job)
	for(var/job_type in all_jobs)
		var/datum/job/job = job_type
		jobs += initial(job.title)

	for(var/job as anything in jobs)
		if(update_list[job])
			continue
		update_list += job

/datum/preferences/proc/check_levelup(job)
	if(!job)
		CRASH("check_levelup called without a job passed in how did this happen!")
	if(!job_xp_list[job])
		return
	var/current_level = job_level_list[job]
	var/xp_needed = (current_level ** 1.5) + 125
	if(job_xp_list[job] > xp_needed)
		job_xp_list[job] -= xp_needed
		job_level_list[job]++
		level_up_reward(job)
		for(var/datum/job_milestone/subtype as anything in subtypesof(/datum/job_milestone))
			if(!(initial(subtype.key_id) == job))
				continue
			var/datum/job_milestone/subtype_created = new subtype
			subtype_created.check_milestones(job_level_list[job], parent)

/datum/preferences/proc/level_up_reward(job)
	if(!job || !job_level_list[job])
		return
	adjust_metacoins(parent.ckey, 25*job_level_list[job], "You have leveled up!", TRUE, TRUE, FALSE)
