/*
 * Tippable component. For making mobs able to be tipped, like cows and medibots.
 */
/datum/component/tippable
	/// Time it takes to tip the mob. Can be 0, for instant tipping.
	var/tip_time = 3 SECONDS
	/// Time it takes to untip the mob. Can also be 0, for instant untip.
	var/untip_time = 1 SECONDS
	/// Time it takes for the mob to right itself. Can be 0 for instant self-righting, or null, to never self-right.
	var/self_right_time = 60 SECONDS
	/// Whether the mob is currently tipped.
	var/is_tipped = FALSE
	/// Callback to additional behavior before being tipped (on try_tip). Return anything from this callback to cancel the tip.
	var/datum/callback/pre_tipped_callback
	/// Callback to additional behavior after successfully tipping the mob.
	var/datum/callback/post_tipped_callback
	/// Callback to additional behavior after being untipped.
	var/datum/callback/post_untipped_callback

/datum/component/tippable/Initialize(
	tip_time = 3 SECONDS,
	untip_time = 1 SECONDS,
	self_right_time = 60 SECONDS,
	datum/callback/pre_tipped_callback,
	datum/callback/post_tipped_callback,
	datum/callback/post_untipped_callback,
)

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.tip_time = tip_time
	src.untip_time = untip_time
	src.self_right_time = self_right_time
	src.pre_tipped_callback = pre_tipped_callback
	src.post_tipped_callback = post_tipped_callback
	src.post_untipped_callback = post_untipped_callback

/datum/component/tippable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, .proc/interact_with_tippable)

/datum/component/tippable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY)

/datum/component/tippable/Destroy()
	if(pre_tipped_callback)
		QDEL_NULL(pre_tipped_callback)
	if(post_tipped_callback)
		QDEL_NULL(post_tipped_callback)
	if(post_untipped_callback)
		QDEL_NULL(post_untipped_callback)
	return ..()

/*
 * Attempt to interact with [source], either tipping it or helping it up.
 *
 * source - the mob being tipped over
 * user - the mob interacting with source
 */
/datum/component/tippable/proc/interact_with_tippable(mob/living/source, mob/user)
	SIGNAL_HANDLER

	var/mob/living/living_user = user
	if(DOING_INTERACTION_WITH_TARGET(user, source))
		return
	if(istype(living_user) && !living_user.combat_mode)
		return

	if(is_tipped)
		INVOKE_ASYNC(src, .proc/try_untip, source, user)
	else
		INVOKE_ASYNC(src, .proc/try_tip, source, user)

	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/*
 * Try to tip over [tipped_mob].
 * If the mob is dead, or optional callback returns a value, or our do-after fails, we don't tip the mob.
 * Otherwise, upon completing of the do_after, tip over the mob.
 *
 * tipped_mob - the mob being tipped over
 * tipper - the mob tipping the tipped_mob
 */
/datum/component/tippable/proc/try_tip(mob/living/tipped_mob, mob/tipper)
	if(tipped_mob.stat != CONSCIOUS)
		return

	if(pre_tipped_callback?.Invoke(tipper))
		return

	if(tip_time > 0)
		to_chat(tipper, span_warning("You begin tipping over [tipped_mob]..."))
		tipped_mob.visible_message(
			span_warning("[tipper] begins tipping over [tipped_mob]."),
			span_userdanger("[tipper] begins tipping you over!"),
			ignored_mobs = tipper
		)

		if(!do_after(tipper, tip_time, target = tipped_mob))
			to_chat(tipper, span_danger("You fail to tip over [tipped_mob]."))
			return
	do_tip(tipped_mob, tipper)

/*
 * Actually tip over the mob, setting it to tipped.
 * Also invoking any callbacks we have, with the tipper as the argument,
 * and set a timer to right our self-right our tipped mob if we can.
 *
 * tipped_mob - the mob who was tipped
 * tipper - the mob who tipped the tipped_mob
 */
/datum/component/tippable/proc/do_tip(mob/living/tipped_mob, mob/tipper)
	if(QDELETED(tipped_mob))
		CRASH("Tippable component: do_tip() called with QDELETED tipped_mob!")

	to_chat(tipper, span_warning("You tip over [tipped_mob]."))
	tipped_mob.visible_message(
		span_warning("[tipper] tips over [tipped_mob]."),
		span_userdanger("You are tipped over by [tipper]!"),
		ignored_mobs = tipper
		)

	set_tipped_status(tipped_mob, TRUE)
	post_tipped_callback?.Invoke(tipper)
	if(isnull(self_right_time))
		return
	else if(self_right_time <= 0)
		right_self(tipped_mob)
	else
		addtimer(CALLBACK(src, .proc/right_self, tipped_mob), self_right_time)

/*
 * Try to untip a mob that has been tipped.
 * After a do-after is completed, we untip the mob.
 *
 * tipped_mob - the mob who is tipped
 * untipper - the mob who is untipping the tipped_mob
 */
/datum/component/tippable/proc/try_untip(mob/living/tipped_mob, mob/untipper)
	if(untip_time > 0)
		to_chat(untipper, span_notice("You begin righting [tipped_mob]..."))
		tipped_mob.visible_message(
			span_notice("[untipper] begins righting [tipped_mob]."),
			span_notice("[untipper] begins righting you."),
			ignored_mobs = untipper
		)

		if(!do_after(untipper, untip_time, target = tipped_mob))
			to_chat(untipper, span_warning("You fail to right [tipped_mob]."))
			return

	do_untip(tipped_mob, untipper)

/*
 * Actually untip over the mob, setting it to untipped.
 * Also invoke any untip callbacks we have, with the untipper as the argument.
 *
 * tipped_mob - the mob who was tipped
 * tipper - the mob who tipped the tipped_mob
 */
/datum/component/tippable/proc/do_untip(mob/living/tipped_mob, mob/untipper)
	if(QDELETED(tipped_mob))
		return

	to_chat(untipper, span_notice("You right [tipped_mob]."))
	tipped_mob.visible_message(
		span_notice("[untipper] rights [tipped_mob]."),
		span_notice("You are righted by [untipper]!"),
		ignored_mobs = untipper
		)

	set_tipped_status(tipped_mob, FALSE)
	post_untipped_callback?.Invoke(untipper)

/*
 * Proc called after a timer to have a tipped mob un-tip itself after a certain length of time.
 * Sets our mob to untipped and invokes the untipped callback without any arguments if we have one.
 *
 * tipped_mob - the mob who was tipped, and is freeing itself
 */
/datum/component/tippable/proc/right_self(mob/living/tipped_mob)
	if(!is_tipped || QDELETED(tipped_mob))
		return

	set_tipped_status(tipped_mob, FALSE)
	post_untipped_callback?.Invoke()

	tipped_mob.visible_message(
		span_notice("[tipped_mob] rights itself."),
		span_notice("You right yourself.")
		)

/*
 * Toggles our tipped status between tipped or untipped (TRUE or FALSE)
 * also handles rotating our mob and adding immobilization traits
 *
 * tipped_mob - the mob we're setting to tipped or untipped
 * new_status - the tipped status we're setting the mob to - TRUE for tipped, FALSE for untipped
 */
/datum/component/tippable/proc/set_tipped_status(mob/living/tipped_mob, new_status = FALSE)
	is_tipped = new_status
	if(is_tipped)
		tipped_mob.transform = turn(tipped_mob.transform, 180)
		ADD_TRAIT(tipped_mob, TRAIT_IMMOBILIZED, TIPPED_OVER)
	else
		tipped_mob.transform = turn(tipped_mob.transform, -180)
		REMOVE_TRAIT(tipped_mob, TRAIT_IMMOBILIZED, TIPPED_OVER)
