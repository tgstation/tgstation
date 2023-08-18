/*
/turf/open/misc/grass
	name = "grass"
	desc = "A patch of grass."
	icon_state = "grass0"
	base_icon_state = "grass"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_GRASS
	canSmoothWith = SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_CLOSED_TURFS
	layer = HIGH_TURF_LAYER
	icon = 'voidcrew/icons/turf/floors/grass.dmi'
	var/smooth_icon = 'voidcrew/icons/turf/floors/grass.dmi'


/turf/open/misc/grass/jungle
	name = "jungle grass"
	planetary_atmos = TRUE
	desc = "Lush, verdant grass."
	icon_state = "junglegrass"
	base_icon_state = "junglegrass"
	smooth_icon = 'voidcrew/icons/turf/floors/junglegrass.dmi'
	baseturfs = /turf/open/floor/plating/grass/jungle

/turf/open/floor/plating/grass/jungle
	icon = 'voidcrew/icons/turf/floors/junglegrass.dmi'
*/
/turf/open/misc/grass/jungle/lit
	light_range = 2
	light_power = 1

/turf/open/misc/dirt/jungle/dark/lit
	light_range = 2
	light_power = 1
/turf/open/misc/dirt/jungle/dark/lit
	light_range = 2
	light_power = 1
/turf/open/misc/dirt/jungle/wasteland/lit
	light_range = 2
	light_power = 1
/turf/open/water/jungle/lit
	light_range = 2
	light_power = 0.8
	light_color = LIGHT_COLOR_BLUEGREEN
/turf/open/misc/dirt/old
	icon_state = "oldsmoothdirt"
/turf/open/misc/dirt/old/lit
	light_power = 1
	light_range = 2
/turf/open/misc/dirt/old/dark
	icon_state =  "oldsmoothdarkdirt"
/turf/open/misc/dirt/old/dark/lit
	light_power = 1
	light_range = 2

/turf/open/misc/dirt/dry
	icon = 'voidcrew/icons/turf/wasteland.dmi'
	icon_state = "dirt"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/misc/dirt/dry

/turf/open/misc/dirt/dry/lit
	light_power = 1
	light_range = 2

/turf/open/misc/grass/lava
	name = "ungodly grass"
	desc = "Common grass, tinged to unnatural colours by chemicals in the atmosphere."
	baseturfs = /turf/open/misc/grass/lava
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	icon_state = "grass"
	base_icon_state = "grass"
	planetary_atmos = TRUE
	icon = 'voidcrew/icons/turf/floors/lava_grass_red.dmi'
	smooth_icon = 'voidcrew/icons/turf/floors/lava_grass_red.dmi'
	light_power = 1
	light_range = 2
	gender = PLURAL

/turf/open/misc/grass/lava/orange
	baseturfs = /turf/open/misc/grass/lava/orange
	icon = 'voidcrew/icons/turf/floors/lava_grass_orange.dmi'
	smooth_icon = 'voidcrew/icons/turf/floors/lava_grass_orange.dmi'

/turf/open/misc/grass/lava/purple
	baseturfs = /turf/open/misc/grass/lava/purple
	icon = 'voidcrew/icons/turf/floors/lava_grass_purple.dmi'
	smooth_icon = 'voidcrew/icons/turf/floors/lava_grass_purple.dmi'

/turf/open/misc/wasteland
	name = "desolate ground"
	desc = "Devoid of all but the most hardy lifeforms."
	icon = 'voidcrew/icons/turf/wasteland.dmi'
	icon_state = "wasteland1"
	base_icon_state = "wasteland"
	baseturfs = /turf/open/misc/wasteland
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	gender = PLURAL

/turf/open/misc/wasteland/Initialize(mapload, inherited_virtual_z)
	. = ..()
	icon_state = "[base_icon_state][rand(1,33)]"

/turf/open/misc/wasteland/lit
	light_power = 1
	light_range = 2

/turf/open/floor/plating/rubble
	name = "rubble"
	desc = "Rubble from a destroyed civilization."
	icon = 'voidcrew/icons/turf/wasteland.dmi'
	icon_state = "rubblefull"
	base_icon_state = "rubble"
	baseturfs = /turf/open/floor/plating/rubble
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	gender = PLURAL

/turf/open/floor/plating/rubble/Initialize(mapload, inherited_virtual_z)
	. = ..()
	icon_state = "[base_icon_state][pick("full", "slab", "plate", "pillar")]"

/turf/open/floor/plating/tunnel
	name = "plating"
	desc = "The foundations of some structure that never came to fruition."
	icon = 'voidcrew/icons/turf/wasteland.dmi'
	icon_state = "tunnelintact"
	base_icon_state = "tunnel"
	baseturfs = /turf/open/floor/plating/tunnel
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	gender = PLURAL

/turf/open/floor/plating/tunnel/Initialize(mapload, inherited_virtual_z)
	. = ..()
	icon_state = "[base_icon_state][pick("intact", "dirty", "rusty", "chess", "chess2", "hole", "wastelandfull", "wastelandfullvar", "wasteland")]"

/turf/open/floor/plating/mossy_stone
	name = "mossy stone"
	desc = "Ancient stone with moss growing on it."
	icon = 'voidcrew/icons/turf/wasteland.dmi'
	icon_state = "stone_old"
	base_icon_state = "stone"
	baseturfs = /turf/open/floor/plating/mossy_stone
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	gender = PLURAL

/turf/open/floor/plating/stone/Initialize(mapload, inherited_virtual_z)
	. = ..()
	icon_state = "[base_icon_state]_[pick("old", "old1", "old2")]"

/turf/open/misc/dust
	name = "dry ground"
	desc = "Dust perpetually blows through this land."
	icon = 'voidcrew/icons/turf/wasteland.dmi'
	icon_state = "dust1"
	base_icon_state = "dust"
	baseturfs = /turf/open/misc/dust
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	gender = PLURAL

/turf/open/misc/dust/Initialize(mapload, inherited_virtual_z)
	. = ..()
	icon_state = "[base_icon_state][pick("1", "2")]"

/turf/open/misc/dust/lit
	light_power = 1
	light_range = 2
