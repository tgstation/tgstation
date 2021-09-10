#define RADPULSE_MAX_LEVELS_AFFECT 2

// A special GetAllContents that doesn't search past things with rad insulation
// Components which return COMPONENT_BLOCK_RADIATION prevent further searching into that object's contents. The object itself will get returned still.
// The ignore list makes those objects never return at all
/proc/get_rad_contents(atom/location)
	var/static/list/ignored_things = typecacheof(list(
		/mob/dead,
		/mob/camera,
		/obj/effect,
		/obj/docking_port,
		/obj/projectile,
		))
	var/list/processing_list = list(location)
	. = list()
	while(processing_list.len)
		var/atom/thing = processing_list[1]
		processing_list -= thing
		if(ignored_things[thing.type])
			continue
		. += thing
		if((thing.flags_1 & RAD_PROTECT_CONTENTS_1) || (SEND_SIGNAL(thing, COMSIG_ATOM_RAD_PROBE) & COMPONENT_BLOCK_RADIATION))
			continue
		processing_list += thing.contents

/proc/radiation_pulse(atom/source, intensity, range_modifier, log=FALSE, can_contaminate=TRUE)
	if(!SSradiation.can_fire)
		return

	var/turf/new_location_above = get_turf(source)
	var/turf/new_location_below = get_turf(source)
	var/base_level_pulsed = FALSE
	for(var/levels in 1 to RADPULSE_MAX_LEVELS_AFFECT)
		if(!base_level_pulsed)
			launch_radiation_wave(source, intensity, range_modifier, can_contaminate)
			base_level_pulsed = TRUE

		intensity *= 0.25
		var/turf/above_level = SSmapping.get_turf_above(new_location_above)
		var/turf/below_level = SSmapping.get_turf_below(new_location_below)

		if(above_level && isturf(above_level))
			launch_radiation_wave(above_level, intensity, range_modifier, can_contaminate)
			new_location_above = above_level
		if(below_level && isturf(below_level))
			launch_radiation_wave(below_level, intensity, range_modifier, can_contaminate)
			new_location_below = below_level

	if(log)
		var/turf/_source_T = isturf(source) ? source : get_turf(source)
		log_game("Radiation pulse with intensity: [intensity] and range modifier: [range_modifier] in [loc_name(_source_T)] ")
	return TRUE

/proc/launch_radiation_wave(atom/source, intensity, range_modifier, can_contaminate)
	for(var/dir in GLOB.cardinals)
		new /datum/radiation_wave(source, dir, intensity, range_modifier, can_contaminate)

	var/list/things = get_rad_contents(source) //copypasta because I don't want to put special code in waves to handle their origin
	for(var/k in 1 to things.len)
		var/atom/thing = things[k]
		if(!thing)
			continue
		thing.rad_act(intensity)

	var/static/last_huge_pulse = 0
	if(intensity > 3000 && world.time > last_huge_pulse + 200)
		last_huge_pulse = world.time
	return TRUE

/proc/get_rad_contamination(atom/location)
	var/rad_strength = 0
	for(var/i in get_rad_contents(location)) // Yes it's intentional that you can't detect radioactive things under rad protection. Gives traitors a way to hide their glowing green rocks.
		var/atom/thing = i
		if(!thing)
			continue
		var/datum/component/radioactive/radiation = thing.GetComponent(/datum/component/radioactive)
		if(radiation && rad_strength < radiation.strength)
			rad_strength = radiation.strength
	return rad_strength

#undef RADPULSE_MAX_LEVELS_AFFECT
