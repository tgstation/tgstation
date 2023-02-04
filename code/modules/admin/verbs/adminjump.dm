ADMIN_VERB(game, jump_to_area, "Jump to the specified area", NONE, area/destination in world)
	var/turf/point

	for(var/turf/turf as anything in destination.get_contained_turfs())
		if(turf.density)
			continue
		point = turf

	if(!point)
		to_chat(usr, span_warning("No turf to jump to!"))
		return

	usr.forceMove(point)
	log_admin("[key_name(usr)] jumped to [AREACOORD(point)]")
	key_name_admin("[key_name(usr)] jumped to [AREACOORD(point)]")

ADMIN_VERB(game, jump_to_turf, "", NONE, turf/destination in world)
	usr.forceMove(destination)
	log_admin("[key_name(usr)] jumped to [AREACOORD(destination)]")
	key_name_admin("[key_name(usr)] jumped to [AREACOORD(destination)]")

ADMIN_VERB(game, jump_to_mob, "", NONE, mob/destination)
	destination ||= tgui_input_list(usr, "Select a mob to teleport to you", "Admin Jump", GLOB.mob_list - usr)
	if(!destination)
		return

	usr.forceMove(get_turf(destination))
	log_admin("[key_name(usr)] jumped to [key_name(destination)]")
	message_admins("[key_name_admin(usr)] jumped to [ADMIN_LOOKUPFLW(destination)] at [AREACOORD(destination)]")

ADMIN_VERB(game, jump_to_coordinate, "", NONE, x as num, y as num, z as num)
	if(x < 1 || y < 1 || z < 1 || x > world.maxx || y > world.maxy || z > world.maxz)
		to_chat(usr, span_warning("Invaild coordinates"))
		return

	var/turf/destination = locate(x, y, z)
	usr.forceMove(destination)
	log_admin("[key_name(usr)] jumped to [AREACOORD(destination)]")
	message_admins("[key_name_admin(usr)] jumped to [AREACOORD(destination)]")

ADMIN_VERB(game, jump_to_player, "", NONE)
	var/list/players = list()
	for(var/client/player as anything in GLOB.clients)
		players[key_name(player)] = WEAKREF(player.mob)

	var/player = tgui_input_list(usr, "Select a player", "Admin Jump", players)
	var/datum/weakref/player_ref = players[player]
	var/mob/chosen_mob = player_ref.resolve()
	if(!chosen_mob)
		to_chat(usr, span_warning("That mob no longer exists!"))
		return

	usr.forceMove(get_turf(chosen_mob))
	log_admin("[key_name(usr)] jumped to player [key_name(usr)]")
	message_admins("[key_name_admin(usr)] jumped to player [key_name_admin(usr)]")

ADMIN_VERB(game, get_mob, "", NONE, mob/teleportee)
	teleportee ||= tgui_input_list(usr, "Select a mob to teleport to you", "Admin Jump", GLOB.mob_list - usr)
	if(!teleportee)
		return

	var/turf/destination = get_turf(usr)
	teleportee.admin_teleport(destination)

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

ADMIN_VERB(game, get_player, "", NONE)
	var/list/players = list()
	for(var/client/player as anything in GLOB.clients)
		players[key_name(player)] = WEAKREF(player.mob)

	var/player = tgui_input_list(usr, "Select a player", "Admin Jump", players)
	var/datum/weakref/player_ref = players[player]
	var/mob/chosen_mob = player_ref.resolve()
	if(!chosen_mob)
		to_chat(usr, span_warning("That mob no longer exists!"))
		return

	chosen_mob.admin_teleport(get_turf(usr))

ADMIN_CONTEXT_ENTRY(context_sendmob, "Send Mob", NONE, mob/jumper in world)
	var/list/sorted_areas = get_sorted_areas()
	if(!length(sorted_areas))
		to_chat(usr, "No areas found.", confidential = TRUE)
		return
	var/area/target_area = tgui_input_list(usr, "Pick an area", "Send Mob", sorted_areas)
	if(isnull(target_area))
		return
	if(!istype(target_area))
		return
	var/list/turfs = get_area_turfs(target_area)
	if(length(turfs) && jumper.forceMove(pick(turfs)))
		log_admin("[key_name(usr)] teleported [key_name(jumper)] to [AREACOORD(jumper)]")
		var/msg = "[key_name_admin(usr)] teleported [ADMIN_LOOKUPFLW(jumper)] to [AREACOORD(jumper)]"
		message_admins(msg)
		admin_ticket_log(jumper, msg)
	else
		to_chat(usr, "Failed to move mob to a valid location.", confidential = TRUE)
