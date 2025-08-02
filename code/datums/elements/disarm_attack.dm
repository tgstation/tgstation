///An element that allows items to be used to shove people around just like right-clicking would.
/datum/element/disarm_attack

/datum/element/disarm_attack/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	var/obj/item/item = target
	RegisterSignal(item, COMSIG_ITEM_ATTACK_SECONDARY, PROC_REF(secondary_attack))
	RegisterSignal(item, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	item.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS
	RegisterSignal(item, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_item_context))

/datum/element/disarm_attack/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_ATOM_EXAMINE, COMSIG_ITEM_ATTACK_SECONDARY, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET))
	return ..()

/datum/element/disarm_attack/proc/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	SIGNAL_HANDLER
	if(!isliving(target) || !can_disarm_attack(source, target, user, FALSE))
		return NONE
	context[SCREENTIP_CONTEXT_RMB] = "Shove"
	return CONTEXTUAL_SCREENTIP_SET

/datum/element/disarm_attack/proc/secondary_attack(obj/item/source, mob/living/victim, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!user.can_disarm(victim) || !can_disarm_attack(source, victim, user))
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
	if(victim.check_block(source, 0, "\the [source]", MELEE_ATTACK, 0))
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
	user.disarm(victim, source)
	user.changeNext_move(source.secondary_attack_speed || source.attack_speed)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

///check if the item conditions for the disarm action are met.
/datum/element/disarm_attack/proc/can_disarm_attack(obj/item/source, mob/living/victim, mob/living/user, message = TRUE)
	if(SEND_SIGNAL(source, COMSIG_ITEM_CAN_DISARM_ATTACK, victim, user, message) & COMPONENT_BLOCK_ITEM_DISARM_ATTACK)
		return FALSE
	return TRUE

/datum/element/disarm_attack/proc/examine(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(can_disarm_attack(source, user, user, FALSE))
		examine_list += span_notice("You can use it to <b>shove</b> people with <b>right-click</b>.")
