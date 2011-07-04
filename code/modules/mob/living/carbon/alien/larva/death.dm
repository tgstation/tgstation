/mob/living/carbon/alien/larva/death(gibbed)
	if(src.stat == 2)
		return
	if(src.healths)
		src.healths.icon_state = "health6"

	/*
	if(istype(src,/mob/living/carbon/alien/larva/metroid))
		src.icon_state = "metroid_dead"
	*/
	else
		src.icon_state = "larva_l"
	src.stat = 2

	if (!gibbed)

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

		if (src.client)
			spawn(10)
				if(src.client && src.stat == 2)
					src.verbs += /mob/proc/ghost

	if(mind) // Skie - Added check that there's someone controlling the alien
		var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
		mind.store_memory("Time of death: [tod]", 0)

	var/cancel
	for (var/mob/M in world)
		if (M.client && !M.stat)
			cancel = 1
			break

	if (!cancel && !abandon_allowed)
		spawn (50)
			cancel = 0
			for (var/mob/M in world)
				if (M.client && !M.stat)
					cancel = 1
					break

			if (!cancel && !abandon_allowed)
				world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"

				spawn (300)
					log_game("Rebooting because of no live players")
					world.Reboot()

	return ..(gibbed)
