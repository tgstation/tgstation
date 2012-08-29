/turf/simulated/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

/turf/simulated/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/simulated/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/beach/water
	name = "Water"
	icon_state = "water"


/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_tile = new/obj/item/stack/tile/grass

	New()
		floor_tile.New() //I guess New() isn't run on objects spawned without the definition of a turf to house them, ah well.
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in cardinal)
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly