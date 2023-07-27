/atom/movable/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return
	if(href_list[VV_HK_SELECT_TTS_VOICE] && check_rights(R_VAREDIT))
		var/selected_tts_seed = tgui_input_list(usr, "Select a TTS voice to change to", "[src.name] TTS voice selection", SStts220.tts_seeds_names)
		if(selected_tts_seed)
			tts_seed = selected_tts_seed

/atom/movable/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_SELECT_TTS_VOICE, "Select TTS voice")
