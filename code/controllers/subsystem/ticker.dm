var/round_start_time = 0

var/datum/subsystem/ticker/ticker

/datum/subsystem/ticker
	name = "Ticker"
	can_fire = 1
	priority = 0

	var/restart_timeout = 250				//delay when restarting server
	var/current_state = GAME_STATE_STARTUP	//state of current round (used by process()) Use the defines GAME_STATE_* !
	var/force_ending = 0					//Round was ended by admin intervention

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music							//music played in pregame lobby
	var/round_end_sound						//music/jingle played when the world reboots

	var/list/datum/mind/minds = list()		//The characters in the game. Used for objective tracking.

		//These bible variables should be a preference
	var/Bible_icon_state					//icon_state the chaplain has chosen for his bible
	var/Bible_item_state					//item_state the chaplain has chosen for his bible
	var/Bible_name							//name of the bible
	var/Bible_deity_name					//name of chaplin's deity

	var/list/syndicate_coalition = list()	//list of traitor-compatible factions
	var/list/factions = list()				//list of all factions
	var/list/availablefactions = list()		//list of factions with openings

	var/delay_end = 0						//if set true, the round will not restart on it's own

	var/triai = 0							//Global holder for Triumvirate
	var/tipped = 0							//Did we broadcast the tip of the day yet?

	var/timeLeft = 1200						//pregame timer

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel

	var/obj/screen/cinematic = null			//used for station explosion cinematic


/datum/subsystem/ticker/New()
	NEW_SS_GLOBAL(ticker)

	login_music = pickweight(list('sound/ambience/title2.ogg' = 31, 'sound/ambience/title1.ogg' = 31, 'sound/ambience/title3.ogg' =31, 'sound/ambience/clown.ogg' = 7)) // choose title music!
	if(SSevent.holidays && SSevent.holidays[APRIL_FOOLS])
		login_music = 'sound/ambience/clown.ogg'

/datum/subsystem/ticker/Initialize(timeofday, zlevel)
	if (zlevel)
		return ..()
	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	setupGenetics()
	setupFactions()
	..()

/datum/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			timeLeft = config.lobby_countdown * 10
			world << "<B><FONT color='blue'>Welcome to the pre-game lobby!</FONT></B>"
			world << "Please, setup your character and select ready. Game will start in [config.lobby_countdown] seconds"
			current_state = GAME_STATE_PREGAME

		if(GAME_STATE_PREGAME)
				//lobby stats for statpanels
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in player_list)
				++totalPlayers
				if(player.ready)
					++totalPlayersReady

			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 300 && !tipped)
				send_random_tip()
				tipped = 1

			if(timeLeft <= 0)
				current_state = GAME_STATE_SETTING_UP

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)

			if(!mode.explosion_in_progress && mode.check_finished() || force_ending)
				current_state = GAME_STATE_FINISHED
				auto_toggle_ooc(1) // Turn it on
				declare_completion()
				spawn(50)
					if(mode.station_was_nuked)
						world.Reboot("Station destroyed by Nuclear Device.", "end_proper", "nuke")
					else
						world.Reboot("Round ended.", "end_proper", "proper completion")

/datum/subsystem/ticker/proc/setup()
		//Create and announce mode
	var/list/datum/game_mode/runnable_modes
	if(master_mode == "random" || master_mode == "secret")
		runnable_modes = config.get_runnable_modes()

		if(master_mode == "secret")
			hide_mode = 1
			if(secret_force_mode != "secret")
				var/datum/game_mode/smode = config.pick_mode(secret_force_mode)
				if(!smode.can_start())
					message_admins("\blue Unable to force secret [secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed.")
				else
					mode = smode

		if(!mode)
			if(!runnable_modes.len)
				world << "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby."
				return 0
			mode = pickweight(runnable_modes)

	else
		mode = config.pick_mode(master_mode)
		if(!mode.can_start())
			world << "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players and [mode.required_enemies] eligible antagonists needed. Reverting to pre-game lobby."
			del(mode)
			SSjob.ResetOccupations()
			return 0

	//Configure mode and assign player to special mode stuff
	var/can_continue = 0
	can_continue = src.mode.pre_setup()		//Choose antagonists
	SSjob.DivideOccupations() 				//Distribute jobs

	if(!Debug2)
		if(!can_continue)
			del(mode)
			world << "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby."
			SSjob.ResetOccupations()
			return 0
	else
		world << "<span class='notice'>DEBUG: Bypassing prestart checks..."

	if(hide_mode)
		var/list/modes = new
		for (var/datum/game_mode/M in runnable_modes)
			modes += M.name
		modes = sortList(modes)
		world << "<B>The current game mode is - Secret!</B>"
		world << "<B>Possibilities:</B> [english_list(modes)]"
	else
		mode.announce()

	current_state = GAME_STATE_PLAYING
	auto_toggle_ooc(0) // Turn it off
	round_start_time = world.time

	start_landmarks_list = shuffle(start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()

	master_controller.roundHasStarted()


	world << "<FONT color='blue'><B>Welcome to [station_name()], enjoy your stay!</B></FONT>"
	world << sound('sound/AI/welcome.ogg')

	if(SSevent.holidays)
		world << "<font color='blue'>and...</font>"
		for(var/holidayname in SSevent.holidays)
			var/datum/holiday/holiday = SSevent.holidays[holidayname]
			world << "<h4>[holiday.greet()]</h4>"


	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.post_setup()
		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if(S.name != "AI")
				qdel(S)

		if(!admins.len)
			send2irc("Server", "Round just started with no admins online!")

	return 1


	//Plus it provides an easy way to make cinematics for other events. Just use this as a template
/datum/subsystem/ticker/proc/station_explosion_cinematic(var/station_missed=0, var/override = null)
	if( cinematic )	return	//already a cinematic in progress!
	auto_toggle_ooc(1) // Turn it on
	//initialise our cinematic screen object
	cinematic = new /obj/screen{icon='icons/effects/station_explosion.dmi';icon_state="station_intact";layer=20;mouse_opacity=0;screen_loc="1,0";}(src)

	var/obj/structure/stool/bed/temp_buckle = new(src)
	if(station_missed)
		for(var/mob/M in mob_list)
			M.buckled = temp_buckle				//buckles the mob so it can't do anything
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/M in mob_list)
			M.buckled = temp_buckle
			if(M.client)
				M.client.screen += cinematic
			if(M.stat != DEAD)
				var/turf/T = get_turf(M)
				if(T && T.z==1)
					M.death(0) //no mercy

	//Now animate the cinematic
	switch(station_missed)
		if(1)	//nuke was nearby but (mostly) missed
			if( mode && !override )
				override = mode.name
			switch( override )
				if("nuclear emergency") //Nuke wasn't on station when it blew up
					flick("intro_nuke",cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')
					flick("station_intact_fade_red",cinematic)
					cinematic.icon_state = "summary_nukefail"
				if("fake") //The round isn't over, we're just freaking people out for fun
					flick("intro_nuke",cinematic)
					sleep(35)
					world << sound('sound/items/bikehorn.ogg')
					flick("summary_selfdes",cinematic)
				else
					flick("intro_nuke",cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')
					//flick("end",cinematic)


		if(2)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
			sleep(50)
			world << sound('sound/effects/explosionfar.ogg')


		else	//station was destroyed
			if( mode && !override )
				override = mode.name
			switch( override )
				if("nuclear emergency") //Nuke Ops successfully bombed the station
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red",cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_nukewin"
				if("AI malfunction") //Malf (screen,explosion,summary)
					flick("intro_malf",cinematic)
					sleep(76)
					flick("station_explode_fade_red",cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_malf"
				if("blob") //Station nuked (nuke,explosion,summary)
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red",cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
				else //Station nuked (nuke,explosion,summary)
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	sleep(300)

	if(cinematic)	qdel(cinematic)		//end the cinematic
	if(temp_buckle)	qdel(temp_buckle)	//release everybody
	return



/datum/subsystem/ticker/proc/create_characters()
	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind)
			joined_player_list += player.ckey
			if(player.mind.assigned_role=="AI")
				player.close_spawn_windows()
				player.AIize()
			else
				player.create_character()
				qdel(player)
		else
			player.new_player_panel()


/datum/subsystem/ticker/proc/collect_minds()
	for(var/mob/living/player in player_list)
		if(player.mind)
			ticker.minds += player.mind


/datum/subsystem/ticker/proc/equip_characters()
	var/captainless=1
	for(var/mob/living/carbon/human/player in player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Captain")
				captainless=0
			if(player.mind.assigned_role != player.mind.special_role)
				SSjob.EquipRank(player, player.mind.assigned_role, 0)
	if(captainless)
		for(var/mob/M in player_list)
			if(!istype(M,/mob/new_player))
				M << "Captainship not forced on anyone."



/datum/subsystem/ticker/proc/declare_completion()
	var/station_evacuated
	if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		station_evacuated = 1
	var/num_survivors = 0
	var/num_escapees = 0

	world << "<BR><BR><BR><FONT size=3><B>The round has ended.</B></FONT>"

	//Player status report
	for(var/mob/Player in mob_list)
		if(Player.mind && !isnewplayer(Player))
			if(Player.stat != DEAD && !isbrain(Player))
				num_survivors++
				if(station_evacuated) //If the shuttle has already left the station
					if(!Player.onCentcom() && !Player.onSyndieBase())
						Player << "<font color='blue'><b>You managed to survive, but were marooned on [station_name()]...</b></FONT>"
					else
						num_escapees++
						Player << "<font color='green'><b>You managed to survive the events on [station_name()] as [Player.real_name].</b></FONT>"
				else
					Player << "<font color='green'><b>You managed to survive the events on [station_name()] as [Player.real_name].</b></FONT>"
			else
				Player << "<font color='red'><b>You did not survive the events on [station_name()]...</b></FONT>"

	//Round statistics report
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(round( 100.0 *  start_state.score(end_state), 0.1), 100.0)

	world << "<BR>[TAB]Shift Duration: <B>[round(world.time / 36000)]:[add_zero("[world.time / 600 % 60]", 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B>"
	world << "<BR>[TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>"
	if(joined_player_list.len)
		world << "<BR>[TAB]Total Population: <B>[joined_player_list.len]</B>"
		if(station_evacuated)
			world << "<BR>[TAB]Evacuation Rate: <B>[num_escapees] ([round((num_escapees/joined_player_list.len)*100, 0.1)]%)</B>"
		else
			world << "<BR>[TAB]Survival Rate: <B>[num_survivors] ([round((num_survivors/joined_player_list.len)*100, 0.1)]%)</B>"
	world << "<BR>"

	//Silicon laws report
	for (var/mob/living/silicon/ai/aiPlayer in mob_list)
		if (aiPlayer.stat != 2 && aiPlayer.mind)
			world << "<b>[aiPlayer.name] (Played by: [aiPlayer.mind.key])'s laws at the end of the round were:</b>"
			aiPlayer.show_laws(1)
		else if (aiPlayer.mind) //if the dead ai has a mind, use its key instead
			world << "<b>[aiPlayer.name] (Played by: [aiPlayer.mind.key])'s laws when it was deactivated were:</b>"
			aiPlayer.show_laws(1)

		world << "<b>Total law changes: [aiPlayer.law_change_counter]</b>"

		if (aiPlayer.connected_robots.len)
			var/robolist = "<b>[aiPlayer.real_name]'s minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				if(robo.mind)
					robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.mind.key]), ":" (Played by: [robo.mind.key]), "]"
			world << "[robolist]"
	for (var/mob/living/silicon/robot/robo in mob_list)
		if (!robo.connected_ai && robo.mind)
			if (robo.stat != 2)
				world << "<b>[robo.name] (Played by: [robo.mind.key]) survived as an AI-less borg! Its laws were:</b>"
			else
				world << "<b>[robo.name] (Played by: [robo.mind.key]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>"

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				robo.laws.show_laws(world)

	mode.declare_completion()//To declare normal completion.

	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if (findtext("[handler]","auto_declare_completion_"))
			call(mode, handler)()

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in minds)
		var/temprole = Mind.special_role
		if(temprole)							//if they are an antagonist of some sort.
			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	return 1

/datum/subsystem/ticker/proc/send_random_tip()
	var/list/randomtips = file2list("config/tips.txt")
	if(randomtips.len)
		world << "<font color='purple'><b>Tip of the round: </b>[html_encode(pick(randomtips))]</font>"

