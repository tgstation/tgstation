/mob/verb/adminhelp(msg as text)
	set category = "Admin"
	set name = "Adminhelp"
	if(!usr.client.authenticated)
		src << "Please authorize before sending these messages."
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (usr.client && usr.client.muted_complete)
		return

	for (var/client/X)
		if (X.holder)
			if(X.sound_adminhelp)
				X << 'adminhelp.ogg'
			X << "\blue <b><font color=red>HELP: </font>[key_name(src, X)] (<A HREF='?src=\ref[X.holder];adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?src=\ref[X.holder];adminplayervars=\ref[src]'>VV</A>) (<A HREF='?src=\ref[X.holder];adminplayersubtlemessage=\ref[src]'>SM</A>) (<A HREF='?src=\ref[X.holder];adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?src=\ref[X.holder];secretsadmin=check_antagonist'>CA</A>):</b> [msg]"

	usr << "Your message has been broadcast to administrators."
	log_admin("HELP: [key_name(src)]: [msg]")
	if(tension_master)
		tension_master.new_adminhelp()
	send2irc(usr.ckey, msg)
	return

proc/send2irc(msg,msg2)
	if(config.useircbot)
		shell("python nudge.py [msg] [msg2]")
	return