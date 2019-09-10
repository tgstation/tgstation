/datum/dynamic_ruleset
	/// For admin logging and round end screen.
	var/name = ""
	/// For admin logging and round end screen, do not change this unless making a new rule type.
	var/ruletype = "" 
	/// If set to TRUE, the rule won't be discarded after being executed, and dynamic will call rule_process() every time it ticks.
	var/persistent = FALSE 
	/// If set to TRUE, dynamic mode will be able to draft this ruleset again later on. (doesn't apply for roundstart rules)
	var/repeatable = FALSE 
	/// If set higher than 0 decreases weight by itself causing the ruleset to appear less often the more it is repeated.
	var/repeatable_weight_decrease = 2 
	/// List of players that are being drafted for this rule
	var/list/mob/candidates = list() 
	/// List of players that were selected for this rule
	var/list/datum/mind/assigned = list() 
	/// Preferences flag such as ROLE_WIZARD that need to be turned on for players to be antag
	var/antag_flag = null 
	/// The antagonist datum that is assigned to the mobs mind on ruleset execution.
	var/datum/antagonist/antag_datum = null
	/// The required minimum account age for this ruleset.
	var/minimum_required_age = 7
	/// If set, and config flag protect_roles_from_antagonist is false, then the rule will not pick players from these roles.
	var/list/protected_roles = list()
	/// If set, rule will deny candidates from those roles always.
	var/list/restricted_roles = list() 
	/// If set, rule will only accept candidates from those roles, IMPORTANT: DOES NOT WORK ON ROUNDSTART RULESETS.
	var/list/exclusive_roles = list() 
	/// If set, there needs to be a certain amount of players doing those roles (among the players who won't be drafted) for the rule to be drafted IMPORTANT: DOES NOT WORK ON ROUNDSTART RULESETS.
	var/list/enemy_roles = list() 
	/// If enemy_roles was set, this is the amount of enemy job workers needed per threat_level range (0-10,10-20,etc) IMPORTANT: DOES NOT WORK ON ROUNDSTART RULESETS.
	var/required_enemies = list(1,1,0,0,0,0,0,0,0,0) 
	/// The rule needs this many candidates (post-trimming) to be executed (example: Cult needs 4 players at round start)
	var/required_candidates = 0 
	/// 1 -> 9, probability for this rule to be picked against other rules
	var/weight = 5 
	/// Threat cost for this rule, this is decreased from the mode's threat when the rule is executed.
	var/cost = 0 
	/// A flag that determines how the ruleset is handled
	/// HIGHLANDER_RULESET are rulesets can end the round.
	/// TRAITOR_RULESET and MINOR_RULESET can't end the round and have no difference right now.
	var/flags = 0
	/// Pop range per requirement. If zero defaults to mode's pop_per_requirement.
	var/pop_per_requirement = 0
	/// Requirements are the threat level requirements per pop range.
	/// With the default values, The rule will never get drafted below 10 threat level (aka: "peaceful extended"), and it requires a higher threat level at lower pops.
	var/list/requirements = list(40,30,20,10,10,10,10,10,10,10)
	/// An alternative, static requirement used instead when pop is over mode's high_pop_limit. 
	var/high_population_requirement = 10
	/// Reference to the mode, use this instead of SSticker.mode.
	var/datum/game_mode/dynamic/mode = null
	/// If a role is to be considered another for the purpose of banning.
	var/antag_flag_override = null 
	/// If a ruleset type which is in this list has been executed, then the ruleset will not be executed.
	var/list/blocking_rules = list()
	/// The minimum amount of players required for the rule to be considered. 
	var/minimum_players = 0
	/// The maximum amount of players required for the rule to be considered.
	/// Anything below zero or exactly zero is ignored. 
	var/maximum_players = 0


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
	/// Delay for when execute will get called from the time of post_setup.
	/// Make sure your ruleset works with execute being called during the game when using this.
	var/delay = 0

// Can be drafted when a player joins the server
/datum/dynamic_ruleset/latejoin
	ruletype = "Latejoin"

/// By default, a rule is acceptable if it satisfies the threat level/population requirements.
/// If your rule has extra checks, such as counting security officers, do that in ready() instead
/datum/dynamic_ruleset/proc/acceptable(population = 0, threat_level = 0)
	if(minimum_players > population)
		return FALSE
	if(maximum_players > 0 && population > maximum_players)
		return FALSE
	if (population >= GLOB.dynamic_high_pop_limit)
		return (threat_level >= high_population_requirement)
	else
		pop_per_requirement = pop_per_requirement > 0 ? pop_per_requirement : mode.pop_per_requirement
		var/indice_pop = min(requirements.len,round(population/pop_per_requirement)+1)
		return (threat_level >= requirements[indice_pop])

/// This is called if persistent variable is true everytime SSTicker ticks.
/datum/dynamic_ruleset/proc/rule_process()
	return

/// Called on game mode pre_setup for roundstart rulesets.
/// Do everything you need to do before job is assigned here.
/// IMPORTANT: ASSIGN special_role HERE
/datum/dynamic_ruleset/proc/pre_execute()
	return TRUE

/// Called on post_setup on roundstart and when the rule executes on midround and latejoin.
/// Give your candidates or assignees equipment and antag datum here.
/datum/dynamic_ruleset/proc/execute()
	for(var/datum/mind/M in assigned)
		M.add_antag_datum(antag_datum)
	return TRUE

/// Here you can perform any additional checks you want. (such as checking the map etc)
/// Remember that on roundstart no one knows what their job is at this point.
/// IMPORTANT: If ready() returns TRUE, that means pre_execute() or execute() should never fail!
/datum/dynamic_ruleset/proc/ready(forced = 0)	
	if (required_candidates > candidates.len)		
		return FALSE
	return TRUE

/// Gets weight of the ruleset
/// Note that this decreases weight if repeatable is TRUE and repeatable_weight_decrease is higher than 0
/// Note: If you don't want repeatable rulesets to decrease their weight use the weight variable directly
/datum/dynamic_ruleset/proc/get_weight()
	if(repeatable && weight > 1 && repeatable_weight_decrease > 0)
		for(var/datum/dynamic_ruleset/DR in mode.executed_rules)
			if(istype(DR, type))
				weight = max(weight-repeatable_weight_decrease,1)
	return weight

/// Here you can remove candidates that do not meet your requirements.
/// This means if their job is not correct or they have disconnected you can remove them from candidates here.
/// Usually this does not need to be changed unless you need some specific requirements from your candidates.
/datum/dynamic_ruleset/proc/trim_candidates()
	return

/// Set mode result and news report here.
/// Only called if ruleset is flagged as HIGHLANDER_RULESET
/datum/dynamic_ruleset/proc/round_result()

/// Checks if round is finished, return true to end the round.
/// Only called if ruleset is flagged as HIGHLANDER_RULESET
/datum/dynamic_ruleset/proc/check_finished()
	return FALSE

//////////////////////////////////////////////
//                                          //
//           ROUNDSTART RULESETS            //
//                                          //
//////////////////////////////////////////////

/// Checks if candidates are connected and if they are banned or don't want to be the antagonist.
/datum/dynamic_ruleset/roundstart/trim_candidates()
	for(var/mob/dead/new_player/P in candidates)
		if (!P.client || !P.mind) // Are they connected?
			candidates.Remove(P)
			continue
		if(!mode.check_age(P.client, minimum_required_age))
			candidates.Remove(P)
			continue
		if(P.mind.special_role) // We really don't want to give antag to an antag.
			candidates.Remove(P)
			continue
		if(antag_flag_override)
			if(!(antag_flag_override in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_flag_override, ROLE_SYNDICATE)))
				candidates.Remove(P)
				continue
		else
			if(!(antag_flag in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_flag, ROLE_SYNDICATE)))
				candidates.Remove(P)
				continue

/// Do your checks if the ruleset is ready to be executed here.
/// Should ignore certain checks if forced is TRUE
/datum/dynamic_ruleset/roundstart/ready(forced = FALSE)
	return ..()
