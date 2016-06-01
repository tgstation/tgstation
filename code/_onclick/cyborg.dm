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
