//////////////////////////////////////////////
//                                          //
//        ROUNDSTART BLOODSUCKER            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodsucker
	name = "Bloodsuckers"
	antag_flag = ROLE_BLOODSUCKER
	antag_datum = /datum/antagonist/bloodsucker
	protected_roles = list(
		// Command
		JOB_CAPTAIN, JOB_HEAD_OF_PERSONNEL, JOB_HEAD_OF_SECURITY, JOB_RESEARCH_DIRECTOR, JOB_CHIEF_ENGINEER, JOB_CHIEF_MEDICAL_OFFICER,
		// Security
		JOB_WARDEN, JOB_SECURITY_OFFICER, JOB_DETECTIVE, JOB_SECURITY_ASSISTANT,
		// Curator
		JOB_CURATOR,
	)
	restricted_roles = list(JOB_AI, JOB_CYBORG)
	required_candidates = 1
	weight = 3
	cost = 14
	minimum_players = 20
	scaling_cost = 9
	requirements = list(101,101,60,30,30,25,20,20,14,14)
	antag_cap = list("denominator" = 24)

/datum/dynamic_ruleset/roundstart/bloodsucker/pre_execute(population)
	. = ..()
	var/num_bloodsuckers = get_antag_cap(population) * (scaled_times + 1)

	for(var/i = 1 to num_bloodsuckers)
		if(length(candidates) <= 0)
			break
		var/mob/selected_mobs = pick_n_take(candidates)
		assigned += selected_mobs.mind
		selected_mobs.mind.restricted_roles = restricted_roles
		GLOB.pre_setup_antags += selected_mobs.mind
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodsucker/execute()
	for(var/datum/mind/candidate_minds as anything in assigned)
		if(!candidate_minds.make_bloodsucker())
			message_admins("[ADMIN_LOOKUPFLW(candidate_minds)] was selected by the [name] ruleset, but couldn't be made into a Bloodsucker.")
			assigned -= candidate_minds
			continue
		GLOB.pre_setup_antags -= candidate_minds
		candidate_minds.special_role = ROLE_BLOODSUCKER
	return TRUE

//////////////////////////////////////////////
//                                          //
//          MIDROUND BLOODSUCKER            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/bloodsucker
	name = "Vampiric Accident"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/bloodsucker
	antag_flag = ROLE_VAMPIRICACCIDENT
	antag_flag_override = ROLE_BLOODSUCKER
	protected_roles = list(
		JOB_CAPTAIN, JOB_HEAD_OF_PERSONNEL, JOB_HEAD_OF_SECURITY,
		JOB_WARDEN, JOB_SECURITY_OFFICER, JOB_DETECTIVE,
		JOB_CURATOR, JOB_SECURITY_ASSISTANT,
	)
	restricted_roles = list(JOB_AI, JOB_CYBORG, "Positronic Brain")
	required_candidates = 1
	weight = 3
	cost = 14
	minimum_players = 20
	requirements = list(101,101,60,30,30,25,20,20,14,14)
	repeatable = FALSE

/datum/dynamic_ruleset/midround/bloodsucker/trim_candidates()
	..()
	candidates = living_players
	for(var/mob/living/player in candidates)
		if(!is_station_level(player.z))
			candidates.Remove(player)
		else if(player.mind && (player.mind.special_role || length(player.mind.antag_datums) > 0))
			candidates.Remove(player)

/datum/dynamic_ruleset/midround/bloodsucker/execute()
	if(!candidates || !length(candidates))
		return FALSE
	var/mob/selected_mobs = pick_n_take(candidates)
	assigned += selected_mobs.mind
	var/datum/mind/candidate_mind = selected_mobs.mind
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = candidate_mind.make_bloodsucker()
	if(!bloodsuckerdatum)
		assigned -= selected_mobs.mind
		message_admins("[ADMIN_LOOKUPFLW(selected_mobs)] was selected by the [name] ruleset, but couldn't be made into a Bloodsucker.")
		return FALSE
	bloodsuckerdatum.bloodsucker_level_unspent = rand(2,3)
	message_admins("[ADMIN_LOOKUPFLW(selected_mobs)] was selected by the [name] ruleset and has been made into a midround Bloodsucker.")
	log_game("DYNAMIC: [key_name(selected_mobs)] was selected by the [name] ruleset and has been made into a midround Bloodsucker.")
	return TRUE

//////////////////////////////////////////////
//                                          //
//          LATEJOIN BLOODSUCKER            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/bloodsucker
	name = "Bloodsucker Breakout"
	antag_datum = /datum/antagonist/bloodsucker
	antag_flag = ROLE_BLOODSUCKERBREAKOUT
	antag_flag_override = ROLE_BLOODSUCKER
	protected_roles = list(
		JOB_CAPTAIN, JOB_HEAD_OF_PERSONNEL, JOB_HEAD_OF_SECURITY,
		JOB_WARDEN, JOB_SECURITY_OFFICER, JOB_DETECTIVE,
		JOB_CURATOR, JOB_SECURITY_ASSISTANT,
	)
	restricted_roles = list(JOB_AI, JOB_CYBORG)
	required_candidates = 1
	weight = 5
	cost = 10
	minimum_players = 20
	requirements = list(101,101,60,20,20,20,20,20,14,14)
	repeatable = FALSE

/datum/dynamic_ruleset/latejoin/bloodsucker/execute()
	var/mob/latejoiner = pick(candidates) // This should contain a single player, but in case.
	assigned += latejoiner.mind

	for(var/datum/mind/candidate_mind as anything in assigned)
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = candidate_mind.make_bloodsucker()
		if(!bloodsuckerdatum)
			assigned -= candidate_mind
			message_admins("[ADMIN_LOOKUPFLW(candidate_mind)] was selected by the [name] ruleset, but couldn't be made into a Bloodsucker.")
			continue
		bloodsuckerdatum.bloodsucker_level_unspent = rand(2,3)
		message_admins("[ADMIN_LOOKUPFLW(candidate_mind)] was selected by the [name] ruleset and has been made into a midround Bloodsucker.")
		log_game("DYNAMIC: [key_name(candidate_mind)] was selected by the [name] ruleset and has been made into a midround Bloodsucker.")
	return TRUE
