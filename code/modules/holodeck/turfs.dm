/turf/open/floor/holofloor
	icon_state = "floor"
	holodeck_compatible = TRUE
	thermal_conductivity = 0
	flags_1 = NONE
	var/direction = SOUTH

/turf/open/floor/holofloor/attackby(obj/item/I, mob/living/user)
	return // HOLOFLOOR DOES NOT GIVE A FUCK

/turf/open/floor/holofloor/tool_act(mob/living/user, obj/item/I, tool_type)
	return

/turf/open/floor/holofloor/burn_tile()
	return //you can't burn a hologram!

/turf/open/floor/holofloor/break_tile()
	return //you can't break a hologram!

/turf/open/floor/holofloor/plating
	name = "holodeck projector floor"
	icon_state = "engine"

/turf/open/floor/holofloor/chapel
	name = "chapel floor"
	icon_state = "chapel"

/turf/open/floor/holofloor/chapel/bottom_left
	direction = WEST

/turf/open/floor/holofloor/chapel/top_right
	direction = EAST

/turf/open/floor/holofloor/chapel/bottom_right

/turf/open/floor/holofloor/chapel/top_left
	direction = NORTH

/turf/open/floor/holofloor/chapel/Initialize(mapload)
	. = ..()
	if (direction != SOUTH)
		setDir(direction)

/turf/open/floor/holofloor/white
	name = "white floor"
	icon_state = "white"

/turf/open/floor/holofloor/pure_white
	name = "white floor"
	desc = "Hey look, it's the inside of a greytiders mind!"
	icon_state = "pure_white"

/turf/open/floor/holofloor/plating/burnmix
	name = "burn-mix floor"
	initial_gas_mix = BURNMIX_ATMOS

/turf/open/floor/holofloor/grass
	gender = PLURAL
	name = "lush grass"
	desc = "Looking at the lushious field, you suddenly feel homesick."
	icon_state = "grass0"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/grass/Initialize(mapload)
	. = ..()
	icon_state = "grass[rand(0,3)]"

/turf/open/floor/holofloor/beach
	gender = PLURAL
	name = "sand"
	desc = "This is better than a vacation, since you're still getting paid."
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/beach/coast_t
	gender = NEUTER
	name = "coastline"
	icon_state = "sandwater_t"

/turf/open/floor/holofloor/beach/coast_b
	gender = NEUTER
	name = "coastline"
	icon_state = "sandwater_b"

/turf/open/floor/holofloor/beach/water
	name = "water"
	desc = "Gives the impression you can walk on water. Chaplains love it."
	icon_state = "water"
	bullet_sizzle = TRUE

/turf/open/floor/holofloor/asteroid
	gender = PLURAL
	name = "asteroid sand"
	desc = "The sand crunches beneath your feet, though it feels soft to the touch."
	icon_state = "asteroid"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/asteroid/Initialize(mapload)
	icon_state = "asteroid[rand(0, 12)]"
	. = ..()

/turf/open/floor/holofloor/basalt
	gender = PLURAL
	name = "basalt"
	desc = "You still feel hot, despite the cool walls of the holodeck."
	icon_state = "basalt0"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/basalt/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open/floor/holofloor/space
	name = "\proper space"
	desc = "Space-looking floor. Thankfully, the deadly aspects of space are not emulated here."
	icon = 'icons/turf/space.dmi'
	icon_state = "space"
	plane = PLANE_SPACE

/turf/open/floor/holofloor/hyperspace
	name = "\proper hyperspace"
	desc = "Gives the impression of moving at hyper-speed, without moving. May induce motion sickness."
	icon = 'icons/turf/space.dmi'
	icon_state = "speedspace_ns_1"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/hyperspace/Initialize(mapload)
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"
	. = ..()

/turf/open/floor/holofloor/hyperspace/ns/Initialize(mapload)
	. = ..()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"

/turf/open/floor/holofloor/carpet
	name = "carpet"
	desc = "Electrically inviting."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET
	canSmoothWith = SMOOTH_GROUP_CARPET
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/carpet/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_appearance)), 1)

/turf/open/floor/holofloor/carpet/update_icon(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && overfloor_placed && smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)

/turf/open/floor/holofloor/wood
	icon_state = "wood"
	desc = "Makes you feel at home."
	tiled_dirt = FALSE

/turf/open/floor/holofloor/snow
	gender = PLURAL
	name = "snow"
	desc = "The puffy snow clumps together to make a solid-looking floor, though it sinks beneath your feet."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	slowdown = 2
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/snow/cold
	initial_gas_mix = "nob=7500;TEMP=2.7"

/turf/open/floor/holofloor/dark
	icon_state = "darkfull"
	desc = "The surrounding enviroment is so dark you can hardly see yourself."

/turf/open/floor/holofloor/stairs
	name = "stairs"
	icon_state = "stairs"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/stairs/left
	icon_state = "stairs-l"

/turf/open/floor/holofloor/stairs/medium
	icon_state = "stairs-m"

/turf/open/floor/holofloor/stairs/right
	icon_state = "stairs-r"

/turf/open/floor/holofloor/chess_white
	icon_state = "white_large"
	color = "#eeeed2"

/turf/open/floor/holofloor/chess_black
	icon_state = "white_large"
	color = "#93b570"
