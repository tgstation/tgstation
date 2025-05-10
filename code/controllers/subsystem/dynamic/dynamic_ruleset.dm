/datum/dynamic_ruleset
	/// Human-readable name of the ruleset.
	var/name
	/// Tag the ruleset uses for configuring.
	/// Don't change this unless you know what you're doing.
	var/config_tag

	/// What flag to check for jobbans? Optional, if unset, uses pref_flag
	var/jobban_flag
	/// What flag to check for prefs? Required
	var/pref_flag
	/// Flags for this ruleset
	var/ruleset_flags = NONE
	/// Antag datum this ruleset applies
	var/antag_datum
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
	var/list/ruleset_lazy_templates

/datum/dynamic_ruleset/New(list/dynamic_config)
	for(var/nvar in dynamic_config?[config_tag])
		set_config_value(nvar, dynamic_config[config_tag][nvar])

/// Used for parsing config entries to validate them
/datum/dynamic_ruleset/proc/set_config_value(nvar, nval)
	if(!(nvar in vars))
		log_dynamic("Erroneous config edit rejected: [nvar]")
		return FALSE
	switch(nvar)
		if(NAMEOF(src, config_tag), NAMEOF(src, vars), NAMEOF(src, jobban_flag), NAMEOF(src, pref_flag), NAMEOF(src, ruleset_flags), NAMEOF(src, antag_datum), NAMEOF(src, ruleset_lazy_templates), NAMEOF(src, selected_minds))
			log_dynamic("Bad config edit rejected: [nvar]")
			return FALSE
		if(NAMEOF(src, weight))
			if(islist(nval))
				weight = load_tier_list(nval)
				return TRUE
		if(NAMEOF(src, min_pop))
			if(islist(nval))
				min_pop = load_tier_list(nval)
				return TRUE

	vars[nvar] = nval
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
	for(var/i in length(tier_list) to 1)
		var/val = tier_list[i]
		if(isnum(val))
			break
		for(var/j in i to 1)
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
/datum/dynamic_ruleset/proc/can_be_selected(population_size)
	//SHOULD_CALL_PARENT(TRUE)
	return TRUE

/**
 * Calculates the weight of this ruleset for the given tier.
 *
 * * population_size - How many players are alive
 */
/datum/dynamic_ruleset/proc/get_weight(population_size = 0, tier)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!can_be_selected(population_size))
		return 0
	var/final_minpop = islist(min_pop) ? min_pop[tier] : min_pop
	if(final_minpop > population_size)
		return 0

	var/final_weight = islist(weight) ? weight[tier] : weight
	for(var/datum/dynamic_ruleset/other_ruleset as anything in SSdynamic.executed_rulesets)
		if(other_ruleset == src)
			continue
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
	if(!can_be_selected(population_size))
		return FALSE

	var/max_candidates = get_antag_cap(population_size, max_antag_cap || min_antag_cap)
	var/min_candidates = get_antag_cap(population_size, min_antag_cap)

	var/list/selected_candidates = select_candidates(antag_candidates, max_candidates)
	if(length(selected_candidates) < min_candidates)
		return FALSE

	for(var/mob/candidate as anything in selected_candidates)
		var/datum/mind/candidate_mind = get_candidate_mind(candidate)
		prepare_for_role(candidate_mind)
		LAZYADDASSOCLIST(SSjob.prevented_occupations, candidate_mind, get_blacklisted_roles()) // this is what makes sure you can't roll traitor as a sec-off
		selected_minds += candidate_mind
		antag_candidates -= candidate

	return TRUE

/// Gets the mind of a candidate
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
	//.SHOULD_BE_PURE(TRUE)
	PRIVATE_PROC(TRUE)

	var/list/valid_candidates = list()
	for(var/mob/candidate as anything in antag_candidates)
		var/client/candidate_client = GET_CLIENT(candidate)
		if(!candidate_client || !candidate.mind)
			continue
		if(candidate_client.get_remaining_days(minimum_required_age) > 0)
			continue
		if(!(pref_flag in candidate_client.prefs.be_special))
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
	//SHOULD_BE_PURE(TRUE)
	PRIVATE_PROC(TRUE)

	if(num_candidates <= 0)
		return list()

	// technically not pure
	var/list/resulting_candidates = shuffle(trim_candidates(antag_candidates)) || list()
	if(length(resulting_candidates) <= num_candidates)
		return resulting_candidates

	resulting_candidates.Cut(num_candidates + 1)
	return resulting_candidates

/datum/dynamic_ruleset/proc/load_templates()
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	for(var/template in ruleset_lazy_templates)
		SSmapping.lazy_load_template(template)

/**
 * Any additional checks to see if this player is a valid candidate for this ruleset
 */
/datum/dynamic_ruleset/proc/is_valid_candidate(mob/candidate, client/candidate_client)
	//SHOULD_CALL_PARENT(TRUE)
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

/datum/dynamic_ruleset/roundstart
	repeatable = TRUE // We can pick multiple of a roundstart ruleset to "scale up" (spawn more of the same type of antag)

/datum/dynamic_ruleset/roundstart/is_valid_candidate(mob/candidate, client/candidate_client)
	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in SSdynamic.queued_rulesets)
		if(candidate.mind in ruleset.selected_minds)
			return FALSE
	return TRUE

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitors"
	config_tag = "Roundstart Traitor"
	pref_flag = ROLE_TRAITOR
	weight = 10
	min_pop = 3
	max_antag_cap = list("denominator" = 38)

/datum/dynamic_ruleset/roundstart/traitor/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor)

/datum/dynamic_ruleset/roundstart/malf_ai
	name = "Malfunctioning AI"
	config_tag = "Roundstart Malfunctioning AI"
	pref_flag = ROLE_MALF
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30
	max_antag_cap = 1

/datum/dynamic_ruleset/roundstart/malf_ai/get_always_blacklisted_roles()
	return list()

/datum/dynamic_ruleset/roundstart/malf_ai/is_valid_candidate(mob/candidate, client/candidate_client)
	// Malf AI can only go to people who want to be AI
	if(!candidate_client.prefs.job_preferences[/datum/job/ai::title])
		return FALSE
	// And only to people who can actually be AI this round
	if(SSjob.check_job_eligibility(candidate, SSjob.get_job_type(/datum/job/ai), "[name] Candidacy") != JOB_AVAILABLE)
		return FALSE
	return ..()

/datum/dynamic_ruleset/roundstart/malf_ai/prepare_for_role(datum/mind/candidate)
	LAZYSET(SSjob.forced_occupations, candidate, /datum/job/ai::title)

/datum/dynamic_ruleset/roundstart/malf_ai/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/malf_ai)

/datum/dynamic_ruleset/roundstart/blood_brother
	name = "Blood Brothers"
	config_tag = "Roundstart Blood Brothers"
	pref_flag = ROLE_BROTHER
	weight = 5
	max_antag_cap = list("denominator" = 29)
	min_pop = 10

/datum/dynamic_ruleset/roundstart/blood_brother/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/brother)

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	config_tag = "Roundstart Changeling"
	pref_flag = ROLE_CHANGELING
	weight = 3
	min_pop = 15
	max_antag_cap = list("denominator" = 29)

/datum/dynamic_ruleset/roundstart/changeling/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/changeling)

/datum/dynamic_ruleset/roundstart/heretic
	name = "Heretics"
	config_tag = "Roundstart Heretics"
	pref_flag = ROLE_HERETIC
	weight = 3
	max_antag_cap = list("denominator" = 24)
	min_pop = 15

/datum/dynamic_ruleset/roundstart/heretic/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/heretic)

/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	config_tag = "Roundstart Wizard"
	pref_flag = ROLE_WIZARD
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	max_antag_cap = 1
	min_pop = 30
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_WIZARDDEN)

/datum/dynamic_ruleset/roundstart/wizard/assign_role(datum/mind/candidate)
	var/datum/antagonist/wizard/wiz = candidate.add_antag_datum(/datum/antagonist/wizard)
	wiz.send_to_lair()

/datum/dynamic_ruleset/roundstart/wizard/round_result()
	for(var/datum/mind/wiz as anything in selected_minds)
		if(considered_alive(wiz) && !considered_exiled(wiz))
			return FALSE

	SSticker.news_report = WIZARD_KILLED
	return TRUE

/datum/dynamic_ruleset/roundstart/blood_cult
	name = "Blood Cult"
	config_tag = "Roundstart Blood Cult"
	pref_flag = ROLE_CULTIST
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)
	min_antag_cap = list("denominator" = 20, "offset" = 1)
	/// Ratio of cultists getting on the shuttle to be considered a minor win
	var/ratio_to_be_considered_escaped = 0.5

/datum/dynamic_ruleset/roundstart/blood_cult/get_always_blacklisted_roles()
	return ..() | JOB_CHAPLAIN

/datum/dynamic_ruleset/roundstart/blood_cult/create_execute_args()
	return list(new /datum/team/cult)

/datum/dynamic_ruleset/roundstart/blood_cult/assign_role(datum/mind/candidate, datum/team/cult)
	var/datum/antagonist/cult/cultist = candidate.add_antag_datum(/datum/antagonist/cult, cult)
	if(get_most_experienced(selected_minds, pref_flag) == candidate)
		cultist.make_cult_leader()

/datum/dynamic_ruleset/roundstart/blood_cult/round_result()
	var/datum/team/cult/main_cult = locate() in GLOB.antagonist_teams
	if(main_cult.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
		return TRUE

	var/num_cultists = main_cult.size_at_maximum || 100
	var/ratio_to_be_considered_escaped = 0.5
	var/escaped_cultists = 0
	for(var/datum/mind/escapee as anything in main_cult.members)
		if(considered_escaped(escapee))
			escaped_cultists++

	SSticker.mode_result = "loss - staff stopped the cult"
	SSticker.news_report = (escaped_cultists / num_cultists) >= ratio_to_be_considered_escaped ? CULT_ESCAPE : CULT_FAILURE
	return TRUE

/datum/dynamic_ruleset/roundstart/nukies
	name = "Nuclear Operatives"
	config_tag = "Roundstart Nukeops"
	pref_flag = ROLE_NUCLEAR_OPERATIVE
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30
	min_antag_cap = list("denominator" = 18, "offset" = 1)
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_NUKIEBASE)

/datum/dynamic_ruleset/roundstart/nukies/create_execute_args()
	return list(new /datum/team/nuclear)

/datum/dynamic_ruleset/roundstart/nukies/assign_role(datum/mind/candidate, datum/team/nuke_team)
	if(get_most_experienced(selected_minds, pref_flag) == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader, nuke_team)
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop, nuke_team)

/datum/dynamic_ruleset/roundstart/nukies/round_result()
	var/datum/antagonist/nukeop/nukie = selected_minds[1].has_antag_datum(/datum/antagonist/nukeop)
	var/datum/team/nuclear/nuke_team = nukie.get_team()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

/datum/dynamic_ruleset/roundstart/nukies/clown
	name = "Clown Operatives"
	config_tag = "Roundstart Clownops"
	pref_flag = ROLE_CLOWN_OPERATIVE
	weight = 0

/datum/dynamic_ruleset/roundstart/nukies/clown/assign_role(datum/mind/candidate, datum/team/nuke_team)
	if(get_most_experienced(selected_minds, pref_flag) == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader/clownop)
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop/clownop)

/datum/dynamic_ruleset/roundstart/revolution
	name = "Revolution"
	config_tag = "Roundstart Revolution"
	pref_flag = ROLE_REV_HEAD
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_antag_cap = 3
	/// How many heads of staff are required to be on the station for this to be selected
	var/heads_necessary = 3

/datum/dynamic_ruleset/roundstart/revolution/can_be_selected(population_size, list/antag_candidates)
	var/head_check = 0
	for(var/mob/player as anything in GLOB.alive_player_list)
		if (player.mind.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
			head_check++
	return head_check >= heads_necessary

/datum/dynamic_ruleset/roundstart/revolution/get_always_blacklisted_roles()
	. = ..()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		if(job.job_flags & JOB_HEAD_OF_STAFF)
			. |= job.title

/datum/dynamic_ruleset/roundstart/revolution/is_valid_candidate(mob/candidate, client/candidate_client)
	return ..() && can_be_headrev(candidate.mind)

/datum/dynamic_ruleset/roundstart/revolution/assign_role(datum/mind/candidate)
	LAZYADD(candidate.special_roles, "Dormant Head Revolutionary")
	addtimer(CALLBACK(src, PROC_REF(reveal_head), candidate), 7 MINUTES, TIMER_DELETE_ME)

/// Reveals the headrev after a set amount of time
/datum/dynamic_ruleset/roundstart/revolution/proc/reveal_head(datum/mind/candidate)
	LAZYREMOVE(candidate.special_roles, "Dormant Head Revolutionary")
	if(!can_be_headrev(candidate))
		log_dynamic("[config_tag]: [key_name(candidate)] was not eligible to be a headrev after the timer expired - finding a replacement.")
		find_another_headrev()
		return
	GLOB.revolution_handler ||= new()
	var/datum/antagonist/rev/head/new_head = new()
	new_head.give_flash = TRUE
	new_head.give_hud = TRUE
	new_head.remove_clumsy = TRUE
	candidate.add_antag_datum(new_head, GLOB.revolution_handler.revs)
	GLOB.revolution_handler.start_revolution()

/datum/dynamic_ruleset/roundstart/revolution/proc/find_another_headrev()
	for(var/mob/living/carbon/human/upstanding_citizen in GLOB.player_list)
		if(!can_be_headrev(upstanding_citizen.mind))
			continue
		reveal_head(upstanding_citizen.mind)
		log_dynamic("[config_tag]: [key_name(upstanding_citizen)] was selected as a replacement headrev.")
		return

	log_dynamic("[config_tag]: Failed to find a replacement headrev.")
	addtimer(CALLBACK(src, PROC_REF(revs_execution_failed)), 1 MINUTES, TIMER_UNIQUE|TIMER_DELETE_ME)

/datum/dynamic_ruleset/roundstart/revolution/proc/revs_execution_failed()
	if(GLOB.revolution_handler)
		return
	// Execution is effectively cancelled by this point, but it's not like we can go back and refund it
	name += " (Canceled)"
	log_dynamic("[config_tag]: All headrevs were ineligible after the timer expired, and no replacements could be found. Ruleset canceled.")
	message_admins("[config_tag]: All headrevs were ineligible after the timer expired, and no replacements could be found. Ruleset canceled.")

/datum/dynamic_ruleset/roundstart/spies
	name = "Spies"
	config_tag = "Roundstart Spies"
	pref_flag = ROLE_SPY
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 10
	min_antag_cap = list("denominator" = 20, "offset" = 1)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/spies/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/spy)

/datum/dynamic_ruleset/roundstart/extended
	name = "Extended"
	config_tag = "Extended"
	weight = 0
	min_antag_cap = 0

/datum/dynamic_ruleset/roundstart/extended/execute()
	for(var/category in SSdynamic.rulesets_to_spawn)
		SSdynamic.rulesets_to_spawn[category] = 0

/datum/dynamic_ruleset/roundstart/meteor
	name = "Meteor"
	config_tag = "Meteor"
	weight = 0
	min_antag_cap = 0

/datum/dynamic_ruleset/roundstart/meteor/execute()
	GLOB.meteor_mode ||= new()
	GLOB.meteor_mode.start_meteor()

/datum/dynamic_ruleset/roundstart/nations
	name = "Nations"
	config_tag = "Nations"
	weight = 0
	min_antag_cap = 0

/datum/dynamic_ruleset/roundstart/nations/execute()
	//notably assistant is not in this list to prevent the round turning into BARBARISM instantly, and silicon is in this list for UN
	var/list/department_types = list(
		/datum/job_department/silicon, //united nations
		/datum/job_department/cargo,
		/datum/job_department/engineering,
		/datum/job_department/medical,
		/datum/job_department/science,
		/datum/job_department/security,
		/datum/job_department/service,
	)

	for(var/department_type in department_types)
		create_separatist_nation(department_type, announcement = FALSE, dangerous = FALSE, message_admins = FALSE)

	GLOB.round_default_lawset = /datum/ai_laws/united_nations

/datum/dynamic_ruleset/midround
	/// MIDROUND_RULESET_STYLE_LIGHT or MIDROUND_RULESET_STYLE_HEAVY - determines which pool it enters
	var/midround_type

/**
 * Collect candidates handles getting the broad pool of players we want to pick from
 * This differs from trim candidates which filters the pool of players down to just people who want the antag (and are eligible)
 * You can sleep in this, say, if you wanted to poll players.
 */
/datum/dynamic_ruleset/midround/proc/collect_candidates()
	return list()

/datum/dynamic_ruleset/midround/from_ghosts
	///Path of an item to show up in ghost polls for applicants to sign up.
	var/signup_atom_appearance = /obj/structure/sign/poster/contraband/syndicate_recruitment

/datum/dynamic_ruleset/midround/from_ghosts/can_be_selected(population_size, list/antag_candidates)
	SHOULD_CALL_PARENT(TRUE)
	return ..() && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT)

/datum/dynamic_ruleset/from_ghosts/get_candidate_mind(mob/dead/candidate)
	// Ghost roles will always get a fresh mind
	return new /datum/mind(candidate.key)

/datum/dynamic_ruleset/midround/from_ghosts/collect_candidates()
	return SSpolling.poll_ghost_candidates(
		question = "Looking for volunteers to become [span_notice(pref_flag)] for [span_danger(name)]",
		check_jobban = jobban_flag || pref_flag,
		role = pref_flag,
		poll_time = 30 SECONDS,
		alert_pic = signup_atom_appearance,
		role_name_text = pref_flag,
	)

/// Helper to make a human from a ghost, with their preferences
/datum/dynamic_ruleset/midround/from_ghosts/proc/make_human(mob/dead/ghost, atom/spawn_loc)
	var/mob/living/carbon/human/new_character = make_body(ghost)
	new_character.dna.remove_all_mutations()
	new_character.forceMove(spawn_loc)
	return new_character

/datum/dynamic_ruleset/midround/from_ghosts/wizard
	name = "Wizard"
	config_tag = "Midround Wizard"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_WIZARD_MIDROUND
	jobban_flag = ROLE_WIZARD
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	max_antag_cap = 1
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_WIZARDDEN)
	signup_atom_appearance = /obj/item/clothing/head/wizard

/datum/dynamic_ruleset/midround/from_ghosts/wizard/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/wizard = make_human(candidate.current, pick(GLOB.wizardstart))
	candidate.transfer_to(wizard, force_key_move = TRUE)
	candidate.add_antag_datum(/datum/antagonist/wizard)

/datum/dynamic_ruleset/midround/from_ghosts/nukies
	name = "Nuclear Operatives"
	config_tag = "Midround Nukeops"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_OPERATIVE_MIDROUND
	jobban_flag = ROLE_NUCLEAR_OPERATIVE
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30
	min_antag_cap = list("denominator" = 18, "offset" = 1)
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_NUKIEBASE)
	signup_atom_appearance = /obj/machinery/nuclearbomb/syndicate

/datum/dynamic_ruleset/midround/from_ghosts/nukies/create_execute_args()
	return list(new /datum/team/nuclear)

/datum/dynamic_ruleset/midround/from_ghosts/nukies/assign_role(datum/mind/candidate, datum/team/nuclear/nuke_team)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, pick(GLOB.nukeop_start))
	candidate.transfer_to(new_character, force_key_move = TRUE)
	if(get_most_experienced(selected_minds, pref_flag) == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader, nuke_team)
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop, nuke_team)

/datum/dynamic_ruleset/midround/from_ghosts/nukies/round_result()
	var/datum/antagonist/nukeop/nukie = selected_minds[1].has_antag_datum(/datum/antagonist/nukeop)
	var/datum/team/nuclear/nuke_team = nukie.get_team()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

/datum/dynamic_ruleset/midround/from_ghosts/nukies/clown
	name = "Clown Operatives"
	config_tag = "Midround Clownops"
	pref_flag = ROLE_CLOWN_OPERATIVE_MIDROUND
	jobban_flag = ROLE_CLOWN_OPERATIVE
	weight = 0
	signup_atom_appearance = /obj/machinery/nuclearbomb/syndicate/bananium

/datum/dynamic_ruleset/midround/from_ghosts/nukies/clown/assign_role(datum/mind/candidate, datum/team/nuclear/nuke_team)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, pick(GLOB.nukeop_start))
	candidate.transfer_to(new_character, force_key_move = TRUE)
	if(get_most_experienced(selected_minds, pref_flag) == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader/clownop, nuke_team)
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop/clownop, nuke_team)

/datum/dynamic_ruleset/midround/from_ghosts/blob
	name = "Blob"
	config_tag = "Blob"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_BLOB
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30
	max_antag_cap = 1
	signup_atom_appearance = /obj/structure/blob/normal

/datum/dynamic_ruleset/midround/from_ghosts/blob/assign_role(datum/mind/candidate)
	candidate.current.become_overmind()

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph
	name = "Alien Infestation"
	config_tag = "Xenomorph"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_ALIEN
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 5,
	)
	min_pop = 30
	max_antag_cap = 1
	min_antag_cap = 1
	signup_atom_appearance = /mob/living/basic/alien

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/New(list/dynamic_config)
	. = ..()
	max_antag_cap += prob(50) // 50% chance to get a second xeno, free!

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/can_be_selected(population_size, list/antag_candidates)
	return ..() && length(find_vents()) > 0

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/create_execute_args()
	return list(find_vents())

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/assign_role(datum/mind/candidate, list/vent_list)
	var/obj/vent = length(vent_list) >= 2 ? pick_n_take(vent_list) : vent_list[1]
	var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
	candidate.transfer_to(new_xeno, force_key_move = TRUE)
	new_xeno.move_into_vent(vent)

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/proc/find_vents()
	var/list/vents = list()
	var/list/vent_pumps = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump)
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent as anything in vent_pumps)
		if(QDELETED(temp_vent))
			continue
		if(!is_station_level(temp_vent.loc.z) || temp_vent.welded)
			continue
		var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
		if(!temp_vent_parent)
			continue
		// Stops Aliens getting stuck in small networks.
		// See: Security, Virology
		if(length(temp_vent_parent.other_atmos_machines) <= 20)
			continue
		vents += temp_vent
	return vents

/datum/dynamic_ruleset/midround/from_ghosts/nightmare
	name = "Nightmare"
	config_tag = "Nightmare"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_NIGHTMARE
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 15
	max_antag_cap = 1
	signup_atom_appearance = /obj/item/light_eater

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/can_be_selected(population_size, list/antag_candidates)
	return ..() && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE))

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE))
	candidate.add_antag_datum(/datum/antagonist/nightmare)
	candidate.transfer_to(new_character)
	new_character.set_species(/datum/species/shadow/nightmare)
	playsound(new_character, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon
	name = "Space Dragon"
	config_tag = "Space Dragon"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_SPACE_DRAGON
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 3,
		DYNAMIC_TIER_MEDIUMHIGH = 5,
	)
	min_pop = 30
	max_antag_cap = 1
	signup_atom_appearance = /mob/living/basic/space_dragon

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/can_be_selected(population_size, list/antag_candidates)
	return ..() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/assign_role(datum/mind/candidate)
	var/mob/living/basic/space_dragon/dragon = new(find_space_spawn())
	candidate.transfer_to(dragon, force_key_move = TRUE)
	candidate.add_antag_datum(/datum/antagonist/space_dragon)
	playsound(dragon, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/execute()
	. = ..()
	priority_announce("A large organic energy flux has been recorded near of [station_name()], please stand-by.", "Lifesign Alert")

/datum/dynamic_ruleset/midround/from_ghosts/abductors
	name = "Abductors"
	config_tag = "Abductors"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_ABDUCTOR
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 20
	min_antag_cap = 2
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_ABDUCTOR_SHIPS)
	signup_atom_appearance = /obj/item/melee/baton/abductor

/datum/dynamic_ruleset/midround/from_ghosts/space_ninja
	name = "Space Ninja"
	config_tag = "Space Ninja"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_NINJA
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	max_antag_cap = 1
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_NINJA_HOLDING_FACILITY)
	signup_atom_appearance = /obj/item/energy_katana

/datum/dynamic_ruleset/midround/from_ghosts/space_ninja/can_be_selected(population_size, list/antag_candidates)
	return ..() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/space_ninja/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, find_space_spawn())
	candidate.transfer_to(new_character, force_key_move = TRUE)
	candidate.add_antag_datum(/datum/antagonist/ninja)

/datum/dynamic_ruleset/midround/from_ghosts/spiders
	name = "Spiders"
	config_tag = "Spiders"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_SPIDER
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	max_antag_cap = 2 // determines how many eggs spawn
	min_antag_cap = 0 // eggs will spawn if there are no ghosts around

// An abornmal ruleset that selects no players, but just spawns eggs
/datum/dynamic_ruleset/midround/from_ghosts/spiders/execute()
	create_midwife_eggs(get_antag_cap(length(GLOB.alive_player_list), max_antag_cap))

/datum/dynamic_ruleset/midround/from_ghosts/revenant
	name = "Revenant"
	config_tag = "Revenant"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_REVENANT
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 10
	max_antag_cap = 1
	signup_atom_appearance = /mob/living/basic/revenant
	/// There must be this many dead mobs on the station for a revenant to spawn (of all mob types, not just humans)
	/// Remember there's usually 2-3 that spawn in the Morgue roundstart, so adjust this accordingly
	var/required_station_corpses = 10

/datum/dynamic_ruleset/midround/from_ghosts/revenant/can_be_selected(population_size, list/antag_candidates)
	if(!..())
		return FALSE
	var/num_station_corpses = 0
	for(var/mob/deceased as anything in GLOB.dead_mob_list)
		var/turf/deceased_turf = get_turf(deceased)
		if(is_station_level(deceased_turf?.z))
			num_station_corpses++

	return num_station_corpses > required_station_corpses

/datum/dynamic_ruleset/midround/from_ghosts/revenant/assign_role(datum/mind/candidate)
	var/mob/living/basic/revenant/revenant = new(pick(get_revenant_spawns()))
	candidate.transfer_to(revenant, force_key_move = TRUE)

/datum/dynamic_ruleset/midround/from_ghosts/revenant/proc/get_revenant_spawns()
	var/list/spawn_locs = list()
	for(var/mob/deceased in GLOB.dead_mob_list)
		var/turf/deceased_turf = get_turf(deceased)
		if(is_station_level(deceased_turf?.z))
			spawn_locs += deceased_turf
	if(!length(spawn_locs) || length(spawn_locs) < 12) // get a comfortably large pool of spawnpoints
		for(var/obj/structure/bodycontainer/corpse_container in GLOB.bodycontainers)
			var/turf/container_turf = get_turf(corpse_container)
			if(is_station_level(container_turf?.z))
				spawn_locs += container_turf
	if(!length(spawn_locs) || length(spawn_locs) < 4) // get a comfortably large pool of spawnpoints
		for(var/obj/effect/landmark/carpspawn/carpspawn in GLOB.landmarks_list)
			spawn_locs += carpspawn.loc

	return spawn_locs

/datum/dynamic_ruleset/midround/from_ghosts/pirates
	name = "Pirates"
	config_tag = "Light Pirates"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = "Space Pirates"
	ruleset_flags = RULESET_INVADER
	weight = 3
	min_pop = 15
	min_antag_cap = 0 // ship will spawn if there are no ghosts around
	signup_atom_appearance = /obj/item/clothing/head/costume/pirate

/datum/dynamic_ruleset/midround/from_ghosts/pirates/can_be_selected(population_size, list/antag_candidates)
	return ..() && !SSmapping.is_planetary() && length(pirate_pool()) > 0

// An abornmal ruleset that selects no players, but just spawns a pirate ship
/datum/dynamic_ruleset/midround/from_ghosts/pirates/execute()
	send_pirate_threat(pirate_pool())

/datum/dynamic_ruleset/midround/from_ghosts/pirates/proc/pirate_pool()
	return GLOB.light_pirate_gangs

/datum/dynamic_ruleset/midround/from_ghosts/pirates/heavy
	name = "Pirates"
	config_tag = "Heavy Pirates"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = "Space Pirates"
	ruleset_flags = RULESET_INVADER
	weight = 3
	min_pop = 25
	min_antag_cap = 0 // ship will spawn if there are no ghosts around

/datum/dynamic_ruleset/midround/from_ghosts/pirates/heavy/pirate_pool()
	return GLOB.heavy_pirate_gangs

/datum/dynamic_ruleset/midround/from_ghosts/space_changeling
	name = "Space Changeling"
	config_tag = "Midround Changeling"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_CHANGELING_MIDROUND
	jobban_flag = ROLE_CHANGELING
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 15
	max_antag_cap = 1
	signup_atom_appearance = /obj/effect/meteor/meaty/changeling

/datum/dynamic_ruleset/midround/from_ghosts/space_changeling/assign_role(datum/mind/candidate)
	generate_changeling_meteor(candidate)

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone
	name = "Paradox Clone"
	config_tag = "Paradox Clone"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_PARADOX_CLONE
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 10
	max_antag_cap = 1
	signup_atom_appearance = /obj/effect/bluespace_stream

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/can_be_selected(population_size, list/antag_candidates)
	return ..() && !isnull(find_clone()) && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE))

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/good_version = find_clone()
	var/mob/living/carbon/human/bad_version = good_version.make_full_human_copy(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE))
	candidate.transfer_to(bad_version, force_key_move = TRUE)

	var/datum/antagonist/paradox_clone/antag = candidate.add_antag_datum(/datum/antagonist/paradox_clone)
	antag.original_ref = WEAKREF(good_version.mind)
	antag.setup_clone()

	playsound(bad_version, 'sound/items/weapons/zapbang.ogg', 30, TRUE)
	bad_version.put_in_hands(new /obj/item/storage/toolbox/mechanical()) //so they dont get stuck in maints

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/proc/find_clone()
	var/list/possible_targets = list()

	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.client || !player.mind || player.stat != CONSCIOUS)
			continue
		if(!(player.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		possible_targets += player

	if(length(possible_targets))
		return pick(possible_targets)
	return null

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker
	name = "Voidwalker"
	config_tag = "Voidwalker"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_VOIDWALKER
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 15
	max_antag_cap = 1
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_VOIDWALKER_VOID)
	signup_atom_appearance = /obj/item/clothing/head/helmet/skull/cosmic

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker/can_be_selected(population_size, list/antag_candidates)
	return ..() && !SSmapping.is_planetary() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, find_space_spawn())
	candidate.transfer_to(new_character, force_key_move = TRUE)
	candidate.add_antag_datum(/datum/antagonist/voidwalker)
	candidate.current.set_species(/datum/species/voidwalker)

	playsound(new_character, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/dynamic_ruleset/midround/from_living
	min_antag_cap = 1
	max_antag_cap = 1

/datum/dynamic_ruleset/midround/from_living/set_config_value(nvar, nval)
	if(nvar == NAMEOF(src, min_antag_cap) || nvar == NAMEOF(src, max_antag_cap))
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_living/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, min_antag_cap) || var_name == NAMEOF(src, max_antag_cap))
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_living/collect_candidates()
	return GLOB.alive_player_list

/datum/dynamic_ruleset/midround/from_living/is_valid_candidate(mob/candidate, client/candidate_client)
	if(candidate.stat == DEAD)
		return FALSE
	// only pick members of the crew
	if(!job_check(candidate))
		return FALSE
	if(!antag_check(candidate))
		return FALSE
	// checks for stuff like bitrunner avatars and ghost mafia
	if(HAS_TRAIT(candidate, TRAIT_MIND_TEMPORARILY_GONE) || HAS_TRAIT(candidate, TRAIT_TEMPORARY_BODY))
		return FALSE
	if(SEND_SIGNAL(candidate, COMSIG_MOB_MIND_BEFORE_MIDROUND_ROLL, src, pref_flag) & CANCEL_ROLL)
		return FALSE
	return TRUE

/// Checks if the candidate is a valid job for this ruleset - by default you probably only want crew members
/datum/dynamic_ruleset/midround/from_living/proc/job_check(mob/candidate)
	return !(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER)

/// Checks if the candidate is an antag - most of the time you don't want to double dip
/datum/dynamic_ruleset/midround/from_living/proc/antag_check(mob/candidate)
	return !candidate.is_antag()

/datum/dynamic_ruleset/midround/from_living/traitor
	name = "Traitor"
	config_tag = "Midround Traitor"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_SLEEPER_AGENT
	jobban_flag = ROLE_TRAITOR
	weight = 10
	min_pop = 3
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/midround/from_living/traitor/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor)

/datum/dynamic_ruleset/midround/from_living/malf_ai
	name = "Malfunctioning AI"
	config_tag = "Midround Malfunctioning AI"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_MALF_MIDROUND
	jobban_flag = ROLE_MALF
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30

/datum/dynamic_ruleset/midround/from_living/malf_ai/get_always_blacklisted_roles()
	return list()

/datum/dynamic_ruleset/midround/from_living/malf_ai/job_check(mob/candidate)
	return istype(candidate.mind.assigned_role, /datum/job/ai)

/datum/dynamic_ruleset/midround/from_living/malf_ai/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/malf_ai)

/datum/dynamic_ruleset/midround/from_living/blob
	name = "Blob Infection"
	config_tag = "Midround Blob"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_BLOB_INFECTION
	jobban_flag = ROLE_BLOB
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30

/datum/dynamic_ruleset/midround/from_living/blob/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/blob/infection)
	notify_ghosts(
		"[candidate.current.real_name] has become a blob host!",
		source = candidate.current,
		header = "So Bulbous...",
	)

/datum/dynamic_ruleset/midround/from_living/obsesed
	name = "Obsessed"
	config_tag = "Midround Obsessed"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_OBSESSED
	blacklisted_roles = list()
	weight = list(
		DYNAMIC_TIER_LOWMEDIUM = 5,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 1,
	)
	min_pop = 5

/datum/dynamic_ruleset/midround/from_living/obsesed/is_valid_candidate(mob/candidate, client/candidate_client)
	return ..() && !!candidate.get_organ_by_type(/obj/item/organ/brain)

/datum/dynamic_ruleset/midround/from_living/obsesed/antag_check(mob/candidate)
	// Obsessed is a special case, it can select other antag players
	return !candidate.mind.has_antag_datum(/datum/antagonist/obsessed)

/datum/dynamic_ruleset/midround/from_living/obsesed/assign_role(datum/mind/candidate)
	var/obj/item/organ/brain/brain = candidate.current.get_organ_by_type(__IMPLIED_TYPE__)
	brain.brain_gain_trauma(/datum/brain_trauma/special/obsessed)
	notify_ghosts(
		"[candidate.current.real_name] has developed an obsession with someone!",
		source = candidate.current,
		header = "Love Can Bloom",
	)

/datum/dynamic_ruleset/latejoin
	min_antag_cap = 1
	max_antag_cap = 1

/datum/dynamic_ruleset/latejoin/from_living/set_config_value(nvar, nval)
	if(nvar == NAMEOF(src, min_antag_cap) || nvar == NAMEOF(src, max_antag_cap))
		return FALSE
	return ..()

/datum/dynamic_ruleset/latejoin/from_living/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, min_antag_cap) || var_name == NAMEOF(src, max_antag_cap))
		return FALSE
	return ..()

/datum/dynamic_ruleset/latejoin/traitor
	name = "Traitor"
	config_tag = "Latejoin Traitor"
	pref_flag = ROLE_SYNDICATE_INFILTRATOR
	jobban_flag = ROLE_TRAITOR
	weight = 10
	min_pop = 3
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/latejoin/traitor/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor)

/datum/dynamic_ruleset/latejoin/heretic
	name = "Heretic"
	config_tag = "Latejoin Heretic"
	pref_flag = ROLE_HERETIC_SMUGGLER
	jobban_flag = ROLE_HERETIC
	weight = 3
	min_pop = 15
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_HERETIC_SACRIFICE)
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/latejoin/heretic/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/heretic)

/datum/dynamic_ruleset/latejoin/changeling
	name = "Changelings"
	config_tag = "Latejoin Changeling"
	pref_flag = ROLE_STOWAWAY_CHANGELING
	jobban_flag = ROLE_CHANGELING
	weight = 3
	min_pop = 15
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/latejoin/changeling/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/changeling)

/datum/dynamic_ruleset/latejoin/revolution
	name = "Revolution"
	config_tag = "Latejoin Revolution"
	pref_flag = ROLE_PROVOCATEUR
	jobban_flag = ROLE_REV_HEAD
	weight = 1
	min_pop = 30
	/// How many heads of staff are required to be on the station for this to be selected
	var/heads_necessary = 3

/datum/dynamic_ruleset/latejoin/revolution/can_be_selected(population_size, list/antag_candidates)
	var/head_check = 0
	for(var/mob/player as anything in GLOB.alive_player_list)
		if (player.mind.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
			head_check++
	return head_check >= heads_necessary

/datum/dynamic_ruleset/latejoin/revolution/get_always_blacklisted_roles()
	. = ..()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		if(job.job_flags & JOB_HEAD_OF_STAFF)
			. |= job.title

/datum/dynamic_ruleset/latejoin/revolution/is_valid_candidate(mob/candidate, client/candidate_client)
	return ..() && can_be_headrev(candidate.mind)

/datum/dynamic_ruleset/latejoin/revolution/assign_role(datum/mind/candidate)
	LAZYADD(candidate.special_roles, "Dormant Head Revolutioanry")
	addtimer(CALLBACK(src, PROC_REF(reveal_head), candidate), 1 MINUTES, TIMER_DELETE_ME)

/datum/dynamic_ruleset/latejoin/revolution/proc/reveal_head(datum/mind/candidate)
	LAZYREMOVE(candidate.special_roles, "Dormant Head Revolutioanry")
	if(!can_be_headrev(candidate))
		name += " (Canceled)"
		log_dynamic("[config_tag]: [key_name(candidate)] was ineligible after the timer expired. Ruleset canceled.")
		message_admins("[config_tag]: [key_name(candidate)] was ineligible after the timer expired. Ruleset canceled.")
		return
	GLOB.revolution_handler ||= new()
	var/datum/antagonist/rev/head/new_head = new()
	new_head.give_flash = TRUE
	new_head.give_hud = TRUE
	new_head.remove_clumsy = TRUE
	candidate.add_antag_datum(new_head, GLOB.revolution_handler.revs)
	GLOB.revolution_handler.start_revolution()
