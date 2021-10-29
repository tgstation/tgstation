/////////////////////
/////AI Changes//////
/////////////////////
/mob/living/silicon/ai/CtrlShiftClickOn(atom/A)
	if(isturf(A)) 
		var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in A
		if(airlock)
			airlock.AICtrlShiftClick(src)
	else
		A.AICtrlShiftClick(src) // End of skyrat edit

/mob/living/silicon/ai/ShiftClickOn(atom/A)
	if(isturf(A)) 
		var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in A
		if(airlock)
			airlock.AIShiftClick(src)
	else
		A.AIShiftClick(src)
		A.AIExamine(A)

/mob/living/silicon/ai/CtrlClickOn(atom/A)
	if(isturf(A)) 
		var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in A
		if(airlock)
			airlock.AICtrlClick(src)
	else
		A.AICtrlClick(src)

/mob/living/silicon/ai/AltClickOn(atom/A)
	if(isturf(A)) 
		var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in A
		if(airlock)
			airlock.AIAltClick(src)
	else
		A.AIAltClick(src)

/atom/proc/AIExamine() // Used for AI specific examines .Currently only employed to stop door examines.
	usr.examinate(src)

// Should keep all AI Examines in here in a list.
/obj/machinery/door/airlock/AIExamine() // Lets not spam the AI with door examinations
	return
	
/mob/living/silicon/ai/ClickOn(atom/A, params)
	..()
	var/list/modifiers = params2list(params)
	if(isturf(A)&&(!modifiers)) // Have to check for modifiers.
		var/obj/machinery/door/firedoor/TheDoor = locate(/obj/machinery/door/firedoor) in A
		if(TheDoor)
			TheDoor.attack_ai(usr)
			
/////////////////////////
/////Cyborg changes//////
/////////////////////////
/mob/living/silicon/robot/CtrlShiftClickOn(atom/A)
	if(isturf(A)) 
		var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in A // Skyrat edit
		if(airlock)
			airlock.BorgCtrlShiftClick(src)
	else
		A.BorgCtrlShiftClick(src) 

/mob/living/silicon/robot/ShiftClickOn(atom/A)
	if(isturf(A)) 
		var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in A // Skyrat edit
		if(airlock)
			airlock.BorgShiftClick(src)
	else
		A.BorgShiftClick(src) 

/mob/living/silicon/robot/CtrlClickOn(atom/A)
	if(isturf(A))
		var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in A // Skyrat edit
		if(airlock)
			airlock.BorgCtrlClick(src)
	else
		A.BorgCtrlClick(src) // End of skyrat edit

/mob/living/silicon/robot/AltClickOn(atom/A)
	if(isturf(A)) 
		var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in A // Skyrat edit
		if(airlock)
			airlock.BorgAltClick(src)
	else
		A.BorgAltClick(src) 
