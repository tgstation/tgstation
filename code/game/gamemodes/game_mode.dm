

/*
 * GAMEMODES (by Rastaf0)
 *
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 *
 */


/datum/game_mode
	var/name = "invalid"
	var/config_tag = null
	var/votable = 1
	var/probability = 0
	var/station_was_nuked = 0 //see nuclearbomb.dm and malfunction.dm
	var/explosion_in_progress = 0 //sit back and relax
	var/round_ends_with_antag_death = 0 //flags the "one verse the station" antags as such
	var/list/datum/mind/modePlayer = new
	var/list/datum/mind/antag_candidates = list()	// List of possible starting antags goes here
	var/list/restricted_jobs = list()	// Jobs it doesn't make sense to be.  I.E chaplain or AI cultist
	var/list/protected_jobs = list()	// Jobs that can't be traitors because
	var/required_players = 0
	var/maximum_players = -1 // -1 is no maximum, positive numbers limit the selection of a mode on overstaffed stations
	var/required_enemies = 0
	var/recommended_enemies = 0
	var/antag_flag = null //preferences flag such as BE_WIZARD that need to be turned on for players to be antag
	var/mob/living/living_antag_player = null
	var/list/datum/game_mode/replacementmode = null
	var/round_converted = 0 //0: round not converted, 1: round going to convert, 2: round converted
	var/reroll_friendly 	//During mode conversion only these are in the running
	var/continuous_sanity_checked	//Catches some cases where config options could be used to suggest that modes without antagonists should end when all antagonists die
	var/enemy_minimum_age = 7 //How many days must players have been playing before they can play this antagonist

	var/announce_span = "warning" //The gamemode's name will be in this span during announcement.
	var/announce_text = "This gamemode forgot to set a descriptive text! Uh oh!" //Used to describe a gamemode when it's announced.

	var/const/waittime_l = 600
	var/const/waittime_h = 1800 // started at 1800

	var/list/datum/station_goal/station_goals = list()

	var/allow_persistence_save = TRUE

/datum/game_mode/proc/announce() //Shows the gamemode's name and a fast description.
	to_chat(world, "<b>The gamemode is: <span class='[announce_span]'>[name]</span>!</b>")
	to_chat(world, "<b>[announce_text]</b>")


///Checks to see if the game can be setup and ran with the current number of players or whatnot.
/datum/game_mode/proc/can_start()
	var/playerC = 0
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if((player.client)&&(player.ready == PLAYER_READY_TO_PLAY))
			playerC++
	if(!GLOB.Debug2)
		if(playerC < required_players || (maximum_players >= 0 && playerC > maximum_players))
			return 0
	antag_candidates = get_players_for_role(antag_flag)
	if(!GLOB.Debug2)
		if(antag_candidates.len < required_enemies)
			return 0
		return 1
	else
		message_admins("<span class='notice'>DEBUG: GAME STARTING WITHOUT PLAYER NUMBER CHECKS, THIS WILL PROBABLY BREAK SHIT.</span>")
		return 1


///Attempts to select players for special roles the mode might have.
/datum/game_mode/proc/pre_setup()
	return 1


///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/game_mode/proc/post_setup(report) //Gamemodes can override the intercept report. Passing TRUE as the argument will force a report.
	if(!report)
		report = config.intercept
	addtimer(CALLBACK(GLOBAL_PROC, .proc/display_roundstart_logout_report), ROUNDSTART_LOGOUT_REPORT_TIME)

	if(SSdbcore.Connect())
		var/sql
		if(SSticker.mode)
			sql += "game_mode = '[SSticker.mode]'"
		if(GLOB.revdata.originmastercommit)
			if(sql)
				sql += ", "
			sql += "commit_hash = '[GLOB.revdata.originmastercommit]'"
		if(sql)
			var/datum/DBQuery/query_round_game_mode = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET [sql] WHERE id = [GLOB.round_id]")
			query_round_game_mode.Execute()
	if(report)
		addtimer(CALLBACK(src, .proc/send_intercept, 0), rand(waittime_l, waittime_h))
	generate_station_goals()
	return 1


///Handles late-join antag assignments
/datum/game_mode/proc/make_antag_chance(mob/living/carbon/human/character)
	if(replacementmode && round_converted == 2)
		replacementmode.make_antag_chance(character)
	return


///Allows rounds to basically be "rerolled" should the initial premise fall through. Also known as mulligan antags.
/datum/game_mode/proc/convert_roundtype()
	set waitfor = FALSE
	var/list/living_crew = list()

	for(var/mob/Player in GLOB.mob_list)
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) && !isbrain(Player) && Player.client)
			living_crew += Player
	if(living_crew.len / GLOB.joined_player_list.len <= config.midround_antag_life_check) //If a lot of the player base died, we start fresh
		message_admins("Convert_roundtype failed due to too many dead people. Limit is [config.midround_antag_life_check * 100]% living crew")
		return null

	var/list/datum/game_mode/runnable_modes = config.get_runnable_midround_modes(living_crew.len)
	var/list/datum/game_mode/usable_modes = list()
	for(var/datum/game_mode/G in runnable_modes)
		if(G.reroll_friendly && living_crew >= G.required_players)
			usable_modes += G
		else
			qdel(G)

	if(!usable_modes)
		message_admins("Convert_roundtype failed due to no valid modes to convert to. Please report this error to the Coders.")
		return null

	replacementmode = pickweight(usable_modes)

	switch(SSshuttle.emergency.mode) //Rounds on the verge of ending don't get new antags, they just run out
		if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE)
			return 1
		if(SHUTTLE_CALL)
			if(SSshuttle.emergency.timeLeft(1) < initial(SSshuttle.emergencyCallTime)*0.5)
				return 1

	if(world.time >= (config.midround_antag_time_check * 600))
		message_admins("Convert_roundtype failed due to round length. Limit is [config.midround_antag_time_check] minutes.")
		return null

	var/list/antag_candidates = list()

	for(var/mob/living/carbon/human/H in living_crew)
		if(H.client && H.client.prefs.allow_midround_antag)
			antag_candidates += H

	if(!antag_candidates)
		message_admins("Convert_roundtype failed due to no antag candidates.")
		return null

	antag_candidates = shuffle(antag_candidates)

	if(config.protect_roles_from_antagonist)
		replacementmode.restricted_jobs += replacementmode.protected_jobs
	if(config.protect_assistant_from_antagonist)
		replacementmode.restricted_jobs += "Assistant"

	message_admins("The roundtype will be converted. If you have other plans for the station or feel the station is too messed up to inhabit <A HREF='?_src_=holder;toggle_midround_antag=\ref[usr]'>stop the creation of antags</A> or <A HREF='?_src_=holder;end_round=\ref[usr]'>end the round now</A>.")

	. = 1
	sleep(rand(600,1800))
	if(!SSticker.IsRoundInProgress())
		message_admins("Roundtype conversion cancelled, the game appears to have finished!")
		round_converted = 0
		return
	 //somewhere between 1 and 3 minutes from now
	if(!config.midround_antag[SSticker.mode.config_tag])
		round_converted = 0
		return 1
	for(var/mob/living/carbon/human/H in antag_candidates)
		replacementmode.make_antag_chance(H)
	round_converted = 2
	message_admins("-- IMPORTANT: The roundtype has been converted to [replacementmode.name], antagonists may have been created! --")


///Called by the gameSSticker
/datum/game_mode/process()
	return 0


/datum/game_mode/proc/check_finished(force_ending) //to be called by SSticker
	if(replacementmode && round_converted == 2)
		return replacementmode.check_finished()
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(station_was_nuked)
		return TRUE
	if(!round_converted && (!config.continuous[config_tag] || (config.continuous[config_tag] && config.midround_antag[config_tag]))) //Non-continuous or continous with replacement antags
		if(!continuous_sanity_checked) //make sure we have antags to be checking in the first place
			for(var/mob/Player in GLOB.mob_list)
				if(Player.mind)
					if(Player.mind.special_role)
						continuous_sanity_checked = 1
						return 0
			if(!continuous_sanity_checked)
				message_admins("The roundtype ([config_tag]) has no antagonists, continuous round has been defaulted to on and midround_antag has been defaulted to off.")
				config.continuous[config_tag] = 1
				config.midround_antag[config_tag] = 0
				SSshuttle.clearHostileEnvironment(src)
				return 0


		if(living_antag_player && living_antag_player.mind && isliving(living_antag_player) && living_antag_player.stat != DEAD && !isnewplayer(living_antag_player) &&!isbrain(living_antag_player))
			return 0 //A resource saver: once we find someone who has to die for all antags to be dead, we can just keep checking them, cycling over everyone only when we lose our mark.

		for(var/mob/Player in GLOB.living_mob_list)
			if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) &&!isbrain(Player) && Player.client)
				if(Player.mind.special_role) //Someone's still antaging!
					living_antag_player = Player
					return 0

		if(!config.continuous[config_tag] || force_ending)
			return 1

		else
			round_converted = convert_roundtype()
			if(!round_converted)
				if(round_ends_with_antag_death)
					return 1
				else
					config.midround_antag[config_tag] = 0
					return 0

	return 0


/datum/game_mode/proc/declare_completion()
	var/clients = 0
	var/surviving_humans = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/escaped_humans = 0
	var/escaped_total = 0

	for(var/mob/M in GLOB.player_list)
		if(M.client)
			clients++
			if(ishuman(M))
				if(!M.stat)
					surviving_humans++
					if(M.z == ZLEVEL_CENTCOM)
						escaped_humans++
			if(!M.stat)
				surviving_total++
				if(M.z == ZLEVEL_CENTCOM)
					escaped_total++


			if(isobserver(M))
				ghosts++

	if(clients > 0)
		SSblackbox.set_val("round_end_clients",clients)
	if(ghosts > 0)
		SSblackbox.set_val("round_end_ghosts",ghosts)
	if(surviving_humans > 0)
		SSblackbox.set_val("survived_human",surviving_humans)
	if(surviving_total > 0)
		SSblackbox.set_val("survived_total",surviving_total)
	if(escaped_humans > 0)
		SSblackbox.set_val("escaped_human",escaped_humans)
	if(escaped_total > 0)
		SSblackbox.set_val("escaped_total",escaped_total)
	send2irc("Server", "Round just ended.")
	if(cult.len && !istype(SSticker.mode, /datum/game_mode/cult))
		datum_cult_completion()

	return 0


/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
	return 0


/datum/game_mode/proc/send_intercept()
	var/intercepttext = "<b><i>Central Command Status Summary</i></b><hr>"
	intercepttext += "<b>Central Command has intercepted and partially decoded a Syndicate transmission with vital information regarding their movements. The following report outlines the most \
	likely threats to appear in your sector.</b>"
	var/list/possible_modes = list()
	possible_modes.Add("blob", "changeling", "clock_cult", "cult", "extended", "malf", "nuclear", "revolution", "traitor", "wizard")
	possible_modes -= name //remove the current gamemode to prevent it from being randomly deleted, it will be readded later

	for(var/i in 1 to 6) //Remove a few modes to leave four
		possible_modes -= pick(possible_modes)

	possible_modes |= name //Re-add the actual gamemode - the intercept will thus always have the correct mode in its list
	possible_modes = shuffle(possible_modes) //Meta prevention

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/V in possible_modes)
		intercepttext += i_text.build(V)

	if(station_goals.len)
		intercepttext += "<hr><b>Special Orders for [station_name()]:</b>"
		for(var/datum/station_goal/G in station_goals)
			G.on_report()
			intercepttext += G.get_report()

	print_command_report(intercepttext, "Central Command Status Summary", announce=FALSE)
	priority_announce("A summary has been copied and printed to all communications consoles.", "Enemy communication intercepted. Security level elevated.", 'sound/ai/intercept.ogg')
	if(GLOB.security_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)


/datum/game_mode/proc/get_players_for_role(role)
	var/list/players = list()
	var/list/candidates = list()
	var/list/drafted = list()
	var/datum/mind/applicant = null

	// Ultimate randomizing code right here
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.client && player.ready == PLAYER_READY_TO_PLAY)
			players += player

	// Shuffling, the players list is now ping-independent!!!
	// Goodbye antag dante
	players = shuffle(players)

	for(var/mob/dead/new_player/player in players)
		if(player.client && player.ready == PLAYER_READY_TO_PLAY)
			if(role in player.client.prefs.be_special)
				if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, role)) //Nodrak/Carn: Antag Job-bans
					if(age_check(player.client)) //Must be older than the minimum age
						candidates += player.mind				// Get a list of all the people who want to be the antagonist for this round

	if(restricted_jobs)
		for(var/datum/mind/player in candidates)
			for(var/job in restricted_jobs)					// Remove people who want to be antagonist but have a job already that precludes it
				if(player.assigned_role == job)
					candidates -= player

	if(candidates.len < recommended_enemies)
		for(var/mob/dead/new_player/player in players)
			if(player.client && player.ready == PLAYER_READY_TO_PLAY)
				if(!(role in player.client.prefs.be_special)) // We don't have enough people who want to be antagonist, make a separate list of people who don't want to be one
					if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, role)) //Nodrak/Carn: Antag Job-bans
						drafted += player.mind

	if(restricted_jobs)
		for(var/datum/mind/player in drafted)				// Remove people who can't be an antagonist
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					drafted -= player

	drafted = shuffle(drafted) // Will hopefully increase randomness, Donkie

	while(candidates.len < recommended_enemies)				// Pick randomlly just the number of people we need and add them to our list of candidates
		if(drafted.len > 0)
			applicant = pick(drafted)
			if(applicant)
				candidates += applicant
				drafted.Remove(applicant)

		else												// Not enough scrubs, ABORT ABORT ABORT
			break

	if(restricted_jobs)
		for(var/datum/mind/player in drafted)				// Remove people who can't be an antagonist
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					drafted -= player

	drafted = shuffle(drafted) // Will hopefully increase randomness, Donkie

	while(candidates.len < recommended_enemies)				// Pick randomlly just the number of people we need and add them to our list of candidates
		if(drafted.len > 0)
			applicant = pick(drafted)
			if(applicant)
				candidates += applicant
				drafted.Remove(applicant)

		else												// Not enough scrubs, ABORT ABORT ABORT
			break

	return candidates		// Returns: The number of people who had the antagonist role set to yes, regardless of recomended_enemies, if that number is greater than recommended_enemies
							//			recommended_enemies if the number of people with that role set to yes is less than recomended_enemies,
							//			Less if there are not enough valid players in the game entirely to make recommended_enemies.



/datum/game_mode/proc/num_players()
	. = 0
	for(var/mob/dead/new_player/P in GLOB.player_list)
		if(P.client && P.ready == PLAYER_READY_TO_PLAY)
			. ++

///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/game_mode/proc/get_living_heads()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.mob_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.command_positions))
			. |= player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/game_mode/proc/get_all_heads()
	. = list()
	for(var/mob/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in GLOB.command_positions))
			. |= player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/game_mode/proc/get_living_sec()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.mob_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.security_positions))
			. |= player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/game_mode/proc/get_all_sec()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in GLOB.security_positions))
			. |= player.mind

//////////////////////////
//Reports player logouts//
//////////////////////////
/proc/display_roundstart_logout_report()
	var/msg = "<span class='boldnotice'>Roundstart logout report\n\n</span>"
	for(var/mob/living/L in GLOB.mob_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in GLOB.clients)
				if(C.ckey == L.ckey)
					found = 1
					break
			if(!found)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client
			if(L.stat)
				if(L.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<span class='boldannounce'>Suicide</span>)\n"
					continue //Disconnected client
				if(L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in GLOB.mob_list)
			if(D.mind && D.mind.current == L)
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='boldannounce'>Suicide</span>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						continue //Adminghost, or cult/wizard ghost
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='boldannounce'>Ghosted</span>)\n"
						continue //Ghosted while alive



	for(var/mob/M in GLOB.mob_list)
		if(M.client && M.client.holder)
			to_chat(M, msg)

/datum/game_mode/proc/printplayer(datum/mind/ply, fleecheck)
	var/text = "<br><b>[ply.key]</b> was <b>[ply.name]</b> the <b>[ply.assigned_role]</b> and"
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += " <span class='boldannounce'>died</span>"
		else
			text += " <span class='greenannounce'>survived</span>"
		if(fleecheck && ply.current.z > ZLEVEL_STATION)
			text += " while <span class='boldannounce'>fleeing the station</span>"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += " <span class='boldannounce'>had their body destroyed</span>"
	return text

/datum/game_mode/proc/printobjectives(datum/mind/ply)
	var/text = ""
	var/count = 1
	for(var/datum/objective/objective in ply.objectives)
		if(objective.check_completion())
			text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span class='greenannounce'>Success!</span>"
		else
			text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span class='boldannounce'>Fail.</span>"
		count++
	return text

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/game_mode/proc/age_check(client/C)
	if(get_remaining_days(C) == 0)
		return 1	//Available in 0 days = available right now = player is old enough to play.
	return 0


/datum/game_mode/proc/get_remaining_days(client/C)
	if(!C)
		return 0
	if(!config.use_age_restriction_for_jobs)
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	if(!isnum(enemy_minimum_age))
		return 0

	return max(0, enemy_minimum_age - C.player_age)

/datum/game_mode/proc/replace_jobbaned_player(mob/living/M, role_type, pref)
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [role_type]?", "[role_type]", null, pref, 50, M)
	var/mob/dead/observer/theghost = null
	if(candidates.len)
		theghost = pick(candidates)
		to_chat(M, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(M)]) to replace a jobbaned player.")
		M.ghostize(0)
		M.key = theghost.key

/datum/game_mode/proc/remove_antag_for_borging(datum/mind/newborgie)
	SSticker.mode.remove_cultist(newborgie, 0, 0)
	SSticker.mode.remove_revolutionary(newborgie, 0)

/datum/game_mode/proc/generate_station_goals()
	var/list/possible = list()
	for(var/T in subtypesof(/datum/station_goal))
		var/datum/station_goal/G = T
		if(config_tag in initial(G.gamemode_blacklist))
			continue
		possible += T
	var/goal_weights = 0
	while(possible.len && goal_weights < STATION_GOAL_BUDGET)
		var/datum/station_goal/picked = pick_n_take(possible)
		goal_weights += initial(picked.weight)
		station_goals += new picked


/datum/game_mode/proc/declare_station_goal_completion()
	for(var/V in station_goals)
		var/datum/station_goal/G = V
		G.print_result()
