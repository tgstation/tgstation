var/global/datum/controller/gameticker/ticker

#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4


/datum/controller/gameticker
	var/remaining_time = 0
	var/const/restart_timeout = 600
	var/current_state = GAME_STATE_PREGAME

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music			// music played in pregame lobby

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	var/Bible_icon_state	// icon_state the chaplain has chosen for his bible
	var/Bible_item_state	// item_state the chaplain has chosen for his bible
	var/Bible_name			// name of the bible
	var/Bible_deity_name = "Space Jesus"

	var/random_players = 0 	// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/list/syndicate_coalition = list() // list of traitor-compatible factions
	var/list/factions = list()			  // list of all factions
	var/list/availablefactions = list()	  // list of factions with openings

	var/pregame_timeleft = 0

	var/delay_end = 0	//if set to nonzero, the round will not restart on it's own

	var/triai = 0//Global holder for Triumvirate

	// Hack
	var/obj/machinery/media/jukebox/superjuke/thematic/theme = null

#define LOBBY_TICKING 1
#define LOBBY_TICKING_RESTARTED 2
/datum/controller/gameticker/proc/pregame()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/pregame() called tick#: [world.time]")
	var/oursong = file(pick(
		"sound/music/space.ogg",
		"sound/music/traitor.ogg",
		"sound/music/space_oddity.ogg",
		"sound/music/title1.ogg",
		"sound/music/title2.ogg",
		"sound/music/clown.ogg",
		"sound/music/robocop.ogg",
		"sound/music/gaytony.ogg",
		"sound/music/rocketman.ogg",
		"sound/music/2525.ogg",
		"sound/music/moonbaseoddity.ogg",
		"sound/music/whatisthissong.ogg",
		"sound/music/space_asshole.ogg",
		))
	login_music = fcopy_rsc(oursong)
	// Wait for MC to get its shit together
	while(!master_controller.initialized)
		sleep(1) // Don't thrash the poor CPU
		continue
	do
		var/delay_timetotal = 3000 //actually 5 minutes or incase this is changed from 3000, (time_in_seconds * 10)
		pregame_timeleft = world.timeofday + delay_timetotal
		world << "<B><FONT color='blue'>Welcome to the pre-game lobby!</FONT></B>"
		world << "Please, setup your character and select ready. Game will start in [(pregame_timeleft - world.timeofday) / 10] seconds"
		while(current_state <= GAME_STATE_PREGAME)
			for(var/i=0, i<10, i++)
				sleep(1)
				vote.process()
				watchdog.check_for_update()
				//if(watchdog.waiting)
					//world << "<span class='notice'>Server update detected, restarting momentarily.</span>"
					//watchdog.signal_ready()
					//return
			if (world.timeofday < (863800 -  delay_timetotal) &&  pregame_timeleft > 863950) // having a remaining time > the max of time of day is bad....
				pregame_timeleft -= 864000
			if(!going && !remaining_time)
				remaining_time = pregame_timeleft - world.timeofday
			if(going == LOBBY_TICKING_RESTARTED)
				pregame_timeleft = world.timeofday + remaining_time
				going = LOBBY_TICKING
				remaining_time = 0

			if(going && world.timeofday >= pregame_timeleft)
				current_state = GAME_STATE_SETTING_UP
	while (!setup())
#undef LOBBY_TICKING
#undef LOBBY_TICKING_RESTARTED
/datum/controller/gameticker/proc/StartThematic(var/playlist)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/StartThematic() called tick#: [world.time]")
	if(!theme)
		theme = new(locate(1,1,CENTCOMM_Z))
	theme.playlist_id=playlist
	theme.playing=1
	theme.update_music()
	theme.update_icon()

/datum/controller/gameticker/proc/StopThematic()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/StopThematic() called tick#: [world.time]")
	theme.playing=0
	theme.update_music()
	theme.update_icon()


/datum/controller/gameticker/proc/setup()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/setup() called tick#: [world.time]")
	//Create and announce mode
	if(master_mode=="secret")
		src.hide_mode = 1
	var/list/datum/game_mode/runnable_modes
	if((master_mode=="random") || (master_mode=="secret"))
		runnable_modes = config.get_runnable_modes()
		if (runnable_modes.len==0)
			current_state = GAME_STATE_PREGAME
			world << "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby."
			return 0
		if(secret_force_mode != "secret")
			var/datum/game_mode/M = config.pick_mode(secret_force_mode)
			if(M.can_start())
				src.mode = config.pick_mode(secret_force_mode)
		job_master.ResetOccupations()
		if(!src.mode)
			src.mode = pickweight(runnable_modes)
		if(src.mode)
			var/mtype = src.mode.type
			src.mode = new mtype
	else
		src.mode = config.pick_mode(master_mode)
	if (!src.mode.can_start())
		world << "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players needed. Reverting to pre-game lobby."
		del(mode)
		current_state = GAME_STATE_PREGAME
		job_master.ResetOccupations()
		return 0

	//Configure mode and assign player to special mode stuff
	job_master.DivideOccupations() //Distribute jobs
	var/can_continue = src.mode.pre_setup()//Setup special modes
	if(!can_continue)
		current_state = GAME_STATE_PREGAME
		world << "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby."
		log_admin("The gamemode setup for [mode.name] errored out.")
		world.log << "The gamemode setup for [mode.name] errored out."
		del(mode)
		job_master.ResetOccupations()
		return 0

	if(hide_mode)
		var/list/modes = new
		for (var/datum/game_mode/M in runnable_modes)
			modes+=M.name
		modes = sortList(modes)
		world << "<B>The current game mode is - Secret!</B>"
		world << "<B>Possibilities:</B> [english_list(modes)]"
	else
		src.mode.announce()

	init_PDAgames_leaderboard()
	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()
	current_state = GAME_STATE_PLAYING

	//here to initialize the random events nicely at round start
	setup_economy()

	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.post_setup()
		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if (S.name != "AI")
				qdel(S)
		var/list/obj/effect/landmark/spacepod/random/L = list()
		for(var/obj/effect/landmark/spacepod/random/SS in landmarks_list)
			if(istype(SS))
				L += SS
		var/obj/effect/landmark/spacepod/random/S = pick(L)
		new /obj/spacepod/random(S.loc)
		for(var/obj in L)
			if(istype(obj, /obj/effect/landmark/spacepod/random))
				qdel(obj)
		world << "<FONT color='blue'><B>Enjoy the game!</B></FONT>"
		//world << sound('sound/AI/welcome.ogg') // Skie //Out with the old, in with the new. - N3X15
		var/welcome_sentence=list('sound/AI/vox_login.ogg')
		welcome_sentence += pick(
			'sound/AI/vox_reminder1.ogg',
			'sound/AI/vox_reminder2.ogg',
			'sound/AI/vox_reminder3.ogg',
			'sound/AI/vox_reminder4.ogg',
			'sound/AI/vox_reminder5.ogg',
			'sound/AI/vox_reminder6.ogg',
			'sound/AI/vox_reminder7.ogg',
			'sound/AI/vox_reminder8.ogg',
			'sound/AI/vox_reminder9.ogg')
		for(var/sound in welcome_sentence)
			play_vox_sound(sound,STATION_Z,null)
		//Holiday Round-start stuff	~Carn
		Holiday_Game_Start()
		mode.Clean_Antags()

	//start_events() //handles random events and space dust.
	//new random event system is handled from the MC.

	if(0 == admins.len)
		send2adminirc("Round has started with no admins online.")

	/*
	supply_shuttle.process() 		//Start the supply shuttle regenerating points -- TLE
	master_controller.process()		//Start master_controller.process()
	lighting_controller.process()	//Start processing DynamicAreaLighting updates
	*/
	processScheduler.start()

	if(config.sql_enabled)
		spawn(3000)
		statistic_cycle() // Polls population totals regularly and stores them in an SQL DB -- TLE

	return 1

/datum/controller/gameticker
	//station_explosion used to be a variable for every mob's hud. Which was a waste!
	//Now we have a general cinematic centrally held within the gameticker....far more efficient!
	var/obj/screen/cinematic = null

	//Plus it provides an easy way to make cinematics for other events. Just use this as a template :)
/datum/controller/gameticker/proc/station_explosion_cinematic(var/station_missed=0, var/override = null)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/station_explosion_cinematic() called tick#: [world.time]")
	if( cinematic )	return	//already a cinematic in progress!

	for (var/datum/html_interface/hi in html_interfaces)
		hi.closeAll()

	//initialise our cinematic screen object
	cinematic = new(src)
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_intact"
	cinematic.layer = 20
	cinematic.mouse_opacity = 0
	cinematic.screen_loc = "1,0"

	var/obj/structure/bed/temp_buckle = new(src)
	//Incredibly hackish. It creates a bed within the gameticker (lol) to stop mobs running around
	if(station_missed)
		for(var/mob/living/M in living_mob_list)
			M.locked_to = temp_buckle				//buckles the mob so it can't do anything
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/living/M in living_mob_list)
			M.locked_to = temp_buckle
			if(M.client)
				M.client.screen += cinematic

			switch(M.z)
				if(0)	//inside a crate or something
					var/turf/T = get_turf(M)
					if(T && T.z==1)				//we don't use M.death(0) because it calls a for(/mob) loop and
						M.health = 0
						M.stat = DEAD
				if(1)	//on a z-level 1 turf.
					M.health = 0
					M.stat = DEAD

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
				else //Station nuked (nuke,explosion,summary)
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
			for(var/mob/living/M in living_mob_list)
				if(M)
					var/turf/T = get_turf(M)
					if(T && T.z == 1)
						M.death()//No mercy
	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	sleep(300)

	if(cinematic)
		qdel(cinematic)		//end the cinematic
	if(temp_buckle)
		qdel(temp_buckle)	//release everybody
	return


/datum/controller/gameticker/proc/create_characters()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/create_characters() called tick#: [world.time]")
	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind)
			if(player.mind.assigned_role=="AI")
				player.close_spawn_windows()
				player.AIize()
			else if(!player.mind.assigned_role)
				continue
			else
				player.FuckUpGenes(player.create_character())
				qdel(player)


/datum/controller/gameticker/proc/collect_minds()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/collect_minds() called tick#: [world.time]")
	for(var/mob/living/player in player_list)
		if(player.mind)
			ticker.minds += player.mind

/datum/controller/gameticker/proc/equip_characters()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/equip_characters() called tick#: [world.time]")
	var/captainless=1
	for(var/mob/living/carbon/human/player in player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Captain")
				captainless=0
			if(player.mind.assigned_role != "MODE")
				job_master.EquipRank(player, player.mind.assigned_role, 0)
				EquipCustomItems(player)
	if(captainless)
		for(var/mob/M in player_list)
			if(!istype(M,/mob/new_player))
				M << "Captainship not forced on anyone."

	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player))
			M.store_position()//updates the players' origin_ vars so they retain their location when the round starts.

/datum/controller/gameticker/proc/process()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/process() called tick#: [world.time]")
	if(current_state != GAME_STATE_PLAYING)
		return 0

	mode.process()

	if(world.time > nanocoins_lastchange)
		nanocoins_lastchange = world.time + rand(3000,15000)
		nanocoins_rates = (rand(1,30))/10

	/*emergency_shuttle.process()*/
	watchdog.check_for_update()

	var/force_round_end=0

	// If server's empty, force round end.
	if(watchdog.waiting && player_list.len == 0)
		force_round_end=1

	var/mode_finished = mode.check_finished() || (emergency_shuttle.location == 2 && emergency_shuttle.alert == 1) || force_round_end
	if(!mode.explosion_in_progress && mode_finished)
		current_state = GAME_STATE_FINISHED

		spawn
			declare_completion()
			if(config.map_voting)
				vote.initiate_vote("map","The Server", popup = 1)
				var/options = list2text(vote.choices, " ")
				feedback_set("map vote choices", options)


		spawn(50)
			if (mode.station_was_nuked)
				feedback_set_details("end_proper","nuke")
				if(!delay_end && !watchdog.waiting)
					world << "<span class='notice'><B>Rebooting due to destruction of station in [restart_timeout/10] seconds</B></span>"
			else
				feedback_set_details("end_proper","\proper completion")
				if(!delay_end && !watchdog.waiting)
					world << "<span class='notice'><B>Restarting in [restart_timeout/10] seconds</B></span>"

			if(blackbox)
				if(config.map_voting)
					spawn(restart_timeout + 1)
						blackbox.save_all_data_to_sql()
				else
					blackbox.save_all_data_to_sql()

			if (watchdog.waiting)
				world << "<span class='notice'><B>Server will shut down for an automatic update [config.map_voting ? "[(restart_timeout/10)] seconds." : "in a few seconds."]</B></span>"
				if(config.map_voting)
					sleep(restart_timeout) //waiting for a mapvote to end
				if(!delay_end)
					watchdog.signal_ready()
				else
					world << "<span class='notice'><B>An admin has delayed the round end</B></span>"
					delay_end = 2
			else if(!delay_end)
				sleep(restart_timeout)
				if(!delay_end)
					CallHook("Reboot",list())
					world.Reboot()
				else
					world << "<span class='notice'><B>An admin has delayed the round end</B></span>"
					delay_end = 2
			else
				world << "<span class='notice'><B>An admin has delayed the round end</B></span>"
				delay_end = 2

	return 1

/datum/controller/gameticker/proc/getfactionbyname(var/name)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/getfactionbyname() called tick#: [world.time]")
	for(var/datum/faction/F in factions)
		if(F.name == name)
			return F


/datum/controller/gameticker/proc/init_PDAgames_leaderboard()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/init_PDAgames_leaderboard() called tick#: [world.time]")
	init_snake_leaderboard()
	init_minesweeper_leaderboard()

/datum/controller/gameticker/proc/init_snake_leaderboard()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/init_snake_leaderboard() called tick#: [world.time]")
	for(var/x=1;x<=PDA_APP_SNAKEII_MAXSPEED;x++)
		snake_station_highscores += x
		snake_station_highscores[x] = list()
		snake_best_players += x
		snake_best_players[x] = list()
		var/list/templist1 = snake_station_highscores[x]
		var/list/templist2 = snake_best_players[x]
		for(var/y=1;y<=PDA_APP_SNAKEII_MAXLABYRINTH;y++)
			templist1 += y
			templist1[y] = 0
			templist2 += y
			templist2[y] = "none"

/datum/controller/gameticker/proc/init_minesweeper_leaderboard()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/init_minesweeper_leaderboard() called tick#: [world.time]")
	minesweeper_station_highscores["beginner"] = 999
	minesweeper_station_highscores["intermediate"] = 999
	minesweeper_station_highscores["expert"] = 999
	minesweeper_best_players["beginner"] = "none"
	minesweeper_best_players["intermediate"] = "none"
	minesweeper_best_players["expert"] = "none"

/datum/controller/gameticker/proc/declare_completion()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/declare_completion() called tick#: [world.time]")
	var/ai_completions = "<h1>Round End Information</h1><HR>"

	ai_completions += "<h3>Silicons Laws</h3>"
	for(var/mob/living/silicon/ai/ai in mob_list)
		var/icon/flat = getFlatIcon(ai)
		end_icons += flat
		var/tempstate = end_icons.len
		if(ai.stat != 2)
			ai_completions += {"<br><b><img src="logo_[tempstate].png"> [ai.name] (Played by: [ai.key])'s laws at the end of the game were:</b>"}
		else
			ai_completions += {"<br><b><img src="logo_[tempstate].png"> [ai.name] (Played by: [ai.key])'s laws when it was deactivated were:</b>"}
		ai_completions += "<br>[ai.write_laws()]"

		if (ai.connected_robots.len)
			var/robolist = "<br><b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in ai.connected_robots)
				if (!robo.connected_ai || !isMoMMI(robo)) // Don't report MoMMIs or unslaved robutts
					continue
				robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.key]), ":" (Played by: [robo.key]), "]"
			ai_completions += "[robolist]"

	for (var/mob/living/silicon/robot/robo in mob_list)
		if(!robo)
			continue
		var/icon/flat = getFlatIcon(robo)
		end_icons += flat
		var/tempstate = end_icons.len
		if (!robo.connected_ai)
			if (robo.stat != 2)
				ai_completions += {"<br><b><img src="logo_[tempstate].png"> [robo.name] (Played by: [robo.key]) survived as an AI-less [isMoMMI(robo)?"MoMMI":"borg"]! Its laws were:</b>"}
			else
				ai_completions += {"<br><b><img src="logo_[tempstate].png"> [robo.name] (Played by: [robo.key]) was unable to survive the rigors of being a [isMoMMI(robo)?"MoMMI":"cyborg"] without an AI. Its laws were:</b>"}
		else
			ai_completions += {"<br><b><img src="logo_[tempstate].png"> [robo.name] (Played by: [robo.key]) [robo.stat!=2?"survived":"perished"] as a [isMoMMI(robo)?"MoMMI":"cyborg"] slaved to [robo.connected_ai]! Its laws were:</b>"}
		ai_completions += "<br>[robo.write_laws()]"

	mode.declare_completion()//To declare normal completion.

	ai_completions += "<HR><BR><h2>Mode Result</h2>"
	//ai_completions += "<br>[mode.completion_text]"

	scoreboard(ai_completions)

	return 1

/datum/controller/gameticker/proc/ert_declare_completion()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/ert_declare_completion() called tick#: [world.time]")
	var/text = ""
	if( ticker.mode.ert.len )
		var/icon/logo = icon('icons/mob/mob.dmi', "ert-logo")
		end_icons += logo
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <FONT size = 2><B>The emergency responders were:</B></FONT> <img src="logo_[tempstate].png">"}
		for(var/datum/mind/ert in ticker.mode.ert)
			if(ert.current)
				var/icon/flat = getFlatIcon(ert.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[ert.key]</b> was <b>[ert.name]</b> ("}
				if(ert.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else
					text += "survived"
				if(ert.current.real_name != ert.name)
					text += " as [ert.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> [ert.key] was [ert.name] ("}
				text += "body destroyed"
			text += ")"
		text += "<BR><HR>"

	return text

/datum/controller/gameticker/proc/deathsquad_declare_completion()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/deathsquad_declare_completion() called tick#: [world.time]")
	var/text = ""
	if( ticker.mode.deathsquad.len )
		var/icon/logo = icon('icons/mob/mob.dmi', "death-logo")
		end_icons += logo
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <FONT size = 2><B>The death commando were:</B></FONT> <img src="logo_[tempstate].png">"}
		for(var/datum/mind/deathsquad in ticker.mode.deathsquad)
			if(deathsquad.current)
				var/icon/flat = getFlatIcon(deathsquad.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[deathsquad.key]</b> was <b>[deathsquad.name]</b> ("}
				if(deathsquad.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else
					text += "survived"
				if(deathsquad.current.real_name != deathsquad.name)
					text += " as [deathsquad.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> [deathsquad.key] was [deathsquad.name] ("}
				text += "body destroyed"
			text += ")"
		text += "<BR><HR>"

	return text

/datum/controller/gameticker/proc/bomberman_declare_completion()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/bomberman_declare_completion() called tick#: [world.time]")
	var/icon/bomberhead = icon('icons/obj/clothing/hats.dmi', "bomberman")
	end_icons += bomberhead
	var/tempstatebomberhead = end_icons.len
	var/icon/bronze = icon('icons/obj/bomberman.dmi', "bronze")
	end_icons += bronze
	var/tempstatebronze = end_icons.len
	var/icon/silver = icon('icons/obj/bomberman.dmi', "silver")
	end_icons += silver
	var/tempstatesilver = end_icons.len
	var/icon/gold = icon('icons/obj/bomberman.dmi', "gold")
	end_icons += gold
	var/tempstategold = end_icons.len
	var/icon/platinum = icon('icons/obj/bomberman.dmi', "platinum")
	end_icons += platinum
	var/tempstateplatinum = end_icons.len

	var/list/bronze_tier = list()
	for (var/mob/living/carbon/M in player_list)
		if(locate(/obj/item/weapon/bomberman/) in M)
			bronze_tier += M
	var/list/silver_tier = list()
	for (var/mob/M in bronze_tier)
		if(M.z == map.zCentcomm)
			silver_tier += M
			bronze_tier -= M
	var/list/gold_tier = list()
	for (var/mob/M in silver_tier)
		var/turf/T = get_turf(M)
		if(istype(T.loc, /area/shuttle/escape/centcom))
			gold_tier += M
			silver_tier -= M
	var/list/platinum_tier = list()
	for (var/mob/living/carbon/human/M in gold_tier)
		if(istype(M.wear_suit, /obj/item/clothing/suit/space/bomberman) && istype(M.head, /obj/item/clothing/head/helmet/space/bomberman))
			var/obj/item/clothing/suit/space/bomberman/C1 = M.wear_suit
			var/obj/item/clothing/head/helmet/space/bomberman/C2 = M.head
			if(C1.never_removed && C2.never_removed)
				platinum_tier += M
				gold_tier -= M

	var/list/special_tier = list()
	for (var/mob/living/silicon/robot/mommi/M in player_list)
		if(istype(M.head_state, /obj/item/clothing/head/helmet/space/bomberman) && istype(M.tool_state, /obj/item/weapon/bomberman/))
			special_tier += M

	var/text = {"<img src="logo_[tempstatebomberhead].png"> <font size=5><b>Bomberman Mode Results</b></font> <img src="logo_[tempstatebomberhead].png">"}
	if(!platinum_tier.len && !gold_tier.len && !silver_tier.len && !bronze_tier.len)
		text += "<br><span class='danger'>DRAW!</span>"
	if(platinum_tier.len)
		text += {"<br><img src="logo_[tempstateplatinum].png"> <b>Platinum Trophy</b> (never removed his clothes, kept his bomb dispenser until the end, and escaped on the shuttle):"}
		for (var/mob/M in platinum_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			end_icons += flat
			var/tempstate = end_icons.len
			text += {"<br><img src="logo_[tempstate].png"> <b>[M.key]</b> as <b>[M.real_name]</b>"}
	if(gold_tier.len)
		text += {"<br><img src="logo_[tempstategold].png"> <b>Gold Trophy</b> (kept his bomb dispenser until the end, and escaped on the shuttle):"}
		for (var/mob/M in gold_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			end_icons += flat
			var/tempstate = end_icons.len
			text += {"<br><img src="logo_[tempstate].png"> <b>[M.key]</b> as <b>[M.real_name]</b>"}
	if(silver_tier.len)
		text += {"<br><img src="logo_[tempstatesilver].png"> <b>Silver Trophy</b> (kept his bomb dispenser until the end, and escaped in a pod):"}
		for (var/mob/M in silver_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			end_icons += flat
			var/tempstate = end_icons.len
			text += {"<br><img src="logo_[tempstate].png"> <b>[M.key]</b> as <b>[M.real_name]</b>"}
	if(bronze_tier.len)
		text += {"<br><img src="logo_[tempstatebronze].png"> <b>Bronze Trophy</b> (kept his bomb dispenser until the end):"}
		for (var/mob/M in bronze_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			end_icons += flat
			var/tempstate = end_icons.len
			text += {"<br><img src="logo_[tempstate].png"> <b>[M.key]</b> as <b>[M.real_name]</b>"}
	if(special_tier.len)
		text += "<br><b>Special Mention</b> to those adorable MoMMis:"
		for (var/mob/M in special_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			end_icons += flat
			var/tempstate = end_icons.len
			text += {"<br><img src="logo_[tempstate].png"> <b>[M.key]</b> as <b>[M.name]</b>"}

	return text

/datum/controller/gameticker/proc/achievement_declare_completion()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/controller/gameticker/proc/achievement_declare_completion() called tick#: [world.time]")
	var/text = "<br><FONT size = 5><b>Additionally, the following players earned achievements:</b></FONT>"
	var/icon/cup = icon('icons/obj/drinks.dmi', "golden_cup")
	end_icons += cup
	var/tempstate = end_icons.len
	for(var/winner in achievements)
		text += {"<br><img src="logo_[tempstate].png"> [winner]"}

	return text
