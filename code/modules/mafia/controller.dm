GLOBAL_LIST_INIT(mafia_roles_by_name, setup_mafia_roles_by_name())

GLOBAL_LIST_INIT(mafia_role_by_alignment, setup_mafia_role_by_alignment())

///How many votes are needed to unlock the 'Universally Hated' achievement.
#define UNIVERSALLY_HATED_REQUIREMENT 12

/**
 * The mafia controller handles the mafia minigame in progress.
 * It is first created when the first ghost signs up to play.
 */
/datum/mafia_controller
	///all roles in the game, dead or alive. check their game status if you only want living or dead.
	var/list/datum/mafia_role/all_roles = list()
	///all living roles in the game, removed on death.
	var/list/datum/mafia_role/living_roles = list()
	///exists to speed up role retrieval, it's a dict.
	/// `player_role_lookup[player ckey/PDA]` will give you the role they play
	var/list/player_role_lookup = list()
	///what part of the game you're playing in. day phases, night phases, judgement phases, etc.
	var/phase = MAFIA_PHASE_SETUP
	///how long the game has gone on for, changes with every sunrise. day one, night one, day two, etc.
	var/turn = 0

	///How much faster the game should be, which triggers when half the players are dead.
	var/time_speedup = 1

	///for debugging and testing a full game, or adminbuse. If this is not empty, it will use this as a setup. clears when game is over
	var/list/custom_setup

	///template picked when the game starts. used for the name and desc reading
	var/datum/map_template/mafia/current_map
	///map generation tool that deletes the current map after the game finishes
	var/datum/map_generator/massdelete/map_deleter

	///Readable list of roles in current game, sent to the tgui panel for roles list > list("Psychologist x1", "Clown x2")
	var/list/current_setup_text

	///starting outfit for all mafia players. it's just a grey jumpsuit.
	var/player_outfit = /datum/outfit/mafia

	///spawn points for players, each one has a house
	var/list/landmarks = list()
	///town center for when people get put on trial
	var/town_center_landmark

	///group voting on one person, like putting people to trial or choosing who to kill as mafia
	var/list/votes = list()
	///and these (judgement_innocent_votes, judgement_abstain_votes and judgement_guilty_votes) are the judgement phase votes, aka people sorting themselves into guilty and innocent, and "eh, i don't really care" lists. whichever has more inno or guilty wins!
	var/list/judgement_abstain_votes = list()
	var/list/judgement_innocent_votes = list()
	var/list/judgement_guilty_votes = list()
	///current role on trial for the judgement phase, will die if guilty is greater than innocent
	var/datum/mafia_role/on_trial

	///current timer for phase
	var/next_phase_timer

	///was our game forced to start early?
	var/early_start = FALSE

	///The 12 roles used in a default game, selected randomly from each list, going in order of position.
	///This is balanced for player amount, regardless of players you'll still be about equal town and evils.
	var/static/list/default_role_list = list(
		//town
		list(TOWN_INVEST, TOWN_OVERFLOW),
		list(TOWN_SUPPORT),
		//mafia
		list(MAFIA_REGULAR),
		//town
		list(TOWN_INVEST),
		//neutral
		list(NEUTRAL_DISRUPT),
		//town
		list(TOWN_PROTECT),
		list(TOWN_OVERFLOW),
		//mafia hard-hitting
		list(MAFIA_REGULAR, MAFIA_SPECIAL),
		//town
		list(TOWN_PROTECT, TOWN_KILLING),
		list(TOWN_KILLING),
		//neutral hard-hitting
		list(NEUTRAL_KILL, NEUTRAL_DISRUPT),
		//town
		list(TOWN_SUPPORT, TOWN_OVERFLOW),
	)

/proc/setup_mafia_roles_by_name()
	var/list/rolelist_dict = list()
	for(var/datum/mafia_role/mafia_role as anything in typesof(/datum/mafia_role))
		rolelist_dict[initial(mafia_role.name) + " ([uppertext(initial(mafia_role.role_type))])"] = mafia_role
	return rolelist_dict

/proc/setup_mafia_role_by_alignment()
	var/list/rolelist_dict = list()
	for(var/datum/mafia_role/mafia_role as anything in typesof(/datum/mafia_role))
		if(!rolelist_dict[initial(mafia_role.role_type)])
			rolelist_dict[initial(mafia_role.role_type)] = list()
		rolelist_dict[initial(mafia_role.role_type)] += mafia_role
	return rolelist_dict

/datum/mafia_controller/New()
	. = ..()
	GLOB.mafia_game = src
	map_deleter = new

/datum/mafia_controller/Destroy(force)
	. = ..()
	end_game()
	player_role_lookup.Cut()
	QDEL_NULL(map_deleter)
	if(GLOB.mafia_game == src)
		GLOB.mafia_game = null

/**
 * Triggers at beginning of the game when there is a confirmed list of valid, ready players.
 * Creates a 100% ready game that has NOT started (no players in bodies)
 * Followed by start game
 *
 * Does the following:
 * * Picks map, and loads it
 * * Grabs landmarks if it is the first time it's loading
 * * Sets up the role list
 * * Puts players in each role randomly
 * Arguments:
 * * setup_list: list of all the datum setups (fancy list of roles) that would work for the game
 * * ready_ghosts_and_pdas: list of filtered, sane (so not playing or disconnected) ghost ckeys & PDAs for the game to put into roles.
 */
/datum/mafia_controller/proc/prepare_game(setup_list, ready_ghosts_and_pdas)
	var/static/list/possible_maps = subtypesof(/datum/map_template/mafia)
	var/turf/spawn_area = get_turf(locate(/obj/effect/landmark/mafia_game_area) in GLOB.landmarks_list)

	current_map = pick(possible_maps)
	current_map = new current_map

	if(!spawn_area)
		CRASH("No spawn area detected for Mafia!")
	var/list/bounds = current_map.load(spawn_area)
	if(!bounds)
		CRASH("Loading mafia map failed!")
#ifdef UNIT_TESTS //unit test map is smaller
	map_deleter.defineRegion(spawn_area, locate(spawn_area.x + 7, spawn_area.y + 7, spawn_area.z), replace = TRUE) //so we're ready to mass delete when round ends
#else
	map_deleter.defineRegion(spawn_area, locate(spawn_area.x + 23, spawn_area.y + 23, spawn_area.z), replace = TRUE) //so we're ready to mass delete when round ends
#endif
	if(!landmarks.len)//we grab town center when we grab landmarks, if there is none (the first game signed up for let's grab them post load)
		for(var/obj/effect/landmark/mafia/possible_spawn in GLOB.landmarks_list)
			if(istype(possible_spawn, /obj/effect/landmark/mafia/town_center))
				town_center_landmark = possible_spawn
			else
				landmarks += possible_spawn

	current_setup_text = list()
	for(var/rtype in setup_list)
		for(var/i in 1 to setup_list[rtype])
			var/datum/mafia_role/new_role = new rtype(src)
			all_roles += new_role
			living_roles += new_role
		var/datum/mafia_role/role_type = rtype
		current_setup_text += "[initial(role_type.name)] x[setup_list[role_type]]"
	var/list/spawnpoints = landmarks.Copy()
	for(var/datum/mafia_role/role as anything in all_roles)
		role.assigned_landmark = pick_n_take(spawnpoints)
		var/selected_player //this can be a ckey or a PDA
		selected_player = pick(ready_ghosts_and_pdas)
		var/client/player_client = GLOB.directory[selected_player]
		if(player_client)
			role.player_key = selected_player
		else
			role.player_pda = selected_player
		ready_ghosts_and_pdas -= selected_player

/**
 * send_message
 * By default, this will send a message to every single role in the game, and putting it in their role message history
 * to view on their PDA/Mafia panel.
 * Args:
 * - msg: The message being sent.
 * - team: A specific team flag that will receive the message, so people not part of it will not get it. Ex: Changeling-only messages.
 * - log_only: Will not send the message to the player's chat, only their PDA/Mafia panel, for messages that aren't
 * needed to be flooding their chat for people who are there physically, such as Day/Night starting.
 */
/datum/mafia_controller/proc/send_message(msg, team, log_only = FALSE)
	for(var/datum/mafia_role/role as anything in all_roles)
		if(team && !(role.team & team))
			continue
		//people who can "hear" the dead, but are alive, can only hear at night.
		if((team & MAFIA_TEAM_DEAD) && role.game_status == MAFIA_ALIVE && phase != MAFIA_PHASE_NIGHT)
			return
		role.role_messages += msg
		if(!log_only)
			to_chat(role.body, msg)

/**
 * The game by this point is now all set up, and so we can put people in their bodies and start the first phase.
 *
 * Does the following:
 * * Creates bodies for all of the roles with the first proc
 * * Starts the first day manually (so no timer) with the second proc
 */
/datum/mafia_controller/proc/start_game()
	create_bodies()
	SEND_GLOBAL_SIGNAL(COMSIG_MAFIA_GAME_START, src)
	start_day(can_vote = FALSE)
	send_message(span_notice("<b>The selected map is [current_map.name]!</b></br> [current_map.description]"))
	send_message("<b>Day [turn] started! There is no voting on the first day. Say hello to everybody!</b>")
	next_phase_timer = addtimer(CALLBACK(src, PROC_REF(check_trial), FALSE), (FIRST_DAY_PERIOD_LENGTH / time_speedup), TIMER_STOPPABLE) //no voting period = no votes = instant night
	for(var/datum/mafia_role/roles as anything in all_roles)
		var/obj/item/modular_computer/modpc = roles.player_pda
		if(!modpc)
			update_static_data(roles.body)
			continue
		modpc.update_static_data_for_all_viewers()

/**
 * How every day starts.
 *
 * What players do in this phase:
 * * If day one, just a small starting period to see who is in the game and check role, leading to the night phase.
 * * Otherwise, it's a longer period used to discuss events that happened during the night, leading to the voting phase.
 */
/datum/mafia_controller/proc/start_day(can_vote = TRUE)
	turn += 1
	phase = MAFIA_PHASE_DAY
	if(check_victory())
		return

	if(!time_speedup)//lets check if the game should be sped up, if not already.
		if(living_roles.len < all_roles.len / 2)
			time_speedup = MAFIA_SPEEDUP_INCREASE
			send_message("<span class='bold notice'>With only [living_roles.len] living players left, the game timers have been sped up.</span>")

	if(can_vote)
		send_message("<b>Day [turn] started! Voting will start in 1 minute.</b>")
		next_phase_timer = addtimer(CALLBACK(src, PROC_REF(start_voting_phase)), (DAY_PERIOD_LENGTH / time_speedup), TIMER_STOPPABLE)

/**
 * Players have finished the discussion period, and now must put up someone to the chopping block.
 *
 * What players do in this phase:
 * * Vote on which player to put up for lynching, leading to the judgement phase.
 * * If no votes are case, the judgement phase is skipped, leading to the night phase.
 */
/datum/mafia_controller/proc/start_voting_phase()
	phase = MAFIA_PHASE_VOTING
	next_phase_timer = addtimer(CALLBACK(src, PROC_REF(check_trial), TRUE), (VOTING_PERIOD_LENGTH / time_speedup), TIMER_STOPPABLE) //be verbose!
	send_message("<b>Voting started! Vote for who you want to see on trial today.</b>")

/**
 * Players have voted someone up, and now the person must defend themselves while the town votes innocent or guilty.
 *
 * What players do in this phase:
 * * Vote innocent or guilty, if they are not on trial.
 * * Defend themselves and wait for judgement, if they are.
 * * Leads to the lynch phase.
 * Arguments:
 * * verbose: boolean, announces whether there were votes or not. after judgement it goes back here with no voting period to end the day.
 */
/datum/mafia_controller/proc/check_trial(verbose = TRUE)
	var/datum/mafia_role/loser = get_vote_winner("Day")//, majority_of_town = TRUE)
	var/loser_votes = get_vote_count(loser, "Day")
	if(loser)
		if(loser_votes > UNIVERSALLY_HATED_REQUIREMENT)
			award_role(/datum/award/achievement/mafia/universally_hated, loser)
		//refresh the lists
		judgement_abstain_votes = list()
		judgement_innocent_votes = list()
		judgement_guilty_votes = list()

		for(var/datum/mafia_role/voters as anything in living_roles)
			if(voters == loser)
				continue
			voters.mafia_alert.update_text("[loser.body.real_name] wins the day vote, Listen to their defense and vote INNOCENT or GUILTY!")
			judgement_abstain_votes += voters

		on_trial = loser
		on_trial.body.forceMove(get_turf(town_center_landmark))
		phase = MAFIA_PHASE_JUDGEMENT
		next_phase_timer = addtimer(CALLBACK(src, PROC_REF(lynch)), (JUDGEMENT_PERIOD_LENGTH / time_speedup), TIMER_STOPPABLE)
		reset_votes("Day")
	else
		lockdown()
		if(verbose)
			send_message("<b>Not enough people have voted to put someone on trial, nobody will be lynched today.</b>")

/**
 * Players have voted innocent or guilty on the person on trial, and that person is now killed or returned home.
 *
 * What players do in this phase:
 * * r/watchpeopledie
 * * If the accused is killed, their true role is revealed to the rest of the players.
 */
/datum/mafia_controller/proc/lynch()
	for(var/datum/mafia_role/role as anything in judgement_abstain_votes)
		send_message(span_comradio("[role.body.real_name] abstained."))

	var/total_innocent_votes
	for(var/datum/mafia_role/role as anything in judgement_innocent_votes)
		send_message(span_green("[role.body.real_name] voted innocent."))
		total_innocent_votes += role.vote_power

	var/total_guilty_votes
	for(var/datum/mafia_role/role as anything in judgement_guilty_votes)
		send_message(span_red("[role.body.real_name] voted guilty."))
		total_guilty_votes += role.vote_power

	if(total_guilty_votes > total_innocent_votes) //strictly need majority guilty to lynch
		send_message(span_red("<b>Guilty wins majority, [on_trial.body.real_name] has been lynched.</b>"))
		on_trial.kill(src, lynch = TRUE)
		next_phase_timer = addtimer(CALLBACK(src, PROC_REF(send_home), on_trial), (LYNCH_PERIOD_LENGTH / time_speedup), TIMER_STOPPABLE)
	else
		send_message(span_green("<b>Innocent wins majority, [on_trial.body.real_name] has been spared.</b>"))
		on_trial.body.forceMove(get_turf(on_trial.assigned_landmark))
	on_trial = null
	if(!check_victory())
		//day votes are already cleared, so this will skip the trial and check victory/lockdown/whatever else
		next_phase_timer = addtimer(CALLBACK(src, PROC_REF(check_trial), FALSE), (LYNCH_PERIOD_LENGTH / time_speedup), TIMER_STOPPABLE)// small pause to see the guy dead, no verbosity since we already did this

/**
 * Teenie helper proc to move players back to their home.
 * Used in the above, but also used in the debug button "send all players home"
 * Arguments:
 * * role: mafia role that is getting sent back to the game.
 */
/datum/mafia_controller/proc/send_home(datum/mafia_role/role)
	role.body.forceMove(get_turf(role.assigned_landmark))

/**
 * Checks to see if a faction (or solo antagonist) has won.
 *
 * Calculates in this order:
 * * counts up town, mafia, and solo
 * * solos can count as town members for the purposes of mafia winning
 * * sends the amount of living people to the solo antagonists, and see if they won, then if town, then if mafia
 * * starts the end of the game if a faction won
 * * returns TRUE if someone won the game, halting other procs from continuing in the case of a victory
 */
/datum/mafia_controller/proc/check_victory()
	var/list/datum/mafia_role/living_town = list()
	var/list/datum/mafia_role/living_mafia = list()
	var/list/datum/mafia_role/living_neutrals = list()

	var/list/datum/mafia_role/neutral_killers = list()

	//voting power of town + solos (since they don't want mafia to overpower)
	var/anti_mafia_power = 0
	//whether town has a role that can theoretically get someone killed singlehandedly.
	var/town_can_kill = FALSE

	for(var/datum/mafia_role/R as anything in living_roles)
		if(R.team & MAFIA_TEAM_MAFIA)
			living_mafia += R
		else if(R.team & MAFIA_TEAM_TOWN)
			living_town += R
			anti_mafia_power += R.vote_power
			//the game cannot autoresolve with killing roles (unless a solo wins anyways, like traitors who are immune)
			if(R.role_flags & ROLE_CAN_KILL)
				town_can_kill = TRUE
		else if(R.team & MAFIA_TEAM_SOLO)
			living_neutrals += R
			anti_mafia_power += R.vote_power
			if(R.role_flags & ROLE_CAN_KILL)
				neutral_killers += R
		else
			stack_trace("[R] somehow lacks a faction while alive in a Mafia match!")

	if(living_mafia.len && living_town.len && living_neutrals.len)
		return FALSE

	var/victory_message

	if(living_mafia.len + living_town.len <= 0)
		victory_message = "Draw!</span>" //this is in-case no neutrals won, but there's no town/mafia left.
		for(var/datum/mafia_role/solo as anything in neutral_killers)
			victory_message = "[uppertext(solo.name)] VICTORY!</span>"
			if(!early_start)
				award_role(solo.winner_award, solo)

	else if(!living_mafia.len && !neutral_killers.len)
		victory_message = "TOWN VICTORY!</span>"
		if(!early_start)
			for(var/datum/mafia_role/townie as anything in living_town)
				award_role(townie.winner_award, townie)

	else if((living_mafia.len >= anti_mafia_power) && !town_can_kill && !neutral_killers.len)
		victory_message = "MAFIA VICTORY!</span>"
		if(!early_start)
			for(var/datum/mafia_role/changeling as anything in living_mafia)
				award_role(changeling.winner_award, changeling)

	if(victory_message)
		start_the_end(victory_message)
		return TRUE
	return FALSE

/**
 * Lets the game award roles with all their checks and sanity, prevents achievements given out for debug games
 *
 * Arguments:
 * * award: path of the award
 * * role: mafia_role datum to reward.
 */
/datum/mafia_controller/proc/award_role(award, datum/mafia_role/rewarded)
	rewarded.body?.client?.give_award(award, rewarded.body)
	if(!rewarded.player_pda)
		return
	for(var/datum/tgui/window as anything in rewarded.player_pda.open_uis)
		window.user?.client?.give_award(award, window.user.client.mob)

/**
 * The end of the game is in two procs, because we want a bit of time for players to see eachothers roles.
 * Because of how check_victory works, the game is halted in other places by this point.
 * We won't delete ourselves in a certain amount of time in unit tests, as the unit test will handle our deletion instead.
 *
 * What players do in this phase:
 * * See everyone's role postgame
 * * See who won the game
 * Arguments:
 * * message: string, if non-null it sends it to all players. used to announce team victories while solos are handled in check victory
 */
/datum/mafia_controller/proc/start_the_end(message)
	SEND_SIGNAL(src, COMSIG_MAFIA_GAME_END)
	for(var/datum/mafia_role/roles as anything in all_roles)
		if(message)
			roles.mafia_alert.update_text("[message]")
		roles.reveal_role(src)
	phase = MAFIA_PHASE_VICTORY_LAP
#ifndef UNIT_TESTS
	next_phase_timer = QDEL_IN_STOPPABLE(src, VICTORY_LAP_PERIOD_LENGTH)
#endif

/**
 * Cleans up the game, resetting variables back to the beginning and removing the map with the generator.
 */
/datum/mafia_controller/proc/end_game()
	QDEL_LIST(all_roles)
	living_roles.Cut()
	QDEL_LIST(landmarks)
	QDEL_NULL(town_center_landmark)
	map_deleter.generate() //remove the map, it will be loaded at the start of the next onemap_deleter.generate() //remove the map, it will be loaded at the start of the next one

/**
 * After the voting and judgement phases, the game goes to night shutting the windows and beginning night with a proc.
 */
/datum/mafia_controller/proc/lockdown()
	toggle_night_curtains(close=TRUE)
	start_night()

/**
 * Shuts poddoors attached to mafia.
 * Arguments:
 * * close: boolean, the state you want the curtains in.
 */
/datum/mafia_controller/proc/toggle_night_curtains(close)
	for(var/obj/machinery/door/poddoor/D as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/poddoor))
		if(D.id != "mafia") //so as to not trigger shutters on station, lol
			continue
		if(close)
			INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door/poddoor, close))
		else
			INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door/poddoor, open))

/**
 * The actual start of night for players. Mostly info is given at the start of the night as the end of the night is when votes and actions are submitted and tried.
 *
 * What players do in this phase:
 * * Mafia are told to begin voting on who to kill
 * * Powers that are picked during the day announce themselves right now
 */
/datum/mafia_controller/proc/start_night()
	phase = MAFIA_PHASE_NIGHT
	send_message("<b>Night [turn] started! Lockdown will end in 40 seconds.</b>")
	SEND_SIGNAL(src, COMSIG_MAFIA_SUNDOWN)
	next_phase_timer = addtimer(CALLBACK(src, PROC_REF(resolve_night)), (NIGHT_PERIOD_LENGTH / time_speedup), TIMER_STOPPABLE)

/**
 * The end of the night, and a series of signals for the order of events on a night.
 *
 * Order of events, and what they mean:
 * * Start of resolve (NIGHT_START) is for activating night abilities that MUST go first
 * * Action phase (NIGHT_ACTION_PHASE) is for non-lethal day abilities
 * * Mafia then tallies votes and kills the highest voted person (note: one random voter visits that person for the purposes of roleblocking)
 * * Killing phase (NIGHT_KILL_PHASE) is for lethal night abilities
 * * End of resolve (NIGHT_END) is for cleaning up abilities that went off and i guess doing some that must go last
 * * Finally opens the curtains and calls the start of day phase, completing the cycle until check victory returns TRUE
 */
/datum/mafia_controller/proc/resolve_night()
	SEND_SIGNAL(src, COMSIG_MAFIA_NIGHT_PRE_ACTION_PHASE)
	SEND_SIGNAL(src, COMSIG_MAFIA_NIGHT_ACTION_PHASE)
	SEND_SIGNAL(src, COMSIG_MAFIA_NIGHT_KILL_PHASE)
	SEND_SIGNAL(src, COMSIG_MAFIA_NIGHT_END)
	toggle_night_curtains(close=FALSE)
	start_day()

/**
 * Proc that goes off when players vote for something with their mafia panel.
 *
 * If teams, it hides the tally overlay and only sends the vote messages to the team that is voting
 * Arguments:
 * * voter: the mafia role that is trying to vote for...
 * * target: the mafia role that is getting voted for
 * * vote_type: type of vote submitted (is this the day vote? is this the mafia night vote?)
 * * teams: see mafia team defines for what to put in, makes the messages only send to a specific team (so mafia night votes only sending messages to mafia at night)
 */
/datum/mafia_controller/proc/vote_for(datum/mafia_role/voter, datum/mafia_role/target, vote_type, teams)
	if(!votes[vote_type])
		votes[vote_type] = list()
	var/old_vote = votes[vote_type][voter]
	if(old_vote && old_vote == target)
		votes[vote_type] -= voter
	else
		votes[vote_type][voter] = target
	if(old_vote && old_vote == target)
		voter.body.maptext_y = initial(voter.body.maptext_y)
		voter.body.maptext_x = initial(voter.body.maptext_x)
		voter.body.maptext_width = initial(voter.body.maptext_width)
		voter.body.maptext = null
		send_message(span_notice("[voter.body.real_name] retracts their vote for [target.body.real_name]!"), team = teams)
	else
		voter.body.maptext_y = 12
		voter.body.maptext_x = -16
		voter.body.maptext_width = 64
		voter.body.maptext = "<span class='maptext' style='text-align: center; vertical-align: top'>[target.body.real_name]</span>"
		send_message(span_notice("[voter.body.real_name] voted for [target.body.real_name]!"), team = teams)
	if(!teams)
		target.body.update_appearance() //Update the vote display if it's a public vote
		var/datum/mafia_role/old = old_vote
		if(old)
			old.body.update_appearance()

/**
 * Clears out the votes of a certain type (day votes, mafia kill votes) while leaving others untouched
 */
/datum/mafia_controller/proc/reset_votes(vote_type)
	var/list/bodies_to_update = list()
	for(var/datum/mafia_role/voter as anything in votes[vote_type])
		voter.body.maptext_y = initial(voter.body.maptext_y)
		voter.body.maptext_x = initial(voter.body.maptext_x)
		voter.body.maptext_width = initial(voter.body.maptext_width)
		voter.body.maptext = null
		var/datum/mafia_role/R = votes[vote_type][voter]
		bodies_to_update += R.body
	votes[vote_type] = list()
	for(var/mob/M in bodies_to_update)
		M.update_appearance()

/**
 * Returns how many people voted for the role, in whatever vote (day vote, night kill vote)
 * Arguments:
 * * role: the mafia role the proc tries to get the amount of votes for
 * * vote_type: the vote type (getting how many day votes were for the role, or mafia night votes for the role)
 */
/datum/mafia_controller/proc/get_vote_count(role,vote_type)
	var/total_votes = 0
	for(var/datum/mafia_role/votee as anything in votes[vote_type])
		if(votes[vote_type][votee] == role)
			total_votes += votee.vote_power
	return total_votes

/**
 * Returns whichever role got the most votes, in whatever vote (day vote, night kill vote)
 * returns null if no votes
 * Arguments:
 * * vote_type: the vote type (getting the role that got the most day votes, or the role that got the most mafia votes)
 */
/datum/mafia_controller/proc/get_vote_winner(vote_type)
	var/list/tally = list()
	for(var/votee in votes[vote_type])
		var/datum/mafia_role/vote_role = votee
		if(!tally[votes[vote_type][votee]])
			tally[votes[vote_type][votee]] = vote_role.vote_power
		else
			tally[votes[vote_type][votee]] += vote_role.vote_power
	sortTim(tally, GLOBAL_PROC_REF(cmp_numeric_dsc), associative=TRUE)
	return length(tally) ? tally[1] : null

/**
 * Returns a random person who voted for whatever vote (day vote, night kill vote)
 * Arguments:
 * * vote_type: vote type (getting a random day voter, or mafia night voter)
 */
/datum/mafia_controller/proc/get_random_voter(vote_type)
	if(length(votes[vote_type]))
		return pick(votes[vote_type])

/**
 * Adds mutable appearances to people who get publicly voted on (so not night votes) showing how many people are picking them
 * Arguments:
 * * source: the body of the role getting the overlays
 * * overlay_list: signal var passing the overlay list of the mob
 */
/datum/mafia_controller/proc/display_votes(atom/source, list/overlay_list)
	SIGNAL_HANDLER

	if(phase != MAFIA_PHASE_VOTING)
		return
	var/v = get_vote_count(get_role_player(source), "Day")
	var/mutable_appearance/MA = mutable_appearance('icons/obj/mafia.dmi',"vote_[v > 12 ? "over_12" : v]")
	overlay_list += MA

/**
 * Called when the game is setting up, AFTER map is loaded but BEFORE the phase timers start. Creates and places each role's body and gives the correct player key
 *
 * Notably:
 * * Toggles godmode so the mafia players cannot kill themselves
 * * Adds signals for voting overlays, see display_votes proc
 * * gives mafia panel
 * * sends the greeting text (goals, role name, etc)
 */
/datum/mafia_controller/proc/create_bodies()
	var/outfit_to_distribute
	if(current_map.custom_outfit) //If our map has a cool custom outfit override, we use that.
		outfit_to_distribute = current_map.custom_outfit
	else
		outfit_to_distribute = player_outfit

	for(var/datum/mafia_role/role as anything in all_roles)
		var/mob/living/carbon/human/human = new(get_turf(role.assigned_landmark))
		human.add_traits(list(
			TRAIT_NOFIRE,
			TRAIT_NOBREATH,
			TRAIT_CANNOT_CRYSTALIZE,
			TRAIT_PERMANENTLY_MORTAL,
			TRAIT_GODMODE,
		), MAFIA_TRAIT)
		human.equipOutfit(outfit_to_distribute)
		RegisterSignal(human, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(display_votes))
		var/obj/item/modular_computer/modpc = role.player_pda
		role.register_body(human)
		if(modpc)
			player_role_lookup[modpc] = role
		else
			player_role_lookup[role.player_key] = role
		var/client/player_client = GLOB.directory[role.player_key]
		if(player_client)
			role.put_player_in_body(player_client)
		role.greet()

///From a 'user' (Either a mob or ModPC) or TGUI UI, will try to find the Mafia role from 'player_role_lookup'.
/datum/mafia_controller/proc/get_role_player(atom/user, datum/tgui/ui)
	var/obj/item/modular_computer/modpc = ui?.src_object || user
	if(istype(modpc))
		return player_role_lookup[modpc]
	var/mob/mob_user = user
	if(!istype(mob_user))
		CRASH("[user] is not a modPC nor a mob, but we are trying to find their role.")
	return player_role_lookup[mob_user.ckey]

/**
 * Signs the player up for Mafia, or removes them from the list if they are already
 * signed up.
 * Args:
 * - ghost_client: is the client of the observer signing up. This can be null in favor of modpc.
 * - modpc: is a living player signing up through a PDA. This can be null in favor of ghost_client.
 */
/datum/mafia_controller/proc/signup_mafia(mob/user, client/ghost_client, obj/item/modular_computer/modpc)
	if(!SSticker.HasRoundStarted())
		to_chat(user, span_warning("Wait for the round to start."))
		return FALSE
	if(isnull(modpc))
		if(GLOB.mafia_signup[ghost_client.ckey])
			GLOB.mafia_signup -= ghost_client.ckey
			GLOB.mafia_early_votes -= ghost_client.ckey //Remove their early start vote as well
			to_chat(user, span_notice("You unregister from Mafia."))
		else
			GLOB.mafia_signup[ghost_client.ckey] = TRUE
			to_chat(user, span_notice("You sign up for Mafia."))
	else
		if(GLOB.pda_mafia_signup[modpc])
			GLOB.pda_mafia_signup -= modpc
			GLOB.mafia_early_votes -= modpc //Remove their early start vote as well
			to_chat(user, span_notice("You unregister from Mafia."))
			return TRUE
		else
			GLOB.pda_mafia_signup[modpc] = TRUE
			to_chat(user, span_notice("You sign up for Mafia."))
	if(phase == MAFIA_PHASE_SETUP)
		check_signups()
		try_autostart()
	return TRUE

/**
 * Returns a standard setup, with certain important/unique roles guaranteed.
 *
 * please check the variables at the top of the proc to see how much of each role types it picks
 * Args:
 * req_players - The amount of players needed.
 */
/datum/mafia_controller/proc/generate_standard_setup(req_players)
	var/list/selected_roles = list()
	var/list/unique_roles_added = list()
	for(var/i in 1 to req_players)
		add_setup_role(selected_roles, unique_roles_added, pick(default_role_list[i]))
	return selected_roles

/**
 * Helper proc that adds a random role of a type to a setup. if it doesn't exist in the setup, it adds the path to the list and otherwise bumps the path in the list up one. unique roles can only get added once.
 */
/datum/mafia_controller/proc/add_setup_role(setup_list, banned_roles, wanted_role_type)
	var/list/role_type_paths = list()
	for(var/datum/mafia_role/instance as anything in GLOB.mafia_role_by_alignment[wanted_role_type])
		if(instance in banned_roles)
			continue
		role_type_paths += instance

	var/datum/mafia_role/mafia_path = pick(role_type_paths)
	if(setup_list[mafia_path])
		setup_list[mafia_path] += 1
	else
		setup_list[mafia_path] = 1

	if(initial(mafia_path.role_flags) & ROLE_UNIQUE) //check to see if we should no longer consider this okay to add to the game
		banned_roles += mafia_path

/**
 * Called when enough players have signed up to fill a setup. DOESN'T NECESSARILY MEAN THE GAME WILL START.
 *
 * Checks for a custom setup, if so gets the required players from that and if not it sets the player requirement to MAFIA_MAX_PLAYER_COUNT and generates one IF basic setup starts a game.
 * Checks if everyone signed up is an observer, and is still connected. If people aren't, they're removed from the list.
 * If there aren't enough players post sanity, it aborts. otherwise, it selects enough people for the game and starts preparing the game for real.
 */
/datum/mafia_controller/proc/basic_setup()
	var/req_players = MAFIA_MAX_PLAYER_COUNT
	var/list/setup = custom_setup
	if(length(setup))
		req_players = counterlist_sum(setup)

	var/list/filtered_keys_and_pdas = filter_players(req_players)

	//don't actually have one yet, so generate a max player random setup.
	//it's good to do this here instead of above so it doesn't generate one every time a game could possibly start.
	if(!length(setup))
		setup = generate_standard_setup(length(filtered_keys_and_pdas))
	prepare_game(setup, filtered_keys_and_pdas)
	start_game()

/**
 * Generates a forced role list and runs the game with the current number of signed-up players.
 *
 * Generates a randomized setup, and begins the game with everyone currently signed up.
 */

/datum/mafia_controller/proc/forced_setup()
	check_signups() //Refresh the signup list, so our numbers are accurate and we only take active players into consideration.
	var/players_needed = GLOB.mafia_signup.len + GLOB.pda_mafia_signup.len
	var/list/filtered_keys_and_pdas = filter_players(players_needed)
	if(!length(filtered_keys_and_pdas)) //If we have nobody signed up, we give up on starting
		log_admin("Attempted to force a mafia game to start with nobody signed up!")
		return

	var/list/setup = generate_standard_setup(length(filtered_keys_and_pdas))

	prepare_game(setup, filtered_keys_and_pdas)
	early_start = TRUE
	start_game()

/**
 * Checks if we have enough early start votes to begin the game early.
 *
 * Checks if we have the bare minimum of three signups, then checks if the number of early voters is at least half of the total
 * number of active signups.
 */

/datum/mafia_controller/proc/check_start_votes()
	check_signups() //Same as before. What a useful proc.

	if(length(GLOB.mafia_signup + GLOB.pda_mafia_signup) < MAFIA_MIN_PLAYER_COUNT)
		return FALSE //Make sure we have the minimum playercount to host a game first.

	if(length(GLOB.mafia_early_votes) < round(length(GLOB.mafia_signup + GLOB.pda_mafia_signup) / 2))
		return FALSE

	return TRUE

/**
 * Handles the filtering of disconected signups when picking who gets to be in the round.
 *
 * Filters out the player list, from a given max_players count. If more players are found
 * in the signup list than max_players, those players will be notified that they will not be put into the game.
 *
 * This should only be run as we are in the process of starting a game.
 *
 * max_players - The maximum number of keys to put in our return list before we start telling people they're not getting in.
 * filtered_keys_and_pdas - A list of player ckeys and PDAs, to be included in the game.
 */
/datum/mafia_controller/proc/filter_players(max_players)
	//final list for all the players who will be in this game
	var/list/filtered_keys_and_pdas = list()
	//cuts invalid players from signups (disconnected/not a ghost)
	var/list/possible_players = list()
	for(var/key in GLOB.mafia_signup)
		if(GLOB.directory[key])
			var/client/C = GLOB.directory[key]
			if(isobserver(C.mob))
				possible_players += key
				continue
		GLOB.mafia_signup -= key //not valid to play when we checked so remove them from signups

	for(var/obj/item/modular_computer/pda/pdas as anything in GLOB.pda_mafia_signup)
		possible_players += pdas

	//if there were too many players, still start but only make filtered keys as big as it needs to be (cut excess)
	//also removes people who do get into final player list from the signup so they have to sign up again when game ends
	for(var/i in 1 to max_players)
		if(!length(possible_players))
			break
		var/chosen_key = pick_n_take(possible_players)
		filtered_keys_and_pdas += chosen_key
		if(chosen_key in GLOB.pda_mafia_signup)
			GLOB.pda_mafia_signup -= chosen_key
		else if(chosen_key in GLOB.mafia_signup)
			GLOB.mafia_signup -= chosen_key
	//small message about not getting into this game for clarity on why they didn't get in
	for(var/unpicked in possible_players)
		if(!(unpicked in GLOB.mafia_signup))
			continue
		var/client/unpicked_client = GLOB.directory[unpicked]
		to_chat(unpicked_client, span_danger("Sorry, the starting mafia game has too many players and you were not picked."))
		to_chat(unpicked_client, span_warning("You're still signed up, getting messages from the current round, and have another chance to join when the one starting now finishes."))

	return filtered_keys_and_pdas

/**
 * Called when someone signs up, and sees if there are enough people in the signup list to begin.
 *
 * Only checks if everyone is actually valid to start (still connected and an observer) if there are enough players (basic_setup)
 */
/datum/mafia_controller/proc/try_autostart()
	if(phase != MAFIA_PHASE_SETUP || !(GLOB.ghost_role_flags & GHOSTROLE_MINIGAME))
		return
	if((GLOB.mafia_signup.len + GLOB.pda_mafia_signup.len) >= MAFIA_MAX_PLAYER_COUNT || custom_setup)//enough people to try and make something (or debug mode)
		basic_setup()

/**
 * Filters inactive player into a different list until they reconnect, and removes players who are no longer ghosts.
 *
 * If a disconnected player gets a non-ghost mob and reconnects, they will be first put back into mafia_signup then filtered by that.
 */
/datum/mafia_controller/proc/check_signups()
#ifndef UNIT_TESTS
	for(var/bad_key in GLOB.mafia_bad_signup)
		if(GLOB.directory[bad_key])//they have reconnected if we can search their key and get a client
			GLOB.mafia_bad_signup -= bad_key
			GLOB.mafia_signup[bad_key] = TRUE
	for(var/key in GLOB.mafia_signup)
		var/client/C = GLOB.directory[key]
		if(!C)//vice versa but in a variable we use later
			GLOB.mafia_signup -= key
			GLOB.mafia_bad_signup[key] = TRUE
			continue
		if(!isobserver(C.mob))
			//they are back to playing the game, remove them from the signups
			GLOB.mafia_signup -= key
#endif

/datum/action/innate/mafia_panel
	name = "Mafia Panel"
	desc = "Use this to play."
	button_icon = 'icons/obj/mafia.dmi'
	button_icon_state = "board"
	///The mafia controller that the button will use the UI of.
	var/datum/mafia_controller/controller_panel

/datum/action/innate/mafia_panel/New(Target, datum/mafia_controller/controller)
	. = ..()
	controller_panel = controller

/datum/action/innate/mafia_panel/Destroy()
	. = ..()
	controller_panel = null

/datum/action/innate/mafia_panel/Activate()
	controller_panel.ui_interact(owner)

/**
 * The popup used for sending important messages to players.
 */
/atom/movable/screen/mafia_popup
	icon = null
	icon_state = null
	plane = ABOVE_HUD_PLANE
	layer = SCREENTIP_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP-5,LEFT"
	maptext_height = 480
	maptext_width = 480
	///The client that owns the popup.
	var/datum/mafia_role/owner

/atom/movable/screen/mafia_popup/Initialize(mapload, datum/mafia_role/mafia)
	. = ..()
	src.owner = mafia

/atom/movable/screen/mafia_popup/Destroy()
	owner = null
	return ..()

/atom/movable/screen/mafia_popup/proc/update_text(text)
	owner.role_messages += text
	if(!owner.body.client)
		return
	maptext = MAPTEXT("<span style='color: [COLOR_RED]; text-align: center; font-size: 24pt'> [text]</span>")
	maptext_width = view_to_pixels(owner.body.client?.view_size.getView())[1]
	owner.body.client?.screen += src
	addtimer(CALLBACK(src, PROC_REF(null_text), owner.body.client), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

///Clears all text to re-use in the future. We use to_clear here in case someone takes over their old body.
/atom/movable/screen/mafia_popup/proc/null_text(client/to_clear)
	maptext = null
	to_clear?.screen -= src

/**
 * Creates the global datum for playing mafia games, destroys the last if that's required and returns the new.
 */
/proc/create_mafia_game()
	if(GLOB.mafia_game)
		QDEL_NULL(GLOB.mafia_game)
	var/datum/mafia_controller/new_controller = new()
	return new_controller

#undef UNIVERSALLY_HATED_REQUIREMENT
