/datum/action/cooldown/spell/touch
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
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
	// If we have an owner, the hand is cleaned up in Remove(), which Destroy() calls.
	if(!owner)
		QDEL_NULL(attached_hand)
	return ..()

/datum/action/cooldown/spell/touch/Remove(mob/living/remove_from)
	remove_hand(remove_from)
	return ..()

/datum/action/cooldown/spell/touch/UpdateButton(atom/movable/screen/movable/action_button/button, status_only = FALSE, force = FALSE)
	. = ..()
	if(!button)
		return
	if(attached_hand)
		button.color = COLOR_GREEN

/datum/action/cooldown/spell/touch/set_statpanel_format()
	. = ..()
	if(!islist(.))
		return

	if(attached_hand)
		.[PANEL_DISPLAY_STATUS] = "ACTIVE"

/datum/action/cooldown/spell/touch/can_cast_spell(feedback = TRUE)
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
	var/obj/item/melee/touch_attack/new_hand = new hand_path(cast_on, src)
	if(!cast_on.put_in_hands(new_hand, del_on_fail = TRUE))
		reset_spell_cooldown()
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
 * If reset_cooldown_after is TRUE, we will additionally refund the cooldown of the spell.
 * If reset_cooldown_after is FALSE, we will instead just start the spell's cooldown
 */
/datum/action/cooldown/spell/touch/proc/remove_hand(mob/living/hand_owner, reset_cooldown_after = FALSE)
	if(!QDELETED(attached_hand))
		UnregisterSignal(attached_hand, list(COMSIG_ITEM_AFTERATTACK, COMSIG_ITEM_AFTERATTACK_SECONDARY, COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED))
		hand_owner?.temporarilyRemoveItemFromInventory(attached_hand)
		QDEL_NULL(attached_hand)

	if(reset_cooldown_after)
		if(hand_owner)
			to_chat(hand_owner, drop_message)
		reset_spell_cooldown()
	else
		StartCooldown()

// Touch spells don't go on cooldown OR give off an invocation until the hand is used itself.
/datum/action/cooldown/spell/touch/before_cast(atom/cast_on)
	return ..() | SPELL_NO_FEEDBACK | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/touch/cast(mob/living/carbon/cast_on)
	if(!QDELETED(attached_hand) && (attached_hand in cast_on.held_items))
		remove_hand(cast_on, reset_cooldown_after = TRUE)
		return

	create_hand(cast_on)
	return ..()

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
	if(!can_cast_spell(feedback = FALSE))
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
	if(!can_cast_spell(feedback = FALSE))
		return

	INVOKE_ASYNC(src, .proc/do_secondary_hand_hit, source, victim, caster)

/**
 * Calls cast_on_hand_hit() from the caster onto the victim.
 */
/datum/action/cooldown/spell/touch/proc/do_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	SEND_SIGNAL(src, COMSIG_SPELL_TOUCH_HAND_HIT, victim, caster, hand)
	if(!cast_on_hand_hit(hand, victim, caster))
		return

	log_combat(caster, victim, "cast the touch spell [name] on", hand)
	spell_feedback()
	remove_hand(caster)

/**
 * Calls do_secondary_hand_hit() from the caster onto the victim.
 */
/datum/action/cooldown/spell/touch/proc/do_secondary_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/secondary_result = cast_on_secondary_hand_hit(hand, victim, caster)
	switch(secondary_result)
		// Continue will remove the hand here and stop
		if(SECONDARY_ATTACK_CONTINUE_CHAIN)
			log_combat(caster, victim, "cast the touch spell [name] on", hand, "(secondary / alt cast)")
			spell_feedback()
			remove_hand(caster)

		// Call normal will call the normal cast proc
		if(SECONDARY_ATTACK_CALL_NORMAL)
			do_hand_hit(hand, victim, caster)

		// Cancel chain will do nothing,
		if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
			return

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
	return SECONDARY_ATTACK_CALL_NORMAL

/**
 * Signal proc for [COMSIG_PARENT_QDELETING] from our attached hand.
 *
 * If our hand is deleted for a reason unrelated to our spell,
 * unlink it (clear refs) and revert the cooldown
 */
/datum/action/cooldown/spell/touch/proc/on_hand_deleted(datum/source)
	SIGNAL_HANDLER

	remove_hand(reset_cooldown_after = TRUE)

/**
 * Signal proc for [COMSIG_ITEM_DROPPED] from our attached hand.
 *
 * If our caster drops the hand, remove the hand / revert the cast
 * Basically gives them an easy hotkey to lose their hand without needing to click the button
 */
/datum/action/cooldown/spell/touch/proc/on_hand_dropped(datum/source, mob/living/dropper)
	SIGNAL_HANDLER

	remove_hand(dropper, reset_cooldown_after = TRUE)

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
	/// A weakref to what spell made us.
	var/datum/weakref/spell_which_made_us

/obj/item/melee/touch_attack/Initialize(mapload, datum/action/cooldown/spell/spell)
	. = ..()

	if(spell)
		spell_which_made_us = WEAKREF(spell)

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return TRUE
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("You can't reach out!"))
		return TRUE
	return ..()

/**
 * When the hand component of a touch spell is qdel'd, (the hand is dropped or otherwise lost),
 * the cooldown on the spell that made it is automatically refunded.
 *
 * However, if you want to consume the hand and not give a cooldown,
 * such as adding a unique behavior to the hand specifically, this function will do that.
 */
/obj/item/melee/touch_attack/mansus_fist/proc/remove_hand_with_no_refund(mob/holder)
	var/datum/action/cooldown/spell/touch/hand_spell = spell_which_made_us?.resolve()
	if(!QDELETED(hand_spell))
		hand_spell.remove_hand(holder, reset_cooldown_after = FALSE)
		return

	// We have no spell associated for some reason, just delete us as normal.
	holder.temporarilyRemoveItemFromInventory(src, force = TRUE)
	qdel(src)
