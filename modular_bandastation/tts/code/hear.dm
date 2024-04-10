/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
    . = ..()
    if(!.)
        return
    speaker.cast_tts(src, raw_message, effect = radio_freq ? /datum/singleton/sound_effect/radio : null)

/mob/dead/observer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
    . = ..()
    if(!.)
        return
    speaker.cast_tts(src, raw_message, effect = radio_freq ? /datum/singleton/sound_effect/radio : null)
