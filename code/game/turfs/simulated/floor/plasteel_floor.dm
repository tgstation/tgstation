/turf/floor/plasteel
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")

/turf/floor/plasteel/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		icon_state = icon_regular_floor



/turf/floor/plasteel/black
	icon_state = "dark"
/turf/floor/plasteel/black/side
	icon_state = "black" //NOTICE ME SEMPAI: floors.dmi contains two sprites named black, remove the incorrect one
/turf/floor/plasteel/black/corner
	icon_state = "blackcorner"


/turf/floor/plasteel/white
	icon_state = "white"
/turf/floor/plasteel/white/side
	icon_state = "whitehall"
/turf/floor/plasteel/white/corner
	icon_state = "whitecorner"



/turf/floor/plasteel/brown
	icon_state = "brown"
/turf/floor/plasteel/brown/corner
	icon_state = "browncorner"

/turf/floor/plasteel/darkbrown
	icon_state = "darkbrownfull"
/turf/floor/plasteel/darkbrown/side
	icon_state = "darkbrown"
/turf/floor/plasteel/darkbrown/corner
	icon_state = "darkbrowncorners"



/turf/floor/plasteel/green
	icon_state = "greenfull"
/turf/floor/plasteel/green/side
	icon_state = "green"
/turf/floor/plasteel/green/corner
	icon_state = "greencorner"

/turf/floor/plasteel/darkgreen
	icon_state = "darkgreenfull"
/turf/floor/plasteel/darkgreen/side
	icon_state = "darkgreen"
/turf/floor/plasteel/darkgreen/corner
	icon_state = "darkgreencorners"

/turf/floor/plasteel/whitegreen
	icon_state = "whitegreenfull"
/turf/floor/plasteel/whitegreen/side
	icon_state = "whitegreen"
/turf/floor/plasteel/whitegreen/corner
	icon_state = "whitegreencorner"



/turf/floor/plasteel/red
	icon_state = "redfull"
/turf/floor/plasteel/red/side
	icon_state = "red"
/turf/floor/plasteel/red/corner
	icon_state = "redcorner"

/turf/floor/plasteel/darkred
	icon_state = "darkredfull"
/turf/floor/plasteel/darkred/side
	icon_state = "darkred"
/turf/floor/plasteel/darkred/corner
	icon_state = "darkredcorners"

/turf/floor/plasteel/whitered
	icon_state = "whiteredfull"
/turf/floor/plasteel/whitered/side
	icon_state = "whitered"
/turf/floor/plasteel/whitered/corner
	icon_state = "whiteredcorner"



/turf/floor/plasteel/blue
	icon_state = "bluefull"
/turf/floor/plasteel/blue/side
	icon_state = "blue"
/turf/floor/plasteel/blue/corner
	icon_state = "bluecorner"

/turf/floor/plasteel/darkblue
	icon_state = "darkbluefull"
/turf/floor/plasteel/darkblue/side
	icon_state = "darkblue"
/turf/floor/plasteel/darkblue/corner
	icon_state = "darkbluecorners"

/turf/floor/plasteel/whiteblue
	icon_state = "whitebluefull"
/turf/floor/plasteel/whiteblue/side
	icon_state = "whiteblue"
/turf/floor/plasteel/whiteblue/corner
	icon_state = "whitebluecorner"



/turf/floor/plasteel/yellow
	icon_state = "yellowfull"
/turf/floor/plasteel/yellow/side
	icon_state = "yellow"
/turf/floor/plasteel/yellow/corner
	icon_state = "yellowcorner"

/turf/floor/plasteel/darkyellow
	icon_state = "darkyellowfull"
/turf/floor/plasteel/darkyellow/side
	icon_state = "darkyellow"
/turf/floor/plasteel/darkyellow/corner
	icon_state = "darkyellowcorners"

/turf/floor/plasteel/whiteyellow
	icon_state = "whiteyellowfull"
/turf/floor/plasteel/whiteyellow/side
	icon_state = "whiteyellow"
/turf/floor/plasteel/whiteyellow/corner
	icon_state = "whiteyellowcorner"



/turf/floor/plasteel/purple
	icon_state = "purplefull"
/turf/floor/plasteel/purple/side
	icon_state = "purple"
/turf/floor/plasteel/purple/corner
	icon_state = "purplecorner"

/turf/floor/plasteel/darkpurple
	icon_state = "darkpurplefull"
/turf/floor/plasteel/darkpurple/side
	icon_state = "darkpurple"
/turf/floor/plasteel/darkpurple/corner
	icon_state = "darkpurplecorners"

/turf/floor/plasteel/whitepurple
	icon_state = "whitepurplefull"
/turf/floor/plasteel/whitepurple/side
	icon_state = "whitepurple"
/turf/floor/plasteel/whitepurple/corner
	icon_state = "whitepurplecorner"


/turf/floor/plasteel/orange
	icon_state = "orangefull"
/turf/floor/plasteel/orange/side
	icon_state = "orange"
/turf/floor/plasteel/orange/corner
	icon_state = "orangecorner"


/turf/floor/plasteel/neutral
	icon_state = "neutralfull"
/turf/floor/plasteel/neutral/side
	icon_state = "neutral"
/turf/floor/plasteel/neutral/corner
	icon_state = "neutralcorner"


/turf/floor/plasteel/arrival
	icon_state = "arrival"
/turf/floor/plasteel/arrival/corner
	icon_state = "arrivalcorner"


/turf/floor/plasteel/escape
	icon_state = "escape"
/turf/floor/plasteel/escape/corner
	icon_state = "escapecorner"


/turf/floor/plasteel/caution
	icon_state = "caution"
/turf/floor/plasteel/caution/corner
	icon_state = "cautioncorner"


/turf/floor/plasteel/warning
	icon_state = "warning"
/turf/floor/plasteel/warning/corner
	icon_state = "warningcorner"


/turf/floor/plasteel/warnplate
	icon_state = "warnplate"
/turf/floor/plasteel/warnplate/corner
	icon_state = "warnplatecorner"


/turf/floor/plasteel/warnwhite
	icon_state = "warnwhite"
/turf/floor/plasteel/warnwhite/corner
	icon_state = "warnwhitecorner"


/turf/floor/plasteel/whitebot
	icon_state = "whitebot"
/turf/floor/plasteel/whitebot/delivery
	icon_state = "whitedelivery"


/turf/floor/plasteel/redyellow
	icon_state = "redyellowfull"
/turf/floor/plasteel/redyellow/side
	icon_state = "redyellow"


/turf/floor/plasteel/redblue
	icon_state = "redbluefull"
/turf/floor/plasteel/redblue/blueside
	icon_state = "bluered"
/turf/floor/plasteel/redblue/redside
	icon_state = "redblue"


/turf/floor/plasteel/redgreen
	icon_state = "redgreenfull"
/turf/floor/plasteel/redgreen/side
	icon_state = "redgreen"


/turf/floor/plasteel/greenyellow
	icon_state = "greenyellowfull"
/turf/floor/plasteel/greenyellow/side
	icon_state = "greenyellow"


/turf/floor/plasteel/greenblue
	icon_state = "greenbluefull"
/turf/floor/plasteel/greenblue/side
	icon_state = "greenblue"


/turf/floor/plasteel/blueyellow
	icon_state = "blueyellowfull"
/turf/floor/plasteel/blueyellow/side
	icon_state = "blueyellow"


/turf/floor/plasteel/darkwarning
	icon_state = "warndark"
/turf/floor/plasteel/darkwarning/corner
	icon_state = "warndarkcorners"

/turf/floor/plasteel/warningline
	icon_state = "warningline"
/turf/floor/plasteel/warningline/corner
	icon_state = "warninglinecorners"

/turf/floor/plasteel/yellowsiding
	icon_state = "yellowsiding"
/turf/floor/plasteel/yellowsiding/corner
	icon_state = "yellowcornersiding"


/turf/floor/plasteel/podhatch
	icon_state = "podhatch"
/turf/floor/plasteel/podhatch/corner
	icon_state = "podhatchcorner"



/turf/floor/plasteel/circuit
	icon_state = "bcircuit"
/turf/floor/plasteel/circuit/off
	icon_state = "bcircuitoff"

/turf/floor/plasteel/circuit/gcircuit
	icon_state = "gcircuit"
/turf/floor/plasteel/circuit/gcircuit/off
	icon_state = "gcircuitoff"
/turf/floor/plasteel/circuit/gcircuit/animated
	icon_state = "gcircuitanim"

/turf/floor/plasteel/circuit/rcircuit
	icon_state = "rcircuit"
/turf/floor/plasteel/circuit/rcircuit/animated
	icon_state = "rcircuitanim"



/turf/floor/plasteel/loadingarea
	icon_state = "loadingarea"
/turf/floor/plasteel/loadingarea/dirty
	icon_state = "loadingareadirty1"
/turf/floor/plasteel/loadingarea/dirtydirty
	icon_state = "loadingareadirty2"


/turf/floor/plasteel/shuttle
	icon_state = "shuttlefloor"
/turf/floor/plasteel/shuttle/red
	name = "Brig floor"
	icon_state = "shuttlefloor4"
/turf/floor/plasteel/shuttle/yellow
	icon_state = "shuttlefloor2"
/turf/floor/plasteel/shuttle/white
	icon_state = "shuttlefloor3"
/turf/floor/plasteel/shuttle/purple
	icon_state = "shuttlefloor5"


/turf/floor/plasteel/asteroid
	icon_state = "asteroidfloor"
/turf/floor/plasteel/asteroid/warning
	icon_state = "asteroidwarning"


/turf/floor/plasteel/recharge_floor
	icon_state = "recharge_floor"
/turf/floor/plasteel/recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"


/turf/floor/plasteel/chapel
	icon_state = "chapel"

/turf/floor/plasteel/showroomfloor
	icon_state = "showroomfloor"

/turf/floor/plasteel/floorgrime
	icon_state = "floorgrime"

/turf/floor/plasteel/solarpanel
	icon_state = "solarpanel"

/turf/floor/plasteel/cmo
	icon_state = "cmo"

/turf/floor/plasteel/barber
	icon_state = "barber"

/turf/floor/plasteel/hydrofloor
	icon_state = "hydrofloor"

/turf/floor/plasteel/delivery
	icon_state = "delivery"

/turf/floor/plasteel/bot
	icon_state = "bot"

/turf/floor/plasteel/freezer
	icon_state = "freezerfloor"

/turf/floor/plasteel/bar
	icon_state = "bar"

/turf/floor/plasteel/grimy
	icon_state = "grimy"

/turf/floor/plasteel/cafeteria
	icon_state = "cafeteria"

/turf/floor/plasteel/vault
	icon_state = "vault"

/turf/floor/plasteel/cult
	icon_state = "cult"
	name = "engraved floor"

/turf/floor/plasteel/goonplaque
	icon_state = "plaque"
	name = "Commemorative Plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."

/turf/floor/plasteel/cult/narsie_act()
	return

/turf/floor/plasteel/cult/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB






//
//unused? remove?
//
/turf/floor/plasteel/stage_bottom
	icon_state = "stage_bottom"
/turf/floor/plasteel/stage_left
	icon_state = "stage_left"
/turf/floor/plasteel/stage_bleft
	icon_state = "stage_bleft"


/turf/floor/plasteel/stairs
	icon_state = "stairs"
/turf/floor/plasteel/stairs/left
	icon_state = "stairs-l"
/turf/floor/plasteel/stairs/medium
	icon_state = "stairs-m"
/turf/floor/plasteel/stairs/right
	icon_state = "stairs-r"
/turf/floor/plasteel/stairs/old
	icon_state = "stairs-old"


/turf/floor/plasteel/brownold
	icon_state = "brownold"
/turf/floor/plasteel/brownold/corner
	icon_state = "browncornerold"


/turf/floor/plasteel/rockvault
	icon_state = "rockvault"
/turf/floor/plasteel/rockvault/alien
	icon_state = "alienvault"
/turf/floor/plasteel/rockvault/sandstone
	icon_state = "sandstonevault"


/turf/floor/plasteel/elevatorshaft
	icon_state = "elevatorshaft"

/turf/floor/plasteel/bluespace
	icon_state = "bluespace"

/turf/floor/plasteel/sepia
	icon_state = "sepia"


/turf/floor/plasteel/sandeffect
	icon_state = "sandeffect"
/turf/floor/plasteel/sandeffect/warning
	icon_state = "warningsandeffect"
/turf/floor/plasteel/sandeffect/warning/corner
	icon_state = "warningsandeffectcorners"