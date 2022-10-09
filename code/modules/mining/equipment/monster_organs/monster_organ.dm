/**
 * Stabilising serum prevents monster organs from decaying before you can use them.
 */
/obj/item/mining_stabilizer
	name = "stabilizing serum"
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject certain types of monster organs with this stabilizer to prevent their rapid decay."
	w_class = WEIGHT_CLASS_TINY

/obj/item/mining_stabilizer/afterattack(obj/item/organ/target_organ, mob/user, proximity)
	. = ..()
	if (!proximity)
		return
	var/obj/item/organ/internal/monster_core/target_core = target_organ
	if (!istype(target_core, /obj/item/organ/internal/monster_core))
		balloon_alert(user, "invalid target")
		return

	if (!target_core.preserve())
		balloon_alert(user, "organ decayed")
		return

	to_chat(user, span_notice("You inject the [target_organ] with the stabilizer. It will no longer go inert."))
	qdel(src)

/**
 * Useful organs which drop as loot from a mining creature.
 * Generalised behaviour is that they will decay and become useless unless provided with serum.
 * These should usually do something both when used in-hand, or when implanted into someone.
 */
/obj/item/organ/internal/monster_core
	name = "monster core"
	desc = "All that remains of a monster. This abstract item should not spawn. \
		It will rapidly decay into uselessness. but don't worry because it's already useless."
	icon_state = "roro core 2"
	visual = FALSE
	item_flags = NOBLUDGEON
	slot = ORGAN_SLOT_MONSTER_CORE
	organ_flags = NONE
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	/// Set to true if this organ has decayed into uselessness.
	var/inert = FALSE
	/// ID of the timer which will decay this organ
	var/decay_timer
	/// Time after which organ should become useless
	var/time_to_decay = 4 MINUTES
	/// Icon state to apply when preserved
	var/icon_state_preserved
	/// Description to use once organ has been preserved
	var/desc_preserved
	/// Icon state to apply when inert
	var/icon_state_inert
	/// Description to use once organ is inert
	var/desc_inert
	/// Status effect applied by this organ
	var/datum/status_effect/user_status
	/// Moodlet applied by this organ
	var/datum/mood_event/moodlet
	/// If true this organ is single use even when implanted
	var/consumed_internal = FALSE

/obj/item/organ/internal/monster_core/Initialize(mapload)
	. = ..()
	decay_timer = addtimer(CALLBACK(src, .proc/go_inert), time_to_decay, TIMER_STOPPABLE)

/obj/item/organ/internal/monster_core/Insert(mob/living/carbon/target_carbon, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if (!decay_timer)
		return
	preserve(TRUE)
	owner.visible_message(span_notice("[src] stabilizes as it's inserted."))

/obj/item/organ/internal/monster_core/Remove(mob/living/carbon/target_carbon, special = 0)
	if (!inert && !special)
		owner.visible_message(span_notice("[src] rapidly decays as it's removed."))
		go_inert()
	return ..()

/**
 * Preserves the organ so that it will not decay.
 * Returns true if successful.
 * * Implanted - If true, organ has just been inserted into someone.
 */
/obj/item/organ/internal/monster_core/proc/preserve(implanted = FALSE)
	if (inert)
		return FALSE
	deltimer(decay_timer)
	decay_timer = null
	update_appearance()
	return TRUE

/**
 * Decays the organ, it is now useless.
 */
/obj/item/organ/internal/monster_core/proc/go_inert()
	if (inert)
		return FALSE
	inert = TRUE
	decay_timer = null
	name = "decayed [name]"
	update_appearance()
	return TRUE

/obj/item/organ/internal/monster_core/update_desc()
	if (inert)
		desc = (desc_inert) ? desc_inert : initial(desc)
		return ..()
	if (!decay_timer)
		desc = (desc_preserved) ? desc_preserved : initial(desc)
		return ..()
	desc = initial(desc)
	return ..()

/obj/item/organ/internal/monster_core/update_icon_state()
	if (inert)
		icon_state = (icon_state_inert) ? icon_state_inert : initial(icon_state)
		return ..()
	if (!decay_timer)
		icon_state = (icon_state_preserved) ? icon_state_preserved : initial(icon_state)
		return ..()
	icon_state = initial(icon_state)
	return ..()

/obj/item/organ/internal/monster_core/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if (!proximity_flag)
		return
	try_apply(target, user)

/obj/item/organ/internal/monster_core/attack_self(mob/user)
	if (!user.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE))
		return
	try_apply(user, user)

/**
 * Tries to apply organ effect to target.
 * Usually you should not need to override this, only apply_to.
 * Arguments
 * * target - Person you are applying this to.
 * * user - Person who is doing the applying.
 */
/obj/item/organ/internal/monster_core/proc/try_apply(atom/target, mob/user)
	if (!isliving(target))
		balloon_alert(user, "invalid target")
		return
	if (inert)
		balloon_alert(user, "organ decayed")
		return
	var/mob/living/live_target = target
	if (live_target.stat == DEAD)
		balloon_alert(user, "target is dead")
		return
	apply_to(target, user)

/**
 * Applies the effect of this organ to the target.
 * Arguments
 * * target - Person you are applying this to.
 * * user - Person who is doing the applying.
 */
/obj/item/organ/internal/monster_core/proc/apply_to(mob/living/target, mob/user)
	if (user_status)
		target.apply_status_effect(user_status)
	if (moodlet)
		target.add_mood_event("core", moodlet)
	qdel(src)

/obj/item/organ/internal/monster_core/on_life(delta_time, times_fired)
	..()
	if (should_apply_on_life())
		try_activate_implanted()

/// Return true under conditions where we want an implanted organ to trigger
/obj/item/organ/internal/monster_core/proc/should_apply_on_life()
	return FALSE

/obj/item/organ/internal/monster_core/ui_action_click()
	try_activate_implanted()

/**
 * Called when activated while implanted inside someone.
 * This performs checking for interness, you should usually override activate_implanted() instead.
 */
/obj/item/organ/internal/monster_core/proc/try_activate_implanted()
	if (inert)
		to_chat(owner, span_notice("[src] breaks down as it tries to activate."))
		qdel(src)
		return
	activate_implanted()

/**
 * Called when activated while implanted inside someone.
 * This is either when they press the UI button or if should_apply_on_life() returns true.
 */
/obj/item/organ/internal/monster_core/proc/activate_implanted()
	if (consumed_internal)
		qdel(src)
