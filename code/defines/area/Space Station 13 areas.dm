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
	name = "Arrival Area"
	icon_state = "start"

/area/admin
	name = "Admin room"
	icon_state = "start"



//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle //DO NOT TURN THE SD_LIGHTING STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	requires_power = 0
	luminosity = 1
	sd_lighting = 0

/area/shuttle/arrival
	name = "Arrival Shuttle"

/area/shuttle/arrival/pre_game
	icon_state = "shuttle2"

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/escape
	name = "Emergency Shuttle"
	music = "music/escape.ogg"

/area/shuttle/escape/station
	icon_state = "shuttle2"

/area/shuttle/escape/centcom
	icon_state = "shuttle"

/area/shuttle/escape/transit // the area to pass through for 3 minute transit
	icon_state = "shuttle"

/area/shuttle/escape_pod1
	name = "Escape Pod One"
	music = "music/escape.ogg"

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod2
	name = "Escape Pod Two"
	music = "music/escape.ogg"

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod3
	name = "Escape Pod Three"
	music = "music/escape.ogg"

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
	name = "Escape Pod Five"
	music = "music/escape.ogg"

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"

/area/shuttle/mining
	name = "Mining Shuttle"
	music = "music/escape.ogg"

/area/shuttle/mining/station
	icon_state = "shuttle2"

/area/shuttle/mining/outpost
	icon_state = "shuttle"

/area/shuttle/transport1/centcom
	icon_state = "shuttle"
	name = "Transport Shuttle Centcom"

/area/shuttle/transport1/station
	icon_state = "shuttle"
	name = "Transport Shuttle"

/area/shuttle/transport2/centcom
	icon_state = "shuttle"

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "Alien Shuttle Base"
	requires_power = 1
	luminosity = 0
	sd_lighting = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "Alien Shuttle Mine"
	requires_power = 1
	luminosity = 0
	sd_lighting = 1

/area/shuttle/prison/
	name = "Prison Shuttle"

/area/shuttle/prison/station
	icon_state = "shuttle"

/area/shuttle/prison/prison
	icon_state = "shuttle2"

/area/shuttle/specops/centcom
	name = "Special Ops Shuttle"
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "Special Ops Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite/mothership
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/administration/centcom
	name = "Administration Shuttle Centcom"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "Administration Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "honk"

/area/shuttle/thunderdome/grnshuttle
	name = "Thunderdome GRN Shuttle"
	icon_state = "green"

/area/shuttle/thunderdome/grnshuttle/dome
	name = "GRN Shuttle"
	icon_state = "shuttlegrn"

/area/shuttle/thunderdome/grnshuttle/station
	name = "GRN Station"
	icon_state = "shuttlegrn2"

/area/shuttle/thunderdome/redshuttle
	name = "Thunderdome RED Shuttle"
	icon_state = "red"

/area/shuttle/thunderdome/redshuttle/dome
	name = "RED Shuttle"
	icon_state = "shuttlered"

/area/shuttle/thunderdome/redshuttle/station
	name = "RED Station"
	icon_state = "shuttlered2"
// === Trying to remove these areas:

/area/airtunnel1/      // referenced in airtunnel.dm:759

/area/dummy/           // Referenced in engine.dm:261

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = 0
	luminosity = 1
	sd_lighting = 0
	has_gravity = 1

// === end remove

/area/alien
	name = "Alien base"
	icon_state = "yellow"
	requires_power = 0

// CENTCOM

/area/centcom
	name = "Centcom"
	icon_state = "centcom"
	requires_power = 0

/area/centcom/control
	name = "Centcom Control"

/area/centcom/evac
	name = "Centcom Emergency Shuttle"

/area/centcom/suppy
	name = "Centcom Supply Shuttle"

/area/centcom/ferry
	name = "Centcom Transport Shuttle"

/area/centcom/shuttle
	name = "Centcom Administration Shuttle"

/area/centcom/test
	name = "Centcom Testing Facility"

/area/centcom/living
	name = "Centcom Living Quarters"

/area/centcom/specops
	name = "Centcom Special Ops"

/area/centcom/creed
	name = "Creed's Office"

/area/centcom/holding
	name = "Holding Facility"

//SYNDICATES

/area/syndicate_mothership
	name = "Syndicate Mothership"
	icon_state = "syndie-ship"
	requires_power = 0

/area/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"

/area/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"

//EXTRA

/area/asteroid					// -- TLE
	name = "Asteroid"
	icon_state = "asteroid"
	requires_power = 0

/area/asteroid/cave				// -- TLE
	name = "Asteroid - Underground"
	icon_state = "cave"
	requires_power = 0

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"















/area/planet/clown
	name = "Clown Planet"
	icon_state = "honk"
	requires_power = 0

/area/tdome
	name = "Thunderdome"
	icon_state = "thunder"
	requires_power = 0

/area/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "yellow"

/area/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "Thunderdome (Observer.)"
	icon_state = "purple"

//ENEMY

/area/syndicate_station
	name = "Syndicate Station"
	icon_state = "yellow"
	requires_power = 0

/area/syndicate_station/start
	name = "Syndicate Station Start"
	icon_state = "yellow"

/area/syndicate_station/one
	name = "Syndicate Station Location 1"
	icon_state = "green"

/area/syndicate_station/two
	name = "Syndicate Station Location 2"
	icon_state = "green"

/area/syndicate_station/three
	name = "Syndicate Station Location 3"
	icon_state = "green"

/area/syndicate_station/four
	name = "Syndicate Station Location 4"
	icon_state = "green"

/area/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	requires_power = 0



/area/borg_deathsquad
	name = "Borg Deathsquad"
	icon_state = "yellow"
	requires_power = 0

/area/borg_deathsquad/start
	name = "Borg Deathsquad - Ready"


/area/borg_deathsquad/station
	name = "Borg Deathsquad - Arrived"








//PRISON
/area/prison
	name = "Brig Prison Wing"
	icon_state = "brig"

/area/prison/arrival_airlock
	name = "Prison Station Airlock"
	icon_state = "green"
	requires_power = 0

/area/prison/control
	name = "Prison Security Checkpoint"
	icon_state = "security"

/area/prison/crew_quarters
	name = "Prison Security Quarters"
	icon_state = "security"

/area/prison/rec_room
	name = "Prison Rec Room"
	icon_state = "green"

/area/prison/closet
	name = "Prison Supply Closet"
	icon_state = "dk_yellow"

/area/prison/hallway/fore
	name = "Prison Fore Hallway"
	icon_state = "yellow"

/area/prison/hallway/aft
	name = "Prison Aft Hallway"
	icon_state = "yellow"

/area/prison/hallway/port
	name = "Prison Port Hallway"
	icon_state = "yellow"

/area/prison/hallway/starboard
	name = "Prison Starboard Hallway"
	icon_state = "yellow"

/area/prison/morgue
	name = "Prison Morgue"
	icon_state = "morgue"

/area/prison/medical_research
	name = "Prison Genetic Research"
	icon_state = "medresearch"

/area/prison/medical
	name = "Prison Medbay"
	icon_state = "medbay"

/area/prison/solar
	name = "Prison Solar Array"
	icon_state = "storage"
	requires_power = 0

/area/prison/podbay
	name = "Prison Podbay"
	icon_state = "dk_yellow"

/area/prison/solar_control
	name = "Prison Solar Array Control"
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
	name = "Incinerator"
	icon_state = "disposal"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

//Hallway

/area/hallway/primary/fore
	name = "Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "Starboard Primary Hallway"
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

/area/hallway/secondary/construction
	name = "Construction Area"
	icon_state = "construction"

/area/hallway/secondary/entry
	name = "Arrival Shuttle Hallway"
	icon_state = "entry"

//Command

/area/bridge
	name = "Bridge"
	icon_state = "bridge"
	music = "signal"

/area/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "bridge"
	music = null

/area/crew_quarters/captain
	name = "Captain's Quarters"
	icon_state = "captain"

/area/crew_quarters/courtroom
	name = "Courtroom"
	icon_state = "courtroom"

/area/crew_quarters/heads
	name = "Head of Personnel's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/hor
	name = "Research Director's Office"
	icon_state = "head_quarters"

/area/crew_quarters/chief
	name = "Chief Engineer's Office"
	icon_state = "head_quarters"

/area/mint
	name = "Mint"
	icon_state = "green"

//Crew

/area/crew_quarters
	name = "Dormitory"
	icon_state = "Sleep"

/area/crew_quarters/toilet
	name = "Dormitory Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep_male
	name = "Male Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_male/toilet_male
	name = "Male Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep_female
	name = "Female Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_female/toilet_female
	name = "Female Toilets"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"

/area/crew_quarters/locker/locker_toilet
	name = "Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/bar
	name = "Bar"
	icon_state = "bar"

/area/crew_quarters/theatre
	name = "Theatre"
	icon_state = "Theatre"

/area/library
 	name = "Library"
 	icon_state = "library"

/area/chapel/main
	name = "Chapel"
	icon_state = "chapel"

/area/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"

/area/lawoffice
	name = "Law Office"
	icon_state = "law"







/area/holodeck
	name = "Holodeck"
	icon_state = "Holodeck"
	luminosity = 1
	sd_lighting = 0

/area/holodeck/alphadeck
	name = "Holodeck Alpha"


/area/holodeck/source_plating
	name = "Holodeck - Off"
	icon_state = "Holodeck"

/area/holodeck/source_emptycourt
	name = "Holodeck - Empty Court"

/area/holodeck/source_boxingcourt
	name = "Holodeck - Boxing Court"

/area/holodeck/source_thunderdomecourt
	name = "Holodeck - Thunderdome Court"

/area/holodeck/source_beach
	name = "Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.

/area/holodeck/source_burntest
	name = "Holodeck - Atmospheric Burn Test"

/area/holodeck/source_wildlife
	name = "Holodeck - Wildlife Simulation"











//Engineering

/area/engine
	engine_smes
		name = "Engineering SMES"
		icon_state = "engine_smes"
		requires_power = 0//This area only covers the batteries and they deal with their own power

	engineering
		name = "Engineering"
		icon_state = "engine"

	chiefs_office
		name = "Chief Engineers office"
		icon_state = "engine_control"


//Solars

/area/solar
	requires_power = 0
	luminosity = 1
	sd_lighting = 0

	auxport
		name = "Port Auxiliary Solar Array"
		icon_state = "panelsA"

	auxstarboard
		name = "Starboard Auxiliary Solar Array"
		icon_state = "panelsA"

	fore
		name = "Fore Solar Array"
		icon_state = "yellow"

	aft
		name = "Aft Solar Array"
		icon_state = "aft"

	starboard
		name = "Starboard Solar Array"
		icon_state = "panelsS"

	port
		name = "Port Solar Array"
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
	name = "Recharging Bay"
	icon_state = "mechbay"

/area/assembly/showroom
	name = "Robotics Showroom"
	icon_state = "showroom"

/area/assembly/assembly_line
	name = "Assembly Line"
	icon_state = "ass_line"

//Teleporter

/area/teleporter
	name = "Teleporter"
	icon_state = "teleporter"
	music = "signal"

/area/AIsattele
	name = "AI Satellite Teleporter Room"
	icon_state = "teleporter"
	music = "signal"

//MedBay

/area/medical/medbay
	name = "Medbay"
	icon_state = "medbay"
	music = 'signal.ogg'

/area/medical/patients_rooms
	name = "Patients Rooms"
	icon_state = "patients"

/area/medical/cmo
	name = "Chief Medical Officer's office"
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
	name = "Morgue"
	icon_state = "morgue"

/area/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/medical/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/medical/cryo
	name = "Cryo"
	icon_state = "cryo"

/area/medical/exam_room
	name = "Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Genetics"
	icon_state = "genetics"

//Security

/area/security/main
	name = "Security Office"
	icon_state = "security"

/area/security/brig
	name = "Brig"
	icon_state = "brig"

/area/security/warden
	name = "Warden"
	icon_state = "Warden"

/area/security/hos
	name = "Head of Security"
	icon_state = "security"

/area/security/detectives_office
	name = "Detectives Office"
	icon_state = "detective"

/area/security/range
	name = "Firing Range"
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
	name = "Vault"
	icon_state = "nuke_storage"

/area/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint2
	name = "Security Checkpoint"
	icon_state = "security"

/area/security/vacantoffice
	name = "Vacant Office"
	icon_state = "security"

/area/quartermaster
	name = "Quartermasters"
	icon_state = "quart"

///////////WORK IN PROGRESS//////////

/area/quartermaster/sorting
	name = "Delivery Office"
	icon_state = "quartstorage"

////////////WORK IN PROGRESS//////////

/area/quartermaster/office
	name = "Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "Cargo Bay"
	icon_state = "quartstorage"

/area/quartermaster/qm
	name = "Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/miningdock
	name = "Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningstorage
	name = "Mining Storage"
	icon_state = "green"

/area/quartermaster/mechbay
	name = "Mech Bay"
	icon_state = "yellow"

/area/janitor/
	name = "Janitors Closet"
	icon_state = "janitor"

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

//Toxins

/area/toxins/lab
	name = "Toxin Lab"
	icon_state = "toxlab"

/area/toxins/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxlab"

/area/toxins/storage
	name = "Toxin Storage"
	icon_state = "toxstorage"

/area/toxins/test_area
	name = "Toxin Test Area"
	icon_state = "toxtest"

/area/toxins/mixing
	name = "Toxin Mixing Room"
	icon_state = "toxmix"

/area/toxins/server
	name = "Server Room"
	icon_state = "server"

//Storage

/area/storage/tools
	name = "Tool Storage"
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
	name = "Emergency Storage A"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Emergency Storage B"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/storage/testroom
	requires_power = 0
	name = "Test Room"
	icon_state = "storage"

//DJSTATION

/area/djstation
	name = "Ruskie DJ Station"
	icon_state = "DJ"

/area/djstation/solars
	name = "DJ Station Solars"
	icon_state = "DJ"

//DERELICT

/area/derelict
	name = "Derelict Station"
	icon_state = "storage"

/area/derelict/hallway/primary
	name = "Derelict Primary Hallway"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "Derelict Secondary Hallway"
	icon_state = "hallS"

/area/derelict/arrival
	name = "Arrival Centre"
	icon_state = "yellow"

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/derelict/bridge
	name = "Control Room"
	icon_state = "bridge"

/area/derelict/secret
	name = "Secret Room"
	icon_state = "library"

/area/derelict/bridge/access
	name = "Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "Ruined Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "Solar Control"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "Derelict Morgue"
	icon_state = "morgue"

/area/derelict/medical/chapel
	name = "Derelict Chapel"
	icon_state = "chapel"

/area/derelict/teleporter
	name = "Derelict Teleporter"
	icon_state = "teleporter"

/area/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"

/area/derelict/ship
	name = "Abandoned ship"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "Derelict Aft Solar Array"
	icon_state = "aft"

/area/derelict/singularity_engine
	name = "Derelict Singularity Engine"
	icon_state = "engine"

//Construction

/area/construction
	name = "Construction Area"
	icon_state = "yellow"

/area/construction/supplyshuttle
	name = "Supply Shuttle"
	icon_state = "yellow"

/area/construction/quarters
	name = "Engineer's Quarters"
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
	name = "AI Upload Chamber"
	icon_state = "ai_upload"

/area/turret_protected/ai_upload_foyer
	name = "AI Upload Foyer"
	icon_state = "ai_foyer"

/area/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"

/area/turret_protected/aisat_interior
	name = "AI Satellite"
	icon_state = "ai"

/area/turret_protected/AIsatextFP
	name = "AI Sat Ext"
	icon_state = "storage"
	luminosity = 1
	sd_lighting = 0

/area/turret_protected/AIsatextFS
	name = "AI Sat Ext"
	icon_state = "storage"
	luminosity = 1
	sd_lighting = 0

/area/turret_protected/AIsatextAS
	name = "AI Sat Ext"
	icon_state = "storage"
	luminosity = 1
	sd_lighting = 0

/area/turret_protected/AIsatextAP
	name = "AI Sat Ext"
	icon_state = "storage"
	luminosity = 1
	sd_lighting = 0

/area/turret_protected/NewAIMain
	name = "AI Main New"
	icon_state = "storage"



//Misc



/area/wreck/ai
	name = "AI Chamber"
	icon_state = "ai"

/area/wreck/main
	name = "Wreck"
	icon_state = "storage"

/area/wreck/engineering
	name = "Power Room"
	icon_state = "engine"

/area/wreck/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/generic
	name = "Unknown"
	icon_state = "storage"



// Telecommunications Satellite

/area/tcommsat/entrance
	name = "Telecommunications Satellite Teleporter"
	icon_state = "tcomsatentrance"

/area/tcommsat/chamber
	name = "Telecommunications Satellite Central Compartment"
	icon_state = "tcomsatcham"

/area/turret_protected/tcomfoyer
	name = "Telecommunications Satellite Foyer"
	icon_state = "tcomsatlob"

/area/turret_protected/tcomwest
	name = "Telecommunications Satellite West Wing"
	icon_state = "tcomsatwest"

/area/turret_protected/tcomeast
	name = "Telecommunications Satellite East Wing"
	icon_state = "tcomsateast"

/area/tcommsat/computer
	name = "Telecommunications Satellite Observatory"
	icon_state = "tcomsatcomp"

/area/tcommsat/lounge
	name = "Telecommunications Satellite Lounge"
	icon_state = "tcomsatlounge"


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
	sd_lighting = 0
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
		process()

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

	proc/process()
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

		spawn(60) .()