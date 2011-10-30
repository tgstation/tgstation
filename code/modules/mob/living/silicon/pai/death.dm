/mob/living/silicon/pai/death(gibbed)
	var/cancel
	src.stat = 2
	src.canmove = 0
	if(src.blind)
		src.blind.layer = 0
	src.sight |= SEE_TURFS
	src.sight |= SEE_MOBS
	src.sight |= SEE_OBJS
	src.see_in_dark = 8
	src.see_invisible = 2

	//var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	//mind.store_memory("Time of death: [tod]", 0)

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
	if(key)
		spawn(50)
			src.ghostize(1)
	del(src)