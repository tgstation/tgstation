/**
 * # AI Held Item Element
 *
 * Manages holding an item for a mob which doesn't have hands but needs to for AI purposes.
 */
/datum/element/ai_held_item

/datum/element/ai_held_item/Attach(datum/target)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/living_target = target
	if (!living_target.ai_controller)
		return ELEMENT_INCOMPATIBLE // If there's no blackboard this would need to be a component

	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_click))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(atom_exited))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignals(target, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_death))

/// Returns the item held in a mob's blackboard, if it has one
/datum/element/ai_held_item/proc/get_held_item(mob/living/source)
	return source.ai_controller.blackboard[BB_SIMPLE_CARRY_ITEM]

/// Someone's interacting with us by hand, if we have an item and like them we'll hand it over
/datum/element/ai_held_item/proc/on_click(mob/living/source, mob/living/user)
	SIGNAL_HANDLER

	if (user.combat_mode)
		return

	if (!(user in source.ai_controller.blackboard[BB_FRIENDS_LIST]))
		return // We don't care about this bozo
	var/obj/item/carried_item = get_held_item(source)
	if (!carried_item)
		return

	source.visible_message(span_danger("[source] drops [carried_item] at [user]'s feet!"))
	carried_item.forceMove(get_turf(user))
	source.ai_controller.clear_blackboard_key(BB_SIMPLE_CARRY_ITEM)

/// If our held item is removed from our atom then take it off the blackboard
/datum/element/ai_held_item/proc/atom_exited(mob/living/source, atom/movable/gone)
	SIGNAL_HANDLER

	var/obj/item/carried_item = get_held_item(source)
	if (carried_item == gone)
		source.ai_controller.clear_blackboard_key(BB_SIMPLE_CARRY_ITEM)

/// Report that we're holding an item.
/datum/element/ai_held_item/proc/on_examined(mob/living/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	var/obj/item/carried_item = get_held_item(source)
	if (!carried_item)
		return
	examine_text += span_notice("[source.p_They()] [source.p_are()] carrying [carried_item.get_examine_string(user)].")

/// If we died, drop anything we were carrying
/datum/element/ai_held_item/proc/on_death(mob/living/ol_yeller)
	SIGNAL_HANDLER

	var/obj/item/carried_item = get_held_item(ol_yeller)
	if(!carried_item)
		return

	ol_yeller.visible_message(span_danger("[ol_yeller] drops [carried_item] as [ol_yeller.p_they()] die[ol_yeller.p_s()]."))
	carried_item.forceMove(ol_yeller.drop_location())
	ol_yeller.ai_controller.clear_blackboard_key(BB_SIMPLE_CARRY_ITEM)
