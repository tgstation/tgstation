/turf/open/floor/goonplaque
	name = "Commemorative Plaque"
	icon_state = "plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/vault
	icon_state = "rockvault"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/bluegrid/New()
	..()
	nuke_tiles += src

/turf/open/floor/bluegrid/Destroy()
	nuke_tiles -= src
	return ..()

/turf/open/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/plating/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

/turf/open/floor/plating/beach/ex_act(severity, target)
	contents_explosion(severity, target)

/turf/open/floor/plating/beach/sand
	name = "Sand"
	icon_state = "sand"
	baseturf = /turf/open/floor/plating/beach/sand

/turf/open/floor/plating/beach/coastline_t
	name = "Coastline"
	icon_state = "sandwater_t"
	baseturf = /turf/open/floor/plating/beach/coastline_t

/turf/open/floor/plating/beach/coastline_b
	name = "Coastline"
	icon_state = "sandwater_b"
	baseturf = /turf/open/floor/plating/beach/coastline_b

/turf/open/floor/plating/beach/water
	name = "Water"
	icon_state = "water"
	baseturf = /turf/open/floor/plating/beach/water

/turf/open/floor/plating/ironsand/New()
	..()
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"

/turf/open/floor/plating/ironsand/burn_tile()
	return

/turf/open/floor/plating/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/snow.dmi'
	icon_state = "ice"
	temperature = 180
	baseturf = /turf/open/floor/plating/ice
	slowdown = 1
	wet = TURF_WET_ICE

/turf/open/floor/plating/ice/colder
	temperature = 140

/turf/open/floor/plating/ice/temperate
	temperature = 255.37

/turf/open/floor/plating/ice/break_tile()
	return

/turf/open/floor/plating/ice/burn_tile()
	return

/turf/open/floor/plating/snowed
	name = "snowed-over plating"
	desc = "A section of plating covered in a light layer of snow."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snowplating"
	temperature = 180

/turf/open/floor/plating/snowed/colder
	temperature = 140

/turf/open/floor/plating/snowed/temperatre
	temperature = 255.37

/turf/open/floor/noslip
	name = "high-traction floor"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	broken_states = list("noslip-damaged1","noslip-damaged2","noslip-damaged3")
	burnt_states = list("noslip-scorched1","noslip-scorched2")
	slowdown = -0.3

/turf/open/floor/noslip/MakeSlippery()
	return
