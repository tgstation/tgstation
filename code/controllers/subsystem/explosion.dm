SUBSYSTEM_DEF(explosion)
	priority = 99
	wait = 1
	flags = SS_TICKER|SS_NO_INIT

	var/list/explosions

	var/rebuild_tick_split_count = FALSE
	var/tick_portions_required = 0

	var/list/logs

	var/list/zlevels_that_ignore_bombcap
	var/list/doppler_arrays

	//legacy caps, set by config
	var/devastation_cap = 3
	var/heavy_cap = 7
	var/light_cap = 14
	var/flash_cap = 14
	var/flame_cap = 14
	var/dyn_ex_scale = 0.5

	var/id_counter = 0

/datum/controller/subsystem/explosion/PreInit()
	doppler_arrays = list()
	logs = list()
	explosions = list()
	zlevels_that_ignore_bombcap = list("[ZLEVEL_MINING]")

/datum/controller/subsystem/explosion/Shutdown()
	QDEL_LIST(explosions)
	QDEL_LIST(logs)
	zlevels_that_ignore_bombcap.Cut()

/datum/controller/subsystem/explosion/Recover()
	explosions = SSexplosion.explosions
	logs = SSexplosion.logs
	id_counter = SSexplosion.id_counter
	rebuild_tick_split_count = TRUE
	zlevels_that_ignore_bombcap = SSexplosion.zlevels_that_ignore_bombcap
	doppler_arrays = SSexplosion.doppler_arrays

	devastation_cap = SSexplosion.devastation_cap
	heavy_cap = SSexplosion.heavy_cap
	light_cap = SSexplosion.light_cap
	flash_cap = SSexplosion.flash_cap
	flame_cap = SSexplosion.flame_cap
	dyn_ex_scale = SSexplosion.dyn_ex_scale

/datum/controller/subsystem/explosion/fire()    
	var/list/cached_explosions = explosions
	var/num_explosions = cached_explosions.len
	if(!num_explosions)
		return
	
	//figure exactly how many tick splits are required
	var/num_splits
	if(rebuild_tick_split_count)
		var/reactionary = config.reactionary_explosions
		num_splits = num_explosions
		for(var/I in cached_explosions)
			var/datum/explosion/E = I
			if(!E.turfs_processed)
				++num_splits
			if(reactionary && !E.densities_processed)
				++num_splits
		tick_portions_required = num_splits
	else
		num_splits = tick_portions_required

	MC_SPLIT_TICK_INIT(num_splits)

	for(var/I in cached_explosions)
		var/datum/explosion/E = I

		var/etp = E.turfs_processed
		if(!etp)
			if(GatherTurfs(E))
				--tick_portions_required
				etp = TRUE
			MC_SPLIT_TICK

		var/edp = E.densities_processed
		if(!edp)
			if(DensityCalculate(E, etp))
				--tick_portions_required
				edp = TRUE
			MC_SPLIT_TICK

		if(ProcessExplosion(E, edp)) //splits the tick
			--tick_portions_required
			explosions -= E
			logs += E
			NotifyDopplers(E)
		MC_SPLIT_TICK

/datum/controller/subsystem/explosion/proc/NotifyDopplers(datum/explosion/E)
	for(var/array in doppler_arrays)
		var/obj/machinery/doppler_array/A = array
		A.sense_explosion(E.epicenter, E.devastation, E.heavy, E.light, E.finished_at - E.started_at, E.orig_dev_range, E.orig_heavy_range, E.orig_light_range)

/datum/controller/subsystem/explosion/proc/Create(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = TRUE, ignorecap = FALSE, flame_range = 0 , silent = FALSE, smoke = FALSE)
	epicenter = get_turf(epicenter)
	if(!epicenter)
		return

	if(adminlog)
		message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in area: [get_area(epicenter)] [ADMIN_COORDJMP(epicenter)]")
		log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z])")

	var/datum/explosion/E = new(++id_counter, epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range, silent, smoke, ignorecap)

	if(heavy_impact_range > 1)
		var/datum/effect_system/explosion/Eff
		if(smoke)
			Eff = new /datum/effect_system/explosion/smoke
		else
			Eff = new
		Eff.set_up(epicenter)
		Eff.start()

	//flash mobs
	if(flash_range)
		for(var/mob/living/L in viewers(flash_range, epicenter))
			L.flash_act()

	if(!silent)
		ExplosionSound(epicenter, devastation_range, heavy_impact_range, E.extent)

	//add to SS
	if(E.extent)
		tick_portions_required += 2 + (config.reactionary_explosions ? 1 : 0)
		explosions += E
	else
		logs += E	//Already done processing

/datum/controller/subsystem/explosion/proc/CreateDynamic(atom/epicenter, power, flash_range, adminlog = TRUE, ignorecap = TRUE, flame_range = 0 , silent = FALSE, smoke = TRUE)
	if(!power)
		return
	var/range = round((2 * power) ** dyn_ex_scale)
	Create(epicenter, round(range * 0.25), round(range * 0.5), round(range), flash_range*range, adminlog, ignorecap, flame_range*range, silent, smoke)

// Using default dyn_ex scale:
// 100 explosion power is a (5, 10, 20) explosion.
// 75 explosion power is a (4, 8, 17) explosion.
// 50 explosion power is a (3, 7, 14) explosion.
// 25 explosion power is a (2, 5, 10) explosion.
// 10 explosion power is a (1, 3, 6) explosion.
// 5 explosion power is a (0, 1, 3) explosion.
// 1 explosion power is a (0, 0, 1) explosion.

/datum/explosion
	var/explosion_id
	var/turf/epicenter

	var/started_at
	var/finished_at
	var/tick_started
	var/tick_finished

	var/turfs_processed = FALSE
	var/densities_processed = FALSE

	var/orig_dev_range
	var/orig_heavy_range
	var/orig_light_range
	var/orig_flash_range
	var/orig_flame_range

	var/devastation
	var/heavy
	var/light
	var/extent

	var/flash
	var/flame

	var/gather_dist = 0

	var/list/gathered_turfs
	var/list/calculated_turfs

	var/list/unsafe_turfs

/datum/explosion/New(id, turf/epi, devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range, silent, smoke, ignorecap)
	explosion_id = id
	epicenter = epi

	densities_processed = !config.reactionary_explosions

	orig_dev_range = devastation_range
	orig_heavy_range = heavy_impact_range
	orig_light_range = light_impact_range
	orig_flash_range = flash_range
	orig_flame_range = flame_range

	if(!ignorecap && !("[epicenter.z]" in SSexplosion.zlevels_that_ignore_bombcap))
		//Clamp all values
		devastation_range = min(SSexplosion.devastation_cap, devastation_range)
		heavy_impact_range = min(SSexplosion.heavy_cap, heavy_impact_range)
		light_impact_range = min(SSexplosion.light_cap, light_impact_range)
		flash_range = min(SSexplosion.flash_cap, flash_range)
		flame_range = min(SSexplosion.flame_cap, flame_range)

	//store this
	devastation = devastation_range
	heavy = heavy_impact_range
	light = light_impact_range

	extent = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)

	flash = flash_range
	flame = flame_range

	started_at = REALTIMEOFDAY
	tick_started = world.time
	
	gathered_turfs = list()
	calculated_turfs = list()
	unsafe_turfs = list()

// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
// Stereo users will also hear the direction of the explosion!

// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
// 3/7/14 will calculate to 80 + 35
/proc/ExplosionSound(turf/epicenter, devastation_range, heavy_impact_range, extent)
	var/far_dist = 0
	far_dist += heavy_impact_range * 5
	far_dist += devastation_range * 20

	var/z0 = epicenter.z

	var/frequency = get_rand_frequency()
	var/ex_sound = get_sfx("explosion")
	for(var/mob/M in GLOB.player_list)
		// Double check for client
		var/turf/M_turf = get_turf(M)
		if(M_turf && M_turf.z == z0)
			var/dist = get_dist(M_turf, epicenter)
			// If inside the blast radius + world.view - 2
			if(dist <= round(extent + world.view - 2, 1))
				M.playsound_local(epicenter, ex_sound, 100, 1, frequency, falloff = 5)
			// You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
			else if(dist <= far_dist)
				var/far_volume = Clamp(far_dist, 30, 50) // Volume is based on explosion size and dist
				far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
				M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1, frequency, falloff = 5)

/datum/explosion/Destroy()
	SSexplosion.explosions -= src
	SSexplosion.logs -= src
	LAZYCLEARLIST(gathered_turfs)
	LAZYCLEARLIST(calculated_turfs)
	LAZYCLEARLIST(unsafe_turfs)
	return ..()

/datum/controller/subsystem/explosion/proc/GatherTurfs(datum/explosion/E)
	var/turf/epicenter = E.epicenter

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z

	var/c_dist = E.gather_dist
	var/dist = E.extent

	var/list/L = E.gathered_turfs

	if(!c_dist)
		L += epicenter
		++c_dist

	while( c_dist <= dist )
		var/y = y0 + c_dist
		var/x = x0 - c_dist + 1
		for(x in x to x0 + c_dist)
			var/turf/T = locate(x, y, z0)
			if(T)
				L += T

		y = y0 + c_dist - 1
		x = x0 + c_dist
		for(y in y0 - c_dist to y)
			var/turf/T = locate(x, y, z0)
			if(T)
				L += T

		y = y0 - c_dist
		x = x0 + c_dist - 1
		for(x in x0 - c_dist to x)
			var/turf/T = locate(x, y, z0)
			if(T)
				L += T

		y = y0 - c_dist + 1
		x = x0 - c_dist
		for(y in y to y0 + c_dist)
			var/turf/T = locate(x, y, z0)
			if(T)
				L += T
		++c_dist

		if(MC_TICK_CHECK)
			break

	if(c_dist > dist)
		E.turfs_processed = TRUE
		return TRUE
	else
		E.gather_dist = c_dist
		return FALSE

/datum/controller/subsystem/explosion/proc/DensityCalculate(datum/explosion/E, done_gathering_turfs)
	var/list/L = E.calculated_turfs
	var/cut_to = 1
	for(var/I in E.gathered_turfs) // we cache the explosion block rating of every turf in the explosion area
		var/turf/T = I
		++cut_to

		var/current_exp_block = T.density ? T.explosion_block : 0

		for(var/obj/machinery/door/D in T)
			if(D.density)
				current_exp_block += D.explosion_block

		for(var/obj/structure/window/W in T)
			if(W.reinf && W.fulltile)
				current_exp_block += W.explosion_block

		for(var/obj/structure/blob/B in T)
			current_exp_block += B.explosion_block
		
		L[T] = current_exp_block

		if(MC_TICK_CHECK)
			E.gathered_turfs.Cut(1, cut_to)
			return FALSE
	
	E.gathered_turfs.Cut()
	return done_gathering_turfs

/datum/controller/subsystem/explosion/proc/ProcessExplosion(datum/explosion/E, done_calculating_turfs)
	//cache shit for speed
	var/id = E.explosion_id

	var/list/cached_unsafe = E.unsafe_turfs
	var/list/cached_exp_block = E.calculated_turfs
	var/list/affected_turfs = cached_exp_block ? cached_exp_block : E.gathered_turfs

	var/devastation_range = E.devastation
	var/heavy_impact_range = E.heavy
	var/light_impact_range = E.light

	var/flame_range = E.flame
	var/throw_range_max = E.extent

	var/turf/epi = E.epicenter
	
	var/x0 = epi.x
	var/y0 = epi.y

	var/cut_to = 1
	for(var/TI in affected_turfs)
		var/turf/T = TI
		++cut_to

		var/init_dist = cheap_hypotenuse(T.x, T.y, x0, y0)
		var/dist = init_dist

		if(cached_exp_block)
			var/turf/Trajectory = T
			while(Trajectory != epi)
				Trajectory = get_step_towards(Trajectory, epi)
				dist += cached_exp_block[Trajectory]

		var/flame_dist = dist < flame_range
		var/throw_dist = dist

		if(dist < devastation_range)
			dist = 1
		else if(dist < heavy_impact_range)
			dist = 2
		else if(dist < light_impact_range)
			dist = 3
		else
			dist = 0

		//------- EX_ACT AND TURF FIRES -------

		if(flame_dist && prob(40) && !isspaceturf(T) && !T.density)
			new /obj/effect/hotspot(T) //Mostly for ambience!

		if(dist > 0)
			T.explosion_level = max(T.explosion_level, dist)	//let the bigger one have it
			T.explosion_id = id
			T.ex_act(dist)
			cached_unsafe += T

		//--- THROW ITEMS AROUND ---

		var/throw_dir = get_dir(epi, T)
		for(var/obj/item/I in T)
			if(!I.anchored)
				var/throw_range = rand(throw_dist, throw_range_max)
				var/turf/throw_at = get_ranged_target_turf(I, throw_dir, throw_range)
				I.throw_speed = 4 //Temporarily change their throw_speed for embedding purposes (Resets when it finishes throwing, regardless of hitting anything)
				I.throw_at(throw_at, throw_range, 4)		

		if(MC_TICK_CHECK)
			var/circumference = (PI * (init_dist + 4) * 2) //+4 to radius to prevent shit gaps
			if(cached_unsafe.len > circumference)	//only do this every revolution
				for(var/Unexplode in cached_unsafe)
					var/turf/UnexplodeT = Unexplode
					UnexplodeT.explosion_level = 0
				cached_unsafe.Cut()
			done_calculating_turfs = FALSE
			break

	affected_turfs.Cut(1, cut_to)

	if(!done_calculating_turfs)
		return FALSE

	//unfuck the shit
	for(var/Unexplode in cached_unsafe)
		var/turf/UnexplodeT = Unexplode
		UnexplodeT.explosion_level = 0
	cached_unsafe.Cut()

	E.finished_at = REALTIMEOFDAY
	E.tick_finished = world.time
	
	return TRUE

/client/proc/check_bomb_impacts()
	set name = "Check Bomb Impact"
	set category = "Debug"

	var/newmode = alert("Use reactionary explosions?","Check Bomb Impact", "Yes", "No")
	var/turf/epicenter = get_turf(mob)
	if(!epicenter)
		return

	var/x0 = epicenter.x
	var/y0 = epicenter.y

	var/dev = 0
	var/heavy = 0
	var/light = 0
	var/list/choices = list("Small Bomb","Medium Bomb","Big Bomb","Custom Bomb")
	var/choice = input("Bomb Size?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			dev = 1
			heavy = 2
			light = 3
		if("Medium Bomb")
			dev = 2
			heavy = 3
			light = 4
		if("Big Bomb")
			dev = 3
			heavy = 5
			light = 7
		if("Custom Bomb")
			dev = input("Devestation range (Tiles):") as num
			heavy = input("Heavy impact range (Tiles):") as num
			light = input("Light impact range (Tiles):") as num
		else
			return

	var/datum/explosion/E = new(null, epicenter, dev, heavy, light, ignorecap = TRUE)

	while(!SSexplosion.GatherTurfs(E))
		stoplag()
	var/list/turfs
	if(newmode)
		while(!SSexplosion.DensityCalculate(E, TRUE))
			stoplag()
		turfs = E.calculated_turfs.Copy()
	else
		turfs = E.gathered_turfs.Copy()

	qdel(E)

	for(var/I in turfs)
		var/turf/T = I
		var/dist = cheap_hypotenuse(T.x, T.y, x0, y0) + turfs[T]

		if(dist < dev)
			T.color = "red"
			T.maptext = "Dev"
		else if (dist < heavy)
			T.color = "yellow"
			T.maptext = "Heavy"
		else if (dist < light)
			T.color = "blue"
			T.maptext = "Light"
		CHECK_TICK

	sleep(100)
	for(var/I in turfs)
		var/turf/T = I
		T.color = null
		T.maptext = null
