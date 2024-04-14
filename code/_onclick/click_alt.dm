/**
 * Base proc for alt click interaction.
 *
 * If you wish to use custom alt_click behavior, use that proc.
 * Override this if you want to change all alt-click behavior for a type.
 */
/atom/proc/base_click_alt(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	if(can_interact(user))
		var/early_sig_return = SEND_SIGNAL(src, COMSIG_CLICK_ALT, user) & CLICK_ACTION_ANY
		if(early_sig_return)
			return early_sig_return

		var/alt_click_return = click_alt(user)
		if(alt_click_return)
			return alt_click_return

	var/turf/tile = get_turf(src)
	if(!tile.Adjacent(user))
		return

	if(HAS_TRAIT(user, TRAIT_MOVE_VENTCRAWLING))
		return

	var/datum/lootpanel/panel = user.client?.loot_panel
	if(isnull(panel))
		return

	panel.open(tile)
	return


/**
 * ## Custom alt click interaction
 * Override this to change default alt click behavior. Return `CLICK_ACTION_SUCCESS`, `CLICK_ACTION_BLOCKING` or `NONE`.
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
