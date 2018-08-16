/client/proc/citaPPoptions(mob/M) // why is this client and not /datum/admins? noone knows, in PP src == client, instead of holder. wtf.
	var/body = "<br>"
	if(M.client)
		body += "<A href='?_src_=holder;[HrefToken()];makementor=[M.ckey]'>Make mentor</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];removementor=[M.ckey]'>Remove mentor</A>"
	return body

/client/proc/cmd_admin_man_up(mob/M in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Man Up"

	if(!M)
		return
	if(!check_rights(R_ADMIN))
		return

	to_chat(M, "<span class='warning bold reallybig'>Man up, and deal with it.</span><br><span class='warning big'>Move on.</span>")
	M.playsound_local(M, 'modular_citadel/sound/misc/manup.ogg', 50, FALSE, pressure_affected = FALSE)

	log_admin("Man up: [key_name(usr)] told [key_name(M)] to man up")
	var/message = "<span class='adminnotice'>[key_name_admin(usr)] told [key_name_admin(M)] to man up.</span>"
	message_admins(message)
	admin_ticket_log(M, message)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Man Up")

/client/proc/cmd_admin_man_up_global()
	set category = "Special Verbs"
	set name = "Man Up Global"

	if(!check_rights(R_ADMIN))
		return

	to_chat(world, "<span class='warning bold reallybig'>Man up, and deal with it.</span><br><span class='warning big'>Move on.</span>")
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M, 'modular_citadel/sound/misc/manup.ogg', 50, FALSE, pressure_affected = FALSE)

	log_admin("Man up global: [key_name(usr)] told everybody to man up")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] told everybody to man up.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Man Up Global")
