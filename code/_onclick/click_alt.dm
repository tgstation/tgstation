/**
 * ### Base proc for alt click interaction.
 *
 * If you wish to add custom `click_alt` behavior for a single type, use that proc.
 */
/mob/proc/base_click_alt(atom/target)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/turf/tile = isturf(target) ? target : get_turf(target)

	if(isobserver(src) || isrevenant(src))
		open_lootpanel(tile)
		return

	if(!isturf(target) && can_perform_action(target, (target.interaction_flags_click | SILENT_ADJACENCY)))
		if(SEND_SIGNAL(target, COMSIG_CLICK_ALT, src) & CLICK_ACTION_ANY)
			return

		if(target.click_alt(src) & CLICK_ACTION_ANY)
			return

	open_lootpanel(tile)


/// Helper for opening the lootpanel
/mob/proc/open_lootpanel(turf/target)
	if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING))
		return

	var/datum/lootpanel/panel = client?.loot_panel
	if(isnull(panel))
		return

	panel.open(target)


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
