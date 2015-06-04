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

/atom/movable/proc/CanAtmosPass()
	return 1

/atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5)
	return (!density || !height)

/turf/CanPass(atom/movable/mover, turf/target, height=1.5)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(!obstacle.CanPass(mover, target, height))
				return 0
		for(var/obj/obstacle in target)
			if(!obstacle.CanPass(mover, src, height))
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
	if(!istype(loc,/turf) && command)
		return
	var/turf/T = get_turf(loc)
	T.air_update_turf(command)

/turf/proc/air_update_turf(var/command = 0)
	if(command)
		CalculateAdjacentTurfs()
	SSair.add_to_active(src,command)

/atom/movable/proc/move_update_air(var/turf/T)
    if(istype(T,/turf))
        T.air_update_turf(1)
    air_update_turf(1)

/atom/movable/proc/atmos_spawn_air(var/text, var/amount) //because a lot of people loves to copy paste awful code lets just make a easy proc to spawn your plasma fires
	var/turf/simulated/T = get_turf(src)
	if(!istype(T))
		return
	T.atmos_spawn_air(text, amount)

var/const/SPAWN_HEAT = 1
var/const/SPAWN_20C = 2
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

	if(flag & SPAWN_20C)
		G.temperature = T20C

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
	SSair.add_to_active(src, 0)