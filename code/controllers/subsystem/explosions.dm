#define EXPLOSION_THROW_SPEED 4
#define EXPLOSION_BLOCK_LIGHT 2.5
#define EXPLOSION_BLOCK_HEAVY 1.5
#define EXPLOSION_BLOCK_DEV 1

GLOBAL_LIST_EMPTY(explosions)

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
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

	/// List of turfs to throw the contents of
	var/list/throwturf = list()
	/// List of turfs to throw the contents of... AFTER the next explosion processes
	/// This avoids order of operations errors and shit
	var/list/held_throwturf = list()

	var/list/low_mov_atom = list()
	var/list/med_mov_atom = list()
	var/list/high_mov_atom = list()

	// Track how many explosions have happened.
	var/explosion_index = 0

	var/currentpart = SSEXPLOSIONS_TURFS


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
	msg += "HTO:[held_throwturf.len]"

	msg += "} "
	return ..()

/datum/controller/subsystem/explosions/proc/is_exploding()
	return (lowturf.len || medturf.len || highturf.len || flameturf.len || throwturf.len || held_throwturf.len || low_mov_atom.len || med_mov_atom.len || high_mov_atom.len)

/datum/controller/subsystem/explosions/proc/wipe_turf(turf/T)
	lowturf -= T
	medturf -= T
	highturf -= T
	flameturf -= T
	throwturf -= T
	held_throwturf -= T

ADMIN_VERB(check_bomb_impacts, R_DEBUG, "Check Bomb Impact", "See what the effect of a bomb would be.", ADMIN_CATEGORY_DEBUG)
	var/newmode = tgui_alert(user, "Use reactionary explosions?","Check Bomb Impact", list("Yes", "No"))
	var/turf/epicenter = get_turf(user.mob)
	if(!epicenter)
		return

	var/dev = 0
	var/heavy = 0
	var/light = 0
	var/list/choices = list("Small Bomb","Medium Bomb","Big Bomb","Custom Bomb")
	var/choice = tgui_input_list(user, "Pick the bomb size", "Bomb Size?", choices)
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
			dev = input(user, "Devastation range (Tiles):") as num
			heavy = input(user, "Heavy impact range (Tiles):") as num
			light = input(user, "Light impact range (Tiles):") as num

	var/max_range = max(dev, heavy, light)
	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/list/wipe_colours = list()
	var/list/cached_exp_block = list()
	for(var/turf/explode in prepare_explosion_turfs(max_range, epicenter))
		wipe_colours += explode
		var/our_x = explode.x
		var/our_y = explode.y
		var/dist = CHEAP_HYPOTENUSE(our_x, our_y, x0, y0)
		var/block = 0

		if(newmode == "Yes")
			if(explode != epicenter)
				var/our_block = cached_exp_block[get_step_towards(explode, epicenter)]
				block += our_block
				cached_exp_block[explode] = our_block + explode.explosive_resistance
			else
				cached_exp_block[explode] = explode.explosive_resistance

		dist = round(dist, 0.01)
		if(dist + (block * EXPLOSION_BLOCK_DEV) < dev)
			explode.color = "red"
			explode.maptext = MAPTEXT("[dist]")
		else if (dist + (block * EXPLOSION_BLOCK_HEAVY) < heavy)
			explode.color = "yellow"
			explode.maptext = MAPTEXT("[dist + (block * EXPLOSION_BLOCK_HEAVY)]")
		else if (dist + (block * EXPLOSION_BLOCK_LIGHT) < light)
			explode.color = "blue"
			explode.maptext = MAPTEXT("[dist + (block * EXPLOSION_BLOCK_LIGHT)]")
		else
			continue

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(wipe_color_and_text), wipe_colours), 10 SECONDS)

/proc/wipe_color_and_text(list/atom/wiping)
	for(var/i in wiping)
		var/atom/A = i
		A.color = null
		A.maptext = ""

/**
 * Using default dyn_ex scale:
 *
 * 100 explosion power is a (5, 10, 20) explosion.
 * 75 explosion power is a (4, 8, 17) explosion.
 * 50 explosion power is a (3, 7, 14) explosion.
 * 25 explosion power is a (2, 5, 10) explosion.
 * 10 explosion power is a (1, 3, 6) explosion.
 * 5 explosion power is a (0, 1, 3) explosion.
 * 1 explosion power is a (0, 0, 1) explosion.
 *
 * Arguments:
 * * epicenter: Turf the explosion is centered at.
 * * power - Dyn explosion power. See reference above.
 * * flame_range: Flame range. Equal to the equivalent of the light impact range multiplied by this value.
 * * flash_range: The range at which the explosion flashes people. Equal to the equivalent of the light impact range multiplied by this value.
 * * adminlog: Whether to log the explosion/report it to the administration.
 * * ignorecap: Whether to ignore the relevant bombcap. Defaults to FALSE.
 * * flame_range: The range at which the explosion should produce hotspots.
 * * silent: Whether to generate/execute sound effects.
 * * smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * * explosion_cause: [Optional] The atom that caused the explosion, when different to the origin. Used for logging.
 */
/proc/dyn_explosion(turf/epicenter, power, flame_range = 0, flash_range = null, adminlog = TRUE, ignorecap = TRUE, silent = FALSE, smoke = TRUE, atom/explosion_cause = null)
	if(!power)
		return
	var/range = 0
	range = round((2 * power)**GLOB.DYN_EX_SCALE)
	explosion(epicenter, devastation_range = round(range * 0.25), heavy_impact_range = round(range * 0.5), light_impact_range = round(range), flame_range = flame_range*range, flash_range = flash_range*range, adminlog = adminlog, ignorecap = ignorecap, silent = silent, smoke = smoke, explosion_cause = explosion_cause)



/**
 * Makes a given atom explode.
 *
 * Arguments:
 * - [origin][/atom]: The atom that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to FALSE.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * - protect_epicenter: Whether to leave the epicenter turf unaffected by the explosion
 * - explosion_cause: [Optional] The atom that caused the explosion, when different to the origin. Used for logging.
 * - explosion_direction: The angle in which the explosion is pointed (for directional explosions.)
 * - explosion_arc: The angle of the arc covered by a directional explosion (if 360 the explosion is non-directional.)
 */
/proc/explosion(atom/origin, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = null, flash_range = null, adminlog = TRUE, ignorecap = FALSE, silent = FALSE, smoke = FALSE, protect_epicenter = FALSE, atom/explosion_cause = null, explosion_direction = 0, explosion_arc = 360)
	. = SSexplosions.explode(arglist(args))


/**
 * Makes a given atom explode. Now on the explosions subsystem!
 *
 * Arguments:
 * - [origin][/atom]: The atom that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to FALSE.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * - protect_epicenter: Whether to leave the epicenter turf unaffected by the explosion
 * - explosion_cause: [Optional] The atom that caused the explosion, when different to the origin. Used for logging.
 * - explosion_direction: The angle in which the explosion is pointed (for directional explosions.)
 * - explosion_arc: The angle of the arc covered by a directional explosion (if 360 the explosion is non-directional.)
 */
/datum/controller/subsystem/explosions/proc/explode(atom/origin, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = null, flash_range = null, adminlog = TRUE, ignorecap = FALSE, silent = FALSE, smoke = FALSE, protect_epicenter = FALSE, atom/explosion_cause = null, explosion_direction = 0, explosion_arc = 360)
	var/list/arguments = list(
		EXARG_KEY_ORIGIN = origin,
		EXARG_KEY_DEV_RANGE = devastation_range,
		EXARG_KEY_HEAVY_RANGE = heavy_impact_range,
		EXARG_KEY_LIGHT_RANGE = light_impact_range,
		EXARG_KEY_FLAME_RANGE = flame_range,
		EXARG_KEY_FLASH_RANGE = flash_range,
		EXARG_KEY_ADMIN_LOG = adminlog,
		EXARG_KEY_IGNORE_CAP = ignorecap,
		EXARG_KEY_SILENT = silent,
		EXARG_KEY_SMOKE = smoke,
		EXARG_KEY_PROTECT_EPICENTER = protect_epicenter,
		EXARG_KEY_EXPLOSION_CAUSE = explosion_cause ? explosion_cause : origin,
		EXARG_KEY_EXPLOSION_DIRECTION = explosion_direction,
		EXARG_KEY_EXPLOSION_ARC = explosion_arc,
	)
	var/atom/location = isturf(origin) ? origin : origin.loc
	if(SEND_SIGNAL(origin, COMSIG_ATOM_EXPLODE, arguments) & COMSIG_CANCEL_EXPLOSION)
		return // Signals are incompatible with `arglist(...)` so we can't actually use that for these. Additionally,

	while(location)
		var/next_loc = location.loc
		if(SEND_SIGNAL(location, COMSIG_ATOM_INTERNAL_EXPLOSION, arguments) & COMSIG_CANCEL_EXPLOSION)
			return
		if(isturf(location))
			break
		location = next_loc

	if(!location)
		return

	var/area/epicenter_area = get_area(location)
	if(SEND_SIGNAL(epicenter_area, COMSIG_AREA_INTERNAL_EXPLOSION, arguments) & COMSIG_CANCEL_EXPLOSION)
		return

	arguments -= EXARG_KEY_ORIGIN

	propagate_blastwave(arglist(list(location) + arguments))

/**
 * Handles the effects of an explosion originating from a given point.
 *
 * Primarily handles popagating the blastwave of the explosion to the relevant turfs.
 * Also handles the fireball from the explosion.
 * Also handles the smoke cloud from the explosion.
 * Also handles sfx and screenshake.
 *
 * Arguments:
 * - [epicenter][/atom]: The location of the explosion rounded to the nearest turf.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to TRUE for some mysterious reason.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * - protect_epicenter: Whether to leave the epicenter turf unaffected by the explosion
 * - explosion_cause: [Optional] The atom that caused the explosion, when different to the origin. Used for logging.
 * - explosion_direction: The angle in which the explosion is pointed (for directional explosions.)
 * - explosion_arc: The angle of the arc covered by a directional explosion (if 360 the explosion is non-directional.)
 */
/datum/controller/subsystem/explosions/proc/propagate_blastwave(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range, adminlog, ignorecap, silent, smoke, protect_epicenter, atom/explosion_cause, explosion_direction, explosion_arc)
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

	var/orig_max_distance = max(devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range)

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

	// Now begins a bit of a logic train to find out whodunnit.
	var/who_did_it = "N/A"
	var/who_did_it_game_log = "N/A"

	// Projectiles have special handling. They rely on a firer var and not fingerprints. Check special cases for firer being
	// mecha, mob or an object such as the gun itself. Handle each uniquely.
	if(isprojectile(explosion_cause))
		var/obj/projectile/fired_projectile = explosion_cause
		if(ismecha(fired_projectile.firer))
			var/obj/vehicle/sealed/mecha/firing_mecha = fired_projectile.firer
			var/list/mob/drivers = firing_mecha.return_occupants()
			if(length(drivers))
				who_did_it = "\[Mecha drivers:"
				who_did_it_game_log = "\[Mecha drivers:"
				for(var/mob/driver in drivers)
					who_did_it += " [ADMIN_LOOKUPFLW(driver)]"
					who_did_it_game_log = " [key_name(driver)]"
				who_did_it += "\]"
				who_did_it_game_log += "\]"
		else if(ismob(fired_projectile.firer))
			who_did_it = "\[Projectile firer: [ADMIN_LOOKUPFLW(fired_projectile.firer)]\]"
			who_did_it_game_log = "\[Projectile firer: [key_name(fired_projectile.firer)]\]"
		else
			who_did_it = "\[Projectile firer: [ADMIN_LOOKUPFLW(fired_projectile.firer?.fingerprintslast)]\]"
			who_did_it_game_log = "\[Projectile firer: [key_name(fired_projectile.firer.fingerprintslast)]\]"
	// Otherwise if the explosion cause is an atom, try get the fingerprints.
	else if(istype(explosion_cause))
		who_did_it = ADMIN_LOOKUPFLW(explosion_cause.fingerprintslast)
		who_did_it_game_log = key_name(explosion_cause.fingerprintslast)

	if(adminlog)
		message_admins("Explosion with size (Devast: [devastation_range], Heavy: [heavy_impact_range], Light: [light_impact_range], Flame: [flame_range]) in [ADMIN_VERBOSEJMP(epicenter)]. Possible cause: [explosion_cause]. Last fingerprints: [who_did_it].")
		log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [loc_name(epicenter)].  Possible cause: [explosion_cause]. Last fingerprints: [who_did_it_game_log].")

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z
	var/area/areatype = get_area(epicenter)
	SSblackbox.record_feedback("associative", "explosion", 1, list("dev" = devastation_range, "heavy" = heavy_impact_range, "light" = light_impact_range, "flame" = flame_range, "flash" = flash_range, "orig_dev" = orig_dev_range, "orig_heavy" = orig_heavy_range, "orig_light" = orig_light_range, "x" = x0, "y" = y0, "z" = z0, "area" = areatype.type, "time" = time_stamp("YYYY-MM-DD hh:mm:ss", 1), "possible_cause" = explosion_cause, "possible_suspect" = who_did_it_game_log))

	// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
	// Stereo users will also hear the direction of the explosion!

	// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
	// 3/7/14 will calculate to 80 + 35

	var/far_dist = 0
	far_dist += heavy_impact_range * 15
	far_dist += devastation_range * 20

	if(!silent)
		shake_the_room(epicenter, orig_max_distance, far_dist, devastation_range, heavy_impact_range)

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

	var/list/affected_turfs = prepare_explosion_turfs(max_range, epicenter, protect_epicenter, explosion_direction, explosion_arc)

	var/reactionary = CONFIG_GET(flag/reactionary_explosions)
	// this list is setup in the form position -> block for that position
	// we assert that turfs will be processed closed to farthest, so we can build this as we go along
	// This is gonna be an array, index'd by turfs
	var/list/cached_exp_block = list()
	var/list/held_throwturf = src.held_throwturf

	//lists are guaranteed to contain at least 1 turf at this point
	//we presuppose that we'll be iterating away from the epicenter
	for(var/turf/explode as anything in affected_turfs)
		var/our_x = explode.x
		var/our_y = explode.y
		var/dist = CHEAP_HYPOTENUSE(our_x, our_y, x0, y0)
		var/block = 0
		// Using this pattern, block will flow out from blocking turfs, essentially caching the recursion
		// This is safe because if get_step_towards is ever anything but caridnally off, it'll do a diagonal move
		// So we always sample from a "loop" closer
		// It's kind of behaviorly unimpressive but that's a problem for the future
		if(reactionary)
			if(explode == epicenter)
				cached_exp_block[explode] = explode.explosive_resistance
			else
				var/our_block = cached_exp_block[get_step_towards(explode, epicenter)]
				block += our_block
				cached_exp_block[explode] = our_block + explode.explosive_resistance

		var/severity = EXPLODE_NONE
		if(dist + (block * EXPLOSION_BLOCK_DEV) < devastation_range)
			severity = EXPLODE_DEVASTATE
		else if(dist + (block * EXPLOSION_BLOCK_HEAVY) < heavy_impact_range)
			severity = EXPLODE_HEAVY
		else if(dist + (block * EXPLOSION_BLOCK_LIGHT) < light_impact_range)
			severity = EXPLODE_LIGHT

		if(explode == epicenter) // Ensures explosives detonating from bags trigger other explosives in that bag
			var/list/items = list()
			for(var/atom/holder as anything in explode)
				if (length(holder.contents) && !(holder.flags_1 & PREVENT_CONTENTS_EXPLOSION_1)) //The atom/contents_explosion() proc returns null if the contents ex_acting has been handled by the atom, and TRUE if it hasn't.
					items += holder.get_all_contents(ignore_flag_1 = PREVENT_CONTENTS_EXPLOSION_1)
				if(isliving(holder))
					items -= holder		//Stops mobs from taking double damage from explosions originating from them/their turf, such as from projectiles
			switch(severity)
				if(EXPLODE_DEVASTATE)
					SSexplosions.high_mov_atom += items
				if(EXPLODE_HEAVY)
					SSexplosions.med_mov_atom += items
				if(EXPLODE_LIGHT)
					SSexplosions.low_mov_atom += items
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += explode
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += explode
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += explode

		if(prob(40) && dist < flame_range && !isspaceturf(explode) && !explode.density)
			flameturf += explode

		//--- THROW ITEMS AROUND ---
		if (explode.explosion_throw_details)
			var/list/throwingturf = explode.explosion_throw_details
			if (throwingturf[1] < max_range - dist)
				throwingturf[1] = max_range - dist
				throwingturf[2] = epicenter
				throwingturf[3] = max_range
		else
			explode.explosion_throw_details = list(max_range - dist, epicenter, max_range)
			held_throwturf += explode


	var/took = (REALTIMEOFDAY - started_at) / 10

	//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes to explosion code using this please so we can compare
	if(GLOB.Debug2)
		log_world("## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds.")

	explosion_index += 1

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_EXPLOSION, epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range, explosion_cause, explosion_index)

// Explosion SFX defines...
/// The probability that a quaking explosion will make the station creak per unit. Maths!
#define QUAKE_CREAK_PROB 30
/// The probability that an echoing explosion will make the station creak per unit.
#define ECHO_CREAK_PROB 5
/// Time taken for the hull to begin to creak after an explosion, if applicable.
#define CREAK_DELAY (5 SECONDS)
/// Lower limit for far explosion SFX volume.
#define FAR_LOWER 40
/// Upper limit for far explosion SFX volume.
#define FAR_UPPER 60
/// The probability that a distant explosion SFX will be a far explosion sound rather than an echo. (0-100)
#define FAR_SOUND_PROB 75
/// The upper limit on screenshake amplitude for nearby explosions.
#define NEAR_SHAKE_CAP 5
/// The upper limit on screenshake amplifude for distant explosions.
#define FAR_SHAKE_CAP 1.5
/// The duration of the screenshake for nearby explosions.
#define NEAR_SHAKE_DURATION (1.5 SECONDS)
/// The duration of the screenshake for distant explosions.
#define FAR_SHAKE_DURATION (1 SECONDS)
/// The lower limit for the randomly selected hull creaking frequency.
#define FREQ_LOWER 25
/// The upper limit for the randomly selected hull creaking frequency.
#define FREQ_UPPER 40

/**
 * Handles the sfx and screenshake caused by an explosion.
 *
 * Arguments:
 * - [epicenter][/turf]: The location of the explosion.
 * - near_distance: How close to the explosion you need to be to get the full effect of the explosion.
 * - far_distance: How close to the explosion you need to be to hear more than echos.
 * - quake_factor: Main scaling factor for screenshake.
 * - echo_factor: Whether to make the explosion echo off of very distant parts of the station.
 * - creaking: Whether to make the station creak. Autoset if null.
 * - [near_sound][/sound]: The sound that plays if you are close to the explosion.
 * - [far_sound][/sound]: The sound that plays if you are far from the explosion.
 * - [echo_sound][/sound]: The sound that plays as echos for the explosion.
 * - [creaking_sound][/sound]: The sound that plays when the station creaks during the explosion.
 * - [hull_creaking_sound][/sound]: The sound that plays when the station creaks after the explosion.
 */
/datum/controller/subsystem/explosions/proc/shake_the_room(turf/epicenter, near_distance, far_distance, quake_factor, echo_factor, creaking, sound/near_sound = sound(get_sfx(SFX_EXPLOSION)), sound/far_sound = sound('sound/effects/explosion/explosionfar.ogg'), sound/echo_sound = sound('sound/effects/explosion/explosion_distant.ogg'), sound/creaking_sound = sound(get_sfx(SFX_EXPLOSION_CREAKING)), hull_creaking_sound = sound(get_sfx(SFX_HULL_CREAKING)))
	var/frequency = get_rand_frequency()
	var/blast_z = epicenter.z
	var/area/epicenter_area = get_area(epicenter)
	if(isnull(creaking)) // Autoset creaking.
		var/on_station = SSmapping.level_trait(epicenter.z, ZTRAIT_STATION)
		if(on_station && prob((quake_factor * QUAKE_CREAK_PROB) + (echo_factor * ECHO_CREAK_PROB))) // Huge explosions are near guaranteed to make the station creak and whine, smaller ones might.
			creaking = TRUE // prob over 100 always returns true
		else
			creaking = FALSE

	for(var/mob/listener as anything in GLOB.player_list)
		var/turf/listener_turf = get_turf(listener)
		if(!listener_turf || listener_turf.z != blast_z)
			continue

		var/distance = get_dist(epicenter, listener_turf)
		if(epicenter == listener_turf)
			distance = 0
		var/base_shake_amount = sqrt(near_distance / (distance + 1))

		if(distance <= round(near_distance + world.view - 2, 1)) // If you are close enough to see the effects of the explosion first-hand (ignoring walls)
			listener.playsound_local(epicenter, null, 100, TRUE, frequency, sound_to_use = near_sound)
			if(base_shake_amount > 0)
				shake_camera(listener, NEAR_SHAKE_DURATION, clamp(base_shake_amount, 0, NEAR_SHAKE_CAP))

		else if(distance < far_distance) // You can hear a far explosion if you are outside the blast radius. Small explosions shouldn't be heard throughout the station.
			var/far_volume = clamp(far_distance / 2, FAR_LOWER, FAR_UPPER)
			if(creaking)
				listener.playsound_local(epicenter, null, far_volume, TRUE, frequency, sound_to_use = creaking_sound, distance_multiplier = 0)
			else if(prob(FAR_SOUND_PROB)) // Sound variety during meteor storm/tesloose/other bad event
				listener.playsound_local(epicenter, null, far_volume, TRUE, frequency, sound_to_use = far_sound, distance_multiplier = 0)
			else
				listener.playsound_local(epicenter, null, far_volume, TRUE, frequency, sound_to_use = echo_sound, distance_multiplier = 0)

			if(base_shake_amount || quake_factor)
				base_shake_amount = max(base_shake_amount, quake_factor * 3, 0) // Devastating explosions rock the station and ground
				shake_camera(listener, FAR_SHAKE_DURATION, min(base_shake_amount, FAR_SHAKE_CAP))

		else if(!isspaceturf(listener_turf) && !(!(epicenter_area.type in GLOB.the_station_areas) && SSmapping.is_planetary()) && echo_factor) // Big enough explosions echo through the hull. Except on planetary maps if the epicenter is not on the station's area.
			var/echo_volume
			if(quake_factor)
				echo_volume = 60
				shake_camera(listener, FAR_SHAKE_DURATION, clamp(quake_factor / 4, 0, FAR_SHAKE_CAP))
			else
				echo_volume = 40
			listener.playsound_local(epicenter, null, echo_volume, TRUE, frequency, sound_to_use = echo_sound, distance_multiplier = 0)

		if(creaking) // 5 seconds after the bang, the station begins to creak
			addtimer(CALLBACK(listener, TYPE_PROC_REF(/mob, playsound_local), epicenter, null, rand(FREQ_LOWER, FREQ_UPPER), TRUE, frequency, null, null, FALSE, hull_creaking_sound, 0), CREAK_DELAY)

#undef CREAK_DELAY
#undef QUAKE_CREAK_PROB
#undef ECHO_CREAK_PROB
#undef FAR_UPPER
#undef FAR_LOWER
#undef FAR_SOUND_PROB
#undef NEAR_SHAKE_CAP
#undef FAR_SHAKE_CAP
#undef NEAR_SHAKE_DURATION
#undef FAR_SHAKE_DURATION
#undef FREQ_UPPER
#undef FREQ_LOWER

/// Returns a list of turfs in X range from the epicenter
/// Returns in a unique order, spiraling outwards
/// This is done to ensure our progressive cache of blast resistance is always valid
/// This is quite fast
/proc/prepare_explosion_turfs(range, turf/epicenter, protect_epicenter, explosion_direction, explosion_arc)
	var/list/outlist = list()
	var/list/candidates = list()
	// Add in the center if it's not protected
	if(!protect_epicenter)
		outlist += epicenter

	var/our_x = epicenter.x
	var/our_y = epicenter.y
	var/our_z = epicenter.z

	var/max_x = world.maxx
	var/max_y = world.maxy

	// Work out the angles to explode between
	var/first_angle_limit = WRAP(explosion_direction - explosion_arc * 0.5, 0, 360)
	var/second_angle_limit = WRAP(explosion_direction + explosion_arc * 0.5, 0, 360)

	// Get everything in the right order
	var/lower_angle_limit
	var/upper_angle_limit
	var/do_directional
	var/reverse_angle

	// Work out which case we're in
	if(first_angle_limit == second_angle_limit) // CASE A: FULL CIRCLE
		do_directional = FALSE
	else if(first_angle_limit < second_angle_limit) // CASE B: When the arc does not cross 0 degrees
		lower_angle_limit = first_angle_limit
		upper_angle_limit = second_angle_limit
		do_directional = TRUE
		reverse_angle = FALSE
	else if (first_angle_limit > second_angle_limit) // CASE C: When the arc crosses 0 degrees
		lower_angle_limit = second_angle_limit
		upper_angle_limit = first_angle_limit
		do_directional = TRUE
		reverse_angle = TRUE

	for(var/i in 1 to range)
		var/lowest_x = our_x - i
		var/lowest_y = our_y - i
		var/highest_x = our_x + i
		var/highest_y = our_y + i
		// top left to one before top right
		if(highest_y <= max_y)
			candidates += block(
				lowest_x, highest_y, our_z,
				highest_x - 1, highest_y, our_z
			)
		// top right to one before bottom right
		if(highest_x <= max_x)
			candidates += block(
				highest_x, highest_y, our_z,
				highest_x, lowest_y + 1, our_z
			)
		// bottom right to one before bottom left
		if(lowest_y >= 1)
			candidates += block(
				highest_x, lowest_y, our_z,
				lowest_x + 1, lowest_y, our_z
			)
		// bottom left to one before top left
		if(lowest_x >= 1)
			candidates += block(
				lowest_x, lowest_y, our_z,
				lowest_x, highest_y - 1, our_z
			)

	if(!do_directional)
		outlist += candidates
	else
		for(var/turf/candidate as anything in candidates)
			var/angle = get_angle(epicenter, candidate)
			if(ISINRANGE(angle, lower_angle_limit, upper_angle_limit) ^ reverse_angle)
				outlist += candidate
	return outlist

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
			EX_ACT(turf_thing, EXPLODE_LIGHT)
		cost_lowturf = MC_AVERAGE(cost_lowturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/med_turf = medturf
		medturf = list()
		for(var/thing in med_turf)
			var/turf/turf_thing = thing
			EX_ACT(turf_thing, EXPLODE_HEAVY)
		cost_medturf = MC_AVERAGE(cost_medturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/high_turf = highturf
		highturf = list()
		for(var/thing in high_turf)
			var/turf/turf_thing = thing
			EX_ACT(turf_thing, EXPLODE_DEVASTATE)
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
			EX_ACT(movable_thing, EXPLODE_DEVASTATE)
		cost_high_mov_atom = MC_AVERAGE(cost_high_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_med_mov_atom = med_mov_atom
		med_mov_atom = list()
		for(var/thing in local_med_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_HEAVY)
		cost_med_mov_atom = MC_AVERAGE(cost_med_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_low_mov_atom = low_mov_atom
		low_mov_atom = list()
		for(var/thing in local_low_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_LIGHT)
		cost_low_mov_atom = MC_AVERAGE(cost_low_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		/// Throwing only becomes acceptable after the explosions process, so we don't miss stuff that explosions GENERATE
		throwturf = held_throwturf
		held_throwturf = list()

	if (currentpart == SSEXPLOSIONS_THROWS)
		currentpart = SSEXPLOSIONS_TURFS
		timer = TICK_USAGE_REAL
		var/list/throw_turf = throwturf
		throwturf = list()
		for (var/thing in throw_turf)
			if (!thing)
				continue
			var/turf/explode = thing
			var/list/details = explode.explosion_throw_details
			explode.explosion_throw_details = null
			if (length(details) != 3)
				continue
			var/throw_range = details[1]
			var/turf/center = details[2]
			var/max_range = details[3]
			for(var/atom/movable/A in explode)
				if(QDELETED(A))
					continue
				if(!A.anchored && A.move_resist != INFINITY)
					// We want to have our distance matter, but we do want to bias to a lot of throw, for the vibe
					var/atom_throw_range = rand(throw_range, max_range) + max_range * 0.3
					var/turf/throw_at = get_ranged_target_turf_direct(A, center, atom_throw_range, 180) // Throw 180 degrees away from the explosion source
					A.throw_at(throw_at, atom_throw_range, EXPLOSION_THROW_SPEED, quickstart = FALSE)
		cost_throwturf = MC_AVERAGE(cost_throwturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	currentpart = SSEXPLOSIONS_TURFS

#undef EXPLOSION_THROW_SPEED
#undef EXPLOSION_BLOCK_LIGHT
#undef EXPLOSION_BLOCK_HEAVY
#undef EXPLOSION_BLOCK_DEV
