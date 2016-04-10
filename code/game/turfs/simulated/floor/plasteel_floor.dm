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
/turf/simulated/floor/plasteel/black/side
	icon_state = "black" //NOTICE ME SEMPAI: floors.dmi contains two sprites named black, remove the incorrect one
/turf/simulated/floor/plasteel/black/corner
	icon_state = "blackcorner"


/turf/simulated/floor/plasteel/white
	icon_state = "white"
/turf/simulated/floor/plasteel/white/side
	icon_state = "whitehall"
/turf/simulated/floor/plasteel/white/corner
	icon_state = "whitecorner"



/turf/simulated/floor/plasteel/brown
	icon_state = "brown"
/turf/simulated/floor/plasteel/brown/corner
	icon_state = "browncorner"

/turf/simulated/floor/plasteel/darkbrown
	icon_state = "darkbrownfull"
/turf/simulated/floor/plasteel/darkbrown/side
	icon_state = "darkbrown"
/turf/simulated/floor/plasteel/darkbrown/corner
	icon_state = "darkbrowncorners"



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

/turf/simulated/floor/plasteel/whitegreen
	icon_state = "whitegreenfull"
/turf/simulated/floor/plasteel/whitegreen/side
	icon_state = "whitegreen"
/turf/simulated/floor/plasteel/whitegreen/corner
	icon_state = "whitegreencorner"



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

/turf/simulated/floor/plasteel/whitered
	icon_state = "whiteredfull"
/turf/simulated/floor/plasteel/whitered/side
	icon_state = "whitered"
/turf/simulated/floor/plasteel/whitered/corner
	icon_state = "whiteredcorner"



/turf/simulated/floor/plasteel/blue
	icon_state = "bluefull"
/turf/simulated/floor/plasteel/blue/side
	icon_state = "blue"
/turf/simulated/floor/plasteel/blue/corner
	icon_state = "bluecorner"

/turf/simulated/floor/plasteel/darkblue
	icon_state = "darkbluefull"
/turf/simulated/floor/plasteel/darkblue/side
	icon_state = "darkblue"
/turf/simulated/floor/plasteel/darkblue/corner
	icon_state = "darkbluecorners"

/turf/simulated/floor/plasteel/whiteblue
	icon_state = "whitebluefull"
/turf/simulated/floor/plasteel/whiteblue/side
	icon_state = "whiteblue"
/turf/simulated/floor/plasteel/whiteblue/corner
	icon_state = "whitebluecorner"



/turf/simulated/floor/plasteel/yellow
	icon_state = "yellowfull"
/turf/simulated/floor/plasteel/yellow/side
	icon_state = "yellow"
/turf/simulated/floor/plasteel/yellow/corner
	icon_state = "yellowcorner"

/turf/simulated/floor/plasteel/darkyellow
	icon_state = "darkyellowfull"
/turf/simulated/floor/plasteel/darkyellow/side
	icon_state = "darkyellow"
/turf/simulated/floor/plasteel/darkyellow/corner
	icon_state = "darkyellowcorners"

/turf/simulated/floor/plasteel/whiteyellow
	icon_state = "whiteyellowfull"
/turf/simulated/floor/plasteel/whiteyellow/side
	icon_state = "whiteyellow"
/turf/simulated/floor/plasteel/whiteyellow/corner
	icon_state = "whiteyellowcorner"



/turf/simulated/floor/plasteel/purple
	icon_state = "purplefull"
/turf/simulated/floor/plasteel/purple/side
	icon_state = "purple"
/turf/simulated/floor/plasteel/purple/corner
	icon_state = "purplecorner"

/turf/simulated/floor/plasteel/darkpurple
	icon_state = "darkpurplefull"
/turf/simulated/floor/plasteel/darkpurple/side
	icon_state = "darkpurple"
/turf/simulated/floor/plasteel/darkpurple/corner
	icon_state = "darkpurplecorners"

/turf/simulated/floor/plasteel/whitepurple
	icon_state = "whitepurplefull"
/turf/simulated/floor/plasteel/whitepurple/side
	icon_state = "whitepurple"
/turf/simulated/floor/plasteel/whitepurple/corner
	icon_state = "whitepurplecorner"


/turf/simulated/floor/plasteel/orange
	icon_state = "orangefull"
/turf/simulated/floor/plasteel/orange/side
	icon_state = "orange"
/turf/simulated/floor/plasteel/orange/corner
	icon_state = "orangecorner"


/turf/simulated/floor/plasteel/neutral
	icon_state = "neutralfull"
/turf/simulated/floor/plasteel/neutral/side
	icon_state = "neutral"
/turf/simulated/floor/plasteel/neutral/corner
	icon_state = "neutralcorner"


/turf/simulated/floor/plasteel/arrival
	icon_state = "arrival"
/turf/simulated/floor/plasteel/arrival/corner
	icon_state = "arrivalcorner"


/turf/simulated/floor/plasteel/escape
	icon_state = "escape"
/turf/simulated/floor/plasteel/escape/corner
	icon_state = "escapecorner"


/turf/simulated/floor/plasteel/caution
	icon_state = "caution"
/turf/simulated/floor/plasteel/caution/corner
	icon_state = "cautioncorner"


/turf/simulated/floor/plasteel/warning
	icon_state = "warning"
/turf/simulated/floor/plasteel/warning/corner
	icon_state = "warningcorner"


/turf/simulated/floor/plasteel/warnplate
	icon_state = "warnplate"
/turf/simulated/floor/plasteel/warnplate/corner
	icon_state = "warnplatecorner"


/turf/simulated/floor/plasteel/warnwhite
	icon_state = "warnwhite"
/turf/simulated/floor/plasteel/warnwhite/corner
	icon_state = "warnwhitecorner"


/turf/simulated/floor/plasteel/whitebot
	icon_state = "whitebot"
/turf/simulated/floor/plasteel/whitebot/delivery
	icon_state = "whitedelivery"


/turf/simulated/floor/plasteel/redyellow
	icon_state = "redyellowfull"
/turf/simulated/floor/plasteel/redyellow/side
	icon_state = "redyellow"


/turf/simulated/floor/plasteel/redblue
	icon_state = "redbluefull"
/turf/simulated/floor/plasteel/redblue/blueside
	icon_state = "bluered"
/turf/simulated/floor/plasteel/redblue/redside
	icon_state = "redblue"


/turf/simulated/floor/plasteel/redgreen
	icon_state = "redgreenfull"
/turf/simulated/floor/plasteel/redgreen/side
	icon_state = "redgreen"


/turf/simulated/floor/plasteel/greenyellow
	icon_state = "greenyellowfull"
/turf/simulated/floor/plasteel/greenyellow/side
	icon_state = "greenyellow"


/turf/simulated/floor/plasteel/greenblue
	icon_state = "greenbluefull"
/turf/simulated/floor/plasteel/greenblue/side
	icon_state = "greenblue"


/turf/simulated/floor/plasteel/blueyellow
	icon_state = "blueyellowfull"
/turf/simulated/floor/plasteel/blueyellow/side
	icon_state = "blueyellow"


/turf/simulated/floor/plasteel/darkwarning
	icon_state = "warndark"
/turf/simulated/floor/plasteel/darkwarning/corner
	icon_state = "warndarkcorners"

/turf/simulated/floor/plasteel/warningline
	icon_state = "warningline"
/turf/simulated/floor/plasteel/warningline/corner
	icon_state = "warninglinecorners"

/turf/simulated/floor/plasteel/yellowsiding
	icon_state = "yellowsiding"
/turf/simulated/floor/plasteel/yellowsiding/corner
	icon_state = "yellowcornersiding"


/turf/simulated/floor/plasteel/podhatch
	icon_state = "podhatch"
/turf/simulated/floor/plasteel/podhatch/corner
	icon_state = "podhatchcorner"



/turf/simulated/floor/plasteel/circuit
	icon_state = "bcircuit"
/turf/simulated/floor/plasteel/circuit/off
	icon_state = "bcircuitoff"

/turf/simulated/floor/plasteel/circuit/gcircuit
	icon_state = "gcircuit"
/turf/simulated/floor/plasteel/circuit/gcircuit/off
	icon_state = "gcircuitoff"
/turf/simulated/floor/plasteel/circuit/gcircuit/animated
	icon_state = "gcircuitanim"

/turf/simulated/floor/plasteel/circuit/rcircuit
	icon_state = "rcircuit"
/turf/simulated/floor/plasteel/circuit/rcircuit/animated
	icon_state = "rcircuitanim"



/turf/simulated/floor/plasteel/loadingarea
	icon_state = "loadingarea"
/turf/simulated/floor/plasteel/loadingarea/dirty
	icon_state = "loadingareadirty1"
/turf/simulated/floor/plasteel/loadingarea/dirtydirty
	icon_state = "loadingareadirty2"


/turf/simulated/floor/plasteel/shuttle
	icon_state = "shuttlefloor"
/turf/simulated/floor/plasteel/shuttle/red
	name = "Brig floor"
	icon_state = "shuttlefloor4"
/turf/simulated/floor/plasteel/shuttle/yellow
	icon_state = "shuttlefloor2"
/turf/simulated/floor/plasteel/shuttle/white
	icon_state = "shuttlefloor3"
/turf/simulated/floor/plasteel/shuttle/purple
	icon_state = "shuttlefloor5"


/turf/simulated/floor/plasteel/asteroid
	icon_state = "asteroidfloor"
/turf/simulated/floor/plasteel/asteroid/warning
	icon_state = "asteroidwarning"


/turf/simulated/floor/plasteel/recharge_floor
	icon_state = "recharge_floor"
/turf/simulated/floor/plasteel/recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"


/turf/simulated/floor/plasteel/chapel
	icon_state = "chapel"

/turf/simulated/floor/plasteel/showroomfloor
	icon_state = "showroomfloor"

/turf/simulated/floor/plasteel/floorgrime
	icon_state = "floorgrime"

/turf/simulated/floor/plasteel/solarpanel
	icon_state = "solarpanel"

/turf/simulated/floor/plasteel/cmo
	icon_state = "cmo"

/turf/simulated/floor/plasteel/barber
	icon_state = "barber"

/turf/simulated/floor/plasteel/hydrofloor
	icon_state = "hydrofloor"

/turf/simulated/floor/plasteel/delivery
	icon_state = "delivery"

/turf/simulated/floor/plasteel/bot
	icon_state = "bot"

/turf/simulated/floor/plasteel/freezer
	icon_state = "freezerfloor"

/turf/simulated/floor/plasteel/bar
	icon_state = "bar"

/turf/simulated/floor/plasteel/grimy
	icon_state = "grimy"

/turf/simulated/floor/plasteel/cafeteria
	icon_state = "cafeteria"

/turf/simulated/floor/plasteel/vault
	icon_state = "vault"

/turf/simulated/floor/plasteel/cult
	icon_state = "cult"
	name = "engraved floor"

/turf/simulated/floor/plasteel/goonplaque
	icon_state = "plaque"
	name = "Commemorative Plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."

/turf/simulated/floor/plasteel/cult/narsie_act()
	return

/turf/simulated/floor/plasteel/cult/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB






//
//unused? remove?
//
/turf/simulated/floor/plasteel/stage_bottom
	icon_state = "stage_bottom"
/turf/simulated/floor/plasteel/stage_left
	icon_state = "stage_left"
/turf/simulated/floor/plasteel/stage_bleft
	icon_state = "stage_bleft"


/turf/simulated/floor/plasteel/stairs
	icon_state = "stairs"
/turf/simulated/floor/plasteel/stairs/left
	icon_state = "stairs-l"
/turf/simulated/floor/plasteel/stairs/medium
	icon_state = "stairs-m"
/turf/simulated/floor/plasteel/stairs/right
	icon_state = "stairs-r"
/turf/simulated/floor/plasteel/stairs/old
	icon_state = "stairs-old"


/turf/simulated/floor/plasteel/brownold
	icon_state = "brownold"
/turf/simulated/floor/plasteel/brownold/corner
	icon_state = "browncornerold"


/turf/simulated/floor/plasteel/rockvault
	icon_state = "rockvault"
/turf/simulated/floor/plasteel/rockvault/alien
	icon_state = "alienvault"
/turf/simulated/floor/plasteel/rockvault/sandstone
	icon_state = "sandstonevault"


/turf/simulated/floor/plasteel/elevatorshaft
	icon_state = "elevatorshaft"

/turf/simulated/floor/plasteel/bluespace
	icon_state = "bluespace"

/turf/simulated/floor/plasteel/sepia
	icon_state = "sepia"

/turf/simulated/floor/plasteel/sandy
	icon_state = "sandy"
	baseturf = /turf/simulated/floor/plating/beach/sand

/turf/simulated/floor/plasteel/sandeffect
	icon_state = "sandeffect"
/turf/simulated/floor/plasteel/sandeffect/warning
	icon_state = "warningsandeffect"
/turf/simulated/floor/plasteel/sandeffect/warning/corner
	icon_state = "warningsandeffectcorners"