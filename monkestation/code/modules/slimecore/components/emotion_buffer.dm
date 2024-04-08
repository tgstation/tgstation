//This is really just a storage cell for mood messages, also handles some basic responding to emotional events for mobs
/datum/component/emotion_buffer
	var/mob/living/host

	///our current emotion
	var/current_emotion = EMOTION_HAPPY

	///the buffer of emotional things with there emotion stored like EMOTION_HAPPY = List("Was fed by x")
	var/emotional_buffer = list(
		EMOTION_HAPPY = list(),
		EMOTION_SAD = list(),
		EMOTION_ANGER = list(),
		EMOTION_FUNNY = list(),
		EMOTION_SCARED = list(),
		EMOTION_SUPRISED = list(),
		EMOTION_HUNGRY = list(),
	)

	var/emotional_responses = list(
		EMOTION_HAPPY = list(),
		EMOTION_SAD = list(),
		EMOTION_ANGER = list(),
		EMOTION_FUNNY = list(),
		EMOTION_SCARED = list(),
		EMOTION_SUPRISED = list(),
		EMOTION_HUNGRY = list(),
	)

	var/emotional_heard = list(
		EMOTION_HAPPY = list(),
		EMOTION_SAD = list(),
		EMOTION_ANGER = list(),
		EMOTION_FUNNY = list(),
		EMOTION_SCARED = list(),
		EMOTION_SUPRISED = list(),
		EMOTION_HUNGRY = list(),
	)

	///these are sent as emotion = icon_state, where the icon is stored inside the sources icon file
	var/list/emotional_overlays = list()

/datum/component/emotion_buffer/Initialize(list/emotional_overlay_states)
	. = ..()
	host = parent
	if(!length(emotional_overlay_states))
		emotional_overlays = list()
	emotional_overlays = emotional_overlay_states

/datum/component/emotion_buffer/RegisterWithParent()
	. = ..()
	if(length(emotional_overlays))
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(emotion_overlay))
		RegisterSignal(parent, EMOTION_BUFFER_UPDATE_OVERLAY_STATES, PROC_REF(replace_overlays))

	RegisterSignal(parent, COMSIG_EMOTION_STORE, PROC_REF(register_emotional_data))
	RegisterSignal(parent, EMOTION_BUFFER_SPEAK_FROM_BUFFER, PROC_REF(speak_from_buffer))
	RegisterSignal(parent, COMSIG_EMOTION_HEARD, PROC_REF(store_heard))
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(hear_speech))

/datum/component/emotion_buffer/Destroy(force, silent)
	. = ..()
	host = null

/datum/component/emotion_buffer/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_EMOTION_STORE)
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(parent, EMOTION_BUFFER_UPDATE_OVERLAY_STATES)
	UnregisterSignal(parent, EMOTION_BUFFER_SPEAK_FROM_BUFFER)
	UnregisterSignal(parent, COMSIG_EMOTION_HEARD)
	UnregisterSignal(parent, COMSIG_MOVABLE_HEAR)


/datum/component/emotion_buffer/proc/register_emotional_data(datum/source, atom/from, emotion, emotional_text, intensity = 1)
	if(!emotional_buffer[emotion])
		return

	if((emotion in list(EMOTION_ANGER, EMOTION_SAD, EMOTION_SCARED)) && intensity)
		intensity *= -1


	if(from)
		emotional_buffer[emotion] += list("[from] [emotional_text]" = FALSE)
		if(intensity)
			SEND_SIGNAL(parent, COMSIG_FRIENDSHIP_CHANGE, from, intensity)
	else
		emotional_buffer[emotion] += list("[emotional_text]" = FALSE)

	current_emotion = emotion

/datum/component/emotion_buffer/proc/emotion_overlay(mob/living/source, list/overlays)
	if(!emotional_overlays[current_emotion])
		return
	if(source.health <= 0)
		return
	overlays += mutable_appearance(source.icon, emotional_overlays[current_emotion], source.layer, source)

/datum/component/emotion_buffer/proc/replace_overlays(mob/living/source, list/new_icon_states)
	emotional_overlays = list()
	emotional_overlays += new_icon_states

/datum/component/emotion_buffer/proc/speak_from_buffer(mob/living/source)
	if(prob(100))
		var/spoken_emotion = current_emotion
		if(prob(25))
			var/list/viable_emotions = list()
			for(var/emotion in emotional_buffer)
				if(!length(emotional_buffer[emotion]))
					continue
				viable_emotions |= emotion
			if(!length(viable_emotions))
				return
			spoken_emotion = pick(viable_emotions)
		var/list/speakable_phrases = list()
		for(var/phrase in emotional_buffer[spoken_emotion])
			if(emotional_buffer[spoken_emotion][phrase])
				continue
			speakable_phrases |= phrase

		if(!length(speakable_phrases))
			return
		var/choice = pick(speakable_phrases)
		if(!choice)
			return
		emotional_buffer[spoken_emotion][choice] = TRUE
		source.say(choice)

		for(var/mob/living/mob in range(5, source))
			if(mob == source)
				continue
			SEND_SIGNAL(mob, COMSIG_EMOTION_HEARD, spoken_emotion, choice, source)

/datum/component/emotion_buffer/proc/store_heard(mob/living/source, emotion, phrase, mob/living/speaker)
	emotional_heard[emotion] += list("[speaker] said [phrase]" = FALSE)

/datum/component/emotion_buffer/proc/hear_speech()
