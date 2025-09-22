/// Base macro-option interface and runner utilities for the AI-controlled crew system.

/datum/ai_option
	/// Unique identifier surfaced to the planner and telemetry.
	var/id = "base_option"
	/// Human-readable label used for admin tooling.
	var/display_name = "Base Option"
	/// Action taxonomy category (Routine, Logistics, Medical, Security, Support).
	var/category = AI_ACTION_CATEGORY_SUPPORT
	/// Relative priority hint; higher values indicate stronger suggestions.
	var/priority = AI_OPTION_PRIORITY_DEFAULT
	/// Default timeout (deciseconds) before the option is considered stale.
	var/timeout_ds = AI_OPTION_DEFAULT_TIMEOUT_DS
	/// Reference back to the owning controller.
	var/datum/ai_controller/crew_human/controller
	/// Cached blackboard pointer for quick data access.
	var/datum/ai_blackboard/blackboard
	/// Cached crew profile pointer for heuristics.
	var/datum/ai_crew_profile/profile
	/// Current lifecycle state.
	var/state = AI_OPTION_STATE_IDLE
	/// Last computed proposal score (for debugging/telemetry).
	var/last_score = 0
	/// Timestamp of the most recent start call.
	var/started_at_ds = 0
	/// Default planner arguments exposed alongside the option id.
	var/list/default_args = list()

/datum/ai_option/proc/attach_to_controller(datum/ai_controller/crew_human/new_controller)
	controller = new_controller
	blackboard = controller?.get_blackboard_component()
	profile = controller?.profile
	on_attached()

/datum/ai_option/proc/on_attached()
	return

/datum/ai_option/proc/on_profile_updated(datum/ai_crew_profile/new_profile)
	profile = new_profile

/datum/ai_option/proc/reset()
	state = AI_OPTION_STATE_IDLE
	last_score = 0
	started_at_ds = 0

/datum/ai_option/proc/get_identifier()
	return id

/datum/ai_option/proc/get_display_name()
	return display_name

/datum/ai_option/proc/get_category()
	return category

/datum/ai_option/proc/get_priority()
	return priority

/datum/ai_option/proc/get_timeout_ds()
	return timeout_ds

/datum/ai_option/proc/get_default_args()
	return default_args?.Copy() || list()

/datum/ai_option/proc/precond(datum/ai_context_snapshot/snapshot)
	if(!controller || QDELETED(controller))
		return FALSE
	if(!controller.pawn)
		return FALSE
	if(!snapshot)
		return FALSE
	return TRUE

/datum/ai_option/proc/compute_score(datum/ai_context_snapshot/snapshot, datum/ai_control_policy/policy)
	// Base implementation offers no preference; override in concrete options.
	return 0

/datum/ai_option/proc/get_metadata(datum/ai_context_snapshot/snapshot)
	return list()

/datum/ai_option/proc/build_proposal(datum/ai_context_snapshot/snapshot, datum/ai_control_policy/policy)
	if(!precond(snapshot))
		return null
	var/score = compute_score(snapshot, policy)
	if(isnull(score))
		return null
	last_score = score
	return list(
		"id" = get_identifier(),
		"display_name" = get_display_name(),
		"category" = get_category(),
		"priority" = get_priority(),
		"score" = score,
		"args" = get_default_args(),
		"timeout_ds" = get_timeout_ds(),
		"metadata" = get_metadata(snapshot),
	)

/datum/ai_option/proc/start(list/args)
	state = AI_OPTION_STATE_RUNNING
	started_at_ds = world.time
	return TRUE

/datum/ai_option/proc/step()
	// Placeholder for future execution logic; return current state.
	return state

/datum/ai_option/proc/complete()
	state = AI_OPTION_STATE_COMPLETE
	return TRUE

/datum/ai_option/proc/abort(reason)
	state = AI_OPTION_STATE_ABORTED
	return TRUE


/datum/ai_option_role
	/// Identifier for logging/admin surfaces.
	var/id = "base_role"
	/// Human readable name.
	var/display_name = "Base Role"
	/// Option runner this pack is attached to.
	var/datum/ai_option_runner/runner

/datum/ai_option_role/proc/register_with_runner(datum/ai_option_runner/new_runner)
	runner = new_runner
	on_registered()

/datum/ai_option_role/proc/on_registered()
	return

/datum/ai_option_role/proc/add_option(datum/ai_option/option)
	if(!runner || !option)
		return
	runner.register_option(option)


/datum/ai_option_runner
	/// Owner controller reference.
	var/datum/ai_controller/crew_human/controller
	/// Active crew profile pointer for convenience.
	var/datum/ai_crew_profile/profile
	/// Cached policy reference for multiplier queries.
	var/datum/ai_control_policy/policy
	/// Options keyed by identifier for quick lookup.
	var/list/options = list()
	/// Role packs currently registered.
	var/list/roles = list()

/datum/ai_option_runner/New(datum/ai_controller/crew_human/new_controller)
	..()
	set_controller(new_controller)
	load_default_role_packs()

/datum/ai_option_runner/proc/set_controller(datum/ai_controller/crew_human/new_controller)
	controller = new_controller
	profile = controller?.profile
	policy = controller?.policy
	for(var/datum/ai_option/option as anything in options)
		option.attach_to_controller(controller)
		option.on_profile_updated(profile)

/datum/ai_option_runner/proc/on_profile_attached(datum/ai_crew_profile/new_profile)
	profile = new_profile
	for(var/datum/ai_option/option as anything in options)
		option.on_profile_updated(profile)

/datum/ai_option_runner/proc/on_profile_detached()
	profile = null
	for(var/datum/ai_option/option as anything in options)
		option.on_profile_updated(null)

/datum/ai_option_runner/proc/on_policy_updated(datum/ai_control_policy/new_policy)
	policy = new_policy

/datum/ai_option_runner/proc/reset()
	for(var/datum/ai_option/option as anything in options)
		option.reset()

/datum/ai_option_runner/proc/register_role_pack(datum/ai_option_role/role)
	if(!role)
		return
	roles += role
	role.register_with_runner(src)

/datum/ai_option_runner/proc/register_option(datum/ai_option/option)
	if(!option)
		return
	option.attach_to_controller(controller)
	option.on_profile_updated(profile)
	var/identifier = option.get_identifier()
	if(!istext(identifier) || !length(identifier))
		identifier = lowertext("option_[length(options)+1]")
	options[identifier] = option

/datum/ai_option_runner/proc/get_option(identifier)
	if(!options || !(identifier in options))
		return null
	return options[identifier]

/datum/ai_option_runner/proc/get_option_catalog(datum/ai_context_snapshot/snapshot)
	var/list/catalog = list()
	for(var/datum/ai_option/option as anything in options)
		var/list/proposal = option.build_proposal(snapshot, policy)
		if(!islist(proposal))
			continue
		catalog += list(proposal)
	return catalog

/datum/ai_option_runner/proc/load_default_role_packs()
	register_role_pack(new /datum/ai_option_role/generic)
