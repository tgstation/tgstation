//Nothing spectacular, just a slightly more configurable MC.

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
	var/breather_ticks = 1		//a somewhat crude attempt to iron over the 'bumps' caused by high-cpu use by letting the MC have a breather for this many ticks after every step
	var/minimum_ticks = 10		//The minimum length of time between MC ticks

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

	if(!tension_master)				tension_master = new /datum/tension()
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

			air_master_ready		= 0
			tension_master_ready	= 0
			sun_ready				= 0
			mobs_ready				= 0
			diseases_ready			= 0
			machines_ready			= 0
			objects_ready			= 0
			networks_ready			= 0
			powernets_ready			= 0
			ticker_ready			= 0

			spawn(0)
				air_master.process()
				air_master_ready = 1
			sleep(breather_ticks)

			spawn(0)
				tension_master.process()
				tension_master_ready = 1
			sleep(breather_ticks)

			spawn(0)
				sun.calc_position()
				sun_ready = 1
			sleep(breather_ticks)

			spawn(0)
				for(var/mob/living/M in world)	//only living mobs have life processes
					M.Life()
				mobs_ready = 1
			sleep(breather_ticks)

			spawn(0)
				for(var/datum/disease/D in active_diseases)
					last_disease_processed = D
					D.process()
				diseases_ready = 1
			sleep(breather_ticks)

			spawn(0)
				for(var/obj/machinery/machine in machines)
					if(machine)
						last_machine_processed = machine
						machine.process()
						if(machine && machine.use_power)
							machine.auto_use_power()
				machines_ready = 1
			sleep(breather_ticks)

			spawn(0)
				for(var/obj/object in processing_objects)
					last_obj_processed = object
					object.process()
				objects_ready = 1
			sleep(breather_ticks)

			spawn(0)
				for(var/datum/pipe_network/network in pipe_networks)
					network.process()
				networks_ready = 1
			sleep(breather_ticks)

			spawn(0)
				for(var/datum/powernet/P in powernets)
					P.reset()
				powernets_ready = 1
			sleep(breather_ticks)

			spawn(0)
				ticker.process()
				ticker_ready = 1

			sleep( minimum_ticks - max(world.timeofday-start_time,0) )	//to prevent long delays happening at midnight

			var/IL_check = 0 //Infinite loop check (To report when the master controller breaks.)
			while(!air_master_ready || !tension_master_ready || !sun_ready || !mobs_ready || !diseases_ready || !machines_ready || !objects_ready || !networks_ready || !powernets_ready || !ticker_ready)
				IL_check++
				if(IL_check > 200)
					var/MC_report = "air_master_ready = [air_master_ready]; tension_master_ready = [tension_master_ready]; sun_ready = [sun_ready]; mobs_ready = [mobs_ready]; diseases_ready = [diseases_ready]; machines_ready = [machines_ready]; objects_ready = [objects_ready]; networks_ready = [networks_ready]; powernets_ready = [powernets_ready]; ticker_ready = [ticker_ready];"
					var/MC_admin_report = "<b><font color='red'>PROC BREAKAGE WARNING:</font> The game's master contorller appears to be stuck in one of it's cycles. It has looped through it's delaying loop [IL_check] times.<br>The master controller reports: [MC_report]</b><br>"
					if(!diseases_ready)
						if(last_disease_processed)
							MC_admin_report += "<b>DISEASE PROCESSING stuck on </b><A HREF='?src=%holder_ref%;adminplayervars=\ref[last_disease_processed]'>[last_disease_processed]</A><br>"
						else
							MC_admin_report += "<b>DISEASE PROCESSING stuck on </b>unknown<br>"
					if(!machines_ready)
						if(last_machine_processed)
							MC_admin_report += "<b>MACHINE PROCESSING stuck on </b><A HREF='?src=%holder_ref%;adminplayervars=\ref[last_machine_processed]'>[last_machine_processed]</A><br>"
						else
							MC_admin_report += "<b>MACHINE PROCESSING stuck on </b>unknown<br>"
					if(!objects_ready)
						if(last_obj_processed)
							MC_admin_report += "<b>OBJ PROCESSING stuck on </b><A HREF='?src=ADMINHOLDERREF;adminplayervars=\ref[last_obj_processed]'>[last_obj_processed]</A><br>"
						else
							MC_admin_report += "<b>OBJ PROCESSING stuck on </b>unknown<br>"
					MC_admin_report += "<font color='red'><b>Master controller breaking out of delaying loop. Restarting the round is advised if problem persists. DO NOT manually restart the master controller.</b></font><br>"
					message_admins(MC_admin_report)
					log_admin("PROC BREAKAGE WARNING: infinite_loop_check = [IL_check]; [MC_report];")
					break
				sleep(3)
		else
			sleep(10)



/datum/failsafe // This thing pretty much just keeps poking the master controller
	var/spinning = 1
	var/current_iteration = 0
	var/ticks_per_spin = 200	//poke the MC every 20 seconds
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
									C << "<font color='red' size='2'><b>Warning. The Master Controller has not fired in the last [4*ticks_per_spin] ticks. Automatic restart in [ticks_per_spin] ticks.</b></font>"
						if(5)
							for(var/client/C)
								if(C.holder)
									C << "<font color='red' size='2'><b>Warning. The Master Controller has still not fired within the last [5*ticks_per_spin] ticks. Killing and restarting...</b></font>"
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

