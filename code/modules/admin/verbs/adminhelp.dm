/mob/verb/adminhelp(msg as text)
	set category = "Admin"
	set name = "Adminhelp"
	if(!usr.client.authenticated)
		src << "Please authorize before sending these messages."
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (usr.muted)
		return

	for (var/mob/M in world)
		if (M.client && M.client.holder)
			M << "\blue <b><font color=red>HELP: </font>[key_name(src, M)](<A HREF='?src=\ref[M.client.holder];adminplayeropts=\ref[src]'>X</A>):</b> [msg]"

	usr << "Your message has been broadcast to administrators."
	log_admin("HELP: [key_name(src)]: [msg]")
