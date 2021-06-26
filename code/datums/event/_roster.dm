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
	var/list/active_contestants
	/// Holds the datums for all contestants who have been eliminated
	var/list/losers
	/// All team datums that are currently active
	var/list/active_teams
	/// Teams that are not rostered and still need to play
	var/list/unrostered_teams
	/// Hardcoded slot 1 for the 2 team match system (RED TEAM)
	var/datum/event_team/team1
	/// Hardcoded slot 2 for the 2 team match system (GREEN TEAM)
	var/datum/event_team/team2
	/// Hardcoded slot 3 for the 2 team match system (BLUE TEAM)
	var/datum/event_team/team3
	/// Counter for how many team datums we've made, each team gets a unique number, even if a lower numbered team has already been deleated
	var/team_id_tracker = 0

	/// Holds the datums for all contestants who are actively spawned and competing
	var/list/live_contestants
	/// Holds the list of /obj/machinery/arena_spawn objects for the currently loaded arena keyed for the RED team (team1)
	var/list/spawns_team1
	/// Holds the list of /obj/machinery/arena_spawn objects for the currently loaded arena keyed for the GREEN team (team2)
	var/list/spawns_team2
	/// Holds the list of /obj/machinery/arena_spawn objects for the currently loaded arena keyed for the BLUE team (team3)
	var/list/spawns_team3
	/// Holds the list of /obj/machinery/arena_spawn/battle_royale objects for the currently loaded arena keyed for the BR team (im lazy)
	var/list/spawns_br
	/// If FALSE, bodyparts cannot suffer wounds by receiving damage. Wounds can still be manually applied as per normal
	var/enable_random_wounds = FALSE
	/// My desperate attempt to accomodate the three team cooking event
	var/three_team_round = FALSE

	/// Once we're down to this many people in the battle royale round, stop the carnage
	var/br_end_population = 16
	/// Are we in BR mode?
	var/battle_royale_active = FALSE
	/// The cooldown for battle royale elim voice lines
	COOLDOWN_DECLARE(battle_royale_voice_cd)
	/// The sound files we choose from when people get elim'd
	var/static/list/br_elimination_voice_files = list('sound/battle_royale/eliminated (1).ogg',\
		'sound/battle_royale/eliminated (2).ogg',\
		'sound/battle_royale/eliminated (3).ogg',\
		'sound/battle_royale/eliminated (4).ogg',\
		'sound/battle_royale/eliminated (5).ogg',\
		'sound/battle_royale/eliminated (6).ogg',\
		'sound/battle_royale/eliminated (7).ogg',\
		'sound/battle_royale/eliminated (8).ogg',\
		'sound/battle_royale/eliminated (9).ogg'
		)

	// antag hud stuff stolen wholesale from the arena computer so they now live here
	/// List of team ids
	var/list/teams = list(ARENA_RED_TEAM,ARENA_GREEN_TEAM,ARENA_BLUE_TEAM)
	/// List of hud instances indedxed by team id
	var/static/list/team_huds = list()
	/// List of hud colors indexed by team id
	var/static/list/team_colors = list(ARENA_RED_TEAM = "red", ARENA_GREEN_TEAM = "green", ARENA_BLUE_TEAM = "blue")
	/// Team hud index in GLOB.huds indexed by team id
	var/static/list/team_hud_index = list()

/datum/roster/New()
	RegisterSignal(SSdcs, COMSIG_GLOB_PLAYER_ENTER, .proc/check_new_player)
	// add a signal for new playters joining or observing or whatever and make it call check_connection with their client
	generate_antag_huds()
	return

/// Hooked to players observing, checks to see if we've expecting their ckey so we can turn them into a contestant
/datum/roster/proc/check_new_player(datum/source, mob/dead/new_player/joining_player)
	SIGNAL_HANDLER

	if(!joining_player?.ckey)
		return

	if(!LAZYFIND(ckeys_at_large, joining_player.ckey))
		return

	register_contestant(null, joining_player)

/// Load a .json file with a list of ckeys to create a list of ckeys to watch out for, so anyone who joins the game with a marked ckey will be added as a contestant when they observe. See sample_roster.json for format
/datum/roster/proc/load_contestants_from_file(mob/user, filepath)
	log_game("[key_name_admin(user)] is trying to load roster from [filepath].")
	if(!filepath)
		CRASH("No filepath!")

	var/list/incoming_ckeys = strings(filepath, "contestants", directory = "strings/rosters")

	testing("Loading strings/rosters/[filepath]")
	if(LAZYLEN(active_contestants))
		var/list/options = list("Clear All", "Add New", "Cancel")
		var/select = input(user, "There are existing contestants! Would you like to clear all existing contestants first, or cancel?") as null|anything in options

		switch(select)
			if("Clear All")
				reset_roster(user)
			else
				return

	var/contestants_created = 0
	var/ckeys_added_to_list = 0

	// first create contestants for people who are currently connected and don't have a contestant
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

	message_admins("[user] loaded a roster from [filepath], [contestants_created] contestants created, [ckeys_added_to_list] ckeys added to watchlist.")
	log_game("[key_name_admin(user)] loaded roster from [filepath].")


/**
 * Take all the contestants and divvy them up into new random teams based on either number of teams or team size. Must clear existing teams to continue.
 *
 * Args:
 * * user- who called this
 * * number_of_teams- If set, we create this many teams and divide the players evenly
 * * team_size- If set, we try to make as many teams of this size as we can
 */
/datum/roster/proc/divvy_into_teams(mob/user, number_of_teams = 0, team_size = 0)
	if(active_teams)
		var/list/options = list("Clear Existing", "Cancel")
		var/select = input(user, "There are still existing teams, you must clear them first! Proceed with clearing, or cancel?") as null|anything in options

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
		CRASH("no team size or num teams defined!")
		return

	remainder = num_contestants % num_teams
	shuffle_inplace(active_contestants)

	var/overall_contestant_index = 1
	for(var/team_index in 1 to num_teams)
		var/datum/event_team/new_team = create_team()
		for(var/contestant_index in 1 to num_per)
			var/datum/contestant/iter_contestant = active_contestants[overall_contestant_index]
			new_team.add_member(user, iter_contestant)
			overall_contestant_index++
	message_admins("Successfully created [num_teams] teams of [num_per] players, with remainder [remainder]!")

// The direct team modifying/creating/removing procs
/// Proc for creating a team, returns the new team
/datum/roster/proc/create_team(mob/user)
	team_id_tracker++
	var/datum/event_team/new_team = new(team_id_tracker)
	LAZYADD(active_teams, new_team)
	LAZYADD(unrostered_teams, new_team)

	log_game("[key_name_admin(user)] created new team [team_id_tracker].")
	return new_team

/// For removing and deleting a team, you must do it through here so they get removed from all the right places
/datum/roster/proc/remove_team(mob/user, datum/event_team/the_team)
	if(!istype(the_team))
		return

	LAZYREMOVE(unrostered_teams, the_team)
	LAZYREMOVE(active_teams, the_team)

	log_game("[key_name_admin(user)] deleted team [the_team].")
	if(team1 == the_team)
		team1 = null
	else if(team2 == the_team)
		team1 = null
	qdel(the_team)

/// For eliminating a team, this will eliminate all contestants who are a member of this team and mark itself as eliminated (though it is not deleted)
/datum/roster/proc/eliminate_team(mob/user, datum/event_team/the_team)
	if(!istype(the_team))
		return

	if(team1 == the_team)
		team1 = null
	else if(team2 == the_team)
		team2 = null
	else if(team3 == the_team)
		team3 = null

	log_game("Team: [the_team] has been eliminated. Eliminated members are as follows:")
	the_team.eliminated = TRUE
	for(var/datum/contestant/iter_member in the_team.members)
		eliminate_contestant(user, iter_member)
	log_game("End team [the_team] eliminations.")

/// Delete all the current teams
/datum/roster/proc/clear_teams(mob/user)
	for(var/datum/event_team/iter_team in active_teams)
		remove_team(user, iter_team)

	if(battle_royale_active)
		end_battle_royale(user)
	log_game("[key_name_admin(user)] has cleared all teams.")

// contestant datum procs
/**
 * Proc for taking a mob with a player who we'd like to make a contestant datum for. Target must be a mob that the player in question has control of (or at least have their ckey defined)
 *
 * Takes a mob and not just a ckey for an argument because this is supposed to represent a player who has confirmed connecting to the server, even if they may not be currently connected at the moment.
 * The contestant datum is tied to the roster and indexed with the player's ckey and not the mob/mind/whatever after creation, so don't worry about them switching bodies
 */
/datum/roster/proc/register_contestant(mob/user, mob/target)
	if(!target?.ckey)
		CRASH("no contestant or target mob has no ckey")
	if(LAZYACCESS(all_contestants, target.ckey))
		to_chat(user, "<span class='warning'>[target.ckey] already has a contestant datum!</span>")
		return

	var/datum/contestant/new_kid = new(target.ckey)
	LAZYADDASSOC(all_contestants, new_kid.ckey, new_kid)
	LAZYADD(active_contestants, new_kid)
	LAZYREMOVE(ckeys_at_large, target.ckey)
	if(user)
		message_admins("[key_name_admin(user)] registered [target] as a contestant.")
	log_game("[key_name_admin(user)] registered [target] as a contestant.")

/// For asking the user a single, specific ckey they'd like to add to the contestants
/datum/roster/proc/add_specific_contestant(mob/user)
	if(!user)
		return

	var/ckey_to_add = stripped_input(user, "Please enter the ckey of the contestant you wish to add.") as text|null
	ckey_to_add = ckey(ckey_to_add)

	if(!ckey_to_add)
		return
	if(LAZYACCESS(all_contestants, ckey_to_add))
		to_chat(user, "<span class='warning'>[ckey_to_add] already has an <b>activated</b> contestant datum!</span>")
		return
	if(LAZYFIND(ckeys_at_large, ckey_to_add))
		to_chat(user, "<span class='warning'>[ckey_to_add] already has a contestant datum, and is waiting for the player to join!</span>")
		return

	if(GLOB.directory[ckey_to_add]) //connected to the server (not sure if currently??) and need a contestant datum
		register_contestant(user, get_mob_by_key(ckey_to_add)) //uhhhhhhh? check what happens to people who connected but are DC'd when this runs, or are still new_player
	else
		LAZYADD(ckeys_at_large, ckey_to_add) // otherwise watch for them with signal
		log_game("[key_name_admin(user)] registered [ckey_to_add] as a contestant, pending the player claiming it.")

/// Deletes (not just eliminate) all existing contestant datums and teams, basically resetting the entire thing
/datum/roster/proc/reset_roster(mob/user)
	if(!LAZYLEN(active_contestants))
		return

	if(user)
		var/select = input(user, "Are you sure you want to nuke all the contestants (and existing teams)? There's no going back!!") as null|anything in list("Yes, delete them", "Cancel")

		switch(select)
			if("Yes, delete them")
				message_admins("Clearing contestants...")
			else
				return

	clear_teams(user) // clear the teams first
	//maybe dump the info in an easily undoable way in case someone fucks up
	for(var/contestant_ckey in all_contestants)
		qdel(all_contestants[contestant_ckey])

	ckeys_at_large = list()
	all_contestants = list()
	active_contestants = null
	losers = null

	message_admins("[key_name_admin(user)] has cleared all contestants.") // log which they chose
	log_game("[key_name_admin(user)] has cleared all contestants!")

/// Dumps the current state of the roster to the game log in case this is accidentally triggered during the tourney, so we can at least try to recover
/datum/roster/proc/dump_contestant_log(mob/user)
	if(!LAZYLEN(active_contestants))
		message_admins("Tried dumping contestant logs, but no contestants found.")
		return

	var/list/text_dump = list("Text dump of roster log:")

	for(var/datum/contestant/iter_contestant in all_contestants)
		text_dump += iter_contestant.dump_info()

	text_dump.Join("\n")
	log_game(text_dump) // lol is this okay? maybe spit it out in its own file
	message_admins("Roster dump hopefully completed successfully!")

/// Eliminates the chosen contestant, taking them out of further contention. Can still be undone and returned to the active list in the contestant menu (not actually rn, but will be added (TODO:))
/datum/roster/proc/remove_ckey_at_large(mob/user, target_ckey)
	if(!target_ckey)
		to_chat(user, "<span class='warning'>No target supplied.</span>")
		return

	target_ckey = ckey(target_ckey)
	if(!LAZYFIND(ckeys_at_large, target_ckey))
		to_chat(user, "<span class='warning'>Target ckey [target_ckey] is not on the ckeys_at_large watchlist.</span>")
		return

	LAZYREMOVE(ckeys_at_large, target_ckey)
	message_admins("[key_name_admin(user)] has removed [target_ckey] from ckeys_at_large watchlist.")
	log_game("[key_name_admin(user)] has removed [target_ckey] from ckeys_at_large watchlist.")

/// Eliminates the chosen contestant, taking them out of further contention. Can still be undone and returned to the active list in the contestant menu (not actually rn, but will be added (TODO:))
/datum/roster/proc/eliminate_contestant(mob/user, datum/contestant/target)
	if(!target)
		to_chat(user, "<span class='warning'>No target supplied.</span>")
		return

	if(!istype(target))
		target = locate(target) in active_contestants
		if(!istype(target))
			to_chat(user, "<span class='warning'>Couldn't find that target to eliminate.</span>")
			return

	if(LAZYFIND(losers, target))
		to_chat(user, "<span class='warning'>[target] has already been eliminated!</span>")
		return

	LAZYREMOVE(active_contestants, target)
	LAZYADD(losers, target)
	target.eliminated = TRUE

	var/mob/loser = target.get_mob()
	to_chat(loser, span_narsiesmall("YOU HAVE BEEN ELIMINATED! Better luck next time!"))

	message_admins("[key_name_admin(user)] has eliminated [target]!") // log which they chose
	log_game("[key_name_admin(user)] has eliminated [target]!")

/**
 * Unmark a contestant who has been marked for elimination, returning them to full active status. Marks come from being killed with "mark on death" active for them, or if their team loses a round.
 *
 * Useful if someone who wasn't supposed to be marked for elimination got misclicked, or not the entire losing team gets eliminated (add helpers to decide who dies randomly (TODO:))
 * No I don't have a helper for marking people for elimination, I'll do that soon
 */
/datum/roster/proc/unmark_contestant(mob/user, datum/contestant/target)
	if(!target)
		to_chat(user, "<span class='warning'>No target supplied.</span>")
		return

	if(!istype(target))
		target = locate(target) in active_contestants
		if(!istype(target))
			to_chat(user, "<span class='warning'>Couldn't find that target to eliminate.</span>")
			return

	if(LAZYFIND(losers, target))
		to_chat(user, "<span class='warning'>[target] has already been eliminated!</span>")
		return
	if(target.eliminated || LAZYFIND(losers, target))
		testing("already a loser")
		return

	target.flagged_for_elimination = FALSE // should be a proc
	message_admins("[key_name_admin(user)] has unmarked for elimination [target]!") // log which they chose
	log_game("[key_name_admin(user)] has unmarked for elimination [target]!")

/// Outright delete a contestant, not to be confused with marking for elimination or eliminating, this shouldn't be done to actual tournament participants during the tournament.
/datum/roster/proc/delete_contestant(mob/user, datum/contestant/target, target_ckey = null)
	if(!target)
		to_chat(user, "<span class='warning'>No target supplied.</span>")
		return

	if(!istype(target))
		target = locate(target) in (active_contestants + losers)
		if(!istype(target))
			to_chat(user, "<span class='warning'>Couldn't find that target to eliminate.</span>")
			return

	LAZYREMOVE(all_contestants, target.ckey)
	LAZYREMOVE(active_contestants, target)
	LAZYREMOVE(losers, target)

	message_admins("[key_name_admin(user)] has deleted contestant [target]!") // log which they chose
	log_game("[key_name_admin(user)] has deleted contestant [target]!")
	qdel(target)

/**
 * Null out the list of ckeys we're looking for the player of so that no more contestants can be created by late joining once we're started.
 *
 * Args:
 * * purge_clientless_too- If TRUE, delete the contestant datum of anyone who's not currently connected (or doesn't have a client, really), in case you need that (mass replacements??)
 */
/datum/roster/proc/purge_unused_contestants(mob/user, purge_clientless_too = FALSE)
	message_admins("[key_name_admin(user)] has purged [length(ckeys_at_large)] ckeys at large!") // log which they chose
	log_game("[key_name_admin(user)] has purged [length(ckeys_at_large)] ckeys at large!")
	LAZYNULL(ckeys_at_large)

	if(!purge_clientless_too)
		return

	var/clientless_deleted = 0
	//maybe dump the info in an easily undoable way in case someone fucks up
	for(var/datum/contestant/iter_contestant in active_contestants) // all or active?
		if(!iter_contestant.get_mob().mind)
			clientless_deleted++
			delete_contestant(user, iter_contestant)
			// remove ckeys from contestant_ckeys?

	message_admins("[key_name_admin(user)] has also deleted [clientless_deleted] clientless contestants!") // log which they chose
	log_game("[key_name_admin(user)] has also deleted [clientless_deleted] clientless contestants!")

// match team slot procs
/// Called by arent computer, to be used for trying to add a team to one of the Match system's 2 team slots (team1 or team2, hardcoded for simplicity sake for this event)
/datum/roster/proc/try_load_team_slot(mob/user, slot)
	if(!slot  || !length(unrostered_teams))
		return
	if((slot == 1 && team1) || (slot == 2 && team2) || (slot == 3 && team3))
		testing("already a team in slot [slot]")
		return

	//testing("trying to get team from [user] for slot [slot], should be [LAZYLEN(unrostered_teams)] teams")
	message_admins("[key_name_admin(user)] is trying to load a team for slot [slot]!") // log which they chose
	log_game("[key_name_admin(user)] is trying to load a team for slot [slot]!")
	var/list/the_teams = list()

	for(var/datum/event_team/iter_team in unrostered_teams)
		//testing("adding [team_iterator_count] | team [iter_team.rostered_id]")
		the_teams["Team [iter_team.rostered_id]"] = iter_team

	var/selected_index = input(user, "Choose a team:", "Team", null) as null|anything in the_teams

	var/datum/event_team/the_team = the_teams[selected_index]
	if(!istype(the_team))
		to_chat(user, "<span class='warning'>No team or invalid team selected!</span>")
		return

	set_team_slot(user, the_team, slot)

/// Called by [/datum/roster/proc/try_load_team_slot] when we know which team we're putting into which slot
/datum/roster/proc/set_team_slot(mob/user, datum/event_team/the_team, slot)
	if(slot == 1)
		team1 = the_team
	else if(slot == 2)
		team2 = the_team
	else if(slot == 3)
		if(!three_team_round)
			message_admins("TRYING TO LOAD TEAM3 WHEN IT'S NOT MARKED AS A 3 TEAM ROUND! I'LL ALLOW IT, BUT TREAD CAREFULLY")
		team3 = the_team

	message_admins("[key_name_admin(user)] has loaded team [the_team] into slot [slot]!") // log which they chose
	log_game("[key_name_admin(user)] has loaded team [the_team] into slot [slot]!")
	LAZYREMOVE(unrostered_teams, the_team)

/// Called by the arena computer, to be used for removing a team from one of the 2 match slots
/datum/roster/proc/try_remove_team_slot(mob/user, slot)
	var/datum/event_team/removed_team
	if(slot == 1)
		removed_team = team1
		team1 = null
	else if(slot == 2)
		removed_team = team2
		team2 = null
	else if(slot == 3)
		removed_team = team3
		team3 = null

	if(removed_team)
		if(user)
			message_admins("[key_name_admin(user)] has removed team [removed_team] from match slot [slot]!") // only show message if done by someone?
		log_game("[key_name_admin(user)] has removed team [removed_team] from match slot [slot]!")
		LAZYADD(unrostered_teams, removed_team)


// match setup procs
/**
 * Called by the arena computer, to be used for showing the user the settings for automatically divvying up teams. You should only make even numbers of teams without remainder players, as I haven't added handling for those situations.
 *
 * These var names and descriptions make no sense because I rushed this and modals are kinda obnoxious with the options you have. I'll make it better, but for now, here's the scoop:
 * * team_event: If TRUE, make events, if FALSE, probably get ready for the battle royale section (not implemented, ask for limit of how many survivors to stop at)
 * * team_num_instead_of_size: If TRUE, we create [team_divvy_factor] teams, then spread the contestants evenly. If FALSE, we make as many teams of [team_divvy_factor] as we can.
 * * team_divvy_factor: Either how many teams, or how many people per team we want.
 */
/datum/roster/proc/try_setup_match(mob/user)
	var/list/settings = list(
		"mainsettings" = list(
			"team_event" = list("desc" = "Team Event? (Set to No for BR)", "type" = "boolean", "value" = "Yes"),
			"team_num_instead_of_size" = list("desc" = "If teams, divvy by team number instead of team size?", "type" = "boolean", "value" = "Yes"),
			"team_divvy_factor" = list("desc" = "If teams, what's the divvy factor? (ask if you don't know!)", "type" = "number", "value" = 2),
			"br_pop_goal" = list("desc" = "If this is a BR round, how many people should we stop the fighting at?", "type" = "number", "value" = 16),
			"three_team" = list("desc" = "Enable third team for the cooking round???", "type" = "boolean", "value" = "No")
		)
	)

	message_admins("[key_name(user)] is setting up next match...")
	var/list/prefreturn = presentpreflikepicker(user,"Setup Next Match", "Setup Next Match", Button1="Ok", width = 600, StealFocus = 1,Timeout = 0, settings=settings)


	if (isnull(prefreturn))
		return FALSE

	if (prefreturn["button"] == 1)
		var/list/prefs = settings["mainsettings"]

		setup_match(user, prefs)

/// To be used for interpreting the preflikepicker that defines the rules of the teams we're about to divvy up, and leads to divvying up the teams
/datum/roster/proc/setup_match(mob/user, list/prefs)
	var/teams = prefs["team_event"]["value"] == "Yes"
	var/divvy_teams_by_num_not_size = prefs["team_num_instead_of_size"]["value"] == "Yes"
	var/team_divvy_factor = prefs["team_divvy_factor"]["value"]
	var/three_team = prefs["three_team"]["value"] == "Yes"

	three_team_round = three_team

	testing("[user] is setting up match with values: Team event: [teams] (Three Team: [three_team]), [divvy_teams_by_num_not_size] divvy mode, [team_divvy_factor] divvy factor")
	if(!teams)
		br_end_population = prefs["br_pop_goal"]["value"]
		setup_battle_royale(user)
	else if(divvy_teams_by_num_not_size)
		divvy_into_teams(user, team_divvy_factor, 0)
	else
		divvy_into_teams(user, 0, team_divvy_factor)

/// Try to resolve a match, this manually asks you which of the two teams won (neither, either, or both). Losing teams will be marked for elimination, winning teams will be marked as proven. Both match team slots will be cleared
/datum/roster/proc/try_resolve_match(mob/user)
	message_admins("[key_name_admin(user)] is resolving the current match...")
	log_game("[key_name_admin(user)] is resolving the current match.")

	var/winner

	if(three_team_round)
		winner = input(user, "Which team lost?", "Loser!", null) as null|anything in list("All Lose", "Team 1 Lost", "Team 2 Lost", "Team 3 Lost")
	else
		winner = input(user, "Which teams won?", "Winner!", null) as null|anything in list("Both Lose", "Team 1 Wins", "Team 2 Wins", "Both Win")

	switch(winner)
		if("Both Lose")
			team1.match_result(FALSE)
			team2.match_result(FALSE)
			team3?.match_result(FALSE)
		if("Team 1 Wins")
			team1.match_result(TRUE)
			team2.match_result(FALSE)
		if("Team 2 Wins")
			team1.match_result(FALSE)
			team2.match_result(TRUE)
		if("Both Win")
			team1.match_result(TRUE)
			team2.match_result(TRUE)
		if("Team 1 Lost")
			team1.match_result(FALSE)
			team2.match_result(TRUE)
			team3.match_result(TRUE)
		if("Team 2 Lost")
			team1.match_result(TRUE)
			team2.match_result(FALSE)
			team3.match_result(TRUE)
		if("Team 3 Lost")
			team1.match_result(TRUE)
			team2.match_result(TRUE)
			team3.match_result(FALSE)
		else
			return

	try_remove_team_slot(user, 1)
	try_remove_team_slot(user, 2)
	if(team3)
		try_remove_team_slot(user, 3)

	message_admins("[key_name_admin(user)] has resolved the current match! Result: [winner]")
	log_game("[key_name_admin(user)] has resolved the current match! Result: [winner]")

/// A debug function, for when you need contestant datums but don't have people
/datum/roster/proc/add_empty_contestant(mob/user)
	var/rand_num = num2text(rand(1,10000))
	message_admins("[key_name_admin(user)] has added an empty contestant ([rand_num])!")
	log_game("[key_name_admin(user)] has added an empty contestant ([rand_num]).")
	var/datum/contestant/new_kid = new(rand_num)
	LAZYADDASSOC(all_contestants, rand_num, new_kid)
	LAZYADD(active_contestants, new_kid)
	new_kid.ckey = rand_num

/**
 * For spawning in teams at their respective spawnpoints. Please note, calling this with no 2nd argument spawns both team1 and team2
 *
 * Arguments:
 * * user: The person who called this
 * * spawning_team: If you want to specify one of the 2 team slots you're spawning, pass the team datum here. If there's no argument for this, we try spawning both teams (assuming there's a team for each slot)
 */
/datum/roster/proc/spawn_team(mob/user, datum/event_team/spawning_team)
	log_game("[key_name_admin(user)] has tried spawning teams!")

	if(battle_royale_active)
		spawn_battle_royale(user)
		return

	if(!istype(spawning_team))
		team1?.spawn_members(user, spawns_team1)
		team2?.spawn_members(user, spawns_team2)
		if(three_team_round)
			team3?.spawn_members(user, spawns_team3)
	else if(spawning_team == team1)
		team1.spawn_members(user, spawns_team1)
	else if(spawning_team == team2)
		team2.spawn_members(user, spawns_team2)
	else if(spawning_team == team3)
		team3.spawn_members(user, spawns_team3)

	message_admins("[key_name_admin(user)] has spawned [spawning_team ? "[spawning_team]" : "all slotted teams!"]")
	log_game("[key_name_admin(user)] has spawned [spawning_team ? "[spawning_team]" : "all slotted teams!"]")

/// Get rid of everyone who's currently spawned, disables mark for elimination on death for all of them
/datum/roster/proc/despawn_everyone(mob/user)
	var/deletes = 0
	for(var/datum/contestant/iter_contestant in live_contestants)
		iter_contestant.set_flag_on_death(FALSE)
		var/mob/living/iter_mob = iter_contestant.get_mob()
		if(istype(iter_mob))
			iter_mob.dust()
		iter_contestant.despawn()
		deletes++

	message_admins("[key_name_admin(user)] has dusted and despawned everyone ([deletes] contestants)!")
	log_game("[key_name_admin(user)] has dusted and despawned everyone ([deletes] contestants)!")

/datum/roster/proc/generate_antag_huds()
	for(var/team in teams)
		testing("Generating antag hud for team [team]")
		var/datum/atom_hud/antag/teamhud = team_huds[team]
		if(!teamhud) //These will be shared between arenas because this stuff is expensive and cross arena fighting is not a thing anyway
			teamhud = new
			teamhud.icon_color = team_colors[team]
			GLOB.huds += teamhud
			team_huds[team] = teamhud
			team_hud_index[team] = length(GLOB.huds)

/datum/roster/proc/get_team_antag_hud(datum/event_team/check_team)
	if(!check_team)
		return

	if(check_team == team1)
		return team_huds[ARENA_RED_TEAM]
	else if(check_team == team2)
		return team_huds[ARENA_GREEN_TEAM]
	else if(check_team == team3)
		return team_huds[ARENA_BLUE_TEAM]

/datum/roster/proc/get_team_slot(datum/event_team/check_team)
	if(!check_team)
		return

	if(check_team == team1)
		return ARENA_RED_TEAM
	else if(check_team == team2)
		return ARENA_GREEN_TEAM
	else if(check_team == team3)
		return ARENA_BLUE_TEAM

/datum/roster/proc/add_contestant_to_antag_hud(datum/event_team/check_team)
	if(!check_team)
		return

	if(check_team == team1)
		return team_huds[ARENA_RED_TEAM]
	else if(check_team == team2)
		return team_huds[ARENA_GREEN_TEAM]
	else if(check_team == team3)
		return team_huds[ARENA_BLUE_TEAM]

/*
/obj/machinery/computer/arena/proc/spawn_member(obj/machinery/arena_spawn/spawnpoint,ckey,team)
	var/mob/oldbody = get_mob_by_key(ckey)
	if(!isobserver(oldbody))
		return
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(spawnpoint))
	oldbody.client.prefs.copy_to(M)
	M.set_species(/datum/species/human) // Could use setting per team
	M.equipOutfit(outfits[team] ? outfits[team] : default_outfit)
	M.faction += team //In case anyone wants to add team based stuff to arena special effects
	M.key = ckey

	var/datum/atom_hud/antag/team_hud = team_huds[team]
	team_hud.join_hud(M)
	set_antag_hud(M,"arena",team_hud_index[team])
	*/

/// For forcing everyone to freeze, including future spawning contestants. Or for unfreezing them all
/datum/roster/proc/set_frozen_all(mob/user, str_toggle)
	var/mode
	if(str_toggle == "on")
		mode = TRUE
	else if(str_toggle == "off")
		mode = FALSE
	else
		return

	// set on all the teams first
	for(var/datum/event_team/iter_team in active_teams)
		iter_team.set_frozen(null, mode)

	// then set on all the individual contestants, just in case
	for(var/datum/contestant/iter_contestant in all_contestants)
		iter_contestant.set_frozen(null, mode)

	message_admins("[key_name_admin(user)] has [mode ? "FROZEN" : "UNFROZEN"] everyone")
	log_game("[key_name_admin(user)] has [mode ? "FROZEN" : "UNFROZEN"] everyone")

/// For forcing everyone to godmode, including future spawning contestants. Or for ungodmodeing them all
/datum/roster/proc/set_godmode_all(mob/user, str_toggle)
	var/mode
	if(str_toggle == "on")
		mode = TRUE
	else if(str_toggle == "off")
		mode = FALSE
	else
		return

	// set on all the teams first
	for(var/datum/event_team/iter_team in active_teams)
		iter_team.set_godmode(null, mode)

	// then set on all the individual contestants, just in case
	for(var/datum/contestant/iter_contestant in all_contestants)
		iter_contestant.set_godmode(null, mode)

	message_admins("[key_name_admin(user)] has [mode ? "GODMODED" : "UNGODMODED"] everyone")
	log_game("[key_name_admin(user)] has [mode ? "GODMODED" : "UNGODMODED"] everyone")

/// For enabling/disabling random wounds
/datum/roster/proc/toggle_wounds(mob/user)
	enable_random_wounds = !enable_random_wounds

	message_admins("[key_name_admin(user)] has [enable_random_wounds ? "ENABLED" : "DISABLED"] random wounds!")
	log_game("[key_name_admin(user)] has [enable_random_wounds ? "ENABLED" : "DISABLED"] random wounds!")
