/atom/movable/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return
	if(href_list[VV_HK_SELECT_TTS_VOICE] && check_rights(R_VAREDIT))
		change_tts_seed(usr, TRUE, TRUE)

/atom/movable/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_SELECT_TTS_VOICE, "Change TTS")
