<<<<<<< HEAD
/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return
	log_prayer("[src.key]/([src.name]): [msg]")
	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			usr << "<span class='danger'>You cannot pray (muted).</span>"
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	var/image/cross = image('icons/obj/storage.dmi',"bible")
	var/font_color = "purple"
	var/prayer_type = "PRAYER"
	if(usr.job == "Chaplain")
		cross = image('icons/obj/storage.dmi',"kingyellow")
		font_color = "blue"
		prayer_type = "CHAPLAIN PRAYER"
	else if(iscultist(usr))
		cross = image('icons/obj/storage.dmi',"tome")
		font_color = "red"
		prayer_type = "CULTIST PRAYER"

	msg = "<span class='adminnotice'>\icon[cross] \
		<b><font color=[font_color]>[prayer_type]: </font>\
		[ADMIN_FULLMONTY(src)] [ADMIN_SC(src)]:</b> \
		[msg]</span>"

	for(var/client/C in admins)
		if(C.prefs.chat_toggles & CHAT_PRAYER)
			C << msg
			if(C.prefs.toggles & SOUND_PRAYERS)
				if(usr.job == "Chaplain")
					C << 'sound/effects/pray.ogg'
	usr << "Your prayers have been received by the gods."

	feedback_add_details("admin_verb","PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("HELP: [key_name(src)]: [msg]")

/proc/Centcomm_announce(text , mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='adminnotice'>\
		<b><font color=orange>CENTCOM:</font>\
		[ADMIN_FULLMONTY(Sender)] [ADMIN_BSA(Sender)] \
		[ADMIN_CENTCOM_REPLY(Sender)]:</b> \
		[msg]</span>"
	admins << msg
	for(var/obj/machinery/computer/communications/C in machines)
		C.overrideCooldown()

/proc/Syndicate_announce(text , mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='adminnotice'><b>\
		<font color=crimson>SYNDICATE:</font>\
		[ADMIN_FULLMONTY(Sender)] [ADMIN_BSA(Sender)] \
		[ADMIN_SYNDICATE_REPLY(Sender)]:</b> \
		[msg]</span>"
	admins << msg
	for(var/obj/machinery/computer/communications/C in machines)
		C.overrideCooldown()

/proc/Nuke_request(text , mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='adminnotice'>\
		<b><font color=orange>NUKE CODE REQUEST:</font>\
		[ADMIN_FULLMONTY(Sender)] [ADMIN_BSA(Sender)] \
		[ADMIN_CENTCOM_REPLY(Sender)] \
		[ADMIN_SET_SD_CODE]:</b> \
		[msg]</span>"
	admins << msg
	for(var/obj/machinery/computer/communications/C in machines)
		C.overrideCooldown()
=======
//The Pray verb. Often known as the IC adminhelp, or the crayon for cool shit trade
/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(say_disabled) //This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return

	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			to_chat(usr, "<span class='warning'>You cannot pray (muted).</span>")
			return
		if(src.client.handle_spam_prevention(msg, MUTE_PRAY))
			return

	var/orig_message = msg
	var/image/cross = image('icons/obj/storage.dmi',"bible")
	msg = "<span class='notice'>[bicon(cross)] <b><font color='purple'>PRAY (DEITY:[ticker.Bible_deity_name]): </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>):</b> [msg]</span>"

	send_prayer_to_admins(msg, 'sound/effects/prayer.ogg')

	if(!stat)
		usr.whisper(orig_message)
	to_chat(usr, "Your prayers have been received by the gods.")

	feedback_add_details("admin_verb", "PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/Centcomm_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='notice'><b><font color=orange>CENTCOMM:</font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	send_prayer_to_admins(msg, 'sound/effects/msn.ogg')

/proc/Syndicate_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='notice'><b><font color=crimson>SYNDICATE:</font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;SyndicateReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	send_prayer_to_admins(msg, 'sound/effects/inception.ogg')

/proc/send_prayer_to_admins(var/msg,var/sound)
	for(var/client/C in admins)
		if(C.prefs.toggles & CHAT_PRAYER)
			if(C.prefs.special_popup)
				C << output(msg, "window1.msay_output") //If i get told to make this a proc imma be fuckin mad
			else
				to_chat(C, msg)
			C << sound
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
