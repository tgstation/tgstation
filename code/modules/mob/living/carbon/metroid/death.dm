/mob/living/carbon/metroid/death(gibbed)
	if(src.stat == 2)
		return
	var/cancel
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

	//var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	//mind.store_memory("Time of death: [tod]", 0)

	ticker.mode.check_win()
	//src.icon_state = "dead"
	for(var/mob/M in world)
		if ((M.client && !( M.stat )))
			cancel = 1
			break
	if (!( cancel ))
		world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"

		feedback_set_details("end_error","no live players")
		feedback_set_details("round_end","[time2text(world.realtime)]")
		if(blackbox)
			blackbox.save_all_data_to_sql()

		spawn( 300 )
			log_game("Rebooting because of no live players")
			world.Reboot()
			return
	if (src.key)
		spawn(50)
			if(src.key && src.stat == 2)
				src.verbs += /mob/proc/ghost

	return ..(gibbed)