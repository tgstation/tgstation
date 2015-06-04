/turf/simulated/floor/plasteel
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")

/turf/simulated/floor/plasteel/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		icon_state = icon_regular_floor


/turf/simulated/floor/plasteel/black
	icon_state = "dark"


/turf/simulated/floor/plasteel/green
	icon_state = "greenfull"
/turf/simulated/floor/plasteel/green/side
	icon_state = "green"
/turf/simulated/floor/plasteel/green/corner
	icon_state = "greencorner"


/turf/simulated/floor/plasteel/darkgreen
	icon_state = "darkgreenfull"
/turf/simulated/floor/plasteel/darkgreen/side
	icon_state = "darkgreen"
/turf/simulated/floor/plasteel/darkgreen/corner
	icon_state = "darkgreencorners"


/turf/simulated/floor/plasteel/brown
	icon_state = "brown"
/turf/simulated/floor/plasteel/brown/corner
	icon_state = "browncorner"


/turf/simulated/floor/plasteel/red
	icon_state = "redfull"
/turf/simulated/floor/plasteel/red/side
	icon_state = "red"
/turf/simulated/floor/plasteel/red/corner
	icon_state = "redcorner"


/turf/simulated/floor/plasteel/darkred
	icon_state = "darkredfull"
/turf/simulated/floor/plasteel/darkred/side
	icon_state = "darkred"
/turf/simulated/floor/plasteel/darkred/corner
	icon_state = "darkredcorners"


/turf/simulated/floor/plasteel/neutral
	icon_state = "neutralfull"
/turf/simulated/floor/plasteel/neutral/side
	icon_state = "neutral"
/turf/simulated/floor/plasteel/neutral/corner
	icon_state = "neutralcorner"


/turf/simulated/floor/plasteel/warning
	icon_state = "warning"
/turf/simulated/floor/plasteel/warning/corner
	icon_state = "warningcorner"


/turf/simulated/floor/plasteel/redyellow
	icon_state = "redyellowfull"
/turf/simulated/floor/plasteel/redyellow/side
	icon_state = "redyellow"


/turf/simulated/floor/plasteel/redblue
	icon_state = "redbluefull"
/turf/simulated/floor/plasteel/redblue/side
	icon_state = "redblue"


/turf/simulated/floor/plasteel/darkwarning
	icon_state = "warndark"
/turf/simulated/floor/plasteel/darkwarning/corner
	icon_state = "warndarkcorners"


/turf/simulated/floor/plasteel/yellowsiding
	icon_state = "yellowsiding"
/turf/simulated/floor/plasteel/yellowsiding/corner
	icon_state = "yellowcornersiding"


/turf/simulated/floor/plasteel/podhatch
	icon_state = "podhatch"
/turf/simulated/floor/plasteel/podhatch/corner
	icon_state = "podhatchcorner"


/turf/simulated/floor/plasteel/loadingarea
	icon_state = "loadingarea"

/turf/simulated/floor/plasteel/delivery
	icon_state = "delivery"

/turf/simulated/floor/plasteel/freezer
	icon_state = "freezerfloor"

/turf/simulated/floor/plasteel/bar
	icon_state = "bar"

/turf/simulated/floor/plasteel/grimy
	icon_state = "grimy"

/turf/simulated/floor/plasteel/cafeteria
	icon_state = "cafeteria"

/turf/simulated/floor/plasteel/cult
	icon_state = "cult"
	name = "engraved floor"

/turf/simulated/floor/plasteel/cult/narsie_act()
	return


/turf/simulated/floor/plasteel/shuttle
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "floor"

/turf/simulated/floor/plasteel/shuttle/red
	name = "Brig floor"
	icon_state = "floor4"