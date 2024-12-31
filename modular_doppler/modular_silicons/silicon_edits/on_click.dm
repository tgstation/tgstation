/*
*	AI CHANGES
*/

/mob/living/silicon/ai/CtrlShiftClickOn(atom/target)
	if(isturf(target))
		var/obj/machinery/door/airlock/airlock = locate() in target
		if(airlock)
			airlock.AICtrlShiftClick(src)
	else
		target.AICtrlShiftClick(src)

/mob/living/silicon/ai/ShiftClickOn(atom/target)
	if(isturf(target))
		var/obj/machinery/door/airlock/airlock = locate() in target
		if(airlock)
			airlock.AIShiftClick(src)
	else
		target.AIShiftClick(src)
		target.AIExamine(target)

/mob/living/silicon/ai/CtrlClickOn(atom/target)
	if(isturf(target))
		var/obj/machinery/door/airlock/airlock = locate() in target
		if(airlock)
			airlock.AICtrlClick(src)
	else
		target.AICtrlClick(src)

/turf/ai_click_alt(mob/living/silicon/ai/user)
	var/obj/machinery/door/airlock/airlock = locate() in src
	if(airlock)
		airlock.ai_click_alt(user)
		return
	return ..()


/atom/proc/AIExamine() // Used for AI specific examines .Currently only employed to stop door examines.
	usr.examinate(src)

// Should keep all AI Examines in here in a list.
/obj/machinery/door/airlock/AIExamine() // Lets not spam the AI with door examinations
	return

/mob/living/silicon/ai/ClickOn(atom/A, params)
	..()
	var/list/modifiers = params2list(params)
	if(isturf(A) && !modifiers) // Have to check for modifiers.
		var/obj/machinery/door/firedoor/the_door = locate() in A
		if(the_door)
			the_door.attack_ai(usr)

/*
*	CYBORG CHANGES
*/

/mob/living/silicon/robot/CtrlShiftClickOn(atom/target)
	if(isturf(target))
		var/obj/machinery/door/airlock/airlock = locate() in target
		if(airlock)
			airlock.BorgCtrlShiftClick(src)
	else
		target.BorgCtrlShiftClick(src)

/mob/living/silicon/robot/ShiftClickOn(atom/target)
	if(isturf(target))
		var/obj/machinery/door/airlock/airlock = locate() in target
		if(airlock)
			airlock.BorgShiftClick(src)
	else
		target.BorgShiftClick(src)

/mob/living/silicon/robot/CtrlClickOn(atom/target)
	if(isturf(target))
		var/obj/machinery/door/airlock/airlock = locate() in target
		if(airlock)
			airlock.BorgCtrlClick(src)
	else
		target.BorgCtrlClick(src)

/turf/borg_click_alt(mob/living/silicon/robot/user)
	var/obj/machinery/door/airlock/airlock = locate() in src
	if(airlock)
		airlock.borg_click_alt(user)
		return
	return ..()
