/**
 * Ctrl click
 */
/mob/proc/CtrlClickOn(atom/A)
	base_ctrl_click(A)
	return

/**
 * Ctrl click
 * Return TRUE if the ctrl click was handled at some point. FALSE means nothing was done
 */
/mob/proc/base_ctrl_click(atom/target)
	SHOULD_NOT_OVERRIDE(TRUE)

	// Check if they've hooked in to prevent src from ctrl clicking anything
	if(SEND_SIGNAL(src, COMSIG_MOB_CTRL_CLICKED, target) & COMSIG_MOB_CANCEL_CLICKON)
		return TRUE

	var/can_use_click_action = FALSE
	if(isturf(target))
		// Turfs are special because they can't be used with can_perform_action
		can_use_click_action = can_perform_turf_action(target)
	else
		can_use_click_action = can_perform_action(target, target.interaction_flags_click | SILENT_ADJACENCY)

	. = TRUE
	if(can_use_click_action)
		// If it has a signal handler that returns a click action, done.
		if(SEND_SIGNAL(target, COMSIG_CLICK_CTRL, src) & CLICK_ACTION_ANY)
			return FALSE

		// If it has a custom click_alt that returns success/block, done.
		if(!(target.ctrl_click(src) & CLICK_ACTION_ANY))
			. = FALSE

/**
 * Ctrl click
 * For most objects, pull
 */
/mob/living/base_ctrl_click(atom/target)
	SHOULD_NOT_OVERRIDE(TRUE)

	. = ..()
	if(. || world.time < next_move || !CanReach(target))
		return

	. = TRUE
	if(grab(target))
		changeNext_move(CLICK_CD_MELEE)
		return
	pulled(target)


/**
 * Ctrl mouse wheel click
 * Except for tagging datumns same as control click
 */
/mob/proc/CtrlMiddleClickOn(atom/A)
	if(check_rights_for(client, R_ADMIN))
		client.toggle_tag_datum(A)
		return
	CtrlClickOn(A)

/**
 * ## Custom ctrl click interaction
 * Override this to change default ctrl click behavior. Return `CLICK_ACTION_SUCCESS`, `CLICK_ACTION_BLOCKING` or `NONE`.
 *
 * ### Guard clauses
 * Consider adding `interaction_flags_click` before adding unique guard clauses.
 *
 * ### Return flags
 * Forgetting your return will cause the default ctrl click behavior to occur thereafter.
 *
 * Returning any value besides NONE will stop the attack chain and thus stop the object from getting pulled/grabbed
 **/
/atom/proc/ctrl_click(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	return NONE


/**
 * Control+Shift click
 * Unused except for AI
 */
/mob/proc/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)

/atom/proc/CtrlShiftClick(mob/user)
	if(!can_interact(user))
		return FALSE
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL_SHIFT, user)
	return
