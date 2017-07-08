/datum/round_event_control/blob
	name = "Blob"
	typepath = /datum/round_event/ghost_role/blob
	weight = 5
	max_occurrences = 1

	min_players = 20
	earliest_start = 18000 //30 minutes

	gamemode_blacklist = list("blob") //Just in case a blob survives that long

/datum/round_event/ghost_role/blob
	announceWhen	= 12
	role_name = "blob overmind"
	var/new_rate = 2

/datum/round_event/ghost_role/blob/New(my_processing = TRUE, set_point_rate)
	..()
	if(set_point_rate)
		new_rate = set_point_rate

/datum/round_event/ghost_role/blob/announce()
	priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/ai/outbreak5.ogg')


/datum/round_event/ghost_role/blob/spawn_role()
	if(!GLOB.blobstart.len)
		return MAP_ERROR
	var/list/candidates = get_candidates("blob", null, ROLE_BLOB)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/new_blob = pick(candidates)
	var/obj/structure/blob/core/BC = new/obj/structure/blob/core(pick(GLOB.blobstart), new_blob.client, new_rate)
	BC.overmind.blob_points = min(20 + GLOB.player_list.len, BC.overmind.max_blob_points)
	spawned_mobs += BC.overmind
	message_admins("[key_name_admin(BC.overmind)] has been made into a blob overmind by an event.")
	log_game("[key_name(BC.overmind)] was spawned as a blob overmind by an event.")
	return SUCCESSFUL_SPAWN
