/**
 * Allows a controller to react to sound
 */
/datum/element/ai_react_to_sound
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// minimum volume for us to react to the sound
	var/minimum_volume
	/// target key we set
	var/target_key

/datum/element/ai_react_to_sound/Attach(datum/target, target_key = BB_SOUND_TARGET, minimum_volume = 50)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	src.minimum_volume = minimum_volume
	src.target_key = target_key
	RegisterSignal(target, COMSIG_ATOM_LISTENING_TO_SOUND, PROC_REF(on_sound_hear))

	ADD_TRAIT(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/element/ai_react_to_sound/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_LISTENING_TO_SOUND)

/// If all conditions are met, set the target key
/datum/element/ai_react_to_sound/proc/on_sound_hear(atom/source, atom/voice_source, volume)
	SIGNAL_HANDLER

	if(QDELETED(voice_source) || volume < minimum_volume)
		return
	source.ai_controller?.set_blackboard_key(target_key, voice_source)
