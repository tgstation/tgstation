/**
 * Delays outgoing attacks which are directed at mobs to give players time to get out of the way
 */
/datum/component/basic_mob_attack_telegraph
	/// Time to wait before attack can complete
	var/telegraph_duration
	/// Overlay which we display over targets
	var/mutable_appearance/target_overlay
	/// Our current target, if we have one
	var/mob/living/current_target
	/// Callback executed when we start aiming at something
	var/datum/callback/on_began_forecast

/datum/component/basic_mob_attack_telegraph/Initialize(
	telegraph_icon = 'icons/mob/telegraphing/telegraph.dmi',
	telegraph_state = ATTACK_EFFECT_BITE,
	telegraph_duration = 0.3 SECONDS,
	datum/callback/on_began_forecast,
)
	. = ..()
	if (!isbasicmob(parent))
		return ELEMENT_INCOMPATIBLE

	target_overlay = mutable_appearance(telegraph_icon, telegraph_state)
	src.telegraph_duration = telegraph_duration
	src.on_began_forecast = on_began_forecast

/datum/component/basic_mob_attack_telegraph/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_attack))

/datum/component/basic_mob_attack_telegraph/UnregisterFromParent()
	if (current_target)
		forget_target(current_target)
	QDEL_NULL(target_overlay)
	REMOVE_TRAIT(parent, TRAIT_BASIC_ATTACK_FORECAST, REF(src))
	UnregisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	return ..()

/// When we attempt to attack, check if it is allowed
/datum/component/basic_mob_attack_telegraph/proc/on_attack(mob/living/basic/source, atom/target)
	SIGNAL_HANDLER
	if (!isliving(target))
		return
	if (HAS_TRAIT_FROM(source, TRAIT_BASIC_ATTACK_FORECAST, REF(src)))
		REMOVE_TRAIT(source, TRAIT_BASIC_ATTACK_FORECAST, REF(src))
		return

	if (!DOING_INTERACTION(source, INTERACTION_BASIC_ATTACK_FORCEAST))
		INVOKE_ASYNC(src, PROC_REF(delayed_attack), source, target)
	return COMPONENT_HOSTILE_NO_ATTACK

/// Perform an attack after a delay
/datum/component/basic_mob_attack_telegraph/proc/delayed_attack(mob/living/basic/source, mob/living/target)
	current_target = target
	target.add_overlay(target_overlay)
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(forget_target))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(target_moved))

	on_began_forecast?.Invoke(target)
	//we stop the do_after if the target moves out of neighboring turfs but if they dance around us they get their face smashed
	if (!do_after(source, delay = telegraph_duration, target = target, timed_action_flags = IGNORE_TARGET_LOC_CHANGE, extra_checks = CALLBACK(source, TYPE_PROC_REF(/atom/movable, Adjacent), target), interaction_key = INTERACTION_BASIC_ATTACK_FORCEAST))
		forget_target(target)
		return
	if (isnull(target)) // They got out of the way :(
		return
	ADD_TRAIT(source, TRAIT_BASIC_ATTACK_FORECAST, REF(src))
	forget_target(target)
	source.melee_attack(target)

/// The guy we're trying to attack moved, is he still in range?
/datum/component/basic_mob_attack_telegraph/proc/target_moved(mob/living/target)
	SIGNAL_HANDLER
	if (in_range(parent, target))
		return
	forget_target(target)

/// The guy we're trying to attack isn't a valid target any more
/datum/component/basic_mob_attack_telegraph/proc/forget_target(atom/target)
	SIGNAL_HANDLER
	current_target = null
	target.cut_overlay(target_overlay)
	UnregisterSignal(target, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
