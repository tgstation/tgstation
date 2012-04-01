/mob/living/silicon/ai/death(gibbed)
	stat = 2
	canmove = 0
	if(blind)
		blind.layer = 0
	sight |= SEE_TURFS
	sight |= SEE_MOBS
	sight |= SEE_OBJS
	see_in_dark = 8
	see_invisible = 2
	icon_state = "ai-crash"

	var/callshuttle = 0

	for(var/obj/machinery/computer/communications/commconsole in world)
		if(istype(commconsole.loc,/turf))
			break
		callshuttle++

	for(var/obj/item/weapon/circuitboard/communications/commboard in world)
		if(istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage))
			break
		callshuttle++

	for(var/mob/living/silicon/ai/shuttlecaller in world)
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			break
		callshuttle++

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || sent_strike_team)
		callshuttle = 0

	if(callshuttle == 3) //if all three conditions are met
		emergency_shuttle.incall(2)
		log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
		message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)
		captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
		world << sound('shuttlecalled.ogg')

	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 15)

	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 2
		if (istype(loc, /obj/item/device/aicard))
			loc.icon_state = "aicard-404"

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	if (key)
		spawn(50)
			if(key && stat == 2)
				verbs += /mob/proc/ghost
	return ..(gibbed)
