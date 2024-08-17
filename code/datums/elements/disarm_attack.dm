///An element that allows items to be used to shove people around just like right-clicking would.
/datum/element/disarm_attack

/datum/element/disarm_attack/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_ATTACK_SECONDARY, PROC_REF(secondary_attack))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(examine))

/datum/element/disarm_attack/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_ATOM_EXAMINE, COMSIG_ITEM_ATTACK_SECONDARY))
	return ..()

/datum/element/disarm_attack/proc/secondary_attack(obj/item/source, mob/living/victim, mob/living/user, params)
	SIGNAL_HANDLER
	if(!user.can_disarm(victim) || !can_disarm_attack(source, victim, user))
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
	if(victim.check_block(source, 0, "the [source.name]", MELEE_ATTACK, 0))
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
