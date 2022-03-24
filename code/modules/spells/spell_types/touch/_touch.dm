/datum/action/cooldown/spell/touch
	// Touch spells don't after_cast:
	// Sound and invocation is handled when the touch ACTUALLY hits a target
	sound = 'sound/items/welder.ogg'
	invocation = "High Five!"
	invocation_type = INVOCATION_SHOUT

	/// Typepath of what hand we create on initial cast.
	var/obj/item/melee/touch_attack/hand_path = /obj/item/melee/touch_attack
	/// Ref to the hand we currently have deployed.
	var/obj/item/melee/touch_attack/attached_hand
	/// The message displayed to the person upon creating the touch hand
	var/draw_message = span_notice("You channel the power of the spell to your hand.")
	/// The message displayed upon willingly dropping / deleting / cancelling the touch hand before using it
	var/drop_message = span_notice("You draw the power out of your hand.")

/datum/action/cooldown/spell/touch/Destroy()
	remove_hand()
	return ..()

/datum/action/cooldown/spell/touch/can_cast_spell()
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(!(carbon_owner.mobility_flags & MOBILITY_USE))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/**
 * Creates a new hand_path hand and equips it to the caster.
 *
 * If the equipping action fails, reverts the cooldown and returns FALSE.
 * Otherwise, registers signals and returns TRUE.
 */
/datum/action/cooldown/spell/touch/proc/create_hand(mob/living/carbon/cast_on)
	var/obj/item/melee/touch_attack/new_hand = new hand_path(cast_on)
	if(!cast_on.put_in_hands(new_hand, del_on_fail = TRUE))
		revert_cast()
		if (cast_on.usable_hands == 0)
			to_chat(cast_on, span_warning("You dont have any usable hands!"))
		else
			to_chat(cast_on, span_warning("Your hands are full!"))
		return FALSE

	attached_hand = new_hand
	RegisterSignal(attached_hand, COMSIG_ITEM_AFTERATTACK, .proc/on_hand_hit)
	RegisterSignal(attached_hand, COMSIG_ITEM_AFTERATTACK_SECONDARY, .proc/on_secondary_hand_hit)
	RegisterSignal(attached_hand, COMSIG_PARENT_QDELETING, .proc/on_hand_deleted)
	RegisterSignal(attached_hand, COMSIG_ITEM_DROPPED, .proc/on_hand_dropped)
	to_chat(cast_on, draw_message)
	return TRUE

/**
 * Unregisters any signals and deletes the hand currently summoned by the spell.
 *
 * If revert_after is TRUE, we will additionally refund the cooldown of the spell.
 */
/datum/action/cooldown/spell/touch/proc/remove_hand(mob/living/hand_owner, revert_after = FALSE)
	if(!QDELETED(attached_hand))
		UnregisterSignal(attached_hand, list(COMSIG_ITEM_AFTERATTACK, COMSIG_ITEM_AFTERATTACK_SECONDARY, COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED))
		hand_owner?.temporarilyRemoveItemFromInventory(attached_hand)
		QDEL_NULL(attached_hand)

	if(revert_after)
		if(hand_owner)
			to_chat(hand_owner, drop_message)
		revert_cast()

/datum/action/cooldown/spell/touch/cast(mob/living/carbon/cast_on)
	if(!QDELETED(attached_hand) && (attached_hand in cast_on.held_items))
		remove_hand(cast_on, revert_after = TRUE)
		return

	create_hand(cast_on)
	return ..()

	/* TODO need a way to pause cooldown for this
	for(var/mob/living/carbon/C in targets)
		if(!attached_hand)
			if(ChargeHand(C))
				recharging = FALSE
				return
	*/

// Overrides spell_feedback, as invocation / sounds are done when the hand hits someone
/datum/action/cooldown/spell/touch/spell_feedback()
	return

/**
 * Signal proc for [COMSIG_ITEM_AFTERATTACK] from our attached hand.
 *
 * When our hand hits an atom, we can cast do_hand_hit() on them.
 */
/datum/action/cooldown/spell/touch/proc/on_hand_hit(datum/source, atom/victim, mob/caster, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	if(victim == caster)
		return
	if(!can_cast_spell())
		return

	INVOKE_ASYNC(src, .proc/do_hand_hit, source, victim, caster)

/**
 * Signal proc for [COMSIG_ITEM_AFTERATTACK_SECONDARY] from our attached hand.
 *
 * Same as on_hand_hit, but for if right-click was used on hit.
 */
/datum/action/cooldown/spell/touch/proc/on_secondary_hand_hit(datum/source, atom/victim, mob/caster, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	if(victim == caster)
		return
	if(!can_cast_spell())
		return

	INVOKE_ASYNC(src, .proc/do_secondary_hand_hit, source, victim, caster)

/**
 * Calls cast_on_hand_hit() from the caster onto the victim.
 */
/datum/action/cooldown/spell/touch/proc/do_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(!cast_on_hand_hit(hand, victim, caster))
		return

	invocation()
	if(sound)
		playsound(get_turf(owner), sound, 50, TRUE)

	remove_hand(caster)

/**
 * Calls do_secondary_hand_hit() from the caster onto the victim.
 */
/datum/action/cooldown/spell/touch/proc/do_secondary_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/secondary_result = cast_on_secondary_hand_hit(hand, victim, caster)
	switch(secondary_result)
		// Continue will remove the hand here and stop
		if(SECONDARY_ATTACK_CONTINUE_CHAIN)
			invocation()
			if(sound)
				playsound(get_turf(owner), sound, 50, TRUE)

			remove_hand(caster)

		// Call normal will call the normal cast proc
		if(SECONDARY_ATTACK_CALL_NORMAL)
			do_hand_hit(hand, victim, caster)

		// Cancel chain will do nothing,

/**
 * The actual process of casting the spell on the victim from the caster.
 *
 * Override / extend this to implement casting effects.
 * Return TRUE on a successful cast to use up the hand (delete it)
 * Return FALSE to do nothing and let them keep the hand in hand
 */
/datum/action/cooldown/spell/touch/proc/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	return FALSE

/**
 * For any special casting effects done if the user right-clicks
 * on touch spell instead of left-clicking
 *
 * Return SECONDARY_ATTACK_CALL_NORMAL to call the normal cast_on_hand_hit
 * Return SECONDARY_ATTACK_CONTINUE_CHAIN to prevent the normal cast_on_hand_hit from calling, but still use up the hand
 * Return SECONDARY_ATTACK_CANCEL_CHAIN to prevent the spell from being used
 */
/datum/action/cooldown/spell/touch/proc/cast_on_secondary_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
 * Signal proc for [COMSIG_PARENT_QDELETING] from our attached hand.
 *
 * If our hand is deleted for a reason unrelated to our spell,
 * unlink it (clear refs) and revert the cooldown
 */
/datum/action/cooldown/spell/touch/proc/on_hand_deleted(datum/source)
	SIGNAL_HANDLER

	remove_hand(revert_after = TRUE)

/**
 * Signal proc for [COMSIG_ITEM_DROPPED] from our attached hand.
 *
 * If our caster drops the hand, remove the hand / revert the cast
 * Basically gives them an easy hotkey to lose their hand without needing to click the button
 */
/datum/action/cooldown/spell/touch/proc/on_hand_dropped(datum/source, mob/living/dropper)
	SIGNAL_HANDLER

	remove_hand(dropper, revert_after = TRUE) // MELBER TODO check if arm removed

/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "latexballon"
	inhand_icon_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return TRUE
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("You can't reach out!"))
		return TRUE
	return ..()
