#define CONTRASTLESS_ROCKS 'modular_bandastation/aesthetics/walls/icons/rocks/contrastless_rocks.dmi'
#define CONTRAST_ROCKS 'modular_bandastation/aesthetics/walls/icons/rocks/contrast_rocks.dmi'
#define DEFAULT_ROCKS 'modular_bandastation/aesthetics/walls/icons/rocks/default_rocks.dmi'
#define MAPPING_ROCKS 'modular_bandastation/aesthetics/walls/icons/rocks/mapping_rocks.dmi'

#define rock_color(color) MAP_SWITCH(color, null)
#define rock_icon_state(state) MAP_SWITCH("smoothrocks-0", state)
#define ROCK_COLOR "#464646"
#define ROCK_COLOR_RED "#861313"
#define ROCK_COLOR_ICE "#cde2e4"
#define ROCK_COLOR_ASH "#ccddff"
#define ROCK_COLOR_SHALE "#353743"
#define ROCK_COLOR_VOLCANIC_RED "#A60100"

// MARK: Minerals
/turf/closed/mineral
	icon = MAP_SWITCH(DEFAULT_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("rock")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR)
	transform = null
	wall_icon_state = null

/turf/closed/mineral/minimap
	name = "DO NOT USE!!!"
	icon = DEFAULT_ROCKS
	icon_state = "smoothrocks-0"
	base_icon_state = "smoothrocks"
	color = ROCK_COLOR

/turf/closed/mineral/strong
	icon = MAP_SWITCH(CONTRAST_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("rock2")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_ASH)

/turf/closed/mineral/strong/wasteland
	icon = MAP_SWITCH(CONTRAST_ROCKS, MAPPING_ROCKS)
	base_icon_state = "smoothrocks"

/turf/closed/mineral/ash_rock
	icon = MAP_SWITCH(CONTRAST_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("rock2")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_ASH)

/turf/closed/mineral/random/stationside/asteroid
	icon = MAP_SWITCH(CONTRAST_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("rock_nochance")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_RED)
	transform = null

/turf/closed/mineral/asteroid
	icon = MAP_SWITCH(CONTRAST_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("redrock")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_RED)
	transform = null

/turf/closed/mineral/random/volcanic/shale
	icon = MAP_SWITCH(CONTRAST_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("shale")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_SHALE)
	transform = null
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/closed/mineral/random/volcanic/red_rock
	icon = MAP_SWITCH(CONTRAST_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("redrock")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_VOLCANIC_RED)
	transform = null
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

// Cold rocks
/turf/closed/mineral/snowmountain
	icon = MAP_SWITCH(CONTRASTLESS_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("mountainrock")
	base_icon_state = "smoothrocks"
	color = rock_color(COLOR_WHITE)

/turf/closed/mineral/snowmountain/cavern
	icon = MAP_SWITCH(DEFAULT_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("icerock2")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_ICE)

/turf/closed/mineral/random/snow
	icon = MAP_SWITCH(CONTRASTLESS_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("mountainrock")
	base_icon_state = "smoothrocks"
	color = rock_color(COLOR_WHITE)

/turf/closed/mineral/random/snow/change_ore(ore_type, random = TRUE)
	. = ..()
	if(mineral_type)
		color = ROCK_COLOR_ICE

/turf/closed/mineral/random/labormineral/ice
	icon = MAP_SWITCH(CONTRASTLESS_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("mountainrock")
	base_icon_state = "smoothrocks"
	color = rock_color(COLOR_WHITE)

/turf/closed/mineral/gibtonite/ice
	icon = MAP_SWITCH(CONTRASTLESS_ROCKS, MAPPING_ROCKS)
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_ICE)

// MARK: Walls
/turf/closed/indestructible/rock
	icon = MAP_SWITCH(DEFAULT_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("rock")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR)
	transform = null
	wall_icon_state = null

/turf/closed/indestructible/rock/snow
	icon = MAP_SWITCH(CONTRASTLESS_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("mountainrock")
	base_icon_state = "smoothrocks"
	color = rock_color(COLOR_WHITE)

/turf/closed/indestructible/rock/snow/ice
	icon = MAP_SWITCH(CONTRASTLESS_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("icerock")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_ICE)

/turf/closed/indestructible/rock/snow/ice/ore
	icon = MAP_SWITCH(DEFAULT_ROCKS, MAPPING_ROCKS)
	icon_state = rock_icon_state("icerock2")
	base_icon_state = "smoothrocks"
	color = rock_color(ROCK_COLOR_ICE)

#undef CONTRASTLESS_ROCKS
#undef CONTRAST_ROCKS
#undef DEFAULT_ROCKS
#undef MAPPING_ROCKS

#undef rock_color
#undef ROCK_COLOR
#undef ROCK_COLOR_RED
#undef ROCK_COLOR_ICE
#undef ROCK_COLOR_ASH
