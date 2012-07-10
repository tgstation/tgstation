/mob/living/carbon/metroid/death(gibbed)
	if(src.stat == 2)
		return

	if(!gibbed)
		if(istype(src, /mob/living/carbon/metroid/adult))

			if(client)
				var/mob/dead/observer/ghost = new(src)
				ghost.key = key
				if (ghost.client)
					ghost.client.eye = ghost

			explosion(src.loc, -1,-1,3,12)
			sleep(2)
			del(src)
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("<b>The [src.name]</b> seizes up and falls limp...", 1) //ded -- Urist

	src.stat = 2
	src.canmove = 0
	if (src.blind)
		src.blind.layer = 0
	src.lying = 1
	src.icon_state = "baby metroid dead"

	var/h = src.hand
	src.hand = 0
	drop_item()
	src.hand = 1
	drop_item()
	src.hand = h

	ticker.mode.check_win()

	if (src.key)
		spawn(50)
			if(src.key && src.stat == 2)
				src.client.verbs += /client/proc/ghost

	return ..(gibbed)