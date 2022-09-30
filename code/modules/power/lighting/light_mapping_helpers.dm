/obj/machinery/light/broken
	status = LIGHT_BROKEN
	icon_state = "tube-broken"

/obj/machinery/light/built
	icon_state = "tube-empty"
	start_with_cell = FALSE

/obj/machinery/light/built/Initialize(mapload)
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
	no_low_power = TRUE

/obj/machinery/light/red/dim
	brightness = 4
	bulb_power = 0.7

/obj/machinery/light/blacklight
	bulb_colour = "#A700FF"
	nightshift_allowed = FALSE
	brightness = 8

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

/obj/machinery/light/small/built/Initialize(mapload)
	. = ..()
	status = LIGHT_EMPTY
	update(0)

/obj/machinery/light/small/red
	bulb_colour = "#FF3232"
	no_low_power = TRUE
	nightshift_allowed = FALSE

/obj/machinery/light/small/red/dim
	brightness = 2
	bulb_power = 0.8

/obj/machinery/light/small/blacklight
	bulb_colour = "#A700FF"
	nightshift_allowed = FALSE
	brightness = 4

// -------- Directional presets
// The directions are backwards on the lights we have now
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light, 0)

// ---- Broken tube
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/broken, 0)

// ---- Tube construct
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_construct, 0)

// ---- Tube frames
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/built, 0)

// ---- No nightlight tubes
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/no_nightlight, 0)

// ---- Warm light tubes
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/warm, 0)

// ---- No nightlight warm light tubes
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/warm/no_nightlight, 0)

// ---- Cold light tubes
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/cold, 0)

// ---- No nightlight cold light tubes
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/cold/no_nightlight, 0)

// ---- Red tubes
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/red, 0)

// ---- Red dim tubes
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/red/dim, 0)

// ---- Blacklight tubes
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/blacklight, 0)

// ---- Dim tubes
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/dim, 0)


// -------- Bulb lights
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/small, 0)

// ---- Bulb construct
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_construct/small, 0)

// ---- Bulb frames
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/small/built, 0)

// ---- Broken bulbs
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/small/broken, 0)

// ---- Red bulbs
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/small/red, 0)

// ---- Red dim bulbs
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/small/red/dim, 0)

// ---- Blacklight bulbs
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/small/blacklight, 0)
