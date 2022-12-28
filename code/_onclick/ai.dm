/*
	AI ClickOn()

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(control_disabled || incapacitated())
		return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()

/mob/living/silicon/ai/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	var/list/modifiers = params2list(params)

	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, A, modifiers) & COMSIG_MOB_CANCEL_CLICKON)
		return

	if(!can_interact_with(A))
		return

	if(multicam_on)
		var/turf/T = get_turf(A)
		if(T)
			for(var/atom/movable/screen/movable/pic_in_pic/ai/P in T.vis_locs)
				if(P.ai == src)
					P.Click(params)
					break

	if(check_click_intercept(params,A))
		return

	if(control_disabled || incapacitated())
		return

	var/turf/pixel_turf = get_turf_pixel(A)
	if(isnull(pixel_turf))
		return
	if(!can_see(A))
		return

	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			CtrlShiftClickOn(A)
			return
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK)) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(A, params)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		var/secondary_result = A.attack_ai_secondary(src, modifiers)
		if(secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
			return
		else if(secondary_result != SECONDARY_ATTACK_CALL_NORMAL)
			CRASH("attack_ai_secondary did not return a SECONDARY_ATTACK_* define.")

	if(world.time <= next_move)
		return

	if(aicamera.in_camera_mode)
		aicamera.toggle_camera_mode(sound = FALSE)
		aicamera.captureimage(pixel_turf, usr)
		return
	if(waypoint_mode)
		waypoint_mode = 0
		set_waypoint(A)
		return

	A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic; attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	A.attack_ai(src)

/mob/living/silicon/ai/RangedAttack(atom/A)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user)
	return

/**
 * What happens when the AI holds right-click on an item. Returns a SECONDARY_ATTACK_* value.
 *
 * Arguments:
 * * user The mob holding the right click
 * * modifiers The list of the custom click modifiers
 */
/atom/proc/attack_ai_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/

/mob/living/silicon/ai/CtrlShiftClickOn(atom/A)
	A.AICtrlShiftClick(src)
/mob/living/silicon/ai/ShiftClickOn(atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/ai/CtrlClickOn(atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/ai/AltClickOn(atom/A)
	A.AIAltClick(src)

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/
/* Questions: Instead of an Emag check on every function, can we not add to airlocks onclick if emag return? */

/* Atom Procs */
/atom/proc/AICtrlClick()
	return
/atom/proc/AIAltClick(mob/living/silicon/ai/user)
	AltClick(user)
	return
/atom/proc/AIShiftClick()
	return
/atom/proc/AICtrlShiftClick()
	return

/* Airlocks */
/obj/machinery/door/airlock/AICtrlClick() // Bolts doors
	if(obj_flags & EMAGGED)
		return

	toggle_bolt(usr)
	add_hiddenprint(usr)

/obj/machinery/door/airlock/AIAltClick() // Eletrifies doors.
	if(obj_flags & EMAGGED)
		return

	if(!secondsElectrified)
		shock_perm(usr)
	else
		shock_restore(usr)

/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if(obj_flags & EMAGGED)
		return

	user_toggle_open(usr)
	add_hiddenprint(usr)

/obj/machinery/door/airlock/AICtrlShiftClick()  // Sets/Unsets Emergency Access Override
	if(obj_flags & EMAGGED)
		return

	toggle_emergency(usr)
	add_hiddenprint(usr)

/* APC */
/obj/machinery/power/apc/AICtrlClick() // turns off/on APCs.
	if(can_use(usr, 1))
		toggle_breaker(usr)

/* AI Turrets */
/obj/machinery/turretid/AIAltClick() //toggles lethal on turrets
	if(ailock)
		return
	toggle_lethal(usr)

/obj/machinery/turretid/AICtrlClick() //turns off/on Turrets
	if(ailock)
		return
	toggle_on(usr)

/* Holopads */
/obj/machinery/holopad/AIAltClick(mob/living/silicon/ai/user)
	hangup_all_calls()
	add_hiddenprint(usr)

//
// Override TurfAdjacent for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(turf/T)
	return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(T))
