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

	/// This value is passed onto the contestants on this team
	var/frozen = FALSE
	/// This value is passed onto the contestants on this team
	var/godmode = FALSE

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

	new_kid.set_frozen(frozen) // are these needed?
	new_kid.set_godmode(godmode)
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
		testing("[dead_kid.ckey] is on a different team")
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

/// If the arg is TRUE, mark the team and members as successfully completing a round. If the arg is FALSE, mark them for elimination
/datum/event_team/proc/set_frozen(new_mode)
	if(frozen == new_mode)
		return

	frozen = new_mode
	for(var/datum/contestant/iter_member in members)
		iter_member.set_frozen(frozen)

/// If the arg is TRUE, mark the team and members as successfully completing a round. If the arg is FALSE, mark them for elimination
/datum/event_team/proc/set_godmode(new_mode)
	if(godmode == new_mode)
		return

	godmode = new_mode
	for(var/datum/contestant/iter_member in members)
		iter_member.set_godmode(godmode)

