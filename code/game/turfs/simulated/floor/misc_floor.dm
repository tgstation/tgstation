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

/turf/simulated/floor/plating/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/plating/beach/water
	name = "Water"
	icon_state = "water"

/turf/simulated/floor/plating/ironsand/New()
	..()
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/simulated/floor/plating/snow/ex_act(severity, target)
	contents_explosion(severity, target)

/turf/simulated/floor/plating/snow/gravsnow
	icon_state = "gravsnow"

/turf/simulated/floor/plating/snow/gravsnow/corner
	icon_state = "gravsnow_corner"

/turf/simulated/floor/plating/snow/gravsnow/surround
	icon_state = "gravsnow_surround"

/turf/simulated/floor/noslip
	name = "high-traction floor"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	broken_states = list("noslip-damaged1","noslip-damaged2","noslip-damaged3")
	burnt_states = list("noslip-scorched1","noslip-scorched2")

/turf/simulated/floor/noslip/MakeSlippery()
	return
