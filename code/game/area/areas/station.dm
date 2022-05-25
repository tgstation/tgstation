// Station areas and shuttles

/area/station/
	name = "Station Areas"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "station"

//Maintenance

/area/station/maintenance
	name = "Generic Maintenance"
	ambience_index = AMBIENCE_MAINT
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED | PERSISTENT_ENGRAVINGS
	airlock_wires = /datum/wires/airlock/maint
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

//Maintenance - Departmental

/area/station/maintenance/department/chapel
	name = "Chapel Maintenance"
	icon_state = "maint_chapel"

/area/station/maintenance/department/chapel/monastery
	name = "Monastery Maintenance"
	icon_state = "maint_monastery"

/area/station/maintenance/department/crew_quarters/bar
	name = "Bar Maintenance"
	icon_state = "maint_bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/maintenance/department/crew_quarters/dorms
	name = "Dormitory Maintenance"
	icon_state = "maint_dorms"

/area/station/maintenance/department/eva
	name = "EVA Maintenance"
	icon_state = "maint_eva"

/area/station/maintenance/department/electrical
	name = "Electrical Maintenance"
	icon_state = "maint_electrical"

/area/station/maintenance/department/engine/atmos
	name = "Atmospherics Maintenance"
	icon_state = "maint_atmos"

/area/station/maintenance/department/security
	name = "Security Maintenance"
	icon_state = "maint_sec"

/area/station/maintenance/department/security/upper
	name = "Upper Security Maintenance"

/area/station/maintenance/department/security/brig
	name = "Brig Maintenance"
	icon_state = "maint_brig"

/area/station/maintenance/department/medical
	name = "Medbay Maintenance"
	icon_state = "medbay_maint"

/area/station/maintenance/department/medical/central
	name = "Central Medbay Maintenance"
	icon_state = "medbay_maint_central"

/area/station/maintenance/department/medical/morgue
	name = "Morgue Maintenance"
	icon_state = "morgue_maint"

/area/station/maintenance/department/science
	name = "Science Maintenance"
	icon_state = "maint_sci"

/area/station/maintenance/department/science/central
	name = "Central Science Maintenance"
	icon_state = "maint_sci_central"

/area/station/maintenance/department/cargo
	name = "Cargo Maintenance"
	icon_state = "maint_cargo"

/area/station/maintenance/department/bridge
	name = "Bridge Maintenance"
	icon_state = "maint_bridge"

/area/station/maintenance/department/engine
	name = "Engineering Maintenance"
	icon_state = "maint_engi"

/area/station/maintenance/department/science/xenobiology
	name = "Xenobiology Maintenance"
	icon_state = "xenomaint"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | XENOBIOLOGY_COMPATIBLE | CULT_PERMITTED

//Maintenance - Generic Tunnels

/area/station/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "aftmaint"

/area/station/maintenance/aft/upper
	name = "Upper Aft Maintenance"
	icon_state = "upperaftmaint"

/area/station/maintenance/aft/greater //use greater variants of area definitions for when the station has two different sections of maintenance on the same z-level. Can stand alone without "lesser". This one means that this goes more fore/north than the "lesser" maintenance area.
	name = "Greater Aft Maintenance"
	icon_state = "greateraftmaint"

/area/station/maintenance/aft/lesser //use lesser variants of area definitions for when the station has two different sections of maintenance on the same z-level in conjunction with "greater" (just because it follows better). This one means that this goes more aft/south than the "greater" maintenance area.
	name = "Lesser Aft Maintenance"
	icon_state = "lesseraftmaint"

/area/station/maintenance/central
	name = "Central Maintenance"
	icon_state = "centralmaint"

/area/station/maintenance/central/greater
	name = "Greater Central Maintenance"
	icon_state = "greatercentralmaint"

/area/station/maintenance/central/lesser
	name = "Lesser Central Maintenance"
	icon_state = "lessercentralmaint"

/area/station/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "foremaint"

/area/station/maintenance/fore/upper
	name = "Upper Fore Maintenance"
	icon_state = "upperforemaint"

/area/station/maintenance/fore/greater
	name = "Greater Fore Maintenance"
	icon_state = "greaterforemaint"

/area/station/maintenance/fore/lesser
	name = "Lesser Fore Maintenance"
	icon_state = "lesserforemaint"

/area/station/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "starboardmaint"

/area/station/maintenance/starboard/upper
	name = "Upper Starboard Maintenance"
	icon_state = "upperstarboardmaint"

/area/station/maintenance/starboard/central
	name = "Central Starboard Maintenance"
	icon_state = "centralstarboardmaint"

/area/station/maintenance/starboard/greater
	name = "Greater Starboard Maintenance"
	icon_state = "greaterstarboardmaint"

/area/station/maintenance/starboard/lesser
	name = "Lesser Starboard Maintenance"
	icon_state = "lesserstarboardmaint"

/area/station/maintenance/starboard/aft
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/starboard/fore
	name = "Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/port
	name = "Port Maintenance"
	icon_state = "portmaint"

/area/station/maintenance/port/central
	name = "Central Port Maintenance"
	icon_state = "centralportmaint"

/area/station/maintenance/port/greater
	name = "Greater Port Maintenance"
	icon_state = "greaterportmaint"

/area/station/maintenance/port/lesser
	name = "Lesser Port Maintenance"
	icon_state = "lesserportmaint"

/area/station/maintenance/port/aft
	name = "Aft Port Maintenance"
	icon_state = "apmaint"

/area/station/maintenance/port/fore
	name = "Fore Port Maintenance"
	icon_state = "fpmaint"

/area/station/maintenance/tram
	name = "Primary Tram Maintenance"

/area/station/maintenance/tram/left
	name = "\improper Port Tram Underpass"
	icon_state = "mainttramL"

/area/station/maintenance/tram/mid
	name = "\improper Central Tram Underpass"
	icon_state = "mainttramM"

/area/station/maintenance/tram/right
	name = "\improper Starboard Tram Underpass"
	icon_state = "mainttramR"

//Maintenance - Discrete Areas
/area/station/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/station/maintenance/disposal/incinerator
	name = "\improper Incinerator"
	icon_state = "incinerator"

/area/station/maintenance/space_hut
	name = "\improper Space Hut"
	icon_state = "spacehut"

/area/station/maintenance/space_hut/cabin
	name = "Abandoned Cabin"

/area/station/maintenance/space_hut/plasmaman
	name = "\improper Abandoned Plasmaman Friendly Startup"

/area/station/maintenance/space_hut/observatory
	name = "\improper Space Observatory"

//Radation storm shelter
/area/station/maintenance/radshelter
	name = "\improper Radstorm Shelter"
	icon_state = "radstorm_shelter"

/area/station/maintenance/radshelter/medical
	name = "\improper Medical Radstorm Shelter"

/area/station/maintenance/radshelter/sec
	name = "\improper Security Radstorm Shelter"

/area/station/maintenance/radshelter/service
	name = "\improper Service Radstorm Shelter"

/area/station/maintenance/radshelter/civil
	name = "\improper Civilian Radstorm Shelter"

/area/station/maintenance/radshelter/sci
	name = "\improper Science Radstorm Shelter"

/area/station/maintenance/radshelter/cargo
	name = "\improper Cargo Radstorm Shelter"


//Hallway

/area/station/hallway
	icon_state = "hall"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/hallway/primary
	name = "\improper Primary Hallway"
	icon_state = "primaryhall"

/area/station/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "afthall"

/area/station/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "forehall"

/area/station/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "starboardhall"

/area/station/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "porthall"

/area/station/hallway/primary/central
	name = "\improper Central Primary Hallway"
	icon_state = "centralhall"

/area/station/hallway/primary/central/fore
	name = "\improper Fore Central Primary Hallway"
	icon_state = "hallCF"

/area/station/hallway/primary/central/aft
	name = "\improper Aft Central Primary Hallway"
	icon_state = "hallCA"

/area/station/hallway/primary/upper
	name = "\improper Upper Central Primary Hallway"
	icon_state = "centralhall"

/area/station/hallway/primary/tram
	name = "\improper Primary Tram"

/area/station/hallway/primary/tram/left
	name = "\improper Port Tram Dock"
	icon_state = "halltramL"

/area/station/hallway/primary/tram/center
	name = "\improper Central Tram Dock"
	icon_state = "halltramM"

/area/station/hallway/primary/tram/right
	name = "\improper Starboard Tram Dock"
	icon_state = "halltramR"

/area/station/hallway/secondary // This shouldn't be used, but it gives an icon for the enviornment tree in the map editor
	icon_state = "secondaryhall"

/area/station/hallway/secondary/command
	name = "\improper Command Hallway"
	icon_state = "bridge_hallway"

/area/station/hallway/secondary/construction
	name = "\improper Construction Area"
	icon_state = "construction"

/area/station/hallway/secondary/construction/engineering
	name = "\improper Engineering Hallway"

/area/station/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/station/hallway/secondary/exit/departure_lounge
	name = "\improper Departure Lounge"
	icon_state = "escape_lounge"

/area/station/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/station/hallway/secondary/service
	name = "\improper Service Hallway"
	icon_state = "hall_service"

//Command

/area/station/command
	name = "Command"
	icon_state = "command"
	ambientsounds = list('sound/ambience/signal.ogg')
	airlock_wires = /datum/wires/airlock/command
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/command/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/station/command/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/meeting_room/council
	name = "\improper Council Chamber"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_showroom
	name = "\improper Corporate Showroom"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/heads_quarters
	icon_state = "heads_quarters"

/area/station/command/heads_quarters/captain
	name = "\improper Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/captain/private
	name = "\improper Captain's Quarters"
	icon_state = "captain_private"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/ce
	name = "\improper Chief Engineer's Office"
	icon_state = "ce_office"

/area/station/command/heads_quarters/cmo
	name = "\improper Chief Medical Officer's Office"
	icon_state = "cmo_office"

/area/station/command/heads_quarters/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "hop_office"

/area/station/command/heads_quarters/hos
	name = "\improper Head of Security's Office"
	icon_state = "hos_office"

/area/station/command/heads_quarters/rd
	name = "\improper Research Director's Office"
	icon_state = "rd_office"

//Command - Teleporters

/area/station/command/teleporter
	name = "\improper Teleporter Room"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI

/area/station/command/gateway
	name = "\improper Gateway"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI

//Commons

/area/station/commons
	name = "\improper Crew Facilities"
	icon_state = "commons"
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/commons/dorms
	name = "\improper Dormitories"
	icon_state = "dorms"

/area/station/commons/dorms/barracks
	name = "\improper Sleep Barracks"

/area/station/commons/dorms/barracks/male
	name = "\improper Male Sleep Barracks"
	icon_state = "dorms_male"

/area/station/commons/dorms/barracks/female
	name = "\improper Female Sleep Barracks"
	icon_state = "dorms_female"

/area/station/commons/dorms/laundry
	name = "\improper Laundry Room"
	icon_state = "laundry_room"

/area/station/commons/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/commons/toilet/auxiliary
	name = "\improper Auxiliary Restrooms"
	icon_state = "toilet"

/area/station/commons/toilet/locker
	name = "\improper Locker Toilets"
	icon_state = "toilet"

/area/station/commons/toilet/restrooms
	name = "\improper Restrooms"
	icon_state = "toilet"

/area/station/commons/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/station/commons/lounge
	name = "\improper Bar Lounge"
	icon_state = "lounge"
	mood_bonus = 5
	mood_message = "I love being in the bar!"
	mood_trait = TRAIT_EXTROVERT
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/commons/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/station/commons/fitness/locker_room
	name = "\improper Unisex Locker Room"
	icon_state = "locker"

/area/station/commons/fitness/locker_room/male
	name = "\improper Male Locker Room"
	icon_state = "locker_male"

/area/station/commons/fitness/locker_room/female
	name = "\improper Female Locker Room"
	icon_state = "locker_female"

/area/station/commons/fitness/recreation
	name = "\improper Recreation Area"
	icon_state = "rec"

/area/station/commons/fitness/recreation/entertainment
	name = "\improper Entertainment Center"
	icon_state = "entertainment"

// Commons - Vacant Rooms
/area/station/commons/vacant_room
	name = "\improper Vacant Room"
	icon_state = "vacant_room"
	ambience_index = AMBIENCE_MAINT

/area/station/commons/vacant_room/office
	name = "\improper Vacant Office"
	icon_state = "vacant_office"

/area/station/commons/vacant_room/commissary
	name = "\improper Vacant Commissary"
	icon_state = "vacant_commissary"

//Commons - Storage
/area/station/commons/storage
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/commons/storage/tools
	name = "\improper Auxiliary Tool Storage"
	icon_state = "tool_storage"

/area/station/commons/storage/primary
	name = "\improper Primary Tool Storage"
	icon_state = "primary_storage"

/area/station/commons/storage/art
	name = "\improper Art Supply Storage"
	icon_state = "art_storage"

/area/station/commons/storage/emergency/starboard
	name = "\improper Starboard Emergency Storage"
	icon_state = "emergency_storage"

/area/station/commons/storage/emergency/port
	name = "\improper Port Emergency Storage"
	icon_state = "emergency_storage"

/area/station/commons/storage/mining
	name = "\improper Public Mining Storage"
	icon_state = "mining_storage"

//Service

/area/station/service
	airlock_wires = /datum/wires/airlock/service

/area/station/service/cafeteria
	name = "\improper Cafeteria"
	icon_state = "cafeteria"

/area/station/service/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/station/service/kitchen/coldroom
	name = "\improper Kitchen Cold Room"
	icon_state = "kitchen_cold"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/kitchen/diner
	name = "\improper Diner"
	icon_state = "diner"

/area/station/service/kitchen/abandoned
	name = "\improper Abandoned Kitchen"
	icon_state = "abandoned_kitchen"

/area/station/service/bar
	name = "\improper Bar"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = "I love being in the bar!"
	mood_trait = TRAIT_EXTROVERT
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/station/service/bar/atrium
	name = "\improper Atrium"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/electronic_marketing_den
	name = "\improper Electronic Marketing Den"
	icon_state = "abandoned_marketing_den"

/area/station/service/abandoned_gambling_den
	name = "\improper Abandoned Gambling Den"
	icon_state = "abandoned_gambling_den"

/area/station/service/abandoned_gambling_den/gaming
	name = "\improper Abandoned Gaming Den"
	icon_state = "abandoned_gaming_den"

/area/station/service/theater
	name = "\improper Theater"
	icon_state = "theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/theater/abandoned
	name = "\improper Abandoned Theater"
	icon_state = "abandoned_theatre"

/area/station/service/library
	name = "\improper Library"
	icon_state = "library"
	mood_bonus = 5
	mood_message = "I love being in the library!"
	mood_trait = TRAIT_INTROVERT
	area_flags = CULT_PERMITTED | BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/station/service/library/lounge
	name = "\improper Library Lounge"
	icon_state = "library_lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/library/artgallery
	name = "\improper  Art Gallery"
	icon_state = "library_gallery"

/area/station/service/library/private
	name = "\improper Library Private Study"
	icon_state = "library_gallery_private"

/area/station/service/library/upper
	name = "\improper Library Upper Floor"
	icon_state = "library"

/area/station/service/library/printer
	name = "\improper Library Printer Room"
	icon_state = "library"

/area/station/service/library/abandoned
	name = "\improper Abandoned Library"
	icon_state = "abandoned_library"

/area/station/service/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	mood_bonus = 5
	mood_message = "Being in the chapel brings me peace."
	mood_trait = TRAIT_SPIRITUAL
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/service/chapel/monastery
	name = "\improper Monastery"

/area/station/service/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/station/service/chapel/asteroid
	name = "\improper Chapel Asteroid"
	icon_state = "explored"
	sound_environment = SOUND_AREA_ASTEROID

/area/station/service/chapel/asteroid/monastery
	name = "\improper Monastery Asteroid"

/area/station/service/chapel/dock
	name = "\improper Chapel Dock"
	icon_state = "construction"

/area/station/service/chapel/storage
	name = "\improper Chapel Storage"
	icon_state = "chapelstorage"

/area/station/service/chapel/funeral
	name = "\improper Chapel Funeral Room"
	icon_state = "chapelfuneral"

/area/station/service/lawoffice
	name = "\improper Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"
	area_flags = CULT_PERMITTED | BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/service/hydroponics/upper
	name = "Upper Hydroponics"
	icon_state = "hydro"

/area/station/service/hydroponics/garden
	name = "Garden"
	icon_state = "garden"

/area/station/service/hydroponics/garden/abandoned
	name = "\improper Abandoned Garden"
	icon_state = "abandoned_garden"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/hydroponics/garden/monastery
	name = "\improper Monastery Garden"
	icon_state = "hydro"

//Engineering

/area/station/engineering
	icon_state = "engie"
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"

/area/station/engineering/main
	name = "Engineering"
	icon_state = "engine"

/area/station/engineering/hallway
	name = "Engineering Hallway"
	icon_state = "engine_hallway"

/area/station/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/station/engineering/atmos/upper
	name = "Upper Atmospherics"

/area/station/engineering/atmos/project
	name = "\improper Atmospherics Project Room"
	icon_state = "atmos_projectroom"

/area/station/engineering/atmos/pumproom
	name = "\improper Atmospherics Pumping Room"
	icon_state = "atmos_pump_room"

/area/station/engineering/atmos/mix
	name = "\improper Atmospherics Mixing Room"
	icon_state = "atmos_mix"

/area/station/engineering/atmos/storage
	name = "\improper Atmospherics Storage Room"
	icon_state = "atmos_storage"

/area/station/engineering/atmos/storage/gas
	name = "\improper Atmospherics Gas Storage"
	icon_state = "atmos_storage_gas"

/area/station/engineering/atmos/office
	name = "\improper Atmospherics Office"
	icon_state = "atmos_office"

/area/station/engineering/atmos/hfr_room
	name = "\improper Atmospherics HFR Room"
	icon_state = "atmos_HFR"

/area/station/engineering/atmospherics_engine
	name = "\improper Atmospherics Engine"
	icon_state = "atmos_engine"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/engineering/lobby
	name = "\improper Engineering Lobby"
	icon_state = "engi_lobby"

/area/station/engineering/supermatter
	name = "\improper Supermatter Engine"
	icon_state = "engine_sm"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/supermatter/room
	name = "\improper Supermatter Engine Room"
	icon_state = "engine_sm_room"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engine_break"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/gravity_generator
	name = "\improper Gravity Generator Room"
	icon_state = "grav_gen"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/storage
	name = "Engineering Storage"
	icon_state = "engine_storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/storage_shared
	name = "Shared Engineering Storage"
	icon_state = "engine_storage_shared"

/area/station/engineering/transit_tube
	name = "\improper Transit Tube"
	icon_state = "transit_tube"

/area/station/engineering/storage/tech
	name = "Technical Storage"
	icon_state = "tech_storage"

/area/station/engineering/storage/tcomms
	name = "Telecomms Storage"
	icon_state = "tcom_storage"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

//Engineering - Construction

/area/station/construction
	name = "\improper Construction Area"
	icon_state = "construction"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/construction/mining/aux_base
	name = "Auxiliary Base Construction"
	icon_state = "aux_base_construction"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/construction/storage_wing
	name = "\improper Storage Wing"
	icon_state = "storage_wing"

//Solars

/area/station/solars
	icon_state = "panels"
	requires_power = FALSE
	area_flags = UNIQUE_AREA | AREA_USES_STARLIGHT
	flags_1 = NONE
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_SPACE
	base_lighting_alpha = 255

/area/station/solars/fore
	name = "\improper Fore Solar Array"
	icon_state = "panelsF"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/solars/aft
	name = "\improper Aft Solar Array"
	icon_state = "panelsAF"

/area/station/solars/aux/port
	name = "\improper Port Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/station/solars/aux/starboard
	name = "\improper Starboard Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/station/solars/starboard
	name = "\improper Starboard Solar Array"
	icon_state = "panelsS"

/area/station/solars/starboard/aft
	name = "\improper Starboard Quarter Solar Array"
	icon_state = "panelsAS"

/area/station/solars/starboard/fore
	name = "\improper Starboard Bow Solar Array"
	icon_state = "panelsFS"

/area/station/solars/port
	name = "\improper Port Solar Array"
	icon_state = "panelsP"

/area/station/solars/port/aft
	name = "\improper Port Quarter Solar Array"
	icon_state = "panelsAP"

/area/station/solars/port/fore
	name = "\improper Port Bow Solar Array"
	icon_state = "panelsFP"

/area/station/solars/aisat
	name = "\improper AI Satellite Solars"
	icon_state = "panelsAI"


//Solar Maint

/area/station/maintenance/solars
	name = "Solar Maintenance"
	icon_state = "yellow"

/area/station/maintenance/solars/port
	name = "Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/station/maintenance/solars/port/aft
	name = "Port Quarter Solar Maintenance"
	icon_state = "SolarcontrolAP"

/area/station/maintenance/solars/port/fore
	name = "Port Bow Solar Maintenance"
	icon_state = "SolarcontrolFP"

/area/station/maintenance/solars/starboard
	name = "Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/station/maintenance/solars/starboard/aft
	name = "Starboard Quarter Solar Maintenance"
	icon_state = "SolarcontrolAS"

/area/station/maintenance/solars/starboard/fore
	name = "Starboard Bow Solar Maintenance"
	icon_state = "SolarcontrolFS"

//MedBay

/area/station/medical
	name = "Medical"
	icon_state = "medbay"
	ambience_index = AMBIENCE_MEDICAL
	airlock_wires = /datum/wires/airlock/medbay
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS

/area/station/medical/abandoned
	name = "\improper Abandoned Medbay"
	icon_state = "abandoned_medbay"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/medical/medbay/central
	name = "Medbay Central"
	icon_state = "med_central"

/area/station/medical/medbay/lobby
	name = "\improper Medbay Lobby"
	icon_state = "med_lobby"

//Medbay is a large area, these additional areas help level out APC load.

/area/station/medical/medbay/aft
	name = "Medbay Aft"
	icon_state = "med_aft"

/area/station/medical/storage
	name = "Medbay Storage"
	icon_state = "med_storage"

/area/station/medical/paramedic
	name = "Paramedic Dispatch"
	icon_state = "paramedic"

/area/station/medical/office
	name = "\improper Medical Office"
	icon_state = "med_office"

/area/station/medical/break_room
	name = "\improper Medical Break Room"
	icon_state = "med_break"

/area/station/medical/coldroom
	name = "\improper Medical Cold Room"
	icon_state = "kitchen_cold"

/area/station/medical/patients_rooms
	name = "\improper Patients' Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms/room_a
	name = "Patient Room A"
	icon_state = "patients"

/area/station/medical/patients_rooms/room_b
	name = "Patient Room B"
	icon_state = "patients"

/area/station/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/station/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/station/medical/pharmacy
	name = "\improper Pharmacy"
	icon_state = "pharmacy"

/area/station/medical/surgery
	name = "\improper Operating Room"
	icon_state = "surgery"

/area/station/medical/surgery/fore
	name = "\improper Fore Operating Room"
	icon_state = "foresurgery"

/area/station/medical/surgery/aft
	name = "\improper Aft Operating Room"
	icon_state = "aftsurgery"

/area/station/medical/surgery/theatre
	name = "\improper Grand Surgery Theatre"
	icon_state = "surgerytheatre"
/area/station/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/station/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/station/medical/treatment_center
	name = "\improper Medbay Treatment Center"
	icon_state = "exam_room"

/area/station/medical/psychology
	name = "\improper Psychology Office"
	icon_state = "psychology"
	mood_bonus = 3
	mood_message = "I feel at ease here."
	ambientsounds = list('sound/ambience/aurora_caelus_short.ogg')

//Security
///When adding a new area to the security areas, make sure to add it to /datum/bounty/item/security/paperwork as well!

/area/station/security
	name = "Security"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/security/office
	name = "\improper Security Office"
	icon_state = "security"

/area/station/security/lockers
	name = "\improper Security Locker Room"
	icon_state = "securitylockerroom"

/area/station/security/brig
	name = "\improper Brig"
	icon_state = "brig"

/area/station/security/holding_cell
	name = "\improper Holding Cell"
	icon_state = "holding_cell"

/area/station/security/medical
	name = "\improper Security Medical"
	icon_state = "security_medical"

/area/station/security/brig/upper
	name = "\improper Brig Overlook"
	icon_state = "upperbrig"

/area/station/security/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED | PERSISTENT_ENGRAVINGS

//Rad proof
/area/station/security/prison/toilet
	name = "\improper Prison Toilet"
	icon_state = "sec_prison_safe"

// Rad proof
/area/station/security/prison/safe
	name = "\improper Prison Wing Cells"
	icon_state = "sec_prison_safe"

/area/station/security/prison/upper
	name = "\improper Upper Prison Wing"
	icon_state = "prison_upper"

/area/station/security/prison/visit
	name = "\improper Prison Visitation Area"
	icon_state = "prison_visit"

/area/station/security/prison/rec
	name = "\improper Prison Rec Room"
	icon_state = "prison_rec"

/area/station/security/prison/mess
	name = "\improper Prison Mess Hall"
	icon_state = "prison_mess"

/area/station/security/prison/work
	name = "\improper Prison Work Room"
	icon_state = "prison_work"

/area/station/security/prison/shower
	name = "\improper Prison Shower"
	icon_state = "prison_shower"

/area/station/security/prison/workout
	name = "\improper Prison Gym"
	icon_state = "prison_workout"

/area/station/security/prison/garden
	name = "\improper Prison Garden"
	icon_state = "prison_garden"

/area/station/security/processing
	name = "\improper Labor Shuttle Dock"
	icon_state = "sec_processing"

/area/station/security/processing/cremation
	name = "\improper Security Crematorium"
	icon_state = "sec_cremation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/interrogation
	name = "\improper Interrogation Room"
	icon_state = "interrogation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/warden
	name = "Brig Control"
	icon_state = "warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/detectives_office
	name = "\improper Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg','sound/ambience/ambidet2.ogg')

/area/station/security/detectives_office/private_investigators_office
	name = "\improper Private Investigator's Office"
	icon_state = "investigate_office"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"

/area/station/security/execution
	icon_state = "execution_room"

/area/station/security/execution/transfer
	name = "\improper Transfer Centre"
	icon_state = "sec_processing"

/area/station/security/execution/education
	name = "\improper Prisoner Education Chamber"

/area/station/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint"

/area/station/security/checkpoint/auxiliary
	icon_state = "checkpoint_aux"

/area/station/security/checkpoint/escape
	icon_state = "checkpoint_esc"

/area/station/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint_supp"

/area/station/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint_engi"

/area/station/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint_med"

/area/station/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint_sci"

/area/station/security/checkpoint/science/research
	name = "Security Post - Research Division"
	icon_state = "checkpoint_res"

/area/station/security/checkpoint/customs
	name = "Customs"
	icon_state = "customs_point"

/area/station/security/checkpoint/customs/auxiliary
	name = "Auxiliary Customs"
	icon_state = "customs_point_aux"

/area/station/security/checkpoint/customs/fore
	name = "Fore Customs"
	icon_state = "customs_point_fore"

/area/station/security/checkpoint/customs/aft
	name = "Aft Customs"
	icon_state = "customs_point_aft"

//Cargo

/area/station/cargo
	name = "Quartermasters"
	icon_state = "quart"
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/cargo/sorting
	name = "\improper Delivery Office"
	icon_state = "cargo_delivery"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/cargo/warehouse
	name = "\improper Warehouse"
	icon_state = "cargo_warehouse"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/cargo/drone_bay
	name = "\improper Drone Bay"
	icon_state = "cargo_drone"

/area/station/cargo/warehouse/upper
	name = "\improper Upper Warehouse"

/area/station/cargo/office
	name = "\improper Cargo Office"
	icon_state = "cargo_office"

/area/station/cargo/storage
	name = "\improper Cargo Bay"
	icon_state = "cargo_bay"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/cargo/lobby
	name = "\improper Cargo Lobby"
	icon_state = "cargo_lobby"

/area/station/cargo/qm
	name = "\improper Quartermaster's Office"
	icon_state = "quart_office"

/area/station/cargo/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining_dock"

/area/station/cargo/miningdock/cafeteria
	name = "\improper Mining Cafeteria"
	icon_state = "mining_cafe"

/area/station/cargo/miningdock/oresilo
	name = "\improper Mining Ore Silo Storage"
	icon_state = "mining_silo"

/area/station/cargo/miningoffice
	name = "\improper Mining Office"
	icon_state = "mining"

//Science

/area/station/science
	name = "\improper Science Division"
	icon_state = "science"
	airlock_wires = /datum/wires/airlock/science
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/science/lobby
	name = "\improper Science Lobby"
	icon_state = "science_lobby"

/area/station/science/lower
	name = "\improper Lower Science Division"
	icon_state = "lower_science"

/area/station/science/breakroom
	name = "\improper Science Break Room"
	icon_state = "science_breakroom"

/area/station/science/lab
	name = "Research and Development"
	icon_state = "research"

/area/station/science/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xenobio"

/area/station/science/xenobiology/hallway
	name = "\improper Xenobiology Hallway"
	icon_state = "xenobio_hall"

/area/station/science/cytology
	name = "\improper Cytology Lab"
	icon_state = "cytology"

/area/station/science/storage
	name = "Ordnance Storage"
	icon_state = "ord_storage"

/area/station/science/test_area
	name = "\improper Ordnance Test Area"
	icon_state = "ord_test"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/science/mixing
	name = "\improper Ordnance Mixing Lab"
	icon_state = "ord_mix"

/area/station/science/mixing/chamber
	name = "\improper Ordnance Mixing Chamber"
	icon_state = "ord_mix_chamber"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/science/mixing/hallway
	name = "\improper Ordnance Mixing Hallway"
	icon_state = "ord_mix_hallway"

/area/station/science/mixing/launch
	name = "\improper Ordnance Mixing Launch Site"
	icon_state = "ord_mix_launch"

/area/station/science/genetics
	name = "\improper Genetics Lab"
	icon_state = "geneticssci"

/area/station/science/misc_lab
	name = "\improper Testing Lab"
	icon_state = "ord_misc"

/area/station/science/misc_lab/range
	name = "\improper Research Testing Range"
	icon_state = "ord_range"

/area/station/science/server
	name = "\improper Research Division Server Room"
	icon_state = "server"

/area/station/science/explab
	name = "\improper Experimentation Lab"
	icon_state = "exp_lab"

/area/station/science/robotics
	name = "Robotics"
	icon_state = "robotics"

/area/station/science/robotics/mechbay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/station/science/robotics/lab
	name = "\improper Robotics Lab"
	icon_state = "ass_line"

/area/station/science/research
	name = "\improper Research Division"
	icon_state = "science"

/area/station/science/research/abandoned
	name = "\improper Abandoned Research Lab"
	icon_state = "abandoned_sci"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

// Telecommunications Satellite

/area/station/tcommsat
	icon_state = "tcomsatcham"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')
	airlock_wires = /datum/wires/airlock/engineering
	network_root_id = STATION_NETWORK_ROOT // They should of unpluged the router before they left

/area/station/tcommsat/computer
	name = "\improper Telecomms Control Room"
	icon_state = "tcomsatcomp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/tcommsat/server
	name = "\improper Telecomms Server Room"
	icon_state = "tcomsatcham"

/area/station/tcommsat/server/upper
	name = "\improper Upper Telecomms Server Room"

//Telecommunications - On Station

/area/station/comms
	name = "\improper Communications Relay"
	icon_state = "tcomsatcham"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/server
	name = "\improper Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

//External Hull Access
/area/station/maintenance/external
	name = "\improper External Hull Access"
	icon_state = "amaint"

/area/station/maintenance/external/aft
	name = "\improper Aft External Hull Access"

/area/station/maintenance/external/port
	name = "\improper Port External Hull Access"

/area/station/maintenance/external/port/bow
	name = "\improper Port Bow External Hull Access"
