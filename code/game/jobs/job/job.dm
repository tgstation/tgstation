/datum/job
	var
		//The name of the job
		title = "NOPE"
		//Bitflags for the job
		flag = 0
		department_flag = 0
		//Players will be allowed to spawn in as jobs that are set to "Station"
		faction = "None"
		//How many players can be this job
		total_positions = 0
		//How many players can spawn in as this job
		spawn_positions = 0
		//How many players have this job
		current_positions = 0


	proc/equip(var/mob/living/carbon/human/H)
		return 1


var/datum/jobs/jobs = new/datum/jobs()

/datum/jobs
	var/list/datum/job/all_jobs = list()

	proc/get_all_jobs()
		return all_jobs

	//This proc returns all the jobs which are NOT admin only
	proc/get_normal_jobs()
//		var/list/datum/job/normal_jobs = list()
//		for(var/datum/job/J in all_jobs)
//			if(!J.admin_only)
//				normal_jobs += J
//		return normal_jobs

	//This proc returns all the jobs which are admin only
	proc/get_admin_jobs()
//		var/list/datum/job/admin_jobs = list()
//		for(var/datum/job/J in all_jobs)
//			if(J.admin_only)
//				admin_jobs += J
//		return admin_jobs

	//This proc returns the job datum of the job with the alias or job title given as the argument. Returns an empty string otherwise.
	proc/get_job(var/alias)
//		for(var/datum/job/J in all_jobs)
//			if(J.is_job_alias(alias))
//				return J
		return ""

	//This proc returns a string with the default job title for the job with the given alias. Returns an empty string otherwise.
	proc/get_job_title(var/alias)
//		for(var/datum/job/J in all_jobs)
//			if(J.is_job_alias(alias))
//				return J.title
		return ""
/*
	//This proc returns all the job datums of the workers whose boss has the alias provided. (IE Engineer under Chief Engineer, etc.)
	proc/get_jobs_under(var/boss_alias)
		var/boss_title = get_job_title(boss_alias)
		var/list/datum/job/employees = list()
		for(var/datum/job/J in all_jobs)
			if(boss_title in J.bosses)
				employees += J
		return employees*/

	//This proc returns the chosen vital and high priority jobs that the person selected. It goes from top to bottom of the list, until it finds a job which does not have such priority.
	//Example: Choosing (in this order): CE, Captain, Engineer, RD will only return CE and Captain, as RD is assumed as being an unwanted choice.
	//This proc is used in the allocation algorithm when deciding vital and high priority jobs.
/*	proc/get_prefered_high_priority_jobs()
		var/list/datum/job/hp_jobs = list()
		for(var/datum/job/J in all_jobs)
			if(J.assignment_priority == HIGH_PRIORITY_JOB || J.assignment_priority == VITAL_PRIORITY_JOB)
				hp_jobs += J
			else
				break
		return hp_jobs

	//If only priority is given, it will return the jobs of only that priority, if end_priority is set it will return the jobs with their priority higher or equal to var/priority and lower or equal to end_priority. end_priority must be higher than 0.
	proc/get_jobs_by_priority(var/priority, var/end_priority = 0)
		var/list/datum/job/priority_jobs = list()
		if(end_priority)
			if(end_priority < priority)
				return
			for(var/datum/job/J in all_jobs)
				if(J.assignment_priority >= priority && J.assignment_priority <= end_priority)
					priority_jobs += J
		else
			for(var/datum/job/J in all_jobs)
				if(J.assignment_priority == priority)
					priority_jobs += J
		return priority_jobs*/