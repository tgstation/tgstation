/client/verb/looc(msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(!mob)	return
	if(IsGuestKey(key))
		to_chat(src,  "Guests may not use LOOC.")
		return

	msg = trim(sanitize(copytext(msg, 1, MAX_MESSAGE_LEN)))
	if(!msg)	return

	if(!(prefs.chat_toggles & CHAT_LOOC))
		to_chat(src, "<span class='notice'>You have LOOC muted. Toggle it on Preferenes -> Show/Hide LOOC</span>")
		return

	if(!(holder && R_ADMIN))
		if(!GLOB.looc_allowed)
			to_chat(src,  "<span class='notice'>LOOC is globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr,  "<span class='notice'>LOOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src,  "<span class='notice'>You cannot use LOOC (muted).</span>")
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src,  "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in LOOC: [msg]")
			return

	log_ooc("(LOCAL) [mob.name]/[key] : [msg]")
	var/list/heard = get_mobs_in_view(7, src.mob)
	var/mob/S = src.mob

	var/display_name = S.key
	if(S.stat != DEAD)
		display_name = S.name

	// Handle non-admins
	for(var/mob/M in heard)
		if(!M.client)
			continue
		var/client/C = M.client
		if(C in GLOB.admins)
			if(R_ADMIN)
				continue //they are handled after that

		if(C.prefs.chat_toggles & CHAT_LOOC)
			if(holder)
				if(holder.fakekey)
					if(C.holder)
						display_name = "[holder.fakekey]/([src.key])"
					else
						display_name = holder.fakekey
			to_chat(C, "<font color='#6699CC'><span class='ooc'><span class='prefix'>LOOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>")

	// Now handle admins
	display_name = S.key
	if(S.stat != DEAD)
		display_name = "[S.name]/([S.key])"

	for(var/client/C in GLOB.admins)
		if(R_ADMIN)
			if(C.prefs.chat_toggles & CHAT_LOOC)
				var/prefix = "(R)LOOC"
				var/link = "<a href='?_src_=holder;adminplayerobservefollow=\ref[S]'>(F)</A> "
				if (C.mob in heard)
					prefix = "LOOC"
				to_chat(C, "[link]<font color='#6699CC'><span class='ooc'><span class='prefix'>[prefix]:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>")

/proc/toggle_looc(toggle = null)
	if(toggle != null)
		if(toggle != GLOB.looc_allowed)
			GLOB.looc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.looc_allowed = !GLOB.looc_allowed
	to_chat("<B>The LOOC channel has been globally [GLOB.looc_allowed ? "enabled" : "disabled"].</B>")