/turf/open/floor/metal
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/metal
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")

/turf/open/floor/metal/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		icon_state = icon_regular_floor


/turf/open/floor/metal/airless
	initial_gas_mix = "TEMP=2.7"


/turf/open/floor/metal/black
	icon_state = "dark"
/turf/open/floor/metal/black/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/black/telecomms/mainframe
	name = "Mainframe Floor"
/turf/open/floor/metal/black/telecomms/server
	name = "Server Base"
/turf/open/floor/metal/black/telecomms/server/walkway
	name = "Server Walkway"
/turf/open/floor/metal/airless/black
	icon_state = "dark"
/turf/open/floor/metal/black/side
	icon_state = "black" //NOTICE ME SEMPAI: floors.dmi contains two sprites named black, remove the incorrect one
/turf/open/floor/metal/black/corner
	icon_state = "blackcorner"



/turf/open/floor/metal/white
	icon_state = "white"
/turf/open/floor/metal/white/side
	icon_state = "whitehall"
/turf/open/floor/metal/white/corner
	icon_state = "whitecorner"
/turf/open/floor/metal/airless/white
	icon_state = "white"
/turf/open/floor/metal/airless/white/side
	icon_state = "whitehall"
/turf/open/floor/metal/airless/white/corner
	icon_state = "whitecorner"



/turf/open/floor/metal/brown
	icon_state = "brown"
/turf/open/floor/metal/brown/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/brown/telecomms/mainframe
	name = "Mainframe Floor"
/turf/open/floor/metal/brown/corner
	icon_state = "browncorner"

/turf/open/floor/metal/darkbrown
	icon_state = "darkbrownfull"
/turf/open/floor/metal/darkbrown/side
	icon_state = "darkbrown"
/turf/open/floor/metal/darkbrown/corner
	icon_state = "darkbrowncorners"



/turf/open/floor/metal/green
	icon_state = "greenfull"
/turf/open/floor/metal/green/side
	icon_state = "green"
/turf/open/floor/metal/green/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/green/corner
	icon_state = "greencorner"

/turf/open/floor/metal/darkgreen
	icon_state = "darkgreenfull"
/turf/open/floor/metal/darkgreen/side
	icon_state = "darkgreen"
/turf/open/floor/metal/darkgreen/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/darkgreen/corner
	icon_state = "darkgreencorners"

/turf/open/floor/metal/whitegreen
	icon_state = "whitegreenfull"
/turf/open/floor/metal/whitegreen/side
	icon_state = "whitegreen"
/turf/open/floor/metal/whitegreen/corner
	icon_state = "whitegreencorner"



/turf/open/floor/metal/red
	icon_state = "redfull"
/turf/open/floor/metal/red/side
	icon_state = "red"
/turf/open/floor/metal/red/corner
	icon_state = "redcorner"

/turf/open/floor/metal/darkred
	icon_state = "darkredfull"
/turf/open/floor/metal/darkred/side
	icon_state = "darkred"
/turf/open/floor/metal/darkred/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/darkred/corner
	icon_state = "darkredcorners"

/turf/open/floor/metal/whitered
	icon_state = "whiteredfull"
/turf/open/floor/metal/whitered/side
	icon_state = "whitered"
/turf/open/floor/metal/whitered/corner
	icon_state = "whiteredcorner"



/turf/open/floor/metal/blue
	icon_state = "bluefull"
/turf/open/floor/metal/blue/side
	icon_state = "blue"
/turf/open/floor/metal/blue/corner
	icon_state = "bluecorner"

/turf/open/floor/metal/darkblue
	icon_state = "darkbluefull"
/turf/open/floor/metal/darkblue/side
	icon_state = "darkblue"
/turf/open/floor/metal/darkblue/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/darkblue/corner
	icon_state = "darkbluecorners"

/turf/open/floor/metal/whiteblue
	icon_state = "whitebluefull"
/turf/open/floor/metal/whiteblue/side
	icon_state = "whiteblue"
/turf/open/floor/metal/whiteblue/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/whiteblue/corner
	icon_state = "whitebluecorner"



/turf/open/floor/metal/yellow
	icon_state = "yellowfull"
/turf/open/floor/metal/yellow/side
	icon_state = "yellow"
/turf/open/floor/metal/yellow/corner
	icon_state = "yellowcorner"

/turf/open/floor/metal/darkyellow
	icon_state = "darkyellowfull"
/turf/open/floor/metal/darkyellow/side
	icon_state = "darkyellow"
/turf/open/floor/metal/darkyellow/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/darkyellow/corner
	icon_state = "darkyellowcorners"

/turf/open/floor/metal/whiteyellow
	icon_state = "whiteyellowfull"
/turf/open/floor/metal/whiteyellow/side
	icon_state = "whiteyellow"
/turf/open/floor/metal/whiteyellow/corner
	icon_state = "whiteyellowcorner"



/turf/open/floor/metal/purple
	icon_state = "purplefull"
/turf/open/floor/metal/purple/side
	icon_state = "purple"
/turf/open/floor/metal/purple/corner
	icon_state = "purplecorner"

/turf/open/floor/metal/darkpurple
	icon_state = "darkpurplefull"
/turf/open/floor/metal/darkpurple/side
	icon_state = "darkpurple"
/turf/open/floor/metal/darkpurple/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/darkpurple/corner
	icon_state = "darkpurplecorners"

/turf/open/floor/metal/whitepurple
	icon_state = "whitepurplefull"
/turf/open/floor/metal/whitepurple/side
	icon_state = "whitepurple"
/turf/open/floor/metal/whitepurple/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/whitepurple/corner
	icon_state = "whitepurplecorner"


/turf/open/floor/metal/orange
	icon_state = "orangefull"
/turf/open/floor/metal/orange/side
	icon_state = "orange"
/turf/open/floor/metal/orange/corner
	icon_state = "orangecorner"


/turf/open/floor/metal/neutral
	icon_state = "neutralfull"
/turf/open/floor/metal/neutral/side
	icon_state = "neutral"
/turf/open/floor/metal/neutral/side/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/neutral/corner
	icon_state = "neutralcorner"


/turf/open/floor/metal/arrival
	icon_state = "arrival"
/turf/open/floor/metal/arrival/corner
	icon_state = "arrivalcorner"

/turf/open/floor/metal/caution
	icon_state = "caution"
/turf/open/floor/metal/caution/corner
	icon_state = "cautioncorner"

/turf/open/floor/metal/escape
	icon_state = "escape"
/turf/open/floor/metal/escape/corner
	icon_state = "escapecorner"

/turf/open/floor/metal/whitebot
	icon_state = "whitebot"
/turf/open/floor/metal/whitebot/delivery
	icon_state = "whitedelivery"


/turf/open/floor/metal/redyellow
	icon_state = "redyellowfull"
/turf/open/floor/metal/redyellow/side
	icon_state = "redyellow"


/turf/open/floor/metal/redblue
	icon_state = "redbluefull"
/turf/open/floor/metal/redblue/blueside
	icon_state = "bluered"
/turf/open/floor/metal/redblue/redside
	icon_state = "redblue"


/turf/open/floor/metal/redgreen
	icon_state = "redgreenfull"
/turf/open/floor/metal/redgreen/side
	icon_state = "redgreen"


/turf/open/floor/metal/greenyellow
	icon_state = "greenyellowfull"
/turf/open/floor/metal/greenyellow/side
	icon_state = "greenyellow"


/turf/open/floor/metal/greenblue
	icon_state = "greenbluefull"
/turf/open/floor/metal/greenblue/side
	icon_state = "greenblue"


/turf/open/floor/metal/blueyellow
	icon_state = "blueyellowfull"
/turf/open/floor/metal/blueyellow/side
	icon_state = "blueyellow"


/turf/open/floor/metal/yellowsiding
	icon_state = "yellowsiding"
/turf/open/floor/metal/yellowsiding/corner
	icon_state = "yellowcornersiding"


/turf/open/floor/metal/podhatch
	icon_state = "podhatch"
/turf/open/floor/metal/podhatch/corner
	icon_state = "podhatchcorner"


/turf/open/floor/metal/loadingarea
	icon_state = "loadingarea"
/turf/open/floor/metal/loadingarea/dirty
	icon_state = "loadingareadirty1"
/turf/open/floor/metal/loadingarea/dirtydirty
	icon_state = "loadingareadirty2"

/turf/open/floor/metal/asteroid
	icon_state = "asteroidfloor"
/turf/open/floor/metal/airless/asteroid
	icon_state = "asteroidfloor"

/turf/open/floor/metal/recharge_floor
	icon_state = "recharge_floor"
/turf/open/floor/metal/recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"


/turf/open/floor/metal/chapel
	icon_state = "chapel"

/turf/open/floor/metal/showroomfloor
	icon_state = "showroomfloor"

/turf/open/floor/metal/floorgrime
	icon_state = "floorgrime"
/turf/open/floor/metal/airless/floorgrime
	icon_state = "floorgrime"

/turf/open/floor/metal/solarpanel
	icon_state = "solarpanel"
/turf/open/floor/metal/airless/solarpanel
	icon_state = "solarpanel"

/turf/open/floor/metal/cmo
	icon_state = "cmo"

/turf/open/floor/metal/barber
	icon_state = "barber"

/turf/open/floor/metal/hydrofloor
	icon_state = "hydrofloor"

/turf/open/floor/metal/delivery
	icon_state = "delivery"

/turf/open/floor/metal/bot
	icon_state = "bot"

/turf/open/floor/metal/freezer
	icon_state = "freezerfloor"

/turf/open/floor/metal/bar
	icon_state = "bar"

/turf/open/floor/metal/airless/bar
	icon_state = "bar"

/turf/open/floor/metal/grimy
	icon_state = "grimy"

/turf/open/floor/metal/cafeteria
	icon_state = "cafeteria"

/turf/open/floor/metal/airless/cafeteria
	icon_state = "cafeteria"

/turf/open/floor/metal/vault
	icon_state = "vault"
/turf/open/floor/metal/vault/telecomms
	initial_gas_mix = "n2=100;TEMP=80"
/turf/open/floor/metal/vault/telecomms/mainframe
	name = "Mainframe Floor"
/turf/open/floor/metal/vault/killroom
	name = "Killroom Floor"

/turf/open/floor/metal/cult
	icon_state = "cult"
	name = "engraved floor"

/turf/open/floor/metal/vaporwave
	icon_state = "pinkblack"

/turf/open/floor/metal/goonplaque
	icon_state = "plaque"
	name = "Commemorative Plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."

/turf/open/floor/metal/cult/narsie_act()
	return

/turf/open/floor/metal/cult/airless
	initial_gas_mix = "TEMP=2.7"






//
//unused? remove?
//
/turf/open/floor/metal/stage_bottom
	icon_state = "stage_bottom"
/turf/open/floor/metal/stage_left
	icon_state = "stage_left"
/turf/open/floor/metal/stage_bleft
	icon_state = "stage_bleft"


/turf/open/floor/metal/stairs
	icon_state = "stairs"
/turf/open/floor/metal/stairs/left
	icon_state = "stairs-l"
/turf/open/floor/metal/stairs/medium
	icon_state = "stairs-m"
/turf/open/floor/metal/stairs/right
	icon_state = "stairs-r"
/turf/open/floor/metal/stairs/old
	icon_state = "stairs-old"


/turf/open/floor/metal/brownold
	icon_state = "brownold"
/turf/open/floor/metal/brownold/corner
	icon_state = "browncornerold"


/turf/open/floor/metal/rockvault
	icon_state = "rockvault"
/turf/open/floor/metal/rockvault/alien
	icon_state = "alienvault"
/turf/open/floor/metal/rockvault/sandstone
	icon_state = "sandstonevault"


/turf/open/floor/metal/elevatorshaft
	icon_state = "elevatorshaft"

/turf/open/floor/metal/bluespace
	icon_state = "bluespace"

/turf/open/floor/metal/sepia
	icon_state = "sepia"
