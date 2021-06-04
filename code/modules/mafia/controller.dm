

/**
 * The mafia controller handles the mafia minigame in progress.
 * It is first created when the first ghost signs up to play.
 */
/datum/mafia_controller
	///list of observers that should get game updates.
	var/list/spectators = list()
	///all roles in the game, dead or alive. check their game status if you only want living or dead.
	var/list/all_roles = list()
	///exists to speed up role retrieval, it's a dict. `player_role_lookup[player ckey]` will give you the role they play
	var/list/player_role_lookup = list()
	///what part of the game you're playing in. day phases, night phases, judgement phases, etc.
	var/phase = MAFIA_PHASE_SETUP
	///how long the game has gone on for, changes with every sunrise. day one, night one, day two, etc.
	var/turn = 0
	///if enabled, the game has fallen under half pop and is sped up
	var/speed_up = FALSE
	///for debugging and testing a full game, or adminbuse. If this is not empty, it will use this as a setup. clears when game is over
	var/list/custom_setup = list()
	///first day has no voting, and thus is shorter
	var/first_day_phase_period = 20 SECONDS
	///talk with others about the last night
	var/day_phase_period = 1 MINUTES
	///vote someone to get put on trial
	var/voting_phase_period = 30 SECONDS
	///defend yourself! don't get lynched! sometimes skipped if nobody votes.
	var/judgement_phase_period = 30 SECONDS
	///guilty or innocent, we want a bit of time for players to process the outcome of the vote
	var/judgement_lynch_period = 5 SECONDS
	///mafia talk at night and pick someone to kill, some town roles use their actions, etc etc.
	var/night_phase_period = 45 SECONDS
	///like the lynch period, players need to see what the other players in the game's roles were
	var/victory_lap_period = 20 SECONDS

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

	///used for debugging in testing (doesn't put people out of the game, some other shit i forgot, who knows just don't set this in live) honestly kinda deprecated
	var/debug = FALSE

/datum/mafia_controller/New()
	. = ..()
	GLOB.mafia_game = src
	map_deleter = new

/datum/mafia_controller/Destroy(force, ...)
	. = ..()
	GLOB.mafia_game = null
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
 * * Sets up the role list
 * * Puts players in each role randomly
 * Arguments:
 * * setup_list: list of all the datum setups (fancy list of roles) that would work for the game
 * * ready_players: list of filtered, sane players (so not playing or disconnected) for the game to put into roles
 */
/datum/mafia_controller/proc/prepare_game(setup_list,ready_players)

	var/list/possible_maps = subtypesof(/datum/map_template/mafia)
	var/turf/spawn_area = get_turf(locate(/obj/effect/landmark/mafia_game_area) in GLOB.landmarks_list)

	current_map = pick(possible_maps)
	current_map = new current_map

	if(!spawn_area)
		CRASH("No spawn area detected for Mafia!")
	var/list/bounds = current_map.load(spawn_area)
	if(!bounds)
		CRASH("Loading mafia map failed!")
	map_deleter.defineRegion(spawn_area, locate(spawn_area.x + 23,spawn_area.y + 23,spawn_area.z), replace = TRUE) //so we're ready to mass delete when round ends

	if(!landmarks.len)//we grab town center when we grab landmarks, if there is none (the first game signed up for let's grab them post load)
		for(var/obj/effect/landmark/mafia/possible_spawn in GLOB.landmarks_list)
			if(istype(possible_spawn, /obj/effect/landmark/mafia/town_center))
				town_center_landmark = possible_spawn
			else
				landmarks += possible_spawn

	current_setup_text = list()
	for(var/rtype in setup_list)
		for(var/i in 1 to setup_list[rtype])
			all_roles += new rtype(src)
		var/datum/mafia_role/rp = rtype
		current_setup_text += "[initial(rp.name)] x[setup_list[rtype]]"
	var/list/spawnpoints = landmarks.Copy()
	for(var/datum/mafia_role/role in all_roles)
		role.assigned_landmark = pick_n_take(spawnpoints)
		if(!debug)
			role.player_key = pick_n_take(ready_players)
		else
			role.player_key = pop(ready_players)

/datum/mafia_controller/proc/send_message(msg,team)
	for(var/datum/mafia_role/R in all_roles)
		if(team && R.team != team)
			continue
		to_chat(R.body,msg)
	var/team_suffix = team ? "([uppertext(team)] CHAT)" : ""
	for(var/M in GLOB.dead_mob_list)
		var/mob/spectator = M
		if(spectator.ckey in spectators) //was in current game, or spectatin' (won't send to living)
			var/link = FOLLOW_LINK(M, town_center_landmark)
			to_chat(M, "[link] MAFIA: [msg] [team_suffix]")

/**
 * The game by this point is now all set up, and so we can put people in their bodies and start the first phase.
 *
 * Does the following:
 * * Creates bodies for all of the roles with the first proc
 * * Starts the first day manually (so no timer) with the second proc
 */
/datum/mafia_controller/proc/start_game()
	create_bodies()
	start_day()

/**
 * How every day starts.
 *
 * What players do in this phase:
 * * If day one, just a small starting period to see who is in the game and check role, leading to the night phase.
 * * Otherwise, it's a longer period used to discuss events that happened during the night, leading to the voting phase.
 */
/datum/mafia_controller/proc/start_day()
	turn += 1
	phase = MAFIA_PHASE_DAY
	if(!check_victory())
		if(!speed_up)//lets check if the game should be sped up, if not already.
			var/living_players = 0
			for(var/i in all_roles)
				var/datum/mafia_role/player = i
				if(player.game_status == MAFIA_ALIVE)
					living_players += 1
			if(living_players < all_roles.len / 2)
				speed_up = TRUE
				send_message("<span class='bold notice'>With only [living_players] living players left, the game timers have been sped up.</span>")
				day_phase_period /= 2
				voting_phase_period /= 2
				judgement_phase_period /= 2
				judgement_lynch_period /= 2
				night_phase_period /= 2
		if(turn == 1)
			send_message("<span class='notice'><b>The selected map is [current_map.name]!</b></br>[current_map.description]</span>")
			send_message("<b>Day [turn] started! There is no voting on the first day. Say hello to everybody!</b>")
			next_phase_timer = addtimer(CALLBACK(src,.proc/check_trial, FALSE),first_day_phase_period,TIMER_STOPPABLE) //no voting period = no votes = instant night
		else
			send_message("<b>Day [turn] started! Voting will start in 1 minute.</b>")
			next_phase_timer = addtimer(CALLBACK(src,.proc/start_voting_phase),day_phase_period,TIMER_STOPPABLE)

	SStgui.update_uis(src)

/**
 * Players have finished the discussion period, and now must put up someone to the chopping block.
 *
 * What players do in this phase:
 * * Vote on which player to put up for lynching, leading to the judgement phase.
 * * If no votes are case, the judgement phase is skipped, leading to the night phase.
 */
/datum/mafia_controller/proc/start_voting_phase()
	phase = MAFIA_PHASE_VOTING
	next_phase_timer = addtimer(CALLBACK(src, .proc/check_trial, TRUE),voting_phase_period,TIMER_STOPPABLE) //be verbose!
	send_message("<b>Voting started! Vote for who you want to see on trial today.</b>")
	SStgui.update_uis(src)

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
	var/loser_votes = get_vote_count(loser,"Day")
	if(loser)
		if(loser_votes > 12)
			award_role(/datum/award/achievement/mafia/universally_hated, loser)
		send_message("<b>[loser.body.real_name] wins the day vote, Listen to their defense and vote \"INNOCENT\" or \"GUILTY\"!</b>")
		//refresh the lists
		judgement_abstain_votes = list()
		judgement_innocent_votes = list()
		judgement_guilty_votes = list()
		for(var/i in all_roles)
			var/datum/mafia_role/abstainee = i
			if(abstainee.game_status == MAFIA_ALIVE && abstainee != loser)
				judgement_abstain_votes += abstainee
		on_trial = loser
		on_trial.body.forceMove(get_turf(town_center_landmark))
		phase = MAFIA_PHASE_JUDGEMENT
		next_phase_timer = addtimer(CALLBACK(src, .proc/lynch),judgement_phase_period,TIMER_STOPPABLE)
		reset_votes("Day")
	else
		if(verbose)
			send_message("<b>Not enough people have voted to put someone on trial, nobody will be lynched today.</b>")
		if(!check_victory())
			lockdown()
	SStgui.update_uis(src)

/**
 * Players have voted innocent or guilty on the person on trial, and that person is now killed or returned home.
 *
 * What players do in this phase:
 * * r/watchpeopledie
 * * If the accused is killed, their true role is revealed to the rest of the players.
 */
/datum/mafia_controller/proc/lynch()
	for(var/i in judgement_innocent_votes)
		var/datum/mafia_role/role = i
		send_message("<span class='green'>[role.body.real_name] voted innocent.</span>")
	for(var/ii in judgement_abstain_votes)
		var/datum/mafia_role/role = ii
		send_message("<span class='comradio'>[role.body.real_name] abstained.</span>")
	for(var/iii in judgement_guilty_votes)
		var/datum/mafia_role/role = iii
		send_message("<span class='red'>[role.body.real_name] voted guilty.</span>")
	if(judgement_guilty_votes.len > judgement_innocent_votes.len) //strictly need majority guilty to lynch
		send_message("<span class='red'><b>Guilty wins majority, [on_trial.body.real_name] has been lynched.</b></span>")
		on_trial.kill(src,lynch = TRUE)
		addtimer(CALLBACK(src, .proc/send_home, on_trial),judgement_lynch_period)
	else
		send_message("<span class='green'><b>Innocent wins majority, [on_trial.body.real_name] has been spared.</b></span>")
		on_trial.body.forceMove(get_turf(on_trial.assigned_landmark))
	on_trial = null
	//day votes are already cleared, so this will skip the trial and check victory/lockdown/whatever else
	next_phase_timer = addtimer(CALLBACK(src, .proc/check_trial, FALSE),judgement_lynch_period,TIMER_STOPPABLE)// small pause to see the guy dead, no verbosity since we already did this

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
 * * sends the amount of living people to the solo antagonists, and see if they won OR block the victory of the teams
 * * checks if solos won from above, then if town, then if mafia
 * * starts the end of the game if a faction won
 * * returns TRUE if someone won the game, halting other procs from continuing in the case of a victory
 */
/datum/mafia_controller/proc/check_victory()
	//needed for achievements
	var/list/total_town = list()
	var/list/total_mafia = list()

	//voting power of town + solos (since they don't want mafia to overpower)
	var/anti_mafia_power = 0
	//voting power of mafia (greater than anti mafia power + team end not blocked = mafia victory)
	var/alive_mafia = 0
	var/list/solos_to_ask = list() //need to ask after because first round is counting team sizes
	var/list/total_victors = list() //if this list gets filled with anyone, they win. list because side antags can with with people
	var/blocked_victory = FALSE //if a solo antagonist is stopping the town or mafia from finishing the game.
	var/town_can_kill = FALSE //Town has a killing role and it cannot allow mafia to win

	///PHASE ONE: TALLY UP ALL NUMBERS OF PEOPLE STILL ALIVE

	for(var/datum/mafia_role/R in all_roles)
		switch(R.team)
			if(MAFIA_TEAM_MAFIA)
				total_mafia += R
				if(R.game_status == MAFIA_ALIVE)
					alive_mafia += R.vote_potential
			if(MAFIA_TEAM_TOWN)
				total_town += R
				if(R.game_status == MAFIA_ALIVE)
					anti_mafia_power += R.vote_potential
				if(R.role_flags & ROLE_CAN_KILL) //the game cannot autoresolve with killing roles (unless a solo wins anyways, like traitors who are immune)
					town_can_kill = TRUE
			if(MAFIA_TEAM_SOLO)
				if(R.game_status == MAFIA_ALIVE)
					anti_mafia_power += R.vote_potential
					solos_to_ask += R

	///PHASE TWO: SEND STATS TO SOLO ANTAGS, SEE IF THEY WON OR TEAMS CANNOT WIN

	for(var/datum/mafia_role/solo in solos_to_ask)
		if(solo.check_total_victory(anti_mafia_power, alive_mafia))
			total_victors += solo
		if(solo.block_team_victory(anti_mafia_power, alive_mafia))
			blocked_victory = TRUE

	//solo victories!
	var/solo_end = FALSE
	for(var/datum/mafia_role/winner in total_victors)
		send_message("<span class='big comradio'>!! [uppertext(winner.name)] VICTORY !!</span>")
		award_role(winner.winner_award, winner)
		solo_end = TRUE
	if(solo_end)
		start_the_end()
		return TRUE
	if(blocked_victory)
		return FALSE
	if(alive_mafia == 0)
		for(var/datum/mafia_role/townie in total_town)
			award_role(townie.winner_award, townie)
		start_the_end("<span class='big green'>!! TOWN VICTORY !!</span>")
		return TRUE
	else if(alive_mafia >= anti_mafia_power && !town_can_kill)
		start_the_end("<span class='big red'>!! MAFIA VICTORY !!</span>")
		for(var/datum/mafia_role/changeling in total_mafia)
			award_role(changeling.winner_award, changeling)
		return TRUE

/**
 * Lets the game award roles with all their checks and sanity, prevents achievements given out for debug games
 *
 * Arguments:
 * * award: path of the award
 * * role: mafia_role datum to reward.
 */
/datum/mafia_controller/proc/award_role(award, datum/mafia_role/rewarded)
	if(custom_setup.len)
		return
	var/client/role_client = GLOB.directory[rewarded.player_key]
	role_client?.give_award(award, rewarded.body)

/**
 * The end of the game is in two procs, because we want a bit of time for players to see eachothers roles.
 * Because of how check_victory works, the game is halted in other places by this point.
 *
 * What players do in this phase:
 * * See everyone's role postgame
 * * See who won the game
 * Arguments:
 * * message: string, if non-null it sends it to all players. used to announce team victories while solos are handled in check victory
 */
/datum/mafia_controller/proc/start_the_end(message)
	SEND_SIGNAL(src,COMSIG_MAFIA_GAME_END)
	if(message)
		send_message(message)
	for(var/datum/mafia_role/R in all_roles)
		R.reveal_role(src)
	phase = MAFIA_PHASE_VICTORY_LAP
	next_phase_timer = addtimer(CALLBACK(src,.proc/end_game),victory_lap_period,TIMER_STOPPABLE)

/**
 * Cleans up the game, resetting variables back to the beginning and removing the map with the generator.
 */
/datum/mafia_controller/proc/end_game()
	map_deleter.generate() //remove the map, it will be loaded at the start of the next one
	QDEL_LIST(all_roles)
	current_setup_text = null
	custom_setup = list()
	turn = 0
	votes = list()

	day_phase_period = initial(day_phase_period)
	voting_phase_period = initial(voting_phase_period)
	judgement_phase_period = initial(judgement_phase_period)
	judgement_lynch_period = initial(judgement_lynch_period)
	night_phase_period = initial(night_phase_period)

	//map gen does not deal with landmarks
	QDEL_LIST(landmarks)
	QDEL_NULL(town_center_landmark)
	phase = MAFIA_PHASE_SETUP

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
	for(var/obj/machinery/door/poddoor/D in GLOB.machines) //I really dislike pathing of these
		if(D.id != "mafia") //so as to not trigger shutters on station, lol
			continue
		if(close)
			INVOKE_ASYNC(D, /obj/machinery/door/poddoor.proc/close)
		else
			INVOKE_ASYNC(D, /obj/machinery/door/poddoor.proc/open)

/**
 * The actual start of night for players. Mostly info is given at the start of the night as the end of the night is when votes and actions are submitted and tried.
 *
 * What players do in this phase:
 * * Mafia are told to begin voting on who to kill
 * * Powers that are picked during the day announce themselves right now
 */
/datum/mafia_controller/proc/start_night()
	phase = MAFIA_PHASE_NIGHT
	send_message("<b>Night [turn] started! Lockdown will end in 45 seconds.</b>")
	SEND_SIGNAL(src,COMSIG_MAFIA_SUNDOWN)
	next_phase_timer = addtimer(CALLBACK(src, .proc/resolve_night),night_phase_period,TIMER_STOPPABLE)
	SStgui.update_uis(src)

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
	SEND_SIGNAL(src,COMSIG_MAFIA_NIGHT_START)
	SEND_SIGNAL(src,COMSIG_MAFIA_NIGHT_ACTION_PHASE)
	//resolve mafia kill, todo unsnowflake this
	var/datum/mafia_role/victim = get_vote_winner("Mafia")
	if(victim)
		var/datum/mafia_role/killer = get_random_voter("Mafia")
		if(!victim.can_action(src, killer, "changeling murder"))
			send_message("<span class='danger'>[killer.body.real_name] was unable to attack [victim.body.real_name] tonight!</span>",MAFIA_TEAM_MAFIA)
		else
			send_message("<span class='danger'>[killer.body.real_name] has attacked [victim.body.real_name]!</span>",MAFIA_TEAM_MAFIA)
			if(victim.kill(src,killer,lynch=FALSE))
				to_chat(victim.body, "<span class='userdanger'>You have been killed by a Changeling!</span>")
	reset_votes("Mafia")
	SEND_SIGNAL(src,COMSIG_MAFIA_NIGHT_KILL_PHASE)
	SEND_SIGNAL(src,COMSIG_MAFIA_NIGHT_END)
	toggle_night_curtains(close=FALSE)
	start_day()
	SStgui.update_uis(src)

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
/datum/mafia_controller/proc/vote_for(datum/mafia_role/voter,datum/mafia_role/target,vote_type, teams)
	if(!votes[vote_type])
		votes[vote_type] = list()
	var/old_vote = votes[vote_type][voter]
	if(old_vote && old_vote == target)
		votes[vote_type] -= voter
	else
		votes[vote_type][voter] = target
	if(old_vote && old_vote == target)
		send_message("<span class='notice'>[voter.body.real_name] retracts their vote for [target.body.real_name]!</span>", team = teams)
	else
		send_message("<span class='notice'>[voter.body.real_name] voted for [target.body.real_name]!</span>",team = teams)
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
	for(var/vote in votes[vote_type])
		var/datum/mafia_role/R = votes[vote_type][vote]
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
	. = 0
	for(var/v in votes[vote_type])
		var/datum/mafia_role/votee = v
		if(votes[vote_type][votee] == role)
			. += votee.vote_power

/**
 * Returns whichever role got the most votes, in whatever vote (day vote, night kill vote)
 * returns null if no votes
 * Arguments:
 * * vote_type: the vote type (getting the role that got the most day votes, or the role that got the most mafia votes)
 */
/datum/mafia_controller/proc/get_vote_winner(vote_type)
	var/list/tally = list()
	for(var/votee in votes[vote_type])
		if(!tally[votes[vote_type][votee]])
			tally[votes[vote_type][votee]] = 1
		else
			tally[votes[vote_type][votee]] += 1
	sortTim(tally,/proc/cmp_numeric_dsc,associative=TRUE)
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
	var/v = get_vote_count(player_role_lookup[source],"Day")
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
	for(var/datum/mafia_role/role in all_roles)
		var/mob/living/carbon/human/H = new(get_turf(role.assigned_landmark))
		ADD_TRAIT(H, TRAIT_NOFIRE, MAFIA_TRAIT)
		ADD_TRAIT(H, TRAIT_NOBREATH, MAFIA_TRAIT)
		H.equipOutfit(player_outfit)
		H.status_flags |= GODMODE
		RegisterSignal(H,COMSIG_ATOM_UPDATE_OVERLAYS,.proc/display_votes)
		var/datum/action/innate/mafia_panel/mafia_panel = new(null,src)
		mafia_panel.Grant(H)
		var/client/player_client = GLOB.directory[role.player_key]
		if(player_client)
			player_client.prefs.copy_to(H)
		role.body = H
		player_role_lookup[H] = role
		H.key = role.player_key
		role.greet()

/datum/mafia_controller/ui_data(mob/user)
	. = ..()
	switch(phase)
		if(MAFIA_PHASE_DAY,MAFIA_PHASE_VOTING,MAFIA_PHASE_JUDGEMENT)
			.["phase"] = "Day [turn]"
		if(MAFIA_PHASE_NIGHT)
			.["phase"] = "Night [turn]"
		else
			.["phase"] = "No Game"
	if(user.client?.holder)
		.["admin_controls"] = TRUE //show admin buttons to start/setup/stop
	if(phase == MAFIA_PHASE_JUDGEMENT)
		.["judgement_phase"] = TRUE //show judgement section
	else
		.["judgement_phase"] = FALSE
	var/datum/mafia_role/user_role = player_role_lookup[user]
	if(user_role)
		.["roleinfo"] = list("role" = user_role.name,"desc" = user_role.desc, "action_log" = user_role.role_notes, "hud_icon" = user_role.hud_icon, "revealed_icon" = user_role.revealed_icon)
		var/actions = list()
		for(var/action in user_role.actions)
			if(user_role.validate_action_target(src,action,null))
				actions += action
		.["actions"] = actions
		.["role_theme"] = user_role.special_theme
	else
		var/list/lobby_data = list()
		for(var/key in GLOB.mafia_signup + GLOB.mafia_bad_signup)
			var/list/lobby_member = list()
			lobby_member["name"] = key
			lobby_member["status"] = "Ready"
			if(key in GLOB.mafia_bad_signup)
				lobby_member["status"] = "Disconnected"
			lobby_member["spectating"] = "Ghost"
			if(key in spectators)
				lobby_member["spectating"] = "Spectator"
			lobby_data += list(lobby_member)
		.["lobbydata"] = lobby_data
	var/list/player_data = list()
	for(var/datum/mafia_role/R in all_roles)
		var/list/player_info = list()
		var/list/actions = list()
		if(user_role) //not observer
			for(var/action in user_role.targeted_actions)
				if(user_role.validate_action_target(src,action,R))
					actions += action
			//Awful snowflake, could use generalizing
			if(phase == MAFIA_PHASE_VOTING)
				player_info["votes"] = get_vote_count(R,"Day")
				if(R.game_status == MAFIA_ALIVE && R != user_role)
					actions += "Vote"
			if(phase == MAFIA_PHASE_NIGHT && user_role.team == MAFIA_TEAM_MAFIA && R.game_status == MAFIA_ALIVE && R.team != MAFIA_TEAM_MAFIA)
				actions += "Kill Vote"
		player_info["name"] = R.body.real_name
		player_info["ref"] = REF(R)
		player_info["actions"] = actions
		player_info["alive"] = R.game_status == MAFIA_ALIVE
		player_data += list(player_info)
	.["players"] = player_data
	.["timeleft"] = next_phase_timer ? timeleft(next_phase_timer) : 0

	//Not sure on this, should this info be visible
	.["all_roles"] = current_setup_text

/datum/mafia_controller/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/mafia),
	)

/datum/mafia_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/datum/mafia_role/user_role = player_role_lookup[usr]
	//Admin actions
	if(usr.client?.holder)
		switch(action)
			if("new_game")
				end_game()
				basic_setup()
			if("nuke")
				end_game()
				qdel(src)
			if("next_phase")
				var/datum/timedevent/timer = SStimer.timer_id_dict[next_phase_timer]
				if(!timer.spent)
					var/datum/callback/tc = timer.callBack
					deltimer(next_phase_timer)
					tc.InvokeAsync()
				return TRUE
			if("players_home")
				var/list/failed = list()
				for(var/datum/mafia_role/player in all_roles)
					if(!player.body)
						failed += player
						continue
					player.body.forceMove(get_turf(player.assigned_landmark))
				if(failed.len)
					to_chat(usr, "List of players who no longer had a body (if you see this, the game is runtiming anyway so just hit \"New Game\" to end it)")
					for(var/i in failed)
						var/datum/mafia_role/fail = i
						to_chat(usr, fail.player_key)
			if("debug_setup")
				var/list/debug_setup = list()
				var/list/rolelist_dict = list()
				var/done = FALSE
				for(var/p in typesof(/datum/mafia_role))
					var/datum/mafia_role/path = p
					rolelist_dict[initial(path.name) + " ([uppertext(initial(path.team))])"] = path
				rolelist_dict = list("CANCEL", "FINISH") + rolelist_dict
				while(!done)
					to_chat(usr, "You have a total player count of [assoc_value_sum(debug_setup)] in this setup.")
					var/chosen_role_name = input(usr,"Select a role!","Custom Setup Creation",rolelist_dict[1]) as null|anything in rolelist_dict
					if(chosen_role_name == "CANCEL")
						return
					if(chosen_role_name == "FINISH")
						break
					var/found_path = rolelist_dict[chosen_role_name]
					var/role_count = input(usr,"How many? Zero to cancel.","Custom Setup Creation",0) as null|num
					if(role_count > 0)
						debug_setup[found_path] = role_count
				custom_setup = debug_setup
				try_autostart()//don't worry, this fails if there's a game in progress
			if("cancel_setup")
				custom_setup = list()
	switch(action) //both living and dead
		if("mf_lookup")
			var/role_lookup = params["atype"]
			var/datum/mafia_role/helper
			for(var/datum/mafia_role/role in all_roles)
				if(role_lookup == role.name)
					helper = role
					break
			helper.show_help(usr)
	if(!user_role)//just the dead
		var/client/C = ui.user.client
		switch(action)
			if("mf_signup")
				if(!SSticker.HasRoundStarted())
					to_chat(usr, "<span class='warning'>Wait for the round to start.</span>")
					return
				if(GLOB.mafia_signup[C.ckey])
					GLOB.mafia_signup -= C.ckey
					to_chat(usr, "<span class='notice'>You unregister from Mafia.</span>")
					return TRUE
				else
					GLOB.mafia_signup[C.ckey] = C
					to_chat(usr, "<span class='notice'>You sign up for Mafia.</span>")
				if(phase == MAFIA_PHASE_SETUP)
					check_signups()
					try_autostart()
				return TRUE
			if("mf_spectate")
				if(C.ckey in spectators)
					to_chat(usr, "<span class='notice'>You will no longer get messages from the game.</span>")
					spectators -= C.ckey
				else
					to_chat(usr, "<span class='notice'>You will now get messages from the game.</span>")
					spectators += C.ckey
				return TRUE
	if(user_role && user_role.game_status == MAFIA_DEAD)
		return
	//User actions (just living)
	switch(action)
		if("mf_action")
			if(!user_role.actions.Find(params["atype"]))
				return
			user_role.handle_action(src,params["atype"],null)
			return TRUE //vals for self-ui update
		if("mf_targ_action")
			var/datum/mafia_role/target = locate(params["target"]) in all_roles
			if(!istype(target))
				return
			switch(params["atype"])
				if("Vote")
					if(phase != MAFIA_PHASE_VOTING)
						return
					vote_for(user_role,target,vote_type="Day")
				if("Kill Vote")
					if(phase != MAFIA_PHASE_NIGHT || user_role.team != MAFIA_TEAM_MAFIA)
						return
					vote_for(user_role,target,"Mafia", MAFIA_TEAM_MAFIA)
					to_chat(user_role.body,"You will vote for [target.body.real_name] for tonights killing.")
				else
					if(!user_role.targeted_actions.Find(params["atype"]))
						return
					if(!user_role.validate_action_target(src,params["atype"],target))
						return
					user_role.handle_action(src,params["atype"],target)
			return TRUE
	if(user_role != on_trial)
		switch(action)
			if("vote_abstain")
				if(phase != MAFIA_PHASE_JUDGEMENT || (user_role in judgement_abstain_votes))
					return
				to_chat(user_role.body,"You have decided to abstain.")
				judgement_innocent_votes -= user_role
				judgement_guilty_votes -= user_role
				judgement_abstain_votes += user_role
			if("vote_innocent")
				if(phase != MAFIA_PHASE_JUDGEMENT || (user_role in judgement_innocent_votes))
					return
				to_chat(user_role.body,"Your vote on [on_trial.body.real_name] submitted as INNOCENT!")
				judgement_abstain_votes -= user_role//no fakers, and...
				judgement_guilty_votes -= user_role//no radical centrism
				judgement_innocent_votes += user_role
			if("vote_guilty")
				if(phase != MAFIA_PHASE_JUDGEMENT || (user_role in judgement_guilty_votes))
					return
				to_chat(user_role.body,"Your vote on [on_trial.body.real_name] submitted as GUILTY!")
				judgement_abstain_votes -= user_role//no fakers, and...
				judgement_innocent_votes -= user_role//no radical centrism
				judgement_guilty_votes += user_role

/datum/mafia_controller/ui_state(mob/user)
	return GLOB.always_state

/datum/mafia_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, null)
	if(!ui)
		ui = new(user, src, "MafiaPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

/proc/assoc_value_sum(list/L)
	. = 0
	for(var/key in L)
		. += L[key]

/**
 * Returns a semirandom setup with 12 roles. balance not guaranteed!
 *
 * please check the variables at the top of the proc to see how much of each role types it picks
 */
/datum/mafia_controller/proc/generate_random_setup()
	var/invests_left = 2
	var/protects_left = 2
	var/killings_left = 1
	var/supports_left = 2

	var/mafiareg_left = 2
	var/mafiaspe_left = 1

	// if there is one killing role, there will be less disruptors
	var/neutral_killing_role = prob(50)

	var/list/random_setup = list()
	var/list/unique_roles_added = list()
	for(var/i in 1 to MAFIA_MAX_PLAYER_COUNT) //should match the number of roles to add
		if(invests_left)
			add_setup_role(random_setup, unique_roles_added, TOWN_INVEST)
			invests_left--
		else if(protects_left)
			add_setup_role(random_setup, unique_roles_added, TOWN_PROTECT)
			protects_left--
		else if(killings_left)
			add_setup_role(random_setup, unique_roles_added, TOWN_KILLING)
			killings_left--
		else if(supports_left)
			add_setup_role(random_setup, unique_roles_added, TOWN_SUPPORT)
			supports_left--
		else if(mafiareg_left)
			add_setup_role(random_setup, unique_roles_added, MAFIA_REGULAR)
			mafiareg_left--
		else if(mafiaspe_left)
			add_setup_role(random_setup, unique_roles_added, MAFIA_SPECIAL)
			mafiaspe_left--
		else if(neutral_killing_role)
			add_setup_role(random_setup, unique_roles_added, NEUTRAL_KILL)
			neutral_killing_role--
		else
			add_setup_role(random_setup, unique_roles_added, NEUTRAL_DISRUPT)
	debug = random_setup
	return random_setup

/**
 * Helper proc that adds a random role of a type to a setup. if it doesn't exist in the setup, it adds the path to the list and otherwise bumps the path in the list up one. unique roles can only get added once.
 */
/datum/mafia_controller/proc/add_setup_role(setup_list, banned_roles, wanted_role_type)
	var/list/role_type_paths = list()
	for(var/path in typesof(/datum/mafia_role))
		var/datum/mafia_role/instance = path
		if(initial(instance.role_type) == wanted_role_type && !(path in banned_roles))
			role_type_paths += instance

	var/mafia_path = pick(role_type_paths)
	var/datum/mafia_role/mafia_path_type = mafia_path
	var/found_role
	for(var/searched_path in setup_list)
		var/datum/mafia_role/searched_path_type = searched_path
		if(initial(mafia_path_type.name) == initial(searched_path_type.name))
			found_role = searched_path
			break
	if(found_role)
		setup_list[found_role] += 1
		return
	setup_list[mafia_path] = 1
	if(initial(mafia_path_type.role_flags) & ROLE_UNIQUE) //check to see if we should no longer consider this okay to add to the game
		banned_roles += mafia_path

/**
 * Called when enough players have signed up to fill a setup. DOESN'T NECESSARILY MEAN THE GAME WILL START.
 *
 * Checks for a custom setup, if so gets the required players from that and if not it sets the player requirement to MAFIA_MAX_PLAYER_COUNT and generates one IF basic setup starts a game.
 * Checks if everyone signed up is an observer, and is still connected. If people aren't, they're removed from the list.
 * If there aren't enough players post sanity, it aborts. otherwise, it selects enough people for the game and starts preparing the game for real.
 */
/datum/mafia_controller/proc/basic_setup()
	var/req_players
	var/list/setup = custom_setup
	if(!setup.len)
		req_players = MAFIA_MAX_PLAYER_COUNT
	else
		req_players = assoc_value_sum(setup)

	//final list for all the players who will be in this game
	var/list/filtered_keys = list()
	//cuts invalid players from signups (disconnected/not a ghost)
	var/list/possible_keys = list()
	for(var/key in GLOB.mafia_signup)
		if(GLOB.directory[key])
			var/client/C = GLOB.directory[key]
			if(isobserver(C.mob))
				possible_keys += key
				continue
		GLOB.mafia_signup -= key //not valid to play when we checked so remove them from signups

	//if there were not enough players, don't start. we already trimmed the list to now hold only valid signups
	if(length(possible_keys) < req_players)
		return

	//if there were too many players, still start but only make filtered keys as big as it needs to be (cut excess)
	//also removes people who do get into final player list from the signup so they have to sign up again when game ends
	for(var/i in 1 to req_players)
		var/chosen_key = pick_n_take(possible_keys)
		filtered_keys += chosen_key
		GLOB.mafia_signup -= chosen_key
	//small message about not getting into this game for clarity on why they didn't get in
	for(var/unpicked in possible_keys)
		var/client/unpicked_client = GLOB.directory[unpicked]
		to_chat(unpicked_client, "<span class='danger'>Sorry, the starting mafia game has too many players and you were not picked.</span>")
		to_chat(unpicked_client, "<span class='warning'>You're still signed up, getting messages from the current round, and have another chance to join when the one starting now finishes.</span>")

	if(!setup.len) //don't actually have one yet, so generate a max player random setup. it's good to do this here instead of above so it doesn't generate one every time a game could possibly start.
		setup = generate_random_setup()
	prepare_game(setup,filtered_keys)
	start_game()

/**
 * Called when someone signs up, and sees if there are enough people in the signup list to begin.
 *
 * Only checks if everyone is actually valid to start (still connected and an observer) if there are enough players (basic_setup)
 */
/datum/mafia_controller/proc/try_autostart()
	if(phase != MAFIA_PHASE_SETUP || !(GLOB.ghost_role_flags & GHOSTROLE_MINIGAME))
		return
	if(GLOB.mafia_signup.len >= MAFIA_MAX_PLAYER_COUNT || custom_setup.len)//enough people to try and make something (or debug mode)
		basic_setup()

/**
 * Filters inactive player into a different list until they reconnect, and removes players who are no longer ghosts.
 *
 * If a disconnected player gets a non-ghost mob and reconnects, they will be first put back into mafia_signup then filtered by that.
 */
/datum/mafia_controller/proc/check_signups()
	for(var/bad_key in GLOB.mafia_bad_signup)
		if(GLOB.directory[bad_key])//they have reconnected if we can search their key and get a client
			GLOB.mafia_bad_signup -= bad_key
			GLOB.mafia_signup += bad_key
	for(var/key in GLOB.mafia_signup)
		var/client/C = GLOB.directory[key]
		if(!C)//vice versa but in a variable we use later
			GLOB.mafia_signup -= key
			GLOB.mafia_bad_signup += key
		if(!isobserver(C.mob))
			//they are back to playing the game, remove them from the signups
			GLOB.mafia_signup -= key

/datum/action/innate/mafia_panel
	name = "Mafia Panel"
	desc = "Use this to play."
	icon_icon = 'icons/obj/mafia.dmi'
	button_icon_state = "board"
	var/datum/mafia_controller/parent

/datum/action/innate/mafia_panel/New(Target,mf)
	. = ..()
	parent = mf

/datum/action/innate/mafia_panel/Activate()
	parent.ui_interact(owner)

/**
 * Creates the global datum for playing mafia games, destroys the last if that's required and returns the new.
 */
/proc/create_mafia_game()
	if(GLOB.mafia_game)
		QDEL_NULL(GLOB.mafia_game)
	var/datum/mafia_controller/MF = new()
	return MF
