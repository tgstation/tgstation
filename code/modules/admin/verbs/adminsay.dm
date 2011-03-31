/client/proc/cmd_admin_say(msg as text)
	set category = "Special Verbs"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1

	//	All admins should be authenticated, but... what if?

	if (!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	if (!src.mob || src.mob.muted)
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	log_admin("[key_name(src)] : [msg]")


	if (!msg)
		return

	for (var/mob/M in world)
		if (M.client && M.client.holder)
			if (src.holder.rank == "Admin Observer")
				M << "<span class=\"gfartadmin\"><span class=\"prefix\">ADMIN:</span> <span class=\"name\">[key_name(usr, M)]:</span> <span class=\"message\">[msg]</span></span>"
			else
				M << "<span class=\"admin\"><span class=\"prefix\">ADMIN:</span> <span class=\"name\">[key_name(usr, M)]:</span> <span class=\"message\">[msg]</span></span>"

