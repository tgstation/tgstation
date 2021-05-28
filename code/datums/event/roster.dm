
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
	var/list/contestant_ckeys

	var/list/all_contestants

	var/list/active_contestants

	var/list/active_teams

	var/list/rostered_teams

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
 *
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
	if(new_kid in active_contestants)
		testing("already in contestants")
		return

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

/// To be used for adding a team to the arena computer's "teams we're spawning" list
/datum/roster/proc/roster_team(mob/user)
	return
