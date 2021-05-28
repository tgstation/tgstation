
// the following defines manage what happens if we divy up teams randomly and people are leftover
/**
 * Those not slotted will get a bye this round, though since their rounds_survived counter won't go up,
 * they will be prioritized for teams next round
 */
#define REMAINDER_MODE_BYE 0
/// Lump the leftovers into their own team, even if it has less people than the others
#define REMAINDER_MODE_SHORT_TEAM 1
/// Distribute the leftovers randomly onto the other teams, one per
#define REMAINDER_MODE_LARGE_TEAM 2



GLOBAL_DATUM_INIT(global_roster, /datum/roster, new)

/**
 * The roster is the main handler for all the contestants and teams
 */
/datum/roster
	/// A big list of all the ckeys we're creating contestant datums for
	var/list/contestant_ckeys
	/// Currently unused, will hold all contestant datums, including ones who have been eliminated from the contest
	var/list/all_contestants
	/// Holds the datums for all contestants still in contention
	var/list/active_contestants
	/// All team datums that are currently active
	var/list/active_teams
	/// Will be used for which teams are actively marked to be spawned next
	var/list/rostered_teams

/datum/roster/New()
	// add a signal for new playters joining or observing or whatever and make it call check_connection with their client
	return

/// Will be hooked to new players joining and check if they have a contestant datum with their ckey that should be hooked to their client
/datum/roster/proc/check_connection(mob/user)
	return

/// Load a .json file with a list of ckeys and
/datum/roster/proc/load_contestants_from_file(mob/user, filepath)
	if(!filepath)
		CRASH("No filepath!")

	var/list/incoming_ckeys = strings(filepath, "contestants", directory = "strings/rosters")

	if(active_contestants)
		var/list/options = list("Clear All", "Add New", "Cancel")
		var/select = input(user, "There are existing contestants! Would you like to clear all existing contestants first, just add new ckeys to the list, or cancel?") as null|anything in options

		switch(select)
			if("Clear All")
				clear_contestants(user)
			if("Add New")
				testing("okk")
			else
				return

	for(var/iter_ckey in incoming_ckeys)
		if(iter_ckey in contestant_ckeys) // assoc list check?
			continue
		var/datum/contestant/new_contestant = new(iter_ckey)

/**
 * Take all the contestants not on a team already and divy them up into new random teams based on either number of teams or team size
 *
 * Args:
 * * user- who called this
 * * number_of_teams- If set, we create this many teams and divide the players evenly
 * * team_size- If set, we try to make as many teams of this size as we can
 * * remainder_mode- See REMAINDER_MODE_BYE and etc defines at top of file
 */
/datum/roster/proc/divy_into_teams(mob/user, number_of_teams = 0, team_size = 0, remainder_mode = REMAINDER_MODE_BYE)
	if(active_teams)
		var/list/options = list("Clear Existing", "Assign Free Agents", "Cancel")
		var/select = input(user, "There are still existing teams! Would you like to clear existing teams first, create new teams from the current free agents, or cancel?") as null|anything in options

		switch(select)
			if("Clear Existing")
				clear_teams(user)
			if("Assign Free Agents")
				testing("ok")
			else
				return

// maybe leave to the contestant datum?
/datum/roster/proc/insert_contestant(mob/user, datum/contestant/new_kid)
	if(!new_kid)
		CRASH("no contestant")
	if(all_contestants[new_kid.ckey])
		testing("already in contestants")
		return

	LAZYADDASSOC(all_contestants, new_kid.ckey, new_kid)
	LAZYADD(active_contestants, new_kid)

/datum/roster/proc/clear_teams(mob/user)
	for(var/datum/event_team/iter_team in active_teams)
		qdel(iter_team)

	testing("teams all cleared!")

/datum/roster/proc/clear_contestants(mob/user)
	//maybe dump the info in an easily undoable way in case someone fucks up
	for(var/datum/contestant/iter_contestant in active_contestants)
		qdel(iter_contestant)

	LAZYNULL(contestant_ckeys)

	testing("contestants all cleared!")

/**
 * Remove all the contestants who haven't had someone with a valid ckey connect and claim it
 *
 * Args:
 * * purge_clientless_too- If TRUE, remove the contestant datums that had someone connect and claim it, but who is not presently connected
 */
/datum/roster/proc/purge_unused_contestants(mob/user, purge_clientless_too = FALSE)
	//maybe dump the info in an easily undoable way in case someone fucks up
	for(var/datum/contestant/iter_contestant in active_contestants)
		if(!iter_contestant.claimed || (purge_clientless_too && !iter_contestant.matched_client))
			qdel(iter_contestant)
			// remove ckeys from contestant_ckeys?

	testing("unclaimed[purge_clientless_too ? " and clientless" : ""] contestants all cleared!")

/// To be used for adding a team to the arena computer's "teams we're spawning" list
/datum/roster/proc/roster_team(mob/user)
	return
