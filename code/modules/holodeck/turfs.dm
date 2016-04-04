/turf/open/floor/holofloor
	icon_state = "floor"
	thermal_conductivity = 0
	broken_states = list("engine")
	burnt_states = list("engine")

/turf/open/floor/holofloor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return // HOLOFLOOR DOES NOT GIVE A FUCK

/turf/open/floor/holofloor/plating
	name = "Holodeck Projector Floor"
	icon_state = "engine"

/turf/open/floor/holofloor/grass
	gender = PLURAL
	name = "lush grass"
	icon_state = "grass"

/turf/open/floor/holofloor/beach
	name = "sand"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"

/turf/open/floor/holofloor/beach/coast_t
	name = "coastline"
	icon_state = "sandwater_t"

/turf/open/floor/holofloor/beach/coast_b
	name = "coastline"
	icon_state = "sandwater_b"

/turf/open/floor/holofloor/beach/water
	name = "water"
	icon_state = "water"

/turf/open/floor/holofloor/asteroid
	name = "Asteroid"
	icon_state = "asteroid0"

/turf/open/floor/holofloor/asteroid/New()
	icon_state = "asteroid[pick(0,1,2,3,4,5,6,7,8,9,10,11,12)]"
	..()

/turf/open/floor/holofloor/space
	name = "Space"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"

/turf/open/floor/holofloor/space/New()
	icon_state = SPACE_ICON_STATE // so realistic
	..()

/turf/open/floor/holofloor/hyperspace
	name = "Hyperspace"
	icon = 'icons/turf/space.dmi'
	icon_state = "speedspace_ew_1"

/turf/open/floor/holofloor/hyperspace/New()
	icon_state = "speedspace_ew_[(x + 5*y + (y%2+1)*7)%15+1]"
	..()

/turf/open/floor/holofloor/hyperspace/ns/New()
	..()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"

/turf/open/floor/holofloor/carpet
	name = "Carpet"
	desc = "Electrically inviting."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	broken_states = list("damaged")
	smooth = SMOOTH_TRUE
	canSmoothWith = null

/turf/open/floor/holofloor/carpet/New()
	..()
	spawn(1)
		update_icon()

/turf/open/floor/holofloor/carpet/update_icon()
	if(!..())
		return 0
	if(intact)
		queue_smooth(src)
