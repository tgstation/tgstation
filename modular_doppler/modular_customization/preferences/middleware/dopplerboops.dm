/// Middleware gamejacked from TTS preview.
/datum/preference_middleware/dopplerboop
	/// Cooldown on requesting a dopplerboop preview.
	COOLDOWN_DECLARE(dopplerboop_cooldown)

	action_delegations = list(
		"play_boop_voice" = PROC_REF(play_boop_voice)
	)

/datum/preference_middleware/dopplerboop/proc/debug_booping(mob/user, chosen_boop)
	var/regex/syllables = regex(@"([a-zA-Z]|[,;.!-\s])", "gmi")
	var/list/all_boops = splittext("Hello, this is my voice.", syllables)
	var/boop_letter = null
	var/dopplerboop_delay_cumulative = 0
	var/sound/final_boop = null
	var/user_volume = user.client?.prefs.read_preference(/datum/preference/numeric/voice_volume)

	for(var/i in 1 to min(length(all_boops), MAX_DOPPLERBOOP_CHARACTERS))
		var/volume = DOPPLERBOOP_DEFAULT_VOLUME
		var/current_delay = DOPPLERBOOP_DEFAULT_DURATION
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
			final_boop = "modular_doppler/dopplerboop/voices/[chosen_boop]/[boop_letter][variation].wav"
		volume = volume*(user_volume / 10)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, playsound_local), null, final_boop, volume), dopplerboop_delay_cumulative + current_delay)
		dopplerboop_delay_cumulative += current_delay

/datum/preference_middleware/dopplerboop/proc/play_boop_voice(list/params, mob/user)
	if(!COOLDOWN_FINISHED(src, dopplerboop_cooldown))
		return TRUE
	COOLDOWN_START(src, dopplerboop_cooldown, 5 SECONDS)
	var/chosen_boop = user?.client?.prefs.read_preference(/datum/preference/choiced/voice_type) || random_voice_type()
	if(chosen_boop == "mute")
		return
	INVOKE_ASYNC(src, PROC_REF(debug_booping), user, chosen_boop)
	return TRUE
