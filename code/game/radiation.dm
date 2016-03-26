#define RAD_RANGE_DIV 	1.5
#define RADIATION_CAP	500
#define RAD_TRANSFER_PERCENTAGE	0.2

#define RAD_BARRIER_NONE 	0
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

/turf/var/radiation = 0 //radiation is removed after 'radiation_ticks_to_remove' number of ticks
/turf/var/radiation_induced = 0 //induced radiation dissipates 'RAD_DISSIPATE_AMOUNT' each tick
/turf/var/radiation_ticks_to_remove = 0
/atom/var/rad_barrier = RAD_BARRIER_NONE
/atom/proc/process_irradiate()

/turf/proc/inherit_radiation(rads, rads_induced, rads_ticks)
	radiation = rads
	radiation_induced = rads_induced
	radiation_ticks_to_remove = rads_ticks

/turf/space/inherit_radiation(rads, rads_induced, rads_ticks)
	radiation = rads
	radiation_ticks_to_remove = rads_ticks

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

/turf/proc/get_radiation()
	return radiation + radiation_induced

/atom/proc/rad_act(amount)
	return 1

/mob/living/rad_act(amount)
	if(amount)
		var/blocked = run_armor_check(null, "rad", "Your clothes feel warm.", "Your clothes feel warm.")
		apply_effect(amount, IRRADIATE, blocked)
		for(var/obj/I in src) //Radiation is also applied to items held by the mob
			I.rad_act(amount)

/turf/simulated/rad_act(amount, induced = FALSE, ticks_remove = 0)
	if(!amount || (!induced && !ticks_remove))
		return

	if(!radiation && !radiation_induced)
		SSradiation.processing |= src

	if(induced)
		radiation_induced = Clamp(radiation_induced + amount, 0, RADIATION_CAP)
	else
		radiation = Clamp(radiation + amount, 0, RADIATION_CAP)
		radiation_ticks_to_remove = ticks_remove

//induced radiation dissipates over time and accumulates to a maximum of RADIATION_CAP
/atom/proc/irradiate_induced(amount = 0, log = FALSE, signature = "\[?]")
	var/turf/epicenter = get_turf(src)
	var/rad_barrier = epicenter.rad_barrier()
	if(rad_barrier == RAD_BARRIER_IMPREGNABLE)
		return

	var/amt = amount
	if(rad_barrier)
		amt /= rad_barrier
	epicenter.rad_act(amt, TRUE)

	for(var/direction in alldirs)
		propagate_radiation(get_step(epicenter, direction), amt, direction, TRUE)

	if(log)
		var/rad_range = 0
		amt = amount
		while(amt > RAD_DISSIPATE_AMOUNT)
			amt /= RAD_RANGE_DIV
			rad_range++
		log_game("Irradiation (induced) with intensity of [amount] and estimated range of [rad_range] in area [epicenter.loc.name]\
@ ([epicenter.x],[epicenter.y],[epicenter.z]) BY [signature]. ")

//radiation from this proc does not dissipate over time and is not decreased with distance
/atom/proc/irradiate(amount = 0, ticks = 1, log = FALSE, signature = "\[?]")
	if(qdeleted(src))
		return
	var/turf/epicenter = get_turf(src)
	var/rad_barrier = epicenter.rad_barrier()
	if(rad_barrier == RAD_BARRIER_IMPREGNABLE)
		return

	var/amt = amount
	if(rad_barrier)
		amt /= rad_barrier
	epicenter.rad_act(amt, FALSE, ticks)

	for(var/direction in alldirs)
		propagate_radiation(get_step(epicenter, direction), amt, direction, FALSE, ticks)

	if(log)
		var/rad_range = 0
		amt = amount
		while(amt > RAD_DISSIPATE_AMOUNT)
			amt /= RAD_RANGE_DIV
			rad_range++
		log_game("Irradiation with intensity of [amount] and estimated range of [rad_range] in area [epicenter.loc.name]\
@ ([epicenter.x],[epicenter.y],[epicenter.z]) BY [signature]. ")

/*
	Radiation propagation procs
*/
/proc/propagate_radiation(turf/T, amount, direction, induced = FALSE, ticks_remove = 0)
	switch(direction)
		if(NORTH, SOUTH, EAST, WEST)
			propagate_radiation_cardinal(T, amount, direction, induced, ticks_remove, amount)
		if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			propagate_radiation_diagonal(T, amount, direction, induced, ticks_remove, amount)

/proc/propagate_radiation_cardinal(turf/T, amount, dir, induced = FALSE, ticks_remove = 0, amt_range = 0)
	if(!T || !amt_range || (!induced && !ticks_remove))
		return

	var/rad_barrier = T.rad_barrier()
	if(rad_barrier == RAD_BARRIER_IMPREGNABLE)
		return
	if(rad_barrier)
		amount /= rad_barrier
		amt_range /= rad_barrier
	T.rad_act(amount, induced, ticks_remove)

	amt_range /= RAD_RANGE_DIV
	amt_range = amt_range < RAD_DISSIPATE_AMOUNT ? 0 : amt_range
	if(induced)
		amount = amt_range

	propagate_radiation_cardinal(get_step(T, dir), amount, dir, induced, ticks_remove, amt_range)

/proc/propagate_radiation_diagonal(turf/T, amount, dir, induced = FALSE, ticks_remove = 0, amt_range = 0)
	if(!T || !amt_range || (!induced && !ticks_remove))
		return

	var/rad_barrier = T.rad_barrier()
	if(rad_barrier == RAD_BARRIER_IMPREGNABLE)
		return
	if(rad_barrier)
		amount /= rad_barrier
		amt_range /= rad_barrier
	T.rad_act(amount, induced, ticks_remove)

	amt_range /= RAD_RANGE_DIV
	amt_range = amt_range < RAD_DISSIPATE_AMOUNT ? 0 : amt_range
	if(induced)
		amount = amt_range

	if(dir & NORTH)
		propagate_radiation_cardinal(get_step(T, NORTH), amount / RAD_RANGE_DIV, NORTH, induced, ticks_remove, amt_range)
	else if(dir & SOUTH)
		propagate_radiation_cardinal(get_step(T, SOUTH), amount / RAD_RANGE_DIV, SOUTH, induced, ticks_remove, amt_range)
	if(dir & WEST)
		propagate_radiation_cardinal(get_step(T, WEST), amount / RAD_RANGE_DIV, WEST, induced, ticks_remove, amt_range)
	else if(dir & EAST)
		propagate_radiation_cardinal(get_step(T, EAST), amount / RAD_RANGE_DIV, EAST, induced, ticks_remove, amt_range)
	propagate_radiation_diagonal(get_step(T, dir), amount / RAD_RANGE_DIV, dir, induced, ticks_remove, amt_range)
