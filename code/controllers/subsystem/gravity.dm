var/datum/subsystem/gravity/SSgravity

/datum/subsystem/gravity
	name = "Gravity"
	priority = 75
	wait = 1
	can_fire = FALSE
	flags = SS_KEEP_TIMING | SS_BACKGROUND

	var/list/currentrun = list()
	var/list/processing = list()

	//Only keeps track of station/Z1.
	var/gravity_direction = FALSE	//FALSE for normal, and cardinals.
	var/gravity_strength = 1
	var/calculation_timer = 0
	var/calculation_interval = 100
	var/throwing = FALSE
	var/recalculation_tick_cost = 0
	var/gravstun = TRUE
	var/gravstun_amount = 10

/datum/subsystem/gravity/New()
	NEW_SS_GLOBAL(SSgravity)

/datum/subsystem/gravity/Initialize()
	recalculate_atoms()

/datum/subsystem/gravity/proc/set_gravity_direction(dir)
	can_fire = FALSE
	if(!dir)
		gravity_direction = FALSE
		processing = list()
		currentrun = list()
		return
	gravity_direction = dir
	recalculate_atoms()
	if(gravstun)
		stun_all_mobs()
	can_fire = TRUE
	throw_everything()

/datum/subsystem/gravity/proc/stun_all_mobs()
	for(var/mob/living/carbon/C in processing)
		if(C.z == 1)
			C.Weaken(gravstun_amount)

/datum/subsystem/gravity/proc/recalculate_atoms()
	processing = list()
	var/before = world.time
	for(var/atom/movable/A in world)
		if(A.z == 1)
			processing += A
		CHECK_TICK
	currentrun = processing.Copy()
	recalculation_tick_cost = (world.time - before)
	world << "<span class='userdanger'>DEBUG: RECALCULATION TOOK [recalculation_tick_cost] TICKS!</span>"

/datum/subsystem/gravity/proc/throw_everything()
	throwing = TRUE
	currentrun = processing.Copy()
	fire(TRUE)

/datum/subsystem/gravity/fire(resumed = FALSE)
	calculation_timer++
	if(calculation_timer >= calculation_interval)
		calculation_timer = 0
		recalculate_atoms()
	if(!gravity_direction)	//Not needed
		can_fire = FALSE
		return
	if(!resumed)
		src.currentrun = processing.Copy()
		throwing = FALSE
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/atom/movable/A = currentrun[currentrun.len]
		currentrun.len--
		if(A)
			if(A.anchored)
				continue
			if(!throwing)
				for(var/i = 0, i < gravity_strength, i++)
					A.gravity_act(gravity_direction, gravity_strength)
			else
				A.gravity_act(gravity_direction, gravity_strength, TRUE)
		else
			processing -= A
		if(MC_TICK_CHECK)
			return
