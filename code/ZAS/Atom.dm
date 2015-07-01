/atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	//Purpose: Determines if the object (or airflow) can pass this atom.
	//Called by: Movement, airflow.
	//Inputs: The moving atom (optional), target turf, "height" and air group
	//Outputs: Boolean if can pass.

	return (!density || !height || air_group)

atom/movable/var/pressure_resistance = 5


/turf/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(!obstacle.CanPass(mover, target, height, air_group))
				return 0
		if(target != src)
			for(var/obj/obstacle in target)
				if(!obstacle.CanPass(mover, src, height, air_group))
					return 0

		return 1


/atom/movable/proc/move_update_air(var/turf/T)
    if(istype(T,/turf))
        T.air_update_turf(1)
    air_update_turf(1)

/atom/proc/air_update_turf(command)
	var/turf/T = get_turf(src)
	T.air_update_turf(command)

/turf/air_update_turf(command)
	if(!SSair)
		return
	atmos_update()
	return 1

/turf/proc/atmos_update()
	SSair.mark_for_update(src)

/turf/proc/update_air()
	update_air_properties()
	post_update_air_properties()
//Basically another way of calling CanPass(null, other, 0, 0) and CanPass(null, other, 1.5, 1).
//Returns:
// 0 - Not blocked
// AIR_BLOCKED - Blocked
// ZONE_BLOCKED - Not blocked, but zone boundaries will not cross.
// BLOCKED - Blocked, zone boundaries will not cross even if opened.
atom/proc/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif
	return !CanPass(null, other, 0, 0) + 2*!CanPass(null, other, 1.5, 1)


turf/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif
	if(blocks_air)
		return BLOCKED

	//Z-level handling code. Always block if there isn't an open space.
	#ifdef ZLEVELS
	if(other.z != src.z)
		if(other.z < src.z)
			if(!istype(src, /turf/simulated/floor/open)) return BLOCKED
		else
			if(!istype(other, /turf/simulated/floor/open)) return BLOCKED
	#endif

	var/result = 0
	for(var/atom/movable/M in contents)
		result |= M.c_airblock(other)
		if(result == BLOCKED) return BLOCKED
	return result



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
	air.update_values()
	SSair.mark_for_update(src)