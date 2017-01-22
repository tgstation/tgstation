var/datum/subsystem/globalvars/SSGlobalVars

/datum/subsystem/globalvars
	name = "Global Variables"
	can_fire = FALSE
	var/global_emote_list
	var/global_objects_portal_list
	var/global_objects_datacore
	var/global_objects_mech_list
	var/global_objects_telebeacon_list
	var/global_objects_navbeacon_list
	var/global_objects_commsconsole_list
	var/global_objects_chemical_reactions
	var/global_objects_chemicals
	var/global_objects_crafting_recipes
	var/global_objects_rcd_list
	var/global_objects_mulebot_beacons
	var/global_objects_mulebot_tags
	var/global_objects_chem_implants
	var/global_objects_track_implants
	var/global_objects_pointofinterest_list
	var/global_mapping_landmarks
	var/global_mapping_landmarks_ruins
	var/global_mapping_landmarks_awaystart
	var/global_mapping_globalmap
	var/global_mapping_spawns
	var/global_mapping_spawns_depsec
	var/global_mapping_spawns_events
	var/global_mapping_spawns_latejoin
	var/global_ntnet
	var/global_uplinks
	var/global_maploader
	var/global_adminsound

/datum/subsystem/globalvars/New()
	NEW_SS_GLOBAL(SSGlobalVars)

/datum/subsystem/globalvars/Initialize()
	global_emote_list = emote_list
	global_objects_portal_list = portals
	global_objects_datacore = data_core
	global_objects_mech_list = mechas_list
	global_objects_telebeacon_list = teleportbeacons
	global_objects_navbeacon_list = navbeacons
	global_objects_commsconsole_list = shuttle_caller_list
	global_objects_chemical_reactions = chemical_reactions_list
	global_objects_chemicals = chemical_reagents_list
	global_objects_crafting_recipes = crafting_recipes
	global_objects_rcd_list = rcd_list
	global_objects_mulebot_beacons = deliverybeacons
	global_objects_mulebot_tags = deliverybeacontags
	global_objects_chem_implants = tracked_chem_implants
	global_objects_track_implants = tracked_implants
	global_objects_pointofinterest_list = poi_list
	global_mapping_landmarks = landmarks_list
	global_mapping_landmarks_ruins = ruin_landmarks
	global_mapping_landmarks_awaystart = awaydestinations
	global_mapping_globalmap = global_map
	global_mapping_spawns = start_landmarks_list
	global_mapping_spawns_depsec = department_security_spawns
	global_mapping_spawns_events = generic_event_spawns
	global_mapping_spawns_latejoin = latejoin
	global_ntnet = ntnet_global
	global_uplinks = uplinks
	global_maploader = maploader
	global_adminsound = admin_sound
