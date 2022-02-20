/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME   (you can make as many subdivisions as you want)
	name = "NICE NAME" (not required but makes things really nice)
	icon = 'ICON FILENAME' (defaults to 'icons/turf/areas.dmi')
	icon_state = "NAME OF ICON" (defaults to "unknown" (blank))
	requires_power = FALSE (defaults to true)
	ambience_index = AMBIENCE_GENERIC   (picks the ambience from an assoc list in ambience.dm)
	ambientsounds = list() (defaults to ambience_index's assoc on Initialize(). override it as "ambientsounds = list('sound/ambience/signal.ogg')" or by changing ambience_index)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/*-----------------------------------------------------------------------------*/

/area/ai_monitored //stub defined ai_monitored.dm

/area/ai_monitored/turret_protected

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	static_lighting = FALSE

	base_lighting_alpha = 255
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	area_flags = UNIQUE_AREA | NO_ALERTS
	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE

/area/space/nearstation
	icon_state = "space_near"
	area_flags = UNIQUE_AREA | NO_ALERTS | AREA_USES_STARLIGHT

/area/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	has_gravity = STANDARD_GRAVITY


/area/testroom
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	name = "Test Room"
	icon_state = "storage"

//EXTRA

/area/asteroid
	name = "\improper Asteroid"
	icon_state = "asteroid"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA
	ambience_index = AMBIENCE_MINING
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_ASTEROID
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/asteroid/nearstation
	static_lighting = TRUE
	ambience_index = AMBIENCE_RUINS
	always_unpowered = FALSE
	requires_power = TRUE
	area_flags = UNIQUE_AREA | BLOBS_ALLOWED

/area/asteroid/nearstation/bomb_site
	name = "\improper Bomb Testing Asteroid"

//STATION13

//AI

/area/ai_monitored
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ai_monitored/aisat/exterior
	name = "\improper AI Satellite Exterior"
	icon_state = "ai"
	airlock_wires = /datum/wires/airlock/ai

/area/ai_monitored/command/storage/satellite
	name = "\improper AI Satellite Maint"
	icon_state = "ai_storage"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/ai

//AI - Turret_protected

/area/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	///Some sounds (like the space jam) are terrible when on loop. We use this varaible to add it to other AI areas, but override it to keep it from the AI's core.
	var/ai_will_not_hear_this = list('sound/ambience/ambimalf.ogg')
	airlock_wires = /datum/wires/airlock/ai

/area/ai_monitored/turret_protected/Initialize(mapload)
	. = ..()
	if(ai_will_not_hear_this)
		ambientsounds += ai_will_not_hear_this

/area/ai_monitored/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ai_monitored/turret_protected/ai_upload_foyer
	name = "\improper AI Upload Access"
	icon_state = "ai_upload_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ai_monitored/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	ai_will_not_hear_this = null

/area/ai_monitored/turret_protected/aisat
	name = "\improper AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/ai_monitored/turret_protected/aisat/atmos
	name = "\improper AI Satellite Atmos"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/foyer
	name = "\improper AI Satellite Foyer"
	icon_state = "ai_foyer"

/area/ai_monitored/turret_protected/aisat/service
	name = "\improper AI Satellite Service"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/hallway
	name = "\improper AI Satellite Hallway"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/maint
	name = "\improper AI Satellite Maintenance"
	icon_state = "ai_maint"

/area/ai_monitored/turret_protected/aisat_interior
	name = "\improper AI Satellite Antechamber"
	icon_state = "ai_interior"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/ai_monitored/turret_protected/ai_sat_ext_as
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_east"

/area/ai_monitored/turret_protected/ai_sat_ext_ap
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_west"

//Maintenance

/area/maintenance
	name = "Generic Maintenance"
	ambience_index = AMBIENCE_MAINT
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED | PERSISTENT_ENGRAVINGS
	airlock_wires = /datum/wires/airlock/maint
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

//Maintenance - Departmental

/area/maintenance/department/chapel
	name = "Chapel Maintenance"
	icon_state = "maint_chapel"

/area/maintenance/department/chapel/monastery
	name = "Monastery Maintenance"
	icon_state = "maint_monastery"

/area/maintenance/department/crew_quarters/bar
	name = "Bar Maintenance"
	icon_state = "maint_bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/maintenance/department/crew_quarters/dorms
	name = "Dormitory Maintenance"
	icon_state = "maint_dorms"

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

/area/maintenance/department/security/upper
	name = "Upper Security Maintenance"

/area/maintenance/department/security/brig
	name = "Brig Maintenance"
	icon_state = "maint_brig"

/area/maintenance/department/medical
	name = "Medbay Maintenance"
	icon_state = "medbay_maint"

/area/maintenance/department/medical/central
	name = "Central Medbay Maintenance"
	icon_state = "medbay_maint_central"

/area/maintenance/department/medical/morgue
	name = "Morgue Maintenance"
	icon_state = "morgue_maint"

/area/maintenance/department/science
	name = "Science Maintenance"
	icon_state = "maint_sci"

/area/maintenance/department/science/central
	name = "Central Science Maintenance"
	icon_state = "maint_sci_central"

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
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | XENOBIOLOGY_COMPATIBLE | CULT_PERMITTED

//Maintenance - Generic Tunnels

/area/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "aftmaint"

/area/maintenance/aft/upper
	name = "Upper Aft Maintenance"
	icon_state = "upperaftmaint"

/area/maintenance/aft/greater //use greater variants of area definitions for when the station has two different sections of maintenance on the same z-level. Can stand alone without "lesser". This one means that this goes more fore/north than the "lesser" maintenance area.
	name = "Greater Aft Maintenance"
	icon_state = "greateraftmaint"

/area/maintenance/aft/lesser //use lesser variants of area definitions for when the station has two different sections of maintenance on the same z-level in conjunction with "greater" (just because it follows better). This one means that this goes more aft/south than the "greater" maintenance area.
	name = "Lesser Aft Maintenance"
	icon_state = "lesseraftmaint"

/area/maintenance/central
	name = "Central Maintenance"
	icon_state = "centralmaint"

/area/maintenance/central/greater
	name = "Greater Central Maintenance"
	icon_state = "greatercentralmaint"

/area/maintenance/central/lesser
	name = "Lesser Central Maintenance"
	icon_state = "lessercentralmaint"

/area/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "foremaint"

/area/maintenance/fore/upper
	name = "Upper Fore Maintenance"
	icon_state = "upperforemaint"

/area/maintenance/fore/greater
	name = "Greater Fore Maintenance"
	icon_state = "greaterforemaint"

/area/maintenance/fore/lesser
	name = "Lesser Fore Maintenance"
	icon_state = "lesserforemaint"

/area/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/starboard/upper
	name = "Upper Starboard Maintenance"
	icon_state = "upperstarboardmaint"

/area/maintenance/starboard/central
	name = "Central Starboard Maintenance"
	icon_state = "centralstarboardmaint"

/area/maintenance/starboard/greater
	name = "Greater Starboard Maintenance"
	icon_state = "greaterstarboardmaint"

/area/maintenance/starboard/lesser
	name = "Lesser Starboard Maintenance"
	icon_state = "lesserstarboardmaint"

/area/maintenance/starboard/aft
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/starboard/fore
	name = "Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/maintenance/port
	name = "Port Maintenance"
	icon_state = "portmaint"

/area/maintenance/port/central
	name = "Central Port Maintenance"
	icon_state = "centralportmaint"

/area/maintenance/port/greater
	name = "Greater Port Maintenance"
	icon_state = "greaterportmaint"

/area/maintenance/port/lesser
	name = "Lesser Port Maintenance"
	icon_state = "lesserportmaint"

/area/maintenance/port/aft
	name = "Aft Port Maintenance"
	icon_state = "apmaint"

/area/maintenance/port/fore
	name = "Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/tram
	name = "Primary Tram Maintenance"

/area/maintenance/tram/left
	name = "\improper Port Tram Underpass"
	icon_state = "mainttramL"

/area/maintenance/tram/mid
	name = "\improper Central Tram Underpass"
	icon_state = "mainttramM"

/area/maintenance/tram/right
	name = "\improper Starboard Tram Underpass"
	icon_state = "mainttramR"

//Maintenance - Discrete Areas
/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"
/area/maintenance/disposal/incinerator
	name = "\improper Incinerator"
	icon_state = "incinerator"

/area/maintenance/space_hut
	name = "\improper Space Hut"
	icon_state = "spacehut"

/area/maintenance/space_hut/cabin
	name = "Abandoned Cabin"

/area/maintenance/space_hut/plasmaman
	name = "\improper Abandoned Plasmaman Friendly Startup"

/area/maintenance/space_hut/observatory
	name = "\improper Space Observatory"

//Radation storm shelter
/area/maintenance/radshelter
	name = "\improper Radstorm Shelter"
	icon_state = "radstorm_shelter"

/area/maintenance/radshelter/medical
	name = "\improper Medical Radstorm Shelter"

/area/maintenance/radshelter/sec
	name = "\improper Security Radstorm Shelter"

/area/maintenance/radshelter/service
	name = "\improper Service Radstorm Shelter"

/area/maintenance/radshelter/civil
	name = "\improper Civilian Radstorm Shelter"

/area/maintenance/radshelter/sci
	name = "\improper Science Radstorm Shelter"

/area/maintenance/radshelter/cargo
	name = "\improper Cargo Radstorm Shelter"


//Hallway

/area/hallway
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hallway/primary
	name = "\improper Primary Hallway"

/area/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/central
	name = "\improper Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/central/fore
	name = "\improper Fore Central Primary Hallway"
	icon_state = "hallCF"

/area/hallway/primary/central/aft
	name = "\improper Aft Central Primary Hallway"
	icon_state = "hallCA"

/area/hallway/primary/upper
	name = "\improper Upper Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/tram
	name = "\improper Primary Tram"

/area/hallway/primary/tram/left
	name = "\improper Port Tram Dock"
	icon_state = "halltramL"

/area/hallway/primary/tram/center
	name = "\improper Central Tram Dock"
	icon_state = "halltramM"

/area/hallway/primary/tram/right
	name = "\improper Starboard Tram Dock"
	icon_state = "halltramR"

/area/hallway/secondary/command
	name = "\improper Command Hallway"
	icon_state = "bridge_hallway"

/area/hallway/secondary/construction
	name = "\improper Construction Area"
	icon_state = "construction"

/area/hallway/secondary/construction/engineering
	name = "\improper Engineering Hallway"

/area/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/exit/departure_lounge
	name = "\improper Departure Lounge"
	icon_state = "escape_lounge"

/area/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/secondary/service
	name = "\improper Service Hallway"
	icon_state = "hall_service"

//Command

/area/command
	name = "Command"
	icon_state = "Bridge"
	ambientsounds = list('sound/ambience/signal.ogg')
	airlock_wires = /datum/wires/airlock/command
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/command/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/command/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/command/meeting_room/council
	name = "\improper Council Chamber"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/command/corporate_showroom
	name = "\improper Corporate Showroom"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/command/heads_quarters

/area/command/heads_quarters/captain
	name = "\improper Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/command/heads_quarters/captain/private
	name = "\improper Captain's Quarters"
	icon_state = "captain_private"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/command/heads_quarters/ce
	name = "\improper Chief Engineer's Office"
	icon_state = "ce_office"

/area/command/heads_quarters/cmo
	name = "\improper Chief Medical Officer's Office"
	icon_state = "cmo_office"

/area/command/heads_quarters/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "hop_office"

/area/command/heads_quarters/hos
	name = "\improper Head of Security's Office"
	icon_state = "hos_office"

/area/command/heads_quarters/rd
	name = "\improper Research Director's Office"
	icon_state = "rd_office"

//Command - Teleporters

/area/command/teleporter
	name = "\improper Teleporter Room"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI

/area/command/gateway
	name = "\improper Gateway"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI

//Command - AI Monitored

/area/ai_monitored/command/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER

/area/ai_monitored/command/storage/eva/upper
	name = "Upper EVA Storage"

/area/ai_monitored/command/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"
	airlock_wires = /datum/wires/airlock/command

//Commons

/area/commons
	name = "\improper Crew Facilities"
	icon_state = "commons"
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/commons/dorms
	name = "\improper Dormitories"
	icon_state = "dorms"

/area/commons/dorms/barracks
	name = "\improper Sleep Barracks"

/area/commons/dorms/barracks/male
	name = "\improper Male Sleep Barracks"
	icon_state = "dorms_male"

/area/commons/dorms/barracks/female
	name = "\improper Female Sleep Barracks"
	icon_state = "dorms_female"

/area/commons/dorms/laundry
	name = "\improper Laundry Room"
	icon_state = "laundry_room"

/area/commons/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/commons/toilet/auxiliary
	name = "\improper Auxiliary Restrooms"
	icon_state = "toilet"

/area/commons/toilet/locker
	name = "\improper Locker Toilets"
	icon_state = "toilet"

/area/commons/toilet/restrooms
	name = "\improper Restrooms"
	icon_state = "toilet"

/area/commons/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/commons/lounge
	name = "\improper Bar Lounge"
	icon_state = "lounge"
	mood_bonus = 5
	mood_message = "<span class='nicegreen'>I love being in the bar!</span>\n"
	mood_trait = TRAIT_EXTROVERT
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/commons/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/commons/fitness/locker_room
	name = "\improper Unisex Locker Room"
	icon_state = "locker"

/area/commons/fitness/locker_room/male
	name = "\improper Male Locker Room"
	icon_state = "locker_male"

/area/commons/fitness/locker_room/female
	name = "\improper Female Locker Room"
	icon_state = "locker_female"

/area/commons/fitness/recreation
	name = "\improper Recreation Area"
	icon_state = "rec"

// Commons - Vacant Rooms
/area/commons/vacant_room
	name = "\improper Vacant Room"
	icon_state = "vacant_room"
	ambience_index = AMBIENCE_MAINT

/area/commons/vacant_room/office
	name = "\improper Vacant Office"
	icon_state = "vacant_office"

/area/commons/vacant_room/commissary
	name = "\improper Vacant Commissary"
	icon_state = "vacant_commissary"

//Commons - Storage
/area/commons/storage
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/commons/storage/tools
	name = "\improper Auxiliary Tool Storage"
	icon_state = "tool_storage"

/area/commons/storage/primary
	name = "\improper Primary Tool Storage"
	icon_state = "primary_storage"

/area/commons/storage/art
	name = "\improper Art Supply Storage"
	icon_state = "art_storage"

/area/commons/storage/emergency/starboard
	name = "\improper Starboard Emergency Storage"
	icon_state = "emergency_storage"

/area/commons/storage/emergency/port
	name = "\improper Port Emergency Storage"
	icon_state = "emergency_storage"

/area/commons/storage/mining
	name = "\improper Public Mining Storage"
	icon_state = "mining"

//Service

/area/service
	airlock_wires = /datum/wires/airlock/service

/area/service/cafeteria
	name = "\improper Cafeteria"
	icon_state = "cafeteria"

/area/service/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/service/kitchen/coldroom
	name = "\improper Kitchen Cold Room"
	icon_state = "kitchen_cold"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/service/kitchen/diner
	name = "\improper Diner"

/area/service/kitchen/abandoned
	name = "\improper Abandoned Kitchen"
	icon_state = "abandoned_kitchen"

/area/service/bar
	name = "\improper Bar"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = "<span class='nicegreen'>I love being in the bar!</span>\n"
	mood_trait = TRAIT_EXTROVERT
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_WOODFLOOR

/area/service/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/service/bar/atrium
	name = "\improper Atrium"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/service/electronic_marketing_den
	name = "\improper Electronic Marketing Den"
	icon_state = "abandoned_marketing_den"

/area/service/abandoned_gambling_den
	name = "\improper Abandoned Gambling Den"
	icon_state = "abandoned_gambling_den"

/area/service/abandoned_gambling_den/gaming
	name = "\improper Abandoned Gaming Den"
	icon_state = "abandoned_gaming_den"

/area/service/theater
	name = "\improper Theater"
	icon_state = "theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/service/theater/abandoned
	name = "\improper Abandoned Theater"
	icon_state = "abandoned_theatre"

/area/service/library
	name = "\improper Library"
	icon_state = "library"
	mood_bonus = 5
	mood_message = "<span class='nicegreen'>I love being in the library!</span>\n"
	mood_trait = TRAIT_INTROVERT
	area_flags = CULT_PERMITTED | BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/service/library/lounge
	name = "\improper Library Lounge"
	icon_state = "library_lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/service/library/artgallery
	name = "\improper  Art Gallery"
	icon_state = "library_gallery"

/area/service/library/private
	name = "\improper Library Private Study"
	icon_state = "library_gallery_private"

/area/service/library/upper
	name = "\improper Library Upper Floor"
	icon_state = "library"

/area/service/library/printer
	name = "\improper Library Printer Room"
	icon_state = "library"

/area/service/library/abandoned
	name = "\improper Abandoned Library"
	icon_state = "abandoned_library"

/area/service/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	mood_bonus = 5
	mood_message = "<span class='nicegreen'>Being in the chapel brings me peace.</span>\n"
	mood_trait = TRAIT_SPIRITUAL
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/service/chapel/monastery
	name = "\improper Monastery"

/area/service/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/service/chapel/asteroid
	name = "\improper Chapel Asteroid"
	icon_state = "explored"
	sound_environment = SOUND_AREA_ASTEROID

/area/service/chapel/asteroid/monastery
	name = "\improper Monastery Asteroid"

/area/service/chapel/dock
	name = "\improper Chapel Dock"
	icon_state = "construction"

/area/service/chapel/storage
	name = "\improper Chapel Storage"
	icon_state = "chapelstorage"

/area/service/lawoffice
	name = "\improper Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/service/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"
	area_flags = CULT_PERMITTED | BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/service/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/service/hydroponics/upper
	name = "Upper Hydroponics"
	icon_state = "hydro"

/area/service/hydroponics/garden
	name = "Garden"
	icon_state = "garden"

/area/service/hydroponics/garden/abandoned
	name = "\improper Abandoned Garden"
	icon_state = "abandoned_garden"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/service/hydroponics/garden/monastery
	name = "\improper Monastery Garden"
	icon_state = "hydro"

//Engineering

/area/engineering
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/engineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"

/area/engineering/main
	name = "Engineering"
	icon_state = "engine"

/area/engineering/hallway
	name = "Engineering Hallway"
	icon_state = "engine_hallway"

/area/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/engineering/atmos/upper
	name = "Upper Atmospherics"

/area/engineering/atmos/project
	name = "\improper Atmospherics Project Room"

/area/engineering/atmos/storage
	name = "\improper Atmospherics Storage Room"
	icon_state = "atmos_storage"

/area/engineering/atmos/storage/gas
	name = "\improper Atmospherics Gas Storage"
	icon_state = "atmos_storage_gas"

/area/engineering/atmos/office
	name = "\improper Atmospherics Office"

/area/engineering/atmos/hfr_room
	name = "\improper Atmospherics HFR Room"

/area/engineering/atmospherics_engine
	name = "\improper Atmospherics Engine"
	icon_state = "atmos_engine"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/engineering/lobby
	name = "\improper Engineering Lobby"
	icon_state = "engi_lobby"

/area/engineering/supermatter
	name = "\improper Supermatter Engine"
	icon_state = "engine_sm"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engineering/supermatter/room
	name = "\improper Supermatter Engine Room"
	icon_state = "engine_sm_room"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/engineering/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engine_break"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engineering/gravity_generator
	name = "\improper Gravity Generator Room"
	icon_state = "grav_gen"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engineering/storage
	name = "Engineering Storage"
	icon_state = "engine_storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engineering/storage_shared
	name = "Shared Engineering Storage"
	icon_state = "engine_storage_shared"

/area/engineering/transit_tube
	name = "\improper Transit Tube"
	icon_state = "transit_tube"

/area/engineering/storage/tech
	name = "Technical Storage"
	icon_state = "aux_storage"

/area/engineering/storage/tcomms
	name = "Telecomms Storage"
	icon_state = "tcom_storage"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

//Engineering - Construction

/area/construction
	name = "\improper Construction Area"
	icon_state = "construction"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/construction/mining/aux_base
	name = "Auxiliary Base Construction"
	icon_state = "aux_base_construction"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/construction/storage_wing
	name = "\improper Storage Wing"
	icon_state = "storage_wing"

//Solars

/area/solars
	requires_power = FALSE
	area_flags = UNIQUE_AREA | AREA_USES_STARLIGHT
	flags_1 = NONE
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_SPACE

/area/solars/fore
	name = "\improper Fore Solar Array"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/solars/aft
	name = "\improper Aft Solar Array"
	icon_state = "yellow"

/area/solars/aux/port
	name = "\improper Port Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solars/aux/starboard
	name = "\improper Starboard Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solars/starboard
	name = "\improper Starboard Solar Array"
	icon_state = "panelsS"

/area/solars/starboard/aft
	name = "\improper Starboard Quarter Solar Array"
	icon_state = "panelsAS"

/area/solars/starboard/fore
	name = "\improper Starboard Bow Solar Array"
	icon_state = "panelsFS"

/area/solars/port
	name = "\improper Port Solar Array"
	icon_state = "panelsP"

/area/solars/port/aft
	name = "\improper Port Quarter Solar Array"
	icon_state = "panelsAP"

/area/solars/port/fore
	name = "\improper Port Bow Solar Array"
	icon_state = "panelsFP"

/area/solars/aisat
	name = "\improper AI Satellite Solars"
	icon_state = "yellow"


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

//MedBay

/area/medical
	name = "Medical"
	icon_state = "medbay"
	ambience_index = AMBIENCE_MEDICAL
	airlock_wires = /datum/wires/airlock/medbay
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS

/area/medical/abandoned
	name = "\improper Abandoned Medbay"
	icon_state = "abandoned_medbay"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/medical/medbay/central
	name = "Medbay Central"
	icon_state = "med_central"

/area/medical/medbay/lobby
	name = "\improper Medbay Lobby"
	icon_state = "med_lobby"

	//Medbay is a large area, these additional areas help level out APC load.
/area/medical/medbay/aft
	name = "Medbay Aft"
	icon_state = "med_aft"

/area/medical/storage
	name = "Medbay Storage"
	icon_state = "med_storage"

/area/medical/paramedic
	name = "Paramedic Dispatch"
	icon_state = "paramedic"

/area/medical/office
	name = "\improper Medical Office"
	icon_state = "med_office"

/area/medical/surgery/room_c
	name = "Surgery C"
	icon_state = "surgery"

/area/medical/surgery/room_d
	name = "Surgery D"
	icon_state = "surgery"

/area/medical/break_room
	name = "\improper Medical Break Room"
	icon_state = "med_break"

/area/medical/coldroom
	name = "\improper Medical Cold Room"
	icon_state = "kitchen_cold"

/area/medical/patients_rooms
	name = "\improper Patients' Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/medical/patients_rooms/room_a
	name = "Patient Room A"
	icon_state = "patients"

/area/medical/patients_rooms/room_b
	name = "Patient Room B"
	icon_state = "patients"

/area/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/medical/pharmacy
	name = "\improper Pharmacy"
	icon_state = "pharmacy"

/area/medical/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/medical/surgery/room_b
	name = "Surgery B"
	icon_state = "surgery"

/area/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/medical/treatment_center
	name = "\improper Medbay Treatment Center"
	icon_state = "exam_room"

/area/medical/psychology
	name = "\improper Psychology Office"
	icon_state = "psychology"
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>I feel at ease here.</span>\n"
	ambientsounds = list('sound/ambience/aurora_caelus_short.ogg')

//Security
///When adding a new area to the security areas, make sure to add it to /datum/bounty/item/security/paperwork as well!

/area/security
	name = "Security"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/security/office
	name = "\improper Security Office"
	icon_state = "security"

/area/security/lockers
	name = "\improper Security Locker Room"
	icon_state = "securitylockerroom"

/area/security/brig
	name = "\improper Brig"
	icon_state = "brig"

/area/security/medical
	name = "\improper Security Medical"
	icon_state = "security_medical"

/area/security/brig/upper
	name = "\improper Brig Overlook"
	icon_state = "upperbrig"

/area/security/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED | PERSISTENT_ENGRAVINGS

/area/security/prison/toilet //radproof
	name = "\improper Prison Toilet"
	icon_state = "sec_prison_safe"

/area/security/prison/safe //radproof
	name = "\improper Prison Wing Cells"
	icon_state = "sec_prison_safe"

/area/security/prison/upper
	name = "\improper Upper Prison Wing"
	icon_state = "prison_upper"

/area/security/prison/visit
	name = "\improper Prison Visitation Area"
	icon_state = "prison_visit"

/area/security/prison/rec
	name = "\improper Prison Rec Room"
	icon_state = "prison_rec"

/area/security/prison/mess
	name = "\improper Prison Mess Hall"
	icon_state = "prison_mess"

/area/security/prison/work
	name = "\improper Prison Work Room"
	icon_state = "prison_work"

/area/security/prison/shower
	name = "\improper Prison Shower"
	icon_state = "prison_shower"

/area/security/prison/workout
	name = "\improper Prison Gym"
	icon_state = "prison_workout"

/area/security/prison/garden
	name = "\improper Prison Garden"
	icon_state = "prison_garden"

/area/security/processing
	name = "\improper Labor Shuttle Dock"
	icon_state = "sec_processing"

/area/security/processing/cremation
	name = "\improper Security Crematorium"
	icon_state = "sec_cremation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/security/interrogation
	name = "\improper Interrogation Room"
	icon_state = "interrogation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/security/warden
	name = "Brig Control"
	icon_state = "warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/detectives_office
	name = "\improper Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg','sound/ambience/ambidet2.ogg')

/area/security/detectives_office/private_investigators_office
	name = "\improper Private Investigator's Office"
	icon_state = "investigate_office"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"

/area/security/execution
	icon_state = "execution_room"

/area/security/execution/transfer
	name = "\improper Transfer Centre"
	icon_state = "sec_processing"

/area/security/execution/education
	name = "\improper Prisoner Education Chamber"

/area/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint"

/area/security/checkpoint/auxiliary
	icon_state = "checkpoint_aux"

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
	name = "Auxiliary Customs"
	icon_state = "customs_point_aux"

/area/security/checkpoint/customs/fore
	name = "Fore Customs"
	icon_state = "customs_point_fore"

/area/security/checkpoint/customs/aft
	name = "Aft Customs"
	icon_state = "customs_point_aft"

//Security - AI Monitored
/area/ai_monitored/security/armory
	name = "\improper Armory"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security

/area/ai_monitored/security/armory/upper
	name = "Upper Armory"

//Cargo

/area/cargo
	name = "Quartermasters"
	icon_state = "quart"
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/cargo/sorting
	name = "\improper Delivery Office"
	icon_state = "cargo_delivery"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/cargo/warehouse
	name = "\improper Warehouse"
	icon_state = "cargo_warehouse"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/cargo/drone_bay
	name = "\improper Drone Bay"
	icon_state = "cargo_drone"

/area/cargo/warehouse/upper
	name = "\improper Upper Warehouse"

/area/cargo/office
	name = "\improper Cargo Office"
	icon_state = "cargo_office"

/area/cargo/storage
	name = "\improper Cargo Bay"
	icon_state = "cargo_bay"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/cargo/qm
	name = "\improper Quartermaster's Office"
	icon_state = "quart_office"

/area/cargo/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining"

/area/cargo/miningoffice
	name = "\improper Mining Office"
	icon_state = "mining"

//Science

/area/science
	name = "\improper Science Division"
	icon_state = "science"
	airlock_wires = /datum/wires/airlock/science
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/science/lobby
	name = "\improper Science Lobby"
	icon_state = "science_lobby"

/area/science/breakroom
	name = "\improper Science Break Room"
	icon_state = "science_breakroom"

/area/science/lab
	name = "Research and Development"
	icon_state = "research"

/area/science/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xenobio"

/area/science/cytology
	name = "\improper Cytology Lab"
	icon_state = "cytology"

/area/science/storage
	name = "Ordnance Storage"
	icon_state = "ord_storage"

/area/science/test_area
	name = "\improper Ordnance Test Area"
	icon_state = "ord_test"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/science/mixing
	name = "\improper Ordnance Mixing Lab"
	icon_state = "ord_mix"

/area/science/mixing/chamber
	name = "\improper Ordnance Mixing Chamber"
	icon_state = "ord_mix_chamber"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/science/genetics
	name = "\improper Genetics Lab"
	icon_state = "geneticssci"

/area/science/misc_lab
	name = "\improper Testing Lab"
	icon_state = "ord_misc"

/area/science/misc_lab/range
	name = "\improper Research Testing Range"
	icon_state = "ord_range"

/area/science/server
	name = "\improper Research Division Server Room"
	icon_state = "server"

/area/science/explab
	name = "\improper Experimentation Lab"
	icon_state = "exp_lab"

/area/science/robotics
	name = "Robotics"
	icon_state = "robotics"

/area/science/robotics/mechbay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/science/robotics/lab
	name = "\improper Robotics Lab"
	icon_state = "ass_line"

/area/science/research
	name = "\improper Research Division"
	icon_state = "science"

/area/science/research/abandoned
	name = "\improper Abandoned Research Lab"
	icon_state = "abandoned_sci"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

// Telecommunications Satellite

/area/tcommsat
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')
	airlock_wires = /datum/wires/airlock/engineering
	network_root_id = STATION_NETWORK_ROOT // They should of unpluged the router before they left

/area/tcommsat/computer
	name = "\improper Telecomms Control Room"
	icon_state = "tcomsatcomp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/tcommsat/server
	name = "\improper Telecomms Server Room"
	icon_state = "tcomsatcham"

/area/tcommsat/server/upper
	name = "\improper Upper Telecomms Server Room"

//Telecommunications - On Station

/area/comms
	name = "\improper Communications Relay"
	icon_state = "tcomsatcham"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/server
	name = "\improper Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

//External Hull Access
/area/maintenance/external
	name = "\improper External Hull Access"
	icon_state = "amaint"

/area/maintenance/external/aft
	name = "\improper Aft External Hull Access"

/area/maintenance/external/port
	name = "\improper Port External Hull Access"

/area/maintenance/external/port/bow
	name = "\improper Port Bow External Hull Access"
