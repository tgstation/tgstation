/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()

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

