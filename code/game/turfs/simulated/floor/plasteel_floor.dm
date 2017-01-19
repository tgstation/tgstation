/turf/open/floor/plasteel
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")

/turf/open/floor/plasteel/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		icon_state = icon_regular_floor


/turf/open/floor/plasteel/airless
	initial_gas_mix = "TEMP=2.7"


/turf/open/floor/plasteel/black
	icon_state = "dark"
/turf/open/floor/plasteel/airless/black
	icon_state = "dark"

/turf/open/floor/plasteel/white
	icon_state = "white"
/turf/open/floor/plasteel/airless/white
	icon_state = "white"

/turf/open/floor/plasteel/podhatch
	icon_state = "podhatch"
/turf/open/floor/plasteel/podhatch/corner
	icon_state = "podhatchcorner"

/turf/open/floor/plasteel/circuit
	icon_state = "bcircuit"
/turf/open/floor/plasteel/airless/circuit
	icon_state = "bcircuit"
/turf/open/floor/plasteel/circuit/off
	icon_state = "bcircuitoff"

/turf/open/floor/plasteel/circuit/gcircuit
	icon_state = "gcircuit"
/turf/open/floor/plasteel/airless/circuit/gcircuit
	icon_state = "gcircuit"
/turf/open/floor/plasteel/circuit/gcircuit/off
	icon_state = "gcircuitoff"
/turf/open/floor/plasteel/circuit/gcircuit/animated
	icon_state = "gcircuitanim"

/turf/open/floor/plasteel/circuit/rcircuit
	icon_state = "rcircuit"
/turf/open/floor/plasteel/circuit/rcircuit/animated
	icon_state = "rcircuitanim"



/turf/open/floor/plasteel/loadingarea
	icon_state = "loadingarea"
/turf/open/floor/plasteel/loadingarea/dirty
	icon_state = "loadingareadirty1"
/turf/open/floor/plasteel/loadingarea/dirtydirty
	icon_state = "loadingareadirty2"


/turf/open/floor/plasteel/shuttle
	icon_state = "shuttlefloor"
	floor_tile = /obj/item/stack/tile/mineral/titanium //old shuttle floors so i don't have to change the map paths in this pr
/turf/open/floor/plasteel/shuttle/red
	name = "Brig floor"
	icon_state = "shuttlefloor4"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium
/turf/open/floor/plasteel/shuttle/yellow
	icon_state = "shuttlefloor2"
/turf/open/floor/plasteel/shuttle/white
	icon_state = "shuttlefloor3"
/turf/open/floor/plasteel/shuttle/purple
	icon_state = "shuttlefloor5"

/turf/open/floor/plasteel/airless/shuttle
	icon_state = "shuttlefloor"
/turf/open/floor/plasteel/airless/shuttle/red
	name = "Brig floor"
	icon_state = "shuttlefloor4"
/turf/open/floor/plasteel/airless/shuttle/yellow
	icon_state = "shuttlefloor2"
/turf/open/floor/plasteel/airless/shuttle/white
	icon_state = "shuttlefloor3"
/turf/open/floor/plasteel/airless/shuttle/purple
	icon_state = "shuttlefloor5"


/turf/open/floor/plasteel/asteroid
	icon_state = "asteroidfloor"
/turf/open/floor/plasteel/airless/asteroid
	icon_state = "asteroidfloor"

/turf/open/floor/plasteel/recharge_floor
	icon_state = "recharge_floor"
/turf/open/floor/plasteel/recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"

/turf/open/floor/plasteel/solarpanel
	icon_state = "solarpanel"
/turf/open/floor/plasteel/airless/solarpanel
	icon_state = "solarpanel"

/turf/open/floor/plasteel/freezer
	icon_state = "freezerfloor"

/turf/open/floor/plasteel/cult
	icon_state = "cult"
	name = "engraved floor"

/turf/open/floor/plasteel/vaporwave
	icon_state = "pinkblack"

/turf/open/floor/plasteel/goonplaque
	icon_state = "plaque"
	name = "Commemorative Plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."

/turf/open/floor/plasteel/cult/narsie_act()
	return

/turf/open/floor/plasteel/cult/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/plasteel/stage_bottom
	icon_state = "stage_bottom"
/turf/open/floor/plasteel/stage_left
	icon_state = "stage_left"
/turf/open/floor/plasteel/stage_bleft
	icon_state = "stage_bleft"


/turf/open/floor/plasteel/stairs
	icon_state = "stairs"
/turf/open/floor/plasteel/stairs/left
	icon_state = "stairs-l"
/turf/open/floor/plasteel/stairs/medium
	icon_state = "stairs-m"
/turf/open/floor/plasteel/stairs/right
	icon_state = "stairs-r"
/turf/open/floor/plasteel/stairs/old
	icon_state = "stairs-old"

/turf/open/floor/plasteel/rockvault
	icon_state = "rockvault"
/turf/open/floor/plasteel/rockvault/alien
	icon_state = "alienvault"
/turf/open/floor/plasteel/rockvault/sandstone
	icon_state = "sandstonevault"


/turf/open/floor/plasteel/elevatorshaft
	icon_state = "elevatorshaft"

/turf/open/floor/plasteel/bluespace
	icon_state = "bluespace"

/turf/open/floor/plasteel/sepia
	icon_state = "sepia"

/turf/open/floor/plasteel/sandy
	icon_state = "sandy"
	baseturf = /turf/open/floor/plating/beach/sand

/turf/open/floor/plasteel/sandeffect
	icon_state = "sandeffect"

/turf/open/floor/plasteel/sandeffect/warning
	icon_state = "warningsandeffect"

/turf/open/floor/plasteel/sandeffect/warning/corner
	icon_state = "warningsandeffectcorners"
