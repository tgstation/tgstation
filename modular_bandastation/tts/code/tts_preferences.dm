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
			"donator_level" = seed.required_donator_level,
		))
	data["seeds"] = seeds
	data["phrases"] = TTS_PHRASES
	return data

/datum/preferences/ui_data(mob/user)
	var/list/data = ..()
	data["tts_seed"] = read_preference(/datum/preference/text/tts_seed)
	return data

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("listen")
			var/phrase = params["phrase"]
			var/seed_name = params["seed"]
			if((phrase in TTS_PHRASES) && (seed_name in SStts220.tts_seeds))
				INVOKE_ASYNC(SStts220, TYPE_PROC_REF(/datum/controller/subsystem/tts220, get_tts), null, usr, phrase, SStts220.tts_seeds[seed_name], FALSE)
			return FALSE
		if("select_voice")
			var/seed_name = params["seed"]
			if(!isnull(seed_name) && (seed_name in SStts220.tts_seeds))
				write_preference(GLOB.preference_entries[/datum/preference/text/tts_seed], seed_name)
			return TRUE

/datum/preference/text/tts_seed
	savefile_key = "tts_seed"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/text/tts_seed/apply_to_human(mob/living/carbon/human/target, value)
	target.AddComponent(/datum/component/tts_component, SStts220.tts_seeds[value])
	target.dna.tts_seed_dna = SStts220.tts_seeds[value]

/datum/preference/numeric/sound_tts_volume_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_volume_radio"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 100

/datum/preference/numeric/sound_tts_volume_radio/create_default_value()
	return maximum
