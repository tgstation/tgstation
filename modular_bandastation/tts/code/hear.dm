/mob/show_message(msg, type, alt_msg, alt_type, avoid_highlighting)
    if(!client)
        return FALSE
    msg = replacetext_char(msg, "+", null)
    . = ..()

/datum/chatmessage/New(text, atom/target, mob/owner, datum/language/language, list/extra_classes, lifespan)
    text = replacetext_char(text, "+", null)
    . = ..()

/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
    . = ..()
    if(!. || (message_mods[MODE_CUSTOM_SAY_EMOTE] && message_mods[MODE_CUSTOM_SAY_ERASE_INPUT]))
        return
    speaker.cast_tts(src, raw_message, effect = radio_freq ? /datum/singleton/sound_effect/radio : null)

/mob/dead/observer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
    . = ..()
    if(!. || (message_mods[MODE_CUSTOM_SAY_EMOTE] && message_mods[MODE_CUSTOM_SAY_ERASE_INPUT]))
        return
    speaker.cast_tts(src, raw_message, effect = radio_freq ? /datum/singleton/sound_effect/radio : null)

/atom/movable/virtualspeaker/cast_tts(mob/listener, message, atom/location, is_local, effect, traits, preSFX, postSFX)
    SEND_SIGNAL(source, COMSIG_ATOM_TTS_CAST, listener, message, location, is_local, effect, traits, preSFX, postSFX)
