//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()
var/global/datum/failsafe/Failsafe

var/global/controller_iteration = 0
var/global/last_tick_timeofday = world.timeofday
var/global/last_tick_duration = 0

datum/controller/game_controller
	var/processing = 0
	var/breather_ticks = 2		//a somewhat crude attempt to iron over the 'bumps' caused by high-cpu use by letting the MC have a breather for this many ticks after every loop
	var/minimum_ticks = 20		//The minimum length of time between MC ticks

	var/air_cost 		= 0
	var/sun_cost		= 0
	var/mobs_cost		= 0
	var/diseases_cost	= 0
	var/machines_cost	= 0
	var/objects_cost	= 0
	var/networks_cost	= 0
	var/powernets_cost	= 0
	var/ticker_cost		= 0
	var/total_cost		= 0

	var/last_thing_processed

datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		if(istype(master_controller,/datum/controller/game_controller))
			Recover()
			del(master_controller)
		master_controller = src

	if(!air_master)
		air_master = new /datum/controller/air_system()
		air_master.setup()

	if(!job_master)
		job_master = new /datum/controller/occupations()
		if(job_master.SetupOccupations())
			world << "\red \b Job setup complete"
			job_master.LoadJobs("config/jobs.txt")

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	if(!ticker)						ticker = new /datum/controller/gameticker()
	if(!emergency_shuttle)			emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()


datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	createRandomZlevel()
	setup_objects()
	setupgenetics()
	setupfactions()

	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	spawn(0)
		if(ticker)
			ticker.pregame()

datum/controller/game_controller/proc/setup_objects()
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
	for(var/obj/machinery/atmospherics/unary/U in world)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()

	world << "\red \b Initializations complete."
	sleep(-1)


datum/controller/game_controller/proc/process()
	processing = 1
	spawn(0)
		set background = 1
		while(1)	//far more efficient than recursively calling ourself
			if(!Failsafe)	new /datum/failsafe()

			var/currenttime = world.timeofday
			last_tick_duration = (currenttime - last_tick_timeofday) / 10
			last_tick_timeofday = currenttime

			if(processing)
				var/timer
				var/start_time = world.timeofday
				controller_iteration++

				//AIR
				/*timer = world.timeofday
				last_thing_processed = air_master.type
				air_master.process()
				air_cost = (world.timeofday - timer) / 10*/

				// this might make atmos slower
				//  1. atmos won't process if the game is generally lagged out(no deadlocks)
				//  2. if the server frequently crashes during atmos processing we will know
				if(!kill_air)
					//src.set_debug_state("Air Master")

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
				//air_master_ready = 1


				sleep(breather_ticks)

				//SUN
				timer = world.timeofday
				last_thing_processed = sun.type
				sun.calc_position()
				sun_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MOBS
				timer = world.timeofday
				var/i = 1
				while(i<=mob_list.len)
					var/mob/M = mob_list[i]
					if(M)
						last_thing_processed = M.type
						M.Life()
						i++
						continue
					mob_list.Cut(i,i+1)
				mobs_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//DISEASES
				timer = world.timeofday
				i = 1
				while(i<=active_diseases.len)
					var/datum/disease/Disease = active_diseases[i]
					if(Disease)
						last_thing_processed = Disease.type
						Disease.process()
						i++
						continue
					active_diseases.Cut(i,i+1)
				diseases_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MACHINES
				timer = world.timeofday
				i = 1
				while(i<=machines.len)
					var/obj/machinery/Machine = machines[i]
					if(Machine)
						last_thing_processed = Machine.type
						if(Machine.process() != PROCESS_KILL)
							if(Machine)
								if(Machine.use_power)
									Machine.auto_use_power()
								i++
								continue
					machines.Cut(i,i+1)
				machines_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//OBJECTS
				timer = world.timeofday
				i = 1
				while(i<=processing_objects.len)
					var/obj/Object = processing_objects[i]
					if(Object)
						last_thing_processed = Object.type
						Object.process()
						i++
						continue
					processing_objects.Cut(i,i+1)
				objects_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//PIPENETS
				timer = world.timeofday
				last_thing_processed = /datum/pipe_network
				i = 1
				while(i<=pipe_networks.len)
					var/datum/pipe_network/Network = pipe_networks[i]
					if(Network)
						Network.process()
						i++
						continue
					pipe_networks.Cut(i,i+1)
				networks_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//POWERNETS
				timer = world.timeofday
				last_thing_processed = /datum/powernet
				i = 1
				while(i<=powernets.len)
					var/datum/powernet/Powernet = powernets[i]
					if(Powernet)
						Powernet.reset()
						i++
						continue
					powernets.Cut(i,i+1)
				powernets_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//TICKER
				timer = world.timeofday
				last_thing_processed = ticker.type
				ticker.process()
				ticker_cost = (world.timeofday - timer) / 10

				//TIMING
				total_cost = air_cost + sun_cost + mobs_cost + diseases_cost + machines_cost + objects_cost + networks_cost + powernets_cost + ticker_cost

				var/end_time = world.timeofday
				if(end_time < start_time)
					start_time -= 864000    //deciseconds in a day
				sleep( round(minimum_ticks - (end_time - start_time),1) )
			else
				sleep(10)

datum/controller/game_controller/proc/Recover()		//Mostly a placeholder for now.
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for(var/varname in master_controller.vars)
		switch(varname)
			if("tag","bestF","type","parent_type","vars")	continue
			else
				var/varval = master_controller.vars[varname]
				if(istype(varval,/datum))
					var/datum/D = varval
					msg += "\t [varname] = [D.type]\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg

/datum/failsafe // This thing pretty much just keeps poking the master controller
	var/spinning = 1
	var/current_iteration = 0
	var/ticks_per_spin = 100	//poke the MC every 10 seconds
	var/defcon = 0				//alert level. For every poke that fails this is raised by 1. When it reaches 5 the MC is replaced with a new one. (effectively killing any master_controller.process() and starting a new one)

/datum/failsafe/New()
	//There can be only one failsafe. Out with the old in with the new (that way we can restart the Failsafe by spawning a new one)
	if(Failsafe && (Failsafe != src))
		del(Failsafe)
	Failsafe = src

	current_iteration = controller_iteration
	Failsafe.spin()


/datum/failsafe/proc/spin()
	spawn(0)
		set background = 1
		while(1)	//more efficient than recursivly calling ourself over and over. background = 1 ensures we do not trigger an infinite loop
			if(master_controller)
				if(spinning && master_controller.processing)	//only poke if these overrides aren't in effect
					if(current_iteration == controller_iteration)	//master_controller hasn't finished processing in the defined interval
						switch(defcon)
							if(0 to 3)
								defcon++
							if(4)
								for(var/client/C in admin_list)
									if(C.holder)
										C << "<font color='red' size='2'><b>Warning. The Master Controller has not fired in the last [defcon*ticks_per_spin] ticks. Automatic restart in [ticks_per_spin] ticks.</b></font>"
								defcon = 5
							if(5)
								for(var/client/C in admin_list)
									if(C.holder)
										C << "<font color='red' size='2'><b>Warning. The Master Controller has still not fired within the last [defcon*ticks_per_spin] ticks. Killing and restarting...</b></font>"
								new /datum/controller/game_controller()	//replace the old master_controller (hence killing the old one's process)
								master_controller.process()	//Start it rolling again
								defcon = 0
					else
						defcon = 0
						current_iteration = controller_iteration
				else
					defcon = 0
			else
				new /datum/controller/game_controller()	//replace the missing master_controller! This should never happen.
			sleep(ticks_per_spin)

//DEBUG VERBS
/*
/client/verb/spawn_MC()
	new /datum/controller/game_controller()


/client/verb/spawn_FS()
	new /datum/failsafe()

/client/verb/machines_list()
	for(var/i=1,i<=machines.len,i++)
		var/machine = machines[i]
		if(istype(machine,/datum))	world.log << machine:type
		else						world.log << machine
*/