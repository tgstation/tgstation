/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return
	log_prayer("[src.key]/([src.name]): [msg]")
	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			usr << "<span class='danger'>You cannot pray (muted).</span>"
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	var/image/cross = image('icons/obj/storage.dmi',"bible")
	if(usr.job == "Chaplain")
		cross = image('icons/obj/storage.dmi',"kingyellow")
		msg = "<span class='adminnotice'>\icon[cross] <b><font color=blue>CHAPLAIN PRAYER: </font>[key_name_admin(src)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[src]'>FLW</A>) (<A HREF='?_src_=holder;traitor=\ref[src]'>TP</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>):</b> [msg]</span>"
	else if(iscultist(usr))
		cross = image('icons/obj/storage.dmi',"tome")
		msg = "<span class='adminnotice'>\icon[cross] <b><font color=red>CULTIST PRAYER: </font>[key_name_admin(src)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[src]'>FLW</A>) (<A HREF='?_src_=holder;traitor=\ref[src]'>TP</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>):</b> [msg]</span>"
	else
		cross = image('icons/obj/storage.dmi',"bible")
		msg = "<span class='adminnotice'>\icon[cross] <b><font color=purple>PRAYER: </font>[key_name_admin(src)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[src]'>FLW</A>) (<A HREF='?_src_=holder;traitor=\ref[src]'>TP</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>):</b> [msg]</span>"
	for(var/client/C in admins)
		if(C.prefs.chat_toggles & CHAT_PRAYER)
			C << msg
			if(C.prefs.toggles & SOUND_PRAYERS)
				if(usr.job == "Chaplain")
					C << 'sound/effects/pray.ogg'
	usr << "Your prayers have been received by the gods."

	feedback_add_details("admin_verb","PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("HELP: [key_name(src)]: [msg]")

/proc/Centcomm_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='adminnotice'> <b><font color=orange>CENTCOM:</font>[key_name_admin(Sender)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[Sender]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[Sender]'>FLW</A>) (<A HREF='?_src_=holder;traitor=\ref[Sender]'>TP</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	admins << msg

/proc/Syndicate_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='adminnotice'><b><font color=crimson>SYNDICATE:</font>[key_name_admin(Sender)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[Sender]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[Sender]'>FLW</A>) (<A HREF='?_src_=holder;traitor=\ref[Sender]'>TP</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;SyndicateReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	admins << msg

/proc/Nuke_request(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='adminnotice'> <b><font color=orange>NUKE CODE REQUEST:</font>[key_name_admin(Sender)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[Sender]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[Sender]'>FLW</A>) (<A HREF='?_src_=holder;traitor=\ref[Sender]'>TP</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	admins << msg
	admins << "<span class='adminnotice'><b>At this current time, the nuke must have the code manually set via varedit.</b></span>"