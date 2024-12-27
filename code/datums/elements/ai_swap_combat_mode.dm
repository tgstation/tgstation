/**
 * Attached to a mob with an AI controller, updates combat mode when the affected mob acquires or loses targets
 */
/datum/element/ai_swap_combat_mode
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The message we yell when we enter combat mode
	var/list/battle_start_barks
	/// A one liner said when we exit combat mode
	var/list/battle_end_barks
	/// The chance to yell the above lines
	var/speech_chance
	/// Target key
	var/target_key

/datum/element/ai_swap_combat_mode/Attach(datum/target, target_key, list/battle_start_barks = null, list/battle_end_barks = null)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/living_target = target
	if(!living_target.ai_controller)
		return ELEMENT_INCOMPATIBLE

	if(isnull(battle_start_barks))
		battle_start_barks = list("En Garde!",)

	if(isnull(battle_end_barks))
		battle_end_barks = list("Never should have come here",)

	src.battle_start_barks = battle_start_barks
	src.battle_end_barks = battle_end_barks
	src.target_key = target_key
	RegisterSignal(target, COMSIG_AI_BLACKBOARD_KEY_SET(target_key), PROC_REF(on_target_gained))
	RegisterSignal(target, COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key), PROC_REF(on_target_cleared))

/datum/element/ai_swap_combat_mode/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_AI_BLACKBOARD_KEY_SET(target_key),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key),
	))

/// When the mob gains a target, and it was not already in combat mode, enter it
/datum/element/ai_swap_combat_mode/proc/on_target_gained(mob/living/source)
	SIGNAL_HANDLER

	if(swap_mode(source, TRUE))
		INVOKE_ASYNC(src, PROC_REF(speak_bark), source, battle_start_barks)

/// When the mob loses its target, and it was not already out of combat mode, exit it
/datum/element/ai_swap_combat_mode/proc/on_target_cleared(mob/living/source)
	SIGNAL_HANDLER

	if(swap_mode(source, FALSE))
		INVOKE_ASYNC(src, PROC_REF(speak_bark), source, battle_end_barks)

///Says a quip, if the RNG allows it
/datum/element/ai_swap_combat_mode/proc/speak_bark(mob/living/source, line)
	source.say(pick(line))

///If the combat mode would be changed into a different state, updates it and returns TRUE, otherwise returns FALSE
/datum/element/ai_swap_combat_mode/proc/swap_mode(mob/living/source, new_mode)
	if(source.combat_mode == new_mode)
		return FALSE
	source.set_combat_mode(new_mode)
	return TRUE
