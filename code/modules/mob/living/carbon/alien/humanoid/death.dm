/mob/living/carbon/alien/humanoid/death(gibbed)
	if(src.stat == 2)
		return
	if(src.healths)
		src.healths.icon_state = "health6"
	src.stat = 2

	if (!gibbed)
//		emote("deathgasp") // Dead -- Skie // Doesn't work due to stat == 2 -- Urist
		playsound(src.loc, 'hiss6.ogg', 80, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("<B>[src]</B> lets out a waning guttural screech, green blood bubbling from its maw...", 1)

		src.canmove = 0
		if(src.client)
			src.blind.layer = 0
		src.lying = 1
		var/h = src.hand
		src.hand = 0
		drop_item()
		src.hand = 1
		drop_item()
		src.hand = h

		if (src.key)
			spawn(10)
				if(src.key && src.stat == 2)
					src.client.verbs += /client/proc/ghost

	tod = worldtime2text() //weasellos time of death patch
	if (mind) mind.store_memory("Time of death: [tod]", 0)
	else src << "We seem to have misplaced your mind datum, so we can't add this to your memory, but you died at [tod]"

	return ..(gibbed)
