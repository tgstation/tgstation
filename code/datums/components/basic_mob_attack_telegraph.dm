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
	display_telegraph_overlay = TRUE,
	telegraph_duration = 0.4 SECONDS,
	datum/callback/on_began_forecast,
)
	. = ..()
	if (!isbasicmob(parent) && !ishostile(parent))
		return ELEMENT_INCOMPATIBLE

	if(display_telegraph_overlay)
		target_overlay = mutable_appearance(telegraph_icon, telegraph_state)

	src.telegraph_duration = telegraph_duration
	src.on_began_forecast = on_began_forecast

/datum/component/basic_mob_attack_telegraph/Destroy(force)
	if(current_target)
		forget_target(current_target)
	target_overlay = null
	on_began_forecast = null
	return ..()

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
	if (!(isliving(target) || ismecha(target))) // Curse you CLARKE
		return
	if (HAS_TRAIT_FROM(source, TRAIT_BASIC_ATTACK_FORECAST, REF(src)))
		REMOVE_TRAIT(source, TRAIT_BASIC_ATTACK_FORECAST, REF(src))
		return

	if (!DOING_INTERACTION(source, INTERACTION_BASIC_ATTACK_FORCEAST))
		INVOKE_ASYNC(src, PROC_REF(delayed_attack), source, target)
	return COMPONENT_HOSTILE_NO_ATTACK

/// Perform an attack after a delay
/datum/component/basic_mob_attack_telegraph/proc/delayed_attack(mob/living/source, atom/target)
	current_target = target

	if(target_overlay)
		RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_target_overlays_update))
		target.update_appearance()

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
	if(isbasicmob(source))
		var/mob/living/basic/basic_source = source
		basic_source.melee_attack(target, ignore_cooldown = TRUE) // We already started the cooldown when we triggered the forecast
		return
	var/mob/living/simple_animal/hostile/hostile_source = source
	hostile_source.AttackingTarget(target)

/// The guy we're trying to attack moved, is he still in range?
/datum/component/basic_mob_attack_telegraph/proc/target_moved(atom/target)
	SIGNAL_HANDLER
	if (in_range(parent, target))
		return
	forget_target(target)

/// The guy we're trying to attack isn't a valid target any more
/datum/component/basic_mob_attack_telegraph/proc/forget_target(atom/target)
	SIGNAL_HANDLER
	current_target = null
	target.update_appearance()
	UnregisterSignal(target, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_ATOM_UPDATE_OVERLAYS))

/datum/component/basic_mob_attack_telegraph/proc/on_target_overlays_update(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	if(parent_atom == current_target)
		overlays += target_overlay
