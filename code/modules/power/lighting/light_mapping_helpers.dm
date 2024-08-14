/obj/machinery/light/broken
	status = LIGHT_BROKEN
	icon_state = "tube-broken"

/obj/machinery/light/built
	icon_state = "tube-empty"
	start_with_cell = FALSE
	status = LIGHT_EMPTY

/obj/machinery/light/no_nightlight
	nightshift_enabled = FALSE

/obj/machinery/light/warm
	bulb_colour = "#fae5c1"

/obj/machinery/light/warm/no_nightlight
	nightshift_allowed = FALSE

/obj/machinery/light/warm/dim
	nightshift_allowed = FALSE
	bulb_power = 0.6

/obj/machinery/light/cold
	bulb_colour = LIGHT_COLOR_FAINT_BLUE
	nightshift_light_color = LIGHT_COLOR_FAINT_BLUE

/obj/machinery/light/cold/no_nightlight
	nightshift_allowed = FALSE

/obj/machinery/light/cold/dim
	nightshift_allowed = FALSE
	bulb_power = 0.6

/obj/machinery/light/red
	bulb_colour = COLOR_VIVID_RED
	nightshift_allowed = FALSE
	no_low_power = TRUE

/obj/machinery/light/red/dim
	brightness = 4
	bulb_power = 0.7
	fire_brightness = 4.5

/obj/machinery/light/blacklight
	bulb_colour = "#A700FF"
	nightshift_allowed = FALSE

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
	fire_brightness = 4.5
	bulb_colour = LIGHT_COLOR_TUNGSTEN
	fire_colour = "#bd3f46"
	desc = "A small lighting fixture."
	light_type = /obj/item/light/bulb

/obj/machinery/light/small/broken
	status = LIGHT_BROKEN
	icon_state = "bulb-broken"

/obj/machinery/light/small/built
	icon_state = "bulb-empty"
	start_with_cell = FALSE
	status = LIGHT_EMPTY

/obj/machinery/light/small/dim
	brightness = 2.4

/obj/machinery/light/small/red
	bulb_colour = COLOR_VIVID_RED
	no_low_power = TRUE
	nightshift_allowed = FALSE
	fire_colour = "#ff1100"

/obj/machinery/light/small/red/dim
	brightness = 2
	bulb_power = 0.8
	fire_brightness = 2.5

/obj/machinery/light/small/blacklight
	bulb_colour = "#A700FF"
	nightshift_allowed = FALSE
	brightness = 4
	fire_brightness = 4.5
	fire_colour = "#d400ff"

// -------- Directional presets
// The directions are backwards on the lights we have now
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light)

// ---- Broken tube
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/broken)

// ---- Tube construct
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/light_construct)

// ---- Tube frames
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/built)

// ---- No nightlight tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/no_nightlight)

// ---- Warm light tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/warm)

// ---- No nightlight warm light tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/warm/no_nightlight)

// ---- Dim warm light tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/warm/dim)

// ---- Cold light tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/cold)

// ---- No nightlight cold light tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/cold/no_nightlight)

// ---- Dim cold light tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/cold/dim)

// ---- Red tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/red)

// ---- Red dim tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/red/dim)

// ---- Blacklight tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/blacklight)

// ---- Dim tubes
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/dim)


// -------- Bulb lights
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/small)

// ---- Bulb construct
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/light_construct/small)

// ---- Bulb frames
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/small/built)

// ---- Broken bulbs
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/small/broken)

// ---- Red bulbs
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/small/red)

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/small/dim)

// ---- Red dim bulbs
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/small/red/dim)

// ---- Blacklight bulbs
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/machinery/light/small/blacklight)
