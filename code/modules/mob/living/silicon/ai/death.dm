/mob/living/silicon/ai/death(gibbed)
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
	src.lying = 1
	src.icon_state = "ai-crash"




	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 2
		if (istype(src.loc, /obj/item/device/aicard))
			src.loc.icon_state = "aicard"
			src.loc.name = "inteliCard"
			src.loc = O

	if(ticker.mode.name == "AI malfunction")
		world << "<FONT size = 3><B>Human Victory</B></FONT>"
		world << "<B>The AI has been killed!</B> The staff is victorious."
		sleep(100)
		world << "\blue Rebooting due to end of game"
		world.Reboot()

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	mind.store_memory("Time of death: [tod]", 0)

	for(var/mob/M in world)
		if ((M.client && !( M.stat )))
			cancel = 1
			break
	if (!( cancel ))
		world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"
		spawn( 300 )
			log_game("Rebooting because of no live players")
			world.Reboot()
			return
	if (src.client)
		spawn(50)
			if(src.client && src.stat == 2)
				src.verbs += /mob/proc/ghostize
	return ..(gibbed)