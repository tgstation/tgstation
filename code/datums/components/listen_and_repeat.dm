/// The maximum number of phrases we can store in our speech buffer
#define MAX_SPEECH_BUFFER_SIZE 500
/// Tendency we have to ignore radio chatter
#define RADIO_IGNORE_CHANCE 10

/// Simple element that will deterministically set a value based on stuff that the source has heard and will then compel the source to repeat it.
/// Requires a valid AI Blackboard.
/datum/component/listen_and_repeat
	/// List of things that we start out having in our speech buffer
	var/list/desired_phrases = null
	/// The AI Blackboard Key we assign the value to.
	var/blackboard_key = null
	/// Probability we speak
	var/speech_probability = null
	/// Probabiliy we switch our phrase
	var/switch_phrase_probability = null
	/// List of things that we've heard and will repeat.
	var/list/speech_buffer = null

/datum/component/listen_and_repeat/Initialize(list/desired_phrases, blackboard_key)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	if(!isnull(desired_phrases))
		LAZYADD(speech_buffer, desired_phrases)

	src.blackboard_key = blackboard_key

	RegisterSignal(parent, COMSIG_MOVABLE_PRE_HEAR, PROC_REF(on_hear))
	RegisterSignal(parent, COMSIG_NEEDS_NEW_PHRASE, PROC_REF(set_new_blackboard_phrase))
	RegisterSignal(parent, COMSIG_LIVING_WRITE_MEMORY, PROC_REF(on_write_memory))

	ADD_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/component/listen_and_repeat/Destroy(force, silent)
	REMOVE_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)
	return ..()

/// Called when we hear something.
/datum/component/listen_and_repeat/proc/on_hear(datum/source, list/passed_arguments)
	SIGNAL_HANDLER

	var/message = passed_arguments[HEARING_RAW_MESSAGE]
	var/speaker = passed_arguments[HEARING_SPEAKER]
	var/over_radio = !!passed_arguments[HEARING_RADIO_FREQ]
	if(speaker == source) // don't parrot ourselves
		return

	if(over_radio && prob(RADIO_IGNORE_CHANCE))
		return

	var/number_of_excess_strings = LAZYLEN(speech_buffer) - MAX_SPEECH_BUFFER_SIZE
	if(number_of_excess_strings > 0) // only remove if we're overfull
		for(var/i in 1 to number_of_excess_strings)
			LAZYREMOVE(speech_buffer, pick(speech_buffer))

	LAZYOR(speech_buffer, html_decode(message))

/// Called to set a new value for the blackboard key.
/datum/component/listen_and_repeat/proc/set_new_blackboard_phrase(datum/source)
	SIGNAL_HANDLER
	var/atom/movable/atom_source = source
	var/datum/ai_controller/controller = atom_source.ai_controller
	if(!LAZYLEN(speech_buffer))
		controller.clear_blackboard_key(blackboard_key)
		return NO_NEW_PHRASE_AVAILABLE

	var/selected_phrase = pick(speech_buffer)
	controller.set_blackboard_key(blackboard_key, selected_phrase)

/// Exports all the speech buffer data to a dedicated blackboard key on the source.
/datum/component/listen_and_repeat/proc/on_write_memory(datum/source, dead, gibbed)
	SIGNAL_HANDLER
	var/atom/movable/atom_source = source
	var/datum/ai_controller/controller = atom_source.ai_controller
	if(LAZYLEN(speech_buffer)) // what? well whatever let's just move on
		return

	controller.set_blackboard_key(BB_EXPORTABLE_STRING_BUFFER_LIST, speech_buffer.Copy())

#undef MAX_SPEECH_BUFFER_SIZE
#undef RADIO_IGNORE_CHANCE
