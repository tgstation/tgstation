/* In this file:
 *
 * Commemorative Plaque
 * Vault floor
 * Vault wall (why)
 * Blue grid
 * Green grid
 * Shuttle floor
 * Beach
 * Ocean
 * Iron Sand
 * Snow
 * High-traction
 * Xenobio floors
 */

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
	ignoredirt = 1
	baseturf = /turf/simulated/floor/plating/beach/sand

/turf/simulated/floor/plating/beach/burn_tile()
	return //unburnable

/turf/simulated/floor/plating/beach/break_tile()
	return //unbreakable

/turf/simulated/floor/beach/ex_act(severity, target)
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
	ignoredirt = 1

/turf/simulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	ignoredirt = 1

/turf/simulated/floor/plating/snow/burn_tile()
	return //unburnable

/turf/simulated/floor/plating/snow/break_tile()
	return //unbreakable

/turf/simulated/floor/plating/snow/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

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


/turf/simulated/floor/plating/sand
	name = "sand"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	baseturf = /turf/simulated/floor/plating/sand


/turf/simulated/floor/plating/sand/burn_tile()
	return //unburnable

/turf/simulated/floor/plating/sand/break_tile()
	return //unbreakable


/turf/simulated/floor/plating/maze
	name = "maze floor"
	heat_capacity = 6000000 // it's like another shoah
	icon = 'icons/misc/beach.dmi'
	icon_state= "sand"
	toxins = 229.8
	oxygen = 0
	carbon_dioxide = 173.4
	nitrogen = 135.1
	temperature = 363.9
	baseturf = /turf/simulated/floor/plating/maze

/turf/simulated/floor/plating/maze/burn_tile()
	return //unburnable
/turf/simulated/floor/plating/maze/break_tile()
	return //unbreakable

/turf/simulated/floor/plating/dust
	name = "dust"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	baseturf = /turf/simulated/floor/plating/dust

/turf/simulated/floor/plating/dust/burn_tile()
	return //unburnable

/turf/simulated/floor/plating/dust/break_tile()
	return //unbreakable

/turf/simulated/floor/plating/dust/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plating/sand/airless

	oxygen = 0
	nitrogen = 0
	temperature = TCMB



/obj/item/stack/tile/bluespace
	name = "bluespace floor tile"
	singular_name = "floor tile"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds"
	icon_state = "tile-bluespace"
	w_class = 3.0
	force = 6.0
	materials = list(MAT_METAL=937.5)
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/simulated/floor/bluespace


/turf/simulated/floor/bluespace
	slowdown = -1
	icon_state = "bluespace"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds"
	floor_tile = /obj/item/stack/tile/bluespace


/obj/item/stack/tile/sepia
	name = "sepia floor tile"
	singular_name = "floor tile"
	desc = "Time seems to flow very slowly around these tiles"
	icon_state = "tile-sepia"
	w_class = 3.0
	force = 6.0
	materials = list(MAT_METAL=937.5)
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/simulated/floor/sepia


/turf/simulated/floor/sepia
	slowdown = 2
	icon_state = "sepia"
	desc = "Time seems to flow very slowly around these tiles"
	floor_tile = /obj/item/stack/tile/sepia