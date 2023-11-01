/datum/mining_template
	var/name = ""
	var/description = ""
	var/rarity = null
	var/randomly_appear = FALSE
	/// The size (radius, chebyshev distance). Will be clamped to the size of the asteroid magnet in New().
	var/size = 7
	/// The center turf.
	var/turf/center

	// Asteroid Map location
	var/x
	var/y

	var/id

/datum/mining_template/New(center, max_size)
	. = ..()
	id = random_string(10, GLOB.hex_characters)
	src.center = center
	if(size)
		size = max(size, max_size)

/// Called during SSmapping.generate_asteroid(). Here is where you mangle the geometry provided by the asteroid generator function.
/// Atoms at this stage are NOT initialized
/datum/mining_template/proc/Generate(list/turfs)

/// Called during SSmapping.generate_asteroid() after all atoms have been initialized.
/datum/mining_template/proc/AfterInitialize(list/atoms)
	return

/datum/mining_template/simple_asteroid
	name = "Asteroid"
	rarity = -1
	size = 3

/proc/_TestLoadAsteroid(destroy)
	var/time = world.timeofday
	var/datum/mining_template/simple_asteroid/template = new(get_turf(usr), 5)

	var/list/turfs = ReserveTurfsForAsteroidGeneration(template.center, template.size)
	var/datum/callback/asteroid_cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(GenerateRoundAsteroid), template, template.center, /turf/closed/mineral/random/asteroid/tospace, null, turfs, TRUE)
	SSmapping.generate_asteroid(template, asteroid_cb)

	to_chat(usr, span_warning("Asteroid took [DisplayTimeText(world.timeofday - time, 0.01)] to generate."))

	if(destroy)
		sleep(5 SECONDS)

		time = world.timeofday
		CleanupAsteroidMagnet(template.center, template.size)
		to_chat(usr, span_warning("Asteroid took [DisplayTimeText(world.timeofday - time, 0.01)] to destroy."))
