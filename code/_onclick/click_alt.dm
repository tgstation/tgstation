/**
 * Base proc for alt click interaction.
 *
 * If you wish to use custom alt_click behavior, use that proc.
 */
/atom/proc/base_click_alt(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	if(!can_interact(user))
		return

	var/early_sig_return = SEND_SIGNAL(src, COMSIG_CLICK_ALT, user) & COMPONENT_CANCEL_CLICK_ALT
	if(early_sig_return)
		return early_sig_return

	var/alt_click_return = click_alt(user)
	if(alt_click_return)
		return alt_click_return

	// TODO: Replace
	var/turf/T = get_turf(src)
	if(T && (isturf(loc) || isturf(src)) && user.TurfAdjacent(T) && !HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING))
		user.set_listed_turf(T)


/**
 * Called when this atom has been alt clicked.
 *
 * Override this proc with your custom behavior, then return a CLICK_ACTION_* flag to handle further actions
 *
 * CLICK_ACTION_SUCCESS, CLICK_ACTION_FAILURE will prevent alt click from continuing.
 *
 * `return NONE` or `return` to continue the base alt click behavior. (favor explicit)
 */
/atom/proc/click_alt(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	return NONE
