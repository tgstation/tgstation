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

#define SUPER_JAMMED 2

/area
	var/fire = null
	var/atmos = 1
	var/atmosalm = 0
	var/poweralm = 1
	var/party = null
	var/radalert = 0
	level = null
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = 10
	mouse_opacity = 0
	invisibility = INVISIBILITY_LIGHTING
	var/lightswitch = 1

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
//	var/list/lights				// list of all lights on this area
	var/list/all_doors = list()		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area

	// /vg/: Bitmap of subsystems asking for firedoors.
	var/door_alerts=0

	var/doors_down=0

	// /vg/: No teleporting for you. 2 = SUPER JAMMED, inaccessible even to telecrystals.
	var/jammed = 0

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

/area/engineering/

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

/area/shuttle //DO NOT TURN THE lighting_use_dynamic STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = 0

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

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Base"
	requires_power = 1
	luminosity = 0
	lighting_use_dynamic = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Mine"
	requires_power = 1
	luminosity = 0
	lighting_use_dynamic = 1

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

/area/shuttle/research
	name = "\improper Research Shuttle"
	music = "music/escape.ogg"

/area/shuttle/research/station
	icon_state = "shuttle2"

/area/shuttle/research/outpost
	icon_state = "shuttle"

/area/shuttle/vox/station
	name = "\improper Vox Skipjack"
	icon_state = "yellow"
	requires_power = 0
	lighting_use_dynamic = 0
	luminosity=1

/area/shuttle/salvage
	name = "\improper Salvage Ship"
	icon_state = "yellow"
	requires_power = 0

/area/shuttle/salvage/start
	name = "\improper Middle of Nowhere"
	icon_state = "yellow"

/area/shuttle/salvage/arrivals
	name = "\improper Space Station Auxiliary Docking"
	icon_state = "yellow"

/area/shuttle/salvage/derelict
	name = "\improper Derelict Station"
	icon_state = "yellow"

/area/shuttle/salvage/djstation
	name = "\improper Ruskie DJ Station"
	icon_state = "yellow"

/area/shuttle/salvage/north
	name = "\improper North of the Station"
	icon_state = "yellow"

/area/shuttle/salvage/east
	name = "\improper East of the Station"
	icon_state = "yellow"

/area/shuttle/salvage/south
	name = "\improper South of the Station"
	icon_state = "yellow"

/area/shuttle/salvage/commssat
	name = "\improper The Communications Satellite"
	icon_state = "yellow"

/area/shuttle/salvage/mining
	name = "\improper South-West of the Mining Asteroid"
	icon_state = "yellow"

/area/shuttle/salvage/abandoned_ship
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/shuttle/salvage/clown_asteroid
	name = "\improper Clown Asteroid"
	icon_state = "yellow"

/area/shuttle/salvage/trading_post
	name = "\improper Trading Post"
	icon_state = "yellow"

/area/shuttle/salvage/transit
	name = "\improper hyperspace"
	icon_state = "shuttle"

// Taxi Shuttle

/area/shuttle/taxi_a
	requires_power = 0

/area/shuttle/taxi_a/medcal_silicon_station
	name = "\improper Medical and Silicon Station"
	icon_state = "bluenew"

/area/shuttle/taxi_a/engineering_cargo_station
	name = "\improper Engineering and Cargo Station"
	icon_state = "bluenew"

/area/shuttle/taxi_a/security_science_station
	name = "\improper Security and Science Station"
	icon_state = "bluenew"

/area/shuttle/taxi_a/abandoned_station
	name = "\improper Abandoned Station"
	icon_state = "bluenew"

/area/shuttle/taxi_a/transit
	name = "\improper hyperspace"
	icon_state = "bluenew"

// B

/area/shuttle/taxi_b
	requires_power = 0

/area/shuttle/taxi_b/medcal_silicon_station
	name = "\improper Medical and Silicon Station"
	icon_state = "dk_yellow"

/area/shuttle/taxi_b/engineering_cargo_station
	name = "\improper Engineering and Cargo Station"
	icon_state = "dk_yellow"

/area/shuttle/taxi_b/security_science_station
	name = "\improper Security and Science Station"
	icon_state = "dk_yellow"

/area/shuttle/taxi_b/abandoned_station
	name = "\improper Abandoned Station"
	icon_state = "dk_yellow"

/area/shuttle/taxi_b/transit
	name = "\improper hyperspace"
	icon_state = "dk_yellow"

// End Taxi Shuttle



/area/airtunnel1/      // referenced in airtunnel.dm:759

/area/dummy/           // Referenced in engine.dm:261

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = 0
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

/area/asteroid/clown
	name = "\improper Clown Roid"
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

//names are used
/area/syndicate_station
	name = "\improper Syndicate Station"
	icon_state = "yellow"
	requires_power = 0

/area/syndicate_station/start
	name = "\improper Syndicate Forward Operating Base"
	icon_state = "yellow"

/area/syndicate_station/southwest
	name = "\improper south-west of SS13"
	icon_state = "southwest"

/area/syndicate_station/northwest
	name = "\improper north-west of SS13"
	icon_state = "northwest"

/area/syndicate_station/northeast
	name = "\improper north-east of SS13"
	icon_state = "northeast"

/area/syndicate_station/southeast
	name = "\improper south-east of SS13"
	icon_state = "southeast"

/area/syndicate_station/north
	name = "\improper north of SS13"
	icon_state = "north"

/area/syndicate_station/south
	name = "\improper south of SS13"
	icon_state = "south"

/area/syndicate_station/commssat
	name = "\improper south of the communication satellite"
	icon_state = "south"

/area/syndicate_station/mining
	name = "\improper north east of the mining asteroid"
	icon_state = "north"

/area/syndicate_station/transit
	name = "\improper hyperspace"
	icon_state = "shuttle"

/area/wizard_station
	name = "\improper Wizard's Den"
	icon_state = "yellow"
	requires_power = 0

/area/vox_station/transit
	name = "\improper hyperspace"
	icon_state = "shuttle"
	requires_power = 0

/area/vox_station/southwest_solars
	name = "\improper aft port solars"
	icon_state = "southwest"
	requires_power = 0

/area/vox_station/northwest_solars
	name = "\improper fore port solars"
	icon_state = "northwest"
	requires_power = 0

/area/vox_station/northeast_solars
	name = "\improper fore starboard solars"
	icon_state = "northeast"
	requires_power = 0

/area/vox_station/southeast_solars
	name = "\improper aft starboard solars"
	icon_state = "southeast"
	requires_power = 0

/area/vox_station/mining
	name = "\improper nearby mining asteroid"
	icon_state = "north"
	requires_power = 0

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

//Maintenance

/area/maintenance/fpmaint
	name = "Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint2
	name = "Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint3
	name = "Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fsmaint
	name = "Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/maintenance/fsmaint2
	name = "Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/maintenance/asmaint
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint2
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint3
	name = "Xenobiology Maintenance"
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

/area/maintenance/atmos
	name = "Atmospherics"
	icon_state = "green"

/area/maintenance/incinerator
	name = "\improper Incinerator"
	icon_state = "disposal"

/area/maintenance/disposal
	name = "Recycling"
	icon_state = "disposal"

/area/maintenance/secdisposal
	name = "Security Disposals"
	icon_state = "secdisp"

/area/maintenance/auxcharge
	name = "Auxiliary Cyborg Recharge"
	icon_state = "auxcharge"

/area/maintenance/ghettobar
	name = "Ghetto Bar"
	icon_state = "ghettobar"

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

//Command

/area/bridge
	name = "\improper Bridge"
	icon_state = "bridge"
	music = "signal"
	jammed=1

/area/bridge/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "bridge"
	music = null
	jammed=0

/area/crew_quarters/captain
	name = "\improper Captain's Office"
	icon_state = "captain"
	jammed=1

/area/crew_quarters/heads
	hop
		name = "\improper Head of Personnel's Quarters"
		icon_state = "head_quarters"
		jammed=1

	rd
		name = "\improper Research Director's Quarters"
		icon_state = "head_quarters"
		jammed=1

	ce
		name = "\improper Chief Engineer's Quarters"
		icon_state = "head_quarters"
		jammed=1

	hos
		name = "\improper Head of Security's Quarters"
		icon_state = "head_quarters"
		jammed=1

	cmo
		name = "\improper Chief Medical Officer's Quarters"
		icon_state = "head_quarters"
		jammed=1

/area/crew_quarters/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"

/area/crew_quarters/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "head_quarters"
	jammed=1

/area/mint
	name = "\improper Mint"
	icon_state = "green"

/area/comms
	name = "\improper Communications Relay"
	icon_state = "tcomsatcham"

/area/server
	name = "\improper Messaging Server Room"
	icon_state = "server"

//Crew

/area/crew_quarters
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep
	name = "\improper Dormitories"
	icon_state = "Sleep"

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
	luminosity = 1
	lighting_use_dynamic = 0

/area/holodeck/alphadeck
	name = "\improper Holodeck Alpha"


/area/holodeck/source_plating
	name = "\improper Holodeck - Off"
	icon_state = "Holodeck"
	jammed=SUPER_JAMMED

/area/holodeck/source_emptycourt
	name = "\improper Holodeck - Empty Court"
	jammed=SUPER_JAMMED

/area/holodeck/source_boxingcourt
	name = "\improper Holodeck - Boxing Court"
	jammed=SUPER_JAMMED

/area/holodeck/source_basketball
	name = "\improper Holodeck - Basketball Court"
	jammed=SUPER_JAMMED

/area/holodeck/source_thunderdomecourt
	name = "\improper Holodeck - Thunderdome Court"
	jammed=SUPER_JAMMED

/area/holodeck/source_beach
	name = "\improper Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.
	jammed=SUPER_JAMMED

/area/holodeck/source_burntest
	name = "\improper Holodeck - Atmospheric Burn Test"
	jammed=SUPER_JAMMED

/area/holodeck/source_wildlife
	name = "\improper Holodeck - Wildlife Simulation"
	jammed=SUPER_JAMMED

/area/holodeck/source_meetinghall
	name = "\improper Holodeck - Meeting Hall"
	jammed=SUPER_JAMMED

/area/holodeck/source_theatre
	name = "\improper Holodeck - Theatre"
	jammed=SUPER_JAMMED

/area/holodeck/source_picnicarea
	name = "\improper Holodeck - Picnic Area"
	jammed=SUPER_JAMMED

/area/holodeck/source_snowfield
	name = "\improper Holodeck - Snow Field"
	jammed=SUPER_JAMMED

/area/holodeck/source_desert
	name = "\improper Holodeck - Desert"
	jammed=SUPER_JAMMED

/area/holodeck/source_space
	name = "\improper Holodeck - Space"
	jammed=SUPER_JAMMED











//Engineering

/area/engineering

/area/engineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"
	requires_power = 0//This area only covers the batteries and they deal with their own power

/area/engineering/engine
	name = "Engineering"
	icon_state = "engine"

/area/engineering/engine_storage
	name = "Engineering Secure Storage"
	icon_state = "engine_storage"

/area/engineering/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engine_lobby"

/area/engineering/ce
	name = "\improper Chief Engineer's Office"
	icon_state = "head_quarters"
	jammed=1

/area/engineering/burn_chamber
	name = "Burn Chamber"
	icon_state = "thermo_engine"

/area/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/engineering/atmos_control
	name = "Atmospherics Monitoring"
	icon_state = "atmos_monitor"

/area/engineering/supermatter_room
	name = "Supermatter Room"
	icon_state = "supermatter"

/area/engineering/antimatter_room
	name = "Antimatter Engine Room"
	icon_state = "antimatter"

/area/engineering/engineering_auxiliary
	name = "Auxiliary Engineering"
	icon_state = "engiaux"

/area/engineering/mechanics
	name = "Mechanics"
	icon_state = "mechanics"


//Solars

/area/solar
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = 0

/area/solar/fport
	name = "\improper Fore Port Solar Array"
	icon_state = "panelsA"

/area/solar/fstarboard
	name = "\improper Fore Starboard Solar Array"
	icon_state = "panelsA"

/area/solar/fore
	name = "\improper Fore Solar Array"
	icon_state = "yellow"

/area/solar/aft
	name = "\improper Aft Solar Array"
	icon_state = "aft"

/area/solar/astarboard
	name = "\improper Aft Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/auxstarboard
	name = "\improper Auxillary Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/aport
	name = "\improper Aft Port Solar Array"
	icon_state = "panelsP"

/area/solar/auxport
	name = "\improper Auxillary Port Solar Array"
	icon_state = "panelsP"

/area/maintenance/auxsolarstarboard
	name = "Auxillary Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/auxsolarport
	name = "Auxillary Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/fportsolar
	name = "Fore Port Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/astarboardsolar
	name = "Aft Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/aportsolar
	name = "Aft Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/fstarboardsolar
	name = "Fore Starboard Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/virology_maint
	name = "Virology Maintenance"
	icon_state = "asmaint"

/area/assembly/showroom
	name = "\improper Robotics Showroom"
	icon_state = "showroom"

/area/assembly/assembly_line //Derelict Assembly Line
	name = "\improper Assembly Line"
	icon_state = "ass_line"
	power_equip = 0
	power_light = 0
	power_environ = 0

//Teleporter

/area/teleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"
	music = "signal"
	jammed=1

/area/gateway
	name = "\improper Gateway"
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
	music = 'sound/ambience/signal.ogg'

//Medbay is a large area, these additional areas help level out APC load.
/area/medical/medbay2
	name = "Medbay"
	icon_state = "medbay2"
	music = 'sound/ambience/signal.ogg'

/area/medical/surgery_ghetto
	name = "Ghetto Surgery"
	icon_state = "medbay_ghetto"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay3
	name = "Medbay"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/break_room
	name = "Medbay Break Room"
	icon_state = "medbay_break"
	music = 'sound/ambience/signal.ogg'

/area/medical/patients_rooms
	name = "\improper Patient's Rooms"
	icon_state = "patients"

/area/medical/patient_room1
	name = "\improper Patient Room 1"
	icon_state = "patients"

/area/medical/patient_room2
	name = "\improper Patient Room 2"
	icon_state = "patients"

/area/medical/cmo
	name = "\improper Chief Medical Officer's Office"
	icon_state = "CMO"
	jammed=1

/area/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/medical/virology_break
	name = "Virology Break Room"
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

/area/medical/storage
	name = "\improper Medbay Storage"
	icon_state = "med_storage"

/area/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/medical/genetics_cloning
	name = "Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Medbay Treatment Center"
	icon_state = "exam_room"

/area/medical/paramedics
	name = "\improper Paramedic Station"
	icon_state = "paramedics"

//Security

/area/security/main
	name = "\improper Security Office"
	icon_state = "security"

/area/security/lobby
	name = "\improper Security Lobby"
	icon_state = "sec_lobby"

/area/security/brig
	name = "\improper Brig"
	icon_state = "brig"

/area/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"

/area/security/gas_chamber
	name = "\improper Execution Chamber"
	icon_state = "bar" // Because it's all parties from here on.
	jammed=1

/area/security/medical
	name = "\improper Brig Medbay"
	icon_state = "sec_medbay"

/area/security/toilet
	name = "\improper Brig Toilets"
	icon_state = "toilet"

/area/security/rec_room
	name = "\improper Brig Recording Room"
	icon_state = "rec"

/area/security/interrogation
	name = "\improper Interrogation Room"
	icon_state = "interrog"

/area/security/processing
	name = "\improper Prisoner Education Chamber"
	icon_state = "interrog"

/obj/item/weapon/paper/Gaschamber
	name = "paper - 'Gas Chambers for Idiots'"
	info = {"<h4>Gas Chambers for Idiots</h4>
<p>So here you are, with a fancy, new gas chamber thanks to cheap MoMMI labor.  Now you've got a guy you need to die and have no idea what to do.</p>
<ol>
	<li>First, use the computer in the witnessing room to shut off the scrubbers: Set Environmental Mode, Off.</li>
	<li>Run down to the door for the room south of the witnessing room. You'll see a bunch of N2O or CO2 tanks.</li>
	<li>Select the tank you want and drag it onto the connector.  N2O (same shit used in anesthesia tanks in surgery) makes you go sleepy and kills in high enough doses, while CO2 makes people fall over comically and eventually die. CO2 is best because it's easier to tell when Mr. Revpants is dead, and because the room is configured for CO2 executions..</li>
	<li>Make sure everyone you don't want dead is out of the chamber and the door is closed.</li>
	<li>Wrench the tank in and go watch the fun from witnessing.</li>
	<li>Once he's dead, set environmentals to filtering (or Cycle, if you're an idiot and used N2O).</li>
	<li>Run back down to gas control and unwrench the tank.</li>
	<li>Drag the dead bastard out once the computer says it's safe to enter.</li>
</ol>"}

/area/security/warden
	name = "\improper Warden"
	icon_state = "Warden"
	jammed=1

/area/security/armory
	name = "\improper Secure Armory"
	icon_state = "Armory"
	jammed=1

/area/security/hos
	name = "\improper Head of Security's Office"
	icon_state = "sec_hos"
	jammed=1

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

/area/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint2
	name = "\improper Security Checkpoint"
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

/area/security/vacantoffice
	name = "\improper Vacant Office"
	icon_state = "security"

/area/security/vacantoffice2
	name = "\improper Vacant Office"
	icon_state = "security"

/area/supply
	name = "\improper Quartermasters"
	icon_state = "quart"

///////////WORK IN PROGRESS//////////

/area/supply/sorting
	name = "\improper Delivery Office"
	icon_state = "cargo_delivery"

////////////WORK IN PROGRESS//////////

/area/supply/lobby
	name ="\improper Cargo Lobby"
	icon_state = "cargo_lobby"

/area/supply/office
	name = "\improper Cargo Office"
	icon_state = "cargo_office"

/area/supply/storage
	name = "\improper Cargo Bay"
	icon_state = "cargo_bay"

/area/supply/qm
	name = "\improper Quartermaster's Office"
	icon_state = "cargo_quart"
	jammed=1

/area/supply/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining"

/area/supply/miningstorage
	name = "\improper Mining Storage"
	icon_state = "green"

/area/supply/miningdelivery
	name = "\improper Mining Delivery"
	icon_state = "mining_delivery"

/area/supply/mechbay
	name = "\improper Mech Bay"
	icon_state = "yellow"

/area/janitor/
	name = "\improper Custodial Closet"
	icon_state = "janitor"

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

//Toxins

/area/science/lab
	name = "\improper Research and Development"
	icon_state = "toxlab"

/area/science/hallway
	name = "\improper Research Division"
	icon_state = "tox_hall"

/area/science/rd
	name = "\improper Research Director's Office"
	icon_state = "head_quarters"
	jammed=1

/area/science/supermatter
	name = "\improper Supermatter Lab"
	icon_state = "toxlab"

/area/science/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xenobio"

/area/science/xenobiology/specimen_1
	name = "\improper Xenobiology Specimen Cage 1"
	icon_state = "xenocell1"

/area/science/xenobiology/specimen_2
	name = "\improper Xenobiology Specimen Cage 2"
	icon_state = "xenocell2"

/area/science/xenobiology/specimen_3
	name = "\improper Xenobiology Specimen Cage 3"
	icon_state = "xenocell3"

/area/science/xenobiology/specimen_4
	name = "\improper Xenobiology Specimen Cage 4"
	icon_state = "xenocell4"

/area/science/xenobiology/specimen_5
	name = "\improper Xenobiology Specimen Cage 5"
	icon_state = "xenocell5"

/area/science/xenobiology/specimen_6
	name = "\improper Xenobiology Specimen Cage 6"
	icon_state = "xenocell6"

/area/science/robotics
	name = "\improper Robotics Lab"
	icon_state = "ass_line"

/area/science/chargebay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/science/storage
	name = "\improper Toxins Storage"
	icon_state = "toxstorage"

/area/science/test_area
	name = "\improper Toxins Test Area"
	icon_state = "toxtest"

/area/science/shuttlebay
	name = "\improper Research Shuttle Bay"
	icon_state = "toxshuttle"

/area/science/mixing
	name = "\improper Toxins Mixing Room"
	icon_state = "toxmix"

/area/science/telescience
	name = "\improper Telescience"
	icon_state = "toxmisc"

/area/science/podbay
	name = "\improper Pod Bay"
	icon_state = "pod"

/area/science/server
	name = "\improper Server Room"
	icon_state = "server"
	jammed=1

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
	jammed=1

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"
	jammed=1

/area/storage/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"

/area/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"
	jammed=1

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

/area/derelict/atmos
	name = "\improper Derelict Atmospherics"
	icon_state = "atmos"

/area/derelict/research
	name = "\improper Derelict Research"
	icon_state = "toxins"

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

/area/derelict/research
	name = "\improper Derelict Research"
	icon_state = "toxmisc"

//Construction

/area/construction
	name = "\improper Construction Area"
	icon_state = "yellow"

/area/construction/mommi_nest
	name = "\improper MoMMI Nest"
	icon_state = "yellow"

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
	jammed=1

/area/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"

/area/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	jammed=1

/area/turret_protected/ai_upload_foyer
	name = "AI Upload Access"
	icon_state = "ai_foyer"

/area/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	jammed=1

/area/turret_protected/aisat
	name = "\improper AI Satellite"
	icon_state = "ai"

/area/turret_protected/aisat_interior
	name = "\improper AI Satellite"
	icon_state = "ai"

/area/turret_protected/AIsatextFP
	name = "\improper AI Sat Ext"
	icon_state = "storage"
	luminosity = 1
	lighting_use_dynamic = 0

/area/turret_protected/AIsatextFS
	name = "\improper AI Sat Ext"
	icon_state = "storage"
	luminosity = 1
	lighting_use_dynamic = 0

/area/turret_protected/AIsatextAS
	name = "\improper AI Sat Ext"
	icon_state = "storage"
	luminosity = 1
	lighting_use_dynamic = 0

/area/turret_protected/AIsatextAP
	name = "\improper AI Sat Ext"
	icon_state = "storage"
	luminosity = 1
	lighting_use_dynamic = 0

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


//////////////////////////////
// VOX TRADING POST
//////////////////////////////
/area/vox_trading_post/trading_floor
	name = "\improper Vox Trading Floor"
	icon_state = "yellow"

/area/vox_trading_post/trade_processing
	name = "\improper Vox Trade Processing"
	icon_state = "green"

/area/vox_trading_post/armory
	name = "\improper Vox Armory"
	icon_state = "armory"

/area/vox_trading_post/gardens
	name = "\improper Vox Botanical Gardens"
	icon_state = "hydro"

/area/vox_trading_post/atmos
	name = "\improper Vox Atmospherics"
	icon_state = "atmos"

/area/vox_trading_post/eva
	name = "\improper Vox EVA"
	icon_state = "eva"

/area/vox_trading_post/storage_1
	name = "\improper Vox Storage Room"
	icon_state = "storage"

/area/vox_trading_post/vault
	name = "\improper Vox Vault"
	icon_state = "primarystorage"

/area/vox_trading_post/hallway
	name = "\improper Vox Hallways"
	icon_state = "hallP"



// Telecommunications Satellite

/area/tcommsat/entrance
	name = "\improper Satellite Teleporter"
	icon_state = "tcomsatentrance"

/area/tcommsat/chamber
	name = "\improper Telecoms Central Compartment"
	icon_state = "tcomsatcham"

/area/tcomms/chamber
	name = "\improper Telecoms Chamber"
	icon_state = "ai"

/area/tcomms/storage
	name = "\improper Telecoms Storage"
	icon_state = "primarystorage"

/area/turret_protected/tcomms_control_room
	name = "\improper Telecomms Control Room"
	icon_state = "tcomsatcomp"
	jammed=1

/area/turret_protected/tcomsat
	name = "\improper Satellite Entrance"
	icon_state = "tcomsatlob"

/area/turret_protected/tcomfoyer
	name = "\improper Telecoms Foyer"
	icon_state = "tcomsatentrance"

/area/turret_protected/tcomwest
	name = "\improper Telecommunications Satellite West Wing"
	icon_state = "tcomsatwest"

/area/turret_protected/tcomeast
	name = "\improper Telecommunications Satellite East Wing"
	icon_state = "tcomsateast"

/area/tcommsat/computer
	name = "\improper Satellite Control Room"
	icon_state = "tcomsatcomp"

/area/tcommsat/lounge
	name = "\improper Satellite Lounge"
	icon_state = "tcomsatlounge"

/area/turret_protected/goonroom
	name = "\improper Goonecode Containment"
	icon_state = "ai_upload"
	jammed=2



// Away Missions
/area/awaymission
	name = "\improper Strange Location"
	icon_state = "away"

/area/awaymission/example
	name = "\improper Strange Station"
	icon_state = "away"

/area/awaymission/wwmines
	name = "\improper Wild West Mines"
	icon_state = "away1"
	luminosity = 1
	requires_power = 0

/area/awaymission/wwgov
	name = "\improper Wild West Mansion"
	icon_state = "away2"
	luminosity = 1
	requires_power = 0

/area/awaymission/wwrefine
	name = "\improper Wild West Refinery"
	icon_state = "away3"
	luminosity = 1
	requires_power = 0

/area/awaymission/wwvault
	name = "\improper Wild West Vault"
	icon_state = "away3"
	luminosity = 0

/area/awaymission/wwvaultdoors
	name = "\improper Wild West Vault Doors"  // this is to keep the vault area being entirely lit because of requires_power
	icon_state = "away2"
	requires_power = 0
	luminosity = 0

/area/awaymission/desert
	name = "Mars"
	icon_state = "away"

/area/awaymission/BMPship1
	name = "\improper Aft Block"
	icon_state = "away1"

/area/awaymission/BMPship2
	name = "\improper Midship Block"
	icon_state = "away2"

/area/awaymission/BMPship3
	name = "\improper Fore Block"
	icon_state = "away3"

/area/awaymission/spacebattle
	name = "\improper Space Battle"
	icon_state = "away"
	requires_power = 0

/area/awaymission/spacebattle/cruiser
	name = "\improper Nanotrasen Cruiser"

/area/awaymission/spacebattle/syndicate1
	name = "\improper Syndicate Assault Ship 1"

/area/awaymission/spacebattle/syndicate2
	name = "\improper Syndicate Assault Ship 2"

/area/awaymission/spacebattle/syndicate3
	name = "\improper Syndicate Assault Ship 3"

/area/awaymission/spacebattle/syndicate4
	name = "\improper Syndicate War Sphere 1"

/area/awaymission/spacebattle/syndicate5
	name = "\improper Syndicate War Sphere 2"

/area/awaymission/spacebattle/syndicate6
	name = "\improper Syndicate War Sphere 3"

/area/awaymission/spacebattle/syndicate7
	name = "\improper Syndicate Fighter"

/area/awaymission/spacebattle/secret
	name = "\improper Hidden Chamber"

/area/awaymission/listeningpost
	name = "\improper Listening Post"
	icon_state = "away"
	requires_power = 0

/area/awaymission/beach
	name = "Beach"
	icon_state = "null"
	luminosity = 1
	lighting_use_dynamic = 0
	requires_power = 0
	var/sound/mysound = null

	New()
		..()
		var/sound/S = new/sound()
		mysound = S
		S.file = 'sound/ambience/shore.ogg'
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
		//set background = 1

		var/sound/S = null
		var/sound_delay = 0
		if(prob(25))
			S = sound(file=pick('sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag3.ogg'), volume=100)
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
	/area/engineering/atmos,
	/area/maintenance,
	/area/hallway,
	/area/bridge,
	/area/crew_quarters,
	/area/holodeck,
	/area/mint,
	/area/library,
	/area/chapel,
	/area/lawoffice,
	/area/engineering,
	/area/solar,
	/area/assembly,
	/area/teleporter,
	/area/medical,
	/area/security,
	/area/supply,
	/area/janitor,
	/area/hydroponics,
	/area/science,
	/area/storage,
	/area/tcomms,
	/area/construction,
	/area/ai_monitored/storage/eva, //do not try to simplify to "/area/ai_monitored" --rastaf0
	/area/ai_monitored/storage/secure,
	/area/ai_monitored/storage/emergency,
	/area/turret_protected/ai_upload, //do not try to simplify to "/area/turret_protected" --rastaf0
	/area/turret_protected/tcomms_control_room,
	/area/turret_protected/ai_upload_foyer,
	/area/turret_protected/ai,
)




/area/beach/
	name = "The metaclub's private beach"
	icon_state = "null"
	luminosity = 1
	lighting_use_dynamic = 0
	requires_power = 0
	var/sound/mysound = null

	New()
		..()
		var/sound/S = new/sound()
		mysound = S
		S.file = 'sound/ambience/shore.ogg'
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
		//set background = 1

		var/sound/S = null
		var/sound_delay = 0
		if(prob(25))
			S = sound(file=pick('sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag3.ogg'), volume=50)
			sound_delay = rand(0, 50)

		for(var/mob/living/carbon/human/H in src)
//			if(H.s_tone > -55)	//ugh...nice/novel idea but please no.
//				H.s_tone--
//				H.update_body()
			if(H.client)
				mysound.status = SOUND_UPDATE
				H << mysound
				if(S)
					spawn(sound_delay)
						H << S

		spawn(60) .()

