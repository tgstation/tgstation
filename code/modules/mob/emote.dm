// All mobs should have custom emote, really..
mob/proc/custom_emote(var/m_type=1,var/message = null)

	if(!emote_allowed && usr == src)
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

		for(var/mob/M in world)
			if (!M.client)
				continue //skip monkeys and leavers
			if (istype(M, /mob/new_player))
				continue
			if(findtext(message," snores.")) //Because we have so many sleeping people.
				continue
			if(M.stat == 2 && M.client.ghost_sight && !(M in viewers(src,null)))
				M.show_message(message)


		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				if(istype(O,/mob/living/carbon/human))
					for(var/mob/living/parasite/P in O:parasites)
						P.show_message(message, m_type)
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src.loc, null))
				if(istype(O,/mob/living/carbon/human))
					for(var/mob/living/parasite/P in O:parasites)
						P.show_message(message, m_type)
				O.show_message(message, m_type)
