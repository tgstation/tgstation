ADMIN_VERB(jump_to_area, R_ADMIN, "Jump To Area", "Jumps to the specified area.", ADMIN_CATEGORY_GAME, area/target in get_sorted_areas())
	var/turf/drop_location
	top_level:
		for(var/list/zlevel_turfs as anything in target.get_zlevel_turf_lists())
			for(var/turf/area_turf as anything in zlevel_turfs)
				if(area_turf.density)
					continue
				drop_location = area_turf
				break top_level

	if(isnull(drop_location))
		to_chat(user, span_warning("No valid drop location found in the area!"))
		return

	user.mob.abstract_move(drop_location)
	log_admin("[key_name(user)] jumped to [AREACOORD(drop_location)]")
	message_admins("[key_name_admin(user)] jumped to [AREACOORD(drop_location)]")
	BLACKBOX_LOG_ADMIN_VERB("Jump To Area")

ADMIN_VERB_AND_CONTEXT_MENU(jump_to_turf, R_ADMIN, "Jump To Turf", "Jump to any turf in the game. This will lag your client.", ADMIN_CATEGORY_GAME, turf/locale in world)
	log_admin("[key_name(user)] jumped to [AREACOORD(locale)]")
	message_admins("[key_name_admin(user)] jumped to [AREACOORD(locale)]")
	user.mob.abstract_move(locale)
	BLACKBOX_LOG_ADMIN_VERB("Jump To Turf")

ADMIN_VERB_AND_CONTEXT_MENU(jump_to_mob, R_ADMIN, "Jump To Mob", "Jump to any mob in the game.", ADMIN_CATEGORY_GAME, mob/target in world)
	user.mob.abstract_move(target.loc)
	log_admin("[key_name(user)] jumped to [key_name(target)]")
	message_admins("[key_name_admin(user)] jumped to [ADMIN_LOOKUPFLW(target)] at [AREACOORD(target)]")
	BLACKBOX_LOG_ADMIN_VERB("Jump To Mob")

ADMIN_VERB(jump_to_coord, R_ADMIN, "Jump To Coordinate", "Jump to a specific coordinate in the game world.", ADMIN_CATEGORY_GAME, cx as num, cy as num, cz as num)
	var/turf/where_we_droppin = locate(cx, cy, cz)
	if(isnull(where_we_droppin))
		to_chat(user, span_warning("Invalid coordinates."))
		return

	user.mob.abstract_move(where_we_droppin)
	message_admins("[key_name_admin(user)] jumped to coordinates [cx], [cy], [cz]")
	BLACKBOX_LOG_ADMIN_VERB("Jump To Coordiate")

ADMIN_VERB(jump_to_key, R_ADMIN, "Jump To Key", "Jump to a specific player.", ADMIN_CATEGORY_GAME)
	if(!isobserver(user.mob))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/client/selection = input(user, "Please, select a player!", "Admin Jumping") as null|anything in sort_key(keys)
	if(!selection)
		to_chat(user, "No keys found.", confidential = TRUE)
		return
	var/mob/M = selection.mob
	log_admin("[key_name(user)] jumped to [key_name(M)]")
	message_admins("[key_name_admin(user)] jumped to [ADMIN_LOOKUPFLW(M)]")
	user.mob.abstract_move(M.loc)
	BLACKBOX_LOG_ADMIN_VERB("Jump To Key")

ADMIN_VERB_AND_CONTEXT_MENU(get_mob, R_ADMIN, "Get Mob", "Teleport a mob to your location.", ADMIN_CATEGORY_GAME, mob/target in world)
	var/atom/loc = get_turf(user.mob)
	target.admin_teleport(loc)
	BLACKBOX_LOG_ADMIN_VERB("Get Mob")

/// Proc to hook user-enacted teleporting behavior and keep logging of the event.
/atom/movable/proc/admin_teleport(atom/new_location)
	if(isnull(new_location))
		log_admin("[key_name(usr)] teleported [key_name(src)] to nullspace")
		moveToNullspace()
	else
		var/turf/location = get_turf(new_location)
		log_admin("[key_name(usr)] teleported [key_name(src)] to [AREACOORD(location)]")
		forceMove(new_location)

/mob/admin_teleport(atom/new_location)
	var/turf/location = get_turf(new_location)
	var/msg = "[key_name_admin(usr)] teleported [ADMIN_LOOKUPFLW(src)] to [isnull(new_location) ? "nullspace" : ADMIN_VERBOSEJMP(location)]"
	message_admins(msg)
	admin_ticket_log(src, msg)
	return ..()

ADMIN_VERB(get_key, R_ADMIN, "Get Key", "Teleport the player with the provided key to you.", ADMIN_CATEGORY_GAME)
	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/client/selection = input(user, "Please, select a player!", "Admin Jumping") as null|anything in sort_key(keys)
	if(!selection)
		return
	var/mob/M = selection.mob

	if(!M)
		return
	log_admin("[key_name(user)] teleported [key_name(M)]")
	var/msg = "[key_name_admin(user)] teleported [ADMIN_LOOKUPFLW(M)]"
	message_admins(msg)
	admin_ticket_log(M, msg)
	if(M)
		M.forceMove(get_turf(user))
		BLACKBOX_LOG_ADMIN_VERB("Get Key")

ADMIN_VERB_AND_CONTEXT_MENU(send_mob, R_ADMIN, "Send Mob", "Teleport the specified mob to an area of your choosing.", ADMIN_CATEGORY_GAME, mob/jumper)
	var/list/sorted_areas = get_sorted_areas()
	if(!length(sorted_areas))
		to_chat(user, "No areas found.", confidential = TRUE)
		return
	var/area/target_area = tgui_input_list(user, "Pick an area", "Send Mob", sorted_areas)
	if(isnull(target_area))
		return
	if(!istype(target_area))
		return
	var/list/turfs = get_area_turfs(target_area)
	if(length(turfs) && jumper.forceMove(pick(turfs)))
		log_admin("[key_name(user)] teleported [key_name(jumper)] to [AREACOORD(jumper)]")
		var/msg = "[key_name_admin(user)] teleported [ADMIN_LOOKUPFLW(jumper)] to [AREACOORD(jumper)]"
		message_admins(msg)
		admin_ticket_log(jumper, msg)
	else
		to_chat(user, "Failed to move mob to a valid location.", confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Send Mob")
