/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = 'ICON FILENAME' 			(defaults to 'icons/turf/areas.dmi')
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = FALSE 				(defaults to true)
	music = null					(defaults to nothing, look in sound/ambience for music)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/*-----------------------------------------------------------------------------*/

/area/ai_monitored	//stub defined ai_monitored.dm

/area/ai_monitored/turret_protected

/area/arrival
	requires_power = FALSE

/area/arrival/start
	name = "Arrival Area"
	icon_state = "start"

/area/admin
	name = "Admin room"
	icon_state = "start"

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	valid_territory = FALSE
	outdoors = TRUE
	ambientsounds = SPACE
	blob_allowed = FALSE //Eating up space doesn't count for victory as a blob.

/area/space/nearstation
	icon_state = "space_near"
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT

/area/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = STANDARD_GRAVITY


//EXTRA

/area/asteroid
	name = "Asteroid"
	icon_state = "asteroid"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	blob_allowed = FALSE //Nope, no winning on the asteroid as a blob. Gotta eat the station.
	valid_territory = FALSE
	ambientsounds = MINING

/area/asteroid/nearstation
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambientsounds = RUINS
	always_unpowered = FALSE
	requires_power = TRUE
	blob_allowed = TRUE

/area/asteroid/nearstation/bomb_site
	name = "Bomb Testing Asteroid"

/area/asteroid/cave
	name = "Asteroid - Underground"
	icon_state = "cave"
	requires_power = FALSE
	outdoors = TRUE

/area/asteroid/cave/space
	name = "Asteroid - Space"

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"
	ambientsounds = RUINS

/area/asteroid/artifactroom/Initialize()
	. = ..()
	set_dynamic_lighting()


//STATION13

//Maintenance

/area/maintenance
	ambientsounds = MAINTENANCE
	valid_territory = FALSE


//Departments

/area/maintenance/department/chapel
	name = "Chapel Maintenance"
	icon_state = "maint_chapel"

/area/maintenance/department/chapel/monastery
	name = "Monastery Maintenance"
	icon_state = "maint_monastery"

/area/maintenance/department/crew_quarters/bar
	name = "Bar Maintenance"
	icon_state = "maint_bar"

/area/maintenance/department/crew_quarters/dorms
	name = "Dormitory Maintenance"
	icon_state = "maint_dorms"

/area/maintenance/department/crew_quarters/locker
	name = "Locker Room Maintenance"
	icon_state = "maint_locker"

/area/maintenance/department/eva
	name = "EVA Maintenance"
	icon_state = "maint_eva"

/area/maintenance/department/electrical
	name = "Electrical Maintenance"
	icon_state = "maint_electrical"

/area/maintenance/department/engine/atmos
	name = "Atmospherics Maintenance"
	icon_state = "maint_atmos"

/area/maintenance/department/security
	name = "Security Maintenance"
	icon_state = "maint_sec"

/area/maintenance/department/security/brig
	name = "Brig Maintenance"
	icon_state = "maint_brig"

/area/maintenance/department/medical
	name = "Medbay Maintenance"
	icon_state = "medbay_maint"

/area/maintenance/department/medical/morgue
	name = "Morgue Maintenance"
	icon_state = "morgue_maint"

/area/maintenance/department/science
	name = "Science Maintenance"
	icon_state = "maint_sci"

/area/maintenance/department/cargo
	name = "Cargo Maintenance"
	icon_state = "maint_cargo"

/area/maintenance/department/bridge
	name = "Bridge Maintenance"
	icon_state = "maint_bridge"

/area/maintenance/department/engine
	name = "Engineering Maintenance"
	icon_state = "maint_engi"

/area/maintenance/department/science/xenobiology
	name = "Xenobiology Maintenance"
	icon_state = "xenomaint"
	xenobiology_compatible = TRUE


//Maintenance - Generic

/area/maintenance/arrivals/north
	name = "Arrivals North Maintenance"
	icon_state = "fpmaint"

/area/maintenance/arrivals/north_2
	name = "Arrivals North Maintenance"
	icon_state = "fpmaint"

/area/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/aft/secondary
	name = "Aft Maintenance"
	icon_state = "amaint_2"

/area/maintenance/central
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
	name = "Starboard Quarter Maintenance"
	icon_state = "asmaint"

/area/maintenance/starboard/fore
	name = "Starboard Bow Maintenance"
	icon_state = "fsmaint"

/area/maintenance/port
	name = "Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/port/central
	name = "Central Port Maintenance"
	icon_state = "maintcentral"

/area/maintenance/port/aft
	name = "Port Quarter Maintenance"
	icon_state = "apmaint"

/area/maintenance/port/fore
	name = "Port Bow Maintenance"
	icon_state = "fpmaint"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/maintenance/disposal/incinerator
	name = "Incinerator"
	icon_state = "disposal"


//Hallway

/area/hallway/primary/aft
	name = "Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/fore
	name = "Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/starboard/aft
	name = "Starboard Quarter Primary Hallway"
	icon_state = "hallAS"

/area/hallway/primary/starboard/fore
	name = "Starboard Bow Primary Hallway"
	icon_state = "hallFS"

/area/hallway/primary/port
	name = "Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/port/aft
	name = "Port Quarter Primary Hallway"
	icon_state = "hallAP"

/area/hallway/primary/port/fore
	name = "Port Bow Primary Hallway"
	icon_state = "hallFP"

/area/hallway/primary/central
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/secondary/command
	name = "Command Hallway"
	icon_state = "bridge_hallway"

/area/hallway/secondary/construction
	name = "Construction Area"
	icon_state = "construction"

/area/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/exit/departure_lounge
	name = "Departure Lounge"
	icon_state = "escape_lounge"

/area/hallway/secondary/entry
	name = "Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/secondary/service
	name = "Service Hallway"
	icon_state = "hall_service"

//Command

/area/bridge
	name = "Bridge"
	icon_state = "bridge"
	music = "signal"

/area/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "meeting"
	music = null

/area/bridge/meeting_room/council
	name = "Council Chamber"
	icon_state = "meeting"
	music = null

/area/bridge/showroom/corporate
	name = "Corporate Showroom"
	icon_state = "showroom"
	music = null

/area/crew_quarters/heads/captain
	name = "Captain's Office"
	icon_state = "captain"

/area/crew_quarters/heads/captain/private
	name = "Captain's Quarters"
	icon_state = "captain"

/area/crew_quarters/heads/chief
	name = "Chief Engineer's Office"
	icon_state = "ce_office"

/area/crew_quarters/heads/chief/private
	name = "Chief Engineer's Private Quarters"
	icon_state = "ce_private"

/area/crew_quarters/heads/cmo
	name = "Chief Medical Officer's Office"
	icon_state = "cmo_office"

/area/crew_quarters/heads/cmo/private
	name = "Chief Medical Officer's Private Quarters"
	icon_state = "cmo_private"

/area/crew_quarters/heads/hop
	name = "Head of Personnel's Office"
	icon_state = "hop_office"

/area/crew_quarters/heads/hop/private
	name = "Head of Personnel's Private Quarters"
	icon_state = "hop_private"

/area/crew_quarters/heads/hos
	name = "Head of Security's Office"
	icon_state = "hos_office"

/area/crew_quarters/heads/hos/private
	name = "Head of Security's Private Quarters"
	icon_state = "hos_private"

/area/crew_quarters/heads/hor
	name = "Research Director's Office"
	icon_state = "rd_office"

/area/crew_quarters/heads/hor/private
	name = "Research Director's Private Quarters"
	icon_state = "rd_private"

/area/comms
	name = "Communications Relay"
	icon_state = "tcomsatcham"

/area/server
	name = "Messaging Server Room"
	icon_state = "server"

//Crew

/area/crew_quarters/dorms
	name = "Dormitories"
	icon_state = "Sleep"
	safe = TRUE

/area/crew_quarters/dorms/male
	name = "Male Dorm"
	icon_state = "Sleep"

/area/crew_quarters/dorms/female
	name = "Female Dorm"
	icon_state = "Sleep"

/area/crew_quarters/rehab_dome
	name = "Rehabilitation Dome"
	icon_state = "Sleep"

/area/crew_quarters/toilet
	name = "Dormitory Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/auxiliary
	name = "Auxiliary Restrooms"
	icon_state = "toilet"

/area/crew_quarters/toilet/locker
	name = "Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/fitness
	name = "Fitness Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/female
	name = "Female Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/male
	name = "Male Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/restrooms
	name = "Restrooms"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"

/area/crew_quarters/lounge
	name = "Lounge"
	icon_state = "yellow"

/area/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/fitness/recreation
	name = "Recreation Area"
	icon_state = "fitness"

/area/crew_quarters/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/cafeteria/lunchroom
	name = "Lunchroom"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/kitchen/backroom
	name = "Kitchen Coldroom"
	icon_state = "kitchen"

/area/crew_quarters/bar
	name = "Bar"
	icon_state = "bar"

/area/crew_quarters/bar/atrium
	name = "Atrium"
	icon_state = "bar"

/area/crew_quarters/electronic_marketing_den
	name = "Electronic Marketing Den"
	icon_state = "bar"

/area/crew_quarters/abandoned_gambling_den
	name = "Abandoned Gambling Den"
	icon_state = "abandoned_g_den"

/area/crew_quarters/abandoned_gambling_den/secondary
	icon_state = "abandoned_g_den_2"

/area/crew_quarters/theatre
	name = "Theatre"
	icon_state = "Theatre"

/area/crew_quarters/theatre/abandoned
	name = "Abandoned Theatre"
	icon_state = "Theatre"

/area/library
	name = "Library"
	icon_state = "library"
	flags_1 = NONE

/area/library/lounge
	name = "Library Lounge"
	icon_state = "library"

/area/library/abandoned
	name = "Abandoned Library"
	icon_state = "library"
	flags_1 = NONE

/area/chapel
	icon_state = "chapel"
	ambientsounds = HOLY
	flags_1 = NONE
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The consecration here prevents you from warping in."

/area/chapel/main
	name = "Chapel"

/area/chapel/main/monastery
	name = "Monastery"

/area/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"

/area/chapel/asteroid
	name = "Chapel Asteroid"
	icon_state = "explored"

/area/chapel/asteroid/monastery
	name = "Monastery Asteroid"

/area/chapel/dock
	name = "Chapel Dock"
	icon_state = "construction"

/area/lawoffice
	name = "Law Office"
	icon_state = "law"


//Engineering

/area/engine
	ambientsounds = ENGINEERING

/area/engine/engine_smes
	name = "Engineering SMES"
	icon_state = "engine_smes"

/area/engine/engineering
	name = "Engineering"
	icon_state = "engine"

/area/engine/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	flags_1 = NONE

/area/engine/atmospherics_engine
	name = "Atmospherics Engine"
	icon_state = "atmos_engine"

/area/engine/supermatter
	name = "Supermatter Engine"
	icon_state = "engine_sm"

/area/engine/break_room
	name = "Engineering Foyer"
	icon_state = "engine_foyer"

/area/engine/gravity_generator
	name = "Gravity Generator Room"
	icon_state = "grav_gen"
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The gravitons generated here could throw off your warp's destination and possibly throw you into deep space."

/area/engine/secure_construction
	name = "Secure Construction Area"
	icon_state = "engine"

/area/engine/storage
	name = "Engineering Storage"
	icon_state = "engi_storage"

/area/engine/storage_shared
	name = "Shared Engineering Storage"
	icon_state = "engi_storage"

/area/engine/transit_tube
	name = "Transit Tube"
	icon_state = "transit_tube"


//Solars

/area/solar
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	valid_territory = FALSE
	blob_allowed = FALSE
	flags_1 = NONE
	ambientsounds = ENGINEERING

/area/solar/fore
	name = "Fore Solar Array"
	icon_state = "yellow"

/area/solar/aft
	name = "Aft Solar Array"
	icon_state = "yellow"

/area/solar/aux/port
	name = "Port Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solar/aux/starboard
	name = "Starboard Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solar/starboard
	name = "Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/starboard/aft
	name = "Starboard Quarter Solar Array"
	icon_state = "panelsAS"

/area/solar/starboard/fore
	name = "Starboard Bow Solar Array"
	icon_state = "panelsFS"

/area/solar/port
	name = "Port Solar Array"
	icon_state = "panelsP"

/area/solar/port/aft
	name = "Port Quarter Solar Array"
	icon_state = "panelsAP"

/area/solar/port/fore
	name = "Port Bow Solar Array"
	icon_state = "panelsFP"


//Solar Maint

/area/maintenance/solars
	name = "Solar Maintenance"
	icon_state = "yellow"

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
	name = "Port Quarter Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolAP"

/area/maintenance/solars/aux/port/fore
	name = "Port Bow Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/solars/aux/starboard
	name = "Starboard Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/solars/aux/starboard/aft
	name = "Starboard Quarter Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/solars/aux/starboard/fore
	name = "Starboard Bow Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

//Teleporter

/area/teleporter
	name = "Teleporter Room"
	icon_state = "teleporter"
	music = "signal"
	ambientsounds = ENGINEERING

/area/gateway
	name = "Gateway"
	icon_state = "gateway"
	music = "signal"
	ambientsounds = ENGINEERING

//MedBay

/area/medical
	name = "Medical"
	icon_state = "medbay3"
	ambientsounds = MEDICAL

/area/medical/abandoned
	name = "Abandoned Medbay"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay/central
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
	name = "Medbay"
	icon_state = "medbay2"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay/zone3
	name = "Medbay"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay/aft
	name = "Medbay Aft"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/storage
	name = "Medbay Storage"
	icon_state = "medbay2"
	music = 'sound/ambience/signal.ogg'

/area/medical/patients_rooms
	name = "Patients' Rooms"
	icon_state = "patients"

/area/medical/patients_rooms/room_a
	name = "Patient Room A"
	icon_state = "patients"

/area/medical/patients_rooms/room_b
	name = "Patient Room B"
	icon_state = "patients"

/area/medical/virology
	name = "Virology"
	icon_state = "virology"
	flags_1 = NONE

/area/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	ambientsounds = SPOOKY

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
	name = "Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Medbay Treatment Center"
	icon_state = "exam_room"


//Security

/area/security
	name = "Security"
	icon_state = "security"
	ambientsounds = HIGHSEC

/area/security/main
	name = "Security Office"
	icon_state = "security"

/area/security/brig
	name = "Brig"
	icon_state = "brig"

/area/security/courtroom
	name = "Courtroom"
	icon_state = "courtroom"

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

/area/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/security/execution
	icon_state = "execution_room"

/area/security/execution/transfer
	name = "Transfer Centre"

/area/security/execution/education
	name = "Prisoner Education Chamber"

/area/security/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/ai_monitored/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint/auxiliary
	icon_state = "checkpoint_aux"

/area/security/checkpoint/tertiary
	icon_state = "checkpoint_tert"

/area/security/checkpoint/escape
	icon_state = "checkpoint_esc"

/area/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint_supp"

/area/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint_engi"

/area/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint_med"

/area/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint_sci"

/area/security/checkpoint/science/research
	name = "Security Post - Research Division"
	icon_state = "checkpoint_res"

/area/security/checkpoint/customs
	name = "Customs"
	icon_state = "customs_point"

/area/security/checkpoint/customs/auxiliary
	icon_state = "customs_point_aux"

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

/area/quartermaster/office
	name = "Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/area/quartermaster/qm
	name = "Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/qm/private
	name = "Quartermaster's Private Quarters"
	icon_state = "quart"

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
	flags_1 = NONE

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

/area/hydroponics/garden
	name = "Garden"
	icon_state = "garden"

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

/area/science/lab
	name = "Research and Development"
	icon_state = "toxlab"

/area/science/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxlab"

/area/science/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"

/area/science/mineral_storeroom
	name = "Mineral Storeroom"
	icon_state = "toxmisc"

/area/science/test_area
	valid_territory = FALSE
	name = "Toxins Test Area"
	icon_state = "toxtest"

/area/science/mixing
	name = "Toxins Mixing Lab"
	icon_state = "toxmix"

/area/science/mixing/chamber
	name = "Toxins Mixing Chamber"
	icon_state = "toxmix"
	valid_territory = FALSE

/area/science/misc_lab
	name = "Testing Lab"
	icon_state = "toxmisc"

/area/science/misc_lab/range
	name = "Research Testing Range"
	icon_state = "toxmisc"

/area/science/server
	name = "Research Division Server Room"
	icon_state = "server"

/area/science/explab
	name = "Experimentation Lab"
	icon_state = "toxmisc"

/area/science/robotics
	name = "Robotics"
	icon_state = "medresearch"

/area/science/robotics/mechbay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/science/robotics/mechbay_cargo
	name = "Mech Bay"
	icon_state = "yellow"

/area/science/robotics/showroom
	name = "Robotics Showroom"
	icon_state = "showroom"

/area/science/robotics/lab
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/science/research
	name = "Research Division"
	icon_state = "medresearch"

/area/science/circuit
	name = "Circuitry Lab"
	icon_state = "cir_lab"

/area/science/research/lobby
	name = "Research Division Lobby"
	icon_state = "medresearch"

/area/science/research/abandoned
	name = "Abandoned Research Lab"
	icon_state = "medresearch"

/area/science/nanite
	name = "Nanite Lab"
	icon_state = "toxmisc"

//Storage

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
	name = "Auxiliary Storage"
	icon_state = "auxstorage"

/area/storage/atmos
	name = "Atmospherics Storage"
	icon_state = "atmos"
	valid_territory = FALSE

/area/storage/tcom
	name = "Telecomms Storage"
	icon_state = "green"
	valid_territory = FALSE

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	clockwork_warp_allowed = FALSE

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"
	clockwork_warp_allowed = FALSE

/area/storage/emergency/starboard
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency/port
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/storage/testroom
	requires_power = FALSE
	name = "Test Room"
	icon_state = "storage"


//Construction

/area/construction
	name = "Construction Area"
	icon_state = "yellow"
	ambientsounds = ENGINEERING

/area/construction/minisat_exterior
	name = "Minisat Exterior"
	icon_state = "yellow"

/area/construction/mining/aux_base
	name = "Auxiliary Base Construction"
	icon_state = "yellow"

/area/construction/mining/aux_base/closet
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
	name = "Storage Wing"
	icon_state = "storage_wing"

// Vacant Rooms
/area/vacant_room
	name = "Vacant Room"
	icon_state = "yellow"
	ambientsounds = MAINTENANCE

/area/vacant_room/office
	name = "Vacant Office"

/area/vacant_room/office/office_a
	name = "Vacant Office - A"

/area/vacant_room/office/office_b
	name = "Vacant Office - B"

/area/vacant_room/commissary
	name = "Vacant Commissary"


//AI

/area/ai_monitored/security/armory
	name = "Armory"
	icon_state = "armory"
	ambientsounds = HIGHSEC

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambientsounds = HIGHSEC

/area/ai_monitored/storage/satellite
	name = "AI Satellite Maint"
	icon_state = "storage"
	ambientsounds = HIGHSEC

	//Turret_protected

/area/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

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


// Telecommunications Satellite

/area/tcommsat
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "For safety reasons, warping here is disallowed; the radio and bluespace noise could cause catastrophic results."
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')

/area/tcommsat/entrance
	name = "Telecomms Teleporter"
	icon_state = "tcomsatentrance"

/area/tcommsat/chamber
	name = "Abandoned Satellite"
	icon_state = "tcomsatcham"

/area/ai_monitored/turret_protected/tcomsat
	name = "Telecomms Satellite"
	icon_state = "tcomsatlob"

/area/ai_monitored/turret_protected/tcomfoyer
	name = "Telecomms Foyer"
	icon_state = "tcomsatentrance"

/area/ai_monitored/turret_protected/tcomwest
	name = "Telecommunications Satellite West Wing"
	icon_state = "tcomsatwest"

/area/ai_monitored/turret_protected/tcomeast
	name = "Telecommunications Satellite East Wing"
	icon_state = "tcomsateast"

/area/tcommsat/computer
	name = "Telecomms Control Room"
	icon_state = "tcomsatcomp"

/area/tcommsat/server
	name = "Telecomms Server Room"
	icon_state = "tcomsatcham"

/area/tcommsat/lounge
	name = "Telecommunications Satellite Lounge"
	icon_state = "tcomsatlounge"
