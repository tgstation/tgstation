
/**
 * Generates a list of bounties for use with the civilian bounty pad.
 *
 * @param bounty_types the define taken from a job for selection of a random_bounty() proc.
 * @param bounty_rolls the number of bounties to be selected from.
 * @param assistant_failsafe Do we guarentee one assistant bounty per generated list? Used for non-assistant jobs to give an easier alternative to that job's default bounties.
 */
/datum/id_trim/proc/generate_bounty_list(bounty_rolls = 3, assistant_failsafe = TRUE)
	var/datum/job/our_job = find_job()
	var/bounty_type = our_job?.bounty_types || CIV_JOB_RANDOM

	var/list/rolling_list = list()
	if(assistant_failsafe)
		var/random_assistant = get_random_bounty_type(CIV_JOB_BASIC)
		var/datum/bounty/assistant_bounty = new random_assistant()
		if(assistant_bounty.can_get())
			rolling_list += assistant_bounty
		else
			qdel(assistant_bounty)

	var/attempts = 20
	while(length(rolling_list) < bounty_rolls && attempts > 0)
		var/random_job = get_random_bounty_type(attempts <= 5 ? CIV_JOB_BASIC : bounty_type)
		var/datum/bounty/job_bounty = new random_job()
		attempts -= 1
		if(!job_bounty.can_get() || has_duplicate_bounty(rolling_list, job_bounty))
			qdel(job_bounty)
			continue

		rolling_list += job_bounty

	return rolling_list

/// Helper to see if there's a duplicate bounty in a list of bounties
/datum/id_trim/proc/has_duplicate_bounty(list/datum/bounty/bounty_list, datum/bounty/check_bounty)
	PRIVATE_PROC(TRUE)

	for(var/datum/bounty/existing as anything in bounty_list)
		if(existing.type != check_bounty.type)
			continue
		if(existing.allow_duplicate && check_bounty.allow_duplicate)
			continue
		return TRUE

	return FALSE

/// Returns a /datum/bounty typepath for a given bounty type
/datum/id_trim/proc/get_random_bounty_type(input_bounty_type)
	if(!input_bounty_type || input_bounty_type == CIV_JOB_RANDOM)
		input_bounty_type = rand(1, MAXIMUM_BOUNTY_JOBS)

	switch(input_bounty_type)
		if(CIV_JOB_BASIC)
			return pick(subtypesof(/datum/bounty/item/assistant))
		if(CIV_JOB_ROBO)
			return pick(subtypesof(/datum/bounty/item/mech))
		if(CIV_JOB_CHEF)
			return pick(subtypesof(/datum/bounty/item/chef) + subtypesof(/datum/bounty/reagent/chef))
		if(CIV_JOB_SEC)
			if(prob(75))
				return /datum/bounty/patrol
			return /datum/bounty/item/contraband
		if(CIV_JOB_DRINK)
			if(prob(50))
				return /datum/bounty/reagent/simple_drink
			return /datum/bounty/reagent/complex_drink
		if(CIV_JOB_CHEM)
			if(prob(50))
				return /datum/bounty/reagent/chemical_simple
			return/datum/bounty/reagent/chemical_complex
		if(CIV_JOB_VIRO)
			return pick(subtypesof(/datum/bounty/virus))
		if(CIV_JOB_SCI)
			if(prob(50))
				return pick(subtypesof(/datum/bounty/item/science))
			return pick(subtypesof(/datum/bounty/item/slime))
		if(CIV_JOB_ENG)
			return pick(subtypesof(/datum/bounty/item/engineering))
		if(CIV_JOB_MINE)
			return pick(subtypesof(/datum/bounty/item/mining))
		if(CIV_JOB_MED)
			return pick(subtypesof(/datum/bounty/item/medical))
		if(CIV_JOB_GROW)
			return pick(subtypesof(/datum/bounty/item/botany))
		if(CIV_JOB_ATMOS)
			return pick(subtypesof(/datum/bounty/item/atmospherics))
		if(CIV_JOB_BITRUN)
			return pick(subtypesof(/datum/bounty/item/bitrunning))

	stack_trace("Failed to get random bounty type for input type [input_bounty_type]")
	return null
