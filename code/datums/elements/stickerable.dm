/// Apply to an item to make it so you can click on anything with that item to stick it as a sticker
/datum/element/stickerable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/max = 15
	var/examine_text

/datum/element/stickerable/Attach(datum/target, max = 15, examine_text)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.max = max
	src.examine_text = examine_text
	RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_item_interact))
	RegisterSignal(target, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))

/datum/element/stickerable/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM)
	UnregisterSignal(target, COMSIG_MOVABLE_BUMP)
	return ..()

/datum/element/stickerable/proc/on_item_interact(obj/item/source, mob/living/user, atom/interacting_with, list/modifiers)
	SIGNAL_HANDLER

	var/cursor_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/cursor_y = text2num(LAZYACCESS(modifiers, ICON_Y))

	if(isnull(cursor_x) || isnull(cursor_y))
		return NONE

	if(attempt_attach(source, interacting_with, user, cursor_x, cursor_y))
		return ITEM_INTERACT_SUCCESS

	return NONE

/datum/element/stickerable/proc/on_bump(obj/item/source, atom/bumped_atom)
	SIGNAL_HANDLER

	if(prob(50) && attempt_attach(source, bumped_atom))
		bumped_atom.balloon_alert_to_viewers("sticker landed on sticky side!")
		return COMPONENT_INTERCEPT_BUMPED
	return NONE

/**
 * Attempts to attach sticker to an object. Returns `FALSE` if atom has more than
 * `MAX_STICKER_COUNT` stickers, `TRUE` otherwise. If no `px` or `py` were passed
 * picks random coordinates based on a `target`'s icon.
 */
/datum/element/stickerable/proc/attempt_attach(obj/item/source, atom/target, mob/user, px, py)
	if(COUNT_TRAIT_SOURCES(target, TRAIT_STICKERED) >= max)
		source.balloon_alert_to_viewers("sticker won't stick!")
		return FALSE

	if(isnull(px) || isnull(py))
		var/icon/target_mask = icon(target.icon, target.icon_state)

		if(isnull(px))
			px = rand(1, target_mask.Width())

		if(isnull(py))
			py = rand(1, target_mask.Height())

	if(!isnull(user))
		user.do_attack_animation(target, used_item = source)
		target.balloon_alert(user, "sticker sticked")
		var/mob/living/victim = target
		if(istype(victim) && !isnull(victim.client))
			user.log_message("stuck [source] to [key_name(victim)]", LOG_ATTACK)
			victim.log_message("had [source] stuck to them by [key_name(user)]", LOG_ATTACK)

	target.AddComponent(/datum/component/sticker, source, get_dir(target, source), px, py, null, null, examine_text)
	return TRUE
