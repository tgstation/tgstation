
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
	/// A list of all the ckeys we're still looking for to tie to contestant datums
	var/list/ckeys_at_large = list()
	/// Assoc list, key is the ckey, value is their contestant datum. Continues holding the contestant after they've been eliminated, unlike active
	var/list/all_contestants
	/// Holds the datums for all contestants still in contention
	var/list/active_contestants = list()
	/// Holds the datums for all contestants who have been eliminated
	var/list/losers = list()
	/// All team datums that are currently active
	var/list/active_teams = list()
	/// Teams that are not rostered and still need to play
	var/list/unrostered_teams = list()

	var/datum/event_team/team1
	var/datum/event_team/team2
	var/team_id_tracker = 0

/datum/roster/New()
	RegisterSignal(SSdcs, COMSIG_GLOB_PLAYER_ENTER, .proc/check_new_player)
	// add a signal for new playters joining or observing or whatever and make it call check_connection with their client
	return

/// Will be hooked to new players joining and check if they have a contestant datum with their ckey that should be hooked to their client
/datum/roster/proc/check_new_player(datum/source, mob/dead/new_player/joining_player)
	SIGNAL_HANDLER

	if(!joining_player?.ckey)
		return

	if(!LAZYACCESS(ckeys_at_large, joining_player.ckey))
		return

	register_contestant(null, joining_player)

// maybe leave to the contestant datum?
/datum/roster/proc/register_contestant(mob/user, mob/target)
	if(!target?.ckey)
		CRASH("no contestant or target mob has no ckey")
	if(all_contestants[target.ckey])
		testing("already in contestants")
		return

	var/datum/contestant/new_kid = new(target.ckey)
	LAZYADDASSOC(all_contestants, new_kid.ckey, new_kid)
	LAZYADD(active_contestants, new_kid)
	LAZYREMOVE(ckeys_at_large, target.ckey)

/// Load a .json file with a list of ckeys and
/datum/roster/proc/load_contestants_from_file(mob/user, filepath)
	testing("try loading [user] [filepath]")
	if(!filepath)
		CRASH("No filepath!")


	var/list/incoming_ckeys = strings(filepath, "contestants", directory = "strings/rosters")

	testing("Loading strings/rosters/[filepath]")
	//testing(json_decode(incoming_ckeys))
	if(length(active_contestants))
		var/list/options = list("Clear All", "Add New", "Cancel")
		var/select = input(user, "There are existing contestants! Would you like to clear all existing contestants first, just add new ckeys to the list, or cancel?") as null|anything in options

		switch(select)
			if("Clear All")
				clear_contestants(user)
			if("Add New")
				testing("okk")
			else
				return

	var/contestants_created = 0
	var/ckeys_added_to_list = 0

	// create contestants for people who are currently connected and don't have a contestant
	for(var/iter_ckey in incoming_ckeys)
		if(LAZYFIND(ckeys_at_large, iter_ckey))
			continue
		else if(LAZYACCESS(all_contestants, iter_ckey)) //already exist
			continue
		if(GLOB.directory[iter_ckey]) //connected to the server (not sure if currently??) and need a contestant datum
			register_contestant(null, get_mob_by_key(iter_ckey)) //uhhhhhhh? check what happens to people who connected but are DC'd when this runs, or are still new_player
			contestants_created++
		else
			LAZYADD(ckeys_at_large, iter_ckey) // otherwise watch for them with signal
			ckeys_added_to_list++

	message_admins("[user] loaded contestants from [filepath], [contestants_created] contestants created, [ckeys_added_to_list] ckeys added to watchlist.")


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
			else
				return

	var/num_contestants = length(active_contestants)
	var/num_teams
	var/num_per
	var/remainder

	if(team_size)
		num_teams = round(num_contestants / team_size)
		num_per = team_size
	else if(number_of_teams)
		num_teams = number_of_teams
		num_per = round(num_contestants / number_of_teams)
	else
		testing("no team size or num teams defined!")
		return

	remainder = num_contestants % num_teams

	testing("making [num_teams] teams of [num_per] with remainder [remainder]")
	var/overall_contestant_index = 1
	for(var/team_index in 1 to num_teams)
		testing(">>creating team [team_index]")
		var/datum/event_team/new_team = create_team()
		for(var/contestant_index in 1 to num_per)
			var/datum/contestant/iter_contestant = active_contestants[overall_contestant_index]
			testing(">>>>assigning contestant #[overall_contestant_index] ([iter_contestant.ckey]) to team [team_index]")
			new_team.add_member(iter_contestant)
			overall_contestant_index++
		testing("------")


/datum/roster/proc/create_team(mob/user)
	team_id_tracker++
	testing("creating team [team_id_tracker]")
	var/datum/event_team/new_team = new(team_id_tracker)
	LAZYADD(active_teams, new_team)
	LAZYADD(unrostered_teams, new_team)

	testing("created team [team_id_tracker]")
	return new_team

/datum/roster/proc/remove_team(mob/user, datum/event_team/the_team)
	if(!istype(the_team))
		return

	LAZYREMOVE(unrostered_teams, the_team)
	LAZYREMOVE(active_teams, the_team)

	testing("Deleting team [the_team]")
	if(team1 == the_team)
		team1 = null
	else if(team2 == the_team)
		team1 = null

/datum/roster/proc/clear_teams(mob/user)
	for(var/datum/event_team/iter_team in active_teams)
		qdel(iter_team)

	testing("teams all cleared!")

/datum/roster/proc/clear_contestants(mob/user)
	//maybe dump the info in an easily undoable way in case someone fucks up
	for(var/contestant_ckey in all_contestants)
		qdel(all_contestants[contestant_ckey])

	ckeys_at_large = list()
	all_contestants = list()

	testing("contestants all cleared!")

/datum/roster/proc/eliminate_contestant(mob/user, datum/contestant/target)
	if(!target)
		return

	if(!istype(target))
		target = locate(target) in active_contestants
		if(!istype(target))
			testing("couldn't find that target to eliminate")
			return

	if(LAZYACCESS(losers, target))
		testing("already a loser")
		return

	LAZYREMOVE(active_contestants, target)
	LAZYADD(losers, target)
	target.eliminated = TRUE
	testing("contestant [target.ckey] elim'd!")

/datum/roster/proc/delete_contestant(mob/user, datum/contestant/target)
	if(!target)
		return

	if(!istype(target))
		target = locate(target) in active_contestants
		if(!istype(target))
			testing("couldn't find that target to delete")
			return

	var/the_ckey_for_later = target.ckey

	LAZYREMOVEASSOC(all_contestants, target.ckey, target)
	LAZYREMOVE(active_contestants, target)
	LAZYREMOVE(losers, target)
	qdel(target)
	testing("contestant [the_ckey_for_later] deleted!")

/**
 * Remove all the contestants who haven't had someone with a valid ckey connect and claim it
 *
 * Args:
 * * purge_clientless_too- If TRUE, remove the contestant datums that had someone connect and claim it, but who is not presently connected
 */
/datum/roster/proc/purge_unused_contestants(mob/user, purge_clientless_too = FALSE)
	//maybe dump the info in an easily undoable way in case someone fucks up
	for(var/datum/contestant/iter_contestant in active_contestants) // all or active?
		if(!iter_contestant.claimed || (purge_clientless_too && !iter_contestant.matched_client))
			qdel(iter_contestant)
			// remove ckeys from contestant_ckeys?

	testing("unclaimed[purge_clientless_too ? " and clientless" : ""] contestants all cleared!")

/// To be used for adding a team to the arena computer's "teams we're spawning" list
/datum/roster/proc/try_load_team_slot(mob/user, slot)
	if(!slot  || !length(unrostered_teams))
		return
	if((slot == 1 && team1) || (slot == 2 && team2))
		testing("already a team in slot [slot]")
		return

	testing("trying to get team from [user] for slot [slot]")
	var/list/the_teams = list()
	var/list/the_team_nums = list()

	var/team_iterator_count = 0
	for(var/datum/event_team/iter_team in unrostered_teams)
		team_iterator_count++
		var/i = iter_team.rostered_id
		the_teams[team_iterator_count] = iter_team
		the_team_nums[team_iterator_count] = i

	var/selected_index = input(user, "Choose a team:", "Team", null) as null|anything in the_team_nums

	var/datum/event_team/the_team = the_teams[selected_index]
	if(!istype(the_team))
		testing("no team")
		return

	set_team_slot(user, the_team, slot)

/// To be used for adding a team to the arena computer's "teams we're spawning" list
/datum/roster/proc/set_team_slot(mob/user, datum/event_team/the_team, slot)
	if(slot == 1)
		team1 = the_team
	else if(slot == 2)
		team2 = the_team

	testing("team [the_team] assigned to slot [slot]")
	LAZYREMOVE(unrostered_teams, the_team)

/// To be used for adding a team to the arena computer's "teams we're spawning" list
/datum/roster/proc/try_remove_team_slot(mob/user, slot)
	var/datum/event_team/removed_team
	if(slot == 1)
		removed_team = team1
		team1 = null
	else if(slot == 2)
		removed_team = team2
		team2 = null

	if(removed_team)
		LAZYADD(unrostered_teams, removed_team)

/// To be used for adding a team to the arena computer's "teams we're spawning" list
/datum/roster/proc/setup_match(mob/user, list/prefs)
	var/teams = prefs["mainsettings"]["team_event"]["value"]
	var/divy_teams_by_num_not_size = prefs["mainsettings"]["team_num_instead_of_size"]["value"]
	var/team_divy_factor = prefs["mainsettings"]["team_divy_factor"]["value"]

	testing("[user] is setting up match with values: [teams] teams, [divy_teams_by_num_not_size] divy mode, [team_divy_factor] divy factor")
	if(divy_teams_by_num_not_size)
		divy_into_teams(user, team_divy_factor, 0, REMAINDER_MODE_BYE)
	else
		divy_into_teams(user, 0, team_divy_factor, REMAINDER_MODE_BYE)

/// To be used for adding a team to the arena computer's "teams we're spawning" list
/datum/roster/proc/try_setup_match(mob/user)

	var/list/settings = list(
		"mainsettings" = list(
			"team_event" = list("desc" = "Team Event?", "type" = "boolean", "value" = "Yes"),
			"team_num_instead_of_size" = list("desc" = "If teams, divy by team number instead of team size?", "type" = "boolean", "value" = "Yes"),
			"team_divy_factor" = list("desc" = "If teams, what's the divy factor? (ask if you don't know!)", "type" = "number", "value" = 2)
		)
	)

	message_admins("[key_name(user)] is setting up next match...")
	var/list/prefreturn = presentpreflikepicker(user,"Setup Next Match", "Setup Next Match", Button1="Ok", width = 600, StealFocus = 1,Timeout = 0, settings=settings)


	if (isnull(prefreturn))
		return FALSE

	if (prefreturn["button"] == 1)
		var/list/prefs = settings["mainsettings"]

		setup_match(user, prefs)


/// To be used for adding a team to the arena computer's "teams we're spawning" list
/datum/roster/proc/add_empty_contestant(mob/user)
	var/rand_num = num2text(rand(1,10000))
	var/datum/contestant/new_kid = new(rand_num)
	LAZYADDASSOC(all_contestants, rand_num, new_kid)
	LAZYADD(active_contestants, new_kid)
	new_kid.ckey = rand_num
	//LAZYREMOVE(ckeys_at_large, target.ckey)
