/turf/simulated/floor/goonplaque
	name = "Commemorative Plaque"
	icon_state = "plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
	floor_tile = /obj/item/stack/tile/plasteel

/turf/simulated/floor/vault
	icon_state = "rockvault"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/simulated/floor/bluegrid/New()
	..()
	nuke_tiles += src

/turf/simulated/floor/bluegrid/Destroy()
	nuke_tiles -= src
	return ..()

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/simulated/floor/plating/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

/turf/simulated/floor/plating/beach/ex_act(severity, target)
	contents_explosion(severity, target)

/turf/simulated/floor/plating/beach/sand
	name = "Sand"
	icon_state = "sand"
	baseturf = /turf/simulated/floor/plating/beach/sand

/turf/simulated/floor/plating/beach/coastline_t
	name = "Coastline"
	icon_state = "sandwater_t"
	baseturf = /turf/simulated/floor/plating/beach/coastline_t

/turf/simulated/floor/plating/beach/coastline_b
	name = "Coastline"
	icon_state = "sandwater_b"
	baseturf = /turf/simulated/floor/plating/beach/coastline_b

/turf/simulated/floor/plating/beach/water
	name = "Water"
	icon_state = "water"
	baseturf = /turf/simulated/floor/plating/beach/water

/turf/simulated/floor/plating/ironsand/New()
	..()
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/ironsand/burn_tile()
	return

/turf/simulated/floor/plating/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/snow.dmi'
	icon_state = "ice"
	temperature = 180
	baseturf = /turf/simulated/floor/plating/ice
	slowdown = 1
	wet = TURF_WET_ICE

/turf/simulated/floor/plating/ice/colder
	temperature = 140

/turf/simulated/floor/plating/ice/temperate
	temperature = 255.37

/turf/simulated/floor/plating/ice/break_tile()
	return

/turf/simulated/floor/plating/ice/burn_tile()
	return

/turf/simulated/floor/plating/snowed
	name = "snowed-over plating"
	desc = "A section of plating covered in a light layer of snow."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snowplating"
	temperature = 180

/turf/simulated/floor/plating/snowed/colder
	temperature = 140

/turf/simulated/floor/plating/snowed/temperate
	temperature = 255.37

/turf/simulated/floor/noslip
	name = "high-traction floor"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	broken_states = list("noslip-damaged1","noslip-damaged2","noslip-damaged3")
	burnt_states = list("noslip-scorched1","noslip-scorched2")
	slowdown = -0.3

/turf/simulated/floor/noslip/MakeSlippery()
	return
