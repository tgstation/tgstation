/*----- Template for ruins, prevents needing to re-type the filepath prefix -----*/
/datum/map_template/ruin/rockplanet
	prefix = "modular_skyrat/modules/mapping/_maps/RandomRuins/RockplanetRuins/"	//Originally _maps\skyrat\RandomRuins\AsteroidRuins, but now they're stored with all our servers Ruins - plus, asteroid was too vague
	allow_duplicates = FALSE
/*------*/

/datum/map_template/ruin/rockplanet/throwback
	name = "Throwback"
	id = "throwback"
	description = "Just wait 'til that asshole with his big hammer comes around."
	suffix = "throwback.dmm"

/datum/map_template/ruin/rockplanet/crashedshuttle
	name = "Crashed Shuttle"
	id = "asteroidcrashedshuttle"
	description = "As a protip - creating a shuttle with no manual exit is never a good idea."
	suffix = "crashedshuttle.dmm"

/datum/map_template/ruin/rockplanet/cozycabin
	name = "Cozy Cabin"
	id = "asteroidcozycabin"
	description = "A comfy cabin out in the wastes, a testament to human survival. Seems whoever the owner is is out somewhere."
	suffix = "cozycabin.dmm"

/datum/map_template/ruin/rockplanet/biodome
	name = "Jungle Biodome"
	id = "asteroidbiodome"
	description = "An experimental location, meant to demonstrate terraforming LV-669 as a possibility."
	suffix = "biodome.dmm"
//Above this line are the original ruins, from when every file relating to Rockplanet was called 'Asteroid'. That was changed because having asteroid(planet) and asteroid(space object) made files and whatnot confusing


/datum/map_template/ruin/rockplanet/xenohive
	name = "Xenomorph Hive"
	id = "rockplanet_xenohive"
	description = "Xenomorphs have built a nest in a pre-existing cave system, and have since been picking off unfortunate explorers or crew from the nearby mining post."
	suffix = "xenohive.dmm"
	cost = 5

/datum/map_template/ruin/rockplanet/factory
	name = "Abandoned Factory"
	id = "rockplanet_factory"
	description = "A long-dormant factory, overtaken by rust and dust. Whatever it was making is lost to time."
	suffix = "factory.dmm"
	cost = 5

/datum/map_template/ruin/rockplanet/syndicate_base
	name = "Syndicate Rockplanet Base"
	id = "rock-base"
	description = "A secret base researching illegal bioweapons, it is closely guarded by an elite team of syndicate agents."
	suffix = "rockplanet_surface_syndicate_base1_skyrat.dmm"
	allow_duplicates = FALSE
	never_spawn_with = list(/datum/map_template/ruin/icemoon/underground/skyrat/syndicate_base, /datum/map_template/ruin/lavaland/skyrat/syndicate_base)
	always_place = TRUE

//Below here should be ruins that are pretty much entirely fluff - minimal loot or threat, just adds to the aesthetic
/datum/map_template/ruin/rockplanet/abandoned_a	//Restaraunt
	name = "Abandoned Structure A"
	id = "rockplanetabandoned_a"
	description = "The remains of some ancient structure."
	suffix = "abandoned_a.dmm"

/datum/map_template/ruin/rockplanet/abandoned_b	//Hotel
	name = "Abandoned Structure B"
	id = "rockplanetabandoned_b"
	description = "The remains of some ancient structure."
	suffix = "abandoned_b.dmm"

/datum/map_template/ruin/rockplanet/abandoned_c	//Gas station
	name = "Abandoned Structure C"
	id = "rockplanetabandoned_c"
	description = "The remains of some ancient structure."
	suffix = "abandoned_c.dmm"

/datum/map_template/ruin/rockplanet/abandoned_d	//Road intersection
	name = "Abandoned Structure D"
	id = "rockplanetabandoned_d"
	description = "The remains of some ancient structure."
	suffix = "abandoned_d.dmm"

// Anywhere ruins that all mining levels should have, minimally modified.

/datum/map_template/ruin/rockplanet/free_golem
	name = "Free Golem Ship"
	id = "golem-ship"
	description = "Lumbering humanoids, made out of precious metals, move inside this ship. They frequently leave to mine more minerals, which they somehow turn into more of them. \
	Seem very intent on research and individual liberty, and also geology-based naming?"
	cost = 20
	prefix = "_maps/RandomRuins/AnywhereRuins/"
	suffix = "golem_ship.dmm"

/datum/map_template/ruin/rockplanet/fountain
	name = "Fountain Hall"
	id = "fountain"
	description = "The fountain has a warning on the side. DANGER: May have undeclared side effects that only become obvious when implemented."
	prefix = "_maps/RandomRuins/AnywhereRuins/"
	suffix = "fountain_hall.dmm"
	cost = 5
//	allow_duplicates = TRUE //Re-enable this when more ruins are added! As it is now, Rockplanet will be FLOODED With these.
