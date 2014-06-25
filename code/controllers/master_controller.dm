// simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
// It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)

var/global/datum/controller/game_controller/master_controller
var/global/last_tick_timeofday = world.timeofday
var/global/last_tick_duration = 0
var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

datum/controller/game_controller
	var/minimum_ticks = 20
	var/breather = 2

datum/controller/game_controller/New()
	. = ..()

	if(master_controller != src) // THERE CAN ONLY BE ONE
		log_debug("Rebuilding Master Controller")

		if(istype(master_controller))
			recover()
			qdel(master_controller)

		master_controller = src

	if(job_master == null)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		world << "\red \b Job setup complete"

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	if(!emergency_shuttle)			emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()

datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	// notify the other process that we started up
	socket_talk = new /datum/socket_talk()
	socket_talk.send_raw("type=startup")

	createRandomZlevel()

	if(!air_master)
		air_master = new /datum/controller/air_system()
		air_master.Setup()

	if(!ticker)
		ticker = new /datum/controller/gameticker()

	if(!garbage)
		garbage = new /datum/controller/garbage_collector()

	setup_objects()
	setupgenetics()
	setupfactions()
	setup_economy()
	SetupXenoarch()

	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	spawn(0)
		if(ticker)
			ticker.pregame()

	lighting_controller.Initialize()

datum/controller/game_controller/proc/setup_objects()
	world << "\red \b Initializing objects"
	sleep(-1)
	for(var/atom/movable/O in world)
		O.initialize()

	world << "\red \b Initializing pipe networks"
	sleep(-1)
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()

	world << "\red \b Initializing atmos machinery."
	sleep(-1)
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()

	world << "\red \b Initializations complete."
	sleep(-1)


/datum/controller/game_controller/proc/process()
	processing = 1

	spawn(0)
		set background = BACKGROUND_ENABLED

		while(1)
			if(failsafe == null)
				new /datum/controller/failsafe()

			var/currenttime = world.timeofday
			last_tick_duration = (currenttime - last_tick_timeofday) / 10
			last_tick_timeofday = currenttime

			if(processing)
				iteration++
				var/start_time = world.timeofday

				vote.process()

				if(!air_processing_killed)
					if(!air_master.Tick()) //Runtimed.
						air_master.failed_ticks++
						if(air_master.failed_ticks > 5)
							world << "<font color='red'><b>RUNTIMES IN ATMOS TICKER.  Killing air simulation!</font></b>"
							world.log << "### ZAS SHUTDOWN"
							message_admins("ZASALERT: unable to run [air_master.tick_progress], shutting down!")
							log_admin("ZASALERT: unable run zone/process() -- [air_master.tick_progress]")
							air_processing_killed = 1
							air_master.failed_ticks = 0

				sun.calc_position(); sleep(breather);
				processMobs();		sleep(breather)
				processDiseases();	sleep(breather)
				processMachines();	sleep(breather)
				processObjects();	sleep(breather)
				if(!pipe_processing_killed)
					processPipenets()
					sleep(breather)
				processPowernets();	sleep(breather)
				processNano()
				processEvents()
				ticker.process()

				var/end_time = world.timeofday
				if(end_time < start_time)
					start_time -= 864000    //deciseconds in a day
				sleep(round(minimum_ticks - (end_time-start_time), 1))
			else
				sleep(10)

/datum/controller/game_controller/proc/processMobs()
	for(var/mob/M in mob_list)
		if(M == null)
			mob_list -= M
			continue
		M.Life()

/datum/controller/game_controller/proc/processDiseases()
	for(var/datum/disease/D in active_diseases)
		if(D == null)
			active_diseases -= D
			continue
		D.process()

/datum/controller/game_controller/proc/processMachines()
	for(var/obj/machinery/M in machines)
		if(M == null || M.loc == null)
			// Not sure if safe to remove from list
			continue

		if(M.process() == PROCESS_KILL)
			M.inMachineList = 0
			machines.Remove(M)
			continue

		if(M.use_power)
			M.auto_use_power()

/datum/controller/game_controller/proc/processObjects()
	for(var/obj/O in processing_objects)
		if(O == null || O.loc == null)
			processing_objects -= O
			continue
		O.process()

/datum/controller/game_controller/proc/processPipenets()
	for(var/datum/pipe_network/P in pipe_networks)
		if(P == null)
			pipe_networks -= P
			continue
		P.process()

/datum/controller/game_controller/proc/processPowernets()
	for(var/datum/powernet/P in powernets)
		if(P == null)
			powernets -= P
			continue
		P.reset()

/datum/controller/game_controller/proc/processNano()
	for(var/datum/nanoui/N in nanomanager.processing_uis)
		if(N == null)
			nanomanager.processing_uis -= N
			continue
		N.process()

/datum/controller/game_controller/proc/processEvents()
	for(var/datum/event/E in events)
		if(E == null)
			events -= E
			continue
	checkEvent()

datum/controller/game_controller/recover()		//Mostly a placeholder for now.
	. = ..()
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for(var/varname in master_controller.vars)
		switch(varname)
			if("tag","type","parent_type","vars")	continue
			else
				var/varval = master_controller.vars[varname]
				if(istype(varval,/datum))
					var/datum/D = varval
					msg += "\t [varname] = [D.type]\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg
