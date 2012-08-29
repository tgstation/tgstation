var/global/datum/controller/game_controller/master_controller //Set in world.New()
var/global/datum/failsafe/Failsafe
var/global/controller_iteration = 0


var/global/last_tick_timeofday = world.timeofday
var/global/last_tick_duration = 0

datum/controller/game_controller
	var/processing = 0

	var/global/air_master_ready = 0
	var/global/sun_ready = 0
	var/global/mobs_ready = 0
	var/global/diseases_ready = 0
	var/global/machines_ready = 0
	var/global/objects_ready = 0
	var/global/networks_ready = 0
	var/global/powernets_ready = 0
	var/global/ticker_ready = 0

	//Used for MC 'proc break' debugging
	var/global/obj/last_obj_processed
	var/global/datum/disease/last_disease_processed
	var/global/obj/machinery/last_machine_processed
	var/global/mob/last_mob_processed


	proc/setup()
		if(master_controller && (master_controller != src))
			del(src)
			return
			//There can be only one master.

		if(!air_master)
			air_master = new /datum/controller/air_system()
			air_master.setup()

		if(!job_master)
			job_master = new /datum/controller/occupations()
			if(job_master.SetupOccupations())
				world << "\red \b Job setup complete"
				job_master.LoadJobs("config/jobs.txt")

		world.tick_lag = config.Ticklag

		createRandomZlevel()

		setup_objects()

		setupgenetics()


		for(var/i = 0, i < max_secret_rooms, i++)
			make_mining_asteroid_secret()

		syndicate_code_phrase = generate_code_phrase()//Sets up code phrase for traitors, for the round.
		syndicate_code_response = generate_code_phrase()

		emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()

		if(!ticker)
			ticker = new /datum/controller/gameticker()

		setupfactions()

		spawn
			ticker.pregame()

	proc/setup_objects()
		world << "\red \b Initializing objects"
		sleep(-1)

		for(var/obj/object in world)
			object.initialize()

		world << "\red \b Initializing pipe networks"
		sleep(-1)

		for(var/obj/machinery/atmospherics/machine in world)
			machine.build_network()

		world << "\red \b Initializing atmos machinery."
		sleep(-1)
		for(var/obj/machinery/atmospherics/unary/vent_pump/T in world)
			T.broadcast_status()
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/T in world)
			T.broadcast_status()

		world << "\red \b Initializations complete."


	proc/process()
		processing = 1
		spawn(0)
			set background = 1
			while(1)
				var/currenttime = world.timeofday
				var/diff = (currenttime - last_tick_timeofday) / 10
				last_tick_timeofday = currenttime
				last_tick_duration = diff

				if(processing)

					controller_iteration++

					var/start_time = world.timeofday

					air_master_ready = 0
					sun_ready = 0
					mobs_ready = 0
					diseases_ready = 0
					machines_ready = 0
					objects_ready = 0
					networks_ready = 0
					powernets_ready = 0
					ticker_ready = 0

					// moved this here from air_master.start()
					// this might make atmos slower
					// upsides:
					//  1. atmos won't process if the game is generally lagged out(no deadlocks)
					//  2. if the server frequently crashes during atmos processing we will know
					if(!kill_air)
						src.set_debug_state("Air Master")

						air_master.current_cycle++
						var/success = air_master.tick() //Changed so that a runtime does not crash the ticker.
						if(!success) //Runtimed.
							log_adminwarn("ZASALERT: air_system/tick() failed: [air_master.tick_progress]")
							air_master.failed_ticks++
							if(air_master.failed_ticks > 5)
								world << "<font color='red'><b>RUNTIMES IN ATMOS TICKER.  Killing air simulation!</font></b>"
								kill_air = 1
								air_master.failed_ticks = 0
						/*else if (air_master.failed_ticks > 10)
							air_master.failed_ticks = 0*/
					air_master_ready = 1

					sleep(1)

					spawn(0)
						sun.calc_position()
						sun_ready = 1

					sleep(-1)

					spawn(0)
						for(var/mob/M in world)
							last_mob_processed = M
							M.Life()
						mobs_ready = 1

					sleep(-1)

					spawn(0)
						for(var/datum/disease/D in active_diseases)
							last_disease_processed = D
							D.process()
						diseases_ready = 1

					spawn(0)
						for(var/obj/machinery/machine in machines)
							if(machine)
								last_machine_processed = machine
								machine.process()
								if(machine && machine.use_power)
									machine.auto_use_power()

						machines_ready = 1

					sleep(1)

					spawn(-1)
						for(var/obj/object in processing_objects)
							last_obj_processed = object
							object.process()
						objects_ready = 1

					sleep(-1)

					spawn(-1)
						for(var/datum/pipe_network/network in pipe_networks)
							network.process()
						networks_ready = 1

					spawn(-1)
						for(var/datum/powernet/P in powernets)
							P.reset()
						powernets_ready = 1

					sleep(-1)

					spawn(-1)
						ticker.process()
						ticker_ready = 1

					var/IL_check = 0 //Infinite loop check (To report when the master controller breaks.)
					while(!air_master_ready || !sun_ready || !mobs_ready || !diseases_ready || !machines_ready || !objects_ready || !networks_ready || !powernets_ready || !ticker_ready)
						IL_check++
						if(IL_check > 600)
							var/MC_report = "air_master_ready = [air_master_ready]; sun_ready = [sun_ready]; mobs_ready = [mobs_ready]; diseases_ready = [diseases_ready]; machines_ready = [machines_ready]; objects_ready = [objects_ready]; networks_ready = [networks_ready]; powernets_ready = [powernets_ready]; ticker_ready = [ticker_ready];"
							message_admins("<b><font color='red'>PROC BREAKAGE WARNING:</font> The game's master contorller appears to be stuck in one of it's cycles. It has looped through it's delaying loop [IL_check] times.</b>")
							message_admins("<b>The master controller reports: [MC_report]</b>")
							if(!diseases_ready)
								if(last_disease_processed)
									message_admins("<b>DISEASE PROCESSING stuck on </b><A HREF='?src=%holder_ref%;adminplayervars=\ref[last_disease_processed]'>[last_disease_processed]</A>", 0, 1)
								else
									message_admins("<b>DISEASE PROCESSING stuck on </b>unknown")
							if(!machines_ready)
								if(last_machine_processed)
									message_admins("<b>MACHINE PROCESSING stuck on </b><A HREF='?src=%holder_ref%;adminplayervars=\ref[last_machine_processed]'>[last_machine_processed]</A>", 0, 1)
								else
									message_admins("<b>MACHINE PROCESSING stuck on </b>unknown")
							if(!objects_ready)
								if(last_obj_processed)
									message_admins("<b>OBJ PROCESSING stuck on </b><A HREF='?src=ADMINHOLDERREF;adminplayervars=\ref[last_obj_processed]'>[last_obj_processed]</A>", 0, 1)
								else
									message_admins("<b>OBJ PROCESSING stuck on </b>unknown")
							log_admin("PROC BREAKAGE WARNING: infinite_loop_check = [IL_check]; [MC_report];")
							message_admins("<font color='red'><b>Master controller breaking out of delaying loop. Restarting the round is advised if problem persists. DO NOT manually restart the master controller.</b></font>")
							break;
						sleep(1)

					sleep(world.timeofday+12-start_time)
				else
					sleep(10)


	proc/set_debug_state(txt)
		// This should describe what is currently being done by the master controller
		// Useful for crashlogs and similar, because that way it's easy to tell what
		// was going on when the server crashed.
		socket_talk.send_raw("type=ticker_state&message=[txt]")
		return