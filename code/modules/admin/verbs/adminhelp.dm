/client/verb/adminhelp(msg as text)
	set category = "Admin"
	set name = "Adminhelp"

	if (muted_complete)
		src << "<font color='red'>Error: Admin-PM: You are completely muted.</font>"
		return

	if(!msg)	return
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if (!msg)	return

	if(mob)
		var/ref_mob = "\ref[src.mob]"
		for (var/client/X)
			if (X.holder)
				if(X.sound_adminhelp)
					X << 'adminhelp.ogg'
				X << "\blue <b><font color=red>HELP: </font>[key_name(src, X)] (<A HREF='?src=\ref[X.holder];adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?src=\ref[X.holder];adminplayervars=[ref_mob]'>VV</A>) (<A HREF='?src=\ref[X.holder];adminplayersubtlemessage=[ref_mob]'>SM</A>) (<A HREF='?src=\ref[X.holder];adminplayerobservejump=[ref_mob]'>JMP</A>) (<A HREF='?src=\ref[X.holder];secretsadmin=check_antagonist'>CA</A>):</b> [msg]"
	else
		var/ref_client = "\ref[src]"
		for (var/client/X)
			if (X.holder)
				if(X.sound_adminhelp)
					X << 'adminhelp.ogg'
				X << "\blue <b><font color=red>HELP: </font>[key_name(src, X)] (<A HREF='?src=\ref[X.holder];adminplayervars=[ref_client]'>VV</A>) (<A HREF='?src=\ref[X.holder];secretsadmin=check_antagonist'>CA</A>):</b> [msg]"

	src << "<font color='blue'>PM to-<b>Admins</b>: [msg]</font>"
	log_admin("HELP: [key_name(src)]: [msg]")
	if(tension_master)
		tension_master.new_adminhelp()
	send2irc(ckey, msg)
	feedback_add_details("admin_verb","AH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

proc/send2irc(msg,msg2)
	if(config.useircbot)
		shell("python nudge.py [msg] [msg2]")
	return