/client/proc/Jump(var/area/A in world)
	set name = "Jump to Area"
	set desc = "Area to jump to"
	set category = "Admin"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	if(config.allow_admin_jump)
		usr.loc = pick(get_area_turfs(A))

		log_admin("[key_name(usr)] jumped to [A]")
		message_admins("[key_name_admin(usr)] jumped to [A]", 1)
	else
		alert("Admin jumping disabled")

/client/proc/jumptoturf(var/turf/T in world)
	set name = "Jump to Turf"
	set category = "Admin"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(config.allow_admin_jump)
		log_admin("[key_name(usr)] jumped to [T.x],[T.y],[T.z] in [T.loc]")
		message_admins("[key_name_admin(usr)] jumped to [T.x],[T.y],[T.z] in [T.loc]", 1)
		usr.loc = T
	else
		alert("Admin jumping disabled")
	return

/client/proc/jumptomob(var/mob/M in world)
	set category = "Admin"
	set name = "Jump to Mob"

	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	if(config.allow_admin_jump)
		log_admin("[key_name(usr)] jumped to [key_name(M)]")
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]", 1)
		usr.loc = get_turf(M)
	else
		alert("Admin jumping disabled")

/client/proc/jumptokey()
	set category = "Admin"
	set name = "Jump to Key"

	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	if(config.allow_admin_jump)
		var/list/keys = list()
		for(var/mob/M in world)
			keys += M.client
		var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in keys
		if(!selection)
			return
		var/mob/M = selection:mob
		log_admin("[key_name(usr)] jumped to [key_name(M)]")
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]", 1)
		usr.loc = M.loc
	else
		alert("Admin jumping disabled")

/client/proc/Getmob(var/mob/M in world)
	set category = "Admin"
	set name = "Get Mob"
	set desc = "Mob to teleport"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(config.allow_admin_jump)
		log_admin("[key_name(usr)] teleported [key_name(M)]")
		message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)]", 1)
		M.loc = get_turf(usr)
	else
		alert("Admin jumping disabled")

/client/proc/sendmob(var/mob/M in world, var/area/A in world)
	set category = "Admin"
	set name = "Send Mob"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(config.allow_admin_jump)
		M.loc = pick(get_area_turfs(A))

		log_admin("[key_name(usr)] teleported [key_name(M)] to [A]")
		message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)] to [A]", 1)
	else
		alert("Admin jumping disabled")