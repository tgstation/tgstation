/datum/mining_template/simple_asteroid
	name = "Asteroid"
	rarity = MINING_COMMON
	size = 3


/datum/mining_template/simple_asteroid/get_description()
	. = ..()
	. += "<div>&gt; STANDARD</div>"

/datum/mining_template/simple_asteroid/Generate()
	var/is_hollow = rand(15)
	var/list/turfs = ReserveTurfsForAsteroidGeneration(center, size, FALSE)
	var/datum/callback/asteroid_cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(GenerateRoundAsteroid), src, center, /turf/closed/mineral/random/asteroid/tospace, null, turfs, is_hollow)
	SSmapping.generate_asteroid(src, asteroid_cb)
