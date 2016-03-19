#define RAD_RANGE_DIV 	1.5
#define RADIATION_CAP	500
#define RAD_TRANSFER_PERCENTAGE	0.2

#define RAD_BARRIER_NONE 	1
#define RAD_BARRIER_I 		2
#define RAD_BARRIER_II 		4
#define RAD_BARRIER_III		6
#define RAD_BARRIER_IV		8
#define RAD_BARRIER_V		10
#define RAD_BARRIER_IMPREGNABLE -1

#define RAD_LEVEL_NORMAL 5
#define RAD_LEVEL_MODERATE 20
#define RAD_LEVEL_HIGH 50
#define RAD_LEVEL_VERY_HIGH 100
#define RAD_LEVEL_CRITICAL 200

/turf/var/radiation = 0
/atom/var/rad_barrier = RAD_BARRIER_NONE

/turf/proc/inherit_radiation(amount)
	radiation = amount

/turf/space/inherit_radiation()
	return

/turf/proc/rad_barrier()
	if(rad_barrier == RAD_BARRIER_IMPREGNABLE)
		return RAD_BARRIER_IMPREGNABLE

	var/barrier_sum = rad_barrier
	for(var/V in src)
		var/atom/A = V
		if(A.rad_barrier == RAD_BARRIER_IMPREGNABLE)
			return RAD_BARRIER_IMPREGNABLE
		barrier_sum += A.rad_barrier
	return min(10, barrier_sum)

/atom/proc/irradiate(amount = 0, log = FALSE, signature = "\[?]")
	var/turf/epicenter = get_turf(src)
	var/rad_barrier = epicenter.rad_barrier()
	if(!rad_barrier)
		rad_barrier = 1
	else if(rad_barrier < 0)
		return
	var/amt = amount / rad_barrier
	epicenter.rad_act(amt)

	for(var/direction in alldirs)
		propagate_radiation(get_step(epicenter, direction), amt, direction)

	if(log)
		var/rad_range = 0
		amt = amount
		while(amt > RAD_DISSIPATE_AMOUNT)
			amt /= RAD_RANGE_DIV
			rad_range++
		log_game("Irradiation with intensity of [amount] and estimated range of [rad_range] in area [epicenter.loc.name]\
@ ([epicenter.x],[epicenter.y],[epicenter.z]) BY [signature]. ")

/atom/proc/rad_act(amount)
	return 1

/mob/living/rad_act(amount)
	if(amount)
		var/blocked = run_armor_check(null, "rad", "Your clothes feel warm.", "Your clothes feel warm.")
		apply_effect(amount, IRRADIATE, blocked)
		for(var/obj/I in src) //Radiation is also applied to items held by the mob
			I.rad_act(amount)

/turf/simulated/rad_act(amount)
	if(!radiation)
		radiation = Clamp(radiation + amount, 0, RADIATION_CAP)
		SSradiation.processing |= src
	else
		radiation = Clamp(radiation + amount, 0, RADIATION_CAP)

/*
	Radiation propagation procs
*/

/proc/propagate_radiation(turf/T, amount, direction)
	switch(direction)
		if(NORTH, SOUTH, EAST, WEST)
			propagate_radiation_cardinal(T, amount, direction)
		if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			propagate_radiation_diagonal(T, amount, direction)

/proc/propagate_radiation_cardinal(turf/T, amount, dir)
	if(!T || (amount < RAD_DISSIPATE_AMOUNT))
		return

	var/rad_barrier = T.rad_barrier()
	if(rad_barrier == RAD_BARRIER_IMPREGNABLE)
		return
	if(rad_barrier)
		amount /= rad_barrier
	T.rad_act(amount)

	propagate_radiation_cardinal(get_step(T, dir), amount / RAD_RANGE_DIV, dir)

/proc/propagate_radiation_diagonal(turf/T, amount, dir)
	if(!T || (amount < RAD_DISSIPATE_AMOUNT))
		return

	var/rad_barrier = T.rad_barrier()
	if(rad_barrier == RAD_BARRIER_IMPREGNABLE)
		return
	if(rad_barrier)
		amount /= rad_barrier
	T.rad_act(amount)

	if(dir & NORTH)
		propagate_radiation_cardinal(get_step(T, NORTH), amount / RAD_RANGE_DIV, NORTH)
	else if(dir & SOUTH)
		propagate_radiation_cardinal(get_step(T, SOUTH), amount / RAD_RANGE_DIV, SOUTH)
	if(dir & WEST)
		propagate_radiation_cardinal(get_step(T, WEST), amount / RAD_RANGE_DIV, WEST)
	else if(dir & EAST)
		propagate_radiation_cardinal(get_step(T, EAST), amount / RAD_RANGE_DIV, EAST)
	propagate_radiation_diagonal(get_step(T, dir), amount / RAD_RANGE_DIV, dir)
