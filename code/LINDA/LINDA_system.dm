var/kill_air = 0

var/global/datum/controller/air_system/air_master

datum/controller/air_system
	var/list/excited_groups = list()
	var/list/active_turfs = list()
	var/list/hotspots = list()
	var/speed = 1

	//Special functions lists
	var/list/turf/simulated/active_super_conductivity = list()
	var/list/turf/simulated/high_pressure_delta = list()

	var/current_cycle = 0


/datum/controller/air_system/proc/setup()
	set background = 1
	world << "\red \b Processing Geometry..."
	sleep(1)

	var/start_time = world.timeofday

	setup_allturfs()

	global_activeturfs = active_turfs.len

	world << "\red \b Geometry processed in [(world.timeofday-start_time)/10] seconds!"

/datum/controller/air_system/proc/process()
	if(kill_air)
		return 1

	for(var/i=0,i<speed,i++)
		current_cycle++

		process_active_turfs()
		process_excited_groups()
		process_high_pressure_delta()
		process_hotspots()
		process_super_conductivity()
	return 1

/datum/controller/air_system/proc/process_hotspots()
	for(var/obj/effect/hotspot/H in hotspots)
		H.process()

/datum/controller/air_system/proc/process_super_conductivity()
	for(var/turf/simulated/T in active_super_conductivity)
		T.super_conduct()

/datum/controller/air_system/proc/process_high_pressure_delta()
	for(var/turf/T in high_pressure_delta)
		T.high_pressure_movements()
		T.pressure_difference = 0
	high_pressure_delta.len = 0

/datum/controller/air_system/proc/process_active_turfs()
	for(var/turf/simulated/T in active_turfs)
		T.process_cell()

/datum/controller/air_system/proc/remove_from_active(var/turf/simulated/T)
	if(istype(T))
		T.excited = 0
		active_turfs -= T
		if(T.excited_group)
			T.excited_group.garbage_collect()

/datum/controller/air_system/proc/add_to_active(var/turf/simulated/T, var/blockchanges = 1)
	if(istype(T) && T.air)
		T.excited = 1
		active_turfs |= T
		if(blockchanges && T.excited_group)
			T.excited_group.garbage_collect()
	else
		for(var/direction in cardinal)
			if(!(T.atmos_adjacent_turfs & direction))
				continue
			var/turf/simulated/S = get_step(T, direction)
			if(istype(S))
				air_master.add_to_active(S)

/datum/controller/air_system/proc/setup_allturfs()
	for(var/turf/simulated/T in world)
		T.CalculateAdjacentTurfs()
		if(!T.blocks_air)
			if(T.air.check_tile_graphic())
				T.update_visuals(T.air)
			for(var/direction in cardinal)
				if(!(T.atmos_adjacent_turfs & direction))
					continue
				var/turf/enemy_tile = get_step(T, direction)
				if(istype(enemy_tile,/turf/simulated/))
					var/turf/simulated/enemy_simulated = enemy_tile
					if(!T.air.compare(enemy_simulated.air))
						T.excited = 1
						active_turfs |= T
						break
				else
					if(!T.air.check_turf(enemy_tile))
						T.excited = 1
						active_turfs |= T

/datum/controller/air_system/proc/process_excited_groups()
	for(var/datum/excited_group/EG in excited_groups)
		if(EG.breakdown)
			EG.breakdown_cooldown ++
		else
			EG.breakdown_cooldown = 0

		if(EG.breakdown_cooldown > 10)
			if(EG.self_compare())
				EG.dismantle()
		if(EG.breakdown_cooldown == 10)
			if(!EG.self_compare())
				EG.reset_cooldowns()
			EG.self_breakdown()
		EG.breakdown = 1

/turf/proc/CanAtmosPass(var/turf/T)
	if(!istype(T))	return 0
	var/R
	if(blocks_air || T.blocks_air)
		R = 1

	for(var/obj/O in contents)
		if(!O.CanAtmosPass(T))
			R = 1
			if(O.BlockSuperconductivity()) 	//the direction and open/closed are already checked on CanAtmosPass() so there are no arguments
				var/D = get_dir(src, T)
				atmos_supeconductivity |= D
				D = get_dir(T, src)
				T.atmos_supeconductivity |= D
				return 0						//no need to keep going, we got all we asked

	for(var/obj/O in T.contents)
		if(!O.CanAtmosPass(src))
			R = 1
			if(O.BlockSuperconductivity())
				var/D = get_dir(src, T)
				atmos_supeconductivity |= D
				D = get_dir(T, src)
				T.atmos_supeconductivity |= D
				return 0

	var/D = get_dir(src, T)
	atmos_supeconductivity &= ~D
	D = get_dir(T, src)
	T.atmos_supeconductivity &= ~D

	if(!R)
		return 1

atom/movable/proc/CanAtmosPass()
	return 1

atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return (!density || !height || air_group)

turf/CanPass(atom/movable/mover, turf/target, height=1.5,air_group=0)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(!obstacle.CanPass(mover, target, height, air_group))
				return 0
		for(var/obj/obstacle in target)
			if(!obstacle.CanPass(mover, src, height, air_group))
				return 0

		return 1

/atom/movable/proc/BlockSuperconductivity() // objects that block air and don't let superconductivity act. Only firelocks atm.
	return 0

/turf/proc/CalculateAdjacentTurfs()
	atmos_adjacent_turfs_amount = 0
	for(var/direction in cardinal)
		var/turf/T = get_step(src, direction)
		if(!istype(T))
			continue
		var/counterdir = get_dir(T, src)
		if(CanAtmosPass(T))
			atmos_adjacent_turfs_amount += 1
			atmos_adjacent_turfs |= direction
			if(!(T.atmos_adjacent_turfs & counterdir))
				T.atmos_adjacent_turfs_amount += 1
			T.atmos_adjacent_turfs |= counterdir
		else
			atmos_adjacent_turfs &= ~direction
			if(T.atmos_adjacent_turfs & counterdir)
				T.atmos_adjacent_turfs_amount -= 1
			T.atmos_adjacent_turfs &= ~counterdir

/atom/movable/proc/air_update_turf(var/command = 0)
	if(istype(loc,/turf))
		for(var/turf/T in locs) // used by double wide doors and other nonexistant multitile structures
			if(command)
				T.CalculateAdjacentTurfs()
			if(air_master)
				air_master.add_to_active(T,command)



/atom/movable/proc/atmos_spawn_air(var/text, var/amount) //because a lot of people loves to copy paste awful code lets just make a easy proc to spawn your plasma fires
	var/turf/simulated/T = get_turf(src)
	if(!istype(T))
		return
	T.atmos_spawn_air(text, amount)

var/const/SPAWN_HEAT = 1

var/const/SPAWN_TOXINS = 4
var/const/SPAWN_OXYGEN = 8
var/const/SPAWN_CO2 = 16
var/const/SPAWN_NITROGEN = 32

var/const/SPAWN_N2O = 64

var/const/SPAWN_AIR = 256

/turf/simulated/proc/atmos_spawn_air(var/flag, var/amount)
	if(!text || !amount || !air)
		return

	var/datum/gas_mixture/G = new

	if(flag & SPAWN_HEAT)
		G.temperature += 1000

	if(flag & SPAWN_TOXINS)
		G.toxins += amount
	if(flag & SPAWN_OXYGEN)
		G.oxygen += amount
	if(flag & SPAWN_CO2)
		G.carbon_dioxide += amount
	if(flag & SPAWN_NITROGEN)
		G.nitrogen += amount

	if(flag & SPAWN_N2O)
		var/datum/gas/sleeping_agent/T = new
		T.moles += amount
		G.trace_gases += T

	if(flag & SPAWN_AIR)
		G.oxygen += MOLES_O2STANDARD * amount
		G.nitrogen += MOLES_N2STANDARD * amount

	air.merge(G)
	air_master.add_to_active(src, 0)