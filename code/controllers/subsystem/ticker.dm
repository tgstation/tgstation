var/round_start_time = 0

var/datum/subsystem/ticker/ticker

/datum/subsystem/ticker
	name = "Ticker"
	init_order = 0

	priority = 200
	flags = SS_FIRE_IN_LOBBY|SS_KEEP_TIMING

	var/current_state = GAME_STATE_STARTUP	//state of current round (used by process()) Use the defines GAME_STATE_* !
	var/force_ending = 0					//Round was ended by admin intervention
	// If true, there is no lobby phase, the game starts immediately.
	var/start_immediately = FALSE

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music							//music played in pregame lobby
	var/round_end_sound						//music/jingle played when the world reboots

	var/list/datum/mind/minds = list()		//The characters in the game. Used for objective tracking.

	var/list/syndicate_coalition = list()	//list of traitor-compatible factions
	var/list/factions = list()				//list of all factions
	var/list/availablefactions = list()		//list of factions with openings
	var/list/scripture_states = list(SCRIPTURE_DRIVER = TRUE, \
	SCRIPTURE_SCRIPT = FALSE, \
	SCRIPTURE_APPLICATION = FALSE, \
	SCRIPTURE_REVENANT = FALSE, \
	SCRIPTURE_JUDGEMENT = FALSE) //list of clockcult scripture states for announcements

	var/delay_end = 0						//if set true, the round will not restart on it's own

	var/triai = 0							//Global holder for Triumvirate
	var/tipped = 0							//Did we broadcast the tip of the day yet?
	var/selected_tip						// What will be the tip of the day?

	var/timeLeft = 1200						//pregame timer

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel

	var/queue_delay = 0
	var/list/queued_players = list()		//used for join queues when the server exceeds the hard population cap

	var/obj/screen/cinematic = null			//used for station explosion cinematic

	var/maprotatechecked = 0

	var/news_report

/datum/subsystem/ticker/New()
	NEW_SS_GLOBAL(ticker)

	login_music = pickweight(list('sound/ambience/title2.ogg' = 15, 'sound/ambience/title1.ogg' =15, 'sound/ambience/title3.ogg' =14, 'sound/ambience/title4.ogg' =14, 'sound/misc/i_did_not_grief_them.ogg' =14, 'sound/ambience/clown.ogg' = 9)) // choose title music!
	if(SSevent.holidays && SSevent.holidays[APRIL_FOOLS])
		login_music = 'sound/ambience/clown.ogg'

/datum/subsystem/ticker/Initialize(timeofday)
	if(!syndicate_code_phrase)
		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response	= generate_code_phrase()
	..()

/datum/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			timeLeft = config.lobby_countdown * 10
			world << "<span class='boldnotice'>Welcome to [station_name()]!</span>"
			world << "Please set up your character and select \"Ready\". The game will start in [config.lobby_countdown] seconds."
			current_state = GAME_STATE_PREGAME
			for(var/client/C in clients)
				window_flash(C) //let them know lobby has opened up.

		if(GAME_STATE_PREGAME)
				//lobby stats for statpanels
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in player_list)
				++totalPlayers
				if(player.ready)
					++totalPlayersReady

			if(start_immediately)
				timeLeft = 0

			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 300 && !tipped)
				send_tip_of_the_round()
				tipped = TRUE

			if(timeLeft <= 0)
				current_state = GAME_STATE_SETTING_UP

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)
			check_queue()
			check_maprotate()
			scripture_states = scripture_unlock_alert(scripture_states)

			if(!mode.explosion_in_progress && mode.check_finished() || force_ending)
				current_state = GAME_STATE_FINISHED
				toggle_ooc(1) // Turn it on
				declare_completion(force_ending)

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
			qdel(mode)
			mode = null
			SSjob.ResetOccupations()
			return 0

	//Configure mode and assign player to special mode stuff
	var/can_continue = 0
	can_continue = src.mode.pre_setup()		//Choose antagonists
	SSjob.DivideOccupations() 				//Distribute jobs

	if(!Debug2)
		if(!can_continue)
			qdel(mode)
			mode = null
			world << "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby."
			SSjob.ResetOccupations()
			return 0
	else
		message_admins("<span class='notice'>DEBUG: Bypassing prestart checks...</span>")

	if(hide_mode)
		var/list/modes = new
		for (var/datum/game_mode/M in runnable_modes)
			modes += M.name
		modes = sortList(modes)
		world << "<b>The gamemode is: secret!\n\
		Possibilities:</B> [english_list(modes)]"
	else
		mode.announce()

	current_state = GAME_STATE_PLAYING
	if(!config.ooc_during_round)
		toggle_ooc(0) // Turn it off
	round_start_time = world.time

	start_landmarks_list = shuffle(start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()

	Master.RoundStart()

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

		var/list/adm = get_admin_counts()
		if(!adm["present"])
			send2irc("Server", "Round just started with no active admins online!")

	return 1

//Plus it provides an easy way to make cinematics for other events. Just use this as a template
/datum/subsystem/ticker/proc/station_explosion_cinematic(station_missed=0, override = null)
	if( cinematic )
		return	//already a cinematic in progress!

	for (var/datum/html_interface/hi in html_interfaces)
		hi.closeAll()
	//initialise our cinematic screen object
	cinematic = new /obj/screen{icon='icons/effects/station_explosion.dmi';icon_state="station_intact";layer=21;mouse_opacity=0;screen_loc="1,0";}(src)

	if(station_missed)
		for(var/mob/M in mob_list)
			M.notransform = TRUE //stop everything moving
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/M in mob_list)
			if(M.client)
				M.client.screen += cinematic
			if(M.stat != DEAD)
				var/turf/T = get_turf(M)
				if(T && T.z==1)
					M.death(0) //no mercy
				else
					M.notransform=TRUE //no moving for you

	//Now animate the cinematic
	switch(station_missed)
		if(NUKE_NEAR_MISS)	//nuke was nearby but (mostly) missed
			if( mode && !override )
				override = mode.name
			switch( override )
				if("nuclear emergency") //Nuke wasn't on station when it blew up
					flick("intro_nuke",cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')
					flick("station_intact_fade_red",cinematic)
					cinematic.icon_state = "summary_nukefail"
				if("gang war") //Gang Domination (just show the override screen)
					cinematic.icon_state = "intro_malf_still"
					flick("intro_malf",cinematic)
					sleep(70)
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


		if(NUKE_MISS_STATION || NUKE_SYNDICATE_BASE)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
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
				if("no_core") //Nuke failed to detonate as it had no core
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_intact",cinematic)
					world << sound('sound/ambience/signal.ogg')
					sleep(100)
					if(cinematic)
						qdel(cinematic)
						cinematic = null
					for(var/mob/M in mob_list)
						M.notransform = FALSE
					return	//Faster exit, since nothing happened
				else //Station nuked (nuke,explosion,summary)
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	spawn(300)
		if(cinematic)
			qdel(cinematic)		//end the cinematic
		for(var/mob/M in mob_list)
			M.notransform = FALSE //gratz you survived
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
			if(!isnewplayer(M))
				M << "Captainship not forced on anyone."



/datum/subsystem/ticker/proc/declare_completion()
	set waitfor = FALSE
	var/station_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED
	var/num_survivors = 0
	var/num_escapees = 0
	var/num_shuttle_escapees = 0

	world << "<BR><BR><BR><FONT size=3><B>The round has ended.</B></FONT>"

	//Player status report
	for(var/mob/Player in mob_list)
		if(Player.mind && !isnewplayer(Player))
			if(Player.stat != DEAD && !isbrain(Player))
				num_survivors++
				if(station_evacuated) //If the shuttle has already left the station
					var/area/shuttle_area
					if(SSshuttle && SSshuttle.emergency)
						shuttle_area = SSshuttle.emergency.areaInstance
					if(!Player.onCentcom() && !Player.onSyndieBase())
						Player << "<font color='blue'><b>You managed to survive, but were marooned on [station_name()]...</b></FONT>"
					else
						num_escapees++
						Player << "<font color='green'><b>You managed to survive the events on [station_name()] as [Player.real_name].</b></FONT>"
						if(get_area(Player) == shuttle_area)
							num_shuttle_escapees++
				else
					Player << "<font color='green'><b>You managed to survive the events on [station_name()] as [Player.real_name].</b></FONT>"
			else
				Player << "<font color='red'><b>You did not survive the events on [station_name()]...</b></FONT>"

		CHECK_TICK

	//Round statistics report
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(PERCENT(start_state.score(end_state)), 100)

	world << "<BR>[TAB]Shift Duration: <B>[round(world.time / 36000)]:[add_zero("[world.time / 600 % 60]", 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B>"
	world << "<BR>[TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>"
	if(mode.station_was_nuked)
		ticker.news_report = STATION_DESTROYED_NUKE
	var/total_players = joined_player_list.len
	if(joined_player_list.len)
		world << "<BR>[TAB]Total Population: <B>[total_players]</B>"
		if(station_evacuated)
			world << "<BR>[TAB]Evacuation Rate: <B>[num_escapees] ([PERCENT(num_escapees/total_players)]%)</B>"
			world << "<BR>[TAB](on emergency shuttle): <B>[num_shuttle_escapees] ([PERCENT(num_shuttle_escapees/total_players)]%)</B>"
			news_report = STATION_EVACUATED
			if(SSshuttle.emergency.is_hijacked())
				news_report = SHUTTLE_HIJACK
		world << "<BR>[TAB]Survival Rate: <B>[num_survivors] ([PERCENT(num_survivors/total_players)]%)</B>"
	world << "<BR>"

	CHECK_TICK

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

	CHECK_TICK

	for (var/mob/living/silicon/robot/robo in mob_list)
		if (!robo.connected_ai && robo.mind)
			if (robo.stat != 2)
				world << "<b>[robo.name] (Played by: [robo.mind.key]) survived as an AI-less borg! Its laws were:</b>"
			else
				world << "<b>[robo.name] (Played by: [robo.mind.key]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>"

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				robo.laws.show_laws(world)

	CHECK_TICK

	mode.declare_completion()//To declare normal completion.

	CHECK_TICK

	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if (findtext("[handler]","auto_declare_completion_"))
			call(mode, handler)(force_ending)

	CHECK_TICK

	if(cross_allowed)
		send_news_report()

	CHECK_TICK

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

	CHECK_TICK

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	CHECK_TICK

	//Borers
	var/borerwin = FALSE
	if(borers.len)
		var/borertext = "<br><font size=3><b>The borers were:</b></font>"
		for(var/mob/living/simple_animal/borer/B in borers)
			if((B.key || B.controlling) && B.stat != DEAD)
				borertext += "<br>[B.controlling ? B.victim.key : B.key] was [B.truename] ("
				var/turf/location = get_turf(B)
				if(location.z == ZLEVEL_CENTCOM && B.victim)
					borertext += "escaped with host"
				else
					borertext += "failed"
				borertext += ")"
		world << borertext

		var/total_borers = 0
		for(var/mob/living/simple_animal/borer/B in borers)
			if((B.key || B.victim) && B.stat != DEAD)
				total_borers++
		if(total_borers)
			var/total_borer_hosts = 0
			for(var/mob/living/carbon/C in mob_list)
				var/mob/living/simple_animal/borer/D = C.has_brain_worms()
				var/turf/location = get_turf(C)
				if(location.z == ZLEVEL_CENTCOM && D && D.stat != DEAD)
					total_borer_hosts++
			if(total_borer_hosts_needed <= total_borer_hosts)
				borerwin = TRUE
			world << "<b>There were [total_borers] borers alive at round end!</b>"
			world << "<b>A total of [total_borer_hosts] borers with hosts escaped on the shuttle alive. The borers needed [total_borer_hosts_needed] hosts to escape.</b>"
			if(borerwin)
				world << "<b><font color='green'>The borers were successful!</font></b>"
			else
				world << "<b><font color='red'>The borers have failed!</font></b>"

	CHECK_TICK

	mode.declare_station_goal_completion()

	CHECK_TICK

	//Adds the del() log to world.log in a format condensable by the runtime condenser found in tools
	if(SSgarbage.didntgc.len)
		var/dellog = ""
		for(var/path in SSgarbage.didntgc)
			dellog += "Path : [path] \n"
			dellog += "Failures : [SSgarbage.didntgc[path]] \n"
		world.log << dellog

	CHECK_TICK

	//Collects persistence features
	SSpersistence.CollectData()

	sleep(50)
	if(mode.station_was_nuked)
		world.Reboot("Station destroyed by Nuclear Device.", "end_proper", "nuke")
	else
		world.Reboot("Round ended.", "end_proper", "proper completion")

/datum/subsystem/ticker/proc/send_tip_of_the_round()
	var/m
	if(selected_tip)
		m = selected_tip
	else
		var/list/randomtips = file2list("config/tips.txt")
		var/list/memetips = file2list("config/sillytips.txt")
		if(randomtips.len && prob(95))
			m = pick(randomtips)
		else if(memetips.len)
			m = pick(memetips)

	if(m)
		world << "<font color='purple'><b>Tip of the round: \
			</b>[html_encode(m)]</font>"

/datum/subsystem/ticker/proc/check_queue()
	if(!queued_players.len || !config.hard_popcap)
		return

	queue_delay++
	var/mob/new_player/next_in_line = queued_players[1]

	switch(queue_delay)
		if(5) //every 5 ticks check if there is a slot available
			if(living_player_count() < config.hard_popcap)
				if(next_in_line && next_in_line.client)
					next_in_line << "<span class='userdanger'>A slot has opened! You have approximately 20 seconds to join. <a href='?src=\ref[next_in_line];late_join=override'>\>\>Join Game\<\<</a></span>"
					next_in_line << sound('sound/misc/notice1.ogg')
					next_in_line.LateChoices()
					return
				queued_players -= next_in_line //Client disconnected, remove he
			queue_delay = 0 //No vacancy: restart timer
		if(25 to INFINITY)  //No response from the next in line when a vacancy exists, remove he
			next_in_line << "<span class='danger'>No response recieved. You have been removed from the line.</span>"
			queued_players -= next_in_line
			queue_delay = 0

/datum/subsystem/ticker/proc/check_maprotate()
	if (!config.maprotation || !SERVERTOOLS)
		return
	if (SSshuttle.emergency.mode != SHUTTLE_ESCAPE || SSshuttle.canRecall())
		return
	if (maprotatechecked)
		return

	maprotatechecked = 1

	//map rotate chance defaults to 75% of the length of the round (in minutes)
	if (!prob((world.time/600)*config.maprotatechancedelta))
		return
	spawn(0) //compiling a map can lock up the mc for 30 to 60 seconds if we don't spawn
		maprotate()


/world/proc/has_round_started()
	if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
		return TRUE
	return FALSE

/datum/subsystem/ticker/Recover()
	current_state = ticker.current_state
	force_ending = ticker.force_ending
	hide_mode = ticker.hide_mode
	mode = ticker.mode
	event_time = ticker.event_time
	event = ticker.event

	login_music = ticker.login_music
	round_end_sound = ticker.round_end_sound

	minds = ticker.minds

	syndicate_coalition = ticker.syndicate_coalition
	factions = ticker.factions
	availablefactions = ticker.availablefactions

	delay_end = ticker.delay_end

	triai = ticker.triai
	tipped = ticker.tipped
	selected_tip = ticker.selected_tip

	timeLeft = ticker.timeLeft

	totalPlayers = ticker.totalPlayers
	totalPlayersReady = ticker.totalPlayersReady

	queue_delay = ticker.queue_delay
	queued_players = ticker.queued_players
	cinematic = ticker.cinematic
	maprotatechecked = ticker.maprotatechecked


/datum/subsystem/ticker/proc/send_news_report()
	var/news_message
	var/news_source = "Nanotrasen News Network"
	switch(news_report)
		if(NUKE_SYNDICATE_BASE)
			news_message = "In a daring raid, the heroic crew of [station_name()] detonated a nuclear device in the heart of a terrorist base."
		if(STATION_DESTROYED_NUKE)
			news_message = "We would like to reassure all employees that the reports of a Syndicate backed nuclear attack on [station_name()] are, in fact, a hoax. Have a secure day!"
		if(STATION_EVACUATED)
			news_message = "The crew of [station_name()] has been evacuated amid unconfirmed reports of enemy activity."
		if(GANG_LOSS)
			news_message = "Organized crime aboard [station_name()] has been stamped out by members of our ever vigilant security team. Remember to thank your assigned officers today!"
		if(GANG_TAKEOVER)
			news_message = "Contact with [station_name()] has been lost after a sophisticated hacking attack by organized criminal elements. Stay vigilant!"
		if(BLOB_WIN)
			news_message = "[station_name()] was overcome by an unknown biological outbreak, killing all crew on board. Don't let it happen to you! Remember, a clean work station is a safe work station."
		if(BLOB_NUKE)
			news_message = "[station_name()] is currently undergoing decontanimation after a controlled burst of radiation was used to remove a biological ooze. All employees were safely evacuated prior, and are enjoying a relaxing vacation."
		if(BLOB_DESTROYED)
			news_message = "[station_name()] is currently undergoing decontamination procedures after the destruction of a biological hazard. As a reminder, any crew members experiencing cramps or bloating should report immediately to security for incineration."
		if(CULT_ESCAPE)
			news_message = "Security Alert: A group of religious fanatics have escaped from [station_name()]."
		if(CULT_FAILURE)
			news_message = "Following the dismantling of a restricted cult aboard [station_name()], we would like to remind all employees that worship outside of the Chapel is strictly prohibited, and cause for termination."
		if(CULT_SUMMON)
			news_message = "Company officials would like to clarify that [station_name()] was scheduled to be decommissioned following meteor damage earlier this year. Earlier reports of an unknowable eldritch horror were made in error."
		if(NUKE_MISS)
			news_message = "The Syndicate have bungled a terrorist attack [station_name()], detonating a nuclear weapon in empty space near by."
		if(OPERATIVES_KILLED)
			news_message = "Repairs to [station_name()] are underway after an elite Syndicate death squad was wiped out by the crew."
		if(OPERATIVE_SKIRMISH)
			news_message = "A skirmish between security forces and Syndicate agents aboard [station_name()] ended with both sides bloodied but intact."
		if(REVS_WIN)
			news_message = "Company officials have reassured investors that despite a union led revolt aboard [station_name()] that there will be no wage increases for workers."
		if(REVS_LOSE)
			news_message = "[station_name()] quickly put down a misguided attempt at mutiny. Remember, unionizing is illegal!"
		if(WIZARD_KILLED)
			news_message = "Tensions have flared with the Wizard's Federation following the death of one of their members aboard [station_name()]."
		if(STATION_NUKED)
			news_message = "[station_name()] activated its self destruct device for unknown reasons. Attempts to clone the Captain so he can be arrested and executed are under way."
		if(CLOCK_SUMMON)
			news_message = "The garbled messages about hailing a mouse and strange energy readings from [station_name()] have been discovered to be an ill-advised, if thorough, prank by a clown."
		if(CLOCK_SILICONS)
			news_message = "The project started by [station_name()] to upgrade their silicon units with advanced equipment have been largely successful, though they have thus far refused to release schematics in a violation of company policy."
		if(CLOCK_PROSELYTIZATION)
			news_message = "The burst of energy released near [station_name()] has been confirmed as merely a test of a new weapon. However, due to an unexpected mechanical error, their communications system has been knocked offline."
		if(SHUTTLE_HIJACK)
			news_message = "During routine evacuation procedures, the emergency shuttle of [station_name()] had its navigation protocols corrupted and went off course, but was recovered shortly after."

	if(news_message)
		send2otherserver(news_source, news_message,"News_Report")
