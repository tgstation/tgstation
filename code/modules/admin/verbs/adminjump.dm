ADMIN_VERB(jumpto_area, "Jump To Area", "", R_ADMIN, VERB_CATEGORY_GAME, area/target in get_sorted_areas())
	var/turf/jump_turf = target.get_contained_turfs()[1]
	user.mob.forceMove(jump_turf)
	log_admin("[key_name(user)] jumped to [AREACOORD(jump_turf)]")
	message_admins("[key_name_admin(user)] jumped to [AREACOORD(jump_turf)]")

ADMIN_VERB(jumpto_turf, "Jump to Turf", "This can cause your client to freeze for a moment!", R_ADMIN, VERB_CATEGORY_GAME, turf/target in world)
	log_admin("[key_name(user)] jumped to [AREACOORD(target)]")
	message_admins("[key_name_admin(user)] jumped to [AREACOORD(target)]")
	user.mob.forceMove(target)

ADMIN_VERB(jumpto_mob, "Jump to Mob", "", R_ADMIN, VERB_CATEGORY_GAME, mob/target in world)
	log_admin("[key_name(user)] jumped to [key_name(target)]")
	message_admins("[key_name_admin(user)] jumped to [ADMIN_LOOKUPFLW(target)] at [AREACOORD(target)]")
	user.mob.forceMove(target.loc)

ADMIN_VERB(jumpto_coord, "Jump to Coordinate", "", R_ADMIN, VERB_CATEGORY_GAME, x as num, y as num, z as num)
	var/turf/target = locate(x, y, z)
	if(!target)
		to_chat(user, "Invalid coordinates.")
		return

	log_admin("[key_name(user)] jumped to [AREACOORD(target)]")
	message_admins("[key_name_admin(user)] jumped to [AREACOORD(target)]")
	user.mob.forceMove(target)

ADMIN_VERB(jumpto_key, "Jump to Key", "", R_ADMIN, VERB_CATEGORY_GAME)
	var/choice = tgui_input_list(user, "Select a key to jump to.", "Jump to Key", sort_key(GLOB.directory.Copy()))
	if(!choice)
		return

	var/client/selected = GLOB.directory[choice]
	log_admin("[key_name(user)] jumped to [key_name(selected)]")
	message_admins("[key_name_admin(user)] jumped to [ADMIN_LOOKUPFLW(selected.mob)]")
	user.mob.forceMove(selected.mob.loc)

ADMIN_VERB(get_mob, "Get Mob", "", R_ADMIN, VERB_CATEGORY_GAME, mob/target in world)
	var/atom/loc = get_turf(user.mob)
	target.admin_teleport(loc)

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

ADMIN_VERB(get_key, "Get Key", "", R_ADMIN, VERB_CATEGORY_GAME)
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
		user.mob.forceMove(M.loc)

/client/proc/sendmob(mob/jumper in sort_mobs())
	set category = "Admin.Game"
	set name = "Send Mob"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return
	var/list/sorted_areas = get_sorted_areas()
	if(!length(sorted_areas))
		to_chat(src, "No areas found.", confidential = TRUE)
		return
	var/area/target_area = tgui_input_list(src, "Pick an area", "Send Mob", sorted_areas)
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
		to_chat(src, "Failed to move mob to a valid location.", confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Send Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
