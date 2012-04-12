/mob/verb/listen_ooc()
	set name = "Un/Mute OOC"
	set category = "OOC"

	if (src.client)
		src.client.listen_ooc = !src.client.listen_ooc
		if (src.client.listen_ooc)
			src << "\blue You are now listening to messages on the OOC channel."
		else
			src << "\blue You are no longer listening to messages on the OOC channel."

/mob/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"
	if (IsGuestKey(src.key))
		src << "You are not authorized to communicate over these channels."
		return
	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return
	else if (!src.client.listen_ooc)
		return
	else if (!ooc_allowed && !src.client.holder)
		return
	else if (!dooc_allowed && !src.client.holder && (src.client.deadchat != 0))
		usr << "OOC for dead mobs has been turned off."
		return
	else if (src.client && (src.client.muted || src.client.muted_complete))
		src << "You are muted."
		return
	else if (findtext(msg, "byond://") && !src.client.holder)
		src << "<B>Advertising other servers is not allowed.</B>"
		log_admin("[key_name(src)] has attempted to advertise in OOC.")
		message_admins("[key_name_admin(src)] has attempted to advertise in OOC.")
		return

	log_ooc("[src.name]/[src.key] : [msg]")

	for (var/client/C)
		if (src.client.holder && (!src.client.stealth || C.holder))
			if (src.client.holder.rank == "Admin Observer")
				C << "<span class='observerooc'><span class='prefix'>OOC:</span> <EM>[src.key][src.client.stealth ? "/([src.client.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></span>"
			else if (src.client.holder.level >= 5)
				C << "<font color=[src.client.ooccolor]><b><span class='prefix'>OOC:</span> <EM>[src.key][src.client.stealth ? "/([src.client.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></b></font>"
			else
				C << "<span class='adminooc'><span class='prefix'>OOC:</span> <EM>[src.key][src.client.stealth ? "/([src.client.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></span>"

		else if (C.listen_ooc)
			C << "<span class='ooc'><span class='prefix'>OOC:</span> <EM>[src.client.stealth ? src.client.fakekey : src.key]:</EM> <span class='message'>[msg]</span></span>"
/*
/mob/verb/goonsay(msg as text)
	set name = "Goonsay"
	if (!src.client.authenticated || !src.client.goon)
		src << "You are not authorized to communicate over these channels."
		return
	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if (!msg)
		return
	else if (!src.client.listen_ooc)
		return
	else if (!goonsay_allowed && !src.client.holder)
		return
	else if (src.muted)
		return

	log_ooc("GOON : [key_name(src)] : [msg]")

	for (var/client/C)
		if (C.goon)
			if(src.client.holder && (!src.client.stealth || C.holder))
				if (src.client.holder.rank == "Admin Observer")
					C << "<span class=\"gfartgoonsay\"><span class=\"prefix\">GOONSAY:</span> <span class=\"name\">[src.key][src.client.stealth ? "/([src.client.fakekey])" : ""]:</span> <span class=\"message\">[msg]</span></span>"
				else
					C << "<span class=\"admingoonsay\"><span class=\"prefix\">GOONSAY:</span> <span class=\"name\">[src.key][src.client.stealth ? "/([src.client.fakekey])" : ""]:</span> <span class=\"message\">[msg]</span></span>"
			else if(C.listen_ooc)
				C << "<span class=\"goonsay\"><span class=\"prefix\">GOONSAY:</span> <span class=\"name\">[src.client.stealth ? src.client.fakekey : src.key]:</span> <span class=\"message\">[msg]</span></span>"


				-- Skie */