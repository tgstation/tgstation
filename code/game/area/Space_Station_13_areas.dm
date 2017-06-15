/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = 'ICON FILENAME' 			(defaults to 'icons/turf/areas.dmi')
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)
	music = null					(defaults to nothing, look in sound/ambience for music)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/*-----------------------------------------------------------------------------*/
/area/ai_monitored	//stub defined ai_monitored.dm

/area/ai_monitored/turret_protected

/area/arrival
	requires_power = 0

/area/arrival/start
	name = "Arrival Area"
	icon_state = "start"

/area/admin
	name = "Admin room"
	icon_state = "start"

/area/space
	icon_state = "space"
	requires_power = 1
	always_unpowered = 1
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	power_light = 0
	power_equip = 0
	power_environ = 0
	valid_territory = 0
	outdoors = 1
	ambientsounds = list('sound/ambience/ambispace.ogg','sound/ambience/title2.ogg')
	blob_allowed = 0 //Eating up space doesn't count for victory as a blob.

/area/space/nearstation
	icon_state = "space_near"
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT

/area/start
	name = "start area"
	icon_state = "start"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = 1


//EXTRA

/area/asteroid
	name = "Asteroid"
	icon_state = "asteroid"
	requires_power = 0
	has_gravity = 1
	blob_allowed = 0 //Nope, no winning on the asteroid as a blob. Gotta eat the station.
	valid_territory = 0

/area/asteroid/cave
	name = "Asteroid - Underground"
	icon_state = "cave"
	requires_power = 0
	outdoors = 1

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"

/area/asteroid/artifactroom/Initialize()
	. = ..()
	set_dynamic_lighting()

/area/planet/clown
	name = "Clown Planet"
	icon_state = "honk"
	requires_power = 0

/area/telesciareas
	name = "Cosmic Anomaly"
	icon_state = "telesci"
	requires_power = 0


//STATION13

//Maintenance

/area/maintenance
	ambientsounds = list('sound/ambience/ambimaint1.ogg',
						 'sound/ambience/ambimaint2.ogg',
						 'sound/ambience/ambimaint3.ogg',
						 'sound/ambience/ambimaint4.ogg',
						 'sound/ambience/ambimaint5.ogg',
						 'sound/voice/lowHiss2.ogg', //Xeno Breathing Hisses, Hahahaha I'm not even sorry.
						 'sound/voice/lowHiss3.ogg',
						 'sound/voice/lowHiss4.ogg')
	valid_territory = 0
	sound_environment = 12


//Departments

/area/maintenance/department/chapel
	name = "Chapel Maintenance"
	icon_state = "fpmaint"

/area/maintenance/department/chapel/monastery
	name = "Monastery Maintenance"
	icon_state = "fpmaint"

/area/maintenance/department/crew_quarters/bar
//	/area/maintenance/fsmaint2
	name = "Bar Maintenance"
	icon_state = "fsmaint"

/area/maintenance/department/crew_quarters/dorms
//	/area/maintenance/fsmaint
	name = "Dormitory Maintenance"
	icon_state = "fsmaint"

/area/maintenance/department/crew_quarters/locker
//	/area/maintenance/port
	name = "Locker Room Maintenance"
	icon_state = "pmaint"

/area/maintenance/department/eva
//	/area/maintenance/fpmaint
	name = "EVA Maintenance"
	icon_state = "fpmaint"

/area/maintenance/department/electrical
//	/area/maintenance/electrical
	name = "Electrical Maintenance"
	icon_state = "yellow"

/area/maintenance/department/engine/atmos
//	/area/maintenance/atmos_control
	name = "Atmospherics Maintenance"
	icon_state = "fpmaint"

/area/maintenance/department/security
	name = "Security Maintenance"
	icon_state = "fpmaint"

/area/maintenance/department/security/brig
	name = "Brig Maintenance"
	icon_state = "fpmaint"

/area/maintenance/department/medical
//	/area/maintenance/asmaint
	name = "Medbay Maintenance"
	icon_state = "asmaint"

/area/maintenance/department/science
//	/area/maintenance/asmaint2
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/maintenance/department/cargo
//	/area/maintenance/apmaint
	name = "Cargo Maintenance"
	icon_state = "apmaint"

/area/maintenance/department/bridge
//	/area/maintenance/maintcentral
	name = "Bridge Maintenance"
	icon_state = "maintcentral"

/area/maintenance/department/engine
//	/area/maintenance/aft
	name = "Engineering Maintenance"
	icon_state = "amaint"

/area/maintenance/department/science/xenobiology
//	/area/maintenance/aft/xeno_maint
	name = "Xenobiology Maintenance"
	icon_state = "xenomaint"


//Maintenance - Generic

/area/maintenance/arrivals/north
//	/area/maintenance/fpmaint2
	name = "Arrivals North Maintenance"
	icon_state = "fpmaint"

/area/maintenance/arrivals/north_2
//	/area/maintenance/fpmaint2/fore_port_maintenance
	name = "Arrivals North Maintenance"
	icon_state = "fpmaint"

/area/maintenance/aft
//	/area/maintenance/aft/Aft_Maintenance // old aft maint path was engi maint
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/aft/secondary
	name = "Aft Maintenance"
	icon_state = "amaint_2"

/area/maintenance/central
//	/area/maintenance/maintcentral
	name = "Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/central/secondary
	name = "Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/fore/secondary
	name = "Fore Maintenance"
	icon_state = "fmaint_2"

/area/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/starboard/central
	name = "Central Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/starboard/aft
//	/area/maintenance/starboard/aft_starboard_maintenance
	name = "Starboard Quarter Maintenance"
	icon_state = "asmaint"

/area/maintenance/starboard/fore
//	/area/maintenance/starboard/fore_starboard_maintenance
	name = "Starboard Bow Maintenance"
	icon_state = "fsmaint"

/area/maintenance/port
//	/area/maintenance/fpmaint2/port_maintenance
	name = "Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/port/central
	name = "Central Port Maintenance"
	icon_state = "maintcentral"

/area/maintenance/port/aft
//	/area/maintenance/fpmaint2/aft_port_maintenance
	name = "Port Quarter Maintenance"
	icon_state = "apmaint"

/area/maintenance/port/fore
	name = "Port Bow Maintenance"
	icon_state = "fpmaint"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/maintenance/disposal/incinerator
//	/area/maintenance/incinerator
	name = "Incinerator"
	icon_state = "disposal"


//Cere / Asteroid Specific
/area/maintenance/asteroid
	sound_environment = 8

/area/maintenance/asteroid/aft/science
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/asteroid/aft/arrivals
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/asteroid/central
	name = "Central Asteroid Maintenance"
	icon_state = "maintcentral"

/area/maintenance/asteroid/disposal/east
	name = "Eastern External Waste Belt"
	icon_state = "disposal"

/area/maintenance/asteroid/disposal/north
	name = "Northern External Waste Belt"
	icon_state = "disposal"

/area/maintenance/asteroid/disposal/southeast
	name = "South-Eastern Disposal"
	icon_state = "disposal"

/area/maintenance/asteroid/disposal/southwest
	name = "South-Western Disposal"
	icon_state = "disposal"

/area/maintenance/asteroid/fore/cargo_west
	name = "Fore Asteroid Maintenance"
	icon_state = "fmaint"

/area/maintenance/asteroid/fore/cargo_south
	name = "Fore Asteroid Maintenance"
	icon_state = "fmaint"

/area/maintenance/asteroid/fore/com_west
	name = "Fore Asteroid Maintenance"
	icon_state = "fmaint"

/area/maintenance/asteroid/fore/com_north
	name = "Fore Asteroid Maintenance"
	icon_state = "fmaint"

/area/maintenance/asteroid/fore/com_east
	name = "Fore Asteroid Maintenance"
	icon_state = "fmaint"

/area/maintenance/asteroid/fore/com_south
	name = "Fore Asteroid Maintenance"
	icon_state = "fmaint"

/area/maintenance/asteroid/port/neast
	name = "Port Asteroid Maintenance"
	icon_state = "pmaint"

/area/maintenance/asteroid/port/east
	name = "Port Asteroid Maintenance"
	icon_state = "pmaint"

/area/maintenance/asteroid/port/west
	name = "Port Asteroid Maintenance"
	icon_state = "pmaint"

/area/maintenance/asteroid/starboard
	name = "Starboard Asteroid Maintenance"
	icon_state = "smaint"


//Hallway
/area/hallway/primary
	sound_environment = 10

/area/hallway/primary/fore
	name = "Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/starboard/aft
	name = "Starboard Quarter Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/starboard/fore
	name = "Starboard Bow Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/aft
	name = "Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/port
	name = "Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/central
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/exit/departure_lounge
	name = "Departure Lounge"
	icon_state = "escape"

/area/hallway/secondary/bridges/cargo_ai
	name = "Cargo-AI-Command Bridge"
	icon_state = "yellow"

/area/hallway/secondary/bridges/com_engi
	name = "Command-Engineering Bridge"
	icon_state = "yellow"

/area/hallway/secondary/bridges/com_serv
	name = "Command-Service Bridge"
	icon_state = "yellow"

/area/hallway/secondary/bridges/dock_med
	name = "Docking-Medical Bridge"
	icon_state = "yellow"

/area/hallway/secondary/bridges/engi_med
	name = "Engineering-Medical Bridge"
	icon_state = "yellow"

/area/hallway/secondary/bridges/med_cargo
	name = "Medical-Cargo Bridge"
	icon_state = "yellow"

/area/hallway/secondary/bridges/sci_dock
	name = "Science-Docking Bridge"
	icon_state = "yellow"

/area/hallway/secondary/bridges/serv_engi
	name = "Service-Engineering Bridge"
	icon_state = "yellow"

/area/hallway/secondary/bridges/serv_sci
	name = "Service-Science Bridge"
	icon_state = "yellow"

/area/hallway/secondary/command
	name = "Command Hallway"
	icon_state = "bridge_hallway"

/area/hallway/secondary/construction
	name = "Construction Area"
	icon_state = "construction"

/area/hallway/secondary/entry
	name = "Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/secondary/service
	name = "Service Hallway"
	icon_state = "Sleep"

//Command

/area/bridge
	name = "Bridge"
	icon_state = "bridge"
	music = "signal"
	sound_environment = 4

/area/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "meeting"
	music = null
	sound_environment = 4

/area/bridge/meeting_room/council
	name = "Council Chamber"
	icon_state = "meeting"
	music = null
	sound_environment = 4

/area/bridge/showroom/corporate
	name = "Corporate Showroom"
	icon_state = "showroom"
	music = null
	sound_environment = 4

/area/crew_quarters/heads/captain
//	/area/crew_quarters/captain
	name = "Captain's Office"
	icon_state = "captain"
	sound_environment = 4

/area/crew_quarters/heads/captain/private
//	/area/crew_quarters/captain/captains_quarters
	name = "Captain's Quarters"
	icon_state = "captain"
	sound_environment = 2

/area/crew_quarters/heads/chief
//	/area/crew_quarters/chief
//	/area/engine/chiefs_office
	name = "Chief Engineer's Office"
	icon_state = "ce_office"
	sound_environment = 4

/area/crew_quarters/heads/chief/private
//	/area/crew_quarters/chief/private
	name = "Chief Engineer's Private Quarters"
	icon_state = "ce_private"
	sound_environment = 2

/area/crew_quarters/heads/cmo
//	/area/medical/cmo
	name = "Chief Medical Officer's Office"
	icon_state = "cmo_office"
	sound_environment = 4

/area/crew_quarters/heads/cmo/private
//	/area/medical/cmo/private
	name = "Chief Medical Officer's Private Quarters"
	icon_state = "cmo_private"
	sound_environment = 2

/area/crew_quarters/heads/hop
//	/area/crew_quarters/heads
	name = "Head of Personnel's Office"
	icon_state = "hop_office"
	sound_environment = 4

/area/crew_quarters/heads/hop/private
//	/area/crew_quarters/heads
	name = "Head of Personnel's Private Quarters"
	icon_state = "hop_private"
	sound_environment = 2

/area/crew_quarters/heads/hos
//	/area/security/hos
	name = "Head of Security's Office"
	icon_state = "hos_office"
	sound_environment = 4

/area/crew_quarters/heads/hos/private
//	/area/security/hos/private
	name = "Head of Security's Private Quarters"
	icon_state = "hos_private"
	sound_environment = 2

/area/crew_quarters/heads/hor
//	/area/crew_quarters/hor
	name = "Research Director's Office"
	icon_state = "rd_office"
	sound_environment = 4

/area/crew_quarters/heads/hor/private
//	/area/crew_quarters/hor/private
	name = "Research Director's Private Quarters"
	icon_state = "rd_private"
	sound_environment = 2

/area/mint
	name = "Mint"
	icon_state = "green"

/area/comms
	name = "Communications Relay"
	icon_state = "tcomsatcham"
	sound_environment = 10

/area/server
	name = "Messaging Server Room"
	icon_state = "server"
	sound_environment = 10

//Crew

/area/crew_quarters/dorms
//	/area/crew_quarters
//	/area/crew_quarters/sleep
	name = "Dormitories"
	icon_state = "Sleep"
	safe = 1
	sound_environment = 2

/area/crew_quarters/dorms/male
//	/area/crew_quarters/sleep_male
	name = "Male Dorm"
	icon_state = "Sleep"

/area/crew_quarters/dorms/female
//	/area/crew_quarters/sleep_female
	name = "Female Dorm"
	icon_state = "Sleep"

/area/crew_quarters/rehab_dome
	name = "Rehabilitation Dome"
	icon_state = "Sleep"

/area/crew_quarters/toilet
	name = "Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = 3

/area/crew_quarters/toilet/auxiliary
	name = "Auxiliary Restrooms"
	icon_state = "toilet"

/area/crew_quarters/toilet/locker
//	/area/crew_quarters/locker/locker_toilet
	name = "Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/female
//	/area/crew_quarters/sleep_female/toilet_female
	name = "Female Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/male
//	/area/crew_quarters/sleep_male/toilet_male
	name = "Male Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/restrooms
	name = "Restrooms"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"
	sound_environment = 10

/area/crew_quarters/lounge
	name = "Lounge"
	icon_state = "yellow"
	sound_environment = 2

/area/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"
	sound_environment = 2

/area/crew_quarters/fitness/recreation
	name = "Recreation Area"
	icon_state = "fitness"
	sound_environment = 2

/area/crew_quarters/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"
	sound_environment = 4

/area/crew_quarters/cafeteria/lunchroom
	name = "Lunchroom"
	icon_state = "cafeteria"
	sound_environment = 4

/area/crew_quarters/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
	sound_environment = 2

/area/crew_quarters/kitchen/backroom
	name = "Kitchen Coldroom"
	icon_state = "kitchen"
	sound_environment = 3

/area/crew_quarters/bar
	name = "Bar"
	icon_state = "bar"
	sound_environment = 10

/area/crew_quarters/bar/atrium
	name = "Atrium"
	icon_state = "bar"
	sound_environment = 10

/area/crew_quarters/electronic_marketing_den
	name = "Electronic Marketing Den"
	icon_state = "bar"

/area/crew_quarters/abandoned_gambling_den
	name = "Abandoned Gambling Den"
	icon_state = "bar"

/area/crew_quarters/theatre
	name = "Theatre"
	icon_state = "Theatre"
	sound_environment = 2

/area/crew_quarters/theatre/abandoned
	name = "Abandoned Theatre"
	icon_state = "Theatre"

/area/library
 	name = "Library"
 	icon_state = "library"
 	flags = NONE
 	sound_environment = 10

/area/library/lounge
 	name = "Library Lounge"
 	icon_state = "library"

/area/library/abandoned
//	/area/library/abandoned_library
 	name = "Abandoned Library"
 	icon_state = "library"
 	flags = NONE

/area/chapel
	icon_state = "chapel"
	ambientsounds = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg')
	flags = NONE
	sound_environment = 7

/area/chapel/main
	name = "Chapel"

/area/chapel/main/monastery
	name = "Monastery"

/area/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"
	sound_environment = 11

/area/chapel/asteroid
	name = "Chapel Asteroid"
	icon_state = "explored"

/area/chapel/dock
	name = "Chapel Dock"
	icon_state = "construction"

/area/lawoffice
	name = "Law Office"
	icon_state = "law"
	sound_environment = 2


//Engineering

/area/engine
	ambientsounds = list('sound/ambience/ambisin1.ogg','sound/ambience/ambisin2.ogg','sound/ambience/ambisin3.ogg','sound/ambience/ambisin4.ogg')
	sound_environment = 10

/area/engine/engine_smes
	name = "Engineering SMES"
	icon_state = "engine_smes"
	sound_environment = 2

/area/engine/engineering
	name = "Engineering"
	icon_state = "engine"

/area/engine/atmos
//	/area/atmos
 	name = "Atmospherics"
 	icon_state = "atmos"
 	flags = NONE
 	sound_environment = 10

/area/engine/atmospherics_engine
	name = "Atmospherics Engine"
	icon_state = "atmos_engine"
	sound_environment = 2

/area/engine/supermatter
	name = "Supermatter Engine"
	icon_state = "engine_sm"
	sound_environment = 3

/area/engine/break_room
	name = "Engineering Foyer"
	icon_state = "engine_foyer"
	sound_environment = 10

/area/engine/gravity_generator
	name = "Gravity Generator Room"
	icon_state = "grav_gen"
	sound_environment = 2

/area/engine/secure_construction
	name = "Secure Construction Area"
	icon_state = "engine"

/area/engine/storage
	name = "Engineering Storage"
	icon_state = "engi_storage"
	sound_environment = 2

/area/engine/transit_tube
	name = "Transit Tube"
	icon_state = "transit_tube"
	sound_environment = 21 //transit tube, sewer pipe, whats the difference


//Solars

/area/solar
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	valid_territory = 0
	blob_allowed = FALSE
	flags = NONE

/area/solar/asteroid/aft
	name = "Aft Asteroid Solar"
	icon_state = "panelsA"

/area/solar/asteroid/command
	name = "Command Asteroid Solar"
	icon_state = "panelsA"

/area/solar/asteroid/fore
	name = "Fore Asteroid Solar"
	icon_state = "panelsA"

/area/solar/fore
	name = "Fore Solar Array"
	icon_state = "yellow"

/area/solar/aft
	name = "Aft Solar Array"
	icon_state = "yellow"

/area/solar/aux/port
//	/area/solar/auxport
	name = "Port Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solar/aux/starboard
//	/area/solar/auxstarboard
	name = "Starboard Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solar/starboard
	name = "Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/starboard/aft
//	/area/solar/starboard
	name = "Starboard Quarter Solar Array"
	icon_state = "panelsAS"

/area/solar/starboard/fore
	name = "Starboard Bow Solar Array"
	icon_state = "panelsFS"

/area/solar/port
	name = "Port Solar Array"
	icon_state = "panelsP"

/area/solar/port/aft
//	/area/solar/port
	name = "Port Quarter Solar Array"
	icon_state = "panelsAP"

/area/solar/port/fore
	name = "Port Bow Solar Array"
	icon_state = "panelsFP"


//Solar Maint

/area/maintenance/solars
	name = "Solar Maintenance"
	icon_state = "yellow"

/area/maintenance/solars/asteroid/aft
	name = "Aft Asteroid Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/solars/asteroid/command
	name = "Command Asteroid Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/solars/asteroid/fore
	name = "Fore Asteroid Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/solars/port
	name = "Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/solars/port/aft
	name = "Port Quarter Solar Maintenance"
	icon_state = "SolarcontrolAP"

/area/maintenance/solars/port/fore
	name = "Port Bow Solar Maintenance"
	icon_state = "SolarcontrolFP"

/area/maintenance/solars/starboard
	name = "Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/solars/starboard/aft
	name = "Starboard Quarter Solar Maintenance"
	icon_state = "SolarcontrolAS"

/area/maintenance/solars/starboard/fore
	name = "Starboard Bow Solar Maintenance"
	icon_state = "SolarcontrolFS"

/area/maintenance/solars/aux/port
	name = "Port Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/solars/aux/port/aft
//	/area/maintenance/portsolar
	name = "Port Quarter Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolAP"

/area/maintenance/solars/aux/port/fore
//	/area/maintenance/auxsolarport
	name = "Port Bow Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/solars/aux/starboard
	name = "Starboard Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/solars/aux/starboard/aft
//	/area/maintenance/starboardsolar
//	/area/maintenance/solars/aux/starboard/port/aft
	name = "Starboard Quarter Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/solars/aux/starboard/fore
//	/area/maintenance/auxsolarstarboard
	name = "Starboard Bow Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/assembly/assembly_line //Derelict Assembly Line
	name = "Assembly Line"
	icon_state = "ass_line"
	power_equip = 0
	power_light = 0
	power_environ = 0

//Teleporter

/area/teleporter
	name = "Teleporter Room"
	icon_state = "teleporter"
	music = "signal"
	sound_environment = 2

/area/teleporter/quantum/cargo
	name = "Cargo Quantum Pad"
	icon_state = "teleporter"
	music = "signal"

/area/teleporter/quantum/docking
	name = "Docking Quantum Pad"
	icon_state = "teleporter"
	music = "signal"

/area/teleporter/quantum/research
	name = "Research Quantum Pad"
	icon_state = "teleporter"
	music = "signal"

/area/teleporter/quantum/security
	name = "Security Quantum Pad"
	icon_state = "teleporter"
	music = "signal"

/area/gateway
	name = "Gateway"
	icon_state = "teleporter"
	music = "signal"

//MedBay

/area/medical
	name = "Medical"
	icon_state = "medbay3"
	sound_environment = 3

/area/medical/abandoned
//	/area/medical/abandoned_medbay
	name = "Abandoned Medbay"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay/central
//	/area/medical/medbay
	name = "Medbay Central"
	icon_state = "medbay"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay/front_office
	name = "Medbay Front Office"
	icon_state = "medbay"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay/lobby
	name = "Medbay Lobby"
	icon_state = "medbay"
	music = 'sound/ambience/signal.ogg'

//Medbay is a large area, these additional areas help level out APC load.
/area/medical/medbay/zone2
//	/area/medical/medbay2
	name = "Medbay"
	icon_state = "medbay2"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay/zone3
//	/area/medical/medbay3
	name = "Medbay"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay/aft
//	/area/medical/medbay3/aft
	name = "Medbay Aft"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/storage
//	/area/medical/medbay2/medbay_storage
	name = "Medbay Storage"
	icon_state = "medbay2"
	music = 'sound/ambience/signal.ogg'

/area/medical/patients_rooms
	name = "Patients' Rooms"
	icon_state = "patients"
	sound_environment = 3

/area/medical/patients_rooms/room_a
	name = "Patient Room A"
	icon_state = "patients"

/area/medical/patients_rooms/room_b
	name = "Patient Room B"
	icon_state = "patients"

/area/medical/virology
	name = "Virology"
	icon_state = "virology"
	flags = NONE
	sound_environment = 3

/area/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	ambientsounds = list('sound/ambience/ambimo1.ogg','sound/ambience/ambimo2.ogg')
	sound_environment = 3

/area/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/medical/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/medical/genetics/cloning
//	/area/medical/genetics_cloning
	name = "Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Medbay Treatment Center"
	icon_state = "exam_room"


//Security

/area/security
	name = "Security"
	icon_state = "security"
	sound_environment = 2

/area/security/main
	name = "Security Office"
	icon_state = "security"

/area/security/brig
	name = "Brig"
	icon_state = "brig"

/area/security/courtroom
//	/area/crew_quarters/courtroom
	name = "Courtroom"
	icon_state = "courtroom"
	sound_environment = 0

/area/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"

/area/security/processing
	name = "Labor Shuttle Dock"
	icon_state = "sec_prison"

/area/security/processing/cremation
	name = "Security Crematorium"
	icon_state = "sec_prison"

/area/security/warden
	name = "Brig Control"
	icon_state = "Warden"

/area/security/armory
	name = "Armory"
	icon_state = "armory"

/area/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg','sound/ambience/ambidet2.ogg')

/area/security/detectives_office/private_investigators_office
	name = "Private Investigator's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg','sound/ambience/ambidet2.ogg')

/area/security/range
	name = "Firing Range"
	icon_state = "firingrange"
	sound_environment = 10

/area/security/transfer
	name = "Transfer Centre"
	icon_state = "execution_room"

/area/security/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/ai_monitored/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint/checkpoint2
//	/area/security/checkpoint2
	name = "Security Checkpoint"
	icon_state = "security"

/area/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint1"

/area/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint1"

/area/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint1"

/area/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint1"

/area/security/checkpoint/science/research
	name = "Security Post - Research Division"
	icon_state = "checkpoint1"

/area/security/checkpoint/customs
	name = "Customs"
	icon_state = "bridge"

/area/security/vacantoffice
	name = "Vacant Office"
	icon_state = "security"

/area/security/vacantoffice/a
	name = "Vacant Office A"
	icon_state = "security"

/area/security/vacantoffice/b
//	/area/security/vacantoffice2
	name = "Vacant Office B"
	icon_state = "security"

/area/quartermaster
	name = "Quartermasters"
	icon_state = "quart"

///////////WORK IN PROGRESS//////////

/area/quartermaster/sorting
	name = "Delivery Office"
	icon_state = "cargo_delivery"

/area/quartermaster/warehouse
	name = "Warehouse"
	icon_state = "cargo_warehouse"

////////////WORK IN PROGRESS//////////
/area/quartermaster
	sound_environment = 2
/area/quartermaster/office
	name = "Cargo Office"
	icon_state = "quartoffice"
	sound_environment = 2

/area/quartermaster/storage
	name = "Cargo Bay"
	icon_state = "cargo_bay"
	sound_environment = 10

/area/quartermaster/qm
	name = "Quartermaster's Office"
	icon_state = "quart"
	sound_environment = 2

/area/quartermaster/qm/private
	name = "Quartermaster's Private Quarters"
	icon_state = "quart"
	sound_environment = 3

/area/quartermaster/miningdock
	name = "Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningdock/abandoned
	name = "Abandoned Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningoffice
	name = "Mining Office"
	icon_state = "mining"

/area/quartermaster/miningstorage
	name = "Mining Storage"
	icon_state = "mining"

/area/janitor
	name = "Custodial Closet"
	icon_state = "janitor"
	flags = NONE
	sound_environment = 3

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	sound_environment = 2

/area/hydroponics/garden
	name = "Garden"
	icon_state = "garden"
	sound_environment = 2

/area/hydroponics/garden/abandoned
	name = "Abandoned Garden"
	icon_state = "abandoned_garden"

/area/hydroponics/garden/monastery
	name = "Monastery Garden"
	icon_state = "hydro"


//Science

/area/science
	name = "Science Division"
	icon_state = "toxlab"
	sound_environment = 2

/area/science/lab
	name = "Research and Development"
	icon_state = "toxlab"
	sound_environment = 2

/area/science/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxlab"
	sound_environment = 2

/area/science/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"
	sound_environment = 3

/area/science/mineral_storeroom
	name = "Mineral Storeroom"
	icon_state = "toxmisc"

/area/science/test_area
	valid_territory = 0
	name = "Toxins Test Area"
	icon_state = "toxtest"

/area/science/mixing
	name = "Toxins Mixing Lab"
	icon_state = "toxmix"
	sound_environment = 2

/area/science/misc_lab
	name = "Testing Lab"
	icon_state = "toxmisc"
	sound_environment = 10

/area/science/misc_lab/range
	name = "Research Testing Range"
	icon_state = "toxmisc"
	sound_environment = 10

/area/science/server
	name = "Research Division Server Room"
	icon_state = "server"
	sound_environment = 3

/area/science/explab
	name = "Experimentation Lab"
	icon_state = "toxmisc"
	sound_environment = 2

/area/science/robotics
//	/area/medical/robotics
	name = "Robotics"
	icon_state = "medresearch"
	sound_environment = 2

/area/science/robotics/mechbay
//	/area/assembly/chargebay
	name = "Mech Bay"
	icon_state = "mechbay"
	sound_environment = 2

/area/science/robotics/mechbay_cargo
//	/area/quartermaster/mechbay
	name = "Mech Bay"
	icon_state = "yellow"

/area/science/robotics/showroom
//	/area/assembly/showroom
	name = "Robotics Showroom"
	icon_state = "showroom"

/area/science/robotics/lab
//	/area/assembly/robotics
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/science/research
//	/area/medical/research
	name = "Research Division"
	icon_state = "medresearch"

/area/science/research/lobby
//	/area/medical/research/research_lobby
	name = "Research Division Lobby"
	icon_state = "medresearch"

/area/science/research/abandoned
//	/area/medical/research/abandoned
//	/area/medical/research/abandoned_research_lab
	name = "Abandoned Research Lab"
	icon_state = "medresearch"

//Storage
/area/storage
	sound_environment = 2

/area/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "storage"

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/autolathe
	name = "Autolathe Storage"
	icon_state = "storage"

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/storage/auxiliary
//	/area/storage/auxillary
	name = "Auxiliary Storage"
	icon_state = "auxstorage"

/area/storage/atmos
//	/area/maintenance/storage
	name = "Atmospherics Storage"
	icon_state = "atmos"
	valid_territory = 0

/area/storage/tcom
//	/area/maintenance/storage/tcom_storage
	name = "Telecoms Storage"
	icon_state = "green"
	valid_territory = 0

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/storage/emergency/starboard
//	/area/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency/port
//	/area/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/storage/testroom
	requires_power = 0
	name = "Test Room"
	icon_state = "storage"


//Construction

/area/construction
	name = "Construction Area"
	icon_state = "yellow"

/area/construction/minisat_exterior
	name = "Minisat Exterior"
	icon_state = "yellow"

/area/construction/mining/aux_base
//	/area/mining_construction
	name = "Auxiliary Base Construction"
	icon_state = "yellow"
	sound_environment = 10

/area/construction/mining/aux_base/closet
//	/area/mining_construction/closet
	name = "Auxiliary Closet Construction"
	icon_state = "yellow"

/area/construction/supplyshuttle
	name = "Supply Shuttle"
	icon_state = "yellow"

/area/construction/quarters
	name = "Engineers' Quarters"
	icon_state = "yellow"

/area/construction/qmaint
	name = "Maintenance"
	icon_state = "yellow"

/area/construction/hallway
	name = "Hallway"
	icon_state = "yellow"

/area/construction/solars
	name = "Solar Panels"
	icon_state = "yellow"

/area/construction/solarscontrol
	name = "Solar Panel Control"
	icon_state = "yellow"

/area/construction/storage
	name = "Construction Site Storage"
	icon_state = "yellow"

/area/construction/storage/wing
//	/area/construction/Storage
	name = "Storage Wing"
	icon_state = "storage_wing"


//AI
/area/ai_monitored
	sound_environment = 2

/area/ai_monitored/security/armory
	name = "Armory"
	icon_state = "armory"

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/ai_monitored/storage/secure
	name = "AI Satellite Storage"
	icon_state = "storage"

/area/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"

/area/ai_monitored/storage/satellite
	name = "AI Satellite Maint"
	icon_state = "storage"


/area/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg')

/area/ai_monitored/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"

/area/ai_monitored/turret_protected/ai_upload_foyer
	name = "AI Upload Access"
	icon_state = "ai_foyer"

/area/ai_monitored/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/ai_monitored/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/atmos
	name = "AI Satellite Atmos"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/foyer
	name = "AI Satellite Foyer"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/service
	name = "AI Satellite Service"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/hallway
	name = "AI Satellite Hallway"
	icon_state = "ai"

/area/aisat
	name = "AI Satellite Exterior"
	icon_state = "yellow"

/area/ai_monitored/turret_protected/aisat_interior
	name = "AI Satellite Antechamber"
	icon_state = "ai"

/area/ai_monitored/turret_protected/AIsatextFP
	name = "AI Sat Ext"
	icon_state = "storage"

/area/ai_monitored/turret_protected/AIsatextFS
	name = "AI Sat Ext"
	icon_state = "storage"

/area/ai_monitored/turret_protected/AIsatextAS
	name = "AI Sat Ext"
	icon_state = "storage"

/area/ai_monitored/turret_protected/AIsatextAP
	name = "AI Sat Ext"
	icon_state = "storage"

/area/ai_monitored/turret_protected/NewAIMain
	name = "AI Main New"
	icon_state = "storage"



// Telecommunications Satellite

/area/tcommsat
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')
	sound_environment = 2

/area/tcommsat/entrance
	name = "Telecoms Teleporter"
	icon_state = "tcomsatentrance"

/area/tcommsat/chamber
	name = "Abandoned Satellite"
	icon_state = "tcomsatcham"

/area/ai_monitored/turret_protected/tcomsat
	name = "Telecoms Satellite"
	icon_state = "tcomsatlob"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/ai_monitored/turret_protected/tcomfoyer
	name = "Telecoms Foyer"
	icon_state = "tcomsatentrance"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/ai_monitored/turret_protected/tcomwest
	name = "Telecommunications Satellite West Wing"
	icon_state = "tcomsatwest"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/ai_monitored/turret_protected/tcomeast
	name = "Telecommunications Satellite East Wing"
	icon_state = "tcomsateast"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/tcommsat/computer
	name = "Telecoms Control Room"
	icon_state = "tcomsatcomp"

/area/tcommsat/server
	name = "Telecoms Server Room"
	icon_state = "tcomsatcham"

/area/tcommsat/lounge
	name = "Telecommunications Satellite Lounge"
	icon_state = "tcomsatlounge"

/////////////////////////////////////////////////////////////////////
/*
 Lists of areas to be used with is_type_in_list.
 Used in gamemodes code at the moment. --rastaf0
*/

//SPACE STATION 13
GLOBAL_LIST_INIT(the_station_areas, list (
	/area/assembly,
	/area/bridge,
	/area/chapel,
	/area/construction,
	/area/crew_quarters,
	/area/engine,
	/area/hallway,
	/area/holodeck,
	/area/hydroponics,
	/area/janitor,
	/area/lawoffice,
	/area/library,
	/area/maintenance,
	/area/medical,
//	/area/mint,		//not present on map
	/area/quartermaster,
	/area/science,	// /area/toxins/
	/area/security,
	/area/solar,
	/area/storage,
	/area/teleporter,
	/area/ai_monitored/storage/eva, //do not try to simplify to "/area/ai_monitored" --rastaf0
//	/area/ai_monitored/storage/secure,	//not present on map
//	/area/ai_monitored/storage/emergency,	//not present on map
	/area/ai_monitored/turret_protected/ai_upload, //do not try to simplify to "/area/ai_monitored/turret_protected" --rastaf0
	/area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai,
))