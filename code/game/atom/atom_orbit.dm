/atom
	///Reference to atom being orbited
	var/atom/orbit_target
	///The orbiter component, if there's anything orbiting this atom
	var/datum/component/orbiter/orbiters

/**
 * Recursive getter method to return a list of all ghosts orbitting this atom
 *
 * This will work fine without manually passing arguments.
 * * processed - The list of atoms we've already convered
 * * source - Is this the atom for who we're counting up all the orbiters?
 * * ignored_stealthed_admins - If TRUE, don't count admins who are stealthmoded and orbiting this
 */
/atom/proc/get_all_orbiters(list/processed, source = TRUE, ignore_stealthed_admins = TRUE)
	var/list/output = list()
	if(!processed)
		processed = list()
	else if(src in processed)
		return output

	if(!source)
		output += src

	processed += src
	for(var/atom/atom_orbiter as anything in orbiters?.orbiter_list)
		output += atom_orbiter.get_all_orbiters(processed, source = FALSE)
	return output

/mob/get_all_orbiters(list/processed, source = TRUE, ignore_stealthed_admins = TRUE)
	if(!source && ignore_stealthed_admins && client?.holder?.fakekey)
		return list()
	return ..()
