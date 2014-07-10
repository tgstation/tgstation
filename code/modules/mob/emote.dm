// All mobs should have custom emote, really..
/mob/proc/custom_emote(var/m_type=1,var/message = null)

	if(stat || !use_me && usr == src)
		usr << "You are unable to emote."
		return

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	if(m_type == 2 && muzzled) return

	var/input
	if(!message)
		input = copytext(sanitize(input(src,"Choose an emote to display.") as text|null),1,MAX_MESSAGE_LEN)
	else
		input = message
	if(input)
		message = "<B>[src]</B> [input]"
	else
		return


	if (message)
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in player_list)
			if (!M.client)
				continue //skip monkeys and leavers
			if (istype(M, /mob/new_player))
				continue
			if(findtext(message," snores.")) //Because we have so many sleeping people.
				break
			if(M.stat == 2 && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)


		// Type 1 (Visual) emotes are sent to anyone in view of the item
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)

		// Type 2 (Audible) emotes are sent to anyone in hear range
		// of the *LOCATION* -- this is important for pAIs to be heard
		else if (m_type & 2)
			for (var/mob/O in hearers(get_turf(src), null))
				O.show_message(message, m_type)

/mob/proc/emote_dead(var/message)

	if(client.prefs.muted & MUTE_DEADCHAT)
		src << "\red You cannot send deadchat emotes (muted)."
		return

	if(!(client.prefs.toggles & CHAT_DEAD))
		src << "\red You have deadchat muted."
		return

	var/input
	if(!message)
		input = copytext(sanitize(input(src, "Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)
	else
		input = message

	if(input)
		message = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <b>[src]</b> [message]</span>"
	else
		return


	if(message)
		log_emote("Ghost/[src.key] : [message]")

		for(var/mob/M in player_list)
			if(istype(M, /mob/new_player))
				continue

			if(M.client && M.client.holder && (M.client.holder.rights & R_ADMIN|R_MOD) && (M.client.prefs.toggles & CHAT_DEAD)) // Show the emote to admins/mods
				M << message

			else if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_DEAD)) // Show the emote to regular ghosts with deadchat toggled on
				M.show_message(message, 2)
