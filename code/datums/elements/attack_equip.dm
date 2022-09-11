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
	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/on_item_attack)

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

	if(attire.mob_can_equip(target, user,  attire.slot_flags, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		INVOKE_ASYNC(src, .proc/equip, attire, sharp_dresser, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN


/datum/element/attack_equip/proc/equip(obj/item/attire, mob/living/carbon/human/sharp_dresser, mob/living/user)

	if(HAS_TRAIT(attire, TRAIT_NODROP))
		to_chat(user, span_warning("You can't put [attire] on [sharp_dresser], it's stuck to your hand!"))
		return
	var/equip_time = attire.equip_delay_other
	if(isclothing(attire))
		var/obj/item/clothing/fancy_tux = attire
		if(fancy_tux.clothing_flags == DANGEROUS_OBJECT) // give us danger text if we have a dangerous object on our hands
			sharp_dresser.visible_message(
				span_danger("[user] tries to put [attire] on [sharp_dresser]."),
				span_userdanger("[user] tries to put [attire] on you."),
				ignored_mobs = user,
			)
		else
			sharp_dresser.visible_message(
				span_notice("[user] tries to put [attire] on [sharp_dresser]."),
				span_notice("[user] tries to put [attire] on you."),
				ignored_mobs = user,
			)
	if(sharp_dresser.is_blind())
		to_chat(sharp_dresser, span_userdanger("You feel someone trying to put something on you."))

	to_chat(user, span_notice("You try to put [attire] on [sharp_dresser]..."))

	user.log_message("is putting [attire] on [key_name(sharp_dresser)]", LOG_ATTACK, color="red")
	sharp_dresser.log_message("is having [attire] put on them by [key_name(user)]", LOG_VICTIM, color="orange", log_globally=FALSE)

	if(!do_mob(user, sharp_dresser, equip_time))
		return

	if(QDELETED(src) || QDELETED(sharp_dresser))
		return

	if(!user.Adjacent(sharp_dresser)) // Due to teleporting shenanigans
		user.put_in_hands(attire)
		return

	user.temporarilyRemoveItemFromInventory(attire)

	sharp_dresser.equip_to_slot_if_possible(attire, attire.slot_flags)

	return finish_equip_mob(attire, sharp_dresser, user)
