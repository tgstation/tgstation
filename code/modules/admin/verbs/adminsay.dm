/client/proc/cmd_admin_say(msg as text)
	set category = "Special Verbs"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1

	if (!src.holder)
		src << "Only administrators may use this command."
		return

	if (src.muted_adminhelp)
		src << "You cannot send ASAY messages (muted by admins)."
		return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	log_admin("[key_name(src)] : [msg]")


	if (!msg)
		return
	feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for (var/client/C in admin_list)
		if (src.holder.rank == "Admin Observer")
			C << "<span class='adminobserver'><span class='prefix'>ADMIN:</span> <EM>[key_name(usr, C)]:</EM> <span class='message'>[msg]</span></span>"
		else
			C << "<span class='admin'><span class='prefix'>ADMIN:</span> <EM>[key_name(usr, C)]</EM> (<A HREF='?src=\ref[C.holder];adminplayerobservejump=\ref[mob]'>JMP</A>): <span class='message'>[msg]</span></span>"

