///A status effect that temporarily replaces the sound of an emote with another
/datum/status_effect/replace_sound
	id = "replace_sound"
	tick_interval = -1
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE
	var/list/emote_key_to_sound
	/// priority of the sound, see [signals_mob_living.dm] under COMSIG_LIVING_GET_EMOTE_SOUND
	var/priority

/datum/status_effect/replace_sound/on_creation(mob/living/new_owner, duration, list/emote_key_to_sound, priority = EMOTE_SOUND_STATUS_EFFECT)
	src.duration = duration
	src.emote_key_to_sound = emote_key_to_sound.Copy()
	src.priority = priority
	return ..()

/datum/status_effect/replace_sound/on_apply()
	for(var/key in emote_key_to_sound)
		RegisterSignal(owner, COMSIG_MOB_EMOTE_SOUND(key), PROC_REF(on_emote))
	return TRUE

/datum/status_effect/replace_sound/proc/on_emote(datum/source, key, list/sounds)
	SIGNAL_HANDLER
	var/sound_override = get_emote_sound_from_list(emote_key_to_sound[key], source)
	sounds[sound_override] = priority

/datum/status_effect/replace_sound/on_remove()
	for(var/key in emote_key_to_sound)
		UnregisterSignal(owner, COMSIG_MOB_EMOTE_SOUND(key))
