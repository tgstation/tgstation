/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()

	if("[icon_state]_dead" in icon_states(src.icon,1))
		icon_state = "[icon_state]_dead"
	else
		icon_state = "ai_dead"

	cameraFollow = null

	anchored = FALSE //unbolt floorbolts
	update_canmove()
	if(eyeobj)
		eyeobj.setLoc(get_turf(src))

	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()

	ShutOffDoomsdayDevice()

	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 15)

	if(src.key)
		for(var/each in GLOB.ai_status_displays) //change status
			var/obj/machinery/status_display/ai/O = each
			O.mode = 2
			O.update()

	if(istype(loc, /obj/item/aicard/aitater))
		loc.icon_state = "aitater-404"
	else if(istype(loc, /obj/item/aicard))
		loc.icon_state = "aicard-404"

/mob/living/silicon/ai/proc/ShutOffDoomsdayDevice()
	if(nuking)
		set_security_level("red")
		nuking = FALSE
		for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
			P.switch_mode_to(TRACK_NUKE_DISK) //Party's over, back to work, everyone
			P.alert = FALSE

	if(doomsday_device)
		doomsday_device.timing = FALSE
		SSshuttle.clearHostileEnvironment(doomsday_device)
		qdel(doomsday_device)
