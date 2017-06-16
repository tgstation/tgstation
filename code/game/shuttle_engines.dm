
/obj/structure/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/shuttle/engine
	name = "engine"
	desc = "A bluespace engine used to make shuttles move forwards."
	density = 1
	anchored = 1

/obj/structure/shuttle/engine/heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power engines."
	icon_state = "heater"

/obj/structure/shuttle/engine/platform
	name = "engine platform"
	desc = "A platform for engine components, or something."
	icon_state = "platform"

/obj/structure/shuttle/engine/propulsion
	name = "propulsion engine"
	desc = "A standard reliable bluespace engine used by many forms of shuttles."
	icon_state = "propulsion"
	opacity = 1

/obj/structure/shuttle/engine/propulsion/burst
	name = "burst engine"
	desc = "An engine that releases a large bluespace burst to propel it forwards."

/obj/structure/shuttle/engine/propulsion/burst/left
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/burst/right
	icon_state = "burst_r"

/obj/structure/shuttle/engine/router
	name = "engine router"
	desc = "Redirects around energized particles in engine structures."
	icon_state = "router"

/obj/structure/shuttle/engine/large
	name = "engine"
	desc = "A very large bluespace engine used to propel very large ships forwards."
	opacity = 1
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	bound_width = 64
	bound_height = 64
	appearance_flags = 0

obj/structure/shuttle/engine/huge
	name = "engine"
	desc = "An extremely large bluespace engine used to propel extremely large ships forwards."
	opacity = 1
	icon = 'icons/obj/3x3.dmi'
	icon_state = "huge_engine"
	bound_width = 96
	bound_height = 96
	appearance_flags = 0