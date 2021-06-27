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

	/// During battle royale, there's just one big team and we don't bother with antag huds
	var/battle_royale = FALSE

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
	new_kid.set_godmode(null, godmode)
	new_kid.current_team = src
	LAZYADD(members, new_kid)
	testing("successfully added [new_kid] to [src]")

/// Add a new contestant to this team
/datum/event_team/proc/query_add_member(mob/user)
	testing("query add member: user")
	if(!user)
		return

	var/datum/roster/the_roster = GLOB.global_roster
	if(!the_roster)
		CRASH("Tried querying to add member to a team, but there's no roster???")

	if(!the_roster.active_contestants)
		to_chat(user, span_warning("ERROR: No active eligible contestants. If you want to add someone who is eliminated, please un-eliminate them first."))
		return

	var/list/free_agents = list()

	for(var/datum/contestant/iter_contestant in the_roster.active_contestants)
		if(!iter_contestant.current_team)
			free_agents += iter_contestant

	var/datum/contestant/selected_contestant = input(user, "Please select the ckey of the free agent you would like to add to this team.", "Who?") as null|anything in free_agents
	if(!istype(selected_contestant))
		return
	if(selected_contestant.current_team)
		to_chat(user, span_warning("[selected_contestant] is already on [selected_contestant.current_team == src ? "this" : "another"] team!"))
		return

	add_member(user, selected_contestant)

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

/// Eliminate a random contestant from this team
/datum/event_team/proc/eliminate_random_member(mob/user)
	if(!LAZYLEN(members))
		message_admins("[key_name_admin(user)] tried eliminating random contestant from team with no members!")
		log_game("[key_name_admin(user)] tried eliminating random contestant from team with no members!")
		return

	var/datum/contestant/dead_kid = pick(members)
	message_admins("[key_name_admin(user)] randomly eliminated a member of team [src]: [dead_kid]!")
	log_game("[key_name_admin(user)] randomly eliminated a member of team [src]: [dead_kid]!")
	remove_member(dead_kid)
	GLOB.global_roster.eliminate_contestant(null, dead_kid)

/// If the arg is TRUE, mark the team and members as successfully completing a round. If the arg is FALSE, mark them for elimination
/datum/event_team/proc/match_result(victorious)
	finished_round = TRUE
	flagged_for_elimination = !victorious

	for(var/datum/contestant/iter_member in members)
		iter_member.rounds_participated++
		iter_member.flagged_for_elimination = !victorious

/// If the arg is TRUE, mark the team and members as successfully completing a round. If the arg is FALSE, mark them for elimination
/datum/event_team/proc/set_frozen(mob/user, new_mode)
	testing("try set fr")
	if(frozen == new_mode)
		return

	if(user)
		message_admins("[key_name_admin(user)] has [new_mode ? "FROZEN" : "UNFROZEN"] [src]!")
		log_game("[key_name_admin(user)] has [new_mode ? "FROZEN" : "UNFROZEN"] [src]!")

	frozen = new_mode
	for(var/datum/contestant/iter_member in members)
		iter_member.set_frozen(null, frozen)

/// If the arg is TRUE, mark the team and members as successfully completing a round. If the arg is FALSE, mark them for elimination
/datum/event_team/proc/set_godmode(mob/user, new_mode)
	testing("try set go")
	if(godmode == new_mode)
		return

	if(user)
		message_admins("[key_name_admin(user)] has [new_mode ? "GODMODED" : "UNGODMODED"] [src]!")
		log_game("[key_name_admin(user)] has [new_mode ? "GODMODED" : "UNGODMODED"] [src]!")

	godmode = new_mode
	for(var/datum/contestant/iter_member in members)
		iter_member.set_godmode(null, godmode)

/// If the arg is TRUE, mark the team and members as successfully completing a round. If the arg is FALSE, mark them for elimination
/datum/event_team/proc/spawn_members(mob/user, list/spawnpoints)
	if(!LAZYLEN(members))
		CRASH("tried spawning with no members!!")
	if(!length(spawnpoints))
		CRASH("tried spawning with no spawnpoints!!")

	if(user)
		message_admins("[key_name_admin(user)] has spawned [src]!")
		log_game("[key_name_admin(user)] has spawned [src]!")

	for(var/datum/contestant/iter_member in members)
		var/obj/machinery/arena_spawn/random_spawn = pick(spawnpoints)
		iter_member.spawn_this_contestant(random_spawn)
