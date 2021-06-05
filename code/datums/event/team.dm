/**
 * The contestant represents one player.
 */
/datum/contestant
	var/name
	/// The ckey we try to match with
	var/ckey
	/// How many rounds this contestant has participated in? Incremented when their team has [/datum/event_team/proc/match_result] called on it
	var/rounds_participated
	/// What team datum we're on right now
	var/datum/event_team/current_team
	/// If we've been marked for elimination
	var/flagged_for_elimination = FALSE
	/// If we've actually been eliminated
	var/eliminated = FALSE
	/// Set to TRUE with [/datum/contestant/proc/set_flag_on_death] if you want the contestant to be marked for elimination when their current living body dies (must be in body already)
	var/flagged_on_death = FALSE

/datum/contestant/New(new_ckey)
	ckey = new_ckey
	name = ckey

	if(!get_mob_by_ckey(ckey))
		return

/datum/contestant/Destroy(force, ...)
	if(current_team)
		current_team.remove_member(src)
	. = ..()

/// Helper to return the current mob quickly
/datum/contestant/proc/get_mob()
	if(!ckey)
		return

	return get_mob_by_ckey(ckey)

/// If arg is TRUE, this contestant will be marked for elimination when their current body dies. If arg is FALSE, disables that
/datum/contestant/proc/set_flag_on_death(new_mode)
	if(flagged_on_death == new_mode)
		return

	flagged_on_death = new_mode
	var/mob/living/our_boy = get_mob()
	if(flagged_on_death)
		RegisterSignal(our_boy, COMSIG_LIVING_DEATH, .proc/on_flagged_death)
	else
		UnregisterSignal(our_boy, COMSIG_LIVING_DEATH)

/// If we die while we were listening for our death, mark us for elimination then stop listening
/datum/contestant/proc/on_flagged_death(datum/source)
	SIGNAL_HANDLER

	flagged_for_elimination = TRUE
	set_flag_on_death(FALSE)

/**
 * Event teams are teams that are constantly being made and deleted. New teams every round.
 */
/datum/event_team
	var/name
	/// Who's in the squad
	var/list/members
	/// What number team is this in terms of how many the roster has created?
	var/rostered_id
	/// Flagged for elimination if the team loses a round
	var/flagged_for_elimination
	/// The team has finished playing a round, if they don't have eliminated set to TRUE, that means they won!
	var/finished_round
	/// If the team has been eliminated and is waiting for the round to end for this datum to be deleted
	var/eliminated

/datum/event_team/New(our_number)
	rostered_id = our_number
	name = "Team #[rostered_id]"

/datum/event_team/Destroy(force, ...)
	for(var/datum/contestant/iter_member in members)
		remove_member(iter_member)
	. = ..()

/// Add a new contestant to this team
/datum/event_team/proc/add_member(mob/user, datum/contestant/new_kid)
	if(!new_kid)
		CRASH("tried adding invalid contestant")
	if(new_kid.current_team == src)
		testing("[new_kid.ckey] is already on this team")
		return
	if(new_kid.current_team)
		testing("[new_kid.ckey] is already on a different team")
		return

	new_kid.current_team = src
	LAZYADD(members, new_kid)
	testing("successfully added [new_kid] to [src]")

/// Remove a contestant from this team
/datum/event_team/proc/remove_member(datum/contestant/dead_kid)
	if(!dead_kid)
		CRASH("tried removing invalid contestant")
	if(!dead_kid.current_team)
		testing("[dead_kid.ckey] isn't on a team")
		return
	if(dead_kid.current_team != src)
		testing("[dead_kid.ckey] is on a differnet team")
		return

	dead_kid.current_team = null
	LAZYREMOVE(members, dead_kid)
	testing("removed [dead_kid] from [src]")

/// If the arg is TRUE, mark the team and members as successfully completing a round. If the arg is FALSE, mark them for elimination
/datum/event_team/proc/match_result(victorious)
	finished_round = TRUE
	flagged_for_elimination = !victorious

	for(var/datum/contestant/iter_member in members)
		iter_member.rounds_participated++
		iter_member.flagged_for_elimination = !victorious
