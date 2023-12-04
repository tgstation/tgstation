/datum/element/disarm_attack

/datum/element/disarm_attack/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_ATTACK_SECONDARY, PROC_REF(secondary_attack))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(examine))

/datum/element/disarm_attack/proc/secondary_attack(obj/item/source, mob/living/victim, mob/living/user, params)
	SIGNAL_HANDLER
	if(!can_disarm_attack(source, victim, user))
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
	if(victim.check_block(source, 0, "the [source.name]", MELEE_ATTACK, 0))
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
	user.disarm(victim, source)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/element/disarm_attack/proc/can_disarm_attack(obj/item/source, mob/living/victim, mob/living/user, message = TRUE)
	if(SEND_SIGNAL(source, COMSIG_ITEM_CAN_DISARM_ATTACK, victim, user) & COMPONENT_BLOCK_ITEM_DISARM_ATTACK)
		return FALSE
	return TRUE

/datum/element/disarm_attack/proc/examine(obj/item/source, mob/user, list/examine_list)
	if(can_disarm_attack(source, null, user, FALSE))
		examine_list += span_notice("You can use it to <b>shove</b> people with <b>right-click</b>.")
