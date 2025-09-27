/**
 * ## Dynamic ruleset datum
 *
 * These datums (which are not singletons) are used by dynamic to create antagonists
 */
/datum/dynamic_ruleset
	/// Human-readable name of the ruleset.
	var/name
	/// Tag the ruleset uses for configuring.
	/// Don't change this unless you know what you're doing.
	var/config_tag

	/// What flag to check for jobbans? Optional, if unset, uses pref_flag
	var/jobban_flag
	/// What flag to check for prefs? Required if the antag has an associated preference
	var/pref_flag
	/// Flags for this ruleset
	var/ruleset_flags = NONE
	/// Points to what antag datum this ruleset will use for generating a preview icon in the prefs menu
	var/preview_antag_datum
	/// List of all minds selected for this ruleset
	VAR_FINAL/list/datum/mind/selected_minds = list()

	/**
	 * The chance the ruleset is picked when selecting from the pool of rulesets.
	 *
	 * This can either be
	 * - A list of weight corresponding to dynamic tiers.
	 * If a tier is not specified, it will use the next highest tier.
	 * Or
	 * - A single weight for all tiers.
	 */
	var/list/weight = 0
	/**
	 * The min population for which this ruleset is available.
	 *
	 * This can either be
	 * - A list of min populations corresponding to dynamic tiers.
	 * If a tier is not specified, it will use the next highest tier.
	 * Or
	 * - A single min population for all tiers.
	 */
	var/list/min_pop = 0
	/// List of roles that are blacklisted from this ruleset
	/// For roundstart rulesets, it will prevent players from being selected for this ruleset if they have one of these roles
	/// For latejoin or midround rulesets, it will prevent players from being assigned to this ruleset if they have one of these roles
	var/list/blacklisted_roles = list()
	/**
	 * How many candidates are needed for this ruleset to be selected?
	 * Ie. "We won't even bother attempting to run this ruleset unless at least x players want to be it"
	 *
	 * This can either be
	 * - A number
	 * Or
	 * - A list in the form of list("denominator" = x, "offset" = y)
	 * which will divide the population size by x and add y to it to calculate the number of candidates
	 */
	var/min_antag_cap = 1
	/**
	 * How many candidates will be this ruleset try to select?
	 * Ie. "We have 10 cadidates, but we only want x of them to be antags"
	 *
	 * This can either be
	 * - A number
	 * Or
	 * - A list in the form of list("denominator" = x, "offset" = y)
	 * which will divide the population size by x and add y to it to calculate the number of candidates
	 *
	 * If null, defaults to min_antag_cap
	 */
	var/max_antag_cap
	/// If set to TRUE, dynamic will be able to draft this ruleset again later on
	var/repeatable = FALSE
	/// Every time this ruleset is selected, the weight will be decreased by this amount
	var/repeatable_weight_decrease = 2
	/// Players whose account is less than this many days old will be filtered out of the candidate list
	var/minimum_required_age = 0
	/// Templates necessary for this ruleset to be executed
	VAR_PROTECTED/list/ruleset_lazy_templates

/datum/dynamic_ruleset/New(list/dynamic_config)
	for(var/new_var in dynamic_config?[config_tag])
		set_config_value(new_var, dynamic_config[config_tag][new_var])

/datum/dynamic_ruleset/Destroy()
	selected_minds = null
	return ..()

/// Used for parsing config entries to validate them
/datum/dynamic_ruleset/proc/set_config_value(new_var, new_val)
	if(!(new_var in vars))
		log_dynamic("Erroneous config edit rejected: [new_var]")
		return FALSE
	var/static/list/locked_config_values = list(
		NAMEOF_STATIC(src, config_tag),
		NAMEOF_STATIC(src, jobban_flag),
		NAMEOF_STATIC(src, pref_flag),
		NAMEOF_STATIC(src, preview_antag_datum),
		NAMEOF_STATIC(src, ruleset_flags),
		NAMEOF_STATIC(src, ruleset_lazy_templates),
		NAMEOF_STATIC(src, selected_minds),
		NAMEOF_STATIC(src, vars),
	)

	if(new_var in locked_config_values)
		log_dynamic("Bad config edit rejected: [new_var]")
		return FALSE
	if(islist(new_val) && (new_var == NAMEOF(src, weight) || new_var == NAMEOF(src, min_pop)))
		new_val = load_tier_list(new_val)

	vars[new_var] = new_val
	return TRUE

/datum/dynamic_ruleset/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, config_tag))
		return FALSE
	return ..()

/// Used to create tier lists for weights and min_pop values
/datum/dynamic_ruleset/proc/load_tier_list(list/incoming_list)
	PRIVATE_PROC(TRUE)

	var/list/tier_list = new /list(4)
	// loads a list of list("2" = 1, "3" = 3) into a list(null, 1, 3, null)
	for(var/tier in incoming_list)
		tier_list[text2num(tier)] = incoming_list[tier]

	// turn list(null, 1, 3, null) into list(1, 1, 3, null)
	for(var/i in 1 to length(tier_list))
		var/val = tier_list[i]
		if(isnum(val))
			break
		for(var/j in i to length(tier_list))
			var/other_val = tier_list[j]
			if(!isnum(other_val))
				continue
			tier_list[i] = other_val
			break

	// turn list(1, 1, 3, null) into list(1, 1, 3, 3)
	for(var/i in length(tier_list) to 1 step -1)
		var/val = tier_list[i]
		if(isnum(val))
			break
		for(var/j in i to 1 step -1)
			var/other_val = tier_list[j]
			if(!isnum(other_val))
				continue
			tier_list[i] = other_val
			break

	// we can assert that tier[1] and tier[4] are not null, but we cannot say the same for tier[2] and tier[3]
	// this can be happen due to the following setup: list(1, null, null, 4)
	// (which is an invalid config, and should be fixed by the operator)
	if(isnull(tier_list[2]))
		tier_list[2] = tier_list[1]
	if(isnull(tier_list[3]))
		tier_list[3] = tier_list[4]

	return tier_list

/**
 * Any additional checks to see if this ruleset can be selected
 */
/datum/dynamic_ruleset/proc/can_be_selected()
	return TRUE

/**
 * Calculates the weight of this ruleset for the given tier.
 *
 * * population_size - How many players are alive
 * * tier - The dynamic tier to calculate the weight for
 */
/datum/dynamic_ruleset/proc/get_weight(population_size = 0, tier = DYNAMIC_TIER_LOW)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(type in SSdynamic.admin_disabled_rulesets)
		return 0
	if(!can_be_selected())
		return 0
	var/final_minpop = islist(min_pop) ? min_pop[tier] : min_pop
	if(final_minpop > population_size)
		return 0

	var/final_weight = islist(weight) ? weight[tier] : weight
	for(var/datum/dynamic_ruleset/other_ruleset as anything in SSdynamic.executed_rulesets)
		if(other_ruleset == src)
			continue
		if(tier != DYNAMIC_TIER_HIGH && (ruleset_flags & RULESET_HIGH_IMPACT) && (other_ruleset.ruleset_flags & RULESET_HIGH_IMPACT))
			return 0
		if(!istype(other_ruleset, type))
			continue
		if(!repeatable)
			return 0
		final_weight -= repeatable_weight_decrease

	return max(final_weight, 0)

/// Returns what the antag cap with the given population is.
/datum/dynamic_ruleset/proc/get_antag_cap(population_size, antag_cap)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (isnum(antag_cap))
		return antag_cap

	return ceil(population_size / antag_cap["denominator"]) + antag_cap["offset"]

/**
 * Prepares the ruleset for execution, primarily used for selecting the players who will be assigned to this ruleset
 *
 * * antag_candidates - List of players who are candidates for this ruleset
 * This list is mutated by this proc!
 *
 * Returns TRUE if execution is ready, FALSE if it should be canceled
 */
/datum/dynamic_ruleset/proc/prepare_execution(population_size = 0, list/mob/antag_candidates = list())
	SHOULD_NOT_OVERRIDE(TRUE)

	// !! THIS SLEEPS !!
	load_templates()

	// This is (mostly) redundant, buuuut the (potential) sleep above makes it iffy, so let's just be safe
	if(!can_be_selected())
		return FALSE

	var/max_candidates = get_antag_cap(population_size, max_antag_cap || min_antag_cap)
	var/min_candidates = get_antag_cap(population_size, min_antag_cap)

	var/list/selected_candidates = select_candidates(antag_candidates, max_candidates)
	if(length(selected_candidates) < min_candidates)
		return FALSE

	for(var/mob/candidate as anything in selected_candidates)
		var/datum/mind/candidate_mind = get_candidate_mind(candidate)
		prepare_for_role(candidate_mind)
		LAZYADDASSOC(SSjob.prevented_occupations, candidate_mind, get_blacklisted_roles()) // this is what makes sure you can't roll traitor as a sec-off
		selected_minds += candidate_mind
		antag_candidates -= candidate

	return TRUE

/// Gets the mind of a candidate, can be overridden to return a different mind if necessary
/datum/dynamic_ruleset/proc/get_candidate_mind(mob/dead/candidate)
	return candidate.mind

/// Returns a list of roles that cannot be selected for this ruleset
/datum/dynamic_ruleset/proc/get_blacklisted_roles()
	return get_config_blacklisted_roles() | get_always_blacklisted_roles()

/// Returns all the jobs the config says this ruleset cannot select
/datum/dynamic_ruleset/proc/get_config_blacklisted_roles()
	SHOULD_NOT_OVERRIDE(TRUE)
	var/list/blacklist = blacklisted_roles.Copy()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		var/protected = (job.job_flags & JOB_ANTAG_PROTECTED)
		var/blacklisted = (job.job_flags & JOB_ANTAG_BLACKLISTED)
		if((CONFIG_GET(flag/protect_roles_from_antagonist) && protected) || blacklisted)
			blacklist |= job.title
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		blacklisted_roles |= JOB_ASSISTANT
	return blacklist

/// Returns a list of roles that are always blacklisted from this ruleset, for mechanical reasons (an AI can't be a changeling)
/datum/dynamic_ruleset/proc/get_always_blacklisted_roles()
	return list(
		JOB_AI,
		JOB_CYBORG,
	)

/// Takes in a list of players and returns a list of players who are valid candidates for this ruleset
/// Don't touch this proc if you need to trim candidates further - override is_valid_candidate() instead
/datum/dynamic_ruleset/proc/trim_candidates(list/mob/antag_candidates)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/list/valid_candidates = list()
	for(var/mob/candidate as anything in antag_candidates)
		var/client/candidate_client = GET_CLIENT(candidate)
		if(isnull(candidate_client))
			continue
		if(candidate_client.get_remaining_days(minimum_required_age) > 0)
			continue
		if(pref_flag && !(pref_flag in candidate_client.prefs.be_special))
			continue
		if(is_banned_from(candidate.ckey, list(ROLE_SYNDICATE, jobban_flag || pref_flag)))
			continue
		if(!is_valid_candidate(candidate, candidate_client))
			continue
		valid_candidates += candidate
	return valid_candidates

/// Returns a list of players picked for this ruleset
/datum/dynamic_ruleset/proc/select_candidates(list/mob/antag_candidates, num_candidates = 0)
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	if(num_candidates <= 0)
		return list()

	// technically not pure
	var/list/resulting_candidates = shuffle(trim_candidates(antag_candidates)) || list()
	if(length(resulting_candidates) <= num_candidates)
		return resulting_candidates

	resulting_candidates.Cut(num_candidates + 1)
	return resulting_candidates

/// Handles loading map templates that this ruleset requires
/datum/dynamic_ruleset/proc/load_templates()
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	for(var/template in ruleset_lazy_templates)
		SSmapping.lazy_load_template(template)

/**
 * Any additional checks to see if this player is a valid candidate for this ruleset
 */
/datum/dynamic_ruleset/proc/is_valid_candidate(mob/candidate, client/candidate_client)
	SHOULD_CALL_PARENT(TRUE)
	return TRUE

/**
 * Handles any special logic that needs to be done for a player before they are assigned to this ruleset
 * This is ran before the player is in their job position, and before they even have a player character
 *
 * Override this proc to do things like set forced jobs, DON'T assign roles or give out equipments here!
 */
/datum/dynamic_ruleset/proc/prepare_for_role(datum/mind/candidate)
	PROTECTED_PROC(TRUE)
	return

/**
 * Executes the ruleset, assigning the selected players to their roles.
 * No backing out now, at this point it's guaranteed to run.
 *
 * Prefer to override assign_role() instead of this proc
 */
/datum/dynamic_ruleset/proc/execute()
	var/list/execute_args = create_execute_args()
	for(var/datum/mind/mind as anything in selected_minds)
		assign_role(arglist(list(mind) + execute_args))

/// Allows you to supply extra arguments to assign_role() if needed
/datum/dynamic_ruleset/proc/create_execute_args()
	return list()

/**
 * Used by the ruleset to actually assign the role to the player
 * This is ran after they have a player character spawned, and after they're in their job (with all their job equipment)
 *
 * Override this proc to give out antag datums or special items or whatever
 */
/datum/dynamic_ruleset/proc/assign_role(datum/mind/candidate)
	PROTECTED_PROC(TRUE)
	stack_trace("Ruleset [src] does not implement assign_role()")
	return

/**
 * Handles setting SSticker news report / mode result for more impactful rulsets
 *
 * Return TRUE if any result was set
 */
/datum/dynamic_ruleset/proc/round_result()
	return FALSE

/**
 * Allows admins to configure rulesets before prepare_execution() is called.
 *
 * Only called if RULESET_ADMIN_CONFIGURABLE is set in ruleset_flags.
 * Also only called by midrounds currently.
 */
/datum/dynamic_ruleset/proc/configure_ruleset(mob/admin)
	stack_trace("Ruleset [type] sets flag RULESET_ADMIN_CONFIGURABLE but does not implement configure_ruleset!")
