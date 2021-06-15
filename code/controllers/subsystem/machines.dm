SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = INIT_ORDER_MACHINES
	flags = SS_KEEP_TIMING
	wait = 2 SECONDS
	var/list/processing = list()
	var/list/currentrun = list()
	var/list/powernets = list()

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	return ..()

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in GLOB.cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/stat_entry(msg)
	msg = "M:[length(processing)]|PN:[length(powernets)]"
	return ..()

/datum/controller/subsystem/machines/fire(resumed = FALSE)
	if (!resumed)
		for(var/datum/powernet/Powernet as anything in powernets)
			Powernet.reset() //reset the power state.
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/machinery/thing = currentrun[currentrun.len]
		currentrun.len--
		if(!QDELETED(thing) && thing.process(wait * 0.1) != PROCESS_KILL)
			if(thing.use_power)
				thing.auto_use_power() //add back the power state
		else
			processing -= thing
			if (!QDELETED(thing))
				thing.datum_flags &= ~DF_ISPROCESSING
		if (MC_TICK_CHECK)
			return

/proc/benchmark(loop_length = 500000)
	var/list/random_numbers = list()

	for(var/i in 1 to loop_length)
		random_numbers += rand(0, 10)

	var/max1 = rand(1, 4)
	var/min1 = -1
	var/max2 = rand(4.1, 9)
	var/min2 = rand(0, 4)

	CHECK_TICK

	var/ecksdee

	var/start = TICK_USAGE

	for(var/val in random_numbers)
		if(max2 != -1 && val >= max2)
			ecksdee = val
			continue

		if(min2 != -1 && val <= min2)
			ecksdee = val
			continue

		if(max1 != -1 && val >= max1)
			ecksdee = val
			continue

		if(min1 != -1 && val <= min1)
			ecksdee = val
			continue

	message_admins("two checks per if took [TICK_USAGE_TO_MS(start)] milliseconds!")

	CHECK_TICK

	start = TICK_USAGE

	for(var/val in random_numbers)
		switch(val)
			if(max2 to INFINITY)
				ecksdee = val
				continue
			if(0 to min2)
				ecksdee = val
				continue

			if(max1 to INFINITY)
				ecksdee = val
				continue
			if(0 to min1)
				ecksdee = val
				continue

	message_admins("switch statement without checking for -1 took [TICK_USAGE_TO_MS(start)] milliseconds!")

	CHECK_TICK

	start = TICK_USAGE

	for(var/val in random_numbers)
		ecksdee = (2*((max2 != -1)&(val >= max2) | (min2 != -1)&(val <= min2))) | ((max1 != -1)&(val >= max1) | (min1 != -1)&(val >= min1))

	message_admins("branchless testing took [TICK_USAGE_TO_MS(start)] milliseconds!")

	CHECK_TICK

	start = TICK_USAGE

	for(var/val in random_numbers)
		if((max2 != -1)&(val >= max2) | (min2 != -1)&(val <= min2))
			ecksdee = val
			continue

		if((max1 != -1)&(val >= max1) | (min1 != -1)&(val >= min1))
			ecksdee = val
			continue

	message_admins("two branches took [TICK_USAGE_TO_MS(start)] milliseconds!")

	CHECK_TICK

	start = TICK_USAGE

	for(var/val in random_numbers)
		switch(val)
			if(max2 to INFINITY)
				if(max2 != -1)
					ecksdee = val
					continue
			if(0 to min2)
				if(min2 != -1)
					ecksdee = val
					continue

			if(max1 to INFINITY)
				if(max1 != -1)
					ecksdee = val
					continue
			if(0 to min1)
				if(min1 != -1)
					ecksdee = val
					continue

	message_admins("switch statement and checking for -1 took [TICK_USAGE_TO_MS(start)] milliseconds!")

	CHECK_TICK

	start = TICK_USAGE

	for(var/val in random_numbers)
		if(max2 != -1 & val >= max2)
			ecksdee = val
			continue

		if(min2 != -1 & val <= min2)
			ecksdee = val
			continue

		if(max1 != -1 & val >= max1)
			ecksdee = val
			continue

		if(min1 != -1 & val <= min1)
			ecksdee = val
			continue

	message_admins("bitwise AND ifs took [TICK_USAGE_TO_MS(start)] milliseconds!")

	CHECK_TICK

	start = TICK_USAGE

	for(var/val in random_numbers)
		if(val >= max2)
			ecksdee = val
			continue

		if(val <= min2)
			ecksdee = val
			continue

		if(val >= max1)
			ecksdee = val
			continue

		if(val <= min1)
			ecksdee = val
			continue

	message_admins("one check per if took [TICK_USAGE_TO_MS(start)] milliseconds!")

/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	var/obj/structure/cable/PC
	for(var/A in 1 to cables.len)
		PC = cables[A]
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/Recover()
	if (istype(SSmachines.processing))
		processing = SSmachines.processing
	if (istype(SSmachines.powernets))
		powernets = SSmachines.powernets
