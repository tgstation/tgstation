/datum/preferences/ui_static_data(mob/user)
	var/list/data = ..()

	data["tts_enabled"] = CONFIG_GET(flag/tts_enabled)

	var/list/providers = list()
	for(var/_provider in SStts220.tts_providers)
		var/datum/tts_provider/provider = SStts220.tts_providers[_provider]
		providers += list(list(
			"name" = provider.name,
			"is_enabled" = provider.is_enabled,
		))
	data["providers"] = providers

	var/list/seeds = list()
	for(var/_seed in SStts220.tts_seeds)
		var/datum/tts_seed/seed = SStts220.tts_seeds[_seed]
		seeds += list(list(
			"name" = seed.name,
			"value" = seed.value,
			"category" = seed.category,
			"gender" = seed.gender,
			"provider" = initial(seed.provider.name),
			"donator_level" = seed.donator_level,
		))
	data["seeds"] = seeds

	data["phrases"] = TTS_PHRASES

	return data


/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch (action)
		if("listen")
			var/phrase = params["phrase"]
			var/seed_name = params["seed"]

			if((phrase in TTS_PHRASES) && (seed_name in SStts220.tts_seeds))
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, usr, phrase, seed_name, FALSE)
			return FALSE

		if("select_voice")
			var/seed_name = params["seed"]
			var/datum/preference/tts_seed = GLOB.preference_entries_by_key["tts_seed"]
			write_preference(tts_seed, seed_name)
			return TRUE

/datum/preference/numeric/sound_tts_local
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_local"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 100

/datum/preference/numeric/sound_tts_local/create_default_value()
	return 100

/datum/preference/numeric/sound_tts_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_radio"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 100

/datum/preference/numeric/sound_tts_radio/create_default_value()
	return 50
