/datum/round_event_control/antagonist
	reoccurence_penalty_multiplier = 0
	track = EVENT_TRACK_ROLESET
	/// Protected roles from the antag roll. People will not get those roles if a config is enabled
	var/list/protected_roles
	/// Restricted roles from the antag roll
	var/list/restricted_roles

/datum/round_event_control/antagonist/New()
	. = ..()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_roles |= protected_roles

/datum/round_event_control/antagonist/can_spawn_event(popchecks = TRUE, allow_magic)
	. = ..()
	if(!.)
		return
	if(!roundstart && !SSgamemode.can_inject_antags())
		return FALSE

/datum/round_event_control/antagonist/solo
	typepath = /datum/round_event/antagonist/solo
	/// How many baseline antags do we spawn
	var/base_antags = 1
	/// How many maximum antags can we spawn
	var/maximum_antags = 3
	/// For this many players we'll add 1 up to the maximum antag amount
	var/denominator = 20
	/// The antag flag to be used
	var/antag_flag
	/// The antag datum to be applied
	var/antag_datum
	/// Prompt players for consent to turn them into antags before doing so. Dont allow this for roundstart.
	var/prompted_picking = FALSE

/datum/round_event_control/antagonist/solo/can_spawn_event(popchecks = TRUE, allow_magic)
	. = ..()
	if(!.)
		return
	var/antag_amt = get_antag_amount()
	var/list/candidates = get_candidates()
	if(candidates.len < antag_amt)
		return FALSE

/datum/round_event_control/antagonist/solo/proc/get_antag_amount()
	var/people = SSgamemode.get_correct_popcount()
	var/amount = base_antags + FLOOR(people / denominator, 1)
	return min(amount, maximum_antags)

/datum/round_event_control/antagonist/solo/proc/get_candidates()
	var/round_started = SSticker.HasRoundStarted()
	var/new_players_arg = round_started ? FALSE : TRUE
	var/living_players_arg = round_started ? TRUE : FALSE
	var/midround_antag_pref_arg = round_started ? FALSE : TRUE

	var/list/candidates = SSgamemode.get_candidates(antag_flag, antag_flag, ready_newplayers = new_players_arg, living_players = living_players_arg, midround_antag_pref = midround_antag_pref_arg, restricted_roles = restricted_roles)
	return candidates

/datum/round_event/antagonist
	fakeable = FALSE
	end_when = 60 //This is so prompted picking events have time to run //TODO: refactor events so they can be the masters of themselves, instead of relying on some weirdly timed vars

/datum/round_event/antagonist/solo
	// ALL of those variables are internal. Check the control event to change them
	/// The antag flag passed from control
	var/antag_flag
	/// The antag datum passed from control
	var/antag_datum
	/// The antag count passed from control
	var/antag_count
	/// The restricted roles (jobs) passed from control
	var/list/restricted_roles
	/// The minds we've setup in setup() and need to finalize in start()
	var/list/setup_minds = list()
	/// Whether we prompt the players before picking them.
	var/prompted_picking = FALSE //TODO: Implement this

/datum/round_event/antagonist/solo/setup()
	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/candidates = cast_control.get_candidates()
	for(var/i in 1 to antag_count)
		if(!candidates.len)
			break
		var/mob/candidate = pick_n_take(candidates)
		setup_minds += candidate.mind
		candidate.mind.special_role = antag_flag
		candidate.mind.restricted_roles = restricted_roles

/datum/round_event/antagonist/solo/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		add_datum_to_mind(antag_mind)

/datum/round_event/antagonist/solo/proc/add_datum_to_mind(datum/mind/antag_mind)
	antag_mind.add_antag_datum(antag_datum)
