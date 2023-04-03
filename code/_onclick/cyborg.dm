/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(check_click_intercept(params,A))
		return

	if(stat || (lockcharge) || IsParalyzed() || IsStun())
		return

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			CtrlShiftClickOn(A)
			return
		if(LAZYACCESS(modifiers, MIDDLE_CLICK))
			ShiftMiddleClickOn(A)
			return
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(A, params)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK)) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK) && !module_active)
		var/secondary_result = A.attack_robot_secondary(src, modifiers)
		if(secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
			return
		else if (secondary_result != SECONDARY_ATTACK_CALL_NORMAL)
			CRASH("attack_robot_secondary did not return a SECONDARY_ATTACK_* define.")

	if(next_move >= world.time)
		return

	face_atom(A) // change direction to face what you clicked on

	if(aicamera.in_camera_mode) //Cyborg picture taking
		aicamera.toggle_camera_mode(sound = FALSE)
		aicamera.captureimage(A, usr)
		return

	var/obj/item/W = get_active_held_item()

	if(!W && get_dist(src,A) <= interaction_range)
		A.attack_robot(src)
		return

	if(W)
		if(incapacitated())
			return

		//while buckled, you can still connect to and control things like doors, but you can't use your modules
		if(buckled)
			to_chat(src, span_warning("You can't use modules while buckled to [buckled]!"))
			return

		//if your "hands" are blocked you shouldn't be able to use modules
		if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
			return

		if(W == A)
			W.attack_self(src)
			return

		// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
		if(A == loc || (A in loc) || (A in contents))
			W.melee_attack_chain(src, A, params)
			return

		if(!isturf(loc))
			return

		// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc && isturf(A.loc.loc))
		if(isturf(A) || isturf(A.loc))
			if(A.Adjacent(src)) // see adjacent.dm
				W.melee_attack_chain(src, A, params)
				return
			else
				W.afterattack(A, src, 0, params)
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

/atom/proc/BorgCtrlShiftClick(mob/living/silicon/robot/user) //forward to human click if not overridden
	CtrlShiftClick(user)

/obj/machinery/door/airlock/BorgCtrlShiftClick(mob/living/silicon/robot/user) // Sets/Unsets Emergency Access Override Forwards to AI code.
	if(get_dist(src,user) <= user.interaction_range)
		AICtrlShiftClick()
	else
		..()


/atom/proc/BorgShiftClick(mob/living/silicon/robot/user) //forward to human click if not overridden
	ShiftClick(user)

/obj/machinery/door/airlock/BorgShiftClick(mob/living/silicon/robot/user)  // Opens and closes doors! Forwards to AI code.
	if(get_dist(src,user) <= user.interaction_range)
		AIShiftClick()
	else
		..()


/atom/proc/BorgCtrlClick(mob/living/silicon/robot/user) //forward to human click if not overridden
	CtrlClick(user)

/obj/machinery/door/airlock/BorgCtrlClick(mob/living/silicon/robot/user) // Bolts doors. Forwards to AI code.
	if(get_dist(src,user) <= user.interaction_range)
		AICtrlClick()
	else
		..()

/obj/machinery/power/apc/BorgCtrlClick(mob/living/silicon/robot/user) // turns off/on APCs. Forwards to AI code.
	if(get_dist(src,user) <= user.interaction_range)
		AICtrlClick()
	else
		..()

/obj/machinery/turretid/BorgCtrlClick(mob/living/silicon/robot/user) //turret control on/off. Forwards to AI code.
	if(get_dist(src,user) <= user.interaction_range)
		AICtrlClick()
	else
		..()

/atom/proc/BorgAltClick(mob/living/silicon/robot/user)
	AltClick(user)
	return

/obj/machinery/door/airlock/BorgAltClick(mob/living/silicon/robot/user) // Eletrifies doors. Forwards to AI code.
	if(get_dist(src,user) <= user.interaction_range)
		AIAltClick()
	else
		..()

/obj/machinery/turretid/BorgAltClick(mob/living/silicon/robot/user) //turret lethal on/off. Forwards to AI code.
	if(get_dist(src,user) <= user.interaction_range)
		AIAltClick()
	else
		..()

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_robot(src)

/mob/living/silicon/robot/RangedAttack(atom/A)
	A.attack_robot(src)

/atom/proc/attack_robot(mob/user)
	if (SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ROBOT, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return

	attack_ai(user)
	return

/**
 * What happens when the cyborg without active module holds right-click on an item. Returns a SECONDARY_ATTACK_* value.
 *
 * Arguments:
 * * user The mob holding the right click
 * * modifiers The list of the custom click modifiers
 */
/atom/proc/attack_robot_secondary(mob/user, list/modifiers)
	if (SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ROBOT_SECONDARY, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return

	return attack_ai_secondary(user, modifiers)
