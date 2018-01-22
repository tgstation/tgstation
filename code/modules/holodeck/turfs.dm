/turf/open2/floor/holofloor
	icon_state = "floor"
	thermal_conductivity = 0
	flags_1 = NONE

/turf/open2/floor/holofloor/attackby(obj/item/I, mob/living/user)
	return // HOLOFLOOR DOES NOT GIVE A FUCK

/turf/open2/floor/holofloor/burn_tile()
	return //you can't burn a hologram!

/turf/open2/floor/holofloor/break_tile()
	return //you can't break a hologram!

/turf/open2/floor/holofloor/plating
	name = "holodeck projector floor"
	icon_state = "engine"

/turf/open2/floor/holofloor/plating/burnmix
	name = "burn-mix floor"
	initial_gas_mix = "o2=2500;plasma=5000;TEMP=370"

/turf/open2/floor/holofloor/grass
	gender = PLURAL
	name = "lush grass"
	icon_state = "grass"

/turf/open2/floor/holofloor/beach
	name = "sand"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"

/turf/open2/floor/holofloor/beach/coast_t
	name = "coastline"
	icon_state = "sandwater_t"

/turf/open2/floor/holofloor/beach/coast_b
	name = "coastline"
	icon_state = "sandwater_b"

/turf/open2/floor/holofloor/beach/water
	name = "water"
	icon_state = "water"

/turf/open2/floor/holofloor/asteroid
	name = "asteroid"
	icon_state = "asteroid0"

/turf/open2/floor/holofloor/asteroid/Initialize()
	icon_state = "asteroid[rand(0, 12)]"
	. = ..()

/turf/open2/floor/holofloor/basalt
	name = "basalt"
	icon_state = "basalt0"

/turf/open2/floor/holofloor/basalt/Initialize()
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open2/floor/holofloor/space
	name = "Space"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"

/turf/open2/floor/holofloor/space/Initialize()
	icon_state = SPACE_ICON_STATE // so realistic
	. = ..()

/turf/open2/floor/holofloor/hyperspace
	name = "hyperspace"
	icon = 'icons/turf/space.dmi'
	icon_state = "speedspace_ns_1"

/turf/open2/floor/holofloor/hyperspace/Initialize()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"
	. = ..()

/turf/open2/floor/holofloor/hyperspace/ns/Initialize()
	. = ..()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"

/turf/open2/floor/holofloor/carpet
	name = "carpet"
	desc = "Electrically inviting."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	smooth = SMOOTH_TRUE
	canSmoothWith = null

/turf/open2/floor/holofloor/carpet/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/update_icon), 1)

/turf/open2/floor/holofloor/carpet/update_icon()
	if(!..())
		return 0
	if(intact)
		queue_smooth(src)

/turf/open2/floor/holofloor/snow
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	slowdown = 2

/turf/open2/floor/holofloor/snow/cold
	initial_gas_mix = "nob=7500;TEMP=2.7"

/turf/open2/floor/holofloor/asteroid
	name = "asteroid sand"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
