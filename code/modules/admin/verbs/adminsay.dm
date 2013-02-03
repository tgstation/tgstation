/client/proc/cmd_admin_say(msg as text)
	set category = "Special Verbs"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(R_ADMIN))	return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	log_admin("[key_name(src)] : [msg]")

	if(check_rights(R_ADMIN,0))
		msg = "<span class='admin'><span class='prefix'>ADMIN:</span> <EM>[key_name(usr, 1)]</EM> (<a href='?_src_=holder;adminplayerobservejump=\ref[mob]'>JMP</A>): <span class='message'>[msg]</span></span>"
		for(var/client/C in admins)
			if(R_ADMIN & C.holder.rights)
				C << msg
/*		admins << msg
	else
		msg = "<span class='adminobserver'><span class='prefix'>ADMIN:</span> <EM>[key_name(usr, 1)]:</EM> <span class='message'>[msg]</span></span>"
		admins << msg
*/
	feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mod_say(msg as text)
	set category = "Special Verbs"
	set name = "Msay"
	set hidden = 1

	if (!src.holder)
		src << "Only administrators may use this command."
		return

	//todo: what? why does this not compile
	/*if (src.muted || src.muted_complete)
		src << "You are muted."
		return*/

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	log_admin("MOD: [key_name(src)] : [msg]")


	if (!msg)
		return
	//feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for (var/mob/M in world)
		if (M.client && M.client.holder)
			if (check_rights(R_ADMIN,0))
				M << "<span class='adminmod'><span class='prefix'>MOD:</span> <EM>[key_name(usr, M)]</EM> (<A HREF='?src=\ref[M.client.holder];adminplayerobservejump=\ref[mob]'>JMP</A>): <span class='message'>[msg]</span></span>"
			else if (check_rights(R_MOD,0))
				M << "<span class='mod'><span class='prefix'>MOD:</span> <EM>[key_name(usr, M)]</EM> (<A HREF='?src=\ref[M.client.holder];adminplayerobservejump=\ref[mob]'>JMP</A>): <span class='message'>[msg]</span></span>"
			else if (src.holder.rank == "Admin Observer")
				M << "<span class='adminobserver'><span class='prefix'>MOD:</span> <EM>[key_name(usr, M)]:</EM> <span class='message'>[msg]</span></span>"

