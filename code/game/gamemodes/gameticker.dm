var/global/datum/controller/gameticker/ticker

#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4

/datum/controller/gameticker
	var/current_state = GAME_STATE_PREGAME

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/list/datum/mind/minds = list()

	var/pregame_timeleft = 0

/datum/controller/gameticker/proc/pregame()
	set background = 1

	pregame_timeleft = 60
	world << "<B><FONT color='blue'>Welcome to the pre-game lobby!</FONT></B>"
	world << "Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds"

	while(current_state == GAME_STATE_PREGAME)
		sleep(10)
		pregame_timeleft--

		if(pregame_timeleft <= 0)
			current_state = GAME_STATE_SETTING_UP

	spawn setup()

/datum/controller/gameticker/proc/setup()
	//Create and announce mode
	if(master_mode=="secret")
		src.hide_mode = 1

	if((master_mode=="random") || (master_mode=="secret"))
		src.mode = config.pick_random_mode()
	else
		src.mode = config.pick_mode(master_mode)

	if(hide_mode)
		var/modes = sortList(config.get_used_mode_names())

		world << "<B>The current game mode is - Secret!</B>"
		world << "<B>Possibilities:</B> [english_list(modes)]"
	else
		src.mode.announce()

	//Configure mode and assign player to special mode stuff
	var/can_continue = src.mode.pre_setup()

	if(!can_continue)
		del(mode)

		current_state = GAME_STATE_PREGAME
		world << "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby."

		spawn pregame()

		return 0

	//Distribute jobs
	distribute_jobs()

	//Create player characters and transfer them
	create_characters()

	add_minds()


	//Equip characters
	equip_characters()

	data_core.manifest()


	current_state = GAME_STATE_PLAYING
	spawn(0)
		mode.post_setup()

		//Cleanup some stuff
		for(var/obj/landmark/start/S in world)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if (S.name != "AI")
				del(S)

		//Start master_controller.process()
		world << "<FONT color='blue'><B>Enjoy the game!</B></FONT>"
		spawn(-1)
			world << sound('welcome.ogg') // Skie


	spawn (3000)
		start_events()
	spawn ((18000+rand(3000)))
		event()
	spawn() supply_ticker() // Added to kick-off the supply shuttle regenerating points -- TLE

	spawn master_controller.process()

	spawn(3000) statistic_cycle() // Polls population totals regularly and stores them in an SQL DB -- TLE

/datum/controller/gameticker
	proc/distribute_jobs()
		DivideOccupations()

	proc/create_characters()
		for(var/mob/new_player/player in world)
			if(player.ready)
				if(player.mind && player.mind.assigned_role=="AI")
					player.close_spawn_windows()
					player.AIize()
				else if(player.mind)
					player.create_character()
					del(player)
	proc/add_minds()
		for(var/mob/living/carbon/human/player in world)
			if(player.mind)
				ticker.minds += player.mind

	proc/equip_characters()
		for(var/mob/living/carbon/human/player in world)
			if(player.mind && player.mind.assigned_role)
				if(player.mind.assigned_role != "MODE")
					player.Equip_Rank(player.mind.assigned_role)

	proc/process()
		if(current_state != GAME_STATE_PLAYING)
			return 0

		mode.process()

		emergency_shuttle.process()

		if(mode.check_finished())
			current_state = GAME_STATE_FINISHED

			spawn
				declare_completion()
			var/noboom = 0
			if(ticker.mode.name == "nuclear emergency")
				var/datum/game_mode/nuclear/bam = ticker.mode
				if (bam.nuke_detonated == 0)
					noboom = 1

			if(ticker.mode.name != "nuclear emergency" || noboom)
				spawn(50)
					world << "\blue <B>Restarting in 25 seconds</B>"

					sleep(250)
					world.Reboot()

		return 1

/*
/datum/controller/gameticker/proc/timeup()

	if (shuttle_left) //Shuttle left but its leaving or arriving again
		check_win()	  //Either way, its not possible
		return

	if (src.shuttle_location == shuttle_z)

		move_shuttle(locate(/area/shuttle), locate(/area/arrival/shuttle))

		src.timeleft = shuttle_time_in_station
		src.shuttle_location = 1

		world << "<B>The Emergency Shuttle has docked with the station! You have [ticker.timeleft/600] minutes to board the Emergency Shuttle.</B>"

	else //marker2
		world << "<B>The Emergency Shuttle is leaving!</B>"
		shuttle_left = 1
		shuttlecoming = 0
		check_win()
	return
*/

/datum/controller/gameticker/proc/declare_completion()

	for (var/mob/living/silicon/ai/aiPlayer in world)
		if (aiPlayer.name != "Inactive AI")
			if (aiPlayer.stat != 2)
				world << "<b>[aiPlayer.name]'s laws at the end of the game were:</b>"
			else
				world << "<b>[aiPlayer.name]'s laws when it was deactivated were:</b>"
			aiPlayer.show_laws(1)

			var/robolist = "The AI's loyal minions were: "
			for(var/mob/living/silicon/robot/robo in world)
				if (robo.connected_ai == aiPlayer)
					robolist += "[robo.name][robo.stat == 2?" (Deactivated), ":", "]"

	for (var/mob/living/silicon/robot/robo in world)
		if (!robo.connected_ai)
			if (robo.stat != 2)
				world << "<b>[robo.name] survived as an AI-less borg! Its laws were:</b>"
			else
				world << "<b>[robo.name] was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>"
			robo.show_laws(1)

	mode.declare_completion()

	return 1

/////
/////SETTING UP THE GAME
/////

/////
/////MAIN PROCESS PART
/////
/*
/datum/controller/gameticker/proc/game_process()

	switch(mode.name)
		if("deathmatch","monkey","nuclear emergency","Corporate Restructuring","revolution","traitor",
		"wizard","extended")
			do
				if (!( shuttle_frozen ))
					if (src.timing == 1)
						src.timeleft -= 10
					else
						if (src.timing == -1.0)
							src.timeleft += 10
							if (src.timeleft >= shuttle_time_to_arrive)
								src.timeleft = null
								src.timing = 0
				if (prob(0.5))
					spawn_meteors()
				if (src.timeleft <= 0 && src.timing)
					src.timeup()
				sleep(10)
			while(src.processing)
			return
//Standard extended process (incorporates most game modes).
//Put yours in here if you don't know where else to put it.
		if("AI malfunction")
			do
				check_win()
				ticker.AItime += 10
				sleep(10)
				if (ticker.AItime == 6000)
					world << "<FONT size = 3><B>Cent. Com. Update</B> AI Malfunction Detected</FONT>"
					world << "\red It seems we have provided you with a malfunctioning AI. We're very sorry."
			while(src.processing)
			return
//malfunction process
		if("meteor")
			do
				if (!( shuttle_frozen ))
					if (src.timing == 1)
						src.timeleft -= 10
					else
						if (src.timing == -1.0)
							src.timeleft += 10
							if (src.timeleft >= shuttle_time_to_arrive)
								src.timeleft = null
								src.timing = 0
				for(var/i = 0; i < 10; i++)
					spawn_meteors()
				if (src.timeleft <= 0 && src.timing)
					src.timeup()
				sleep(10)
			while(src.processing)
			return
//meteor mode!!! MORE METEORS!!!
		else
			return
//Anything else, like sandbox, return.
*/