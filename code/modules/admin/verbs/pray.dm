/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"
	if(!usr.client.authenticated)
		src << "Please authorize before sending these messages."
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (usr.muted)
		return

	var/icon/cross = icon('storage.dmi',"bible")

	for (var/mob/M in world)
		if (M.client && M.client.holder && M.client.seeprayers)
			M << "\blue \icon[cross] <b><font color=purple>PRAY: </font>[key_name(src, M)] (<A HREF='?src=\ref[M.client.holder];adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?src=\ref[M.client.holder];adminplayervars=\ref[src]'>VV</A>) (<A HREF='?src=\ref[M.client.holder];adminplayersubtlemessage=\ref[src]'>SM</A>)(<A HREF='?src=\ref[M.client.holder];adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?src=\ref[M.client.holder];adminplayervars=\ref[src]'>VV</A>) (<A HREF='?src=\ref[M.client.holder];adminplayersubtlemessage=\ref[src]'>SM</A>):</b> [msg]"

	usr << "Your prayers have been received by the gods."
	//log_admin("HELP: [key_name(src)]: [msg]")
