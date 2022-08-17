/obj/structure/overmap/event
	name = "generic overmap event"

	/// Chance to spread to nearby tiles if spawned
	var/spread_chance = 0
	/// How many additional tiles to spawn at once in the selected orbit
	var/chain_rate = 0

/obj/structure/overmap/event/meteor
	name = "asteroid storm (moderate)"
	icon_state = "meteor1"
	spread_chance = 50
	chain_rate = 4

/obj/structure/overmap/event/meteor/Initialize(mapload)
	. = ..()
	icon_state = "meteor[rand(1, 4)]"

/obj/structure/overmap/event/meteor/minor
	name = "asteroid storm (minor)"
	chain_rate = 3

/obj/structure/overmap/event/meteor/majour
	name = "asteroid storm (majour)"
	spread_chance = 25
	chain_rate = 6

/obj/structure/overmap/event/emp
	name = "ion storm (moderate)"
	icon_state = "ion1"
	spread_chance = 20
	chain_rate = 2

/obj/structure/overmap/event/emp/Initialize(mapload)
	. = ..()
	icon_state = "ion[rand(1, 4)]"

/obj/structure/overmap/event/emp/minor
	name = "ion storm (minor)"
	chain_rate = 1

/obj/structure/overmap/event/emp/majour
	name = "ion storm (majour)"
	chain_rate = 4

/obj/structure/overmap/event/electric
	name = "electrical storm (moderate)"
	icon_state = "electrical1"
	spread_chance = 30
	chain_rate = 3

/obj/structure/overmap/event/electric/Initialize(mapload)
	. = ..()
	icon_state = "electrical[rand(1, 4)]"

/obj/structure/overmap/event/electric/minor
	name = "electrical storm (minor)"
	spread_chance = 40
	chain_rate = 2

/obj/structure/overmap/event/electric/majour
	name = "electrical storm (majour)"
	spread_chance = 15
	chain_rate = 6

/obj/structure/overmap/event/nebula
	name = "nebula"
	icon_state = "nebula"
	chain_rate = 8
	spread_chance = 75
	opacity = TRUE

// voidcrew TODO: reimplement wormholes once ships are working again

GLOBAL_LIST_INIT(overmap_event_pick_list, list(
	/obj/structure/overmap/event/nebula = 60,
	/obj/structure/overmap/event/electric/minor = 45,
	/obj/structure/overmap/event/electric = 40,
	/obj/structure/overmap/event/electric/majour = 35,
	/obj/structure/overmap/event/emp/minor = 45,
	/obj/structure/overmap/event/emp = 40,
	/obj/structure/overmap/event/emp/majour = 45,
	/obj/structure/overmap/event/meteor/minor = 45,
	/obj/structure/overmap/event/meteor = 40,
	/obj/structure/overmap/event/meteor/majour = 35
))

