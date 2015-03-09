/client/proc/jumptoarea(area/A in sortedAreas)
	set name = "Jump to Area"
	set desc = "Area to jump to"
	set category = "Admin"
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	if(!A)
		return

	var/list/turfs = list()
	for(var/area/Ar in A.related)
		for(var/turf/T in Ar)
			if(T.density)
				continue
			turfs.Add(T)

	var/turf/T = pick_n_take(turfs)
	if(!T)
		src << "Nowhere to jump to!"
		return
	admin_forcemove(usr, T)
	log_admin("[key_name(usr)] jumped to [A]")
	message_admins("[key_name_admin(usr)] jumped to [A]")
	feedback_add_details("admin_verb","JA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/jumptoturf(var/turf/T in world)
	set name = "Jump to Turf"
	set category = "Admin"
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	log_admin("[key_name(usr)] jumped to [T.x],[T.y],[T.z] in [T.loc]")
	message_admins("[key_name_admin(usr)] jumped to [T.x],[T.y],[T.z] in [T.loc]")
	usr.loc = T
	feedback_add_details("admin_verb","JT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/jumptomob(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Jump to Mob"

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]")
	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = get_turf(M)
		if(T && isturf(T))
			feedback_add_details("admin_verb","JM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			admin_forcemove(A, M.loc)
		else
			A << "This mob is not located in the game world."

/client/proc/jumptocoord(tx as num, ty as num, tz as num)
	set category = "Admin"
	set name = "Jump to Coordinate"

	if (!holder)
		src << "Only administrators may use this command."
		return

	if(src.mob)
		var/mob/A = src.mob
		A.x = tx
		A.y = ty
		A.z = tz
		feedback_add_details("admin_verb","JC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	message_admins("[key_name_admin(usr)] jumped to coordinates [tx], [ty], [tz]")

/client/proc/jumptokey()
	set category = "Admin"
	set name = "Jump to Key"

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	var/list/keys = list()
	for(var/mob/M in player_list)
		keys += M.client
	var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		src << "No keys found."
		return
	var/mob/M = selection:mob
	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]")

	admin_forcemove(usr, M.loc)

	feedback_add_details("admin_verb","JK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Getmob(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Get Mob"
	set desc = "Mob to teleport"
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	log_admin("[key_name(usr)] teleported [key_name(M)]")
	message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)]")
	admin_forcemove(M, get_turf(usr))
	feedback_add_details("admin_verb","GM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Getkey()
	set category = "Admin"
	set name = "Get Key"
	set desc = "Key to teleport"

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	var/list/keys = list()
	for(var/mob/M in player_list)
		keys += M.client
	var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		return
	var/mob/M = selection:mob

	if(!M)
		return
	log_admin("[key_name(usr)] teleported [key_name(M)]")
	message_admins("[key_name_admin(usr)] teleported [key_name(M)]")
	if(M)
		admin_forcemove(M, get_turf(usr))
		usr.loc = M.loc
		feedback_add_details("admin_verb","GK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/sendmob(var/mob/M in sortmobs())
	set category = "Admin"
	set name = "Send Mob"
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	var/area/A = input(usr, "Pick an area.", "Pick an area") in sortedAreas
	if(A)
		admin_forcemove(M, pick(get_area_turfs(A)))
		feedback_add_details("admin_verb","SMOB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] teleported [key_name(M)] to [A]")
		message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)] to [A]")

/proc/admin_forcemove(var/mob/mover, var/atom/newloc)
	mover.loc = newloc
	mover.on_forcemove(newloc)

/mob/proc/on_forcemove(var/atom/newloc)
	return


