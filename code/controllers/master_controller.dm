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

	var/obj/machinery/last_obj_processed		//Used for MC 'proc break' debugging
	var/datum/disease/last_disease_processed	//Used for MC 'proc break' debugging
	var/obj/machinery/last_machine_processed	//Used for MC 'proc break' debugging

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

				timer = world.timeofday
				air_master.process()
				air_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				timer = world.timeofday
				sun.calc_position()
				sun_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				timer = world.timeofday
				for(var/i=1,i<=mob_list.len,i++)
					var/mob/M = mob_list[i]
					if(M)
						M.Life()
						continue
					mob_list.Cut(i,i+1)
					i--
				mobs_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				timer = world.timeofday
				for(var/i=1,i<=active_diseases.len,i++)
					var/datum/disease/Disease = active_diseases[i]
					if(Disease)
						last_disease_processed = Disease
						Disease.process()
						continue
					active_diseases.Cut(i,i+1)
					i--
				diseases_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				timer = world.timeofday
				for(var/i=1,i<=machines.len,i++)
					var/obj/machinery/Machine = machines[i]
					if(Machine)
						last_machine_processed = Machine
						Machine.process()
						if(Machine)
							if(Machine.use_power)
								Machine.auto_use_power()
							continue
					machines.Cut(i,i+1)
					i--
				machines_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				timer = world.timeofday
				for(var/i=1,i<=processing_objects.len,i++)
					var/obj/Object = processing_objects[i]
					if(Object)
						last_obj_processed = Object
						Object.process()
						continue
					processing_objects.Cut(i,i+1)
					i--
				objects_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				timer = world.timeofday
				for(var/i=1,i<=pipe_networks.len,i++)
					var/datum/pipe_network/Network = pipe_networks[i]
					if(Network)
						Network.process()
						continue
					pipe_networks.Cut(i,i+1)
					i--
				networks_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				timer = world.timeofday
				for(var/i=1,i<=powernets.len,i++)
					var/datum/powernet/Powernet = powernets[i]
					if(Powernet)
						Powernet.reset()
						continue
					powernets.Cut(i,i+1)
					i--
				powernets_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				timer = world.timeofday
				ticker.process()
				ticker_cost = (world.timeofday - timer) / 10

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
								defcon = 5
								for(var/client/C in admin_list)
									if(C.holder)
										C << "<font color='red' size='2'><b>Warning. The Master Controller has not fired in the last [defcon*ticks_per_spin] ticks. Automatic restart in [ticks_per_spin] ticks.</b></font>"
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
*/
