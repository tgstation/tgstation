/**
 * The contestant represents one player.
 */
/datum/contestant
	var/name
	/// The ckey we try to match with
	var/ckey
	/// Whether or not someone has been associated with this datum
	var/claimed
	/// What client
	var/client/matched_client
	/// What mob (follows the client/player, not the mob), may not be needed
	var/mob/current_mob
	/// How many rounds this contestant has survived participating in (contestants with the least number of rounds won will be prioritized for being slotted into teams for the next round, so you can't get a bye for multiple rounds)
	var/rounds_won
	/// Probably unneeded
	var/rounds_participated
	/// What team datum we're on right now
	var/datum/event_team/current_team

	var/flagged_for_elimination = FALSE

	var/flagged_on_death = FALSE

	var/eliminated = FALSE

/datum/contestant/New(new_ckey)
	ckey = new_ckey
	name = ckey
	current_mob = get_mob_by_ckey(ckey)

	//GLOB.global_roster.insert_contestant(user=null, new_kid=src) // check if success?
	if(!current_mob)
		return
	claimed = TRUE
	matched_client = current_mob.client

/datum/contestant/Destroy(force, ...)
	if(current_team)
		current_team.remove_member(src)
	. = ..()

/datum/contestant/proc/get_mob()
	if(!ckey)
		return

	return get_mob_by_ckey(ckey)

/datum/contestant/proc/set_flag_on_death(new_mode)
	if(flagged_on_death == new_mode)
		return

	flagged_on_death = new_mode
	var/mob/living/our_boy = get_mob()
	if(flagged_on_death)
		RegisterSignal(our_boy, COMSIG_LIVING_DEATH, .proc/on_flagged_death)
	else
		UnregisterSignal(our_boy, COMSIG_LIVING_DEATH)

/datum/contestant/proc/on_flagged_death(datum/source)
	SIGNAL_HANDLER

	flagged_for_elimination = TRUE
	set_flag_on_death(FALSE)

/**
 * Event teams are teams that are constantly being made and remade
 */
/datum/event_team
	var/name
	var/list/members

	var/rostered_id

/datum/event_team/New(our_number)
	rostered_id = our_number
	name = rostered_id

/datum/event_team/Destroy(force, ...)
	for(var/datum/contestant/iter_member in members)
		remove_member(iter_member)
	. = ..()

 // maybe track the user so we can tell them if there's an issue (if they're already on a team, ask if we should force it?) ((also maybe for logging))
/datum/event_team/proc/add_member(mob/user, datum/contestant/new_kid)
	if(!new_kid)
		CRASH("tried adding invalid contestant")
	if(new_kid.current_team == src)
		testing("[new_kid.ckey] is already on this team")
		return
	if(new_kid.current_team)
		testing("[new_kid.ckey] is already on a differnet team")
		return

	new_kid.current_team = src
	LAZYADD(members, new_kid)

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
