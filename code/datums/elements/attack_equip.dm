/**
 * Attached to an item, when the item is used to attack a human, and the attacker isn't in combat mode, attempts to equip the item to the target after the normal delay.
 *
 * Uses the compare_zone_to_item_slot() proc to see if the attacker is targeting a valid slot.
 */
/datum/element/attack_equip

/datum/element/attack_equip/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_item_attack))

/datum/element/attack_equip/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/attack_equip/proc/on_item_attack(obj/item/attire, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(user.combat_mode || !ishuman(target) || target == user)
		return

	var/mob/living/carbon/human/sharp_dresser = target
	var/targeted_zone = user.zone_selected

	if(!attire.compare_zone_to_item_slot(targeted_zone))
		return

	if(attire.mob_can_equip(target, attire.slot_flags, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		INVOKE_ASYNC(src, PROC_REF(equip), attire, sharp_dresser, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN


/datum/element/attack_equip/proc/equip(obj/item/attire, mob/living/carbon/human/sharp_dresser, mob/living/user)

	if(HAS_TRAIT(attire, TRAIT_NODROP))
		to_chat(user, span_warning("You can't put [attire] on [sharp_dresser], it's stuck to your hand!"))
		return
	var/equip_time = attire.equip_delay_other

	attire.item_start_equip(sharp_dresser, attire, user)

	if(!do_after(user, equip_time, sharp_dresser))
		return

	if(!user.Adjacent(sharp_dresser)) // Due to teleporting shenanigans
		user.put_in_hands(attire)
		return

	user.temporarilyRemoveItemFromInventory(attire)
	//we've spent time based on the item's equip_delay_other already, so we don't need to wait more on a self-equip timer
	sharp_dresser.equip_to_slot_if_possible(attire, attire.slot_flags, bypass_equip_delay_self = TRUE)

	return finish_equip_mob(attire, sharp_dresser, user)
