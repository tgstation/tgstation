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
/turf/open/floor/plasteel/black/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/black/telecomms/mainframe
	name = "Mainframe Floor"
/turf/open/floor/plasteel/black/telecomms/server
	name = "Server Base"
/turf/open/floor/plasteel/black/telecomms/server/walkway
	name = "Server Walkway"
/turf/open/floor/plasteel/airless/black
	icon_state = "dark"
/turf/open/floor/plasteel/black/side
	icon_state = "black" //NOTICE ME SEMPAI: floors.dmi contains two sprites named black, remove the incorrect one
/turf/open/floor/plasteel/black/corner
	icon_state = "blackcorner"



/turf/open/floor/plasteel/white
	icon_state = "white"
/turf/open/floor/plasteel/white/side
	icon_state = "whitehall"
/turf/open/floor/plasteel/white/corner
	icon_state = "whitecorner"
/turf/open/floor/plasteel/airless/white
	icon_state = "white"
/turf/open/floor/plasteel/airless/white/side
	icon_state = "whitehall"
/turf/open/floor/plasteel/airless/white/corner
	icon_state = "whitecorner"



/turf/open/floor/plasteel/brown
	icon_state = "brown"
/turf/open/floor/plasteel/brown/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/brown/telecomms/mainframe
	name = "Mainframe Floor"
/turf/open/floor/plasteel/brown/corner
	icon_state = "browncorner"

/turf/open/floor/plasteel/darkbrown
	icon_state = "darkbrownfull"
/turf/open/floor/plasteel/darkbrown/side
	icon_state = "darkbrown"
/turf/open/floor/plasteel/darkbrown/corner
	icon_state = "darkbrowncorners"



/turf/open/floor/plasteel/green
	icon_state = "greenfull"
/turf/open/floor/plasteel/green/side
	icon_state = "green"
/turf/open/floor/plasteel/green/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/green/corner
	icon_state = "greencorner"

/turf/open/floor/plasteel/darkgreen
	icon_state = "darkgreenfull"
/turf/open/floor/plasteel/darkgreen/side
	icon_state = "darkgreen"
/turf/open/floor/plasteel/darkgreen/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/darkgreen/corner
	icon_state = "darkgreencorners"

/turf/open/floor/plasteel/whitegreen
	icon_state = "whitegreenfull"
/turf/open/floor/plasteel/whitegreen/side
	icon_state = "whitegreen"
/turf/open/floor/plasteel/whitegreen/corner
	icon_state = "whitegreencorner"



/turf/open/floor/plasteel/red
	icon_state = "redfull"
/turf/open/floor/plasteel/red/side
	icon_state = "red"
/turf/open/floor/plasteel/red/corner
	icon_state = "redcorner"

/turf/open/floor/plasteel/darkred
	icon_state = "darkredfull"
/turf/open/floor/plasteel/darkred/side
	icon_state = "darkred"
/turf/open/floor/plasteel/darkred/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/darkred/corner
	icon_state = "darkredcorners"

/turf/open/floor/plasteel/whitered
	icon_state = "whiteredfull"
/turf/open/floor/plasteel/whitered/side
	icon_state = "whitered"
/turf/open/floor/plasteel/whitered/corner
	icon_state = "whiteredcorner"



/turf/open/floor/plasteel/blue
	icon_state = "bluefull"
/turf/open/floor/plasteel/blue/side
	icon_state = "blue"
/turf/open/floor/plasteel/blue/corner
	icon_state = "bluecorner"

/turf/open/floor/plasteel/darkblue
	icon_state = "darkbluefull"
/turf/open/floor/plasteel/darkblue/side
	icon_state = "darkblue"
/turf/open/floor/plasteel/darkblue/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/darkblue/corner
	icon_state = "darkbluecorners"

/turf/open/floor/plasteel/whiteblue
	icon_state = "whitebluefull"
/turf/open/floor/plasteel/whiteblue/side
	icon_state = "whiteblue"
/turf/open/floor/plasteel/whiteblue/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/whiteblue/corner
	icon_state = "whitebluecorner"



/turf/open/floor/plasteel/yellow
	icon_state = "yellowfull"
/turf/open/floor/plasteel/yellow/side
	icon_state = "yellow"
/turf/open/floor/plasteel/yellow/corner
	icon_state = "yellowcorner"

/turf/open/floor/plasteel/darkyellow
	icon_state = "darkyellowfull"
/turf/open/floor/plasteel/darkyellow/side
	icon_state = "darkyellow"
/turf/open/floor/plasteel/darkyellow/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/darkyellow/corner
	icon_state = "darkyellowcorners"

/turf/open/floor/plasteel/whiteyellow
	icon_state = "whiteyellowfull"
/turf/open/floor/plasteel/whiteyellow/side
	icon_state = "whiteyellow"
/turf/open/floor/plasteel/whiteyellow/corner
	icon_state = "whiteyellowcorner"



/turf/open/floor/plasteel/purple
	icon_state = "purplefull"
/turf/open/floor/plasteel/purple/side
	icon_state = "purple"
/turf/open/floor/plasteel/purple/corner
	icon_state = "purplecorner"

/turf/open/floor/plasteel/darkpurple
	icon_state = "darkpurplefull"
/turf/open/floor/plasteel/darkpurple/side
	icon_state = "darkpurple"
/turf/open/floor/plasteel/darkpurple/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/darkpurple/corner
	icon_state = "darkpurplecorners"

/turf/open/floor/plasteel/whitepurple
	icon_state = "whitepurplefull"
/turf/open/floor/plasteel/whitepurple/side
	icon_state = "whitepurple"
/turf/open/floor/plasteel/whitepurple/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/whitepurple/corner
	icon_state = "whitepurplecorner"


/turf/open/floor/plasteel/orange
	icon_state = "orangefull"
/turf/open/floor/plasteel/orange/side
	icon_state = "orange"
/turf/open/floor/plasteel/orange/corner
	icon_state = "orangecorner"


/turf/open/floor/plasteel/neutral
	icon_state = "neutralfull"
/turf/open/floor/plasteel/neutral/side
	icon_state = "neutral"
/turf/open/floor/plasteel/neutral/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/neutral/corner
	icon_state = "neutralcorner"


/turf/open/floor/plasteel/arrival
	icon_state = "arrival"
/turf/open/floor/plasteel/arrival/corner
	icon_state = "arrivalcorner"

/turf/open/floor/plasteel/caution
	icon_state = "caution"
/turf/open/floor/plasteel/caution/corner
	icon_state = "cautioncorner"

/turf/open/floor/plasteel/escape
	icon_state = "escape"
/turf/open/floor/plasteel/escape/corner
	icon_state = "escapecorner"

/turf/open/floor/plasteel/whitebot
	icon_state = "whitebot"
/turf/open/floor/plasteel/whitebot/delivery
	icon_state = "whitedelivery"


/turf/open/floor/plasteel/redyellow
	icon_state = "redyellowfull"
/turf/open/floor/plasteel/redyellow/side
	icon_state = "redyellow"


/turf/open/floor/plasteel/redblue
	icon_state = "redbluefull"
/turf/open/floor/plasteel/redblue/blueside
	icon_state = "bluered"
/turf/open/floor/plasteel/redblue/redside
	icon_state = "redblue"


/turf/open/floor/plasteel/redgreen
	icon_state = "redgreenfull"
/turf/open/floor/plasteel/redgreen/side
	icon_state = "redgreen"


/turf/open/floor/plasteel/greenyellow
	icon_state = "greenyellowfull"
/turf/open/floor/plasteel/greenyellow/side
	icon_state = "greenyellow"


/turf/open/floor/plasteel/greenblue
	icon_state = "greenbluefull"
/turf/open/floor/plasteel/greenblue/side
	icon_state = "greenblue"


/turf/open/floor/plasteel/blueyellow
	icon_state = "blueyellowfull"
/turf/open/floor/plasteel/blueyellow/side
	icon_state = "blueyellow"


/turf/open/floor/plasteel/yellowsiding
	icon_state = "yellowsiding"
/turf/open/floor/plasteel/yellowsiding/corner
	icon_state = "yellowcornersiding"


/turf/open/floor/plasteel/podhatch
	icon_state = "podhatch"
/turf/open/floor/plasteel/podhatch/corner
	icon_state = "podhatchcorner"


/turf/open/floor/plasteel/loadingarea
	icon_state = "loadingarea"
/turf/open/floor/plasteel/loadingarea/dirty
	icon_state = "loadingareadirty1"
/turf/open/floor/plasteel/loadingarea/dirtydirty
	icon_state = "loadingareadirty2"

/turf/open/floor/plasteel/asteroid
	icon_state = "asteroidfloor"
/turf/open/floor/plasteel/airless/asteroid
	icon_state = "asteroidfloor"

/turf/open/floor/plasteel/recharge_floor
	icon_state = "recharge_floor"
/turf/open/floor/plasteel/recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"


/turf/open/floor/plasteel/chapel
	icon_state = "chapel"

/turf/open/floor/plasteel/showroomfloor
	icon_state = "showroomfloor"

/turf/open/floor/plasteel/floorgrime
	icon_state = "floorgrime"
/turf/open/floor/plasteel/airless/floorgrime
	icon_state = "floorgrime"

/turf/open/floor/plasteel/solarpanel
	icon_state = "solarpanel"
/turf/open/floor/plasteel/airless/solarpanel
	icon_state = "solarpanel"

/turf/open/floor/plasteel/cmo
	icon_state = "cmo"

/turf/open/floor/plasteel/barber
	icon_state = "barber"

/turf/open/floor/plasteel/hydrofloor
	icon_state = "hydrofloor"

/turf/open/floor/plasteel/delivery
	icon_state = "delivery"

/turf/open/floor/plasteel/bot
	icon_state = "bot"

/turf/open/floor/plasteel/freezer
	icon_state = "freezerfloor"

/turf/open/floor/plasteel/bar
	icon_state = "bar"

/turf/open/floor/plasteel/airless/bar
	icon_state = "bar"

/turf/open/floor/plasteel/grimy
	icon_state = "grimy"

/turf/open/floor/plasteel/cafeteria
	icon_state = "cafeteria"

/turf/open/floor/plasteel/airless/cafeteria
	icon_state = "cafeteria"

/turf/open/floor/plasteel/vault
	icon_state = "vault"
/turf/open/floor/plasteel/vault/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/plasteel/vault/telecomms/mainframe
	name = "Mainframe Floor"
/turf/open/floor/plasteel/vault/killroom
	name = "Killroom Floor"

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






//
//unused? remove?
//
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


/turf/open/floor/plasteel/brownold
	icon_state = "brownold"
/turf/open/floor/plasteel/brownold/corner
	icon_state = "browncornerold"


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
