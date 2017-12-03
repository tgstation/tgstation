// A special GetAllContents that doesn't search past things with rad insulation
// The protection var only protects the things inside from being affected.
// The protecting object itself will get returned still.
// The ignore list makes those objects never return at all
/proc/get_rad_contents(atom/location)
	var/list/processing_list = list(location)
	. = list()
	while(processing_list.len)
		var/static/list/ignored_things = typecacheof(list(
			/mob/dead,
			/mob/camera,
			/obj/effect,
			/obj/docking_port,
			/atom/movable/lighting_object,
			/obj/item/projectile
			))
		var/atom/thing = processing_list[1]
		processing_list -= thing
		if(ignored_things[thing.type])
			continue
		. += thing
		var/datum/component/rad_insulation/insulation = thing.GetComponent(/datum/component/rad_insulation)
		if(insulation && insulation.protects)
			continue
		processing_list += thing.contents

/proc/radiation_pulse(atom/source, intensity, range_modifier, log=FALSE, can_contaminate=TRUE)
	if(!SSradiation.can_fire)
		return
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
		log = TRUE
	if(log)
		log_game("Radiation pulse with intensity:[intensity] and range modifier:[range_modifier] in area [get_area(source)] ")
	return TRUE