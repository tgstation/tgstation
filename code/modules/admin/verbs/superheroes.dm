
/client/proc/summon_superheroes()
	set category = "Admin.Fun"
	set name = "Summon Superheroes and Supervillains"
	set desc = "Spawn superhero and supervillain ships. USE ONLY ONCE OR SHIPS MAY BREAK."

	holder?.spawnSuperheroes()
	holder?.spawnSupervillains()

	var/list/candidates = pollGhostCandidates("Would you like to play as a superhero/supervillain?", ROLE_SUPERHERO, FALSE, 300)
	var/list/heroes = list()
	for(var/obj/effect/mob_spawn/human/superhero/spawner in world)
		heroes.Add(spawner)

	while(LAZYLEN(candidates) && LAZYLEN(heroes))
		var/mob/dead/observer/ghostie = pick_n_take(candidates)
		var/obj/effect/mob_spawn/human/superhero/spawner = pick_n_take(heroes)
		spawner.create(ckey = ghostie.ckey)

	message_admins("[key_name(usr)] spawned superheroes and supervillains.")
	log_admin("[key_name(usr)] spawned superheroes and supervillains.")

	priority_announce("Two unidentified ships detected near the station.")

/datum/admins/proc/spawnSuperheroes()
	var/datum/map_template/shuttle/superhero/owlskip/ship = new()
	var/x = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)

	if(!T)
		CRASH("Superhero ship found no turf to load in")

	if(!ship.load(T))
		CRASH("Loading superhero ship failed!")

/datum/admins/proc/spawnSupervillains()
	var/datum/map_template/shuttle/superhero/dark_mothership/ship = new()
	var/x = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)

	if(!T)
		CRASH("Supervillain ship found no turf to load in")

	if(!ship.load(T))
		CRASH("Loading supervillain ship failed!")
