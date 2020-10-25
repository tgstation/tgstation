#define EXPLOSION_THROW_SPEED 4
GLOBAL_LIST_EMPTY(explosions)

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = INIT_ORDER_EXPLOSIONS
	priority = FIRE_PRIORITY_EXPLOSIONS
	wait = 1
	flags = SS_TICKER|SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cost_lowturf = 0
	var/cost_medturf = 0
	var/cost_highturf = 0
	var/cost_flameturf = 0

	var/cost_throwturf = 0

	var/cost_low_mov_atom = 0
	var/cost_med_mov_atom = 0
	var/cost_high_mov_atom = 0

	var/list/lowturf = list()
	var/list/medturf = list()
	var/list/highturf = list()
	var/list/flameturf = list()

	var/list/throwturf = list()

	var/list/low_mov_atom = list()
	var/list/med_mov_atom = list()
	var/list/high_mov_atom = list()

	var/list/explosions = list()

	var/currentpart = SSAIR_PIPENETS


/datum/controller/subsystem/explosions/stat_entry(msg)
	msg += "C:{"
	msg += "LT:[round(cost_lowturf,1)]|"
	msg += "MT:[round(cost_medturf,1)]|"
	msg += "HT:[round(cost_highturf,1)]|"
	msg += "FT:[round(cost_flameturf,1)]||"

	msg += "LO:[round(cost_low_mov_atom,1)]|"
	msg += "MO:[round(cost_med_mov_atom,1)]|"
	msg += "HO:[round(cost_high_mov_atom,1)]|"

	msg += "TO:[round(cost_throwturf,1)]"

	msg += "} "

	msg += "AMT:{"
	msg += "LT:[lowturf.len]|"
	msg += "MT:[medturf.len]|"
	msg += "HT:[highturf.len]|"
	msg += "FT:[flameturf.len]||"

	msg += "LO:[low_mov_atom.len]|"
	msg += "MO:[med_mov_atom.len]|"
	msg += "HO:[high_mov_atom.len]|"

	msg += "TO:[throwturf.len]"

	msg += "} "
	return ..()


#define SSEX_TURF "turf"
#define SSEX_OBJ "obj"

/datum/controller/subsystem/explosions/proc/is_exploding()
	return (lowturf.len || medturf.len || highturf.len || flameturf.len || throwturf.len || low_mov_atom.len || med_mov_atom.len || high_mov_atom.len)

/datum/controller/subsystem/explosions/proc/wipe_turf(turf/T)
	lowturf -= T
	medturf -= T
	highturf -= T
	flameturf -= T
	throwturf -= T

/client/proc/check_bomb_impacts()
	set name = "Check Bomb Impact"
	set category = "Debug"

	var/newmode = alert("Use reactionary explosions?","Check Bomb Impact", "Yes", "No")
	var/turf/epicenter = get_turf(mob)
	if(!epicenter)
		return

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
			dev = input("Devastation range (Tiles):") as num
			heavy = input("Heavy impact range (Tiles):") as num
			light = input("Light impact range (Tiles):") as num

	var/max_range = max(dev, heavy, light)
	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/list/wipe_colours = list()
	for(var/turf/T in spiral_range_turfs(max_range, epicenter))
		wipe_colours += T
		var/dist = cheap_hypotenuse(T.x, T.y, x0, y0)

		if(newmode == "Yes")
			var/turf/TT = T
			while(TT != epicenter)
				TT = get_step_towards(TT,epicenter)
				if(TT.density)
					dist += TT.explosion_block

				for(var/obj/O in T)
					var/the_block = O.explosion_block
					dist += the_block == EXPLOSION_BLOCK_PROC ? O.GetExplosionBlock() : the_block

		if(dist < dev)
			T.color = "red"
			T.maptext = "Dev"
		else if (dist < heavy)
			T.color = "yellow"
			T.maptext = "Heavy"
		else if (dist < light)
			T.color = "blue"
			T.maptext = "Light"
		else
			continue

	addtimer(CALLBACK(GLOBAL_PROC, .proc/wipe_color_and_text, wipe_colours), 100)

/proc/wipe_color_and_text(list/atom/wiping)
	for(var/i in wiping)
		var/atom/A = i
		A.color = null
		A.maptext = ""

/proc/dyn_explosion(turf/epicenter, power, flash_range, adminlog = TRUE, ignorecap = TRUE, flame_range = 0, silent = FALSE, smoke = TRUE)
	if(!power)
		return
	var/range = 0
	range = round((2 * power)**GLOB.DYN_EX_SCALE)
	explosion(epicenter, round(range * 0.25), round(range * 0.5), round(range), flash_range*range, adminlog, ignorecap, flame_range*range, silent, smoke)

// Using default dyn_ex scale:
// 100 explosion power is a (5, 10, 20) explosion.
// 75 explosion power is a (4, 8, 17) explosion.
// 50 explosion power is a (3, 7, 14) explosion.
// 25 explosion power is a (2, 5, 10) explosion.
// 10 explosion power is a (1, 3, 6) explosion.
// 5 explosion power is a (0, 1, 3) explosion.
// 1 explosion power is a (0, 0, 1) explosion.

/proc/explosion(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = TRUE, ignorecap = FALSE, flame_range = 0, silent = FALSE, smoke = FALSE)
	. = SSexplosions.explode(arglist(args))

#define CREAK_DELAY 5 SECONDS //Time taken for the creak to play after explosion, if applicable.
#define DEVASTATION_PROB 30 //The probability modifier for devistation, maths!
#define HEAVY_IMPACT_PROB 5 //ditto
#define FAR_UPPER 60 //Upper limit for the far_volume, distance, clamped.
#define FAR_LOWER 40 //lower limit for the far_volume, distance, clamped.
#define PROB_SOUND 75 //The probability modifier for a sound to be an echo, or a far sound. (0-100)
#define SHAKE_CLAMP 2.5 //The limit for how much the camera can shake for out of view booms.
#define FREQ_UPPER 40 //The upper limit for the randomly selected frequency.
#define FREQ_LOWER 25 //The lower of the above.

/datum/controller/subsystem/explosions/proc/explode(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog, ignorecap, flame_range, silent, smoke)
	epicenter = get_turf(epicenter)
	if(!epicenter)
		return

	if(isnull(flame_range))
		flame_range = light_impact_range
	if(isnull(flash_range))
		flash_range = devastation_range

	// Archive the uncapped explosion for the doppler array
	var/orig_dev_range = devastation_range
	var/orig_heavy_range = heavy_impact_range
	var/orig_light_range = light_impact_range

	var/orig_max_distance = max(devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range)

	//Zlevel specific bomb cap multiplier
	var/cap_multiplier = SSmapping.level_trait(epicenter.z, ZTRAIT_BOMBCAP_MULTIPLIER)
	if (isnull(cap_multiplier))
		cap_multiplier = 1

	if(!ignorecap)
		devastation_range = min(GLOB.MAX_EX_DEVESTATION_RANGE * cap_multiplier, devastation_range)
		heavy_impact_range = min(GLOB.MAX_EX_HEAVY_RANGE * cap_multiplier, heavy_impact_range)
		light_impact_range = min(GLOB.MAX_EX_LIGHT_RANGE * cap_multiplier, light_impact_range)
		flash_range = min(GLOB.MAX_EX_FLASH_RANGE * cap_multiplier, flash_range)
		flame_range = min(GLOB.MAX_EX_FLAME_RANGE * cap_multiplier, flame_range)

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)
	var/started_at = REALTIMEOFDAY
	if(adminlog)
		message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [ADMIN_VERBOSEJMP(epicenter)]")
		log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [loc_name(epicenter)]")

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z
	var/area/areatype = get_area(epicenter)
	SSblackbox.record_feedback("associative", "explosion", 1, list("dev" = devastation_range, "heavy" = heavy_impact_range, "light" = light_impact_range, "flash" = flash_range, "flame" = flame_range, "orig_dev" = orig_dev_range, "orig_heavy" = orig_heavy_range, "orig_light" = orig_light_range, "x" = x0, "y" = y0, "z" = z0, "area" = areatype.type, "time" = time_stamp("YYYY-MM-DD hh:mm:ss", 1)))

	// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
	// Stereo users will also hear the direction of the explosion!

	// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
	// 3/7/14 will calculate to 80 + 35

	var/far_dist = 0
	far_dist += heavy_impact_range * 15
	far_dist += devastation_range * 20

	if(!silent)
		var/frequency = get_rand_frequency()
		var/sound/explosion_sound = sound(get_sfx("explosion"))
		var/sound/far_explosion_sound = sound('sound/effects/explosionfar.ogg')
		var/sound/creaking_explosion_sound = sound(get_sfx("explosion_creaking"))
		var/sound/hull_creaking_sound = sound(get_sfx("hull_creaking"))
		var/sound/explosion_echo_sound = sound('sound/effects/explosion_distant.ogg')
		var/on_station = SSmapping.level_trait(epicenter.z, ZTRAIT_STATION)
		var/creaking_explosion = FALSE

		if(prob(devastation_range*DEVASTATION_PROB+heavy_impact_range*HEAVY_IMPACT_PROB) && on_station) // Huge explosions are near guaranteed to make the station creak and whine, smaller ones might.
			creaking_explosion = TRUE // prob over 100 always returns true

		for(var/MN in GLOB.player_list)
			var/mob/M = MN
			// Double check for client
			var/turf/M_turf = get_turf(M)
			if(M_turf && M_turf.z == z0)
				var/dist = get_dist(M_turf, epicenter)
				var/baseshakeamount
				if(orig_max_distance - dist > 0)
					baseshakeamount = sqrt((orig_max_distance - dist)*0.1)
				// If inside the blast radius + world.view - 2
				if(dist <= round(max_range + world.view - 2, 1))
					M.playsound_local(epicenter, null, 100, 1, frequency, S = explosion_sound)
					if(baseshakeamount > 0)
						shake_camera(M, 25, clamp(baseshakeamount, 0, 10))
				// You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
				else if(dist <= far_dist)
					var/far_volume = clamp(far_dist/2, FAR_LOWER, FAR_UPPER) // Volume is based on explosion size and dist
					if(creaking_explosion)
						M.playsound_local(epicenter, null, far_volume, 1, frequency, S = creaking_explosion_sound, distance_multiplier = 0)
					else if(prob(PROB_SOUND)) // Sound variety during meteor storm/tesloose/other bad event
						M.playsound_local(epicenter, null, far_volume, 1, frequency, S = far_explosion_sound, distance_multiplier = 0) // Far sound
					else
						M.playsound_local(epicenter, null, far_volume, 1, frequency, S = explosion_echo_sound, distance_multiplier = 0) // Echo sound

					if(baseshakeamount > 0 || devastation_range)
						if(!baseshakeamount) // Devastating explosions rock the station and ground
							baseshakeamount = devastation_range*3
						shake_camera(M, 10, clamp(baseshakeamount*0.25, 0, SHAKE_CLAMP))
				else if(!isspaceturf(get_turf(M)) && heavy_impact_range) // Big enough explosions echo throughout the hull
					var/echo_volume = 40
					if(devastation_range)
						baseshakeamount = devastation_range
						shake_camera(M, 10, clamp(baseshakeamount*0.25, 0, SHAKE_CLAMP))
						echo_volume = 60
					M.playsound_local(epicenter, null, echo_volume, 1, frequency, S = explosion_echo_sound, distance_multiplier = 0)

				if(creaking_explosion) // 5 seconds after the bang, the station begins to creak
					addtimer(CALLBACK(M, /mob/proc/playsound_local, epicenter, null, rand(FREQ_LOWER, FREQ_UPPER), 1, frequency, null, null, FALSE, hull_creaking_sound, 0), CREAK_DELAY)

	if(heavy_impact_range > 1)
		var/datum/effect_system/explosion/E
		if(smoke)
			E = new /datum/effect_system/explosion/smoke
		else
			E = new
		E.set_up(epicenter)
		E.start()

	//flash mobs
	if(flash_range)
		for(var/mob/living/L in viewers(flash_range, epicenter))
			L.flash_act()

	var/list/affected_turfs = GatherSpiralTurfs(max_range, epicenter)

	var/reactionary = CONFIG_GET(flag/reactionary_explosions)
	var/list/cached_exp_block

	if(reactionary)
		cached_exp_block = CaculateExplosionBlock(affected_turfs)

	//lists are guaranteed to contain at least 1 turf at this point

	for(var/TI in affected_turfs)
		var/turf/T = TI
		var/init_dist = cheap_hypotenuse(T.x, T.y, x0, y0)
		var/dist = init_dist

		if(reactionary)
			var/turf/Trajectory = T
			while(Trajectory != epicenter)
				Trajectory = get_step_towards(Trajectory, epicenter)
				dist += cached_exp_block[Trajectory]

		var/flame_dist = dist < flame_range
		var/throw_dist = dist

		if(dist < devastation_range)
			dist = EXPLODE_DEVASTATE
		else if(dist < heavy_impact_range)
			dist = EXPLODE_HEAVY
		else if(dist < light_impact_range)
			dist = EXPLODE_LIGHT
		else
			dist = EXPLODE_NONE

		if(T == epicenter) // Ensures explosives detonating from bags trigger other explosives in that bag
			var/list/items = list()
			for(var/I in T)
				var/atom/A = I
				if (length(A.contents) && !(A.flags_1 & PREVENT_CONTENTS_EXPLOSION_1)) //The atom/contents_explosion() proc returns null if the contents ex_acting has been handled by the atom, and TRUE if it hasn't.
					items += A.GetAllContents()
			for(var/thing in items)
				var/atom/movable/movable_thing = thing
				if(QDELETED(movable_thing))
					continue
				switch(dist)
					if(EXPLODE_DEVASTATE)
						SSexplosions.high_mov_atom += movable_thing
					if(EXPLODE_HEAVY)
						SSexplosions.med_mov_atom += movable_thing
					if(EXPLODE_LIGHT)
						SSexplosions.low_mov_atom += movable_thing
		switch(dist)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += T
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += T
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += T


		if(flame_dist && prob(40) && !isspaceturf(T) && !T.density)
			flameturf += T

		//--- THROW ITEMS AROUND ---
		var/throw_dir = get_dir(epicenter,T)
		var/throw_range = max_range-throw_dist
		var/list/throwingturf = T.explosion_throw_details
		if (throwingturf)
			if (throwingturf[1] < throw_range)
				throwingturf[1] = throw_range
				throwingturf[2] = throw_dir
				throwingturf[3] = max_range
		else
			T.explosion_throw_details = list(throw_range, throw_dir, max_range)
			throwturf += T


	var/took = (REALTIMEOFDAY - started_at) / 10

	//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes to explosion code using this please so we can compare
	if(GLOB.Debug2)
		log_world("## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds.")

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_EXPLOSION, epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)

#undef CREAK_DELAY
#undef DEVASTATION_PROB
#undef HEAVY_IMPACT_PROB
#undef FAR_UPPER
#undef FAR_LOWER
#undef PROB_SOUND
#undef SHAKE_CLAMP
#undef FREQ_UPPER
#undef FREQ_LOWER

/datum/controller/subsystem/explosions/proc/GatherSpiralTurfs(range, turf/epicenter)
	var/list/outlist = list()
	var/center = epicenter
	var/dist = range
	if(!dist)
		outlist += center
		return outlist

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return outlist

	var/list/L = outlist
	var/turf/T
	var/y
	var/x
	var/c_dist = 1
	L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++
	. = L

/datum/controller/subsystem/explosions/proc/CaculateExplosionBlock(list/affected_turfs)
	. = list()
	var/I
	for(I in 1 to affected_turfs.len) // we cache the explosion block rating of every turf in the explosion area
		var/turf/T = affected_turfs[I]
		var/current_exp_block = T.density ? T.explosion_block : 0

		for(var/obj/O in T)
			var/the_block = O.explosion_block
			current_exp_block += the_block == EXPLOSION_BLOCK_PROC ? O.GetExplosionBlock() : the_block

		.[T] = current_exp_block

/datum/controller/subsystem/explosions/fire(resumed = 0)
	if (!is_exploding())
		return
	var/timer
	Master.current_ticklimit = TICK_LIMIT_RUNNING //force using the entire tick if we need it.

	if(currentpart == SSEXPLOSIONS_TURFS)
		currentpart = SSEXPLOSIONS_MOVABLES

		timer = TICK_USAGE_REAL
		var/list/low_turf = lowturf
		lowturf = list()
		for(var/thing in low_turf)
			var/turf/turf_thing = thing
			turf_thing.explosion_level = max(turf_thing.explosion_level, EXPLODE_LIGHT)
			turf_thing.ex_act(EXPLODE_LIGHT)
		cost_lowturf = MC_AVERAGE(cost_lowturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/med_turf = medturf
		medturf = list()
		for(var/thing in med_turf)
			var/turf/turf_thing = thing
			turf_thing.explosion_level = max(turf_thing.explosion_level, EXPLODE_HEAVY)
			turf_thing.ex_act(EXPLODE_HEAVY)
		cost_medturf = MC_AVERAGE(cost_medturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/high_turf = highturf
		highturf = list()
		for(var/thing in high_turf)
			var/turf/turf_thing = thing
			turf_thing.explosion_level = max(turf_thing.explosion_level, EXPLODE_DEVASTATE)
			turf_thing.ex_act(EXPLODE_DEVASTATE)
		cost_highturf = MC_AVERAGE(cost_highturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/flame_turf = flameturf
		flameturf = list()
		for(var/thing in flame_turf)
			if(thing)
				var/turf/T = thing
				new /obj/effect/hotspot(T) //Mostly for ambience!
		cost_flameturf = MC_AVERAGE(cost_flameturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		if (low_turf.len || med_turf.len || high_turf.len)
			Master.laggy_byond_map_update_incoming()

	if(currentpart == SSEXPLOSIONS_MOVABLES)
		currentpart = SSEXPLOSIONS_THROWS

		timer = TICK_USAGE_REAL
		var/list/local_high_mov_atom = high_mov_atom
		high_mov_atom = list()
		for(var/thing in local_high_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			movable_thing.ex_act(EXPLODE_DEVASTATE)
		cost_high_mov_atom = MC_AVERAGE(cost_high_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_med_mov_atom = med_mov_atom
		med_mov_atom = list()
		for(var/thing in local_med_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			movable_thing.ex_act(EXPLODE_HEAVY)
		cost_med_mov_atom = MC_AVERAGE(cost_med_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_low_mov_atom = low_mov_atom
		low_mov_atom = list()
		for(var/thing in local_low_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			movable_thing.ex_act(EXPLODE_LIGHT)
		cost_low_mov_atom = MC_AVERAGE(cost_low_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))


	if (currentpart == SSEXPLOSIONS_THROWS)
		currentpart = SSEXPLOSIONS_TURFS
		timer = TICK_USAGE_REAL
		var/list/throw_turf = throwturf
		throwturf = list()
		for (var/thing in throw_turf)
			if (!thing)
				continue
			var/turf/T = thing
			var/list/L = T.explosion_throw_details
			T.explosion_throw_details = null
			if (length(L) != 3)
				continue
			var/throw_range = L[1]
			var/throw_dir = L[2]
			var/max_range = L[3]
			for(var/atom/movable/A in T)
				if(!A.anchored && A.move_resist != INFINITY)
					var/atom_throw_range = rand(throw_range, max_range)
					var/turf/throw_at = get_ranged_target_turf(A, throw_dir, atom_throw_range)
					A.throw_at(throw_at, atom_throw_range, EXPLOSION_THROW_SPEED, quickstart = FALSE)
		cost_throwturf = MC_AVERAGE(cost_throwturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	currentpart = SSEXPLOSIONS_TURFS
