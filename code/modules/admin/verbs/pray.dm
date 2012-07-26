/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (usr.client)
		if(usr.client.muted_pray)
			return

		if (src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	var/icon/cross = icon('icons/obj/storage.dmi',"bible")

	for (var/mob/M in admin_list)
		if (M.client.seeprayers)
			M << "\blue \icon[cross] <b><font color=purple>PRAY: </font>[key_name(src, M)] (<A HREF='?src=\ref[M.client.holder];adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?src=\ref[M.client.holder];adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?src=\ref[M.client.holder];adminplayervars=\ref[src]'>VV</A>) (<A HREF='?src=\ref[M.client.holder];adminplayersubtlemessage=\ref[src]'>SM</A>) (<A HREF='?src=\ref[M.client.holder];adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?src=\ref[M.client.holder];secretsadmin=check_antagonist'>CA</A>) (<A HREF='?src=\ref[M.client.holder];adminspawncookie=\ref[src]'>SC</a>):</b> [msg]"

	usr << "Your prayers have been received by the gods."
	feedback_add_details("admin_verb","PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("HELP: [key_name(src)]: [msg]")


/proc/Centcomm_announce(var/text , var/mob/Sender)

	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)

//	log_admin("[key_name(Sender)] sent a message to Centcomm!  The message was [msg]")  // Handled somewhere else

	for (var/mob/M in admin_list)
		M << "\blue <b><font color=orange>CENTCOMM:</font>[key_name(Sender, M)] (<A HREF='?src=\ref[M.client.holder];adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?src=\ref[M.client.holder];adminplayervars=\ref[Sender]'>VV</A>) (<A HREF='?src=\ref[M.client.holder];adminplayersubtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?src=\ref[M.client.holder];adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?src=\ref[M.client.holder];secretsadmin=check_antagonist'>CA</A>) (<A HREF='?src=\ref[M.client.holder];BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?src=\ref[M.client.holder];CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]"
			//
/proc/Syndicate_announce(var/text , var/mob/Sender)

	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)

//	log_admin("[key_name(Sender)] sent a message to the Syndicate!  The message was [msg]")  // Handled somewhere else

	for (var/mob/M in admin_list)
		M << "\blue <b><font color=crimson>SYNDICATE:</font>[key_name(Sender, M)] (<A HREF='?src=\ref[M.client.holder];adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?src=\ref[M.client.holder];adminplayervars=\ref[Sender]'>VV</A>) (<A HREF='?src=\ref[M.client.holder];adminplayersubtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?src=\ref[M.client.holder];adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?src=\ref[M.client.holder];secretsadmin=check_antagonist'>CA</A>) (<A HREF='?src=\ref[M.client.holder];BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?src=\ref[M.client.holder];SyndicateReply=\ref[Sender]'>RPLY</A>):</b> [msg]"
			//
