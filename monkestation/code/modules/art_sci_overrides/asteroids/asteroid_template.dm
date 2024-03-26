
/datum/mining_template
	var/name = "PLACEHOLDER NAME"
	var/rarity = MINING_NO_RANDOM_SPAWN
	var/randomly_appear = FALSE
	/// The size (radius, chebyshev distance). Will be clamped to the size of the asteroid magnet in New().
	var/size = 7
	/// The center turf.
	var/turf/center

	// Asteroid Map location
	var/x
	var/y

	/// Has this template been located by players?
	var/found = FALSE
	/// Has this template been summoned?
	var/summoned = FALSE

/datum/mining_template/New(center, max_size)
	. = ..()
	src.center = center
	if(size)
		size = max(size, max_size)


/// Randomize the data of this template. Does not change size, center, or location.
/datum/mining_template/proc/randomize()
	return

/// The proc to call to completely generate an asteroid
/datum/mining_template/proc/Generate()
	return

/// Called during SSmapping.generate_asteroid(). Here is where you mangle the geometry provided by the asteroid generator function.
/// Atoms at this stage are NOT initialized
/datum/mining_template/proc/Populate(list/turfs)
	return

/// Called during SSmapping.generate_asteroid() after all atoms have been initialized.
/datum/mining_template/proc/AfterInitialize(list/atoms)
	return

/// Called by an asteroid magnet to return a description as a list of bullets
/datum/mining_template/proc/get_description()
	return list()
