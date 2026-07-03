/datum/dna
	var/datum/tts_seed/tts_seed_dna

/datum/dna/copy_dna(datum/dna/new_dna, transfer_flags = COPY_DNA_SE|COPY_DNA_SPECIES)
	. = ..()
	new_dna.tts_seed_dna = tts_seed_dna
	if(istype(new_dna.holder))
		new_dna.holder.AddComponent(/datum/component/tts_component, new_dna.tts_seed_dna)

/atom/proc/add_tts_component()
	return

/atom/Initialize(mapload, ...)
	. = ..()
	add_tts_component()

/atom/proc/cast_tts(mob/listener, message, atom/location, is_local = TRUE, is_radio = FALSE, list/effects, traits = TTS_TRAIT_RATE_FASTER, preSFX, postSFX, tts_seed_override, channel_override, check_deafness)
	SEND_SIGNAL(src, COMSIG_ATOM_TTS_CAST, listener, message, location, is_local, is_radio, effects, traits, preSFX, postSFX, tts_seed_override, channel_override, check_deafness)

/atom/movable/virtualspeaker/cast_tts(mob/listener, message, atom/location, is_local, is_radio, list/effects, traits, preSFX, postSFX, tts_seed_override, channel_override, check_deafness)
	SEND_SIGNAL(source, COMSIG_ATOM_TTS_CAST, listener, message, location, is_local, is_radio, effects, traits, preSFX, postSFX, tts_seed_override, channel_override, check_deafness)

// TODO: Do it better?
/atom/proc/get_tts_seed()
	var/datum/component/tts_component/tts_component = GetComponent(/datum/component/tts_component)
	if(tts_component)
		return tts_component.tts_seed

/atom/proc/get_tts_effects(list/additional_effects)
	var/datum/component/tts_component/tts_component = GetComponent(/datum/component/tts_component)
	return tts_component.get_effects(additional_effects)

/atom/proc/change_tts_seed(mob/chooser, overrides, list/new_sound_effects)
	if(!get_tts_seed())
		if(alert(chooser, "Отсутствует TTS компонент. Создать?", "Изменение TTS", "Да", "Нет") == "Нет")
			return
		AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/angel)
	SEND_SIGNAL(src, COMSIG_ATOM_TTS_SEED_CHANGE, chooser, overrides, new_sound_effects)

/atom/proc/tts_effects_add(list/effects)
	SEND_SIGNAL(src, COMSIG_ATOM_TTS_EFFECTS_ADD, effects)

/atom/proc/tts_effects_remove(list/effects)
	SEND_SIGNAL(src, COMSIG_ATOM_TTS_EFFECTS_REMOVE, effects)
