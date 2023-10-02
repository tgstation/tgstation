/**
 * Component attached to an attack style
 * Delays outgoing attacks to give players time to get out of the way
 */
/datum/component/swing_attack_telegraph
	/// Time to wait before attack can complete
	var/telegraph_duration
	/// Overlay which we display over the centre of our swing
	var/mutable_appearance/target_overlay
	/// Our current target, if we have one
	var/turf/current_target
	/// If true, only utilise this component in combat mode
	var/combat_only
	/// Callback executed when we start aiming at something
	var/datum/callback/on_began_forecast

/datum/component/swing_attack_telegraph/Initialize(
	telegraph_icon = 'icons/mob/telegraphing/telegraph.dmi',
	telegraph_state = ATTACK_EFFECT_BITE,
	telegraph_duration = 0.4 SECONDS,
	combat_only = TRUE,
	datum/callback/on_began_forecast,
)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	target_overlay = mutable_appearance(telegraph_icon, telegraph_state)
	src.telegraph_duration = telegraph_duration
	src.on_began_forecast = on_began_forecast
	src.combat_only = combat_only

/datum/component/swing_attack_telegraph/Destroy(force, silent)
	if(current_target)
		forget_target(current_target)
	target_overlay = null
	on_began_forecast = null
	return ..()

/datum/component/swing_attack_telegraph/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_ATTACK_STYLE_PREPROCESS, PROC_REF(on_swing))

/datum/component/swing_attack_telegraph/UnregisterFromParent()
	if (current_target)
		forget_target(current_target)
	REMOVE_TRAIT(parent, TRAIT_SWING_FORECAST_COMPLETE, REF(src))
	UnregisterSignal(parent, COMSIG_LIVING_ATTACK_STYLE_PREPROCESS)
	return ..()

/// When we attempt to attack, check if it is allowed
/datum/component/swing_attack_telegraph/proc/on_swing(mob/living/attacker, datum/attack_style/style, atom/weapon, list/affected_turfs)
	SIGNAL_HANDLER
	if (combat_only && !attacker.combat_mode)
		return
	if (DOING_INTERACTION(attacker, DOAFTER_SOURCE_SWING_FORECAST))
		return CANCEL_ATTACK_PREPROCESS
	if (HAS_TRAIT(attacker, TRAIT_SWING_FORECAST_COMPLETE))
		REMOVE_TRAIT(attacker, TRAIT_SWING_FORECAST_COMPLETE, REF(src))
		return
	INVOKE_ASYNC(src, PROC_REF(delayed_attack), attacker, style, weapon, affected_turfs)
	return CANCEL_ATTACK_PREPROCESS

/// Perform an attack after a delay
/datum/component/swing_attack_telegraph/proc/delayed_attack(mob/living/attacker, datum/attack_style/style, atom/weapon, list/affected_turfs)
	var/turf/target_turf = get_turf(style.get_movable_to_layer_effect_over(affected_turfs))
	RegisterSignal(target_turf, COMSIG_QDELETING, PROC_REF(forget_target))
	target_turf.add_overlay(target_overlay)
	on_began_forecast?.Invoke(target_turf)
	var/succeeded = do_after(attacker, delay = telegraph_duration, target = target_turf, timed_action_flags = IGNORE_TARGET_LOC_CHANGE, interaction_key = DOAFTER_SOURCE_SWING_FORECAST)
	forget_target(target_turf)
	if (!succeeded)
		return
	ADD_TRAIT(attacker, TRAIT_SWING_FORECAST_COMPLETE, REF(src))
	style.process_attack(attacker, weapon, target_turf)

/// The guy we're trying to attack isn't a valid target any more
/datum/component/swing_attack_telegraph/proc/forget_target(atom/target)
	SIGNAL_HANDLER
	current_target = null
	target.cut_overlay(target_overlay)
	UnregisterSignal(target, COMSIG_QDELETING)
