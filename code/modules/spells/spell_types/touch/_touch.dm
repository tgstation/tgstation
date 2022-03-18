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

	var/draw_message = "You channel the power of the spell to your hand."
	var/drop_message = "You draw the power out of your hand."
	var/on_hit_sound
	var/hand_charges = 1

/datum/action/cooldown/spell/touch/Destroy()
	remove_hand()
	return ..()

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
		if (user.usable_hands == 0)
			to_chat(user, span_warning("You dont have any usable hands!"))
		else
			to_chat(user, span_warning("Your hands are full!"))
		return FALSE

	attached_hand = new_hand
	RegisterSignal(attached_hand, COMSIG_ITEM_AFTERATTACK, .proc/on_hand_hit)
	RegisterSignal(attached_hand, COMSIG_PARENT_QDELETING, .proc/on_hand_deleted)
	to_chat(user, span_notice("[draw_message]"))
	return TRUE

/**
 * Unregisters any signals and deletes the hand currently summoned by the spell.
 *
 * If revert_after is TRUE, we will additionally refund the cooldown of the spell.
 */
/datum/action/cooldown/spell/touch/proc/remove_hand(revert_after = FALSE)
	if(!QDELETED(attached_hand))
		UnregisterSignal(attached_hand, COMSIG_ITEM_AFTERATTACK)
		UnregisterSignal(attached_hand, COMSIG_PARENT_QDELETING)
		QDEL_NULL(attached_hand)

	if(revert_after)
		revert_cast()

/datum/action/cooldown/spell/touch/cast(mob/living/carbon/cast_on)
	if(!QDELETED(attached_hand) && (attached_hand in cast_on.held_items))
		remove_hand(revert_after = TRUE)
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

	INVOKE_ASYNC(src, .proc/do_hand_hit, source, victim, caster)

/**
 * Calls cast_on_hand_hit() from the caster onto the victim.
 * If cast_on_hand_hit() returns success, follows up by deleting the hand.
 */
/datum/action/cooldown/spell/touch/proc/do_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(!cast_on_hand_hit(hand, victim, caster))
		return

	remove_hand()

/**
 * The actual process of casting the spell on the victim from the caster.
 *
 * Override / extend this to implement casting effects.
 */
/datum/action/cooldown/spell/touch/proc/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(!isliving(victim) || !(caster.mobility_flags & MOBILITY_USE))
		return FALSE
	if(!can_invoke())
		return FALSE

	invocation()
	if(sound)
		playsound(get_turf(owner), sound, 50, TRUE)

	return TRUE

/**
 * Signal proc for [COMSIG_PARENT_QDELETING] from our attached hand.
 *
 * If our hand is deleted for a reason unrelated to our spell,
 * unlink it (clear refs) and revert the cooldown
 */
/datum/action/cooldown/spell/touch/proc/on_hand_deleted(datum/source)
	SIGNAL_HANDLER

	remove_hand(revert_after = TRUE)

/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "latexballon"
	inhand_icon_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
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
