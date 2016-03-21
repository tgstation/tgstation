//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

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
	var/required_enemies = 0
	var/recommended_enemies = 0
	var/antag_flag = null //preferences flag such as BE_WIZARD that need to be turned on for players to be antag
	var/mob/living/living_antag_player = null
	var/list/datum/game_mode/replacementmode = null
	var/round_converted = 0 //0: round not converted, 1: round going to convert, 2: round converted
	var/reroll_friendly 	//During mode conversion only these are in the running
	var/continuous_sanity_checked	//Catches some cases where config options could be used to suggest that modes without antagonists should end when all antagonists die
	var/enemy_minimum_age = 7 //How many days must players have been playing before they can play this antagonist

	var/const/waittime_l = 600
	var/const/waittime_h = 1800 // started at 1800


/datum/game_mode/proc/announce() //to be calles when round starts
	world << "<B>Notice</B>: [src] did not define announce()"


///can_start()
///Checks to see if the game can be setup and ran with the current number of players or whatnot.
/datum/game_mode/proc/can_start()
	var/playerC = 0
	for(var/mob/new_player/player in player_list)
		if((player.client)&&(player.ready))
			playerC++
	if(!Debug2)
		if(playerC < required_players)
			return 0
	antag_candidates = get_players_for_role(antag_flag)
	if(!Debug2)
		if(antag_candidates.len < required_enemies)
			return 0
		return 1
	else
		world << "<span class='notice'>DEBUG: GAME STARTING WITHOUT PLAYER NUMBER CHECKS, THIS WILL PROBABLY BREAK SHIT."
		return 1


///pre_setup()
///Attempts to select players for special roles the mode might have.
/datum/game_mode/proc/pre_setup()
	return 1


///post_setup()
///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/game_mode/proc/post_setup(report=0) //Gamemodes can override the intercept report. Passing a 1 as the argument will force a report.
	if(!report)
		report = config.intercept
	spawn (ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	feedback_set_details("round_start","[time2text(world.realtime)]")
	if(ticker && ticker.mode)
		feedback_set_details("game_mode","[ticker.mode]")
	if(revdata.commit)
		feedback_set_details("revision","[revdata.commit]")
	feedback_set_details("server_ip","[world.internet_address]:[world.port]")
	if(report)
		spawn (rand(waittime_l, waittime_h))
			send_intercept(0)
	start_state = new /datum/station_state()
	start_state.count(1)
	return 1

///make_antag_chance()
///Handles late-join antag assignments
/datum/game_mode/proc/make_antag_chance(mob/living/carbon/human/character)
	if(replacementmode && round_converted == 2)
		replacementmode.make_antag_chance(character)
	return

///convert_roundtype()
///Allows rounds to basically be "rerolled" should the initial premise fall through
/datum/game_mode/proc/convert_roundtype()
	var/list/living_crew = list()

	for(var/mob/Player in mob_list)
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) &&!isbrain(Player))
			living_crew += Player
	if(living_crew.len / joined_player_list.len <= config.midround_antag_life_check) //If a lot of the player base died, we start fresh
		message_admins("Convert_roundtype failed due to too many dead people. Limit is [config.midround_antag_life_check * 100]% living crew")
		return null

	var/list/datum/game_mode/runnable_modes = config.get_runnable_midround_modes(living_crew.len)
	var/list/datum/game_mode/usable_modes = list()
	for(var/datum/game_mode/G in runnable_modes)
		if(G.reroll_friendly)
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

	var/list/antag_canadates = list()

	for(var/mob/living/carbon/human/H in living_crew)
		if(H.client && H.client.prefs.allow_midround_antag)
			antag_canadates += H

	if(!antag_canadates)
		message_admins("Convert_roundtype failed due to no antag canadates.")
		return null

	antag_canadates = shuffle(antag_canadates)

	if(config.protect_roles_from_antagonist)
		replacementmode.restricted_jobs += replacementmode.protected_jobs
	if(config.protect_assistant_from_antagonist)
		replacementmode.restricted_jobs += "Assistant"

	message_admins("The roundtype will be converted. If you have other plans for the station or think the round should end <A HREF='?_src_=holder;toggle_midround_antag=\ref[usr]'>stop the creation of antags</A> or <A HREF='?_src_=holder;end_round=\ref[usr]'>end the round now</A>.")

	spawn(rand(1200,3000)) //somewhere between 2 and 5 minutes from now
		if(!config.midround_antag[ticker.mode.config_tag])
			round_converted = 0
			return 1
		for(var/mob/living/carbon/human/H in antag_canadates)
			replacementmode.make_antag_chance(H)
		round_converted = 2
		message_admins("The roundtype has been converted, antagonists may have been created")
	return 1

///process()
///Called by the gameticker
/datum/game_mode/process()
	return 0


/datum/game_mode/proc/check_finished() //to be called by ticker
	if(replacementmode && round_converted == 2)
		return replacementmode.check_finished()
	if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME || station_was_nuked)
		return 1
	if(!round_converted && (!config.continuous[config_tag] || (config.continuous[config_tag] && config.midround_antag[config_tag]))) //Non-continuous or continous with replacement antags
		if(!continuous_sanity_checked) //make sure we have antags to be checking in the first place
			for(var/mob/Player in mob_list)
				if(Player.mind)
					if(Player.mind.special_role)
						continuous_sanity_checked = 1
						return 0
			if(!continuous_sanity_checked)
				message_admins("The roundtype ([config_tag]) has no antagonists, continuous round has been defaulted to on and midround_antag has been defaulted to off.")
				config.continuous[config_tag] = 1
				config.midround_antag[config_tag] = 0
				SSshuttle.emergencyNoEscape = 0
				return 0


		if(living_antag_player && living_antag_player.mind && isliving(living_antag_player) && living_antag_player.stat != DEAD && !isnewplayer(living_antag_player) &&!isbrain(living_antag_player))
			return 0 //A resource saver: once we find someone who has to die for all antags to be dead, we can just keep checking them, cycling over everyone only when we lose our mark.

		for(var/mob/Player in living_mob_list)
			if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) &&!isbrain(Player))
				if(Player.mind.special_role) //Someone's still antaging!
					living_antag_player = Player
					return 0

		if(!config.continuous[config_tag])
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

	for(var/mob/M in player_list)
		if(M.client)
			clients++
			if(ishuman(M))
				if(!M.stat)
					surviving_humans++
					if(M.z == 2)
						escaped_humans++
			if(!M.stat)
				surviving_total++
				if(M.z == 2)
					escaped_total++


			if(isobserver(M))
				ghosts++

	if(clients > 0)
		feedback_set("round_end_clients",clients)
	if(ghosts > 0)
		feedback_set("round_end_ghosts",ghosts)
	if(surviving_humans > 0)
		feedback_set("survived_human",surviving_humans)
	if(surviving_total > 0)
		feedback_set("survived_total",surviving_total)
	if(escaped_humans > 0)
		feedback_set("escaped_human",escaped_humans)
	if(escaped_total > 0)
		feedback_set("escaped_total",escaped_total)
	send2irc("Server", "Round just ended.")
	return 0


/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
	return 0


/datum/game_mode/proc/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Centcom Update</B> Requested status information:</FONT><HR>"
	intercepttext += "<B> Centcom has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult", "gang")
	possible_modes -= "[ticker.mode]" //remove current gamemode to prevent it from being randomly deleted, it will be readded later

	var/number = pick(1, 2)
	var/i = 0
	for(i = 0, i < number, i++) //remove 1 or 2 possibles modes from the list
		possible_modes.Remove(pick(possible_modes))

	possible_modes[rand(1, possible_modes.len)] = "[ticker.mode]" //replace a random game mode with the current one

	possible_modes = shuffle(possible_modes) //shuffle the list to prevent meta

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		if(modePlayer.len == 0)
			intercepttext += i_text.build(A)
		else
			intercepttext += i_text.build(A, pick(modePlayer))

	print_command_report(intercepttext,"Centcom Status Summary")
	priority_announce("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.", 'sound/AI/intercept.ogg')
	if(security_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)


/datum/game_mode/proc/get_players_for_role(role)
	var/list/players = list()
	var/list/candidates = list()
	var/list/drafted = list()
	var/datum/mind/applicant = null

	// Ultimate randomizing code right here
	for(var/mob/new_player/player in player_list)
		if(player.client && player.ready)
			players += player

	// Shuffling, the players list is now ping-independent!!!
	// Goodbye antag dante
	players = shuffle(players)

	for(var/mob/new_player/player in players)
		if(player.client && player.ready)
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
		for(var/mob/new_player/player in players)
			if(player.client && player.ready)
				if(!(role in player.client.prefs.be_special)) // We don't have enough people who want to be antagonist, make a seperate list of people who don't want to be one
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
/*
	if(candidates.len < recommended_enemies && override_jobbans) //If we still don't have enough people, we're going to start drafting banned people.
		for(var/mob/new_player/player in players)
			if (player.client && player.ready)
				if(jobban_isbanned(player, "Syndicate") || jobban_isbanned(player, roletext)) //Nodrak/Carn: Antag Job-bans
					drafted += player.mind
*/
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

/*
/datum/game_mode/proc/check_player_role_pref(var/role, var/mob/new_player/player)
	if(player.preferences.be_special & role)
		return 1
	return 0
*/

/datum/game_mode/proc/num_players()
	. = 0
	for(var/mob/new_player/P in player_list)
		if(P.client && P.ready)
			. ++

///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/game_mode/proc/get_living_heads()
	. = list()
	for(var/mob/living/carbon/human/player in mob_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in command_positions))
			. |= player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/game_mode/proc/get_all_heads()
	. = list()
	for(var/mob/player in mob_list)
		if(player.mind && (player.mind.assigned_role in command_positions))
			. |= player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/game_mode/proc/get_living_sec()
	. = list()
	for(var/mob/living/carbon/human/player in mob_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in security_positions))
			. |= player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/game_mode/proc/get_all_sec()
	. = list()
	for(var/mob/living/carbon/human/player in mob_list)
		if(player.mind && (player.mind.assigned_role in security_positions))
			. |= player.mind

//////////////////////////
//Reports player logouts//
//////////////////////////
/proc/display_roundstart_logout_report()
	var/msg = "<span class='boldnotice'>Roundstart logout report\n\n</span>"
	for(var/mob/living/L in mob_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in clients)
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
		for(var/mob/dead/observer/D in mob_list)
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



	for(var/mob/M in mob_list)
		if(M.client && M.client.holder)
			M << msg

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
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as a [role_type]?", "[role_type]", null, pref, 100)
	var/mob/dead/observer/theghost = null
	if(candidates.len)
		theghost = pick(candidates)
		M << "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!"
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(M)]) to replace a jobbaned player.")
		M.ghostize(0)
		M.key = theghost.key

/datum/game_mode/proc/remove_antag_for_borging(datum/mind/newborgie)
	ticker.mode.remove_cultist(newborgie, 0)
	ticker.mode.remove_revolutionary(newborgie, 0)
	ticker.mode.remove_gangster(newborgie, 0, remove_bosses=1)
	ticker.mode.remove_hog_follower(newborgie, 0)
