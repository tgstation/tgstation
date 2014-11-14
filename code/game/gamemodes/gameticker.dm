var/global/datum/controller/gameticker/ticker

#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4


/datum/controller/gameticker
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
	var/Bible_deity_name

	var/random_players = 0 	// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/list/syndicate_coalition = list() // list of traitor-compatible factions
	var/list/factions = list()			  // list of all factions
	var/list/availablefactions = list()	  // list of factions with openings

	var/pregame_timeleft = 0

	var/delay_end = 0	//if set to nonzero, the round will not restart on it's own

	var/triai = 0//Global holder for Triumvirate

	// Hack
	var/obj/machinery/media/jukebox/superjuke/thematic/theme = null

/datum/controller/gameticker/proc/pregame()
	login_music = pick(\
	'sound/music/space.ogg',\
	'sound/music/traitor.ogg',\
	'sound/music/space_oddity.ogg',\
	'sound/music/title1.ogg',\
	'sound/music/title2.ogg',\
	'sound/music/clown.ogg',\
	'sound/music/robocop.ogg',\
	'sound/music/gaytony.ogg',\
	'sound/music/rocketman.ogg',\
	'sound/music/2525.ogg',\
	'sound/music/moonbaseoddity.ogg',\
	'sound/music/whatisthissong.ogg')
	do
		pregame_timeleft = 300
		world << "<B><FONT color='blue'>Welcome to the pre-game lobby!</FONT></B>"
		world << "Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds"
		while(current_state == GAME_STATE_PREGAME)
			for(var/i=0, i<10, i++)
				sleep(1)
				vote.process()
				watchdog.check_for_update()
				if(watchdog.waiting)
					world << "<span class='notice'>Server update detected, restarting momentarily.</span>"
					watchdog.signal_ready()
					return
			if(going)
				pregame_timeleft--

			if(pregame_timeleft <= 0)
				current_state = GAME_STATE_SETTING_UP
	while (!setup())

/datum/controller/gameticker/proc/StartThematic(var/playlist)
	if(!theme)
		theme = new(locate(1,1,CENTCOMM_Z))
	theme.playlist_id=playlist
	theme.playing=1
	theme.update_music()
	theme.update_icon()

/datum/controller/gameticker/proc/StopThematic()
	theme.playing=0
	theme.update_music()
	theme.update_icon()


/datum/controller/gameticker/proc/setup()
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
		del(mode)
		current_state = GAME_STATE_PREGAME
		world << "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby."
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

	//setup the money accounts
	if(!centcomm_account_db)
		for(var/obj/machinery/account_database/check_db in machines)
			if(check_db.z == 2)
				centcomm_account_db = check_db
				break

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

	//start_events() //handles random events and space dust.
	//new random event system is handled from the MC.

	if(0 == admins.len)
		send2adminirc("Round has started with no admins online.")

	supply_shuttle.process() 		//Start the supply shuttle regenerating points -- TLE
	master_controller.process()		//Start master_controller.process()
	lighting_controller.process()	//Start processing DynamicAreaLighting updates

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
	if( cinematic )	return	//already a cinematic in progress!

	//initialise our cinematic screen object
	cinematic = new(src)
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_intact"
	cinematic.layer = 20
	cinematic.mouse_opacity = 0
	cinematic.screen_loc = "1,0"

	var/obj/structure/stool/bed/temp_buckle = new(src)
	//Incredibly hackish. It creates a bed within the gameticker (lol) to stop mobs running around
	if(station_missed)
		for(var/mob/living/M in living_mob_list)
			M.buckled = temp_buckle				//buckles the mob so it can't do anything
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/living/M in living_mob_list)
			M.buckled = temp_buckle
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
			for(var/mob/living/M in living_mob_list)
				if(M.loc.z == 1)
					M.death()//No mercy
	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	sleep(300)

	if(cinematic)	del(cinematic)		//end the cinematic
	if(temp_buckle)	del(temp_buckle)	//release everybody
	return


/datum/controller/gameticker/proc/create_characters()
	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind)
			if(player.mind.assigned_role=="AI")
				player.close_spawn_windows()
				player.AIize()
			else if(!player.mind.assigned_role)
				continue
			else
				player.FuckUpGenes(player.create_character())
				del(player)


/datum/controller/gameticker/proc/collect_minds()
	for(var/mob/living/player in player_list)
		if(player.mind)
			ticker.minds += player.mind


/datum/controller/gameticker/proc/equip_characters()
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


/datum/controller/gameticker/proc/process()
	if(current_state != GAME_STATE_PLAYING)
		return 0

	mode.process()

	emergency_shuttle.process()
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
				vote.initiate_vote("map","The Server")

		spawn(50)
			if (mode.station_was_nuked)
				feedback_set_details("end_proper","nuke")
				if(!delay_end && !watchdog.waiting)
					world << "<span class='notice'><B>Rebooting due to destruction of station in [restart_timeout/10] seconds</B></span>"
			else
				feedback_set_details("end_proper","proper completion")
				if(!delay_end && !watchdog.waiting)
					world << "<span class='notice'><B>Restarting in [restart_timeout/10] seconds</B></span>"

			if(blackbox)
				blackbox.save_all_data_to_sql()

			if (watchdog.waiting)
				world << "<span class='notice'><B>Server will shut down for an automatic update in a few seconds.</B></span>"
				watchdog.signal_ready()
			else if(!delay_end)
				sleep(restart_timeout)
				if(!delay_end)
					CallHook("Reboot",list())
					world.Reboot()
				else
					world << "<span class='notice'><B>An admin has delayed the round end</B></span>"
			else
				world << "<span class='notice'><B>An admin has delayed the round end</B></span>"

	return 1

/datum/controller/gameticker/proc/getfactionbyname(var/name)
	for(var/datum/faction/F in factions)
		if(F.name == name)
			return F


/datum/controller/gameticker/proc/declare_completion()

	for(var/mob/living/silicon/ai/ai in mob_list)
		if(ai.stat != 2)
			world << "<b>[ai.name] (Played by: [ai.key])'s laws at the end of the game were:</b>"
		else
			world << "<b>[ai.name] (Played by: [ai.key])'s laws when it was deactivated were:</b>"
		ai.show_laws(1)

		if (ai.connected_robots.len)
			var/robolist = "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in ai.connected_robots)
				if (!robo.connected_ai || !isMoMMI(robo)) // Don't report MoMMIs or unslaved robutts
					continue
				robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.key]), ":" (Played by: [robo.key]), "]"
			world << "[robolist]"

	for (var/mob/living/silicon/robot/robo in mob_list)
		if(!robo)
			continue
		if (!robo.connected_ai)
			if (robo.stat != 2)
				world << "<b>[robo.name] (Played by: [robo.key]) survived as an AI-less [isMoMMI(robo)?"MoMMI":"borg"]! Its laws were:</b>"
			else
				world << "<b>[robo.name] (Played by: [robo.key]) was unable to survive the rigors of being a [isMoMMI(robo)?"MoMMI":"cyborg"] without an AI. Its laws were:</b>"
		else
			world << "<b>[robo.name] (Played by: [robo.key]) [robo.stat!=2?"survived":"perished"] as a [isMoMMI(robo)?"MoMMI":"cyborg"] slaved to [robo.connected_ai]! Its laws were:</b>"
		robo.laws.show_laws(world)

	mode.declare_completion()//To declare normal completion.

	scoreboard()

	return 1
