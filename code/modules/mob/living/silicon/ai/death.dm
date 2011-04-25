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

	for(var/obj/machinery/computer/communications/commconsole in world)
		if(istype(commconsole.loc,/turf))
			return

	for(var/obj/item/weapon/circuitboard/communications/commboard in world)
		if(istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage))
			return

	for(var/mob/living/silicon/ai/shuttlecaller in world)
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			return

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || sent_strike_team)
		return

	emergency_shuttle.incall(2)
	log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
	message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)
	world << "\blue <B>Alert: The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.</B>"
	world << sound('shuttlecalled.ogg')

	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 2
		if (istype(src.loc, /obj/item/device/aicard))
			src.loc.icon_state = "aicard-404"

	if(ticker.mode.name == "AI malfunction")
		var/datum/game_mode/malfunction/malf = ticker.mode
		for(var/datum/mind/AI_mind in malf.malf_ai)
			if (src.mind == AI_mind)
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
	if (src.key)
		spawn(50)
			if(src.key && src.stat == 2)
				src.verbs += /mob/proc/ghostize
	return ..(gibbed)