GLOBAL_LIST_EMPTY(human_to_tts)

/datum/preference_middleware/text_to_speech
	action_delegations = list(
		"listen" = PROC_REF(listen_voice),
		"select_voice" = PROC_REF(select_voice),
	)

/datum/preference_middleware/text_to_speech/get_ui_data(mob/user)
	var/list/data = list()
	data["tts_seed"] = preferences.read_preference(/datum/preference/text/tts_seed)
	data["tts_enabled"] = CONFIG_GET(flag/tts_enabled)
	return data

/datum/preference_middleware/text_to_speech/get_constant_data()
	var/list/data = list()
	data["providers"] = get_tts_providers_ui_data()
	data["seeds"] = get_tts_seeds_ui_data()
	data["phrases"] = TTS_PHRASES
	return data

/datum/preference_middleware/text_to_speech/proc/get_tts_providers_ui_data()
	var/list/providers = list()
	for(var/_provider in SStts220.tts_providers)
		var/datum/tts_provider/provider = SStts220.tts_providers[_provider]
		providers += list(list(
			"name" = provider.name,
			"is_enabled" = provider.is_enabled,
		))
	return providers

/datum/preference_middleware/text_to_speech/proc/get_tts_seeds_ui_data()
	var/list/seeds = list()
	for(var/_seed in SStts220.tts_seeds)
		var/datum/tts_seed/seed = SStts220.tts_seeds[_seed]
		seeds += list(list(
			"name" = seed.name,
			"value" = seed.value,
			"category" = seed.category,
			"gender" = seed.gender,
			"provider" = initial(seed.provider.name),
			"donator_level" = seed.required_donator_level,
		))
	return seeds

/datum/preference_middleware/text_to_speech/proc/listen_voice(list/params, mob/user)
	var/seed_name = params["seed"]
	if(!seed_name)
		return FALSE

	var/datum/tts_seed/seed = SStts220.tts_seeds[seed_name]
	if(!seed)
		return FALSE

	var/phrase = params["phrase"]
	if(!phrase || !(phrase in TTS_PHRASES))
		phrase = pick(TTS_PHRASES)

	INVOKE_ASYNC(SStts220, TYPE_PROC_REF(/datum/controller/subsystem/tts220, get_tts), null, usr, phrase, seed, FALSE)

	return FALSE

/datum/preference_middleware/text_to_speech/proc/select_voice(list/params, mob/user)
	var/seed_name = params["seed"]
	if(!seed_name || !SStts220.tts_seeds[seed_name])
		return FALSE

	var/list/available_seeds = SStts220.get_available_seeds(user)
	if(!(seed_name in available_seeds))
		return FALSE

	preferences.update_preference(GLOB.preference_entries[/datum/preference/text/tts_seed], seed_name)
	return TRUE
