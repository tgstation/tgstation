/**
 * ### Base proc for alt click interaction left click.
 *
 * If you wish to add custom `click_alt` behavior for a single type, use that proc.
 */
/mob/proc/base_click_alt(atom/target)
	SHOULD_NOT_OVERRIDE(TRUE)

	// Check if they've hooked in to prevent src from alt clicking anything
	if(SEND_SIGNAL(src, COMSIG_MOB_ALTCLICKON, target) & COMSIG_MOB_CANCEL_CLICKON)
		return

	// Is it visible (and we're not wearing it (our clothes are invisible))?
	if(!CAN_I_SEE(target))
		return

	if(is_blind() && !IN_GIVEN_RANGE(src, target, 1))
		return

	var/turf/tile = get_turf(target)

	// Ghosties just see loot
	if(isobserver(src) || isrevenant(src))
		client.loot_panel.open(tile)
		return

	var/can_use_click_action = FALSE
	if(isturf(target))
		// Turfs are special because they can't be used with can_perform_action
		can_use_click_action = can_perform_turf_action(target)
	else
		can_use_click_action = can_perform_action(target, (target.interaction_flags_click | SILENT_ADJACENCY))

	if(can_use_click_action)
		// If it has a signal handler that returns a click action, done.
		if(SEND_SIGNAL(target, COMSIG_CLICK_ALT, src) & CLICK_ACTION_ANY)
			return

		// If it has a custom click_alt that returns success/block, done.
		if(target.click_alt(src) & CLICK_ACTION_ANY)
			return

	// No alt clicking to view turf from beneath
	if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING))
		return

	/// No loot panel if it's on our person
	if(isobj(target) && isliving(src))
		var/mob/living/user = src
		if(target in user.get_all_gear())
			to_chat(user, span_warning("You can't search for this item, it's already in your inventory! Take it off first."))
			return

	client.loot_panel.open(tile)

/**
 * ## Custom alt click interaction
 * Override this to change default alt click behavior. Return `CLICK_ACTION_SUCCESS`, `CLICK_ACTION_BLOCKING` or `NONE`.
 *
 * ### Guard clauses
 * Consider adding `interaction_flags_click` before adding unique guard clauses.
 *
 * ### Return flags
 * Forgetting your return will cause the default alt click behavior to occur thereafter.
 *
 * The difference between NONE and BLOCKING can get hazy, but I like to keep NONE limited to guard clauses and "never" cases.
 *
 * A good usage for BLOCKING over NONE is when it's situational for the item and there's some feedback indicating this.
 *
 * ### Examples:
 * User is a ghost, alt clicks on item with special disk eject: NONE
 *
 * Machine broken, no feedback: NONE
 *
 * Alt click a pipe to max output but its already max: BLOCKING
 *
 * Alt click a gun that normally works, but is out of ammo: BLOCKING
 *
 * User unauthorized, machine beeps: BLOCKING
 *
 * @param {mob} user - The person doing the alt clicking.
 */
/atom/proc/click_alt(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	return NONE


/**
 * ### Base proc for alt click interaction right click.
 *
 * If you wish to add custom `click_alt_secondary` behavior for a single type, use that proc.
 */
/mob/proc/base_click_alt_secondary(atom/target)
	SHOULD_NOT_OVERRIDE(TRUE)

	//Hook on the mob to intercept the click
	if(SEND_SIGNAL(src, COMSIG_MOB_ALTCLICKON_SECONDARY, target) & COMSIG_MOB_CANCEL_CLICKON)
		return

	var/can_use_click_action = FALSE
	if(isturf(target))
		// Turfs are special because they can't be used with can_perform_action
		can_use_click_action = can_perform_turf_action(target)
	else
		can_use_click_action = can_perform_action(target, target.interaction_flags_click | SILENT_ADJACENCY)
	if(!can_use_click_action)
		return

	//Hook on the atom to intercept the click
	if(SEND_SIGNAL(target, COMSIG_CLICK_ALT_SECONDARY, src) & COMPONENT_CANCEL_CLICK_ALT_SECONDARY)
		return
	if(isobserver(src) && client && check_rights_for(client, R_DEBUG))
		client.toggle_tag_datum(src)
		return
	target.click_alt_secondary(src)

/**
 * ## Custom alt click secondary interaction
 * Override this to change default alt right click behavior.
 *
 * ### Guard clauses
 * Consider adding `interaction_flags_click` before adding unique guard clauses.
 **/
/atom/proc/click_alt_secondary(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	return NONE

/// Helper proc to validate turfs. Used because can_perform_action does not support turfs.
/mob/proc/can_perform_turf_action(turf/target)
	if(!CanReach(target)) // No error message for parity with SILENT_ADJACENCY
		return FALSE

	if(incapacitated())
		to_chat(src, span_warning("You can't use this!"))
		return FALSE

	return TRUE
