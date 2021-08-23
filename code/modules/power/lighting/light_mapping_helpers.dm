/obj/machinery/light/broken
	status = LIGHT_BROKEN
	icon_state = "tube-broken"

/obj/machinery/light/built
	icon_state = "tube-empty"
	start_with_cell = FALSE

/obj/machinery/light/built/Initialize()
	. = ..()
	status = LIGHT_EMPTY
	update(0)

/obj/machinery/light/no_nightlight
	nightshift_enabled = FALSE

/obj/machinery/light/warm
	bulb_colour = "#fae5c1"

/obj/machinery/light/warm/no_nightlight
	nightshift_allowed = FALSE

/obj/machinery/light/cold
	bulb_colour = "#deefff"
	nightshift_light_color = "#deefff"

/obj/machinery/light/cold/no_nightlight
	nightshift_allowed = FALSE

/obj/machinery/light/red
	bulb_colour = "#FF3232"
	nightshift_allowed = FALSE
	no_emergency = TRUE
	brightness = 2
	bulb_power = 0.7

/obj/machinery/light/blacklight
	bulb_colour = "#A700FF"
	nightshift_allowed = FALSE
	brightness = 2
	bulb_power = 0.8

/obj/machinery/light/dim
	nightshift_allowed = FALSE
	bulb_colour = "#FFDDCC"
	bulb_power = 0.6

// the smaller bulb light fixture

/obj/machinery/light/small
	icon_state = "bulb"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 4
	nightshift_brightness = 4
	bulb_colour = "#FFD6AA"
	desc = "A small lighting fixture."
	light_type = /obj/item/light/bulb

/obj/machinery/light/small/broken
	status = LIGHT_BROKEN
	icon_state = "bulb-broken"

/obj/machinery/light/small/built
	icon_state = "bulb-empty"
	start_with_cell = FALSE

/obj/machinery/light/small/built/Initialize()
	. = ..()
	status = LIGHT_EMPTY
	update(0)

/obj/machinery/light/small/red
	bulb_colour = "#FF3232"
	no_emergency = TRUE
	nightshift_allowed = FALSE
	brightness = 1
	bulb_power = 0.8

/obj/machinery/light/small/blacklight
	bulb_colour = "#A700FF"
	nightshift_allowed = FALSE
	brightness = 1
	bulb_power = 0.9

// -------- Directional presets
// The directions are backwards on the lights we have now
/obj/machinery/light/directional/north
	dir = NORTH

/obj/machinery/light/directional/south
	dir = SOUTH

/obj/machinery/light/directional/east
	dir = EAST

/obj/machinery/light/directional/west
	dir = WEST

// ---- Broken tube
/obj/machinery/light/broken/directional/north
	dir = NORTH

/obj/machinery/light/broken/directional/south
	dir = SOUTH

/obj/machinery/light/broken/directional/east
	dir = EAST

/obj/machinery/light/broken/directional/west
	dir = WEST

// ---- Tube construct
/obj/structure/light_construct/directional/north
	dir = NORTH

/obj/structure/light_construct/directional/south
	dir = SOUTH

/obj/structure/light_construct/directional/east
	dir = EAST

/obj/structure/light_construct/directional/west
	dir = WEST

// ---- Tube frames
/obj/machinery/light/built/directional/north
	dir = NORTH

/obj/machinery/light/built/directional/south
	dir = SOUTH

/obj/machinery/light/built/directional/east
	dir = EAST

/obj/machinery/light/built/directional/west
	dir = WEST

// ---- No nightlight tubes
/obj/machinery/light/no_nightlight/directional/north
	dir = NORTH

/obj/machinery/light/no_nightlight/directional/south
	dir = SOUTH

/obj/machinery/light/no_nightlight/directional/east
	dir = EAST

/obj/machinery/light/no_nightlight/directional/west
	dir = WEST

// ---- Warm light tubes
/obj/machinery/light/warm/directional/north
	dir = NORTH

/obj/machinery/light/warm/directional/south
	dir = SOUTH

/obj/machinery/light/warm/directional/east
	dir = EAST

/obj/machinery/light/warm/directional/west
	dir = WEST

// ---- No nightlight warm light tubes
/obj/machinery/light/warm/no_nightlight/directional/north
	dir = NORTH

/obj/machinery/light/warm/no_nightlight/directional/south
	dir = SOUTH

/obj/machinery/light/warm/no_nightlight/directional/east
	dir = EAST

/obj/machinery/light/warm/no_nightlight/directional/west
	dir = WEST

// ---- Cold light tubes
/obj/machinery/light/cold/directional/north
	dir = NORTH

/obj/machinery/light/cold/directional/south
	dir = SOUTH

/obj/machinery/light/cold/directional/east
	dir = EAST

/obj/machinery/light/cold/directional/west
	dir = WEST

// ---- No nightlight cold light tubes
/obj/machinery/light/cold/no_nightlight/directional/north
	dir = NORTH

/obj/machinery/light/cold/no_nightlight/directional/south
	dir = SOUTH

/obj/machinery/light/cold/no_nightlight/directional/east
	dir = EAST

/obj/machinery/light/cold/no_nightlight/directional/west
	dir = WEST

// ---- Red tubes
/obj/machinery/light/red/directional/north
	dir = NORTH

/obj/machinery/light/red/directional/south
	dir = SOUTH

/obj/machinery/light/red/directional/east
	dir = EAST

/obj/machinery/light/red/directional/west
	dir = WEST

// ---- Blacklight tubes
/obj/machinery/light/blacklight/directional/north
	dir = NORTH

/obj/machinery/light/blacklight/directional/south
	dir = SOUTH

/obj/machinery/light/blacklight/directional/east
	dir = EAST

/obj/machinery/light/blacklight/directional/west
	dir = WEST

// ---- Dim tubes
/obj/machinery/light/dim/directional/north
	dir = NORTH

/obj/machinery/light/dim/directional/south
	dir = SOUTH

/obj/machinery/light/dim/directional/east
	dir = EAST

/obj/machinery/light/dim/directional/west
	dir = WEST


// -------- Bulb lights
/obj/machinery/light/small/directional/north
	dir = NORTH

/obj/machinery/light/small/directional/south
	dir = SOUTH

/obj/machinery/light/small/directional/east
	dir = EAST

/obj/machinery/light/small/directional/west
	dir = WEST

// ---- Bulb construct
/obj/structure/light_construct/small/directional/north
	dir = NORTH

/obj/structure/light_construct/small/directional/south
	dir = SOUTH

/obj/structure/light_construct/small/directional/east
	dir = EAST

/obj/structure/light_construct/small/directional/west
	dir = WEST

// ---- Bulb frames
/obj/machinery/light/small/built/directional/north
	dir = NORTH

/obj/machinery/light/small/built/directional/south
	dir = SOUTH

/obj/machinery/light/small/built/directional/east
	dir = EAST

/obj/machinery/light/small/built/directional/west
	dir = WEST

// ---- Broken bulbs
/obj/machinery/light/small/broken/directional/north
	dir = NORTH

/obj/machinery/light/small/broken/directional/south
	dir = SOUTH

/obj/machinery/light/small/broken/directional/east
	dir = EAST

/obj/machinery/light/small/broken/directional/west
	dir = WEST

// ---- Red bulbs
/obj/machinery/light/small/red/directional/north
	dir = NORTH

/obj/machinery/light/small/red/directional/south
	dir = SOUTH

/obj/machinery/light/small/red/directional/east
	dir = EAST

/obj/machinery/light/small/red/directional/west
	dir = WEST

// ---- Blacklight bulbs
/obj/machinery/light/small/blacklight/directional/north
	dir = NORTH

/obj/machinery/light/small/blacklight/directional/south
	dir = SOUTH

/obj/machinery/light/small/blacklight/directional/east
	dir = EAST

/obj/machinery/light/small/blacklight/directional/west
	dir = WEST
