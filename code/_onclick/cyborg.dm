<<<<<<< HEAD
/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(var/atom/A, var/params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.click_intercept)
		if(call(client.click_intercept,"InterceptClickOn")(src,params,A))
			return

	if(stat || lockcharge || weakened || stunned || paralysis)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(next_move >= world.time)
		return

	face_atom(A) // change direction to face what you clicked on

	/*
	cyborg restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
		return
	*/
	if(aicamera.in_camera_mode) //Cyborg picture taking
		aicamera.camera_mode_off()
		aicamera.captureimage(A, usr)
		return

	var/obj/item/W = get_active_hand()

	// Cyborgs have no range-checking unless there is item use
	if(!W)
		A.attack_robot(src)
		return

	// buckled cannot prevent machine interlinking but stops arm movement
	if( buckled || incapacitated())
		return

	if(W == A)
		W.attack_self(src)
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
	if(A == loc || (A in loc) || (A in contents))
		// No adjacency checks
		var/resolved = A.attackby(W,src, params)
		if(!resolved && A && W)
			W.afterattack(A,src,1,params)
		return

	if(!isturf(loc))
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc && isturf(A.loc.loc))
	if(isturf(A) || isturf(A.loc))
		if(A.Adjacent(src)) // see adjacent.dm
			var/resolved = A.attackby(W, src, params)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, params)
			return
		else
			W.afterattack(A, src, 0, params)
			return
	return

//Middle click cycles through selected modules.
/mob/living/silicon/robot/MiddleClickOn(atom/A)
	cycle_modules()
	return

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/robot/CtrlShiftClickOn(atom/A)
	A.BorgCtrlShiftClick(src)
/mob/living/silicon/robot/ShiftClickOn(atom/A)
	A.BorgShiftClick(src)
/mob/living/silicon/robot/CtrlClickOn(atom/A)
	A.BorgCtrlClick(src)
/mob/living/silicon/robot/AltClickOn(atom/A)
	A.BorgAltClick(src)

/atom/proc/BorgCtrlShiftClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlShiftClick(user)

/obj/machinery/door/airlock/BorgCtrlShiftClick() // Sets/Unsets Emergency Access Override Forwards to AI code.
	AICtrlShiftClick()


/atom/proc/BorgShiftClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	ShiftClick(user)

/obj/machinery/door/airlock/BorgShiftClick()  // Opens and closes doors! Forwards to AI code.
	AIShiftClick()


/atom/proc/BorgCtrlClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlClick(user)

/obj/machinery/door/airlock/BorgCtrlClick() // Bolts doors. Forwards to AI code.
	AICtrlClick()

/obj/machinery/power/apc/BorgCtrlClick() // turns off/on APCs. Forwards to AI code.
	AICtrlClick()

/obj/machinery/turretid/BorgCtrlClick() //turret control on/off. Forwards to AI code.
	AICtrlClick()

/atom/proc/BorgAltClick(mob/living/silicon/robot/user)
	AltClick(user)
	return

/obj/machinery/door/airlock/BorgAltClick() // Eletrifies doors. Forwards to AI code.
	AIAltClick()

/obj/machinery/turretid/BorgAltClick() //turret lethal on/off. Forwards to AI code.
	AIAltClick()

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	A.attack_robot(src)
/mob/living/silicon/robot/RangedAttack(atom/A)
	A.attack_robot(src)

/atom/proc/attack_robot(mob/user)
	attack_ai(user)
	return
=======
/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(var/atom/A, var/params)
	if(click_delayer.blocked())
		return
	click_delayer.setDelay(1)

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	if(incapacitated() || lockcharge)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(attack_delayer.blocked())
		return
	if(isVentCrawling())
		to_chat(src, "<span class='danger'>Not while we're vent crawling!</span>")
		return
	face_atom(A) // change direction to face what you clicked on

	/*
	cyborg restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
		return
	*/

	var/obj/item/W = get_active_hand()

	// Cyborgs have no range-checking unless there is item use
	if(!W)
		A.add_hiddenprint(src)
		A.attack_robot(src)
		return

	// locked_to cannot prevent machine interlinking but stops arm movement
	if(locked_to)
		return

	if(W == A)
		/*next_move = world.time + 8
		if(W.flags&USEDELAY)
			next_move += 5
		*/
		W.attack_self(src, params)
		return

	if(!isturf(loc) && !is_holder_of(src, A)) // Can't touch anything from inside a locker/cyborg recharging station etc, unless it's inside our inventory.
		return

	if(A.Adjacent(src, MAX_ITEM_DEPTH)) // see adjacent.dm
		/*next_move = world.time + 10
		if(W.flags&USEDELAY)
			next_move += 5
		*/
		var/resolved = W.preattack(A, src, 1, params)
		if(!resolved)
			resolved = A.attackby(W,src,params)
			if(ismob(A) || istype(A, /obj/mecha))
				delayNextAttack(10)
			if(!resolved && A && W)
				W.afterattack(A,src,1,params) // 1 indicates adjacency
			else
				delayNextAttack(10)
		return
	else
		//next_move = world.time + 10
		W.afterattack(A, src, 0, params)
		return
	return

//Middle click cycles through selected modules.
/mob/living/silicon/robot/MiddleClickOn(var/atom/A)
	cycle_modules()
	return

//Middle click cycles through selected modules.
/mob/living/silicon/robot/AltClickOn(var/atom/A)
	//Borgs dont need a quick shock hotkey, just in case
	/*
	if(istype(A, /obj/machinery/door/airlock))
		A.AIAltClick(src)
		return
	*/
	. = ..()
	if(.)
		return
	if(isturf(A))
		A.RobotAltClick(src)
		return
	A.RobotAltClick(src)
	return

/mob/living/silicon/robot/ShiftClickOn(var/atom/A)
	//Borgs can into doors as well
	if(istype(A, /obj/machinery/door/airlock))
		A.AIShiftClick(src)
		return
	..()

/mob/living/silicon/robot/CtrlClickOn(var/atom/A)
	//Borgs can into doors as well
	if(istype(A, /obj/machinery/door/airlock))
		A.AICtrlClick(src)
		return
	..()

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	if(ismob(A))
		delayNextAttack(10)
	A.attack_robot(src)
	return
/mob/living/silicon/robot/RangedAttack(atom/A)
	A.attack_robot(src)

/atom/proc/attack_robot(mob/user as mob)
	attack_ai(user)
	return


// /vg/: Alt-click.
/atom/proc/RobotAltClick()
	return

// /vg/: Alt-click to open shit
/* not anymore
/obj/machinery/door/airlock/RobotAltClick() // Opens doors
	if(density)
		Topic("aiEnable=7", list("aiEnable"="7"), 1) // 1 meaning no window (consistency!)
	else
		Topic("aiDisable=7", list("aiDisable"="7"), 1)*/
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
