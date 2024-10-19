/** This system was ported from Mojave Sun 13 and modified, where it was ported from Concordia and modified :3c
 * The meat of the system is a process by which a user's message is received, processed into a list of pseudo-syllables and punctuation. Originally a regex was used to try and identify syllables, but due to
 * English language conventions this is more complicated than this system really needs. Every three characters is detected, and then the first letter of that character is used to determine what sound is played. Punctuation
 * plays no sound, but leaves an empty space to indicate it's use.
 * Currently the sound file must be passed as a sound datum. This was initially with the intention of using BYOND's in-built pitch on sound datums, but that sucks and has a bunch of weird issues. It does have the added benefit
 * of giving a check to make sure we're actually passing a real sound file through to playsound_local, though.
 *
 * File format is as follows: [voice name]/[letter][variation].wav.
 * Each vowel has twenty variations, while each consonant has six.
 * An Audacity macro to make the sounds less irritating on the ear was made and used to process each voice. It can be found in the initial PR related to this system.
 */

/datum/component/dopplerboop
	var/chosen_boop // voice type assigned by preference
	var/volume = DOPPLERBOOP_DEFAULT_VOLUME
	var/falloff = DOPPLERBOOP_DEFAULT_FALLOFF
	var/duration = DOPPLERBOOP_DEFAULT_DURATION // duration between each syllable, i.e. speech speed
	var/frequency = DOPPLERBOOP_DEFAULT_FREQUENCY // speed at which the sound file is played
	var/last_dopplerboop = 0

/datum/component/dopplerboop/Initialize(mob/living/target, volume = DOPPLERBOOP_DEFAULT_VOLUME, duration = DOPPLERBOOP_DEFAULT_DURATION)
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.volume = volume
	src.duration = duration

/datum/component/dopplerboop/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_POST_SAY, PROC_REF(after_say))

/datum/component/dopplerboop/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOB_POST_SAY)

/datum/component/dopplerboop/proc/after_say(mob/dopplerbooper, list/speech_args, list/speech_spans, list/speech_mods)
	SIGNAL_HANDLER
	last_dopplerboop = world.time
	INVOKE_ASYNC(src, PROC_REF(handle_booping), dopplerbooper, speech_args, speech_spans, speech_mods)

/datum/component/dopplerboop/proc/handle_booping(mob/living/carbon/human/dopplerbooper, list/speech_args, list/speech_spans, list/speech_mods)
	chosen_boop = dopplerbooper?.voice_type || random_voice_type() // Uses the boop chosen by the player. If it's null for whatever unholy reason, it should chose a completely random voice for every single phonetic which should be funny.
	if(chosen_boop == "mute")
		return
	var/message = speech_args[SPEECH_MESSAGE]
	var/initial_dopplerboop_time = last_dopplerboop
	var/initial_volume = volume
	var/initial_falloff = falloff
	var/boop_letter = null
	var/sound/final_boop = null
	if(speech_mods[WHISPER_MODE]) // Makes you quieter when whispering...
		initial_volume -= 25
		initial_falloff -= 5
	else if(speech_spans[SPAN_YELL]) // And louder when yelling
		initial_volume += 15
		initial_falloff += 3
	var/obj/item/clothing/mask/mask = dopplerbooper.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask) && mask.voice_filter && !mask.adjusted_flags) // Helps muffle a little bit
		initial_volume -= 0.1
		initial_falloff -= 1
	var/initial_delay = duration
	var/list/hearers = GLOB.player_list.Copy() 	// This stuff is for people that don't want to hear it
	for(var/mob/hearer as anything in hearers)
		if(hearer.client && hearer.can_hear() && hearer.client.prefs.read_preference(/datum/preference/toggle/enable_dopplerboops))
			continue
		hearers -= hearer
	var/dopplerboop_delay_cumulative = 0

	var/regex/syllables = regex(@"([a-zA-Z]|[,;.!-\s])", "gmi")
	var/list/all_boops = splittext(message, syllables)


	for(var/i in 1 to min(length(all_boops), MAX_DOPPLERBOOP_CHARACTERS))
		var/volume = initial_volume
		var/current_delay = initial_delay
		if(!all_boops[i] || all_boops[i] == " ")
			continue
		boop_letter = lowertext(all_boops[i][1])
		if(!is_alpha(boop_letter))
			if(boop_letter == "." || boop_letter == "!")
				volume = 0
				current_delay *= 2
			else
				volume = 0
				current_delay *= 1.5
			final_boop = null
		else
			var/variation
			if(boop_letter in VOWELS)
				variation = rand(1, 20)
			else
				variation = rand(1, 5)
			final_boop = sound("modular_doppler/dopplerboop/voices/[chosen_boop]/[boop_letter][variation].wav")

		addtimer(CALLBACK(src, PROC_REF(play_dopplerboop), hearers, dopplerbooper, final_boop, volume, initial_dopplerboop_time, initial_falloff, frequency), dopplerboop_delay_cumulative + current_delay)
		dopplerboop_delay_cumulative += current_delay

/datum/component/dopplerboop/proc/play_dopplerboop(list/hearers, mob/dopplerbooper, final_boop, volume, initial_dopplerboop_time, falloff_exponent, freq)
	if(!volume || (last_dopplerboop != initial_dopplerboop_time) || !final_boop)
		return
	for(var/mob/hearer as anything in hearers)
		var/user_volume = hearer.client?.prefs.read_preference(/datum/preference/numeric/voice_volume)
		volume = volume*(user_volume / 10)
		hearer.playsound_local(turf_source = get_turf(dopplerbooper), sound_to_use = final_boop, vol = volume, vary = TRUE, frequency = freq, falloff_distance = falloff_exponent, max_distance = 16)
