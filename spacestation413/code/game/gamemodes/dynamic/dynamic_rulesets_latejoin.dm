/datum/dynamic_ruleset/latejoin/vampire
	name = "vampire"
	antag_flag = ROLE_VAMPIRE
	antag_datum = /datum/antagonist/vampire
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	restricted_roles = list("AI", "Cyborg")
	required_candidates = 1
	weight = 5
	cost = 15
	requirements = list(80,70,60,50,40,20,20,10,10,10)
	repeatable = TRUE
	high_population_requirement = 10

/datum/dynamic_ruleset/latejoin/vampire/pre_execute()
	var/mob/M = pick(candidates)
	candidates -= M
	assigned += M.mind
	M.mind.restricted_roles = restricted_roles
	M.mind.special_role = ROLE_VAMPIRE
	return TRUE
