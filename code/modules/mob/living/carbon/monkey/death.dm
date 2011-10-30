/mob/living/carbon/monkey/death(gibbed)
	if(src.stat == 2)
		return
	var/cancel
	if (src.healths)
		src.healths.icon_state = "health5"
	if(!gibbed)
		for(var/mob/O in viewers(src, null))
			O.show_message("<b>The [src.name]</b> lets out a faint chimper as it collapses and stops moving...", 1) //ded -- Urist

	src.stat = 2
	src.canmove = 0
	if (src.blind)
		src.blind.layer = 0
	src.lying = 1

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