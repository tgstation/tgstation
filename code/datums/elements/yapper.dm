/// Makes the mob play a funny animation when they talk
/datum/element/yapper
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Icon used to grab part of the mob to animate
	var/mask_icon
	/// Icon state used to grab part of the mob to animate
	var/mask_icon_state

/datum/element/yapper/Attach(datum/target, mask_icon = 'icons/effects/cut.dmi', mask_icon_state = "cut_head")
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE // I would love for vending machines to do it but they cant take status effects
	src.mask_icon = mask_icon
	src.mask_icon_state = mask_icon_state
	RegisterSignal(target, COMSIG_MOB_SAY, PROC_REF(on_spoke))

/datum/element/yapper/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_MOB_SAY)

/// When they speak, animate. It's virtually all handled by status effect anyway
/datum/element/yapper/proc/on_spoke(mob/living/yapper, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	var/list/words = splittext(message, " ")

	// Maybe there's some fancy regex I could do to more accurately grab syllable count but this is fine
	var/naive_length = 0
	for (var/word in words)
		naive_length += ceil(length(word) / 4)

	yapper.apply_status_effect(/datum/status_effect/yapping, naive_length, mask_icon, mask_icon_state)
