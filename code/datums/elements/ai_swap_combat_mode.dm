/**
 * Attached to a mob with an AI controller, updates combat mode when the affected mob acquires or loses targets
 */
/datum/element/ai_swap_combat_mode
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The message we yell when we enter combat mode
	var/battle_start_bark
	/// A one liner said when we exit combat mode
	var/battle_end_bark
	/// The chance to yell the above lines
	var/speech_chance
	/// Target key
	var/target_key

/datum/element/ai_swap_combat_mode/Attach(datum/target, target_key, battle_start_bark = "Guards!", battle_end_bark = "Never should have come here")
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/living_target = target
	if(!living_target.ai_controller)
		return ELEMENT_INCOMPATIBLE
	src.battle_start_bark = battle_start_bark
	src.battle_end_bark = battle_end_bark
	src.target_key = target_key
	RegisterSignal(target, COMSIG_AI_BLACKBOARD_KEY_SET(target_key), PROC_REF(on_target_gained))
	RegisterSignal(target, COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key), PROC_REF(on_target_cleared))

/datum/element/ai_swap_combat_mode/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_AI_BLACKBOARD_KEY_SET(target_key))
	UnregisterSignal(source, COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key))

/// When the mob gains a target, and it was not already in combat mode, enter it
/datum/element/ai_swap_combat_mode/proc/on_target_gained(mob/living/source)
	SIGNAL_HANDLER

	if(swap_mode(source, TRUE))
		INVOKE_ASYNC(src, PROC_REF(speak_bark), source, battle_start_bark)

/// When the mob loses its target, and it was not already out of combat mode, exit it
/datum/element/ai_swap_combat_mode/proc/on_target_cleared(mob/living/source)
	SIGNAL_HANDLER

	if(swap_mode(source, FALSE))
		INVOKE_ASYNC(src, PROC_REF(speak_bark), source, battle_end_bark)

///Says a quip, if the RNG allows it
/datum/element/ai_swap_combat_mode/proc/speak_bark(mob/living/source, line)
	source.say(line)

///If the combat mode would be changed into a different state, updates it and returns TRUE, otherwise returns FALSE
/datum/element/ai_swap_combat_mode/proc/swap_mode(mob/living/source, new_mode)
	if(source.combat_mode==new_mode)
		return FALSE
	source.set_combat_mode(new_mode)
	return TRUE
