/**
 * - is_valid_z_level
 *
 * Checks if source_loc and checking_loc is both on the station, or on the same z level.
 * This is because the station's several levels aren't considered the same z, so multi-z stations need this special case.
 *
 * Args:
 * source_loc - turf of the source we're comparing.
 * checking_loc - turf we are comparing to source_loc.
 *
 * returns TRUE if connection is valid, FALSE otherwise.
 */
/proc/is_valid_z_level(turf/source_loc, turf/checking_loc)
	// if we're both on "station", regardless of multi-z, we'll pass by.
	if(is_station_level(source_loc.z) && is_station_level(checking_loc.z))
		return TRUE
	if(source_loc.z == checking_loc.z)
		return TRUE
	return FALSE

/**
 * Checks if the passed non-area atom is on a "planet".
 *
 * A planet is defined as anything with planetary atmos that has gravity:
 *
 * * - Mining level is definitely planetside (asteroid mining btfo'd)
 * * - Station level is planetside if planetary is enabled
 * * - Also just check for planetary turfs, might as well
 * * - If there's no gravity, it's definitely not a planet
 *
 * This essentially narrows it down so that
 *
 * * - Lavaland is a planet
 * * - Away missions are planets if they have gravity and planetary turfs
 * * - Icebox above ground is a planet
 * * - Icebox below ground is, yes, a planet
 *
 * Otherwise, we assume we're in "space". This includes
 *
 * * - Metastation (and friends)
 * * - Shuttles
 * * - Centcom
 * * - Deep space
 * * - Away Missions without gravity OR planetary turfs
 * * - Anyting on reserved z-levels without gravity OR planetary turfs (Lazy map templates)
 */
/proc/is_on_a_planet(atom/what)
	ASSERT(!isarea(what))

	var/turf/open/new_turf = get_turf(what)
	if(isnull(new_turf))
		return FALSE

	var/z_level_checks = (is_station_level(new_turf.z) && SSmapping.config.planetary) || is_mining_level(new_turf.z)
	var/planetary_check = istype(new_turf) && new_turf.planetary_atmos
	return (z_level_checks || planetary_check) && new_turf.has_gravity()
