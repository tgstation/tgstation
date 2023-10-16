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
		ai_tracking_tool.set_tracked_mob(src, A.name)
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

/mob/living/silicon/ai/CtrlShiftClickOn(atom/target)
	target.AICtrlShiftClick(src)

/mob/living/silicon/ai/ShiftClickOn(atom/target)
	target.AIShiftClick(src)

/mob/living/silicon/ai/CtrlClickOn(atom/target)
	target.AICtrlClick(src)

/mob/living/silicon/ai/AltClickOn(atom/target)
	target.AIAltClick(src)

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/
/* Questions: Instead of an Emag check on every function, can we not add to airlocks onclick if emag return? */

/* Atom Procs */
/atom/proc/AICtrlClick(mob/living/silicon/ai/user)
	return

/atom/proc/AIAltClick(mob/living/silicon/ai/user)
	AltClick(user)
	return

/atom/proc/AIShiftClick(mob/living/silicon/ai/user)
	return

/atom/proc/AICtrlShiftClick(mob/living/silicon/ai/user)
	return

/* Airlocks */
/obj/machinery/door/airlock/AICtrlClick(mob/living/silicon/ai/user) // Bolts doors
	if(obj_flags & EMAGGED)
		return

	toggle_bolt(user)
	add_hiddenprint(user)

/obj/machinery/door/airlock/AIAltClick(mob/living/silicon/ai/user) // Eletrifies doors.
	if(obj_flags & EMAGGED)
		return

	if(!secondsElectrified)
		shock_perm(user)
	else
		shock_restore(user)

/obj/machinery/door/airlock/AIShiftClick(mob/living/silicon/ai/user)  // Opens and closes doors!
	if(obj_flags & EMAGGED)
		return

	user_toggle_open(user)
	add_hiddenprint(user)

/obj/machinery/door/airlock/AICtrlShiftClick(mob/living/silicon/ai/user)  // Sets/Unsets Emergency Access Override
	if(obj_flags & EMAGGED)
		return

	toggle_emergency(user)
	add_hiddenprint(user)

/////////////
/*   APC   */
/////////////

/// Toggle APC power settings
/obj/machinery/power/apc/AICtrlClick(mob/living/silicon/ai/user)
	if(!can_use(user, loud = TRUE))
		return

	toggle_breaker(user)

/// Toggle APC environment settings (atmos)
/obj/machinery/power/apc/AICtrlShiftClick(mob/living/silicon/ai/user)
	if(!can_use(user, loud = TRUE))
		return

	if(!is_operational || failure_timer)
		return

	environ = environ ? APC_CHANNEL_OFF : APC_CHANNEL_ON
	if (user)
		add_hiddenprint(user)
		var/enabled_or_disabled = environ ? "enabled" : "disabled"
		balloon_alert(user, "environment power [enabled_or_disabled]")
		user.log_message("[enabled_or_disabled] the [src] environment settings", LOG_GAME)
	update_appearance()
	update()

/// Toggle APC lighting settings
/obj/machinery/power/apc/AIShiftClick(mob/living/silicon/ai/user)
	if(!can_use(user, loud = TRUE))
		return

	if(!is_operational || failure_timer)
		return

	lighting = lighting ? APC_CHANNEL_OFF : APC_CHANNEL_ON
	if (user)
		var/enabled_or_disabled = lighting ? "enabled" : "disabled"
		add_hiddenprint(user)
		balloon_alert(user, "lighting power toggled [enabled_or_disabled]")
		user.log_message("turned [enabled_or_disabled] the [src] lighting settings", LOG_GAME)
	update_appearance()
	update()

/// Toggle APC equipment settings
/obj/machinery/power/apc/AIAltClick(mob/living/silicon/ai/user)
	if(!can_use(user, loud = TRUE))
		return

	if(!is_operational || failure_timer)
		return

	equipment = equipment ? APC_CHANNEL_OFF : APC_CHANNEL_ON
	if (user)
		var/enabled_or_disabled = equipment ? "enabled" : "disabled"
		balloon_alert(user, "equipment power toggled [enabled_or_disabled]")
		add_hiddenprint(user)
		user.log_message("turned [enabled_or_disabled] the [src] equipment settings", LOG_GAME)
	update_appearance()
	update()

/obj/machinery/power/apc/attack_ai_secondary(mob/living/silicon/user, list/modifiers)
	if(!can_use(user, loud = TRUE))
		return

	togglelock(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/* AI Turrets */
/obj/machinery/turretid/AIAltClick(mob/living/silicon/ai/user) //toggles lethal on turrets
	if(ailock)
		return
	toggle_lethal(user)

/obj/machinery/turretid/AICtrlClick(mob/living/silicon/ai/user) //turns off/on Turrets
	if(ailock)
		return
	toggle_on(user)

/* Holopads */
/obj/machinery/holopad/AIAltClick(mob/living/silicon/ai/user)
	if (user)
		balloon_alert(user, "disrupted all active calls")
		add_hiddenprint(user)
	hangup_all_calls()

//
// Override TurfAdjacent for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(turf/target_turf)
	return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(target_turf))
