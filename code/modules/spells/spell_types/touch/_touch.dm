/**
 * ## Touch Spell
 *
 * Touch spells are spells which function through the power of an item attack.
 *
 * Instead of the spell triggering when the caster presses the button,
 * pressing the button will give them a hand object.
 * The spell's effects are cast when the hand object makes contact with something.
 *
 * To implement a touch spell, all you need is to implement:
 * * is_valid_target - to check whether the slapped target is valid
 * * cast_on_hand_hit - to implement effects on cast
 *
 * However, for added complexity, you can optionally implement:
 * * on_antimagic_triggered - to cause effects when antimagic is triggered
 * * cast_on_secondary_hand_hit - to implement different effects if the caster r-clicked

 * It is not necessarily to touch any of the core functions, and is
 * (generally) inadvisable unless you know what you're doing
 */
/datum/action/cooldown/spell/touch
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	sound = 'sound/items/tools/welder.ogg'
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
	/// If TRUE, the caster can willingly hit themselves with the hand
	var/can_cast_on_self = FALSE

/datum/action/cooldown/spell/touch/Destroy()
	// If we have an owner, the hand is cleaned up in Remove(), which Destroy() calls.
	if(!owner)
		QDEL_NULL(attached_hand)
	return ..()

/datum/action/cooldown/spell/touch/Remove(mob/living/remove_from)
	remove_hand(remove_from)
	return ..()

// PreActivate is overridden to not check is_valid_target on the caster, as it makes less sense.
/datum/action/cooldown/spell/touch/PreActivate(atom/target)
	return Activate(target)

/datum/action/cooldown/spell/touch/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return !!attached_hand

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
	// Currently, hard checks for carbons.
	// If someone wants to add support for simplemobs
	// adminbussed to have hands, go for it
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(!(carbon_owner.mobility_flags & MOBILITY_USE))
		return FALSE
	return TRUE

// Checks if the mob slapped with the hand is a valid target.
/datum/action/cooldown/spell/touch/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/**
 * Creates a new hand_path hand and equips it to the caster.
 *
 * If the equipping action fails, reverts the cooldown and returns FALSE.
 * Otherwise, registers signals and returns TRUE.
 */
/datum/action/cooldown/spell/touch/proc/create_hand(mob/living/carbon/cast_on)
	SHOULD_CALL_PARENT(TRUE)

	var/obj/item/melee/touch_attack/new_hand = new hand_path(cast_on, src)
	if(!cast_on.put_in_hands(new_hand, del_on_fail = TRUE))
		reset_spell_cooldown()
		if (cast_on.usable_hands == 0)
			to_chat(cast_on, span_warning("You dont have any usable hands!"))
		else
			to_chat(cast_on, span_warning("Your hands are full!"))
		return FALSE

	attached_hand = new_hand
	register_hand_signals()
	to_chat(cast_on, draw_message)
	return TRUE

/**
 * Unregisters any signals and deletes the hand currently summoned by the spell.
 *
 * If reset_cooldown_after is TRUE, we will additionally refund the cooldown of the spell.
 * If reset_cooldown_after is FALSE, we will instead just start the spell's cooldown
 */
/datum/action/cooldown/spell/touch/proc/remove_hand(mob/living/hand_owner, reset_cooldown_after = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(!QDELETED(attached_hand))
		unregister_hand_signals()
		hand_owner?.temporarilyRemoveItemFromInventory(attached_hand)
		QDEL_NULL(attached_hand)

	if(reset_cooldown_after)
		if(hand_owner)
			to_chat(hand_owner, drop_message)
		reset_spell_cooldown()
	else
		StartCooldown()
		build_all_button_icons()

/// Registers all signal procs for the hand.
/datum/action/cooldown/spell/touch/proc/register_hand_signals()
	SHOULD_CALL_PARENT(TRUE)

	RegisterSignal(attached_hand, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_hand_hit))
	RegisterSignal(attached_hand, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(on_hand_hit_secondary))
	RegisterSignal(attached_hand, COMSIG_ITEM_DROPPED, PROC_REF(on_hand_dropped))
	RegisterSignal(attached_hand, COMSIG_QDELETING, PROC_REF(on_hand_deleted))

	// We can high five with our touch hand. It casts the spell on people. Radical
	attached_hand.AddElement(/datum/element/high_fiver)
	RegisterSignal(attached_hand, COMSIG_ITEM_OFFER_TAKEN, PROC_REF(on_hand_taken))

/// Unregisters all signal procs for the hand.
/datum/action/cooldown/spell/touch/proc/unregister_hand_signals()
	SHOULD_CALL_PARENT(TRUE)

	UnregisterSignal(attached_hand, list(
		COMSIG_ITEM_INTERACTING_WITH_ATOM,
		COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY,
		COMSIG_ITEM_DROPPED,
		COMSIG_QDELETING,
		COMSIG_ITEM_OFFER_TAKEN,
	))

// Touch spells don't go on cooldown OR give off an invocation until the hand is used itself.
/datum/action/cooldown/spell/touch/before_cast(atom/cast_on)
	return ..() | SPELL_NO_FEEDBACK | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/touch/cast(mob/living/carbon/cast_on)
	if(SEND_SIGNAL(cast_on, COMSIG_TOUCH_HANDLESS_CAST, src) & COMPONENT_CAST_HANDLESS)
		StartCooldown()
		return

	if(!QDELETED(attached_hand) && (attached_hand in cast_on.held_items))
		remove_hand(cast_on, reset_cooldown_after = TRUE)
		return

	create_hand(cast_on)
	return ..()

/**
 * Signal proc for [COMSIG_ITEM_INTERACTING_WITH_ATOM] from our attached hand.
 *
 * When our hand hits an atom, we can cast do_hand_hit() on them.
 */
/datum/action/cooldown/spell/touch/proc/on_hand_hit(datum/source, mob/living/caster, atom/target, click_parameters)
	SIGNAL_HANDLER
	SHOULD_NOT_OVERRIDE(TRUE) // DEFINITELY don't put effects here, put them in cast_on_hand_hit

	if(!can_hit_with_hand(target, caster))
		return NONE

	return do_hand_hit(source, target, caster)

/**
 * Signal proc for [COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY] from our attached hand.
 *
 * When our hand hits an atom, we can cast do_hand_hit() on them.
 */
/datum/action/cooldown/spell/touch/proc/on_hand_hit_secondary(datum/source, mob/living/caster, atom/target, click_parameters)
	SIGNAL_HANDLER
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!can_hit_with_hand(target, caster))
		return NONE

	return do_secondary_hand_hit(source, target, caster)

/// Checks if the passed victim can be cast on by the caster.
/datum/action/cooldown/spell/touch/proc/can_hit_with_hand(atom/victim, mob/living/caster)
	if(!can_cast_on_self && victim == caster)
		return FALSE
	if(!is_valid_target(victim))
		return FALSE
	if(!can_cast_spell(feedback = TRUE))
		return FALSE
	if(!(caster.mobility_flags & MOBILITY_USE))
		caster.balloon_alert(caster, "can't reach out!")
		return FALSE

	return TRUE

/**
 * Calls cast_on_hand_hit() from the caster onto the victim.
 * It's worth noting that victim will be guaranteed to be whatever checks are implemented in is_valid_target by this point.
 *
 * Implements checks for antimagic.
 */
/datum/action/cooldown/spell/touch/proc/do_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	SHOULD_NOT_OVERRIDE(TRUE) // Don't put effects here, put them in cast_on_hand_hit

	SEND_SIGNAL(src, COMSIG_SPELL_TOUCH_HAND_HIT, victim, caster, hand)

	var/mob/mob_victim = victim
	if(istype(mob_victim) && mob_victim.can_block_magic(antimagic_flags))
		on_antimagic_triggered(hand, victim, caster)

	else if(!cast_on_hand_hit(hand, victim, caster))
		return NONE

	log_combat(caster, victim, "cast the touch spell [name] on", hand)
	INVOKE_ASYNC(src, PROC_REF(spell_feedback), caster)
	caster.do_attack_animation(victim)
	caster.changeNext_move(CLICK_CD_MELEE)
	victim.add_fingerprint(caster)
	remove_hand(caster)
	return ITEM_INTERACT_SUCCESS

/**
 * Calls do_secondary_hand_hit() from the caster onto the victim.
 * It's worth noting that victim will be guaranteed to be whatever checks are implemented in is_valid_target by this point.

 * Does NOT check for antimagic on its own. Implement your own checks if you want the r-click to abide by it.
 */
/datum/action/cooldown/spell/touch/proc/do_secondary_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	SHOULD_NOT_OVERRIDE(TRUE) // Don't put effects here, put them in cast_on_secondary_hand_hit

	var/secondary_result = cast_on_secondary_hand_hit(hand, victim, caster)
	switch(secondary_result)
		// Continue will remove the hand here and stop
		if(SECONDARY_ATTACK_CONTINUE_CHAIN)
			log_combat(caster, victim, "cast the touch spell [name] on", hand, "(secondary / alt cast)")
			INVOKE_ASYNC(src, PROC_REF(spell_feedback), caster)
			caster.do_attack_animation(victim)
			caster.changeNext_move(CLICK_CD_MELEE)
			victim.add_fingerprint(caster)
			remove_hand(caster)
			return ITEM_INTERACT_SUCCESS

		// Call normal will call the normal cast proc
		if(SECONDARY_ATTACK_CALL_NORMAL)
			do_hand_hit(hand, victim, caster)

		// Cancel chain will do nothing,
		if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
			return NONE

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
 * Signal proc for [COMSIG_QDELETING] from our attached hand.
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

/**
 * Signal proc for [COMSIG_ITEM_OFFER_TAKEN] from our attached hand.
 *
 * Giving a high five with our hand makes it cast
 */
/datum/action/cooldown/spell/touch/proc/on_hand_taken(obj/item/source, mob/living/carbon/offerer, mob/living/carbon/taker)
	SIGNAL_HANDLER

	if(!can_hit_with_hand(taker, offerer))
		return

	INVOKE_ASYNC(src, PROC_REF(do_hand_hit), source, taker, offerer)
	return COMPONENT_OFFER_INTERRUPT

/**
 * Called whenever our spell is cast, but blocked by antimagic.
 */
/datum/action/cooldown/spell/touch/proc/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	return

/**
 * ## Touch attack item
 *
 * Used for touch spells to have something physical to slap people with.
 *
 * Try to avoid adding behavior onto these for your touch spells!
 * The spells themselves should handle most, if not all, of the casted effects.
 *
 * These should generally just be dummy objects - holds name and icon stuff.
 */
/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	icon = 'icons/obj/weapons/hand.dmi'
	lefthand_file = 'icons/mob/inhands/items/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/touchspell_righthand.dmi'
	icon_state = "latexballoon"
	inhand_icon_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | HAND_ITEM
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

/**
 * When the hand component of a touch spell is qdel'd, (the hand is dropped or otherwise lost),
 * the cooldown on the spell that made it is automatically refunded.
 *
 * However, if you want to consume the hand and not give a cooldown,
 * such as adding a unique behavior to the hand specifically, this function will do that.
 */
/obj/item/melee/touch_attack/proc/remove_hand_with_no_refund(mob/holder)
	var/datum/action/cooldown/spell/touch/hand_spell = spell_which_made_us?.resolve()
	if(!QDELETED(hand_spell))
		hand_spell.remove_hand(holder, reset_cooldown_after = FALSE)
		return

	// We have no spell associated for some reason, just delete us as normal.
	holder.temporarilyRemoveItemFromInventory(src, force = TRUE)
	qdel(src)
