// Note currently ai restrained() returns 0 in all cases

// New feature: Double click on mobs as AI to track them

// No adjacency, no nothing
/mob/living/silicon/ai/ClickOn(var/atom/A, var/doubleclick)
	if(control_disabled || stat || (world.time <= next_move && !doubleclick)) return
	next_move = world.time + 9

	if(doubleclick)
		if(ismob(A))
			ai_actual_track(A)
		else
			A.move_camera_by_click()
	else if(restrained())
		A.hand_a(src)
	else
		A.attack_ai(src)

/atom/proc/attack_ai(mob/user as mob)
	return
/atom/proc/hand_a(mob/user as mob)			//AI - restrained
	return


/mob/living/silicon/ai/ShiftClickOn(var/atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/ai/CtrlClickOn(var/atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/ai/AltClickOn(var/atom/A)
	A.AIAltClick(src)


// The following criminally helpful code is just the previous code cleaned up
// I have no idea why it was in atoms.dm instead of respective files

/atom/proc/AIShiftClick()
	return

/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if(density)
		Topic("aiEnable=7", list("aiEnable"="7"), 1) // 1 meaning no window (consistency!)
	else
		Topic("aiDisable=7", list("aiDisable"="7"), 1)
	return


/atom/proc/AICtrlClick()
	return

/obj/machinery/door/airlock/AICtrlClick() // Bolts doors
	if(locked)
		Topic("aiEnable=4", list("aiEnable"="4"), 1)
	else
		Topic("aiDisable=4", list("aiDisable"="4"), 1)

/obj/machinery/power/apc/AICtrlClick() // turns off APCs.
	Topic("breaker=1", list("breaker"="1"), 0) // 0 meaning no window (consistency!)


/atom/proc/AIAltClick()
	return

/obj/machinery/door/airlock/AIAltClick() // Eletrifies doors.
	if(!secondsElectrified)
		// permenant shock
		Topic("aiEnable=6", list("aiEnable"="6"), 1) // 1 meaning no window (consistency!)
	else
		// disable/6 is not in Topic; disable/5 disables both temporary and permenant shock
		Topic("aiDisable=5", list("aiDisable"="5"), 1)
	return
