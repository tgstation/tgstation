/datum/round_event_control/blob
	name = "Blob"
	typepath = /datum/round_event/ghost_role/blob
	weight = 10
	max_occurrences = 1

	min_players = 20

	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a new blob overmind."

/datum/round_event_control/blob/can_spawn_event(players, allow_magic = FALSE)
	if(EMERGENCY_PAST_POINT_OF_NO_RETURN) // no blobs if the shuttle is past the point of no return
		return FALSE

	return ..()

/datum/round_event/ghost_role/blob
	announce_chance = 0
	role_name = "blob overmind"
	fakeable = TRUE

/datum/round_event/ghost_role/blob/announce(fake)
	if(!fake)
		return //the mob itself handles this.
	priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK5)

/datum/round_event/ghost_role/blob/spawn_role()
	if(!GLOB.blobstart.len)
		return MAP_ERROR
	var/icon/blob_icon = icon('icons/mob/nonhuman-player/blob.dmi', icon_state = "blob_core")
	blob_icon.Blend("#9ACD32", ICON_MULTIPLY)
	blob_icon.Blend(icon('icons/mob/nonhuman-player/blob.dmi', "blob_core_overlay"), ICON_OVERLAY)
	var/image/blob_image = image(blob_icon)
	var/mob/chosen_one = SSpolling.poll_ghost_candidates(check_jobban = ROLE_BLOB, role = ROLE_BLOB, alert_pic = blob_image, role_name_text = role_name, amount_to_pick = 1, chat_text_border_icon = blob_image)
	if(isnull(chosen_one))
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/new_blob = chosen_one
	var/mob/eye/blob/BC = new_blob.become_overmind()
	spawned_mobs += BC
	message_admins("[ADMIN_LOOKUPFLW(BC)] has been made into a blob overmind by an event.")
	BC.log_message("was spawned as a blob overmind by an event.", LOG_GAME)
	return SUCCESSFUL_SPAWN
