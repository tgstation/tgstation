/datum/dynamic_ruleset/roundstart/vampire
	name = "vampire"
	antag_flag = ROLE_VAMPIRE
	antag_datum = /datum/antagonist/vampire
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	restricted_roles = list("AI", "Cyborg")
	required_candidates = 1
	weight = 3
	cost = 30
	requirements = list(80,70,60,50,40,20,20,10,10,10)
	high_population_requirement = 10

/datum/dynamic_ruleset/roundstart/vampire/pre_execute()
	var/num_vampires = min(round(mode.candidates.len / 10) + 1, candidates.len)
	for (var/i = 1 to num_vampires)
		var/mob/M = pick(candidates)
		candidates -= M
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = ROLE_VAMPIRE
	return TRUE

// is that really it. what the heck. amazing
