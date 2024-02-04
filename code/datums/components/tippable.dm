/**
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
	/// Callback to any extra roleplay behaviour
	var/datum/callback/roleplay_callback
	///The timer given until they untip themselves
	var/self_untip_timer

	///Should we accept roleplay?
	var/roleplay_friendly
	///Have we roleplayed?
	var/roleplayed = FALSE
	///List of emotes that will half their untip time
	var/list/roleplay_emotes

/datum/component/tippable/Initialize(
	tip_time = 3 SECONDS,
	untip_time = 1 SECONDS,
	self_right_time = 60 SECONDS,
	datum/callback/pre_tipped_callback,
	datum/callback/post_tipped_callback,
	datum/callback/post_untipped_callback,
	roleplay_friendly = FALSE,
	roleplay_emotes,
	datum/callback/roleplay_callback,
)

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.tip_time = tip_time
	src.untip_time = untip_time
	src.self_right_time = self_right_time
	src.pre_tipped_callback = pre_tipped_callback
	src.post_tipped_callback = post_tipped_callback
	src.post_untipped_callback = post_untipped_callback
	src.roleplay_friendly = roleplay_friendly
	src.roleplay_emotes = roleplay_emotes
	src.roleplay_callback = roleplay_callback

/datum/component/tippable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(interact_with_tippable))
	if (roleplay_friendly)
		RegisterSignal(parent, COMSIG_MOB_EMOTE, PROC_REF(accept_roleplay))


/datum/component/tippable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY)

/datum/component/tippable/Destroy()
	pre_tipped_callback = null
	post_tipped_callback = null
	post_untipped_callback = null
	roleplay_callback = null
	return ..()

/**
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
		INVOKE_ASYNC(src, PROC_REF(try_untip), source, user)
	else
		INVOKE_ASYNC(src, PROC_REF(try_tip), source, user)

	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/**
 * Try to tip over [tipped_mob].
 * If the mob is dead, or optional callback returns a value, or our do-after fails, we don't tip the mob.
 * Otherwise, upon completing of the do_after, tip over the mob.
 *
 * tipped_mob - the mob being tipped over
 * tipper - the mob tipping the tipped_mob
 */
/datum/component/tippable/proc/try_tip(mob/living/tipped_mob, mob/tipper)
	if(tipped_mob.stat != CONSCIOUS && !HAS_TRAIT(tipped_mob, TRAIT_FORCED_STANDING))
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
			if(!isnull(tipped_mob.client))
				tipped_mob.log_message("was attempted to tip over by [key_name(tipper)]", LOG_VICTIM, log_globally = FALSE)
				tipper.log_message("failed to tip over [key_name(tipped_mob)]", LOG_ATTACK)
			to_chat(tipper, span_danger("You fail to tip over [tipped_mob]."))
			return
	do_tip(tipped_mob, tipper)

/**
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
	if (is_tipped) // sanity check in case multiple people try to tip at the same time
		return

	to_chat(tipper, span_warning("You tip over [tipped_mob]."))
	if (!isnull(tipped_mob.client))
		tipped_mob.log_message("has been tipped over by [key_name(tipper)].", LOG_ATTACK)
		tipper.log_message("has tipped over [key_name(tipped_mob)].", LOG_ATTACK)
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
		self_untip_timer = addtimer(CALLBACK(src, PROC_REF(right_self), tipped_mob), self_right_time, TIMER_UNIQUE | TIMER_STOPPABLE)

/**
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

/**
 * Actually untip over the mob, setting it to untipped.
 * Also invoke any untip callbacks we have, with the untipper as the argument.
 *
 * tipped_mob - the mob who was tipped
 * tipper - the mob who tipped the tipped_mob
 */
/datum/component/tippable/proc/do_untip(mob/living/tipped_mob, mob/untipper)
	if(QDELETED(tipped_mob))
		return
	if (!is_tipped) // sanity check in case multiple people try to untip at the same time
		return

	to_chat(untipper, span_notice("You right [tipped_mob]."))
	tipped_mob.visible_message(
		span_notice("[untipper] rights [tipped_mob]."),
		span_notice("You are righted by [untipper]!"),
		ignored_mobs = untipper
		)

	if(self_untip_timer)
		deltimer(self_untip_timer)
	set_tipped_status(tipped_mob, FALSE)
	post_untipped_callback?.Invoke(untipper)

/**
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

/**
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
		tipped_mob.add_traits(list(TRAIT_MOB_TIPPED, TRAIT_IMMOBILIZED), TIPPED_OVER)
		return

	tipped_mob.transform = turn(tipped_mob.transform, -180)
	tipped_mob.remove_traits(list(TRAIT_MOB_TIPPED, TRAIT_IMMOBILIZED), TIPPED_OVER)

/**
 * Accepts "roleplay" in the form of emotes, which removes a quarter of the remaining time left to untip ourself.
 *
 * Arguments:
 * * mob/living/user - The tipped mob
 * * datum/emote/emote - The emote used by the mob
 */
/datum/component/tippable/proc/accept_roleplay(mob/living/user, datum/emote/emote)
	SIGNAL_HANDLER

	if (!is_tipped)
		return
	if (roleplayed)
		return
	if (!is_type_in_list(emote, roleplay_emotes))
		return
	var/time_left = timeleft(self_untip_timer)
	deltimer(self_untip_timer)
	self_untip_timer = addtimer(CALLBACK(src, PROC_REF(right_self), user), time_left * 0.75, TIMER_UNIQUE | TIMER_STOPPABLE)
	roleplayed = TRUE
	roleplay_callback?.Invoke(user)
