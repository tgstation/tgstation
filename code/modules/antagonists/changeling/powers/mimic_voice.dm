/datum/action/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice. Maintaining this power slows chemical production."
	button_icon_state = "mimic_voice"
	helptext = "Will turn your voice into the name that you enter. We must constantly expend chemicals to maintain our form like this."
	chemical_cost = 0//constant chemical drain hardcoded
	dna_cost = 1
	req_human = TRUE
	var/datum/tts_seed/mimic_tts_seed

// Fake Voice
/datum/action/changeling/mimicvoice/sting_action(mob/user)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(changeling.mimicing)
		changeling.mimicing = ""
		changeling.chem_recharge_slowdown -= 0.25
		to_chat(user, span_notice("We return our vocal glands to their original position."))
		UnregisterSignal(user, COMSIG_TTS_COMPONENT_PRE_CAST_TTS) // BANDASTATION EDIT START - TTS
		return
	// BANDASTATION EDIT START - TTS
	var/mimic_voice
	var/choice = tgui_input_list(user, "Выбрать самому имя или из существующих людей?", "Имитация голоса", list("Ручной ввод имени", "Существующий человек"))
	switch(choice)
		if("Существующий человек")
			mimic_voice = tgui_input_list(user, "Выберите имя для подражания", "Имитация голоса", GLOB.human_to_tts)
			if(!mimic_voice)
				return
			mimic_tts_seed = GLOB.human_to_tts[mimic_voice]
		if("Ручной ввод имени")
			mimic_voice = sanitize_name(tgui_input_text(user, "Введите имя для подражания", "Имитация голоса", max_length = MAX_NAME_LEN))
			if(!mimic_voice)
				return
			if(GLOB.human_to_tts[mimic_voice])
				mimic_tts_seed = GLOB.human_to_tts[mimic_voice]
			else
				var/mimic_tts_seed_name = tgui_input_list(user, "Выберите TTS голос для подражания", "Имитация голоса", SStts220.get_available_seeds(user))
				mimic_tts_seed = SStts220.tts_seeds[mimic_tts_seed_name]
	// BANDASTATION EDIT END
	..()
	changeling.mimicing = mimic_voice
	changeling.chem_recharge_slowdown += 0.25
	to_chat(user, span_notice("We shape our glands to take the voice of <b>[mimic_voice]</b>, this will slow down regenerating chemicals while active."))
	to_chat(user, span_notice("Use this power again to return to our original voice and return chemical production to normal levels."))
	RegisterSignal(user, COMSIG_TTS_COMPONENT_PRE_CAST_TTS, PROC_REF(replace_tts_seed)) // BANDASTATION EDIT START - TTS
	return TRUE

/datum/action/changeling/mimicvoice/Remove(mob/user)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(changeling?.mimicing)
		changeling.chem_recharge_slowdown = max(0, changeling.chem_recharge_slowdown - 0.25)
		changeling.mimicing = ""
		to_chat(user, span_notice("Our vocal glands return to their original position."))
		UnregisterSignal(user, COMSIG_TTS_COMPONENT_PRE_CAST_TTS) // BANDASTATION EDIT START - TTS
	. = ..()

// BANDASTATION EDIT START - TTS
/datum/action/changeling/mimicvoice/proc/replace_tts_seed(mob/user, list/tts_args)
	SIGNAL_HANDLER
	if(tts_args[TTS_PRIORITY] < TTS_PRIORITY_MIMIC)
		tts_args[TTS_CAST_SEED] = mimic_tts_seed || tts_args[TTS_CAST_SEED]
// BANDASTATION EDIT END
