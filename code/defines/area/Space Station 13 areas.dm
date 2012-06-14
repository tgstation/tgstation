/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)
	music = "music/music.ogg"		(defaults to "music/music.ogg")

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/area
	var/fire = null
	var/atmos = 1
	var/atmosalm = 0
	var/poweralm = 1
	var/party = null
	level = null
	name = "Space"
	icon = 'areas.dmi'
	icon_state = "unknown"
	layer = 10
	mouse_opacity = 0
	var/lightswitch = 1

	var/area_lights_luminosity = 9	//This gets assigned at area creation. It is used to determine how bright the lights in an area should be. At the time of writing the value that it gets assigned is rand(6,9) - only used for light tubes

	var/eject = null

	var/requires_power = 1
	var/always_unpowered = 0	//this gets overriden to 1 for space in area/New()

	var/power_equip = 1
	var/power_light = 1
	var/power_environ = 1
	var/music = null
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0

	var/has_gravity = 1

	var/no_air = null
	var/area/master				// master area used for power calcluations
								// (original area before splitting due to sd_DAL)
	var/list/related			// the other areas of the same type as this
	var/list/lights				// list of all lights on this area

	var/list/all_doors = list()		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area
	var/air_doors_activated

/*Adding a wizard area teleport list because motherfucking lag -- Urist*/
/*I am far too lazy to make it a proper list of areas so I'll just make it run the usual telepot routine at the start of the game*/
var/list/teleportlocs = list()

proc/process_teleport_locs()
	for(var/area/AR in world)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station) || istype(AR, /area/wizard_station)) continue
		if(teleportlocs.Find(AR.name)) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == 1)
			teleportlocs += AR.name
			teleportlocs[AR.name] = AR

	var/not_in_order = 0
	do
		not_in_order = 0
		if(teleportlocs.len <= 1)
			break
		for(var/i = 1, i <= (teleportlocs.len - 1), i++)
			if(sorttext(teleportlocs[i], teleportlocs[i+1]) == -1)
				teleportlocs.Swap(i, i+1)
				not_in_order = 1
	while(not_in_order)

var/list/ghostteleportlocs = list()

proc/process_ghost_teleport_locs()
	for(var/area/AR in world)
		if(ghostteleportlocs.Find(AR.name)) continue
		if(istype(AR, /area/turret_protected/aisat) || istype(AR, /area/derelict) || istype(AR, /area/tdome))
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == 1 || picked.z == 5 || picked.z == 3)
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR

	var/not_in_order = 0
	do
		not_in_order = 0
		if(ghostteleportlocs.len <= 1)
			break
		for(var/i = 1, i <= (ghostteleportlocs.len - 1), i++)
			if(sorttext(ghostteleportlocs[i], ghostteleportlocs[i+1]) == -1)
				ghostteleportlocs.Swap(i, i+1)
				not_in_order = 1
	while(not_in_order)


/*-----------------------------------------------------------------------------*/

/area/engine/

/area/turret_protected/

/area/arrival
	requires_power = 0

/area/arrival/start
	name = "\improper Arrival Area"
	icon_state = "start"

/area/admin
	name = "\improper Admin room"
	icon_state = "start"



//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle //DO NOT TURN THE ul_Lighting STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	requires_power = 0

/area/shuttle/arrival
	name = "\improper Arrival Shuttle"

/area/shuttle/arrival/pre_game
	icon_state = "shuttle2"

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/escape
	name = "\improper Emergency Shuttle"
	music = "music/escape.ogg"

/area/shuttle/escape/station
	name = "\improper Emergency Shuttle Station"
	icon_state = "shuttle2"

/area/shuttle/escape/centcom
	name = "\improper Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/escape/transit // the area to pass through for 3 minute transit
	name = "\improper Emergency Shuttle Transit"
	icon_state = "shuttle"

/area/shuttle/escape_pod1
	name = "\improper Escape Pod One"
	music = "music/escape.ogg"

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod2
	name = "\improper Escape Pod Two"
	music = "music/escape.ogg"

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod3
	name = "\improper Escape Pod Three"
	music = "music/escape.ogg"

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
	name = "\improper Escape Pod Five"
	music = "music/escape.ogg"

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"

/area/shuttle/mining
	name = "\improper Mining Shuttle"
	music = "music/escape.ogg"

/area/shuttle/mining/station
	icon_state = "shuttle2"

/area/shuttle/mining/outpost
	icon_state = "shuttle"

/area/shuttle/transport1/centcom
	icon_state = "shuttle"
	name = "\improper Transport Shuttle Centcom"

/area/shuttle/transport1/station
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"

/area/shuttle/transport2/centcom
	icon_state = "shuttle"

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Base"
	requires_power = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Mine"
	requires_power = 1

/area/shuttle/prison/
	name = "\improper Prison Shuttle"

/area/shuttle/prison/station
	icon_state = "shuttle"

/area/shuttle/prison/prison
	icon_state = "shuttle2"

/area/shuttle/specops/centcom
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite/mothership
	name = "\improper Syndicate Elite Shuttle"
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "\improper Syndicate Elite Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/administration/centcom
	name = "\improper Administration Shuttle Centcom"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "\improper Administration Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "honk"

/area/shuttle/thunderdome/grnshuttle
	name = "\improper Thunderdome GRN Shuttle"
	icon_state = "green"

/area/shuttle/thunderdome/grnshuttle/dome
	name = "\improper GRN Shuttle"
	icon_state = "shuttlegrn"

/area/shuttle/thunderdome/grnshuttle/station
	name = "\improper GRN Station"
	icon_state = "shuttlegrn2"

/area/shuttle/thunderdome/redshuttle
	name = "\improper Thunderdome RED Shuttle"
	icon_state = "red"

/area/shuttle/thunderdome/redshuttle/dome
	name = "\improper RED Shuttle"
	icon_state = "shuttlered"

/area/shuttle/thunderdome/redshuttle/station
	name = "\improper RED Station"
	icon_state = "shuttlered2"
// === Trying to remove these areas:

/area/airtunnel1/      // referenced in airtunnel.dm:759

/area/dummy/           // Referenced in engine.dm:261

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = 0
	luminosity = 1
	ul_Lighting = 0
	has_gravity = 1

// === end remove

/area/alien
	name = "\improper Alien base"
	icon_state = "yellow"
	requires_power = 0

// CENTCOM

/area/centcom
	name = "\improper Centcom"
	icon_state = "centcom"
	requires_power = 0

/area/centcom/control
	name = "\improper Centcom Control"

/area/centcom/evac
	name = "\improper Centcom Emergency Shuttle"

/area/centcom/suppy
	name = "\improper Centcom Supply Shuttle"

/area/centcom/ferry
	name = "\improper Centcom Transport Shuttle"

/area/centcom/shuttle
	name = "\improper Centcom Administration Shuttle"

/area/centcom/test
	name = "\improper Centcom Testing Facility"

/area/centcom/living
	name = "\improper Centcom Living Quarters"

/area/centcom/specops
	name = "\improper Centcom Special Ops"

/area/centcom/creed
	name = "Creed's Office"

/area/centcom/holding
	name = "\improper Holding Facility"

//SYNDICATES

/area/syndicate_mothership
	name = "\improper Syndicate Mothership"
	icon_state = "syndie-ship"
	requires_power = 0

/area/syndicate_mothership/control
	name = "\improper Syndicate Control Room"
	icon_state = "syndie-control"

/area/syndicate_mothership/elite_squad
	name = "\improper Syndicate Elite Squad"
	icon_state = "syndie-elite"

//EXTRA

/area/asteroid					// -- TLE
	name = "\improper Asteroid"
	icon_state = "asteroid"
	requires_power = 0

/area/asteroid/cave				// -- TLE
	name = "\improper Asteroid - Underground"
	icon_state = "cave"
	requires_power = 0

/area/asteroid/artifactroom
	name = "\improper Asteroid - Artifact"
	icon_state = "cave"















/area/planet/clown
	name = "\improper Clown Planet"
	icon_state = "honk"
	requires_power = 0

/area/tdome
	name = "\improper Thunderdome"
	icon_state = "thunder"
	requires_power = 0

/area/tdome/tdome1
	name = "\improper Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "\improper Thunderdome (Team 2)"
	icon_state = "yellow"

/area/tdome/tdomeadmin
	name = "\improper Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "\improper Thunderdome (Observer.)"
	icon_state = "purple"

//ENEMY

/area/syndicate_station
	name = "\improper Syndicate Station"
	icon_state = "yellow"
	requires_power = 0

/area/syndicate_station/start
	name = "\improper Syndicate Station Start"
	icon_state = "yellow"

/area/syndicate_station/one
	name = "\improper Syndicate Station Location 1"
	icon_state = "green"

/area/syndicate_station/two
	name = "\improper Syndicate Station Location 2"
	icon_state = "green"

/area/syndicate_station/three
	name = "\improper Syndicate Station Location 3"
	icon_state = "green"

/area/syndicate_station/four
	name = "\improper Syndicate Station Location 4"
	icon_state = "green"

/area/syndicate_station/five
	name = "\improper Syndicate Station Location 5"
	icon_state = "green"

/area/syndicate_station/six
	name = "\improper Syndicate Station Location 6"
	icon_state = "green"

/area/wizard_station
	name = "\improper Wizard's Den"
	icon_state = "yellow"
	requires_power = 0



/area/borg_deathsquad
	name = "\improper Borg Deathsquad"
	icon_state = "yellow"
	requires_power = 0

/area/borg_deathsquad/start
	name = "\improper Borg Deathsquad - Ready"


/area/borg_deathsquad/station
	name = "\improper Borg Deathsquad - Arrived"








//PRISON
/area/prison
	name = "\improper Prison Station"
	icon_state = "brig"

/area/prison/arrival_airlock
	name = "\improper Prison Station Airlock"
	icon_state = "green"
	requires_power = 0

/area/prison/control
	name = "\improper Prison Security Checkpoint"
	icon_state = "security"

/area/prison/crew_quarters
	name = "\improper Prison Security Quarters"
	icon_state = "security"

/area/prison/rec_room
	name = "\improper Prison Rec Room"
	icon_state = "green"

/area/prison/closet
	name = "\improper Prison Supply Closet"
	icon_state = "dk_yellow"

/area/prison/hallway/fore
	name = "\improper Prison Fore Hallway"
	icon_state = "yellow"

/area/prison/hallway/aft
	name = "\improper Prison Aft Hallway"
	icon_state = "yellow"

/area/prison/hallway/port
	name = "\improper Prison Port Hallway"
	icon_state = "yellow"

/area/prison/hallway/starboard
	name = "\improper Prison Starboard Hallway"
	icon_state = "yellow"

/area/prison/morgue
	name = "\improper Prison Morgue"
	icon_state = "morgue"

/area/prison/medical_research
	name = "\improper Prison Genetic Research"
	icon_state = "medresearch"

/area/prison/medical
	name = "\improper Prison Medbay"
	icon_state = "medbay"

/area/prison/solar
	name = "\improper Prison Solar Array"
	icon_state = "storage"
	requires_power = 0

/area/prison/podbay
	name = "\improper Prison Podbay"
	icon_state = "dk_yellow"

/area/prison/solar_control
	name = "\improper Prison Solar Array Control"
	icon_state = "dk_yellow"

/area/prison/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

/area/prison/cell_block/A
	name = "Prison Cell Block A"
	icon_state = "brig"

/area/prison/cell_block/B
	name = "Prison Cell Block B"
	icon_state = "brig"

/area/prison/cell_block/C
	name = "Prison Cell Block C"
	icon_state = "brig"

//STATION13

/area/atmos
 	name = "Atmospherics"
 	icon_state = "atmos"

/area/atmos/refilling
 	name = "\improper Refilling Station"
 	icon_state = "atmos"

//Maintenance

/area/maintenance/atmos_control
	name = "Atmospherics Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint
	name = "Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint2
	name = "Secondary Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fsmaint
	name = "Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/maintenance/asmaint
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint2
	name = "Secondary Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/apmaint
	name = "Aft Port Maintenance"
	icon_state = "apmaint"

/area/maintenance/maintcentral
	name = "Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/port
	name = "Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/storage
	name = "Atmospherics"
	icon_state = "green"

/area/maintenance/incinerator
	name = "\improper Incinerator"
	icon_state = "disposal"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

//Hallway

/area/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/central
	name = "\improper Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/construction
	name = "\improper Construction Area"
	icon_state = "construction"

/area/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/secondary/docking
	name = "\improper Docking Arm"
	icon_state = "entry"

//Command

/area/bridge
	name = "\improper Bridge"
	icon_state = "bridge"
	music = "signal"

/area/bridge/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "bridge"
	music = null

/area/crew_quarters/captain
	name = "\improper Captain's Quarters"
	icon_state = "captain"

/area/crew_quarters/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"

/area/crew_quarters/heads/hop
	name = "\improper Head of Personnel's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hor
	name = "\improper Research Director's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/chief
	name = "\improper Chief Engineer's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hos
	name = "\improper Head of Security's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/cmo
	name = "\improper Chief Medical Officer's Quarters"
	icon_state = "head_quarters"

/area/mint
	name = "\improper Mint"
	icon_state = "green"

//Crew

/area/crew_quarters
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep_male
	name = "\improper Male Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_male/toilet_male
	name = "\improper Male Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep_female
	name = "\improper Female Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_female/toilet_female
	name = "\improper Female Toilets"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/crew_quarters/locker/locker_toilet
	name = "\improper Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/cafeteria
	name = "\improper Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/bar
	name = "\improper Bar"
	icon_state = "bar"

/area/crew_quarters/theatre
	name = "\improper Theatre"
	icon_state = "Theatre"

/area/library
 	name = "\improper Library"
 	icon_state = "library"

/area/chapel/main
	name = "\improper Chapel"
	icon_state = "chapel"

/area/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/lawoffice
	name = "\improper Law Office"
	icon_state = "law"







/area/holodeck
	name = "\improper Holodeck"
	icon_state = "Holodeck"

/area/holodeck/alphadeck
	name = "\improper Holodeck Alpha"


/area/holodeck/source_plating
	name = "\improper Holodeck - Off"
	icon_state = "Holodeck"

/area/holodeck/source_emptycourt
	name = "\improper Holodeck - Empty Court"

/area/holodeck/source_boxingcourt
	name = "\improper Holodeck - Boxing Court"

/area/holodeck/source_thunderdomecourt
	name = "\improper Holodeck - Thunderdome Court"

/area/holodeck/source_beach
	name = "\improper Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.

/area/holodeck/source_burntest
	name = "\improper Holodeck - Atmospheric Burn Test"

/area/holodeck/source_wildlife
	name = "\improper Holodeck - Wildlife Simulation"











//Engineering

/area/engine
	engine_smes
		name = "\improper Engineering SMES"
		icon_state = "engine_smes"
		requires_power = 0//This area only covers the batteries and they deal with their own power

	engineering
		name = "Engineering"
		icon_state = "engine"

	engineering_break_room
		name = "\improper Engineering Break Room"
		icon_state = "engine_breakroom"

	chiefs_office
		name = "\improper Chief Engineer's office"
		icon_state = "engine_ce"

	particle_accelerator
		name = "\improper Particle Accelerator"
		icon_state = "engine_pa"

	control
		name = "\improper Engineering Control"
		icon_state = "engine_control"

	port
		name = "Engineering Port"
		icon_state = "engine_port"

	starboard
		name = "Engineering Starboard"
		icon_state = "engine_starboard"

	fore
		name = "Engineering Fore"
		icon_state = "engine_fore"

	aft
		name = "Engineering Aft"
		icon_state = "engine_aft"

	locker
		name = "\improper Engineering Locker Room"
		icon_state = "engine_locker"

	construction_storage
		name = "Engineering Construction Storage"
		icon_state = "engine_construction"

	atmos_storage
		name = "Engineering Atmos Storage"
		icon_state = "engine_atmos"

	electrical_storage
		name = "Engineering Electrical Storage"
		icon_state = "engine_electrical"

	secure_storage
		name = "Engineering Secure Storage"
		icon_state = "engine_secure"

	foyer
		name = "\improper Engineering Foyer"
		icon_state = "engine_foyer"

	core
		name = "\improper Engineering Core"
		icon_state = "engine_core"

//reactor areas

	reactor_core
		name = "\improper Reactor Core"
		icon_state = "engine_core"

	reactor_gas
		name = "Reactor Gas Storage"
		icon_state = "engine_atmos"

	aux_control
		name = "Reactor Auxiliary Control"
		icon_state = "engine_aux"

	turbine_control
		name = "Turbine Control"
		icon_state = "engine_turbine"

	reactor_airlock
		name = "\improper Reactor Primary Entrance"
		icon_state = "engine_airlock"

	reactor_fuel_storage
		name = "Reactor Fuel Storage"
		icon_state = "engine_fuel"

	reactor_fuel_ports
		name = "\improper Reactor Fuel Ports"
		icon_state = "engine_port"

	generators
		name = "\improper Generator Room"
		icon_state = "engine_generators"

	port_gyro_bay
		name = "\improper Port Gyrotron Bay"
		icon_state = "engine_starboardgyro"

	starboard_gyro_bay
		name = "\improper Starboard Gyrotron Bay"
		icon_state = "engine_portgyro"

//Solars

/area/solar
	requires_power = 0

	auxport
		name = "\improper Port Auxiliary Solar Array"
		icon_state = "panelsA"

	auxstarboard
		name = "\improper Starboard Auxiliary Solar Array"
		icon_state = "panelsA"

	fore
		name = "\improper Fore Solar Array"
		icon_state = "yellow"

	aft
		name = "\improper Aft Solar Array"
		icon_state = "aft"

	starboard
		name = "\improper Starboard Solar Array"
		icon_state = "panelsS"

	port
		name = "\improper Port Solar Array"
		icon_state = "panelsP"

/area/maintenance/auxsolarport
	name = "Port Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/starboardsolar
	name = "Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/portsolar
	name = "Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/auxsolarstarboard
	name = "Starboard Auxiliary Solar Maintenance"
	icon_state = "SolarcontrolA"


/area/assembly/chargebay
	name = "\improper Recharging Bay"
	icon_state = "mechbay"

/area/assembly/showroom
	name = "\improper Robotics Showroom"
	icon_state = "showroom"

/area/assembly/assembly_line
	name = "\improper Robotics Assembly Line"
	icon_state = "ass_line"

//Teleporter

/area/teleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"
	music = "signal"

/area/teleporter/gateway
	name = "\improper Secure Construction Area"
	icon_state = "teleporter"
	music = "signal"

/area/AIsattele
	name = "\improper AI Satellite Teleporter Room"
	icon_state = "teleporter"
	music = "signal"

//MedBay

/area/medical/medbay
	name = "Medbay"
	icon_state = "medbay"
	music = 'signal.ogg'

/area/medical/patients_rooms
	name = "\improper Patient's Rooms"
	icon_state = "patients"

/area/medical/cmo
	name = "\improper Chief Medical Officer's office"
	icon_state = "CMO"

/area/medical/robotics
	name = "Robotics"
	icon_state = "medresearch"

/area/medical/research
	name = "Medical Research"
	icon_state = "medresearch"

/area/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"

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
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Genetics"
	icon_state = "genetics"

/area/medical/sleeper
	name = "\improper Medical Sleepers Room"
	icon_state = "medbay"

//Security

/area/security/main
	name = "\improper Security Office"
	icon_state = "security"

/area/security/lobby
	name = "\improper Security Lobby"
	icon_state = "security"

/area/security/brig
	name = "\improper Brig"
	icon_state = "brig"

/area/security/prison
	name = "\improper Prison Wing"
	icon_state = "security"

/area/security/warden
	name = "\improper Warden"
	icon_state = "Warden"

/area/security/armoury
	name = "\improper Armoury"
	icon_state = "Warden"

/area/security/hos
	name = "\improper Head of Security's Office"
	icon_state = "security"

/area/security/detectives_office
	name = "\improper Detective's Office"
	icon_state = "detective"

/area/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"

/*
	New()
		..()

		spawn(10) //let objects set up first
			for(var/turf/turfToGrayscale in src)
				if(turfToGrayscale.icon)
					var/icon/newIcon = icon(turfToGrayscale.icon)
					newIcon.GrayScale()
					turfToGrayscale.icon = newIcon
				for(var/obj/objectToGrayscale in turfToGrayscale) //1 level deep, means tables, apcs, locker, etc, but not locker contents
					if(objectToGrayscale.icon)
						var/icon/newIcon = icon(objectToGrayscale.icon)
						newIcon.GrayScale()
						objectToGrayscale.icon = newIcon
*/

/area/security/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"

/area/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint2
	name = "\improper Security Checkpoint"
	icon_state = "security"

/area/security/vacantoffice
	name = "\improper Vacant Office"
	icon_state = "security"

/area/quartermaster
	name = "\improper Quartermasters"
	icon_state = "quart"

///////////WORK IN PROGRESS//////////

/area/quartermaster/sorting
	name = "\improper Delivery Office"
	icon_state = "quartstorage"

////////////WORK IN PROGRESS//////////

/area/quartermaster/office
	name = "\improper Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "\improper Cargo Bay"
	icon_state = "quartstorage"

/area/quartermaster/qm
	name = "\improper Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningstorage
	name = "\improper Mining Storage"
	icon_state = "green"

/area/quartermaster/mechbay
	name = "\improper Mech Bay"
	icon_state = "yellow"

/area/janitor/
	name = "\improper Custodial Closet"
	icon_state = "janitor"

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

//Toxins

/area/toxins/hallway
	name = "\improper R&D Hallway"
	icon_state = "hallC"

/area/toxins/lab
	name = "\improper Research Lab"
	icon_state = "researchlab"

/area/toxins/rdoffice
	name = "\improper Research Director's Office"
	icon_state = "head_quarters"

/area/toxins/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xenolab"

/area/toxins/gasstorage
	name = "R&D Gas Storage"
	icon_state = "gasstorage"

/area/toxins/toxinslab
	name = "\improper Toxins Lab"
	icon_state = "toxlab"

/area/toxins/storage
	name = "\improper Toxins Storage"
	icon_state = "toxstorage"

/area/toxins/test_area
	name = "\improper Toxins Test Area"
	icon_state = "toxtest"

/area/toxins/mixing
	name = "\improper Toxins Mixing Room"
	icon_state = "toxmix"

/area/toxins/observatory
	name = "\improper Toxins Lab Observatory"
	icon_state = "toxobserv"

/area/toxins/server
	name = "\improper Server Room"
	icon_state = "server"

/area/toxins/supermatter
	name = "\improper Supermatter Laboratory"
	icon_state = "supermatter"

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

/area/storage/auxillary
	name = "Auxillary Storage"
	icon_state = "auxstorage"

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/storage/testroom
	requires_power = 0
	name = "\improper Test Room"
	icon_state = "storage"

//DJSTATION

/area/djstation
	name = "\improper Ruskie DJ Station"
	icon_state = "DJ"

/area/djstation/solars
	name = "\improper DJ Station Solars"
	icon_state = "DJ"

//DERELICT

/area/derelict
	name = "\improper Derelict Station"
	icon_state = "storage"

/area/derelict/hallway/primary
	name = "\improper Derelict Primary Hallway"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "\improper Derelict Secondary Hallway"
	icon_state = "hallS"

/area/derelict/arrival
	name = "\improper Derelict Arrival Centre"
	icon_state = "yellow"

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/derelict/bridge
	name = "\improper Derelict Control Room"
	icon_state = "bridge"

/area/derelict/secret
	name = "\improper Derelict Secret Room"
	icon_state = "library"

/area/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "\improper Derelict Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "\improper Derelict Solar Control"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "\improper Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "\improper Derelict Morgue"
	icon_state = "morgue"

/area/derelict/medical/chapel
	name = "\improper Derelict Chapel"
	icon_state = "chapel"

/area/derelict/teleporter
	name = "\improper Derelict Teleporter"
	icon_state = "teleporter"

/area/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"

/area/derelict/ship
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "\improper Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "\improper Derelict Aft Solar Array"
	icon_state = "aft"

/area/derelict/singularity_engine
	name = "\improper Derelict Singularity Engine"
	icon_state = "engine"

//Construction

/area/construction
	name = "\improper Construction Area"
	icon_state = "yellow"

/area/construction/under_construction_small
	name = "\improper Construction Area"
	icon_state = "construction"

/area/construction/under_construction_large
	name = "\improper Construction Area"
	icon_state = "construction"

/area/construction/supplyshuttle
	name = "\improper Supply Shuttle"
	icon_state = "yellow"

/area/construction/quarters
	name = "\improper Engineer's Quarters"
	icon_state = "yellow"

/area/construction/qmaint
	name = "Maintenance"
	icon_state = "yellow"

/area/construction/hallway
	name = "\improper Hallway"
	icon_state = "yellow"

/area/construction/solars
	name = "\improper Solar Panels"
	icon_state = "yellow"

/area/construction/solarscontrol
	name = "\improper Solar Panel Control"
	icon_state = "yellow"

/area/construction/Storage
	name = "Construction Site Storage"
	icon_state = "yellow"

//AI

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"

/area/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"

/area/turret_protected/ai_upload_foyer
	name = "\improper AI Upload Foyer"
	icon_state = "ai_foyer"

/area/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"

/area/turret_protected/aisat
	name = "\improper AI Satellite"
	icon_state = "ai"

/area/turret_protected/aisat_interior
	name = "\improper AI Satellite"
	icon_state = "ai"

/area/turret_protected/AIsatextFP
	name = "\improper AI Sat Ext"
	icon_state = "storage"

/area/turret_protected/AIsatextFS
	name = "\improper AI Sat Ext"
	icon_state = "storage"

/area/turret_protected/AIsatextAS
	name = "\improper AI Sat Ext"
	icon_state = "storage"

/area/turret_protected/AIsatextAP
	name = "\improper AI Sat Ext"
	icon_state = "storage"

/area/turret_protected/NewAIMain
	name = "\improper AI Main New"
	icon_state = "storage"



//Misc



/area/wreck/ai
	name = "\improper AI Chamber"
	icon_state = "ai"

/area/wreck/main
	name = "\improper Wreck"
	icon_state = "storage"

/area/wreck/engineering
	name = "\improper Power Room"
	icon_state = "engine"

/area/wreck/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/generic
	name = "Unknown"
	icon_state = "storage"



// Telecommunications Satellite

/area/tcommsat/entrance
	name = "\improper Telecommunications Satellite Teleporter"
	icon_state = "tcomsatentrance"

/area/tcommsat/chamber
	name = "\improper Telecommunications Satellite Central Compartment"
	icon_state = "tcomsatcham"

/area/turret_protected/tcomfoyer
	name = "\improper Telecommunications Satellite Foyer"
	icon_state = "tcomsatlob"

/area/turret_protected/tcomwest
	name = "\improper Telecommunications Satellite West Wing"
	icon_state = "tcomsatwest"

/area/turret_protected/tcomeast
	name = "\improper Telecommunications Satellite East Wing"
	icon_state = "tcomsateast"

/area/tcommsat/computer
	name = "\improper Telecommunications Satellite Observatory"
	icon_state = "tcomsatcomp"

/area/tcommsat/lounge
	name = "\improper Telecommunications Satellite Lounge"
	icon_state = "tcomsatlounge"












/area/turret_protected/AssistantRoom
	name = "\improper Assistant Room"
	icon_state = "storage"
	ul_Lighting = 0

/////////////////////////////////////////////////////////////////////
/*
 Lists of areas to be used with is_type_in_list.
 Used in gamemodes code at the moment. --rastaf0
*/

// CENTCOM
var/list/centcom_areas = list (
	/area/centcom,
	/area/shuttle/escape/centcom,
	/area/shuttle/escape_pod1/centcom,
	/area/shuttle/escape_pod2/centcom,
	/area/shuttle/escape_pod3/centcom,
	/area/shuttle/escape_pod5/centcom,
	/area/shuttle/transport1/centcom,
	/area/shuttle/transport2/centcom,
	/area/shuttle/administration/centcom,
	/area/shuttle/specops/centcom,
)

//SPACE STATION 13
var/list/the_station_areas = list (
	/area/shuttle/arrival,
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/mining/station,
	/area/shuttle/transport1/station,
	// /area/shuttle/transport2/station,
	/area/shuttle/prison/station,
	/area/shuttle/administration/station,
	/area/shuttle/specops/station,
	/area/atmos,
	/area/maintenance,
	/area/hallway,
	/area/bridge,
	/area/crew_quarters,
	/area/holodeck,
	/area/mint,
	/area/library,
	/area/chapel,
	/area/lawoffice,
	/area/engine,
	/area/solar,
	/area/assembly,
	/area/teleporter,
	/area/medical,
	/area/security,
	/area/quartermaster,
	/area/janitor,
	/area/hydroponics,
	/area/toxins,
	/area/storage,
	/area/construction,
	/area/ai_monitored/storage/eva, //do not try to simplify to "/area/ai_monitored" --rastaf0
	/area/ai_monitored/storage/secure,
	/area/ai_monitored/storage/emergency,
	/area/turret_protected/ai_upload, //do not try to simplify to "/area/turret_protected" --rastaf0
	/area/turret_protected/ai_upload_foyer,
	/area/turret_protected/ai,
)




/area/beach
	name = "Keelin's private beach"
	icon_state = "null"
	luminosity = 1
	ul_Lighting = 0
	requires_power = 0
	var/sound/mysound = null

	New()
		..()
		var/sound/S = new/sound()
		mysound = S
		S.file = 'shore.ogg'
		S.repeat = 1
		S.wait = 0
		S.channel = 123
		S.volume = 100
		S.priority = 255
		S.status = SOUND_UPDATE
//		process()

	Entered(atom/movable/Obj,atom/OldLoc)
		if(ismob(Obj))
			if(Obj:client)
				mysound.status = SOUND_UPDATE
				Obj << mysound
		return

	Exited(atom/movable/Obj)
		if(ismob(Obj))
			if(Obj:client)
				mysound.status = SOUND_PAUSED | SOUND_UPDATE
				Obj << mysound

/*	proc/process()
		set background = 1

		var/sound/S = null
		var/sound_delay = 0
		if(prob(25))
			S = sound(file=pick('seag1.ogg','seag2.ogg','seag3.ogg'), volume=100)
			sound_delay = rand(0, 50)

		for(var/mob/living/carbon/human/H in src)
			if(H.s_tone > -55)
				H.s_tone--
				H.update_body()
			if(H.client)
				mysound.status = SOUND_UPDATE
				H << mysound
				if(S)
					spawn(sound_delay)
						H << S

		spawn(60) .() */