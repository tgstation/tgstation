/*
 * Tippable component. For making mobs able to be tipped, like cows and medibots.
 */
/datum/component/tippable
	/// Time it takes to tip the mob. Can be 0, for instant tipping.
	var/tip_time = 3 SECONDS
	/// Time it takes to untip the mob. Can also be 0.
	var/untip_time = 1 SECONDS
	/// Time it takes for the mob to right itself. If 0 or negative, the mob will never self-right.
	var/self_right_time = 60 SECONDS
	/// Whether the mob is currently tipped.
	var/is_tipped = FALSE
	/// List of sounds to play when attempting to tip the mob.
	var/list/try_tipped_sounds
	/// Lists of sounds to play after successfully tipping the mob.
	var/list/on_tipped_sounds
	/// Callback to additional behavior before being tipped (on try_tip). Return anything from this callback to cancel the tip.
	var/datum/callback/pre_tipped_callback
	/// Callback to additional behavior after successfully tipping the mob.
	var/datum/callback/post_tipped_callback
	/// Callback to additoinal behavior after sucessfuly being untipped.
	var/datum/callback/post_untipped_callback

/datum/component/tippable/Initialize(
		tip_time = 3 SECONDS,
		untip_time = 1 SECONDS,
		self_right_time = 60 SECONDS,
		try_tipped_sounds,
		on_tipped_sounds,
		datum/callback/pre_tipped_callback,
		datum/callback/post_tipped_callback,
		datum/callback/post_untipped_callback)

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.tip_time = tip_time
	src.untip_time = untip_time
	src.self_right_time = self_right_time
	if(islist(try_tipped_sounds))
		src.try_tipped_sounds = try_tipped_sounds
	else if(try_tipped_sounds)
		src.try_tipped_sounds =  list(try_tipped_sounds)
	if(islist(on_tipped_sounds))
		src.on_tipped_sounds = on_tipped_sounds
	else if(on_tipped_sounds)
		src.on_tipped_sounds =  list(on_tipped_sounds)
	src.pre_tipped_callback = pre_tipped_callback
	src.post_tipped_callback = post_tipped_callback
	src.post_untipped_callback = post_tipped_callback

/datum/component/tippable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/interact_with_tippable)

/datum/component/tippable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)

/datum/component/tippable/proc/interact_with_tippable(mob/living/source, mob/user, modifiers)
	SIGNAL_HANDLER

	if(DOING_INTERACTION_WITH_TARGET(user, source))
		return
	if(user.combat_mode)
		return

	if(!is_tipped)
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			INVOKE_ASYNC(src, .proc/try_tip, source, user)
	else
		INVOKE_ASYNC(src, .proc/try_untip, source, user)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/tippable/proc/try_tip(mob/living/tipped_mob, mob/tipper)
	if(tipped_mob.stat)
		return

	if(pre_tipped_callback?.Invoke(tipper))
		return

	if(tip_time > 0)
		to_chat(tipper, span_warning("You begin tipping over [tipped_mob]..."))
		to_chat(tipped_mob, span_userdanger("[tipper] begins tipping you over!"))
		tipper.visible_message(span_warning("[tipper] begins tipping over [tipped_mob]."), ignored_mobs = list(tipped_mob, tipper))
		if(!do_after(tipper, tip_time, target = tipped_mob))
			to_chat(tipper, span_danger("You fail to tip over [tipped_mob]."))
			return
	do_tip(tipped_mob, tipper)

/datum/component/tippable/proc/do_tip(mob/living/tipped_mob, mob/tipper)
	if(QDELETED(tipped_mob))
		return

	to_chat(tipped_mob, span_userdanger("You are tipped over by [tipper]!"))
	to_chat(tipper, span_warning("You tip over [tipped_mob]."))
	tipped_mob.visible_message(span_warning("[tipper] tips over [tipped_mob]."), ignored_mobs = list(tipped_mob, tipper))

	set_tipped_status(tipped_mob, TRUE)
	post_tipped_callback?.Invoke(tipper)
	if(self_right_time > 0)
		addtimer(CALLBACK(src, .proc/right_self, tipped_mob), self_right_time)

/datum/component/tippable/proc/try_untip(mob/living/tipped_mob, mob/untipper)
	if(untip_time > 0)
		to_chat(untipper, span_notice("You begin righting [tipped_mob]..."))
		to_chat(tipped_mob, span_notice("[untipper] begins righting you!"))
		untipper.visible_message(span_notice("[untipper] begins righting [tipped_mob]."), ignored_mobs = list(tipped_mob, untipper))
		if(!do_after(untipper, untip_time, target = tipped_mob))
			to_chat(untipper, span_warning("You fail to right [tipped_mob]."))
			return

	do_untip(tipped_mob, untipper)

/datum/component/tippable/proc/do_untip(mob/living/tipped_mob, mob/untipper)
	if(QDELETED(tipped_mob))
		return

	to_chat(tipped_mob, span_notice("You are righted by [untipper]!"))
	to_chat(untipper, span_notice("You right [tipped_mob]."))
	tipped_mob.visible_message(span_notice("[untipper] rights [tipped_mob]."), ignored_mobs = list(tipped_mob, untipper))

	set_tipped_status(tipped_mob, FALSE)
	post_untipped_callback?.Invoke(untipper)

/datum/component/tippable/proc/right_self(mob/living/tipped_mob)
	if(!is_tipped || QDELETED(tipped_mob))
		return

	set_tipped_status(tipped_mob, FALSE)

	to_chat(tipped_mob, span_notice("You right yourself."))
	tipped_mob.visible_message(span_notice("[tipped_mob] rights itself."), ignored_mobs = tipped_mob)

/datum/component/tippable/proc/set_tipped_status(mob/living/tipped_mob, new_status = TRUE)
	is_tipped = new_status
	if(is_tipped)
		tipped_mob.transform = turn(tipped_mob.transform, 180)
		ADD_TRAIT(tipped_mob, TRAIT_IMMOBILIZED, TIPPED_OVER)
	else
		tipped_mob.transform = turn(tipped_mob.transform, -180)
		REMOVE_TRAIT(tipped_mob, TRAIT_IMMOBILIZED, TIPPED_OVER)
