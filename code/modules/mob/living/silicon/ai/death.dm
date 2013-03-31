/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	icon_state = "ai-crash"

	update_canmove()
	if(src.eyeobj)
		src.eyeobj.setLoc(get_turf(src))
	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	var/callshuttle = 1

	for(var/SC in shuttle_caller_list)
		if(istype(SC,/mob/living/silicon/ai))
			var/mob/living/silicon/ai/AI = SC
			if(AI.stat && !AI.client)
				continue
		var/turf/T = get_turf(SC)
		if(T && T.z == 1)
			callshuttle = 0 //if there's an alive AI or a communication console on the station z level, we don't call the shuttle
			break

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" /* DEATH SQUADS || sent_strike_team*/)
		callshuttle = 0

	if(callshuttle)
		if(!emergency_shuttle.online && emergency_shuttle.direction == 1) //we don't call the shuttle if it's already coming
			emergency_shuttle.incall(2.5) //25 minutes! If they want to recall, they have 20 minutes to do so
			log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
			message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)
			captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
			world << sound('sound/AI/shuttlecalled.ogg')

	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 15)

	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 2
		if (istype(loc, /obj/item/device/aicard))
			loc.icon_state = "aicard-404"

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	return ..(gibbed)
