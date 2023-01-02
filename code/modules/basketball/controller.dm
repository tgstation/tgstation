///how many people can play basketball without issues (running out of spawns, procs not expecting more than this amount of people, etc)
#define BASKETBALL_MIN_PLAYER_COUNT 2
#define BASKETBALL_MAX_PLAYER_COUNT 8 // shoould be 6

#define BASKETBALL_TEAM_HOME "home"
#define BASKETBALL_TEAM_AWAY "away"

//#define MAFIA_PHASE_SETUP 1
//#define MAFIA_PHASE_VICTORY_LAP 6
///signal sent to roles when the game is confirmed ending
//#define COMSIG_MAFIA_GAME_END "game_end"

/// list of ghosts who want to play mafia, every time someone enters the list it checks to see if enough are in
GLOBAL_LIST_EMPTY(basketball_signup)
/// list of ghosts who want to play mafia that have since disconnected. They are kept in the lobby, but not counted for starting a game.
GLOBAL_LIST_EMPTY(basketball_bad_signup)
/// the current global mafia game running.
GLOBAL_VAR(basketball_game)

/**
 * The basketball controller handles the basketball minigame in progress.
 * It is first created when the first ghost signs up to play.
 */
/datum/basketball_controller
	///template picked when the game starts. used for the name and desc reading
	var/datum/map_template/basketball/current_map
	///map generation tool that deletes the current map after the game finishes
	var/datum/map_generator/massdelete/map_deleter

	/// Spawn points for home team players
	var/list/home_team_landmarks = list()
	/// Home team players
	var/list/home_team_players = list()

	/// Spawn points for away team players
	var/list/away_team_landmarks = list()
	/// Away team players
	var/list/away_team_players = list()

/datum/basketball_controller/New()
	. = ..()
	GLOB.basketball_game = src
	map_deleter = new

/datum/basketball_controller/Destroy(force, ...)
	. = ..()
	GLOB.basketball_game = null
	end_game()
	qdel(map_deleter)

/**
 * Triggers at beginning of the game when there is a confirmed list of valid, ready players.
 * Creates a 100% ready game that has NOT started (no players in bodies)
 * Followed by start game
 *
 * Does the following:
 * * Picks map, and loads it
 * * Grabs landmarks if it is the first time it's loading
 * * Puts players in each team randomly
 * Arguments:
 * * ready_players: list of filtered, sane players (so not playing or disconnected) for the game to put into roles
 */
/datum/basketball_controller/proc/prepare_game(ready_players)
	var/list/possible_maps = subtypesof(/datum/map_template/basketball)
	var/turf/spawn_area = get_turf(locate(/obj/effect/landmark/basketball/game_area) in GLOB.landmarks_list)

	current_map = pick(possible_maps)
	current_map = new current_map

	if(!spawn_area)
		CRASH("No spawn area detected for Basketball Minigame!")
	var/list/bounds = current_map.load(spawn_area)
	if(!bounds)
		CRASH("Loading basketball map failed!")
	map_deleter.defineRegion(spawn_area, locate(spawn_area.x + 23, spawn_area.y + 23,spawn_area.z), replace = TRUE) //so we're ready to mass delete when round ends

	if(!home_team_landmarks.len)
		for(var/obj/effect/landmark/basketball/team_spawn/home/possible_spawn in GLOB.landmarks_list)
			home_team_landmarks += possible_spawn

	if(!away_team_landmarks.len)
		for(var/obj/effect/landmark/basketball/team_spawn/away/possible_spawn in GLOB.landmarks_list)
			away_team_landmarks += possible_spawn

	var/list/home_spawnpoints = home_team_landmarks.Copy()
	var/list/away_spawnpoints = away_team_landmarks.Copy()

	create_bodies(ready_players)

/**
 * The game by this point is now all set up, and so we can put people in their bodies and start the first phase.
 *
 * Does the following:
 * * Creates bodies for all of the roles with the first proc
 * * Starts the first day manually (so no timer) with the second proc
 */
/datum/basketball_controller/proc/start_game()
	create_bodies()
	//start_game()

/**
 * Called when the game is setting up, AFTER map is loaded but BEFORE the phase timers start. Creates and places each role's body and gives the correct player key
 *
 * Notably:
 * * Toggles godmode so the mafia players cannot kill themselves
 * * Adds signals for voting overlays, see display_votes proc
 * * gives mafia panel
 * * sends the greeting text (goals, role name, etc)
 */
/datum/basketball_controller/proc/create_bodies(ready_players)
	var/list/possible_away_teams = subtypesof(/datum/map_template/basketball) - current_map
	var/datum/map_template/basketball/away_map = pick(possible_away_teams)

	var/list/home_spawnpoints = home_team_landmarks.Copy()
	var/list/away_spawnpoints = away_team_landmarks.Copy()
	var/obj/effect/landmark/basketball/team_spawn/spawn_landmark

	var/team_uniform
	var/team_name

	for(var/player_key in ready_players)


		// we need an iterator that ++1 so we can get correct even/odds



		if(length(ready_players) % 2) // odd is home team
			spawn_landmark = pick_n_take(home_spawnpoints)
			home_team_players |= player_key
			team_uniform = current_map.home_team_uniform
			team_name = current_map.team_name
		else // even is away team
			spawn_landmark = pick_n_take(away_spawnpoints)
			away_team_players |= player_key
			team_uniform = away_map.home_team_uniform
			team_name = away_map.team_name

		var/mob/living/carbon/human/baller = new(get_turf(spawn_landmark))

		if(baller.dna.species.outfit_important_for_life)
			baller.set_species(/datum/species/human)

		ADD_TRAIT(baller, TRAIT_NOFIRE, BASKETBALL_MINIGAME_TRAIT)
		ADD_TRAIT(baller, TRAIT_NOBREATH, BASKETBALL_MINIGAME_TRAIT)
		ADD_TRAIT(baller, TRAIT_CANNOT_CRYSTALIZE, BASKETBALL_MINIGAME_TRAIT)
		// this is basketball, not a boxing match
		ADD_TRAIT(baller, TRAIT_PACIFISM, BASKETBALL_MINIGAME_TRAIT)
		baller.status_flags |= GODMODE

		if(!team_uniform)
			team_uniform = prob(50) ? /obj/item/clothing/under/shorts/blue : /obj/item/clothing/under/shorts/red

		baller.equipOutfit(team_uniform)

		var/client/player_client = GLOB.directory[player_key]
		if(player_client)
			player_client.prefs.safe_transfer_prefs_to(baller, is_antag = TRUE)
		baller.key = player_key

		SEND_SOUND(baller, 'sound/machines/scanbuzz.ogg')
		to_chat(baller, span_danger("You are a basketball player for the [team_name]. Score as much as you can before time runs out."))

/datum/basketball_controller/proc/check_victory()
	return

/**
 * Cleans up the game, resetting variables back to the beginning and removing the map with the generator.
 */
/datum/basketball_controller/proc/end_game()
	return


//////////////////////////////////////////

/**
 * Called when enough players have signed up to fill a setup. DOESN'T NECESSARILY MEAN THE GAME WILL START.
 *
 * Checks for a custom setup, if so gets the required players from that and if not it sets the player requirement to MAFIA_MAX_PLAYER_COUNT and generates one IF basic setup starts a game.
 * Checks if everyone signed up is an observer, and is still connected. If people aren't, they're removed from the list.
 * If there aren't enough players post sanity, it aborts. otherwise, it selects enough people for the game and starts preparing the game for real.
 */
/datum/basketball_controller/proc/basic_setup()
	//final list for all the players who will be in this game
	var/list/filtered_keys = list()
	//cuts invalid players from signups (disconnected/not a ghost)
	var/list/possible_keys = list()
	for(var/key in GLOB.basketball_signup)
		if(GLOB.directory[key])
			var/client/C = GLOB.directory[key]
			if(isobserver(C.mob))
				possible_keys += key
				continue
		GLOB.basketball_signup -= key //not valid to play when we checked so remove them from signups

	//if there were not enough players, don't start. we already trimmed the list to now hold only valid signups
	if(length(possible_keys) < BASKETBALL_MIN_PLAYER_COUNT)
		return

	var/req_players = length(possible_keys) >= BASKETBALL_MAX_PLAYER_COUNT ? BASKETBALL_MAX_PLAYER_COUNT : length(possible_keys)
	// both teams need to have the same number of players, so we remove one person if it's an odd number
	req_players -= req_players % 2

	//if there were too many players, still start but only make filtered keys as big as it needs to be (cut excess)
	//also removes people who do get into final player list from the signup so they have to sign up again when game ends
	for(var/i in 1 to req_players)
		var/chosen_key = pick_n_take(possible_keys)
		filtered_keys += chosen_key
		GLOB.basketball_signup -= chosen_key

	//small message about not getting into this game for clarity on why they didn't get in
	for(var/unpicked in possible_keys)
		var/client/unpicked_client = GLOB.directory[unpicked]
		to_chat(unpicked_client, span_danger("Sorry, the starting basketball game has too many players and you were not picked."))
		to_chat(unpicked_client, span_warning("You're still signed up, getting messages from the current round, and have another chance to join when the one starting now finishes."))

	prepare_game(filtered_keys)
	//start_game()
