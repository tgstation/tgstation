//////////////////////////////////////////////
//                                          //
//                DARKSPAWN                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/darkspawn
	name = "Darkspawn"
	antag_flag = ROLE_DARKSPAWN
	antag_datum = /datum/antagonist/darkspawn
	minimum_required_age = 20
	protected_roles = list(JOB_SECURITY_OFFICER, JOB_WARDEN, JOB_DETECTIVE, JOB_HEAD_OF_SECURITY, JOB_CAPTAIN, JOB_PRISONER)
	restricted_roles = list(JOB_AI, JOB_CYBORG)
	flags = HIGH_IMPACT_RULESET
	required_candidates = 3
	weight = 3
	cost = 20
	scaling_cost = 20
	antag_cap = list(3,3,3,3,3,3,3,3,3,3)
	requirements = list(80,75,70,65,50,30,30,30,25,20)
	minimum_players = 30

/datum/dynamic_ruleset/roundstart/darkspawn/pre_execute(population)
	. = ..()
	var/num_darkspawn = antag_cap[indice_pop] * (scaled_times + 1)
	for (var/i = 1 to num_darkspawn)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_DARKSPAWN
		M.mind.restricted_roles = restricted_roles
		log_game("[key_name(M)] has been selected as a Darkspawn")
	return TRUE
