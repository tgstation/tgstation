//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration = 0
var/global/last_tick_timeofday = world.timeofday
var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

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
	var/nano_cost		= 0
	var/events_cost		= 0
	var/ticker_cost		= 0
	var/total_cost		= 0

	var/last_thing_processed

datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		if(istype(master_controller))
			Recover()
			del(master_controller)
		master_controller = src

	createRandomZlevel()			//probably shouldn't be here!

	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	if(!events)
		new /datum/controller/event()

	if(!air_master)
		air_master = new /datum/controller/air_system()
		air_master.setup()

	if(!job_master)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		world << "\red \b Job setup complete"

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	if(!ticker)						ticker = new /datum/controller/gameticker()
	if(!emergency_shuttle)			emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()
	if(!supply_shuttle)				supply_shuttle = new /datum/controller/supply_shuttle()


datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	setup_objects()
	setupgenetics()
	setupfactions()

	spawn(0)
		if(ticker)
			ticker.pregame()

datum/controller/game_controller/proc/setup_objects()
	world << "\red \b Initializing objects..."
	sleep(-1)
	for(var/atom/movable/object in world)
		object.initialize()

	world << "\red \b Initializing pipe networks..."
	sleep(-1)
	for(var/obj/machinery/atmospherics/machine in world)
		machine.build_network()

	world << "\red \b Initializing atmos machinery..."
	sleep(-1)
	for(var/obj/machinery/atmospherics/unary/U in world)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()

	world << "\red \b Making a mess..."
	sleep(-1)
	for(var/turf/simulated/floor/F in world)
		F.MakeDirty()

	world << "\red \b Initializations complete."
	sleep(-1)


datum/controller/game_controller/proc/process()
	processing = 1
	spawn(0)
		set background = 1
		while(1)	//far more efficient than recursively calling ourself
			if(!Failsafe)	new /datum/controller/failsafe()

			var/currenttime = world.timeofday
			last_tick_duration = (currenttime - last_tick_timeofday) / 10
			last_tick_timeofday = currenttime

			if(processing)
				var/timer
				var/start_time = world.timeofday
				controller_iteration++

				vote.process()

				//AIR
				if(!air_processing_killed)
					timer = world.timeofday
					last_thing_processed = air_master.type
					air_master.process()
					air_cost = (world.timeofday - timer) / 10
					global_activeturfs = air_master.active_turfs.len

				sleep(breather_ticks)

				//SUN
				timer = world.timeofday
				last_thing_processed = sun.type
				sun.calc_position()
				sun_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MOBS
				timer = world.timeofday
				process_mobs()
				mobs_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//DISEASES
				timer = world.timeofday
				process_diseases()
				diseases_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MACHINES
				timer = world.timeofday
				process_machines()
				machines_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//OBJECTS
				timer = world.timeofday
				process_objects()
				objects_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//PIPENETS
				if(!pipe_processing_killed)
					timer = world.timeofday
					process_pipenets()
					networks_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//POWERNETS
				timer = world.timeofday
				process_powernets()
				powernets_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//NANO UIS
				timer = world.timeofday
				process_nano()
				nano_cost = (world.timeofday - timer) / 10

				//EVENTS
				timer = world.timeofday
				last_thing_processed = /datum/round_event
				events.process()
				events_cost = (world.timeofday - timer) / 10

				//TICKER
				timer = world.timeofday
				last_thing_processed = ticker.type
				ticker.process()
				ticker_cost = (world.timeofday - timer) / 10

				//TIMING
				total_cost = air_cost + sun_cost + mobs_cost + diseases_cost + machines_cost + objects_cost + networks_cost + powernets_cost + nano_cost + events_cost + ticker_cost

				var/end_time = world.timeofday
				if(end_time < start_time)
					start_time -= MIDNIGHT_ROLLOVER    //deciseconds in a day
				sleep( round(minimum_ticks - (end_time - start_time),1) )
			else
				sleep(10)

/*
datum/controller/game_controller/proc/process_liquid()
	last_thing_processed = /datum/puddle
	var/i = 1
	while(i<=puddles.len)
		var/datum/puddle/Puddle = puddles[i]
		if(Puddle)
			Puddle.process()
			i++
			continue
		puddles.Cut(i,i+1)
*/

datum/controller/game_controller/proc/process_mobs()
	var/i = 1
	while(i<=mob_list.len)
		var/mob/M = mob_list[i]
		if(M)
			last_thing_processed = M.type
			M.Life()
			i++
			continue
		mob_list.Cut(i,i+1)

datum/controller/game_controller/proc/process_diseases()
	var/i = 1
	while(i<=active_diseases.len)
		var/datum/disease/Disease = active_diseases[i]
		if(Disease)
			last_thing_processed = Disease.type
			Disease.process()
			i++
			continue
		active_diseases.Cut(i,i+1)

datum/controller/game_controller/proc/process_machines()
	var/i = 1
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

datum/controller/game_controller/proc/process_objects()
	var/i = 1
	while(i<=processing_objects.len)
		var/obj/Object = processing_objects[i]
		if(Object)
			last_thing_processed = Object.type
			Object.process()
			i++
			continue
		processing_objects.Cut(i,i+1)

datum/controller/game_controller/proc/process_pipenets()
	last_thing_processed = /datum/pipe_network
	var/i = 1
	while(i<=pipe_networks.len)
		var/datum/pipe_network/Network = pipe_networks[i]
		if(Network)
			Network.process()
			i++
			continue
		pipe_networks.Cut(i,i+1)

datum/controller/game_controller/proc/process_powernets()
	last_thing_processed = /datum/powernet
	var/i = 1
	while(i<=powernets.len)
		var/datum/powernet/Powernet = powernets[i]
		if(Powernet)
			Powernet.reset()
			i++
			continue
		powernets.Cut(i,i+1)

datum/controller/game_controller/proc/process_nano()
	var/i = 1
	while(i<=nanomanager.processing_uis.len)
		var/datum/nanoui/ui = nanomanager.processing_uis[i]
		if(ui && ui.src_object && ui.user)
			ui.process()
			i++
			continue
		nanomanager.processing_uis.Cut(i,i+1)

datum/controller/game_controller/proc/Recover()		//Mostly a placeholder for now.
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
