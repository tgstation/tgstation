/datum/dynamic_ruleset
	var/name = "" // For admin logging
	var/ruletype = "" // For admin logging, do not change unless making a new rule type.
	var/persistent = FALSE // If set to TRUE, the rule won't be discarded after being executed, and dynamic will call rule_process() every SSTicker tick
	var/repeatable = FALSE // If set to TRUE, dynamic mode will be able to draft this ruleset again later on. (doesn't apply for roundstart rules)
	var/repeatable_weight_decrease = 2 // If set higher than 0, decreases weight by itself causing the ruleset to appear less often the more it is repeated.
	var/list/mob/candidates = list() // List of players that are being drafted for this rule
	var/list/datum/mind/assigned = list() // List of players that were selected for this rule
	var/antag_flag = null // Preferences flag such as ROLE_WIZARD that need to be turned on for players to be antag
	var/datum/antagonist/antag_datum = null
	var/list/protected_roles = list() // If set, and config flag protect_roles_from_antagonist is false, then the rule will pick players from these roles.
	var/list/restricted_roles = list() // If set, rule will deny candidates from those roles
	var/list/exclusive_roles = list() // If set, rule will only accept candidates from those roles, IMPORTANT: DOES NOT WORK ON ROUNDSTART RULESETS.
	var/list/enemy_roles = list() // If set, there needs to be a certain amount of players doing those roles (among the players who won't be drafted) for the rule to be drafted IMPORTANT: DOES NOT WORK ON ROUNDSTART RULESETS.
	var/required_enemies = list(1,1,0,0,0,0,0,0,0,0) // If enemy_roles was set, this is the amount of enemy job workers needed per threat_level range (0-10,10-20,etc) IMPORTANT: DOES NOT WORK ON ROUNDSTART RULESETS.
	var/required_candidates = 0 // The rule needs this many candidates (post-trimming) to be executed (example: Cult need 4 players at round start)
	var/weight = 5 // 1 -> 9, probability for this rule to be picked against other rules
	var/cost = 0 // Threat cost for this rule.

	var/flags = 0

	// For midround polling
	var/list/applicants = list()

	// Pop range per requirement. If this is the default five, the pop range for requirements are:
	// 0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-54, 45+
	var/pop_per_requirement = 5
	// Requirements are the threat level requirements per pop range.
	// With the default values, The rule will never get drafted below 10 threat level (aka: "peaceful extended"), and it requires a higher threat level at lower pops.
	var/list/requirements = list(40,30,20,10,10,10,10,10,10,10)
	// An alternative, static requirement used instead when pop is over mode's high_pop_limit. 
	var/high_population_requirement = 10.

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
	else if (GLOB.master_mode != "dynamic") // This is here to make roundstart forced ruleset function.
		qdel(src)

/datum/dynamic_ruleset/roundstart // One or more of those drafted at roundstart
	ruletype = "Roundstart"

/datum/dynamic_ruleset/roundstart/delayed/ // Executed with a 30 seconds delay
	var/delay = 30 SECONDS
	var/required_type = /mob/living/carbon/human // No ghosts, new players or silicons allowed.

// Can be drafted when a player joins the server
/datum/dynamic_ruleset/latejoin
	ruletype = "Latejoin"

// By default, a rule is acceptable if it satisfies the threat level/population requirements.
// If your rule has extra checks, such as counting security officers, do that in ready() instead
/datum/dynamic_ruleset/proc/acceptable(population=0, threat_level=0)
	if (population >= GLOB.dynamic_high_pop_limit)
		return (threat_level >= high_population_requirement)
	else
		var/indice_pop = min(10,round(population/pop_per_requirement)+1)
		return (threat_level >= requirements[indice_pop])

// This is called if persistent variable is true everytime SSTicker ticks.
/datum/dynamic_ruleset/proc/rule_process()
	return

// Called on game mode pre_setup, used for non-delayed roundstart rulesets only.
// Do everything you need to do before job is assigned here.
// IMPORTANT: ASSIGN special_role HERE
/datum/dynamic_ruleset/proc/pre_execute()
	return TRUE

// Called on post_setup on roundstart and when the rule executes on midround and latejoin.
// Give your candidates or assignees equipment and antag datum here.
/datum/dynamic_ruleset/proc/execute()
	for(var/datum/mind/M in assigned)
		M.add_antag_datum(antag_datum)
	return TRUE

// Called after delay set in ruleset.
// Give your candidates or assignees equipment and antag datum here.
/datum/dynamic_ruleset/roundstart/delayed/execute()
	if (SSticker && SSticker.current_state < GAME_STATE_PLAYING)
		CRASH("The delayed ruleset [src.name] executed before the round started.")

// Here you can perform any additional checks you want. (such as checking the map etc)
// Remember that on roundstart no one knows what their job is at this point.
// IMPORTANT: If ready() returns TRUE, that means pre_execute() or execute() should never fail!
/datum/dynamic_ruleset/proc/ready(forced = 0)	
	if (required_candidates > candidates.len)		
		return FALSE
	return TRUE

// Gets weight of the ruleset
// Note that this decreases weight if repeatable is TRUE and repeatable_weight_decrease is higher than 0
// Note: If you don't want repeatable rulesets to decrease their weight use the weight variable directly
/datum/dynamic_ruleset/proc/get_weight()
	if(repeatable && weight > 1 && repeatable_weight_decrease > 0)
		for(var/datum/dynamic_ruleset/DR in mode.executed_rules)
			if(istype(DR, type))
				weight = max(weight-repeatable_weight_decrease,1)
	return weight

// Here you can remove candidates that do not meet your requirements.
// This means if their job is not correct or they have disconnected you can remove them from candidates here.
// Usually this does not need to be changed unless you need some specific requirements from your candidates.
/datum/dynamic_ruleset/proc/trim_candidates()
	return

// This sends a poll to ghosts if they want to be a ghost spawn from a ruleset.
// Called by from_ghost midround rulesets.
/datum/dynamic_ruleset/proc/send_applications(list/possible_volunteers = list())
	if (possible_volunteers.len <= 0) // This shouldn't happen, as ready() should return FALSE if there is not a single valid candidate
		message_admins("Possible volunteers was 0. This shouldn't appear, because of ready(), unless you forced it!")
		return
	message_admins("DYNAMIC MODE: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")
	log_game("DYNAMIC: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")

	applicants = pollGhostCandidates("The mode is looking for volunteers to become [initial(antag_flag)]", antag_flag, SSticker.mode, antag_flag, poll_time = 600)
	
	if(!applicants || applicants.len <= 0)
		message_admins("DYNAMIC MODE: [name] received no applications.")
		log_game("DYNAMIC: [name] received no applications.")
		mode.refund_threat(cost)
		mode.threat_log += "[worldtime2text()]: Rule [name] refunded [cost] (no applications)"
		mode.executed_rules -= src
		return

	message_admins("DYNAMIC MODE: [applicants.len] players volunteered for [name].")
	log_game("DYNAMIC: [applicants.len] players volunteered for [name].")
	review_applications()

// Here is where you can check if your ghost applicants are still valid.
// Called by send_applications().
/datum/dynamic_ruleset/proc/review_applications()

// Counts how many players are ready at roundstart.
// Used only by non-delayed roundstart rulesets. 
/datum/dynamic_ruleset/proc/num_players()
	. = 0
	for(var/mob/dead/new_player/P in GLOB.player_list)
		if(P.client && P.ready == PLAYER_READY_TO_PLAY)
			. ++

// Set mode result and news report here.
// Only called if ruleset is flagged as HIGHLANDER_RULESET
/datum/dynamic_ruleset/proc/round_result()

// Checks if round is finished, return true to end the round.
// Only called if ruleset is flagged as HIGHLANDER_RULESET
/datum/dynamic_ruleset/proc/check_finished()
	return FALSE

//////////////////////////////////////////////
//                                          //
//           ROUNDSTART RULESETS            //
//                                          //
//////////////////////////////////////////////

// Checks if candidates are connected and if they are banned or don't want to be the antagonist.
/datum/dynamic_ruleset/roundstart/trim_candidates()
	for(var/mob/dead/new_player/P in candidates)
		if (!P.client || !P.mind) // Are they connected?
			candidates.Remove(P)
			continue
		if(!mode.age_check(P.client))
			candidates.Remove(P)
			continue
		if(P.mind.special_role) // We really don't want to give antag to an antag.
			candidates.Remove(P)
			continue
		if (!(antag_flag in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_flag, ROLE_SYNDICATE)) || (antag_flag_override && is_banned_from(P.ckey, list(antag_flag_override, ROLE_SYNDICATE))))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue

// Checks if candidates are required mob type, connected, banned and if the job is exclusive to the role. 
/datum/dynamic_ruleset/roundstart/delayed/trim_candidates()
	. = ..()
	for (var/mob/P in candidates)
		if (!istype(P, required_type))
			candidates.Remove(P) // Can be a new_player, etc.
			continue
		if(!mode.age_check(P.client))
			candidates.Remove(P)
			continue
		if (!P.client || !P.mind || !P.mind.assigned_role) // Are they connected?
			candidates.Remove(P)
			continue
		if(P.mind.special_role || P.mind.antag_datums?.len > 0) // Are they an antag already?
			candidates.Remove(P)
			continue
		if (!(antag_flag in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_flag, ROLE_SYNDICATE)) || (antag_flag_override && is_banned_from(P.ckey, list(antag_flag_override, ROLE_SYNDICATE))))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if ((exclusive_roles.len > 0) && !(P.mind.assigned_role in exclusive_roles)) // Is the rule exclusive to their job?
			candidates.Remove(P)
			continue

// Do your checks if the ruleset is ready to be executed here.
// Should ignore certain checks if forced is TRUE
/datum/dynamic_ruleset/roundstart/ready(forced = FALSE)
	return ..()
