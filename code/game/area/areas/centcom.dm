
// CENTCOM
// CentCom itself
/area/centcom
	name = "CentCom"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "centcom"
	static_lighting = TRUE
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE

// This is just to define the category
/area/centcom/central_command_areas
	name = "Central Command Areas"

/area/centcom/central_command_areas/control
	name = "CentCom Central Control"
	icon_state = "centcom_control"

/area/centcom/central_command_areas/evacuation
	name = "CentCom Recovery Wing"
	icon_state = "centcom_evacuation"

/area/centcom/central_command_areas/evacuation/ship
	name = "CentCom Recovery Ship"
	icon_state = "centcom_evacuation_ship"

/area/centcom/central_command_areas/fore
	name = "Fore CentCom Dock"
	icon_state = "centcom_fore"

/area/centcom/central_command_areas/supply
	name = "CentCom Supply Wing"
	icon_state = "centcom_supply"

/area/centcom/central_command_areas/ferry
	name = "CentCom Transport Shuttle Dock"
	icon_state = "centcom_ferry"

/area/centcom/central_command_areas/briefing
	name = "CentCom Briefing Room"
	icon_state = "centcom_briefing"

/area/centcom/central_command_areas/armory
	name = "CentCom Armory"
	icon_state = "centcom_armory"

/area/centcom/central_command_areas/admin
	name = "CentCom Administrative Office"
	icon_state = "centcom_admin"

/area/centcom/central_command_areas/admin/storage
	name = "CentCom Administrative Office Storage"
	icon_state = "centcom_admin_storage"

/area/centcom/central_command_areas/prison
	name = "Admin Prison"
	icon_state = "centcom_prison"

/area/centcom/central_command_areas/prison/cells
	name = "Admin Prison Cells"
	icon_state = "centcom_cells"

/area/centcom/central_command_areas/courtroom
	name = "Nanotrasen Grand Courtroom"
	icon_state = "centcom_court"

/area/centcom/central_command_areas/holding
	name = "Holding Facility"
	icon_state = "centcom_holding"

/area/centcom/central_command_areas/supplypod/supplypod_temp_holding
	name = "Supplypod Shipping Lane"
	icon_state = "supplypod_flight"

/area/centcom/central_command_areas/supplypod
	name = "Supplypod Facility"
	icon_state = "supplypod"

/area/centcom/central_command_areas/supplypod/pod_storage
	name = "Supplypod Storage"
	icon_state = "supplypod_holding"

/area/centcom/central_command_areas/supplypod/loading
	name = "Supplypod Loading Facility"
	icon_state = "supplypod_loading"
	var/loading_id = ""

/area/centcom/central_command_areas/supplypod/loading/Initialize(mapload)
	. = ..()
	if(!loading_id)
		CRASH("[type] created without a loading_id")
	if(GLOB.supplypod_loading_bays[loading_id])
		CRASH("Duplicate loading bay area: [type] ([loading_id])")
	GLOB.supplypod_loading_bays[loading_id] = src

/area/centcom/central_command_areas/supplypod/loading/one
	name = "Bay #1"
	loading_id = "1"

/area/centcom/central_command_areas/supplypod/loading/two
	name = "Bay #2"
	loading_id = "2"

/area/centcom/central_command_areas/supplypod/loading/three
	name = "Bay #3"
	loading_id = "3"

/area/centcom/central_command_areas/supplypod/loading/four
	name = "Bay #4"
	loading_id = "4"

/area/centcom/central_command_areas/supplypod/loading/ert
	name = "ERT Bay"
	loading_id = "5"

//THUNDERDOME
/area/centcom/tdome
	name = "Thunderdome"
	icon_state = "thunder"

/area/centcom/tdome/arena
	name = "Thunderdome Arena"
	icon_state = "thunder"
	area_flags = parent_type::area_flags | UNLIMITED_FISHING //for possible testing purposes

/area/centcom/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "thunder_team_one"

/area/centcom/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "thunder_team_two"

/area/centcom/tdome/administration
	name = "Thunderdome Administration"
	icon_state = "thunder_admin"

/area/centcom/tdome/observation
	name = "Thunderdome Observation"
	icon_state = "thunder_observe"


// ENEMY

// Wizard
/area/centcom/wizard_station
	name = "Wizard's Den"
	icon_state = "wizards_den"
	static_lighting = TRUE
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE


//Abductors
/area/centcom/abductor_ship
	name = "Abductor Ship"
	icon_state = "abductor_ship"
	requires_power = FALSE
	area_flags = UNIQUE_AREA | NOTELEPORT
	static_lighting = FALSE
	base_lighting_alpha = 255
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE

//Syndicates
/area/centcom/syndicate_mothership
	name = "Syndicate Mothership"
	icon_state = "syndie-ship"
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE
	ambience_index = AMBIENCE_DANGER

/area/centcom/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"
	static_lighting = TRUE

/area/centcom/syndicate_mothership/expansion_bombthreat
	name = "Syndicate Ordnance Laboratory"
	icon_state = "syndie-elite"
	static_lighting = TRUE
	ambience_index = AMBIENCE_ENGI

/area/centcom/syndicate_mothership/expansion_bioterrorism
	name = "Syndicate Bio-Weapon Laboratory"
	icon_state = "syndie-elite"
	static_lighting = TRUE
	ambience_index = AMBIENCE_MEDICAL

/area/centcom/syndicate_mothership/expansion_chemicalwarfare
	name = "Syndicate Chemical Weapon Manufacturing Plant"
	icon_state = "syndie-elite"
	static_lighting = TRUE
	ambience_index = AMBIENCE_REEBE

/area/centcom/syndicate_mothership/expansion_fridgerummage
	name = "Syndicate Perishables and Foodstuffs Storage"
	icon_state = "syndie-elite"
	static_lighting = TRUE

/area/centcom/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"

/area/centcom/syndicate_mothership/expansion_custodialcloset
	name = "Syndicate Custodial Closet"
	icon_state = "syndie-elite"

//MAFIA
/area/centcom/mafia
	name = "Mafia Minigame"
	icon_state = "mafia"
	static_lighting = FALSE

	base_lighting_alpha = 255
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = BLOCK_SUICIDE | UNIQUE_AREA

//CAPTURE THE FLAG
/area/centcom/ctf
	name = "Capture the Flag"
	icon_state = "ctf"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = UNIQUE_AREA | NOTELEPORT | NO_DEATH_MESSAGE | BLOCK_SUICIDE

/area/centcom/ctf/control_room
	name = "Control Room A"
	icon_state = "ctf_room_a"

/area/centcom/ctf/control_room2
	name = "Control Room B"
	icon_state = "ctf_room_b"

/area/centcom/ctf/central
	name = "Central"
	icon_state = "ctf_central"

/area/centcom/ctf/main_hall
	name = "Main Hall A"
	icon_state = "ctf_hall_a"

/area/centcom/ctf/main_hall2
	name = "Main Hall B"
	icon_state = "ctf_hall_b"

/area/centcom/ctf/corridor
	name = "Corridor A"
	icon_state = "ctf_corr_a"

/area/centcom/ctf/corridor2
	name = "Corridor B"
	icon_state = "ctf_corr_b"

/area/centcom/ctf/flag_room
	name = "Flag Room A"
	icon_state = "ctf_flag_a"

/area/centcom/ctf/flag_room2
	name = "Flag Room B"
	icon_state = "ctf_flag_b"

// Asteroid area stuff
/area/centcom/asteroid
	name = "\improper Asteroid"
	icon_state = "asteroid"
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA
	ambience_index = AMBIENCE_MINING
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_ASTEROID

/area/centcom/asteroid/nearstation
	static_lighting = TRUE
	ambience_index = AMBIENCE_RUINS
	always_unpowered = FALSE
	requires_power = TRUE
	area_flags = UNIQUE_AREA | BLOBS_ALLOWED

/area/centcom/asteroid/nearstation/bomb_site
	name = "\improper Bomb Testing Asteroid"
