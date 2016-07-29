<<<<<<< HEAD
/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		visible_message("<b>[src]</b> lets out a flurry of sparks, its screen flickering as its systems slowly halt.")
	stat = DEAD


	if("[icon_state]_dead" in icon_states(src.icon,1))
		icon_state = "[icon_state]_dead"
	else
		icon_state = "ai_dead"

	cameraFollow = null

	anchored = 0 //unbolt floorbolts
	update_canmove()
	if(eyeobj)
		eyeobj.setLoc(get_turf(src))

	shuttle_caller_list -= src
	SSshuttle.autoEvac()

	if(nuking)
		set_security_level("red")
		nuking = FALSE
		for(var/obj/item/weapon/pinpointer/P in pinpointer_list)
			P.switch_mode_to(TRACK_NUKE_DISK) //Party's over, back to work, everyone
			P.nuke_warning = FALSE

	if(doomsday_device)
		doomsday_device.timing = FALSE
		SSshuttle.clearHostileEnvironment(doomsday_device)
		qdel(doomsday_device)
	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 15)

	for(var/obj/machinery/ai_status_display/O in world) //change status
		if(src.key)
			O.mode = 2
			if(istype(loc, /obj/item/device/aicard))
				loc.icon_state = "aicard-404"

	return ..()
=======
/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	if (src.custom_sprite == 1)//check for custom AI sprite, defaulting to blue screen if no.
		icon_state = "[ckey]-ai-crash"
	else icon_state = "ai-crash"
	update_canmove()
	if(src.eyeobj)
		src.eyeobj.forceMove(get_turf(src))
	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	var/callshuttle = 0

	for(var/obj/machinery/computer/communications/commconsole in machines)
		if(commconsole.z == 2)
			continue
		if(istype(commconsole.loc,/turf))
			break
		callshuttle++

	for(var/obj/item/weapon/circuitboard/communications/commboard in world)
		if(commboard.z == 2)
			continue
		if(istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage))
			break
		callshuttle++

	for(var/mob/living/silicon/ai/shuttlecaller in player_list)
		if(shuttlecaller.z == 2)
			continue
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
		world << sound('sound/AI/shuttlecalled.ogg')

	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 15)

	for(var/obj/machinery/ai_status_display/O in machines) //change status
		spawn( 0 )
		O.mode = 2
		if (istype(loc, /obj/item/device/aicard))
			loc.icon_state = "aicard-404"

	tod = worldtime2text() //weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
		if(!suiciding) //Cowards don't count
			score["deadaipenalty"] += 1

	return ..(gibbed)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
