// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX

/// Returns a list of vox sounds based on the sound_type passed in
/mob/living/silicon/ai/proc/get_vox_sounds(vox_type)
	switch(vox_type)
		if(VOX_NORMAL)
			return GLOB.vox_sounds
		if(VOX_HL)
			return GLOB.vox_sounds_hl
		if(VOX_BMS)
			return GLOB.vox_sounds_bms
		if(VOX_MIL)
			return GLOB.vox_sounds_mil
	return GLOB.vox_sounds

/mob/living/silicon/ai/verb/switch_vox()
	set name = "Switch Vox Voice"
	set desc = "Switch your VOX announcement voice!"
	set category = "AI Commands"

	if(incapacitated)
		return
	var/selection = tgui_input_list(src, "Пожалуйста, выберите новый VOX голос:", "VOX VOICE", vox_voices)
	if(isnull(selection))
		return
	vox_type = selection

	to_chat(src, span_info("VOX голос изменен на [vox_type]."))

#endif
