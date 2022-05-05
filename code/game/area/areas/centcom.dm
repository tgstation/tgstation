
// CENTCOM

// Side note, be sure to change the network_root_id of any areas that are not a part of centcom
// and just using the z space as safe harbor.  It shouldn't matter much as centcom z is isolated
// from everything anyway

/area/centcom
	name = "CentCom"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "centcom"
	static_lighting = TRUE
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE

/area/centcom/control
	name = "CentCom Central Control"
	icon_state = "centcom_control"

/area/centcom/evacuation
	name = "CentCom Recovery Wing"
	icon_state = "centcom_evacuation"

/area/centcom/evacuation/ship
	name = "CentCom Recovery Ship"
	icon_state = "centcom_evacuation_ship"

/area/centcom/fore
	name = "Fore CentCom Dock"
	icon_state = "centcom_fore"

/area/centcom/supply
	name = "CentCom Supply Wing"
	icon_state = "centcom_supply"

/area/centcom/ferry
	name = "CentCom Transport Shuttle Dock"
	icon_state = "centcom_ferry"

/area/centcom/briefing
	name = "CentCom Briefing Room"
	icon_state = "centcom_briefing"

/area/centcom/armory
	name = "CentCom Armory"
	icon_state = "centcom_armory"

/area/centcom/admin
	name = "CentCom Administrative Office"
	icon_state = "centcom_admin"

/area/centcom/admin/storage
	name = "CentCom Administrative Office Storage"
	icon_state = "centcom_admin_storage"

/area/centcom/prison
	name = "Admin Prison"
	icon_state = "centcom_prison"

/area/centcom/prison/cells
	name = "Admin Prison Cells"
	icon_state = "centcom_cells"

/area/centcom/courtroom
	name = "Nanotrasen Grand Courtroom"
	icon_state = "centcom_court"

/area/centcom/holding
	name = "Holding Facility"
	icon_state = "centcom_holding"

/area/centcom/supplypod/supplypod_temp_holding
	name = "Supplypod Shipping Lane"
	icon_state = "supplypod_flight"

/area/centcom/supplypod
	name = "Supplypod Facility"
	icon_state = "supplypod"
	static_lighting = FALSE

	base_lighting_alpha = 255

/area/centcom/supplypod/pod_storage
	name = "Supplypod Storage"
	icon_state = "supplypod_holding"

/area/centcom/supplypod/loading
	name = "Supplypod Loading Facility"
	icon_state = "supplypod_loading"
	var/loading_id = ""

/area/centcom/supplypod/loading/Initialize(mapload)
	. = ..()
	if(!loading_id)
		CRASH("[type] created without a loading_id")
	if(GLOB.supplypod_loading_bays[loading_id])
		CRASH("Duplicate loading bay area: [type] ([loading_id])")
	GLOB.supplypod_loading_bays[loading_id] = src

/area/centcom/supplypod/loading/one
	name = "Bay #1"
	loading_id = "1"

/area/centcom/supplypod/loading/two
	name = "Bay #2"
	loading_id = "2"

/area/centcom/supplypod/loading/three
	name = "Bay #3"
	loading_id = "3"

/area/centcom/supplypod/loading/four
	name = "Bay #4"
	loading_id = "4"

/area/centcom/supplypod/loading/ert
	name = "ERT Bay"
	loading_id = "5"
//THUNDERDOME

/area/tdome
	name = "Thunderdome"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "thunder"
	static_lighting = TRUE
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE

/area/tdome/arena
	name = "Thunderdome Arena"
	icon_state = "thunder"
	static_lighting = FALSE
	base_lighting_alpha = 255


/area/tdome/arena_source
	name = "Thunderdome Arena Template"
	icon_state = "thunder"
	static_lighting = FALSE
	base_lighting_alpha = 255


/area/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "thunder_team_one"

/area/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "thunder_team_two"

/area/tdome/administration
	name = "Thunderdome Administration"
	icon_state = "thunder_admin"

/area/tdome/observation
	name = "Thunderdome Observation"
	icon_state = "thunder_observe"


//ENEMY

//Wizard
/area/wizard_station
	name = "Wizard's Den"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "wizards_den"
	static_lighting = TRUE
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE
	network_root_id = "MAGIC_NET"

//Abductors
/area/abductor_ship
	name = "Abductor Ship"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "abductor_ship"
	requires_power = FALSE
	area_flags = UNIQUE_AREA | NOTELEPORT
	static_lighting = FALSE
	base_lighting_alpha = 255
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	network_root_id = "ALIENS"

//Syndicates
/area/syndicate_mothership
	name = "Syndicate Mothership"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "syndie-ship"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE
	ambience_index = AMBIENCE_DANGER
	network_root_id = SYNDICATE_NETWORK_ROOT

/area/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"
	static_lighting = TRUE

/area/syndicate_mothership/expansion_bombthreat
	name = "Syndicate Ordnance Laboratory"
	icon_state = "syndie-elite"
	static_lighting = TRUE
	ambience_index = AMBIENCE_ENGI

/area/syndicate_mothership/expansion_bioterrorism
	name = "Syndicate Bio-Weapon Laboratory"
	icon_state = "syndie-elite"
	static_lighting = TRUE
	ambience_index = AMBIENCE_MEDICAL

/area/syndicate_mothership/expansion_chemicalwarfare
	name = "Syndicate Chemical Weapon Manufacturing Plant"
	icon_state = "syndie-elite"
	static_lighting = TRUE
	ambience_index = AMBIENCE_REEBE

/area/syndicate_mothership/expansion_fridgerummage
	name = "Syndicate Perishables and Foodstuffs Storage"
	icon_state = "syndie-elite"
	static_lighting = TRUE

/area/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"

//CAPTURE THE FLAG

/area/ctf
	name = "Capture the Flag"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "ctf"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE

/area/ctf/control_room
	name = "Control Room A"
	icon_state = "ctf_room_a"

/area/ctf/control_room2
	name = "Control Room B"
	icon_state = "ctf_room_b"

/area/ctf/central
	name = "Central"
	icon_state = "central"

/area/ctf/main_hall
	name = "Main Hall A"
	icon_state = "ctf_hall_a"

/area/ctf/main_hall2
	name = "Main Hall B"
	icon_state = "ctf_hall_b"

/area/ctf/corridor
	name = "Corridor A"
	icon_state = "ctf_corr_a"

/area/ctf/corridor2
	name = "Corridor B"
	icon_state = "ctf_corr_b"

/area/ctf/flag_room
	name = "Flag Room A"
	icon_state = "ctf_flag_a"

/area/ctf/flag_room2
	name = "Flag Room B"
	icon_state = "ctf_flag_b"
