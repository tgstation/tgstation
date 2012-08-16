//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()
var/global/datum/failsafe/Failsafe
var/global/controller_iteration = 0


var/global/last_tick_timeofday = world.timeofday
var/global/last_tick_duration = 0

var/global/obj/machinery/last_obj_processed			//Used for MC 'proc break' debugging
var/global/datum/disease/last_disease_processed		//Used for MC 'proc break' debugging
var/global/obj/machinery/last_machine_processed		//Used for MC 'proc break' debugging

datum/controller/game_controller
	var/processing = 0
	var/breather_ticks = 2		//a somewhat crude attempt to iron over the 'bumps' caused by high-cpu use by letting the MC have a breather for this many ticks after every loop
	var/minimum_ticks = 20		//The minimum length of time between MC ticks

	var/global/air_master_ready		= 0
	var/global/tension_master_ready	= 0
	var/global/sun_ready			= 0
	var/global/mobs_ready			= 0
	var/global/diseases_ready		= 0
	var/global/machines_ready		= 0
	var/global/objects_ready		= 0
	var/global/networks_ready		= 0
	var/global/powernets_ready		= 0
	var/global/ticker_ready			= 0

datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller)
		if(master_controller != src)
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

	for(var/i = 0, i < max_secret_rooms, i++)
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
	for(var/obj/machinery/atmospherics/unary/vent_pump/T in world)
		T.broadcast_status()
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/T in world)
		T.broadcast_status()

	world << "\red \b Initializations complete."
	sleep(-1)


datum/controller/game_controller/proc/process()
	set background = 1
	processing = 1
	while(1)	//far more efficient than recursively calling ourself
		if(!Failsafe)	new /datum/failsafe()

		var/currenttime = world.timeofday
		last_tick_duration = (currenttime - last_tick_timeofday) / 10
		last_tick_timeofday = currenttime

		if(processing)
			var/start_time = world.timeofday
			controller_iteration++

			air_master.process()
			sleep(breather_ticks)

			sun.calc_position()
			sleep(breather_ticks)

			for(var/mob/living/M in world)	//only living mobs have life processes
				M.Life()
			sleep(breather_ticks)

			for(var/datum/disease/D in active_diseases)
				last_disease_processed = D
				D.process()
			sleep(breather_ticks)

			for(var/obj/machinery/machine in machines)
				if(machine)
					last_machine_processed = machine
					machine.process()
					if(machine && machine.use_power)
						machine.auto_use_power()
			sleep(breather_ticks)

			for(var/obj/object in processing_objects)
				last_obj_processed = object
				object.process()
			sleep(breather_ticks)

			for(var/datum/pipe_network/network in pipe_networks)
				network.process()
			sleep(breather_ticks)


			for(var/datum/powernet/P in powernets)
				P.reset()
			sleep(breather_ticks)

			ticker.process()

			sleep( minimum_ticks - max(world.timeofday-start_time,0) )	//to prevent long delays happening at midnight

		else
			sleep(10)



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
	spawn(0)
		Failsafe.spin()


/datum/failsafe/proc/spin()
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
							for(var/client/C)
								if(C.holder)
									C << "<font color='red' size='2'><b>Warning. The Master Controller has not fired in the last [defcon*ticks_per_spin] ticks. Automatic restart in [ticks_per_spin] ticks.</b></font>"
						if(5)
							for(var/client/C)
								if(C.holder)
									C << "<font color='red' size='2'><b>Warning. The Master Controller has still not fired within the last [defcon*ticks_per_spin] ticks. Killing and restarting...</b></font>"
							spawn(0)
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