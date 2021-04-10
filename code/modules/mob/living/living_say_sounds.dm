/// -- mob/living vars and overrides. --
/// Bitflags for what kind of sound we're making
#define SOUND_NORMAL (1<<0)
#define SOUND_QUESTION (1<<1)
#define SOUND_EXCLAMATION (1<<2)

/// Default, middle frequency
#define DEFAULT_FREQUENCY 44100

//I don't want to fuck up say so I'm putting it all here.
/mob/living/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	. = ..()

	// If say failed for some reason we should probably fail
	if(!.)
		return

	/// Our list of sounds we're going to play
	var/list/chosen_speech_sounds
	/// Whether this is a question, an exclamation, or neither
	var/sound_type
	/// What frequency we pass to playsound for variance
	var/sound_frequency = DEFAULT_FREQUENCY
	/// The last char of the message.
	var/msg_end = copytext_char(message, -1)
	// Determine if this is a question, an exclamation, or neither and update sound_type and sound_frequency accordingly.
	switch(msg_end)
		if("?")
			sound_type = SOUND_QUESTION
			sound_frequency = rand(DEFAULT_FREQUENCY, 55000) //questions are raised in the end
		if("!")
			sound_type = SOUND_EXCLAMATION
			sound_frequency = rand(32000, DEFAULT_FREQUENCY) //exclamations are lowered in the end
		else
			sound_type = SOUND_NORMAL
			sound_frequency = round((get_rand_frequency() + get_rand_frequency())/2) //normal speaking is just the average of 2 random frequencies (to trend to the middle)

	/// our speaker (src) typecasted into a human.
	var/mob/living/carbon/human/human_speaker = src
	// If we ARE a human, check for species specific speech sounds
	if(istype(human_speaker) && human_speaker.dna?.species)
		if(sound_type & SOUND_QUESTION)
			chosen_speech_sounds = human_speaker.dna.species.species_speech_sounds_ask
		if(sound_type & SOUND_EXCLAMATION)
			chosen_speech_sounds = human_speaker.dna.species.species_speech_sounds_exclaim
		if(sound_type & SOUND_NORMAL || !LAZYLEN(chosen_speech_sounds)) //default sounds if the other ones are empty
			chosen_speech_sounds = human_speaker.dna.species.species_speech_sounds
	// If we're not a human with a species, use the mob speech sounds
	else if(LAZYLEN(mob_speech_sounds))
		chosen_speech_sounds = mob_speech_sounds

	if(!LAZYLEN(chosen_speech_sounds))
		return

	/// Pick a sound from our found sounds and play it.
	var/picked_sound = pick(chosen_speech_sounds)
	playsound(src, picked_sound, chosen_speech_sounds[picked_sound], vary = TRUE, frequency = sound_frequency, pressure_affected = TRUE, extrarange = -10, ignore_walls = FALSE)

/// Extend hear so we can have radio messages make radio sounds.
/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()

	// No message = no sound.
	if(!message)
		return

	// Don't bother playing sounds to clientless mobs to save time
	if(!client)
		return

	// We only deal with radio messages from this point
	if(!message_mods[MODE_HEADSET] && !message_mods[RADIO_EXTENSION])
		return

	/// The list of chosen sounds we hear.
	var/list/chosen_speech_sounds
	/// Speaker typecasted into a virtual speaker (Radios use virtualspeakers)
	var/atom/movable/virtualspeaker/vspeaker = speaker
	/// Speaker typecasted into a /mob/living
	var/mob/living/living_speaker
	// Speaker is either a virtual speaker or a mob - whatever it is it needs to be a mob in the end.
	if(istype(vspeaker))
		living_speaker = vspeaker.source
		if(!istype(living_speaker))
			return
	else if(isliving(speaker))
		living_speaker = speaker
	else
		return

	chosen_speech_sounds = living_speaker.mob_radio_sounds

	if(!LAZYLEN(chosen_speech_sounds))
		return

	/// Pick a sound from our found sounds and play it.
	var/picked_sound = pick(chosen_speech_sounds)
	if(living_speaker == src)
		playsound(src, picked_sound, chosen_speech_sounds[picked_sound], vary = TRUE, extrarange = -13, ignore_walls = FALSE)
	else
		playsound(src, picked_sound, chosen_speech_sounds[picked_sound] - 15, vary = TRUE, extrarange = -15, ignore_walls = FALSE)


#undef SOUND_NORMAL
#undef SOUND_QUESTION
#undef SOUND_EXCLAMATION
#undef DEFAULT_FREQUENCY
