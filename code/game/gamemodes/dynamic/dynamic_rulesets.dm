/datum/dynamic_ruleset
	var/name = ""//For admin logging, and round end scoreboard
	var/persistent = 0//if set to 1, the rule won't be discarded after being executed, and /gamemode/dynamic will call rule_process() every MC tick
	var/repeatable = 0//if set to 1, dynamic mode will be able to draft this ruleset again later on. (doesn't apply for roundstart rules)
	var/list/candidates = list()//list of players that are being drafted for this rule
	var/list/assigned = list()//list of players that were selected for this rule
	var/antag_flag = null //preferences flag such as BE_WIZARD that need to be turned on for players to be antag
	var/antag_datum = null
	var/list/protected_roles = list() // if set, and config.protect_roles_antagonist = 0, then the rule will have a much lower chance than usual to pick those roles.
	var/list/restricted_roles = list()//if set, rule will deny candidates from those roles
	var/list/exclusive_roles = list()//if set, rule will only accept candidates from those roles
	var/list/job_priority = list() //May be used by progressive_job_search for prioritizing some roles for a role. Order matters.
	var/list/enemy_roles = list()//if set, there needs to be a certain amount of players doing those roles (among the players who won't be drafted) for the rule to be drafted
	var/required_enemies = list(1,1,0,0,0,0,0,0,0,0)//if enemy_roles was set, this is the amount of enemy job workers needed per threat_level range (0-10,10-20,etc)
	var/required_candidates = 0//the rule needs this many candidates (post-trimming) to be executed (example: Cult need 4 players at round start)
	var/weight = 5//1 -> 9, probability for this rule to be picked against other rules
	var/cost = 0//threat cost for this rule.

	var/flags = 0

	//for midround polling
	var/list/applicants = list()

	var/list/requirements = list(40,30,20,10,10,10,10,10,10,10)
	//requirements are the threat level requirements per pop range. The ranges are as follow:
	//0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-54, 45+
	//so with the above default values, The rule will never get drafted below 10 threat level (aka: "peaceful extended"), and it requires a higher threat level at lower pops.
	//for reminder: the threat level is rolled at roundstart and tends to hover around 50 https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=499381388
	var/high_population_requirement = 10
	//an alternative, static requirement used instead when "high_population_override" is set to 1 in the config
	//which it should be when even low pop rounds have over 30 players and high pop rounds have 90+.

	var/datum/game_mode/dynamic/mode = null

	var/antag_flag_override = null // If a role is to be considered another for the purpose of banning.

/datum/dynamic_ruleset/New()
	..()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_roles += protected_roles
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_roles += "Assistant"

	if (istype(SSticker.mode, /datum/game_mode/dynamic))
		mode = SSticker.mode
	else
		qdel(src)

/datum/dynamic_ruleset/roundstart//One or more of those drafted at roundstart

/datum/dynamic_ruleset/roundstart/delayed/ // Executed with a 30 seconds delay
	var/delay = 30 SECONDS
	var/required_type = /mob/living/carbon/human // No ghosts, new players or silicons allowed.

/datum/dynamic_ruleset/latejoin//Can be drafted when a player joins the server


/datum/dynamic_ruleset/proc/acceptable(var/population=0,var/threat_level=0)
	//by default, a rule is acceptable if it satisfies the threat level/population requirements.
	//If your rule has extra checks, such as counting security officers, do that in ready() instead

	if (GLOB.player_list.len >= mode.high_pop_limit)
		return (threat_level >= high_population_requirement)
	else
		var/indice_pop = min(10,round(population/5)+1)
		return (threat_level >= requirements[indice_pop])

/datum/dynamic_ruleset/proc/rule_process()
	return

/datum/dynamic_ruleset/proc/pre_execute()
	return TRUE

/datum/dynamic_ruleset/proc/execute()
	for(var/mob/M in assigned)
		M.mind.add_antag_datum(antag_datum)
	return TRUE

/datum/dynamic_ruleset/proc/ready(var/forced = 0)	//Here you can perform any additional checks you want. (such as checking the map, the amount of certain roles, etc)
	if (required_candidates > candidates.len)		//IMPORTANT: If ready() returns TRUE, that means pre_execute() should never fail!
		return FALSE
	return TRUE

/datum/dynamic_ruleset/proc/get_weight()
	if(repeatable && weight > 1)
		for(var/datum/dynamic_ruleset/DR in mode.executed_rules)
			if(istype(DR,src.type))
				weight = max(weight-2,1)
	message_admins("[name] had [weight] weight (-[initial(weight) - weight]).")
	return weight

/datum/dynamic_ruleset/proc/trim_candidates()
	return

/datum/dynamic_ruleset/proc/send_applications(var/list/possible_volunteers = list())
	if (possible_volunteers.len <= 0)//this shouldn't happen, as ready() should return FALSE if there is not a single valid candidate
		message_admins("Possible volunteers was 0. This shouldn't appear, because of ready(), unless you forced it!")
		return
	message_admins("DYNAMIC MODE: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")
	log_admin("DYNAMIC MODE: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")

	applicants = pollGhostCandidates("The mode is looking for volunteers to become [initial(antag_flag)]", antag_flag, SSticker.mode, antag_flag, poll_time = 600)
	
	if(!applicants || applicants.len <= 0)
		log_admin("DYNAMIC MODE: [name] received no applications.")
		message_admins("DYNAMIC MODE: [name] received no applications.")
		mode.refund_threat(cost)
		mode.threat_log += "[worldtime2text()]: Rule [name] refunded [cost] (no applications)"
		mode.executed_rules -= src
		return

	log_admin("DYNAMIC MODE: [applicants.len] players volunteered for [name].")
	message_admins("DYNAMIC MODE: [applicants.len] players volunteered for [name].")
	review_applications()

/datum/dynamic_ruleset/proc/review_applications()

/datum/dynamic_ruleset/proc/progressive_job_search()
	for(var/job in job_priority)
		for(var/mob/M in candidates)
			if(M.mind.assigned_role == job)
				assigned += M
				candidates -= M
				return M
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	return M


/datum/dynamic_ruleset/proc/num_players()
	. = 0
	for(var/mob/dead/new_player/P in GLOB.player_list)
		if(P.client && P.ready == PLAYER_READY_TO_PLAY)
			. ++

/datum/dynamic_ruleset/proc/round_result()

//////////////////////////////////////////////
//                                          //
//           ROUNDSTART RULESETS            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/trim_candidates()
	var/antag_name = initial(antag_flag)
	for(var/mob/dead/new_player/P in candidates)
		if (!P.client || !P.mind)//are they connected?
			candidates.Remove(P)
			continue
		if (!(antag_name in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_name, ROLE_SYNDICATE)) || (antag_flag_override && is_banned_from(P.ckey, list(antag_flag_override, ROLE_SYNDICATE))))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if ((exclusive_roles.len > 0) && !(P.mind.assigned_role in exclusive_roles))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/roundstart/delayed/trim_candidates()
	if (SSticker && SSticker.current_state < GAME_STATE_PLAYING)
		return ..() // If the game didn't start, we'll use the parent's method to see if we have enough people desiring the role & what not.
	var/antag_name = initial(antag_flag)
	for (var/mob/P in candidates)
		if (!istype(P, required_type))
			candidates.Remove(P) // Can be a new_player, etc.
			continue
		if (!P.client || !P.mind || !P.mind.assigned_role || P.mind.special_role)//are they connected? Are they an antag already?
			candidates.Remove(P)
			continue
		if (!(antag_name in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_name, ROLE_SYNDICATE)) || (antag_flag_override && is_banned_from(P.ckey, list(antag_flag_override, ROLE_SYNDICATE))))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if ((exclusive_roles.len > 0) && !(P.mind.assigned_role in exclusive_roles))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/roundstart/ready(var/forced = 0)
	if (!forced)
		var/job_check = 0
		if (enemy_roles.len > 0)
			for (var/mob/M in mode.candidates)
				if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_roles) && (!(M in candidates) || (M.mind.assigned_role in restricted_roles)))
					job_check++//checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

		var/threat = round(mode.threat_level/10)
		if (job_check < required_enemies[threat])
			return FALSE
	return ..()
