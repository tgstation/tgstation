/datum/dynamic_ruleset/roundstart/clock_cult
	name = "Clock Cult"
	antag_flag = ROLE_CLOCK_CULTIST
	antag_datum = /datum/antagonist/clock_cultist
	minimum_required_age = 14
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHAPLAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	required_candidates = 3
	weight = 3
	cost = 20
	requirements = list(100,90,80,60,40,30,10,10,10,10)
	flags = HIGH_IMPACT_RULESET
	antag_cap = list("denominator" = 20, "offset" = 1)

	minimum_players = 30

/datum/dynamic_ruleset/roundstart/clock_cult/ready(population, forced = FALSE)
	required_candidates = get_antag_cap(population)
	return ..()

/datum/dynamic_ruleset/roundstart/clock_cult/pre_execute(population)
	. = ..()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_reebe))
	var/cultists = get_antag_cap(population)
	for(var/cultists_number = 1 to cultists)
		if(candidates.len <= 0)
			break
		var/mob/candidate = pick_n_take(candidates)
		assigned += candidate.mind
		candidate.mind.special_role = ROLE_CLOCK_CULTIST
		candidate.mind.restricted_roles = restricted_roles
		GLOB.pre_setup_antags += candidate.mind
	return TRUE

/datum/dynamic_ruleset/roundstart/clock_cult/execute()
	for(var/datum/mind/assigned_mob in assigned)
		assigned_mob.add_antag_datum(/datum/antagonist/clock_cultist)
		GLOB.pre_setup_antags -= assigned_mob
	return TRUE
