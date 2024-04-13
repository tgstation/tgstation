/**
 * Base proc for alt click interaction. Do not call this directly.
 *
 * If you wish to use custom alt_click behavior, use that proc.
 */
/mob/proc/base_click_alt(atom/thing)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	var/early_sig_return = SEND_SIGNAL(src, COMSIG_CLICK_ALT, thing)
	if(early_sig_return)
		return early_sig_return

	var/alt_click_return = thing.click_alt(src)
	if(alt_click_return)
		return alt_click_return

	if(!can_interact_with(thing))
		return

	// TODO: Replace
	var/turf/T = get_turf(thing)
	if(T && (isturf(thing.loc) || isturf(thing)) && TurfAdjacent(T) && !HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING))
		set_listed_turf(T)


/**
 * Called when this atom has been alt clicked.
 *
 * Override this proc with your custom behavior, then return a CLICK_ACTION_* flag to handle further actions
 *
 * Return NONE to continue the base alt click behavior.
 */
/atom/proc/click_alt(mob/user)
	return NONE
